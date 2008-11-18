From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 08/13] dmatest: convert to dma_request_channel
Date: Tue, 18 Nov 2008 11:24:21 -0700
Message-ID: <1227032661.15042.10.camel@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
	 <20081114213458.32354.58258.stgit@dwillia2-linux.ch.intel.com>
	 <20081114221704.fe9ea599.akpm@linux-foundation.org>
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
Received: from mga09.intel.com ([134.134.136.24]:6367 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbYKRSYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 13:24:24 -0500
In-Reply-To: <20081114221704.fe9ea599.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-14 at 23:17 -0700, Andrew Morton wrote:
> On Fri, 14 Nov 2008 14:34:58 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
> 
> >  static int __init dmatest_init(void)
> >  {
> > -	dma_cap_set(DMA_MEMCPY, dmatest_client.cap_mask);
> > -	dma_async_client_register(&dmatest_client);
> > -	dma_async_client_chan_request(&dmatest_client);
> > +	dma_cap_mask_t mask;
> > +	struct dma_chan *chan;
> > +
> > +	dma_cap_zero(mask);
> > +	dma_cap_set(DMA_MEMCPY, mask);
> > +	for (;;) {
> > +		chan = dma_request_channel(mask, filter, NULL);
> > +		if (chan) {
> > +			if (dmatest_add_channel(chan) == 0)
> > +				continue;
> 
> hrm.  I trust this loop can't lock up the box.
> 

Only if the system has infinite channels, but we should break if
dma_add_channel fails.

diff --git a/drivers/dma/dmatest.c b/drivers/dma/dmatest.c
index e0f9139..c77d47c 100644
--- a/drivers/dma/dmatest.c
+++ b/drivers/dma/dmatest.c
@@ -375,23 +375,27 @@ static int __init dmatest_init(void)
 {
 	dma_cap_mask_t mask;
 	struct dma_chan *chan;
+	int err = 0;
 
 	dma_cap_zero(mask);
 	dma_cap_set(DMA_MEMCPY, mask);
 	for (;;) {
 		chan = dma_request_channel(mask, filter, NULL);
 		if (chan) {
-			if (dmatest_add_channel(chan) == 0)
+			err = dmatest_add_channel(chan);
+			if (err == 0)
 				continue;
-			else
+			else {
 				dma_release_channel(chan);
+				break; /* add_channel failed, punt */
+			}
 		} else
 			break; /* no more channels available */
 		if (max_channels && nr_channels >= max_channels)
 			break; /* we have all we need */
 	}
 
-	return 0;
+	return err;
 }
 /* when compiled-in wait for drivers to load first */
 late_initcall(dmatest_init);

---

Ok, so I now have:
# git shortlog `stg id akpm-review-spell-fixes.patch`^..
Dan Williams (6):
      dmaengine review: spelling/grammar fixes
      dmaengine review: dma_wait_for_async_tx clarification
      dmaengine review: fix up kernel doc for dma_list_mutex usage
      dmaengine review: propagate alloc_chan_resources error code
      dmaengine review: return meaningful error code from initcall
      dmaengine review: dmatest stop on dmatest_add_channel failure

May I add your Reviewed-by for these and the original 13.  I could fold
these into the originals but perhaps it is better to document fixups
when they are the result of review [1].

Thanks,
Dan

[1] http://lwn.net/Articles/306690/

