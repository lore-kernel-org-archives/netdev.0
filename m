From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 32/41] CAPI: Rework capiminor RX handler
Date: Mon,  8 Feb 2010 21:12:36 +0100
Message-ID: <986a5c803a1c55bd0d7d721024a471fbe43953c9.1265659936.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate02.web.de ([217.72.192.227]:43397 "EHLO
	fmmailgate02.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333Ab0BHUNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 15:13:14 -0500
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid re-queuing skbs unless the error detected in handle_recv_skb is
expected to be recoverable such as lacking memory, a full CAPI queue, a
full TTY input buffer, or a not yet existing TTY.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   60 +++++++++++++++++++++++++++++-----------------
 1 files changed, 38 insertions(+), 22 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 554fa1b..c5c54fa 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -436,15 +436,13 @@ gen_data_b3_resp_for(struct capiminor *mp, struct sk_buff *skb)
 
 static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 {
+	unsigned int datalen = skb->len - CAPIMSG_LEN(skb->data);
 	struct tty_struct *tty;
 	struct sk_buff *nskb;
-	int datalen;
 	u16 errcode, datahandle;
 	struct tty_ldisc *ld;
 	int ret = -1;
 
-	datalen = skb->len - CAPIMSG_LEN(skb->data);
-
 	tty = tty_port_tty_get(&mp->port);
 	if (!tty) {
 #ifdef _DEBUG_DATAFLOW
@@ -454,50 +452,68 @@ static int handle_recv_skb(struct capiminor *mp, struct sk_buff *skb)
 	}
 	
 	ld = tty_ldisc_ref(tty);
-	if (!ld)
-		goto out1;
+	if (!ld) {
+		/* fatal error, do not requeue */
+		ret = 0;
+		kfree_skb(skb);
+		goto deref_tty;
+	}
 
 	if (ld->ops->receive_buf == NULL) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: ldisc has no receive_buf function\n");
 #endif
-		goto out2;
+		/* fatal error, do not requeue */
+		goto free_skb;
 	}
 	if (mp->ttyinstop) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: recv tty throttled\n");
 #endif
-		goto out2;
+		goto deref_ldisc;
 	}
+
 	if (tty->receive_room < datalen) {
 #if defined(_DEBUG_DATAFLOW) || defined(_DEBUG_TTYFUNCS)
 		printk(KERN_DEBUG "capi: no room in tty\n");
 #endif
-		goto out2;
+		goto deref_ldisc;
 	}
-	if ((nskb = gen_data_b3_resp_for(mp, skb)) == NULL) {
+
+	nskb = gen_data_b3_resp_for(mp, skb);
+	if (!nskb) {
 		printk(KERN_ERR "capi: gen_data_b3_resp failed\n");
-		goto out2;
+		goto deref_ldisc;
 	}
-	datahandle = CAPIMSG_U16(skb->data,CAPIMSG_BASELEN+4);
+
+	datahandle = CAPIMSG_U16(skb->data, CAPIMSG_BASELEN + 4);
+
 	errcode = capi20_put_message(mp->ap, nskb);
-	if (errcode != CAPI_NOERROR) {
+
+	if (errcode == CAPI_NOERROR) {
+		skb_pull(skb, CAPIMSG_LEN(skb->data));
+#ifdef _DEBUG_DATAFLOW
+		printk(KERN_DEBUG "capi: DATA_B3_RESP %u len=%d => ldisc\n",
+					datahandle, skb->len);
+#endif
+		ld->ops->receive_buf(tty, skb->data, NULL, skb->len);
+	} else {
 		printk(KERN_ERR "capi: send DATA_B3_RESP failed=%x\n",
 				errcode);
 		kfree_skb(nskb);
-		goto out2;
+
+		if (errcode == CAPI_SENDQUEUEFULL)
+			goto deref_ldisc;
 	}
-	(void)skb_pull(skb, CAPIMSG_LEN(skb->data));
-#ifdef _DEBUG_DATAFLOW
-	printk(KERN_DEBUG "capi: DATA_B3_RESP %u len=%d => ldisc\n",
-				datahandle, skb->len);
-#endif
-	ld->ops->receive_buf(tty, skb->data, NULL, skb->len);
-	kfree_skb(skb);
+
+free_skb:
 	ret = 0;
-out2:
+	kfree_skb(skb);
+
+deref_ldisc:
 	tty_ldisc_deref(ld);
-out1:
+
+deref_tty:
 	tty_kref_put(tty);
 	return ret;
 }
-- 
1.6.0.2

