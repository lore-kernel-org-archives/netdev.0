From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] net: Add support for	ndo_select_queue()	functions to
 cache the queue mapping
Date: Fri, 29 Jan 2010 00:34:23 +0530
Message-ID: <OF88AC8A99.4F475BCE-ON652576B9.00674F3C-652576B9.0067AAF7@in.ibm.com>
References: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>	 <OF2C36A392.08814AE1-ON652576B9.00617C98-652576B9.0062AE8B@in.ibm.com>
	 <1264702224.2783.18.camel@achroite.uk.solarflarecom.com>	 <OFC8D29372.BEB60058-ON652576B9.00642767-652576B9.00659789@in.ibm.com> <1264704059.2783.50.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([122.248.162.5]:56679 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587Ab0A1Sw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:52:26 -0500
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp05.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0SIqNCg012165
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 00:22:23 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0SIqMqu2744382
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 00:22:22 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0SIqMoG011735
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 05:52:22 +1100
In-Reply-To: <1264704059.2783.50.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ben Hutchings <bhutchings@solarflare.com>
>
> Re: [RFC] [PATCH] net: Add support for ndo_select_queue() functions
> to cache the queue mapping
>
> On Fri, 2010-01-29 at 00:11 +0530, Krishna Kumar2 wrote:
> > > Ben Hutchings <bhutchings@solarflare.com>
> > >
> > > On Thu, 2010-01-28 at 23:39 +0530, Krishna Kumar2 wrote:
> [...]
> > > > Other than that, I saw netif_sk_tx_queue_set is not called.
> > > > And dev_pick_tx has already capped automatically, you probably
> > > > don't need another here?
> > >
> > > Only the return value of ndo_select_queue() is capped; the cached
value
> > > is assumed to be valid.
> >
> > +void netif_sk_tx_queue_set(struct net_device *dev, struct sock *sk,
> > +                             u16 queue_index)
> > +{
> > +     sk_tx_queue_set(sk, dev_cap_txqueue(dev, queue_index));
> > +}
> >
> > I guess I didn't understand this then, who calls this function?
> [...]
>
> The driver's ndo_select_queue() implementation calls it before
> returning, if and only if sk_may_set_tx_queue() is true and its
> selection is dependent only on the flow id.
>
> As an example, ixgbe's selection function:
>
>         static u16 ixgbe_select_queue(struct net_device *dev, struct
> sk_buff *skb)
>         {
>            struct ixgbe_adapter *adapter = netdev_priv(dev);
>            int txq = smp_processor_id();
>
>            if (adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE)
>               return txq;
>
>         #ifdef IXGBE_FCOE
>            if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
>                (skb->protocol == htons(ETH_P_FCOE))) {
>               txq &= (adapter->ring_feature[RING_F_FCOE].indices - 1);
>               txq += adapter->ring_feature[RING_F_FCOE].mask;
>               return txq;
>            }
>         #endif
>            if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
>               return (skb->vlan_tci & IXGBE_TX_FLAGS_VLAN_PRIO_MASK) >>
13;
>
>            return skb_tx_hash(dev, skb);
>         }
>
> would not call netif_sk_tx_queue_set() in the first two cases, but could
> do so in the last two cases if sk_may_set_tx_queue(skb->sk) is true.

That's a good optimization - saves calls to driver and hash
calculation for every skb (for devices that have select_txq
but find that they can cache after the first time).

Thanks,

- KK

