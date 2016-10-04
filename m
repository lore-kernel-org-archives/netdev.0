From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [Xen-devel] [PATCH v2 net-next 4/7] xen-netback: immediately wake
 tx queue when guest rx queue has space
Date: Tue, 4 Oct 2016 13:56:15 +0000
Message-ID: <136ea81c65e847719c787c37679f8da3@AMSPEX02CL03.citrite.net>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-5-git-send-email-paul.durrant@citrix.com>
 <20161004124854.GD30836@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        Wei Liu <wei.liu2@citrix.com>,
        David Vrabel <david.vrabel@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:20157 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbcJDOIF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 10:08:05 -0400
In-Reply-To: <20161004124854.GD30836@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Konrad Rzeszutek Wilk [mailto:konrad.wilk@oracle.com]
> Sent: 04 October 2016 13:49
> To: Paul Durrant <Paul.Durrant@citrix.com>
> Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Wei Liu
> <wei.liu2@citrix.com>; David Vrabel <david.vrabel@citrix.com>
> Subject: Re: [Xen-devel] [PATCH v2 net-next 4/7] xen-netback: immediately
> wake tx queue when guest rx queue has space
> 
> On Tue, Oct 04, 2016 at 02:29:15AM -0700, Paul Durrant wrote:
> > From: David Vrabel <david.vrabel@citrix.com>
> >
> > When an skb is removed from the guest rx queue, immediately wake the
> > tx queue, instead of after processing them.
> 
> Please, could the description explain why?
> 

Is it not reasonably obvious that it improves parallelism between filling and draining the queue? I could add a comment if you think it needs spelling out.

  Paul

> >
> > Signed-off-by: David Vrabel <david.vrabel@citrix.com> [re-based]
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > ---
> > Cc: Wei Liu <wei.liu2@citrix.com>
> > ---
> >  drivers/net/xen-netback/rx.c | 24 ++++++++----------------
> >  1 file changed, 8 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/net/xen-netback/rx.c
> > b/drivers/net/xen-netback/rx.c index b0ce4c6..9548709 100644
> > --- a/drivers/net/xen-netback/rx.c
> > +++ b/drivers/net/xen-netback/rx.c
> > @@ -92,27 +92,21 @@ static struct sk_buff *xenvif_rx_dequeue(struct
> xenvif_queue *queue)
> >  	spin_lock_irq(&queue->rx_queue.lock);
> >
> >  	skb = __skb_dequeue(&queue->rx_queue);
> > -	if (skb)
> > +	if (skb) {
> >  		queue->rx_queue_len -= skb->len;
> > +		if (queue->rx_queue_len < queue->rx_queue_max) {
> > +			struct netdev_queue *txq;
> > +
> > +			txq = netdev_get_tx_queue(queue->vif->dev,
> queue->id);
> > +			netif_tx_wake_queue(txq);
> > +		}
> > +	}
> >
> >  	spin_unlock_irq(&queue->rx_queue.lock);
> >
> >  	return skb;
> >  }
> >
> > -static void xenvif_rx_queue_maybe_wake(struct xenvif_queue *queue) -
> {
> > -	spin_lock_irq(&queue->rx_queue.lock);
> > -
> > -	if (queue->rx_queue_len < queue->rx_queue_max) {
> > -		struct net_device *dev = queue->vif->dev;
> > -
> > -		netif_tx_wake_queue(netdev_get_tx_queue(dev, queue-
> >id));
> > -	}
> > -
> > -	spin_unlock_irq(&queue->rx_queue.lock);
> > -}
> > -
> >  static void xenvif_rx_queue_purge(struct xenvif_queue *queue)  {
> >  	struct sk_buff *skb;
> > @@ -585,8 +579,6 @@ int xenvif_kthread_guest_rx(void *data)
> >  		 */
> >  		xenvif_rx_queue_drop_expired(queue);
> >
> > -		xenvif_rx_queue_maybe_wake(queue);
> > -
> >  		cond_resched();
> >  	}
> >
> > --
> > 2.1.4
> >
> >
> > _______________________________________________
> > Xen-devel mailing list
> > Xen-devel@lists.xen.org
> > https://lists.xen.org/xen-devel
