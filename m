From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] net/cpsw: redo rx skb allocation in rx path
Date: Thu, 18 Apr 2013 07:59:52 -0700
Message-ID: <1366297192.3205.51.camel@edumazet-glaptop>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de>
	 <1366235536-15744-6-git-send-email-bigeasy@linutronix.de>
	 <516FDE20.2050605@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:60233 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966492Ab3DRO7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:59:54 -0400
Received: by mail-pd0-f173.google.com with SMTP id v14so1605603pde.32
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:59:54 -0700 (PDT)
In-Reply-To: <516FDE20.2050605@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-18 at 17:20 +0530, Mugunthan V N wrote:
> On 4/18/2013 3:22 AM, Sebastian Andrzej Siewior wrote:
> > In case that we run into OOM during the allocation of the new rx-skb we
> > don't get one and we have one skb less than we used to have. If this
> > continues to happen then we end up with no rx-skbs at all.
> > This patch changes the following:
> > - if we fail to allocate the new skb, then we treat the currently
> >    completed skb as the new one and so drop the currently received data.
> > - instead of testing multiple times if the device is gone we rely one
> >    the status field which is set to -ENOSYS in case the channel is going
> >    down and incomplete requests are purged.
> >    cpdma_chan_stop() removes most of the packages with -ENOSYS. The
> >    currently active packet which is removed has the "tear down" bit set.
> >    So if that bit is set, we send ENOSYS as well otherwise we pass the
> >    status bits which are required to figure out which of the two possible
> >    just finished.
> >
> > Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> > ---
> >   drivers/net/ethernet/ti/cpsw.c          |   33 ++++++++++++-------------------
> >   drivers/net/ethernet/ti/davinci_cpdma.c |    7 ++++++-
> >   2 files changed, 19 insertions(+), 21 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> > index 559b020..f684e9b 100644
> > --- a/drivers/net/ethernet/ti/cpsw.c
> > +++ b/drivers/net/ethernet/ti/cpsw.c
> > @@ -469,43 +469,36 @@ void cpsw_tx_handler(void *token, int len, int status)
> >   void cpsw_rx_handler(void *token, int len, int status)
> >   {
> >   	struct sk_buff		*skb = token;
> > +	struct sk_buff		*new_skb;
> >   	struct net_device	*ndev = skb->dev;
> >   	struct cpsw_priv	*priv = netdev_priv(ndev);
> >   	int			ret = 0;
> >   
> >   	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
> >   
> > -	/* free and bail if we are shutting down */
> > -	if (unlikely(!netif_running(ndev)) ||
> > -			unlikely(!netif_carrier_ok(ndev))) {
> > +	if (unlikely(status < 0)) {
> > +		/* the interface is going down, skbs are purged */
> >   		dev_kfree_skb_any(skb);
> >   		return;
> >   	}
> > -	if (likely(status >= 0)) {
> > +
> > +	new_skb = netdev_alloc_skb_ip_align(ndev, priv->rx_packet_max);
> > +	if (new_skb) {
> >   		skb_put(skb, len);
> >   		cpts_rx_timestamp(priv->cpts, skb);
> >   		skb->protocol = eth_type_trans(skb, ndev);
> >   		netif_receive_skb(skb);
> >   		priv->stats.rx_bytes += len;
> >   		priv->stats.rx_packets++;
> > -		skb = NULL;
> > -	}
> > -
> > -	if (unlikely(!netif_running(ndev))) {
> > -		if (skb)
> > -			dev_kfree_skb_any(skb);
> > -		return;
> > +	} else {
> > +		priv->stats.rx_dropped++;
> > +		new_skb = skb;
> Why you want to drop a successfully received packet as you memory alloc 
> failed?
> Let the stack get it processed and there after you can continue with one 
> less
> rx skb

Have you read the changelog at all ?

This patch sounds quite correct to me.

If you cannot allocate a new skb, then drop the incoming frame, instead
of dealing with strange allocation retries later.
