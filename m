From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 2/5] isdn/gigaset: clarify gigaset_modem_fill control structure
Date: Wed, 10 Dec 2014 13:41:55 +0100 (CET)
Message-ID: <6f96c6fe10d572f6c19b326c670e9cc197c2153d.1418214588.git.tilman@imap.cc>
References: <cover.1418214588.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:33187 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755889AbaLJM77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 07:59:59 -0500
In-Reply-To: <cover.1418214588.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace the flag-controlled retry loop by explicit goto statements
in the error branches to make the control structure easier to
understand.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/usb-gigaset.c | 52 ++++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 28 deletions(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index a8e652d..c31d746 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -304,7 +304,6 @@ static void gigaset_modem_fill(unsigned long data)
 	struct cardstate *cs = (struct cardstate *) data;
 	struct bc_state *bcs = &cs->bcs[0]; /* only one channel */
 	struct cmdbuf_t *cb;
-	int again;
 
 	gig_dbg(DEBUG_OUTPUT, "modem_fill");
 
@@ -313,36 +312,33 @@ static void gigaset_modem_fill(unsigned long data)
 		return;
 	}
 
-	do {
-		again = 0;
-		if (!bcs->tx_skb) { /* no skb is being sent */
-			cb = cs->cmdbuf;
-			if (cb) { /* commands to send? */
-				gig_dbg(DEBUG_OUTPUT, "modem_fill: cb");
-				if (send_cb(cs, cb) < 0) {
-					gig_dbg(DEBUG_OUTPUT,
-						"modem_fill: send_cb failed");
-					again = 1; /* no callback will be
-						      called! */
-				}
-			} else { /* skbs to send? */
-				bcs->tx_skb = skb_dequeue(&bcs->squeue);
-				if (bcs->tx_skb)
-					gig_dbg(DEBUG_INTR,
-						"Dequeued skb (Adr: %lx)!",
-						(unsigned long) bcs->tx_skb);
-			}
-		}
-
-		if (bcs->tx_skb) {
-			gig_dbg(DEBUG_OUTPUT, "modem_fill: tx_skb");
-			if (write_modem(cs) < 0) {
+again:
+	if (!bcs->tx_skb) {	/* no skb is being sent */
+		cb = cs->cmdbuf;
+		if (cb) {	/* commands to send? */
+			gig_dbg(DEBUG_OUTPUT, "modem_fill: cb");
+			if (send_cb(cs, cb) < 0) {
 				gig_dbg(DEBUG_OUTPUT,
-					"modem_fill: write_modem failed");
-				again = 1; /* no callback will be called! */
+					"modem_fill: send_cb failed");
+				goto again; /* no callback will be called! */
 			}
+			return;
 		}
-	} while (again);
+
+		/* skbs to send? */
+		bcs->tx_skb = skb_dequeue(&bcs->squeue);
+		if (!bcs->tx_skb)
+			return;
+
+		gig_dbg(DEBUG_INTR, "Dequeued skb (Adr: %lx)!",
+			(unsigned long) bcs->tx_skb);
+	}
+
+	gig_dbg(DEBUG_OUTPUT, "modem_fill: tx_skb");
+	if (write_modem(cs) < 0) {
+		gig_dbg(DEBUG_OUTPUT, "modem_fill: write_modem failed");
+		goto again;	/* no callback will be called! */
+	}
 }
 
 /*
-- 
1.9.2.459.g68773ac
