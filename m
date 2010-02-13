From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 2/9] tg3: Prevent rx producer ring overruns
Date: Fri, 12 Feb 2010 16:47:06 -0800
Message-ID: <1266022033-3546-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2533 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756094Ab0BMArd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 19:47:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When operating in RSS mode, it is possible for one rx return ring to
submit enough rx buffers back to the hardware such that it inadvertently
overwrites data needed by another rx return ring.  This patch addresses
the problem by looking for non-NULL skb pointers in the
rx_[std|jmb]_buffers rings that parallel the rx producer rings.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   38 ++++++++++++++++++++++++++++++++++++++
 1 files changed, 38 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 6874ce5..115fb7c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4552,6 +4552,12 @@ static void tg3_recycle_rx(struct tg3_napi *tnapi,
 			   pci_unmap_addr(src_map, mapping));
 	dest_desc->addr_hi = src_desc->addr_hi;
 	dest_desc->addr_lo = src_desc->addr_lo;
+
+	/* Ensure that the update to the skb happens after the physical
+	 * addresses have been transferred to the new BD location.
+	 */
+	smp_wmb();
+
 	src_map->skb = NULL;
 }
 
@@ -4816,6 +4822,22 @@ static void tg3_rx_prodring_xfer(struct tg3 *tp,
 		si = spr->rx_std_cons_idx;
 		di = dpr->rx_std_prod_idx;
 
+		for (i = di; i < di + cpycnt; i++) {
+			if (dpr->rx_std_buffers[i].skb) {
+				cpycnt = i - di;
+				break;
+			}
+		}
+
+		if (!cpycnt)
+			break;
+
+		/* Ensure that updates to the rx_std_buffers ring and the
+		 * shadowed hardware producer ring from tg3_recycle_skb() are
+		 * ordered correctly WRT the skb check above.
+		 */
+		smp_rmb();
+
 		memcpy(&dpr->rx_std_buffers[di],
 		       &spr->rx_std_buffers[si],
 		       cpycnt * sizeof(struct ring_info));
@@ -4856,6 +4878,22 @@ static void tg3_rx_prodring_xfer(struct tg3 *tp,
 		si = spr->rx_jmb_cons_idx;
 		di = dpr->rx_jmb_prod_idx;
 
+		for (i = di; i < di + cpycnt; i++) {
+			if (dpr->rx_jmb_buffers[i].skb) {
+				cpycnt = i - di;
+				break;
+			}
+		}
+
+		if (!cpycnt)
+			break;
+
+		/* Ensure that updates to the rx_jmb_buffers ring and the
+		 * shadowed hardware producer ring from tg3_recycle_skb() are
+		 * ordered correctly WRT the skb check above.
+		 */
+		smp_rmb();
+
 		memcpy(&dpr->rx_jmb_buffers[di],
 		       &spr->rx_jmb_buffers[si],
 		       cpycnt * sizeof(struct ring_info));
-- 
1.6.4.4


