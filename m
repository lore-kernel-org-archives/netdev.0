From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/5] iw_cxgb4: log detailed warnings for negative advice
Date: Mon, 21 Jul 2014 20:55:13 +0530
Message-ID: <1405956316-13591-3-git-send-email-hariprasad@chelsio.com>
References: <1405956316-13591-1-git-send-email-hariprasad@chelsio.com>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405956316-13591-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Signed-off-by: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
---
 drivers/infiniband/hw/cxgb4/cm.c |   29 +++++++++++++++++++++++------
 1 files changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index df5bd3d..6d61a16 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -1813,6 +1813,20 @@ static int is_neg_adv(unsigned int status)
 	       status == CPL_ERR_KEEPALV_NEG_ADVICE;
 }
 
+static char *neg_adv_str(unsigned int status)
+{
+	switch (status) {
+	case CPL_ERR_RTX_NEG_ADVICE:
+		return "Retransmit timeout";
+	case CPL_ERR_PERSIST_NEG_ADVICE:
+		return "Persist timeout";
+	case CPL_ERR_KEEPALV_NEG_ADVICE:
+		return "Keepalive timeout";
+	default:
+		return "Unknown";
+	}
+}
+
 static void set_tcp_window(struct c4iw_ep *ep, struct port_info *pi)
 {
 	ep->snd_win = snd_win;
@@ -2011,8 +2025,9 @@ static int act_open_rpl(struct c4iw_dev *dev, struct sk_buff *skb)
 	     status, status2errno(status));
 
 	if (is_neg_adv(status)) {
-		printk(KERN_WARNING MOD "Connection problems for atid %u\n",
-			atid);
+		dev_warn(&dev->rdev.lldi.pdev->dev,
+			 "Connection problems for atid %u status %u (%s)\n",
+			 atid, status, neg_adv_str(status));
 		return 0;
 	}
 
@@ -2488,8 +2503,9 @@ static int peer_abort(struct c4iw_dev *dev, struct sk_buff *skb)
 
 	ep = lookup_tid(t, tid);
 	if (is_neg_adv(req->status)) {
-		PDBG("%s neg_adv_abort ep %p tid %u\n", __func__, ep,
-		     ep->hwtid);
+		dev_warn(&dev->rdev.lldi.pdev->dev,
+			 "Negative advice on abort - tid %u status %d (%s)\n",
+			 ep->hwtid, req->status, neg_adv_str(req->status));
 		return 0;
 	}
 	PDBG("%s ep %p tid %u state %u\n", __func__, ep, ep->hwtid,
@@ -3894,8 +3910,9 @@ static int peer_abort_intr(struct c4iw_dev *dev, struct sk_buff *skb)
 		return 0;
 	}
 	if (is_neg_adv(req->status)) {
-		PDBG("%s neg_adv_abort ep %p tid %u\n", __func__, ep,
-		     ep->hwtid);
+		dev_warn(&dev->rdev.lldi.pdev->dev,
+			 "Negative advice on abort - tid %u status %d (%s)\n",
+			 ep->hwtid, req->status, neg_adv_str(req->status));
 		kfree_skb(skb);
 		return 0;
 	}
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
