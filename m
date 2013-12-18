From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net v2 4/8] cxgb4: Account for stid entries properly in case of IPv6
Date: Wed, 18 Dec 2013 16:38:22 +0530
Message-ID: <1387364906-1967-5-git-send-email-hariprasad@chelsio.com>
References: <1387364906-1967-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1387364906-1967-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

IPv6 uses 2 TIDs with CLIP enabled and 4 TIDs without CLIP.
Currently we are incrementing STIDs in use by 1 for both IPv4 and IPv6 which
is wrong.

Further, driver currently does not have interface to query if CLIP is programmed
for particular IPv6 address. So, in this patch we increment/decrement TIDs in use
by 4 for IPv6 assuming absence of CLIP. Such assumption keeps us on safe side and
we don't end up allocating more stids for IPv6 than actually supported.

Based on original work by Santosh Rastapur <santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>

Signed-off-by: Kumar Sanghvi <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f4f46fc..f9ca36c 100644
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
@@ -3039,7 +3046,10 @@ void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family)
 	else
 		bitmap_release_region(t->stid_bmap, stid, 2);
 	t->stid_tab[stid].data = NULL;
-	t->stids_in_use--;
+	if (family == PF_INET)
+		t->stids_in_use--;
+	else
+		t->stids_in_use -= 4;
 	spin_unlock_bh(&t->stid_lock);
 }
 EXPORT_SYMBOL(cxgb4_free_stid);
-- 
1.8.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
