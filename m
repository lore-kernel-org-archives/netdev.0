From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 21/28] mISDN: Add interface to allow upper layers to modify RX buffer limits
Date: Sat, 21 Apr 2012 17:26:30 +0200
Message-ID: <20120423170551.0433B9FB98@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:61705 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab2DWRIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems to be useful to let applications decide the
size of the data chunks they want receive.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/avmfritz.c  |   17 +++++++++++++----
 drivers/isdn/hardware/mISDN/mISDNipac.c |   17 +++++++++++++----
 include/linux/mISDNif.h                 |   11 ++++++++++-
 3 files changed, 36 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/avmfritz.c b/drivers/isdn/hardware/mISDN/avmfritz.c
index 4b1c86e..9cee744 100644
--- a/drivers/isdn/hardware/mISDN/avmfritz.c
+++ b/drivers/isdn/hardware/mISDN/avmfritz.c
@@ -835,15 +835,24 @@ init_card(struct fritzcard *fc)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int ret = 0;
+	int ret = 0, o1, o2;
 	struct fritzcard *fc = bch->hw;
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = 0;
+		cq->op = MISDN_CTRL_RX_BUFFER;
+		break;
+	case MISDN_CTRL_RX_BUFFER:
+		/* We return the old values */
+		o1 = bch->minlen;
+		o2 =  bch->maxlen;
+		if (cq->p1 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p1;
+		if (cq->p2 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p2;
+		cq->p1 = o1;
+		cq->p2 = o2;
 		break;
-		/* Nothing implemented yet */
-	case MISDN_CTRL_FILL_EMPTY:
 	default:
 		pr_info("%s: %s unknown Op %x\n", fc->name, __func__, cq->op);
 		ret = -EINVAL;
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 1bc75ae..b32f5bb 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -1395,14 +1395,23 @@ hscx_l2l1(struct mISDNchannel *ch, struct sk_buff *skb)
 static int
 channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 {
-	int	ret = 0;
+	int	ret = 0, o1, o2;
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = 0;
+		cq->op = MISDN_CTRL_RX_BUFFER;
+		break;
+	case MISDN_CTRL_RX_BUFFER:
+		/* We return the old values */
+		o1 = bch->minlen;
+		o2 =  bch->maxlen;
+		if (cq->p1 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p1;
+		if (cq->p2 != MISDN_CTRL_RX_SIZE_IGNORE)
+			bch->minlen = cq->p2;
+		cq->p1 = o1;
+		cq->p2 = o2;
 		break;
-		/* Nothing implemented yet */
-	case MISDN_CTRL_FILL_EMPTY:
 	default:
 		pr_info("%s: unknown Op %x\n", __func__, cq->op);
 		ret = -EINVAL;
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index 850fe1f..b26de1a 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		29
+#define MISDN_RELEASE		30
 
 /* primitives for information exchange
  * generell format
@@ -367,6 +367,7 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_LOOP			0x00000001
 #define MISDN_CTRL_CONNECT		0x00000002
 #define MISDN_CTRL_DISCONNECT		0x00000004
+#define MISDN_CTRL_RX_BUFFER		0x00000008
 #define MISDN_CTRL_GET_PCM_SLOTS	0x00000010
 #define MISDN_CTRL_SET_PCM_SLOTS	0x00000020
 #define MISDN_CTRL_SETPEER		0x00000040
@@ -394,6 +395,14 @@ clear_channelmap(u_int nr, u_char *map)
 #define MISDN_CTRL_L1_TS0_MODE		0x00010003
 #define MISDN_CTRL_L1_GET_SYNC_INFO	0x00010004
 
+/* special RX buffer values for MISDN_CTRL_RX_BUFFER
+ * req.p1 is minimum buffer size, req.p2 the maximum
+ * MISDN_CTRL_RX_SIZE_ IGNORE value will not change but is still read back
+ */
+#define MISDN_CTRL_RX_SIZE_NOCHECK	-1
+#define MISDN_CTRL_RX_SIZE_IGNORE	-2
+
+
 /* special PCM slot numbers */
 #define MISDN_PCM_SLOT_DISABLE	-1	/* PCM disabled */
 #define MISDN_PCM_SLOT_IGNORE	-2	/* PCM setting will be not changed */
-- 
1.7.3.4
