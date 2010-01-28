From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [RFC] [PATCH] net: Add support for ndo_select_queue()	functions to
 cache the queue mapping
Date: Fri, 29 Jan 2010 00:11:42 +0530
Message-ID: <OFC8D29372.BEB60058-ON652576B9.00642767-652576B9.00659789@in.ibm.com>
References: <1264700317.2783.15.camel@achroite.uk.solarflarecom.com>	 <OF2C36A392.08814AE1-ON652576B9.00617C98-652576B9.0062AE8B@in.ibm.com> <1264702224.2783.18.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:34514 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755570Ab0A1S3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 13:29:43 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp06.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0SITffK017182
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 23:59:41 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0SITfaK2838602
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 23:59:41 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0SITe3Q013290
	for <netdev@vger.kernel.org>; Thu, 28 Jan 2010 23:59:41 +0530
In-Reply-To: <1264702224.2783.18.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ben Hutchings <bhutchings@solarflare.com>
>
> On Thu, 2010-01-28 at 23:39 +0530, Krishna Kumar2 wrote:
> > > Ben Hutchings <bhutchings@solarflare.com>
> > >
> > > We think it's worth matching up RX and TX queue selection for a
socket
> > > when the queues share an interrupt.  Currently the default TX queue
> > > selection is unlikely to match RX queue selection.  TX queue
selectionc
> > > can be overridden by the driver to match RX queue selection, but at
the
> > > expense of caching.  We found that without caching the cost of
> > > recalculating the the hash in software for each packet outweighed the
> > > benefit of good queue selection.
> > >
> > > This adds two simple helper functions: sk_may_set_tx_queue() reports
> > > whether the queue mapping should be cacheable for a socket, and
> > > netif_sk_tx_queue_set() sets it after validating the queue index.
This
> > > will allow drivers to evalulate expensive queue selection functions
> > > (such as Toeplitz hash functions) only once for connected sockets,
and
> > > to avoid doing so for other skbs.
> [...]
> > I am confused about this - isn't the txq# and rxq# already
> > matched due to the check for skb_rx_queue_recorded?
>
> When forwarding, yes.
>
> > sk_dst_cache is also not set for these routing/forwarding
> > workloads, this can be relied only for locally connected
> > xmits.
>
> Correct, that's exactly what it's for.
>
> > Other than that, I saw netif_sk_tx_queue_set is not called.
> > And dev_pick_tx has already capped automatically, you probably
> > don't need another here?
>
> Only the return value of ndo_select_queue() is capped; the cached value
> is assumed to be valid.

+void netif_sk_tx_queue_set(struct net_device *dev, struct sock *sk,
+                             u16 queue_index)
+{
+     sk_tx_queue_set(sk, dev_cap_txqueue(dev, queue_index));
+}

I guess I didn't understand this then, who calls this function? Is
it after getting the txq from the driver? In which case, are you
planning to do something like:

static struct netdev_queue *dev_pick_tx(struct net_device *dev,
                                        struct sk_buff *skb)
{
      u16 queue_index;
      struct sock *sk = skb->sk;

      if (sk_tx_queue_recorded(sk)) {
            queue_index = sk_tx_queue_get(sk);
      } else {
            const struct net_device_ops *ops = dev->netdev_ops;

            if (ops->ndo_select_queue) {
                  queue_index = ops->ndo_select_queue(dev, skb);
                  queue_index = dev_cap_txqueue(dev, queue_index);
            } else {
                  queue_index = 0;
                  if (dev->real_num_tx_queues > 1)
                        queue_index = skb_tx_hash(dev, skb); /*already
capped */
            }

            if (sk_may_set_tx_queue(sk))
                  sk_tx_queue_set(sk, queue_index);
        }
        skb_set_queue_mapping(skb, queue_index);
        return netdev_get_tx_queue(dev, queue_index);
}

Thanks,

- KK

