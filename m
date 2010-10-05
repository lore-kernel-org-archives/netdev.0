From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH] SIW: Object management
Date: Tue, 5 Oct 2010 16:56:33 +0200
Message-ID: <OF706D1D5F.5849676F-ONC12577B3.004FB763-C12577B3.00521572@ch.ibm.com>
References: <1286261665-5175-1-git-send-email-bmt@zurich.ibm.com> <4CAB35A8.6080906@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4CAB35A8.6080906-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org> wrote on 10/05/2010 04:26:48 PM:

> Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org> 
> 10/05/2010 04:26 PM
> 
> To
> 
> Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
> 
> cc
> 
> netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> Subject
> 
> Re: [PATCH] SIW: Object management
> 
> On 10/05/2010 01:54 AM, Bernard Metzler wrote:
> 
> <snip>+
> > +
> > +/***** routines for WQE handling ***/
> > +
> > +/*
> > + * siw_wqe_get()
> > + *
> > + * Get new WQE. For READ RESPONSE, take it from the free list which
> > + * has a maximum size of maximum inbound READs. All other WQE are
> > + * malloc'ed which creates some overhead. Consider change to
> > + *
> > + * 1. malloc WR only if it cannot be synchonously completed, or
> > + * 2. operate own cache of reuseable WQE's.
> > + *
> > + * Current code trusts on malloc efficiency.
> > + */
> > +inline struct siw_wqe *siw_wqe_get(struct siw_qp *qp, enum 
> siw_wr_opcode op)
> > +{
> > +   struct siw_wqe *wqe;
> > +
> > +   if (op == SIW_WR_RDMA_READ_RESP) {
> > +      spin_lock(&qp->freelist_lock);
> > +      if (!(list_empty(&qp->wqe_freelist))) {
> > +         wqe = list_entry(qp->wqe_freelist.next,
> > +                struct siw_wqe, list);
> > +         list_del(&wqe->list);
> > +         spin_unlock(&qp->freelist_lock);
> > +         wqe->processed = 0;
> > +         dprint(DBG_OBJ|DBG_WR,
> > +            "(QP%d): WQE from FreeList p: %p\n",
> > +            QP_ID(qp), wqe);
> > +      } else {
> > +         spin_unlock(&qp->freelist_lock);
> > +         wqe = NULL;
> > +         dprint(DBG_ON|DBG_OBJ|DBG_WR,
> > +            "(QP%d): FreeList empty!\n", QP_ID(qp));
> > +      }
> > +   } else {
> > +      wqe = kzalloc(sizeof(struct siw_wqe), GFP_KERNEL);
> > +      dprint(DBG_OBJ|DBG_WR, "(QP%d): New WQE p: %p\n",
> > +         QP_ID(qp), wqe);
> > +   }
> > 
> 
> I think you can't allocate at GFP_KERNEL here if this is called from the 

> post_ functions.  I think you might want to pre-allocate these when you 
> create the QP...
> 
the idea was to keep the memory footprint small and flexible
while using the linux/list.h routines to manipulate all queues
(no ring buffers etc, just lists). at the same time we
decided to take the provided uverbs_cmd-syscall path down to
the driver even for the post_-functions (since we would have to ring a 
doorbell on the send path anyway, which in software, is a syscall).
in that path, even ib_uverbs_post_send() does one kmalloc() per wr
(it would be helpful if the provider could keep and reuse that wr of
known size, freeing it later at its own premises. that would avoid
the second kmalloc here.)

currently only work queue elements which are needed to satisfy
inbound read requests are pre-allocated (amount corresponding
to inbound read queue depth), since the read response is
scheduled in network softirq context which must not sleep.

that discussion may relate to the spinlock at the entrance to the
post_ verbs. going down the uverbs_cmd path may sleep anyway...?

thanks,
bernard.
> 
> Steve.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
