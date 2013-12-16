From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 4/9] cxgb4: Account for stid entries properly in case of IPv6
Date: Mon, 16 Dec 2013 17:42:13 +0530
Message-ID: <1387195938-3531-5-git-send-email-hariprasad@chelsio.com>
References: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9595 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3LPMUF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:20:05 -0500
In-Reply-To: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

IPv6 uses 2 TIDs with CLIP enabled and 4 TIDs without CLIP.
Currently we are incrementing STIDs in use by 1 for both IPv4 and IPv6 which
is wrong.

Further, driver currently does not have interface to query if CLIP is programmed
for particular IPv6 address. So, in this patch we increment/decrement TIDs in use
by 4 for IPv6 assuming absence of CLIP. Such assumption keeps us on safe side and
we don't end up allocating more stids for IPv6 than actually supported.

Based on original work by Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2cd7098..4bccfca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2986,7 +2986,14 @@ int cxgb4_alloc_stid(struct tid_info *t, int family, void *data)
 	if (stid >= 0) {
 		t->stid_tab[stid].data = data;
 		stid += t->stid_base;
-		t->stids_in_use++;
+		/* IPv6 requires max of 520 bits or 16 cells in TCAM
+		 * This is equivalent to 4 TIDs. With CLIP enabled it
+		 * needs 2 TIDs.
+		 */
+		if (family == PF_INET)
+			t->stids_in_use++;
+		else
+			t->stids_in_use += 4;
 	}
 	spin_unlock_bh(&t->stid_lock);
 	return stid;
@@ -3032,10 +3039,14 @@ void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family)
 		bitmap_release_region(t->stid_bmap, stid, 2);
 	t->stid_tab[stid].data = NULL;
 	t->stids_in_use--;
-	if (stid < t->nstids)
-		t->stids_in_use--;
-	else
+	if (stid < t->nstids) {
+		if (family == PF_INET)
+			t->stids_in_use--;
+		else
+			t->stids_in_use -= 4;
+	} else {
 		t->sftids_in_use--;
+	}
 	spin_unlock_bh(&t->stid_lock);
 }
 EXPORT_SYMBOL(cxgb4_free_stid);
-- 
1.8.0
