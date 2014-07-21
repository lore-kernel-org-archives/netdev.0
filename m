From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH for stable 3.15 2/4 v2] xen-netback: Fix releasing frag_list skbs in error path
Date: Mon, 21 Jul 2014 11:41:00 +0100
Message-ID: <1405939262-7944-2-git-send-email-zoltan.kiss@citrix.com>
References: <1405939262-7944-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405939262-7944-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the grant operations failed, the skb is freed up eventually, and it tries
to release the frags, if there is any. For the main skb nr_frags is set to 0 to
avoid this, but on the frag_list it iterates through the frags array, and tries
to call put_page on the page pointer which contains garbage at that time.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Reported-by: Armin Zentai <armin.zentai@ezit.hu>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org
---
v2: adding comment
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 9b0f482..75b7d1a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1498,7 +1498,16 @@ static int xenvif_tx_submit(struct xenvif *vif)
 
 		/* Check the remap error code. */
 		if (unlikely(xenvif_tx_check_gop(vif, skb, &gop_map, &gop_copy))) {
+			/* If there was an error, xenvif_tx_check_gop is
+			 * expected to release all the frags which were mapped,
+			 * so kfree_skb shouldn't do it again
+			 */
 			skb_shinfo(skb)->nr_frags = 0;
+			if (skb_has_frag_list(skb)) {
+				struct sk_buff *nskb =
+						skb_shinfo(skb)->frag_list;
+				skb_shinfo(nskb)->nr_frags = 0;
+			}
 			kfree_skb(skb);
 			continue;
 		}
