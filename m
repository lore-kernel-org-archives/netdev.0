From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1 1/1] net/lapb: tuse %*ph to dump buffers
Date: Thu, 26 May 2016 14:43:52 +0300
Message-ID: <1464263032-96325-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Maxime Jayat <maxime.jayat@mobile-devices.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:3125 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753463AbcEZLoM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 07:44:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use %*ph specifier to dump small buffers in hex format instead doing this
byte-by-byte.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 net/lapb/lapb_in.c   |  5 ++---
 net/lapb/lapb_out.c  |  4 +---
 net/lapb/lapb_subr.c | 14 +++++---------
 3 files changed, 8 insertions(+), 15 deletions(-)

diff --git a/net/lapb/lapb_in.c b/net/lapb/lapb_in.c
index 5dba899..1824708 100644
--- a/net/lapb/lapb_in.c
+++ b/net/lapb/lapb_in.c
@@ -444,10 +444,9 @@ static void lapb_state3_machine(struct lapb_cb *lapb, struct sk_buff *skb,
 		break;
 
 	case LAPB_FRMR:
-		lapb_dbg(1, "(%p) S3 RX FRMR(%d) %02X %02X %02X %02X %02X\n",
+		lapb_dbg(1, "(%p) S3 RX FRMR(%d) %5ph\n",
 			 lapb->dev, frame->pf,
-			 skb->data[0], skb->data[1], skb->data[2],
-			 skb->data[3], skb->data[4]);
+			 skb->data);
 		lapb_establish_data_link(lapb);
 		lapb_dbg(0, "(%p) S3 -> S1\n", lapb->dev);
 		lapb_requeue_frames(lapb);
diff --git a/net/lapb/lapb_out.c b/net/lapb/lapb_out.c
index ba4d015..482c94d 100644
--- a/net/lapb/lapb_out.c
+++ b/net/lapb/lapb_out.c
@@ -148,9 +148,7 @@ void lapb_transmit_buffer(struct lapb_cb *lapb, struct sk_buff *skb, int type)
 		}
 	}
 
-	lapb_dbg(2, "(%p) S%d TX %02X %02X %02X\n",
-		 lapb->dev, lapb->state,
-		 skb->data[0], skb->data[1], skb->data[2]);
+	lapb_dbg(2, "(%p) S%d TX %3ph\n", lapb->dev, lapb->state, skb->data);
 
 	if (!lapb_data_transmit(lapb, skb))
 		kfree_skb(skb);
diff --git a/net/lapb/lapb_subr.c b/net/lapb/lapb_subr.c
index 9d0a426..3c1914d 100644
--- a/net/lapb/lapb_subr.c
+++ b/net/lapb/lapb_subr.c
@@ -113,9 +113,7 @@ int lapb_decode(struct lapb_cb *lapb, struct sk_buff *skb,
 {
 	frame->type = LAPB_ILLEGAL;
 
-	lapb_dbg(2, "(%p) S%d RX %02X %02X %02X\n",
-		 lapb->dev, lapb->state,
-		 skb->data[0], skb->data[1], skb->data[2]);
+	lapb_dbg(2, "(%p) S%d RX %3ph\n", lapb->dev, lapb->state, skb->data);
 
 	/* We always need to look at 2 bytes, sometimes we need
 	 * to look at 3 and those cases are handled below.
@@ -284,10 +282,9 @@ void lapb_transmit_frmr(struct lapb_cb *lapb)
 		dptr++;
 		*dptr++ = lapb->frmr_type;
 
-		lapb_dbg(1, "(%p) S%d TX FRMR %02X %02X %02X %02X %02X\n",
+		lapb_dbg(1, "(%p) S%d TX FRMR %5ph\n",
 			 lapb->dev, lapb->state,
-			 skb->data[1], skb->data[2], skb->data[3],
-			 skb->data[4], skb->data[5]);
+			 &skb->data[1]);
 	} else {
 		dptr    = skb_put(skb, 4);
 		*dptr++ = LAPB_FRMR;
@@ -299,9 +296,8 @@ void lapb_transmit_frmr(struct lapb_cb *lapb)
 		dptr++;
 		*dptr++ = lapb->frmr_type;
 
-		lapb_dbg(1, "(%p) S%d TX FRMR %02X %02X %02X\n",
-			 lapb->dev, lapb->state, skb->data[1],
-			 skb->data[2], skb->data[3]);
+		lapb_dbg(1, "(%p) S%d TX FRMR %3ph\n",
+			 lapb->dev, lapb->state, &skb->data[1]);
 	}
 
 	lapb_transmit_buffer(lapb, skb, LAPB_RESPONSE);
-- 
2.8.1
