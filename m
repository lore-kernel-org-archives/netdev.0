From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet Bridging: Enable Hardware Checksumming)
Date: Fri, 20 May 2005 13:54:46 -0500
Message-ID: <200505201354.46824.jdmason@us.ibm.com>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro> <20050519214015.GA19961@us.ibm.com> <Pine.LNX.4.62.0505200858480.12681@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505200858480.12681@webhosting.rdsbv.ro>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 20 May 2005 01:07 am, Catalin(ux aka Dino) BOIE wrote:
> >> +static inline void br_features_change(struct net_bridge *br, struct
> >> net_device *dev) +{
> >> +	br->dev->features &= dev->features | ~BR_FEAT_MASK;
> >
> > ~BR_FEAT_MASK isn't necessary. Either you wanted to do an '&' just
> > before it, so that BR_FEAT_MASK features are the only ones that you want
> > or you are enabling features that aren't necessarily supported by the
> > adapter/driver (like LLTX and HW_VLAN stuff).
>
> So, I invert BR_FEAT_MASK so I can, by default clear special features.
> Then I ored with dev->features, so I can enable special features if the
> slave device supports it. Then, I do & so I can clear stuff that is not
> supported by device, but the rest of br->dev features remains untouched.
>
> Let's test: if dev hash SG the code is like this:
> BR_FEAT_MASK = 1001 (only test SG and HW_CSUM)
> # br is inited
> br |= 1001
> br &= 0001 | ~1001
> br &= 0001 | 0110
> br &= 0111
> br = 1001 & 0111 = 0001 - so bit SG is set also in br. But not HW_CSUM
> because it's not in device.
>
> I can't see the code is wrong. Can you give me an example when it fails,
> please?

Let's use the full BR_FEAT_MASK of NETIF_F_HW_CSUM | NETIF_F_SG |                       
| NETIF_F_FRAGLIST | NETIF_F_IP_CSUM | NETIF_F_HIGHDMA | NETIF_F_TSO).
That is 0011 0000 0110 1011

Now, let's assume that the NIC only has NETIF_F_TSO, 
NETIF_F_IP_CSUM, and NETIF_F_SG enabled.
So, that is 0000 1000 0000 0011

So, we have the following:
For the first adapter added:
br = 0001 1000 0110 1011
br = 0001 1000 0110 1011 & 0000 1000 0000 0011 | ~0001 1000 0110 1011
br = 0001 1000 0110 1011 & 0000 1000 0000 0011 | 1110 0111 1001 0100
br = 0000 1000 0000 0011 | 1110 0111 1001 0100
br = 1110 1111 1001 0111
Note - this breaks down to the following being enabled:
NETIF_F_SG
NETIF_F_IP_CSUM  
NETIF_F_NO_CSUM
UNDEFINED BIT
NETIF_F_HW_VLAN_RX
NETIF_F_HW_VLAN_FILTER 
NETIF_F_VLAN_CHALLENGED
NETIF_F_TSO 
NETIF_F_LLTX 

For a second adapter with the same features added:
br = 1110 1111 1001 0111
br = 1110 1111 1001 0111 & 0000 1000 0000 0011 | 1110 0111 1001 0100
br = 1110 1111 1001 0111 | 1110 0111 1001 0100
br = 1110 1111 1001 0111

So, NETIF_F_HW_VLAN_RX, NETIF_F_HW_VLAN_FILTER, NETIF_F_VLAN_CHALLENGED, and 
NETIF_F_LLTX will be enabled, and they might not be enabled/supported.  If 
you take out the ~BR_FEAT_MASK then it will behave as I would expect 
(verified with printks on the last patch).

On a side note:  Wouldn't it make more sense to have NETIF_F_TSO defined as 16 
in include/linux/netdevice.h (as it would be grouped with the other hardware 
offload bits and the bit is free).

> >> +}
> >> +
> >> +/*
> >> + * Recomputes features using slave's features
> >> + */
> >> +static void br_features_recompute(struct net_bridge *br)
> >> +{
> >> +	struct net_bridge_port *p;
> >> +
> >> +	br->dev->features |= BR_FEAT_MASK;
> >
> > The OR is not needed.  Just re-initialize features to BR_FEAT_MASK and
> > everything will take case of itself.
>
> Nope. Not correct. Because we might enable LLTX on the bridge, but not in
> BR_FEAT_MASK.

This is not the case.  This is the same as re-doing the entire feature list 
(as if it was being done initially).  All that needs to be done is for 
br->dev->features to have a initial value.

> I will post a patch in few hours with all stuff updated.

Great.  Thanks.

Thanks,
Jon
