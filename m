From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 3/5] isdn/gigaset: elliminate unnecessary argument from send_cb()
Date: Wed, 10 Dec 2014 13:41:55 +0100 (CET)
Message-ID: <3d4ed5b460bfe97379224f06cd86e0eae7988702.1418214588.git.tilman@imap.cc>
References: <cover.1418214588.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:33187 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755474AbaLJNAG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 08:00:06 -0500
In-Reply-To: <cover.1418214588.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to pass a member of the cardstate structure as a separate
argument if the entire structure is already passed.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/usb-gigaset.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index c31d746..5f306e2 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -293,7 +293,7 @@ static int gigaset_close_bchannel(struct bc_state *bcs)
 }
 
 static int write_modem(struct cardstate *cs);
-static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb);
+static int send_cb(struct cardstate *cs);
 
 
 /* Write tasklet handler: Continue sending current skb, or send command, or
@@ -303,7 +303,6 @@ static void gigaset_modem_fill(unsigned long data)
 {
 	struct cardstate *cs = (struct cardstate *) data;
 	struct bc_state *bcs = &cs->bcs[0]; /* only one channel */
-	struct cmdbuf_t *cb;
 
 	gig_dbg(DEBUG_OUTPUT, "modem_fill");
 
@@ -314,10 +313,9 @@ static void gigaset_modem_fill(unsigned long data)
 
 again:
 	if (!bcs->tx_skb) {	/* no skb is being sent */
-		cb = cs->cmdbuf;
-		if (cb) {	/* commands to send? */
+		if (cs->cmdbuf) {	/* commands to send? */
 			gig_dbg(DEBUG_OUTPUT, "modem_fill: cb");
-			if (send_cb(cs, cb) < 0) {
+			if (send_cb(cs) < 0) {
 				gig_dbg(DEBUG_OUTPUT,
 					"modem_fill: send_cb failed");
 				goto again; /* no callback will be called! */
@@ -425,9 +423,9 @@ static void gigaset_write_bulk_callback(struct urb *urb)
 	spin_unlock_irqrestore(&cs->lock, flags);
 }
 
-static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb)
+static int send_cb(struct cardstate *cs)
 {
-	struct cmdbuf_t *tcb;
+	struct cmdbuf_t *cb = cs->cmdbuf;
 	unsigned long flags;
 	int count;
 	int status = -ENOENT;
@@ -435,26 +433,27 @@ static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb)
 
 	do {
 		if (!cb->len) {
-			tcb = cb;
-
 			spin_lock_irqsave(&cs->cmdlock, flags);
 			cs->cmdbytes -= cs->curlen;
 			gig_dbg(DEBUG_OUTPUT, "send_cb: sent %u bytes, %u left",
 				cs->curlen, cs->cmdbytes);
-			cs->cmdbuf = cb = cb->next;
-			if (cb) {
-				cb->prev = NULL;
-				cs->curlen = cb->len;
+			cs->cmdbuf = cb->next;
+			if (cs->cmdbuf) {
+				cs->cmdbuf->prev = NULL;
+				cs->curlen = cs->cmdbuf->len;
 			} else {
 				cs->lastcmdbuf = NULL;
 				cs->curlen = 0;
 			}
 			spin_unlock_irqrestore(&cs->cmdlock, flags);
 
-			if (tcb->wake_tasklet)
-				tasklet_schedule(tcb->wake_tasklet);
-			kfree(tcb);
+			if (cb->wake_tasklet)
+				tasklet_schedule(cb->wake_tasklet);
+			kfree(cb);
+
+			cb = cs->cmdbuf;
 		}
+
 		if (cb) {
 			count = min(cb->len, ucs->bulk_out_size);
 			gig_dbg(DEBUG_OUTPUT, "send_cb: send %d bytes", count);
-- 
1.9.2.459.g68773ac
