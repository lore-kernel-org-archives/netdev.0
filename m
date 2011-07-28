From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC net-next PATCH 3/4] ethtool: Add new set commands
Date: Thu, 28 Jul 2011 13:38:31 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019414D86D@orsmsx508.amr.corp.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
 <20110727221759.8435.11589.stgit@gitlad.jf.intel.com>
 <20110727.222749.1654973220321763098.davem@davemloft.net>
 <43F901BD926A4E43B106BF17856F0755019414D509@orsmsx508.amr.corp.intel.com>
 <539DF151-E442-4375-8777-19676B95059B@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12288 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919Ab1G1Uie convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 16:38:34 -0400
In-Reply-To: <539DF151-E442-4375-8777-19676B95059B@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Anirban Chakraborty [mailto:anirban.chakraborty@qlogic.com] 
> Sent: Thursday, July 28, 2011 12:04 PM
> To: Rose, Gregory V
> Cc: David Miller; netdev; Ben Hutchings; Kirsher, Jeffrey T
> Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> 
> 
> On Jul 28, 2011, at 8:51 AM, Rose, Gregory V wrote:
> 
> 
> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, July 27, 2011 10:28 PM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com; Kirsher, Jeffrey T
> Subject: Re: [RFC net-next PATCH 3/4] ethtool: Add new set commands
> 
> From: Greg Rose <gregory.v.rose@intel.com>
> Date: Wed, 27 Jul 2011 15:17:59 -0700
> 
> Add new set commands to configure the number of SR-IOV VFs, the
> number of VM queues and spoof checking on/off switch.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> ---
> 
> include/linux/ethtool.h |   11 ++++++++++-
> 1 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index c6e427a..c4972ba 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -36,12 +36,14 @@ struct ethtool_cmd {
> 	__u8	mdio_support;
> 	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
> 	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
> +	__u32	num_vfs;	/* Enable SR-IOV VFs */
> +	__u32	num_vmqs;	/* Set number of queues for VMDq */
> 
> You can't change the layout of this datastructure in this way without
> breaking every ethtool binary out there.
> 
> You have to find another place to add these knobs.
> 
> Perhaps at the end of the ethtool_cmd structure?  Something like this:
> 
> /* This should work for both 32 and 64 bit userland. */
> struct ethtool_cmd {
>        __u32   cmd;
>        __u32   supported;      /* Features this interface supports */
>        __u32   advertising;    /* Features this interface advertises */
>        __u16   speed;          /* The forced speed (lower bits) in
>                                 * Mbps. Please use
>                                 * ethtool_cmd_speed()/_set() to
>                                 * access it */
>        __u8    duplex;         /* Duplex, half or full */
>        __u8    port;           /* Which connector port */
>        __u8    phy_address;
>        __u8    transceiver;    /* Which transceiver to use */
>        __u8    autoneg;        /* Enable or disable autonegotiation */
>        __u8    mdio_support;
>        __u32   maxtxpkt;       /* Tx pkts before generating tx int */
>        __u32   maxrxpkt;       /* Rx pkts before generating rx int */
>        __u16   speed_hi;       /* The forced speed (upper
>                                 * bits) in Mbps. Please use
>                                 * ethtool_cmd_speed()/_set() to
>                                 * access it */
>        __u8    eth_tp_mdix;
>        __u8    spoof_check;    /* Enable/Disable anti-spoofing */
>        __u32   lp_advertising; /* Features the link partner advertises */
>        __u32   reserved[2];
>        __u32   num_vfs;        /* Enable SR-IOV VFs */
>        __u32   num_vmqs;       /* Set number of queues for VMDq */
> };
> 
> If I understood it correctly, you are trying to set/unset spoofing on per
> eth interface,  which could be a PF on the hypervisor or a pci passthru-ed
> VF in the linux guest.  There are other security features that one could set
> for a port on the VF (lets call it vport),  e.g. setting a port VLAN ID for
> a VF and specifying if the VF (VM) is allowed to send tagged/untagged
> packets, setting a vport in port mirroring mode so that the PF can monitor
> the traffic on a VF,  setting a vport in promiscuous mode etc. 
> 
> Does it make sense to try to use ip link util to specify all these parameters,
> since ip link already does the  job of setting VF properties and VF port
> profile?
> 
> Any thoughts?
> 

Sure, that's a possibility too.  I was considering ethtool for this since MAC addresses and VLANs are fairly specific to Ethernet whereas netlink might apply to other types of physical networks.  At least that's my understanding.

However, I have no strong feelings about it and if community consensus is to use ip link instead then that's fine by me.

Of course, patches implementing such would be quite welcome also.

;^)

- Greg

