From: Simon Horman <horms@verge.net.au>
Subject: Re: [net-next PATCH 2/6] enic: Bug fix: try harder to fill Rx ring
 on skb allocation failures
Date: Sun, 20 Dec 2009 12:15:00 +1100
Message-ID: <20091220011500.GA12578@verge.net.au>
References: <20091219104128.GB20743@verge.net.au>
 <C75279E7.1B001%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60914 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754870AbZLTBPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 20:15:05 -0500
Content-Disposition: inline
In-Reply-To: <C75279E7.1B001%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 19, 2009 at 12:39:03PM -0800, Scott Feldman wrote:
> On 12/19/09 2:41 AM, "Simon Horman" <horms@verge.net.au> wrote:
> 
> > On Fri, Dec 18, 2009 at 06:09:46PM -0800, Scott Feldman wrote:
> >> enic: Bug fix: try harder to fill Rx ring on skb allocation failures
> >> 
> >> During probe(), make sure we get at least one skb on the Rx ring.
> >> Otherwise abort the interface load.  Also, if we get skb allocation
> >> failures in NAPI poll while trying to replenish the ring, try again
> >> later so we don't end up starving out the Rx ring completely.
> >> 
> >> @@ -1115,16 +1116,19 @@ static int enic_poll(struct napi_struct *napi, int
> >> budget)
> >> 0 /* don't unmask intr */,
> >> 0 /* don't reset intr timer */);
> >>  
> >> - if (rq_work_done > 0) {
> >> + err = vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
> >>  
> >> -  /* Replenish RQ
> >> -   */
> >> + /* Buffer allocation failed. Stay in polling
> >> +  * mode so we can try to fill the ring again.
> >> +  */
> >>  
> >> -  vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
> >> + if (err)
> >> +  rq_work_done = rq_work_to_do;
> > 
> > Is it intentional for rq_work_done = rq_work_to_do to become the
> > return value?
> 
> That was intentional.  If the replacement skb allocation fails, we're
> returning like we did a full budget's worth of work so we stay scheduled and
> hopefully the next polling pass we'll get the allocations.  Before this fix,
> there is a corner case which isn't covered: if hw has used all descs and
> gens an intr and we get into polling and the replacement alloc fails, then
> Rx is hung.  Hw is desc starved and we're not going to get any more intrs:
> game over.

Ok, understood. Though doesn't this fix just narrow the scope for that
failure? It seems that it could still occur in a pathological case.

> I was looking at tg3.c and it looks like it does napi_schedule() if the
> allocation fails.  Would this be a better option than setting work_done =
> budget?

I don't think that calling napi_schedule() would help for this case as
it looks like it only schedules the poll routine if its not already running.

>  
> >> @@ -1333,11 +1343,13 @@ static int enic_open(struct net_device *netdev)
> >> }
> >>  
> >> for (i = 0; i < enic->rq_count; i++) {
> >> -  err = vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
> >> -  if (err) {
> >> +  vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
> >> +  /* Need at least one buffer on ring to get going */
> >> +  if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
> >> printk(KERN_ERR PFX
> >> "%s: Unable to alloc receive buffers.\n",
> >> netdev->name);
> >> +   err = -ENOMEM;
> >> goto err_out_notify_unset;
> >> }
> >> }
> > 
> > My brain may well have switched off for the day,
> > but its unclear to me how &enic->rq[i] could ever be NULL.
> 
> You missed a ")"

Yes, I did. And the more I stared at it, the more I missed it :-(

>  
> > Also, in the case where a failure occurs for i > 0,
> > it it necessary to unwind the previous rq allocations?
> 
> Yes, good catch.  We'll fix that.
> 
> -scott
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
