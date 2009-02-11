From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4] bnx2: Fix jumbo frames error handling.
Date: Wed, 11 Feb 2009 15:52:17 -0800
Message-ID: <1234396338-14859-3-git-send-email-mchan@broadcom.com>
References: <1234396338-14859-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Matt Carlson" <mcarlson@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1145 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066AbZBKXoa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 18:44:30 -0500
In-Reply-To: <1234396338-14859-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If errors are reported on a frame descriptor, we need to
account for the buffer pages that may have been used for this
error packet and recycle them.  Otherwise, we may get the wrong
pages for the next packet.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   30 +++++++++++++++++++-----------
 1 files changed, 19 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 49e0e51..903d13b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2920,18 +2920,8 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 
 		rx_hdr = (struct l2_fhdr *) skb->data;
 		len = rx_hdr->l2_fhdr_pkt_len;
+		status = rx_hdr->l2_fhdr_status;
 
-		if ((status = rx_hdr->l2_fhdr_status) &
-			(L2_FHDR_ERRORS_BAD_CRC |
-			L2_FHDR_ERRORS_PHY_DECODE |
-			L2_FHDR_ERRORS_ALIGNMENT |
-			L2_FHDR_ERRORS_TOO_SHORT |
-			L2_FHDR_ERRORS_GIANT_FRAME)) {
-
-			bnx2_reuse_rx_skb(bp, rxr, skb, sw_ring_cons,
-					  sw_ring_prod);
-			goto next_rx;
-		}
 		hdr_len = 0;
 		if (status & L2_FHDR_STATUS_SPLIT) {
 			hdr_len = rx_hdr->l2_fhdr_ip_xsum;
@@ -2941,6 +2931,24 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			pg_ring_used = 1;
 		}
 
+		if (unlikely(status & (L2_FHDR_ERRORS_BAD_CRC |
+				       L2_FHDR_ERRORS_PHY_DECODE |
+				       L2_FHDR_ERRORS_ALIGNMENT |
+				       L2_FHDR_ERRORS_TOO_SHORT |
+				       L2_FHDR_ERRORS_GIANT_FRAME))) {
+
+			bnx2_reuse_rx_skb(bp, rxr, skb, sw_ring_cons,
+					  sw_ring_prod);
+			if (pg_ring_used) {
+				int pages;
+
+				pages = PAGE_ALIGN(len - hdr_len) >> PAGE_SHIFT;
+
+				bnx2_reuse_rx_skb_pages(bp, rxr, NULL, pages);
+			}
+			goto next_rx;
+		}
+
 		len -= 4;
 
 		if (len <= bp->rx_copy_thresh) {
-- 
1.5.6.GIT


