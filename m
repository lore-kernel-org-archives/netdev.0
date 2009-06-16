From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next-2.6] ixgbe: fix multi-ring polling [V2]
Date: Tue, 16 Jun 2009 17:42:13 -0400
Message-ID: <20090616214213.GC8515@gospo.rdu.redhat.com>
References: <20090616205338.GB8515@gospo.rdu.redhat.com> <alpine.WNT.2.00.0906161400001.6404@jbrandeb-MOBL3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41716 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666AbZFPVmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2009 17:42:23 -0400
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.0906161400001.6404@jbrandeb-MOBL3.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2009 at 02:11:45PM -0700, Brandeburg, Jesse wrote:
> 
> 
> On Tue, 16 Jun 2009, Andy Gospodarek wrote:
> 
> > 
> > When looking at ixgbe_clean_rxtx_many I noticed two small problems.
> > 
> >  - work_done needs to be cleared before calling ixgbe_clean_rx_irq since
> >    it will exit without cleaning any buffers when work_done is greater
> >    than budget (which could happen pretty often after the first ring is
> >    cleaned).  A total count will ensure we still return the correct
> >    number of frames processed.
> 
> but (not seen in the below patch) the budget is divided by the number of 
> rings on this vector before it is passed to rx_clean, so each ring will 
> always get a chance to clean at least one buffer.
> 

Not by my reading of ixgbe_clean_rx_irq (which could be wrong, but I've
looked again to be sure).  If we have 2 rings that need to be cleaned
and a budget of 64 passed into ixgbe_clean_rxtx_many, then budget will
be 32 inside the loop.  If the system is busy and there are more than 32
buffers that need to be cleaned on the first ring ixgbe_clean_rx_irq
will not break until work_done is 32.  When the second ring is polled,
work_done is already 32 and so is budget.  The while loop in
ixgbe_clean_rx_irq will break immediately and nothing will be cleaned on
the second ring.  Let me know if I'm missing something.

> >  - napi_complete should only be called if all rings associated with this
> >    napi instance were cleaned completely.  It seems wise to stay on the
> >    poll-list if not completely cleaned.
> 
> that part I agree to.
> 
> > 
> > This has been compile tested only.
> 
> we can test it but I think we need a V2, see below...
> 
> > 
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> > ---
> > 
> >  ixgbe_main.c |   11 +++++++----
> >  1 file changed, 7 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> > index a551a96..c009642 100644
> > --- a/drivers/net/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ixgbe/ixgbe_main.c
> > @@ -1362,9 +1362,9 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
> >  	                       container_of(napi, struct ixgbe_q_vector, napi);
> >  	struct ixgbe_adapter *adapter = q_vector->adapter;
> >  	struct ixgbe_ring *ring = NULL;
> > -	int work_done = 0, i;
> > +	int work_done = 0, total_work = 0, i;
> >  	long r_idx;
> > -	bool tx_clean_complete = true;
> > +	bool rx_clean_complete = true, tx_clean_complete = true;
> >  
> >  	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
> >  	for (i = 0; i < q_vector->txr_count; i++) {
> > @@ -1384,12 +1384,15 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
> >  	budget = max(budget, 1);
> >  	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
> >  	for (i = 0; i < q_vector->rxr_count; i++) {
> > +		work_done = 0;
> >  		ring = &(adapter->rx_ring[r_idx]);
> >  #ifdef CONFIG_IXGBE_DCA
> >  		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
> >  			ixgbe_update_rx_dca(adapter, ring);
> >  #endif
> >  		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
> > +		total_work += work_done;
> > +		rx_clean_complete &= (work_done < budget);
> >  		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
> >  		                      r_idx + 1);
> >  	}
> > @@ -1397,7 +1400,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
> >  	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
> >  	ring = &(adapter->rx_ring[r_idx]);
> >  	/* If all Rx work done, exit the polling mode */
> > -	if (work_done < budget) {
> > +	if (rx_clean_complete && tx_clean_complete) {
> >  		napi_complete(napi);
> >  		if (adapter->itr_setting & 1)
> >  			ixgbe_set_itr_msix(q_vector);
> > @@ -1407,7 +1410,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
> >  		return 0;
> >  	}
> >  
> > -	return work_done;
> > +	return total_work;
> 
> I don't think you can return total_work here unless it is always
>  == budget, otherwise NAPI will hang.
> 
> before the only values that would ever be returned were:
>  
> 1) napi_complete, return work_done (work_done < budget)
> 2) return work_done (work_done >= budget)
> 
> I'm not sure if the > case is even valid in the new napi model, the only 
> one we ever use is the work_done == budget to continue polling.
> 

Adding a check is no problem, but that means we need to save the
original budget.  It would be good to do that to avoid the WARN_ON_ONCE
in net_rx_action as well, but should we be cheating like that?  Here's
the new patch:



[PATCH net-next-2.6] ixgbe: fix multi-ring polling

When looking at ixgbe_clean_rxtx_many I noticed two small problems.

 - work_done needs to be cleared before calling ixgbe_clean_rx_irq since
   it will exit without cleaning any buffers when work_done is greater
   than budget (which could happen pretty often after the first ring is
   cleaned).  A total count will ensure will still return the correct
   number of frames processed.
 - napi_complete should only be called if all rings associated with this
   napi instance were cleaned completely.  It seems wise to stay on the
   poll-list if not completely cleaned.

This has been compile tested only.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---

 ixgbe_main.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index a551a96..a5c8bf1 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1362,9 +1362,9 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	                       container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
 	struct ixgbe_ring *ring = NULL;
-	int work_done = 0, i;
+	int work_done = 0, total_work = 0, i, old_budget = budget;
 	long r_idx;
-	bool tx_clean_complete = true;
+	bool rx_clean_complete = true, tx_clean_complete = true;
 
 	r_idx = find_first_bit(q_vector->txr_idx, adapter->num_tx_queues);
 	for (i = 0; i < q_vector->txr_count; i++) {
@@ -1384,12 +1384,15 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	budget = max(budget, 1);
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	for (i = 0; i < q_vector->rxr_count; i++) {
+		work_done = 0;
 		ring = &(adapter->rx_ring[r_idx]);
 #ifdef CONFIG_IXGBE_DCA
 		if (adapter->flags & IXGBE_FLAG_DCA_ENABLED)
 			ixgbe_update_rx_dca(adapter, ring);
 #endif
 		ixgbe_clean_rx_irq(q_vector, ring, &work_done, budget);
+		total_work += work_done;
+		rx_clean_complete &= (work_done < budget);
 		r_idx = find_next_bit(q_vector->rxr_idx, adapter->num_rx_queues,
 		                      r_idx + 1);
 	}
@@ -1397,7 +1400,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 	r_idx = find_first_bit(q_vector->rxr_idx, adapter->num_rx_queues);
 	ring = &(adapter->rx_ring[r_idx]);
 	/* If all Rx work done, exit the polling mode */
-	if (work_done < budget) {
+	if (rx_clean_complete && tx_clean_complete) {
 		napi_complete(napi);
 		if (adapter->itr_setting & 1)
 			ixgbe_set_itr_msix(q_vector);
@@ -1407,7 +1410,7 @@ static int ixgbe_clean_rxtx_many(struct napi_struct *napi, int budget)
 		return 0;
 	}
 
-	return work_done;
+	return total_work > old_budget ? old_budget : total_work;
 }
 
 /**
