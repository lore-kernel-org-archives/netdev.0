From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v7 4/9] xen-netback: Introduce TX grant mapping
Date: Thu, 13 Mar 2014 13:56:30 +0000
Message-ID: <1394718990.25873.70.camel@kazak.uk.xensource.com>
References: <1394142511-14827-1-git-send-email-zoltan.kiss@citrix.com>
		 <1394142511-14827-5-git-send-email-zoltan.kiss@citrix.com>
	 <1394706812.25873.28.camel@kazak.uk.xensource.com>
	 <5321B006.9070608@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5321B006.9070608@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-03-13 at 13:17 +0000, Zoltan Kiss wrote:
> On 13/03/14 10:33, Ian Campbell wrote:
> > On Thu, 2014-03-06 at 21:48 +0000, Zoltan Kiss wrote:
> >> @@ -135,13 +146,31 @@ struct xenvif {
> >>   	pending_ring_idx_t pending_cons;
> >>   	u16 pending_ring[MAX_PENDING_REQS];
> >>   	struct pending_tx_info pending_tx_info[MAX_PENDING_REQS];
> >> +	grant_handle_t grant_tx_handle[MAX_PENDING_REQS];
> >>
> >>   	/* Coalescing tx requests before copying makes number of grant
> >>   	 * copy ops greater or equal to number of slots required. In
> >>   	 * worst case a tx request consumes 2 gnttab_copy.
> >>   	 */
> >>   	struct gnttab_copy tx_copy_ops[2*MAX_PENDING_REQS];
> >> -
> >> +	struct gnttab_map_grant_ref tx_map_ops[MAX_PENDING_REQS];
> >> +	struct gnttab_unmap_grant_ref tx_unmap_ops[MAX_PENDING_REQS];
> >
> > I wonder if we should break some of these arrays into separate
> > allocations? Wasn't there a problem with sizeof(struct xenvif) at one
> > point?
> tx_copy_ops will be removed in the next patch. Yes, for grant_copy_op we 
> allocate it separately, because it has MAX_SKB_FRAGS * 
> XEN_NETIF_RX_RING_SIZE elements, but that's for the RX thread

OK

> >> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> >> index bc32627..1fe9fe5 100644
> >> --- a/drivers/net/xen-netback/interface.c
> >> +++ b/drivers/net/xen-netback/interface.c
> >> @@ -493,6 +533,23 @@ void xenvif_disconnect(struct xenvif *vif)
> >>
> >>   void xenvif_free(struct xenvif *vif)
> >>   {
> >> +	int i, unmap_timeout = 0;
> >> +
> >> +	for (i = 0; i < MAX_PENDING_REQS; ++i) {
> >> +		if (vif->grant_tx_handle[i] != NETBACK_INVALID_HANDLE) {
> >> +			unmap_timeout++;
> >> +			schedule_timeout(msecs_to_jiffies(1000));
> >> +			if (unmap_timeout > 9 &&
> >> +			    net_ratelimit())
> >
> > Does this really reach 80 columns when unwrapped?
> Not here, but in a later patch 9 will be replaced with 
> worst_case_skb_lifetime.

OK.

> > (there seems to my eye to be a lot of overaggressive wrapping in this
> > patch, but nevermind)
> I tried to fix every warning and error noticed by checkpatch.pl, however 
> there are still a few lines longer than 80, just because I couldn't 
> reasonably wrap them.

I thought checkpatch had been reined in a bit wrt 80 columns because the
cure is often worse than the disease. Anyway, it's there now.

> >
> >> +				netdev_err(vif->dev,
> >> +					   "Page still granted! Index: %x\n",
> >> +					   i);
> >> +			i = -1;
> >
> > Should there not be a break here? Otherwise don't we restart the for
> > loop from 0 again? If that is intentional then a comment would be very
> > useful.
> Yes, that's intentional, we shouldn't exit this loop until everything is 
> unmapped. An i-- would be fine as well. I will put a comment there.

Yes please do, it's very non-obvious what is going on. I'm almost
inclined to suggest that this is one of the few places where a goto
retry might be appropriate.

Can you also add a comment saying what is doing the actual unmap work
which we are waiting for here since it is not actually part of the loop.
Might a barrier be needed to ensure we see that work happening?

> >
> >> @@ -919,11 +873,38 @@ err:
> >>   	return NULL;
> >>   }
> >>
> >> +static inline void xenvif_grant_handle_set(struct xenvif *vif,
> >> +					   u16 pending_idx,
> >> +					   grant_handle_t handle)
> >> +{
> >> +	if (unlikely(vif->grant_tx_handle[pending_idx] !=
> >> +		     NETBACK_INVALID_HANDLE)) {
> >> +		netdev_err(vif->dev,
> >
> > Is this in any way guest triggerable? Needs to be ratelimited in that
> > case (and arguably even if not?)
> It shouldn't be guest triggerable. It only means netback really screwed 
> up the accounting of granted pages. There is a BUG right after it, and 
> the kernel should panic here.

OK.

> >> +			   "Trying to unmap invalid handle! pending_idx: %x\n",
> >> +			   pending_idx);
> >> +		BUG();
> >> +	}
> >> +	vif->grant_tx_handle[pending_idx] = NETBACK_INVALID_HANDLE;
> >> +}
> >> +
> >> @@ -1001,6 +982,17 @@ static void xenvif_fill_frags(struct xenvif *vif, struct sk_buff *skb)
> >>
> >>   		pending_idx = frag_get_pending_idx(frag);
> >>
> >> +		/* If this is not the first frag, chain it to the previous*/
> >> +		if (unlikely(prev_pending_idx == INVALID_PENDING_IDX))
> >> +			skb_shinfo(skb)->destructor_arg =
> >> +				&vif->pending_tx_info[pending_idx].callback_struct;
> >> +		else if (likely(pending_idx != prev_pending_idx))
> >> +			vif->pending_tx_info[prev_pending_idx].callback_struct.ctx =
> >> +				&(vif->pending_tx_info[pending_idx].callback_struct);
> >
> > #define callback_for(vif, pending_idx) .... would make this and a bunch
> > of other places a lot less verbose IMHO.
> Yeah, I was thinking about that, but it's really used here and 2 places 
> in tx_submit, so I didn't bother to do it.

That's still 5-6 uses I think. Worth it IMHO.

Thanks,

Ian.
