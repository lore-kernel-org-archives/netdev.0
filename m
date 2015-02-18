From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH next v4 6/6] bonding: Implement user key part of port_key
 in an AD system.
Date: Wed, 18 Feb 2015 13:56:19 +0100
Message-ID: <54E48BF3.6080305@redhat.com>
References: <1424243878-27212-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbbBRM4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2015 07:56:30 -0500
In-Reply-To: <1424243878-27212-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/18/2015 08:17 AM, Mahesh Bandewar wrote:
> The port key has three components - user-key, speed-part, and duplex-part.
> The LSBit is for the duplex-part, next 5 bits are for the speed while the
> remaining 10 bits are the user defined key bits. Get these 10 bits
> from the user-space (through the SysFs interface) and use it to form the
> admin port-key. Allowed range for the user-key is 0 - 1023 (10 bits). If
> it is not provided then use zero for the user-key-bits (default).
> 
> It can set using following example code -
> 
>    # modprobe bonding mode=4
>    # usr_port_key=$(( RANDOM & 0x3FF ))
>    # echo $usr_port_key > /sys/class/net/bond0/bonding/ad_user_port_key
>    # echo +eth1 > /sys/class/net/bond0/bonding/slaves
>    ...
>    # ip link set bond0 up
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1:
>   Initial version
> v2:
>   Renamed ad_actor_user_port_key ad_user_port_key
> v3-v4:
>   Rebase
> 
>  Documentation/networking/bonding.txt | 62 ++++++++++++++++++++++++++++++++++++
>  drivers/net/bonding/bond_3ad.c       | 14 ++++----
>  drivers/net/bonding/bond_main.c      | 10 ++++++
>  drivers/net/bonding/bond_options.c   | 26 +++++++++++++++
>  drivers/net/bonding/bond_sysfs.c     | 15 +++++++++
>  include/net/bond_options.h           |  1 +
>  include/net/bonding.h                |  1 +
>  7 files changed, 122 insertions(+), 7 deletions(-)
> 
> diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
> index f0d93c58cdb0..da22956b408f 100644
> --- a/Documentation/networking/bonding.txt
> +++ b/Documentation/networking/bonding.txt
> @@ -51,6 +51,7 @@ Table of Contents
>  3.4	Configuring Bonding Manually via Sysfs
>  3.5	Configuration with Interfaces Support
>  3.6	Overriding Configuration for Special Cases
> +3.7 Configuring LACP for 802.3ad mode in a more secure way
>  
>  4. Querying Bonding Configuration
>  4.1	Bonding Configuration
> @@ -241,6 +242,21 @@ ad_select
>  
>  	This option was added in bonding version 3.4.0.
>  
> +ad_user_port_key
> +
> +	In an AD system, the port-key has three parts as shown below -
> +
> +	   Bits   Use
> +	   00     Duplex
> +	   01-05  Speed
> +	   06-15  User-defined
> +
> +	This defines the upper 10 bits of the port key. The values can be
> +	from 0 - 1023. If not given, the system defaults to 0.
> +
> +	This paramter has effect only in 802.3ad mode and is available through
^^^^^^^^^^^
s/paramter/parameter/

> +	SysFs interface.
> +
>  all_slaves_active
>  
>  	Specifies that duplicate frames (received on inactive ports) should be
> @@ -1643,6 +1659,52 @@ output port selection.
>  This feature first appeared in bonding driver version 3.7.0 and support for
>  output slave selection was limited to round-robin and active-backup modes.
>  
> +3.7 Configuring LACP for 802.3ad mode in a more secure way
> +----------------------------------------------------------
> +
> +When using 802.3ad bonding mode, the Actor (host) and Partner (switch)
> +exchange LACPDUs.  These LACPDUs cannot be sniffed, because they are
> +destined to link local mac addresses (which switches/bridges are not
> +supposed to forward).  However, most of the values are easily predictable
> +or are simply the machine's MAC address (which is trivially known to all
> +other hosts in the same L2).  This implies that other machines in the L2
> +domain can spoof LACPDU packets from other hosts to the switch and potentially
> +cause mayhem by joining (from the point of view of the switch) another
> +machine's aggregate, thus receiving a portion of that hosts incoming
> +traffic and / or spoofing traffic from that machine themselves (potentially
> +even successfully terminating some portion of flows). Though this is not
> +a likely scenario, one could avoid this possibility by simply configuring
> +few bonding parameters:
> +
> +   (a) ad_actor_system : You can set a random mac-address that can be used for
> +       these LACPDU exchanges. The value can not be either NULL or Multicast.
> +       Also it's preferable to set the local-admin bit. This can be done using
> +       the following shell code -
> +
> +       # sys_mac_addr=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
> +                                $(( (RANDOM & 0xFE) | 0x02 )) \
> +                                $(( RANDOM & 0xFF )) \
> +                                $(( RANDOM & 0xFF )) \
> +                                $(( RANDOM & 0xFF )) \
> +                                $(( RANDOM & 0xFF )) \
> +                                $(( RANDOM & 0xFF )))
> +       # echo $sys_mac_addr > /sys/class/net/bond0/bonding/ad_actor_system
> +
> +   (b) ad_actor_sys_prio : Randomize the system priority. The default value
> +       is 65535, but system can take the value from 1 - 65535. You can do this
> +       this using the following shell code -
> +
> +       # sys_prio=$(( 1 + RANDOM + RANDOM ))
> +       # echo $sys_prio > /sys/class/net/bond0/bonding/ad_actor_sys_prio
> +
> +   (c) ad_user_port_key : Use the user portion of the port-key. The default
> +       keeps this empty. These the upper 10 bits of the port-key and value
                            ^^^^^^^^^^^^^^^^^^
These are ?

> +       ranges from 0 - 1023. You can do this using the following shell code -
> +
> +       # usr_port_key=$(( RANDOM & 0x3FF ))
> +       # echo $usr_port_key > /sys/class/net/bond0/bonding/ad_user_port_key
> +
> +
