From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v7 9/9] xen-netback: Aggregate TX unmap
 operations
Date: Thu, 20 Mar 2014 09:53:12 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD029201D@AMSPEX01CL01.citrite.net>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
 <1394142511-14827-10-git-send-email-zoltan.kiss@citrix.com>
 <532A0915.5090006@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Jonathan Davies" <Jonathan.Davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:41054 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733AbaCTJxP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 05:53:15 -0400
In-Reply-To: <532A0915.5090006@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Zoltan Kiss
> Sent: 19 March 2014 21:16
> To: Ian Campbell; Wei Liu; xen-devel@lists.xenproject.org
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jonathan Davies;
> Paul Durrant
> Subject: Re: [PATCH net-next v7 9/9] xen-netback: Aggregate TX unmap
> operations
> 
> Hi,
> 
> I'm thinking about revoking this patch: it's value is pretty small, but
> it causes performance regression on Win7 guests. And probably it is not
> the best solution for this problem. It might be the delay it takes the
> dealloc thread to be scheduled is enough.
> What do you think?
> 

Yes, I think we need a revert to fix the performance regression. As I understand things, it's sufficiently bad that we would not want to take the grant mapping series into XenServer without the reversion.

  Paul

> Zoli
> 
> On 06/03/14 21:48, Zoltan Kiss wrote:
> > Unmapping causes TLB flushing, therefore we should make it in the largest
> > possible batches. However we shouldn't starve the guest for too long. So if
> > the guest has space for at least two big packets and we don't have at least a
> > quarter ring to unmap, delay it for at most 1 milisec.
> >
> > Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> > ---
> > v4:
> > - use bool for tx_dealloc_work_todo
> >
> > v6:
> > - rebase tx_dealloc_work_todo due to missing ;
> >
> > diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-
> netback/common.h
> > index d1cd8ce..95498c8 100644
> > --- a/drivers/net/xen-netback/common.h
> > +++ b/drivers/net/xen-netback/common.h
> > @@ -118,6 +118,8 @@ struct xenvif {
> >   	u16 dealloc_ring[MAX_PENDING_REQS];
> >   	struct task_struct *dealloc_task;
> >   	wait_queue_head_t dealloc_wq;
> > +	struct timer_list dealloc_delay;
> > +	bool dealloc_delay_timed_out;
> >
> >   	/* Use kthread for guest RX */
> >   	struct task_struct *task;
> > diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
> netback/interface.c
> > index 40aa500..f925af5 100644
> > --- a/drivers/net/xen-netback/interface.c
> > +++ b/drivers/net/xen-netback/interface.c
> > @@ -407,6 +407,7 @@ struct xenvif *xenvif_alloc(struct device *parent,
> domid_t domid,
> >   			  .desc = i };
> >   		vif->grant_tx_handle[i] = NETBACK_INVALID_HANDLE;
> >   	}
> > +	init_timer(&vif->dealloc_delay);
> >
> >   	/*
> >   	 * Initialise a dummy MAC address. We choose the numerically
> > @@ -557,6 +558,7 @@ void xenvif_disconnect(struct xenvif *vif)
> >   	}
> >
> >   	if (vif->dealloc_task) {
> > +		del_timer_sync(&vif->dealloc_delay);
> >   		kthread_stop(vif->dealloc_task);
> >   		vif->dealloc_task = NULL;
> >   	}
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> netback/netback.c
> > index bb65c7c..c098276 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -135,6 +135,11 @@ static inline pending_ring_idx_t
> nr_pending_reqs(struct xenvif *vif)
> >   		vif->pending_prod + vif->pending_cons;
> >   }
> >
> > +static inline pending_ring_idx_t nr_free_slots(struct
> xen_netif_tx_back_ring *ring)
> > +{
> > +	return ring->nr_ents -	(ring->sring->req_prod - ring-
> >rsp_prod_pvt);
> > +}
> > +
> >   bool xenvif_rx_ring_slots_available(struct xenvif *vif, int needed)
> >   {
> >   	RING_IDX prod, cons;
> > @@ -1932,9 +1937,36 @@ static inline int tx_work_todo(struct xenvif *vif)
> >   	return 0;
> >   }
> >
> > +static void xenvif_dealloc_delay(unsigned long data)
> > +{
> > +	struct xenvif *vif = (struct xenvif *)data;
> > +
> > +	vif->dealloc_delay_timed_out = true;
> > +	wake_up(&vif->dealloc_wq);
> > +}
> > +
> >   static inline bool tx_dealloc_work_todo(struct xenvif *vif)
> >   {
> > -	return vif->dealloc_cons != vif->dealloc_prod;
> > +	if (vif->dealloc_cons != vif->dealloc_prod) {
> > +		if ((nr_free_slots(&vif->tx) > 2 *
> XEN_NETBK_LEGACY_SLOTS_MAX) &&
> > +		    (vif->dealloc_prod - vif->dealloc_cons <
> MAX_PENDING_REQS / 4) &&
> > +		    !vif->dealloc_delay_timed_out) {
> > +			if (!timer_pending(&vif->dealloc_delay)) {
> > +				vif->dealloc_delay.function =
> > +					xenvif_dealloc_delay;
> > +				vif->dealloc_delay.data = (unsigned long)vif;
> > +				mod_timer(&vif->dealloc_delay,
> > +					  jiffies + msecs_to_jiffies(1));
> > +
> > +			}
> > +			return false;
> > +		}
> > +		del_timer_sync(&vif->dealloc_delay);
> > +		vif->dealloc_delay_timed_out = false;
> > +		return true;
> > +	}
> > +
> > +	return false;
> >   }
> >
> >   void xenvif_unmap_frontend_rings(struct xenvif *vif)
> >
