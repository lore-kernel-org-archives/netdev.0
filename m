From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH v3 2/5] cxgb4/cxgb4vf: Replace __skb_alloc_page
 with __dev_alloc_page
Date: Tue, 11 Nov 2014 09:26:42 -0800
Message-ID: <20141111172642.16460.73564.stgit@ahduyck-vm-fedora20>
References: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, hariprasad@chelsio.com,
	donald.c.skidmore@intel.com, oliver@neukum.org, balbi@ti.com,
	matthew.vick@intel.com, mgorman@suse.de, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58104 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbaKKR1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 12:27:14 -0500
In-Reply-To: <20141111172523.16460.16845.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop the bloated use of __skb_alloc_page and replace it with
__dev_alloc_page.  In addition update the one other spot that is
allocating a page so that it allocates with the correct flags.

Cc: Hariprasad S <hariprasad@chelsio.com>
Cc: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c   |    6 +++---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |    7 ++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 5e1b314..20ee002 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -576,7 +576,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 	__be64 *d = &q->desc[q->pidx];
 	struct rx_sw_desc *sd = &q->sdesc[q->pidx];
 
-	gfp |= __GFP_NOWARN | __GFP_COLD;
+	gfp |= __GFP_NOWARN;
 
 	if (s->fl_pg_order == 0)
 		goto alloc_small_pages;
@@ -585,7 +585,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 	 * Prefer large buffers
 	 */
 	while (n) {
-		pg = alloc_pages(gfp | __GFP_COMP, s->fl_pg_order);
+		pg = __dev_alloc_pages(gfp, s->fl_pg_order);
 		if (unlikely(!pg)) {
 			q->large_alloc_failed++;
 			break;       /* fall back to single pages */
@@ -615,7 +615,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 
 alloc_small_pages:
 	while (n--) {
-		pg = __skb_alloc_page(gfp, NULL);
+		pg = __dev_alloc_page(gfp);
 		if (unlikely(!pg)) {
 			q->alloc_failed++;
 			break;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 85036e6..9df40df 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -602,6 +602,8 @@ static unsigned int refill_fl(struct adapter *adapter, struct sge_fl *fl,
 	 */
 	BUG_ON(fl->avail + n > fl->size - FL_PER_EQ_UNIT);
 
+	gfp |= __GFP_NOWARN;
+
 	/*
 	 * If we support large pages, prefer large buffers and fail over to
 	 * small pages if we can't allocate large pages to satisfy the refill.
@@ -612,8 +614,7 @@ static unsigned int refill_fl(struct adapter *adapter, struct sge_fl *fl,
 		goto alloc_small_pages;
 
 	while (n) {
-		page = alloc_pages(gfp | __GFP_COMP | __GFP_NOWARN,
-				   FL_PG_ORDER);
+		page = __dev_alloc_pages(gfp, FL_PG_ORDER);
 		if (unlikely(!page)) {
 			/*
 			 * We've failed inour attempt to allocate a "large
@@ -657,7 +658,7 @@ static unsigned int refill_fl(struct adapter *adapter, struct sge_fl *fl,
 
 alloc_small_pages:
 	while (n--) {
-		page = __skb_alloc_page(gfp | __GFP_NOWARN, NULL);
+		page = __dev_alloc_page(gfp);
 		if (unlikely(!page)) {
 			fl->alloc_failed++;
 			break;
