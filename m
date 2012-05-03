From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCHv2 3/7] mISDN: L2 timeouts need to be queued as L2 event
Date: Thu,  3 May 2012 17:47:28 +0200
Message-ID: <1336060052-27119-4-git-send-email-kkeil@linux-pingi.de>
References: <1336060052-27119-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:52455 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757595Ab2ECPxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 11:53:04 -0400
In-Reply-To: <1336060052-27119-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>

To be full preemptiv safe, we cannot handle a L2 timeout in the timer
context itself, we should do all actions via the D-channel thread.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/mISDN/layer2.c |   58 +++++++++++++++++++++++++++++++++++++++---
 drivers/isdn/mISDN/tei.c    |   13 +++++++--
 include/linux/mISDNif.h     |    7 ++++-
 3 files changed, 69 insertions(+), 9 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 39d7375..d421495 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -58,6 +58,8 @@ enum {
 	EV_L1_DEACTIVATE,
 	EV_L2_T200,
 	EV_L2_T203,
+	EV_L2_T200I,
+	EV_L2_T203I,
 	EV_L2_SET_OWN_BUSY,
 	EV_L2_CLEAR_OWN_BUSY,
 	EV_L2_FRAME_ERROR,
@@ -86,6 +88,8 @@ static char *strL2Event[] =
 	"EV_L1_DEACTIVATE",
 	"EV_L2_T200",
 	"EV_L2_T203",
+	"EV_L2_T200I",
+	"EV_L2_T203I",
 	"EV_L2_SET_OWN_BUSY",
 	"EV_L2_CLEAR_OWN_BUSY",
 	"EV_L2_FRAME_ERROR",
@@ -276,6 +280,31 @@ ph_data_confirm(struct layer2 *l2, struct mISDNhead *hh, struct sk_buff *skb) {
 	return ret;
 }
 
+static void
+l2_timeout(struct FsmInst *fi, int event, void *arg)
+{
+	struct layer2 *l2 = fi->userdata;
+	struct sk_buff *skb;
+	struct mISDNhead *hh;
+
+	skb = mI_alloc_skb(0, GFP_ATOMIC);
+	if (!skb) {
+		printk(KERN_WARNING "L2(%d,%d) nr:%x timer %s lost - no skb\n",
+			l2->sapi, l2->tei, l2->ch.nr, event == EV_L2_T200 ?
+			"T200" : "T203");
+		return;
+	}
+	hh = mISDN_HEAD_P(skb);
+	hh->prim = event == EV_L2_T200 ? DL_TIMER200_IND : DL_TIMER203_IND;
+	hh->id = l2->ch.nr;
+	if (*debug & DEBUG_TIMER)
+		printk(KERN_DEBUG "L2(%d,%d) nr:%x timer %s expired\n",
+			l2->sapi, l2->tei, l2->ch.nr, event == EV_L2_T200 ?
+			"T200" : "T203");
+	if (l2->ch.st)
+		l2->ch.st->own.recv(&l2->ch.st->own, skb);
+}
+
 static int
 l2mgr(struct layer2 *l2, u_int prim, void *arg) {
 	long c = (long)arg;
@@ -1814,11 +1843,16 @@ static struct FsmNode L2FnList[] =
 	{ST_L2_8, EV_L2_SUPER, l2_st8_got_super},
 	{ST_L2_7, EV_L2_I, l2_got_iframe},
 	{ST_L2_8, EV_L2_I, l2_got_iframe},
-	{ST_L2_5, EV_L2_T200, l2_st5_tout_200},
-	{ST_L2_6, EV_L2_T200, l2_st6_tout_200},
-	{ST_L2_7, EV_L2_T200, l2_st7_tout_200},
-	{ST_L2_8, EV_L2_T200, l2_st8_tout_200},
-	{ST_L2_7, EV_L2_T203, l2_st7_tout_203},
+	{ST_L2_5, EV_L2_T200, l2_timeout},
+	{ST_L2_6, EV_L2_T200, l2_timeout},
+	{ST_L2_7, EV_L2_T200, l2_timeout},
+	{ST_L2_8, EV_L2_T200, l2_timeout},
+	{ST_L2_7, EV_L2_T203, l2_timeout},
+	{ST_L2_5, EV_L2_T200I, l2_st5_tout_200},
+	{ST_L2_6, EV_L2_T200I, l2_st6_tout_200},
+	{ST_L2_7, EV_L2_T200I, l2_st7_tout_200},
+	{ST_L2_8, EV_L2_T200I, l2_st8_tout_200},
+	{ST_L2_7, EV_L2_T203I, l2_st7_tout_203},
 	{ST_L2_7, EV_L2_ACK_PULL, l2_pull_iqueue},
 	{ST_L2_7, EV_L2_SET_OWN_BUSY, l2_set_own_busy},
 	{ST_L2_8, EV_L2_SET_OWN_BUSY, l2_set_own_busy},
@@ -1932,6 +1966,14 @@ l2_send(struct mISDNchannel *ch, struct sk_buff *skb)
 	if (*debug & DEBUG_L2_RECV)
 		printk(KERN_DEBUG "%s: prim(%x) id(%x) sapi(%d) tei(%d)\n",
 		       __func__, hh->prim, hh->id, l2->sapi, l2->tei);
+	if (hh->prim == DL_INTERN_MSG) {
+		struct mISDNhead *chh = hh + 1; /* saved copy */
+
+		*hh = *chh;
+		if (*debug & DEBUG_L2_RECV)
+			printk(KERN_DEBUG "%s: prim(%x) id(%x) internal msg\n",
+				__func__, hh->prim, hh->id);
+	}
 	switch (hh->prim) {
 	case PH_DATA_IND:
 		ret = ph_data_indication(l2, hh, skb);
@@ -1987,6 +2029,12 @@ l2_send(struct mISDNchannel *ch, struct sk_buff *skb)
 		ret = mISDN_FsmEvent(&l2->l2m, EV_L2_DL_RELEASE_REQ,
 				     skb);
 		break;
+	case DL_TIMER200_IND:
+		mISDN_FsmEvent(&l2->l2m, EV_L2_T200I, NULL);
+		break;
+	case DL_TIMER203_IND:
+		mISDN_FsmEvent(&l2->l2m, EV_L2_T203I, NULL);
+		break;
 	default:
 		if (*debug & DEBUG_L2)
 			l2m_debug(&l2->l2m, "l2 unknown pr %04x",
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index 0023433..b340338 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -1293,7 +1293,7 @@ static int
 mgr_bcast(struct mISDNchannel *ch, struct sk_buff *skb)
 {
 	struct manager		*mgr = container_of(ch, struct manager, bcast);
-	struct mISDNhead	*hh = mISDN_HEAD_P(skb);
+	struct mISDNhead	*hhc, *hh = mISDN_HEAD_P(skb);
 	struct sk_buff		*cskb = NULL;
 	struct layer2		*l2;
 	u_long			flags;
@@ -1308,10 +1308,17 @@ mgr_bcast(struct mISDNchannel *ch, struct sk_buff *skb)
 				skb = NULL;
 			} else {
 				if (!cskb)
-					cskb = skb_copy(skb, GFP_KERNEL);
+					cskb = skb_copy(skb, GFP_ATOMIC);
 			}
 			if (cskb) {
-				ret = l2->ch.send(&l2->ch, cskb);
+				hhc = mISDN_HEAD_P(cskb);
+				/* save original header behind normal header */
+				hhc++;
+				*hhc = *hh;
+				hhc--;
+				hhc->prim = DL_INTERN_MSG;
+				hhc->id = l2->ch.nr;
+				ret = ch->st->own.recv(&ch->st->own, cskb);
 				if (ret) {
 					if (*debug & DEBUG_SEND_ERR)
 						printk(KERN_DEBUG
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index b5e7f22..b80f764 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		21
+#define MISDN_RELEASE		26
 
 /* primitives for information exchange
  * generell format
@@ -115,6 +115,11 @@
 #define MDL_ERROR_IND		0x1F04
 #define MDL_ERROR_RSP		0x5F04
 
+/* intern layer 2 */
+#define DL_TIMER200_IND		0x7004
+#define DL_TIMER203_IND		0x7304
+#define DL_INTERN_MSG		0x7804
+
 /* DL_INFORMATION_IND types */
 #define DL_INFO_L2_CONNECT	0x0001
 #define DL_INFO_L2_REMOVED	0x0002
-- 
1.7.3.4
