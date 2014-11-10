From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [patch net-next v2 02/10] net: introduce generic switch devices
 support
Date: Mon, 10 Nov 2014 13:59:38 -0800
Message-ID: <5461354A.3020906@gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvac
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:60599 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbaKJWAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 17:00:15 -0500
Received: by mail-oi0-f53.google.com with SMTP id a141so6185260oig.12
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 14:00:15 -0800 (PST)
In-Reply-To: <1415530280-9190-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2014 02:51 AM, Jiri Pirko wrote:
> The goal of this is to provide a possibility to support various switch
> chips. Drivers should implement relevant ndos to do so. Now there is
> only one ndo defined:
> - for getting physical switch id is in place.
>
> Note that user can use random port netdevice to access the switch.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   Documentation/networking/switchdev.txt | 59 ++++++++++++++++++++++++++++++++++
>   MAINTAINERS                            |  7 ++++
>   include/linux/netdevice.h              | 10 ++++++
>   include/net/switchdev.h                | 30 +++++++++++++++++
>   net/Kconfig                            |  1 +
>   net/Makefile                           |  3 ++
>   net/switchdev/Kconfig                  | 13 ++++++++
>   net/switchdev/Makefile                 |  5 +++
>   net/switchdev/switchdev.c              | 33 +++++++++++++++++++
>   9 files changed, 161 insertions(+)
>   create mode 100644 Documentation/networking/switchdev.txt
>   create mode 100644 include/net/switchdev.h
>   create mode 100644 net/switchdev/Kconfig
>   create mode 100644 net/switchdev/Makefile
>   create mode 100644 net/switchdev/switchdev.c
>
> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> new file mode 100644
> index 0000000..98be76c
> --- /dev/null
> +++ b/Documentation/networking/switchdev.txt
> @@ -0,0 +1,59 @@
> +Switch (and switch-ish) device drivers HOWTO
> +===========================
> +
> +Please note that the word "switch" is here used in very generic meaning.
> +This include devices supporting L2/L3 but also various flow offloading chips,
> +including switches embedded into SR-IOV NICs.
> +
> +Lets describe a topology a bit. Imagine the following example:
> +
> +       +----------------------------+    +---------------+
> +       |     SOME switch chip       |    |      CPU      |
> +       +----------------------------+    +---------------+
> +       port1 port2 port3 port4 MNGMNT    |     PCI-E     |
> +         |     |     |     |     |       +---------------+
> +        PHY   PHY    |     |     |         |  NIC0 NIC1
> +                     |     |     |         |   |    |
> +                     |     |     +- PCI-E -+   |    |
> +                     |     +------- MII -------+    |
> +                     +------------- MII ------------+
> +
> +In this example, there are two independent lines between the switch silicon
> +and CPU. NIC0 and NIC1 drivers are not aware of a switch presence. They are
> +separate from the switch driver. SOME switch chip is by managed by a driver
> +via PCI-E device MNGMNT. Note that MNGMNT device, NIC0 and NIC1 may be
> +connected to some other type of bus.
> +
> +Now, for the previous example show the representation in kernel:
> +
> +       +----------------------------+    +---------------+
> +       |     SOME switch chip       |    |      CPU      |
> +       +----------------------------+    +---------------+
> +       sw0p0 sw0p1 sw0p2 sw0p3 MNGMNT    |     PCI-E     |
> +         |     |     |     |     |       +---------------+
> +        PHY   PHY    |     |     |         |  eth0 eth1
> +                     |     |     |         |   |    |
> +                     |     |     +- PCI-E -+   |    |
> +                     |     +------- MII -------+    |
> +                     +------------- MII ------------+
> +
> +Lets call the example switch driver for SOME switch chip "SOMEswitch". This
> +driver takes care of PCI-E device MNGMNT. There is a netdevice instance sw0pX
> +created for each port of a switch. These netdevices are instances
> +of "SOMEswitch" driver. sw0pX netdevices serve as a "representation"
> +of the switch chip. eth0 and eth1 are instances of some other existing driver.
> +
> +The only difference of the switch-port netdevice from the ordinary netdevice
> +is that is implements couple more NDOs:
> +
> +	ndo_sw_parent_get_id - This returns the same ID for two port netdevices
> +			       of the same physical switch chip. This is
> +			       mandatory to be implemented by all switch drivers
> +			       and serves the caller for recognition of a port
> +			       netdevice.

What is the connection between ndo_sw_parent_get_id and
ndo_get_phys_port_id(). I'm having a bit of trouble teasing
this out.

For example here is my ascii art for a SR-IOV NIC,

        eth0     eth1     eth2
         |         |        |
         |         |        |
         PF        VF       VF
    +----+---------+--------+----+
    |       embedded bridge      |
    +-------------+--------------+
                  |
                 port

that can do switching between the various uplinks and downlinks.
In IEEE 802.1Q language the embedded bridge acts like an edge
relay. At least that seems to be the current state of the art
for SR-IOV. Edge relay just means it has a single uplink port
to the network and multiple downlinks and also isn't required
to do learning and run loop detection protocols STP, et. al.

Also there are multi-function devices that look the same except
replace the VFs with PFs. It seems to be a common mode for NICs
that do the iSCSI offloads with storage functions.

When something is an embedded bridge vs a SOME switch chip is
not entirely clear.

My understanding is use ndo_sw_parent_get_id() when you have
multiple physical ports all connected to a single switch object.
When you have a single port connected to multiple PCIE functions
or queues representing a netdev (e.g. macvlan offload) use the
ndo_get_phys_port_id(). Just want to be sure we are on the
same page here.

Otherwise patch looks good. I think we can clear the above up
with an addition to the documentation. Could go in after the
initial set and be OK with me.

IMO this patch is needed otherwise user space is at a complete
loss on trying to figure out how netdevs map to switch silicon.
You could have reused ndo_get_phys_port_id() perhaps but then
I think user space may get confused by SR-IOV/VMDQ/etc ports
attached to a switch silicon. For .02$ having a new distinct
identifier is cleaner.


> +	ndo_sw_parent_* - Functions that serve for a manipulation of the switch
> +			  chip itself (it can be though of as a "parent" of the
> +			  port, therefore the name). They are not port-specific.
> +			  Caller might use arbitrary port netdevice of the same
> +			  switch and it will make no difference.
> +	ndo_sw_port_* - Functions that serve for a port-specific manipulation.

[...]

Thanks,
John


-- 
John Fastabend         Intel Corporation
