From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net 3/4 v2] xen-netback: Fix releasing header slot on error path
Date: Fri, 18 Jul 2014 19:08:04 +0100
Message-ID: <1405706885-16763-4-git-send-email-zoltan.kiss@citrix.com>
References: <1405706885-16763-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405706885-16763-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes this function aware that the first frag and the header might
share the same ring slot. That could happen if the first slot is bigger than
PKT_PROT_LEN. Due to this the error path might release that slot twice or never,
depending on the error scenario.
xenvif_idx_release is also removed from xenvif_idx_unmap, and called separately.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
v2: remove stray blank line

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 8cbf60d..6fff911 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1039,6 +1039,8 @@ static int xenvif_tx_check_gop(struct xenvif_queue *queue,
 	 */
 	struct skb_shared_info *first_shinfo = NULL;
 	int nr_frags = shinfo->nr_frags;
+	const bool sharedslot = nr_frags &&
+				frag_get_pending_idx(&shinfo->frags[0]) == pending_idx;
 	int i, err;
 
 	/* Check status of header. */
@@ -1051,7 +1053,10 @@ static int xenvif_tx_check_gop(struct xenvif_queue *queue,
 				   (*gopp_copy)->status,
 				   pending_idx,
 				   (*gopp_copy)->source.u.ref);
-		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_ERROR);
+		/* The first frag might still have this slot mapped */
+		if (!sharedslot)
+			xenvif_idx_release(queue, pending_idx,
+					   XEN_NETIF_RSP_ERROR);
 	}
 
 check_frags:
@@ -1068,8 +1073,19 @@ check_frags:
 						pending_idx,
 						gop_map->handle);
 			/* Had a previous error? Invalidate this fragment. */
-			if (unlikely(err))
+			if (unlikely(err)) {
 				xenvif_idx_unmap(queue, pending_idx);
+				/* If the mapping of the first frag was OK, but
+				 * the header's copy failed, and they are
+				 * sharing a slot, send an error
+				 */
+				if (i == 0 && sharedslot)
+					xenvif_idx_release(queue, pending_idx,
+							   XEN_NETIF_RSP_ERROR);
+				else
+					xenvif_idx_release(queue, pending_idx,
+							   XEN_NETIF_RSP_OKAY);
+			}
 			continue;
 		}
 
@@ -1081,15 +1097,27 @@ check_frags:
 				   gop_map->status,
 				   pending_idx,
 				   gop_map->ref);
+
 		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_ERROR);
 
 		/* Not the first error? Preceding frags already invalidated. */
 		if (err)
 			continue;
-		/* First error: invalidate preceding fragments. */
+
+		/* First error: if the header haven't shared a slot with the
+		 * first frag, release it as well.
+		 */
+		if (!sharedslot)
+			xenvif_idx_release(queue,
+					   XENVIF_TX_CB(skb)->pending_idx,
+					   XEN_NETIF_RSP_OKAY);
+
+		/* Invalidate preceding fragments of this skb. */
 		for (j = 0; j < i; j++) {
 			pending_idx = frag_get_pending_idx(&shinfo->frags[j]);
 			xenvif_idx_unmap(queue, pending_idx);
+			xenvif_idx_release(queue, pending_idx,
+					   XEN_NETIF_RSP_OKAY);
 		}
 
 		/* And if we found the error while checking the frag_list, unmap
@@ -1099,6 +1127,8 @@ check_frags:
 			for (j = 0; j < first_shinfo->nr_frags; j++) {
 				pending_idx = frag_get_pending_idx(&first_shinfo->frags[j]);
 				xenvif_idx_unmap(queue, pending_idx);
+				xenvif_idx_release(queue, pending_idx,
+						   XEN_NETIF_RSP_OKAY);
 			}
 		}
 
@@ -1834,8 +1864,6 @@ void xenvif_idx_unmap(struct xenvif_queue *queue, u16 pending_idx)
 			   tx_unmap_op.status);
 		BUG();
 	}
-
-	xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_OKAY);
 }
 
 static inline int rx_work_todo(struct xenvif_queue *queue)
