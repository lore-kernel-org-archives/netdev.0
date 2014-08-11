From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 2/3] xen-netback: don't stop dealloc
 kthread too early
Date: Mon, 11 Aug 2014 14:48:47 +0100
Message-ID: <20140811134847.GF3249@zion.uk.xensource.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
 <1407515833-2550-3-git-send-email-wei.liu2@citrix.com>
 <53E8B2A4.9070008@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:56476 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753492AbaHKNst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 09:48:49 -0400
Content-Disposition: inline
In-Reply-To: <53E8B2A4.9070008@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2014 at 01:10:12PM +0100, David Vrabel wrote:
> On 08/08/14 17:37, Wei Liu wrote:
[...]
> >  	if (tx_evtchn == rx_evtchn) {
> >  		/* feature-split-event-channels == 0 */
> > @@ -687,6 +700,9 @@ void xenvif_disconnect(struct xenvif *vif)
> >  			queue->task = NULL;
> >  		}
> >  
> > +		wait_event(queue->inflight_wq,
> > +			   atomic_read(&queue->inflight_packets) == 0);
> 
> Just make the dealloc task not stop unless it has deallocated all
> outstanding requests.  There's no need for another wait queue here.
> 

Are you suggesting something like

  while (atomic_read(&queue->inflight_packets) !=0)
  	schedule_timeout(SOME_TIMEOUT);

?

> > +
> >  		if (queue->dealloc_task) {
> >  			kthread_stop(queue->dealloc_task);
> >  			queue->dealloc_task = NULL;
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> > index 4734472..d2f0c7d7 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -107,6 +107,18 @@ static inline unsigned long idx_to_kaddr(struct xenvif_queue *queue,
> >  #define callback_param(vif, pending_idx) \
> >  	(vif->pending_tx_info[pending_idx].callback_struct)
> >  
> > +/* This function is used to set SKBTX_DEV_ZEROCOPY as well as
> > + * increasing the inflight counter. We need to increase the inflight
> > + * counter because core driver calls into xenvif_zerocopy_callback
> > + * which calls xenvif_dec_inflight_packets.
> > + */
> > +static void set_skb_zerocopy(struct xenvif_queue *queue,
> > +			     struct sk_buff *skb)
> > +{
> > +	skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> > +	xenvif_inc_inflight_packets(queue);
> > +}
> 
> This name makes this look like a core function instead of a netback
> specific one.
> 
> I would suggest a pair of functions:
> 
> xenvif_skb_zerocopy_prepare()
> xenvif_skb_zerocopy_complete()
> 

This will do.

Wei.

> Or similar.
> 
> David
