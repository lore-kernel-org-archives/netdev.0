From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 04/13] dmaengine: centralize channel allocation,
	introduce dma_find_channel
Date: Mon, 17 Nov 2008 22:59:06 -0700
Message-ID: <1226987947.25411.43.camel@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213437.32354.66972.stgit@dwillia2-linux.ch.intel.com>
	 <20081114221442.d16cdaa1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sosnowski, Maciej" <maciej.sosnowski@intel.com>,
	"hskinnemoen@atmel.com" <hskinnemoen@atmel.com>,
	"g.liakhovetski@gmx.de" <g.liakhovetski@gmx.de>,
	"nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:49766 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYKRF7I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 00:59:08 -0500
In-Reply-To: <20081114221442.d16cdaa1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-14 at 23:14 -0700, Andrew Morton wrote:
> > +/**
> > + * dma_chan_tbl_ent - tracks channel allocations per core/opertion
> > + */
> 
> Would be conventional to document the fields as well.
> 

diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 644a8c8..ebbfe2d 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -218,7 +218,8 @@ EXPORT_SYMBOL(dma_sync_wait);
 static dma_cap_mask_t dma_cap_mask_all;
 
 /**
- * dma_chan_tbl_ent - tracks channel allocations per core/opertion
+ * dma_chan_tbl_ent - tracks channel allocations per core/operation
+ * @chan - associated channel for this entry
  */
 struct dma_chan_tbl_ent {
 	struct dma_chan *chan;

> > +	for_each_dma_cap_mask(cap, dma_cap_mask_all) {
> > +		channel_table[cap] = alloc_percpu(struct dma_chan_tbl_ent);
> > +		if (!channel_table[cap]) {
> > +			err = 1;
> 
> initcalls can return -ve errnos, and that at least would make the
> message in do_one_initcall() more meaningful.
> 

@@ -247,7 +247,7 @@ static int __init dma_channel_table_init(void)
 	for_each_dma_cap_mask(cap, dma_cap_mask_all) {
 		channel_table[cap] = alloc_percpu(struct dma_chan_tbl_ent);
 		if (!channel_table[cap]) {
-			err = 1;
+			err = -ENOMEM;
 			break;
 		}
 	}

> > +/**
> > + * dma_find_channel - find a channel to carry out the operation
> > + * @tx_type: transaction type
> > + */
> > +struct dma_chan *dma_find_channel(enum dma_transaction_type tx_type)
> > +{
> > +	struct dma_chan *chan;
> > +	int cpu;
> > +
> > +	WARN_ONCE(dmaengine_ref_count == 0,
> > +		  "client called %s without a reference", __func__);
> > +
> > +	cpu = get_cpu();
> > +	chan = per_cpu_ptr(channel_table[tx_type], cpu)->chan;
> > +	put_cpu();
> > +
> > +	return chan;
> > +}
> > +EXPORT_SYMBOL(dma_find_channel);
> 
> Strange.  We return the address of a per-cpu variable, but we've
> reenabled preemption so this thread can now switch CPUs.  Hence there
> must be spinlocking on *chan as well?

There is locking when we call into the driver.  dmaengine is using the
cpuid as a load balancing hint and nothing more.  We loosely try to
maintain cpu-channel affinity, but if preemption occasionally jumbles
these associations clients can tolerate it.  dma_find_channel is called
relatively frequently so these misassociations should be short-lived

> > +	if (ret)
> > +		ret->table_count++;
> 
> Undocumented locking for ->table_count.
> 

@@ -313,7 +313,8 @@ EXPORT_SYMBOL(dma_issue_pending_all);
  * @n: nth channel desired
  *
  * Defaults to returning the channel with the desired capability and the
- * lowest reference count when 'n' cannot be satisfied
+ * lowest reference count when 'n' cannot be satisfied.  Must be called
+ * under dma_list_mutex.
  */
 static struct dma_chan *nth_chan(enum dma_transaction_type cap, int n)
 {

> >
> > +	/* undo the last distribution */
> > +	for_each_dma_cap_mask(cap, dma_cap_mask_all)
> > +		for_each_possible_cpu(cpu)
> > +			per_cpu_ptr(channel_table[cap], cpu)->chan = NULL;
> 
> The number of possible cpus can be larger than the number of online
> CPUs.  Is it worth making this code hotplug-aware?
> 

...nobody has missed it from the NET_DMA case so far, but yes, at some
future date.

Regards,
Dan

