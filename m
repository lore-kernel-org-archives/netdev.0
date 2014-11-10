From: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [net-next PATCH 2/5] cxgb4/cxgb4vf: Replace __skb_alloc_page with
 __netdev_alloc_page
Date: Mon, 10 Nov 2014 11:52:06 -0800
Message-ID: <20141110195206.16182.95549.stgit@ahduyck-vm-fedora20>
References: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141110195104.16182.98174.stgit@ahduyck-vm-fedora20>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Drop the bloated use of __skb_alloc_page and replace it with
__netdev_alloc_page.  In addition update the one other spot that is
allocating a page so that it allocates with the correct flags.

Cc: Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Cc: Casey Leedom <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c   |    6 +++---
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c |    7 ++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 5e1b314..f7dd6e3 100644
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
+		pg = __netdev_alloc_pages(gfp, s->fl_pg_order);
 		if (unlikely(!pg)) {
 			q->large_alloc_failed++;
 			break;       /* fall back to single pages */
@@ -615,7 +615,7 @@ static unsigned int refill_fl(struct adapter *adap, struct sge_fl *q, int n,
 
 alloc_small_pages:
 	while (n--) {
-		pg = __skb_alloc_page(gfp, NULL);
+		pg = __netdev_alloc_page(gfp);
 		if (unlikely(!pg)) {
 			q->alloc_failed++;
 			break;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 85036e6..ad5df49 100644
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
+		page = __netdev_alloc_pages(gfp, FL_PG_ORDER);
 		if (unlikely(!page)) {
 			/*
 			 * We've failed inour attempt to allocate a "large
@@ -657,7 +658,7 @@ static unsigned int refill_fl(struct adapter *adapter, struct sge_fl *fl,
 
 alloc_small_pages:
 	while (n--) {
-		page = __skb_alloc_page(gfp | __GFP_NOWARN, NULL);
+		page = __netdev_alloc_page(gfp);
 		if (unlikely(!page)) {
 			fl->alloc_failed++;
 			break;

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
