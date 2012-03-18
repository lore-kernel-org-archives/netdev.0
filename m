From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 16/28] mISDN: Help to identify L2 issues
Date: Sun, 18 Mar 2012 14:38:45 +0100
Message-ID: <20120423170550.DABA99FBA7@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:59260 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab2DWRIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With multiple cards is hard to figure out which port cause trouble.
Now we have the informations in the log output.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/mISDN/core.c   |   16 +++++++++
 drivers/isdn/mISDN/layer2.c |   75 ++++++++++++++++++++++++------------------
 include/linux/mISDNif.h     |    3 +-
 3 files changed, 61 insertions(+), 33 deletions(-)

diff --git a/drivers/isdn/mISDN/core.c b/drivers/isdn/mISDN/core.c
index a24530f..c401634 100644
--- a/drivers/isdn/mISDN/core.c
+++ b/drivers/isdn/mISDN/core.c
@@ -355,6 +355,22 @@ mISDN_unregister_Bprotocol(struct Bprotocol *bp)
 }
 EXPORT_SYMBOL(mISDN_unregister_Bprotocol);
 
+static const char *msg_no_channel = "<no channel>";
+static const char *msg_no_stack = "<no stack>";
+static const char *msg_no_stackdev = "<no stack device>";
+
+const char *mISDNDevName4ch(struct mISDNchannel *ch)
+{
+	if (!ch)
+		return msg_no_channel;
+	if (!ch->st)
+		return msg_no_stack;
+	if (!ch->st->dev)
+		return msg_no_stackdev;
+	return dev_name(&ch->st->dev->dev);
+};
+EXPORT_SYMBOL(mISDNDevName4ch);
+
 static int
 mISDNInit(void)
 {
diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index d421495..2829d93 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -110,8 +110,8 @@ l2m_debug(struct FsmInst *fi, char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &va;
 
-	printk(KERN_DEBUG "l2 (sapi %d tei %d): %pV\n",
-	       l2->sapi, l2->tei, &vaf);
+	printk(KERN_DEBUG "%s l2 (sapi %d tei %d): %pV\n",
+	       mISDNDevName4ch(&l2->ch), l2->sapi, l2->tei, &vaf);
 
 	va_end(va);
 }
@@ -154,7 +154,8 @@ l2up(struct layer2 *l2, u_int prim, struct sk_buff *skb)
 	mISDN_HEAD_ID(skb) = (l2->ch.nr << 16) | l2->ch.addr;
 	err = l2->up->send(l2->up, skb);
 	if (err) {
-		printk(KERN_WARNING "%s: err=%d\n", __func__, err);
+		printk(KERN_WARNING "%s: dev %s err=%d\n", __func__,
+			mISDNDevName4ch(&l2->ch), err);
 		dev_kfree_skb(skb);
 	}
 }
@@ -178,7 +179,8 @@ l2up_create(struct layer2 *l2, u_int prim, int len, void *arg)
 		memcpy(skb_put(skb, len), arg, len);
 	err = l2->up->send(l2->up, skb);
 	if (err) {
-		printk(KERN_WARNING "%s: err=%d\n", __func__, err);
+		printk(KERN_WARNING "%s: dev %s err=%d\n", __func__,
+			mISDNDevName4ch(&l2->ch), err);
 		dev_kfree_skb(skb);
 	}
 }
@@ -189,7 +191,8 @@ l2down_skb(struct layer2 *l2, struct sk_buff *skb) {
 
 	ret = l2->ch.recv(l2->ch.peer, skb);
 	if (ret && (*debug & DEBUG_L2_RECV))
-		printk(KERN_DEBUG "l2down_skb: ret(%d)\n", ret);
+		printk(KERN_DEBUG "l2down_skb: dev %s ret(%d)\n",
+			mISDNDevName4ch(&l2->ch), ret);
 	return ret;
 }
 
@@ -289,18 +292,18 @@ l2_timeout(struct FsmInst *fi, int event, void *arg)
 
 	skb = mI_alloc_skb(0, GFP_ATOMIC);
 	if (!skb) {
-		printk(KERN_WARNING "L2(%d,%d) nr:%x timer %s lost - no skb\n",
-			l2->sapi, l2->tei, l2->ch.nr, event == EV_L2_T200 ?
-			"T200" : "T203");
+		printk(KERN_WARNING "%s: L2(%d,%d) nr:%x timer %s no skb\n",
+			mISDNDevName4ch(&l2->ch), l2->sapi, l2->tei,
+			l2->ch.nr, event == EV_L2_T200 ? "T200" : "T203");
 		return;
 	}
 	hh = mISDN_HEAD_P(skb);
 	hh->prim = event == EV_L2_T200 ? DL_TIMER200_IND : DL_TIMER203_IND;
 	hh->id = l2->ch.nr;
 	if (*debug & DEBUG_TIMER)
-		printk(KERN_DEBUG "L2(%d,%d) nr:%x timer %s expired\n",
-			l2->sapi, l2->tei, l2->ch.nr, event == EV_L2_T200 ?
-			"T200" : "T203");
+		printk(KERN_DEBUG "%s: L2(%d,%d) nr:%x timer %s expired\n",
+			mISDNDevName4ch(&l2->ch), l2->sapi, l2->tei,
+			l2->ch.nr, event == EV_L2_T200 ? "T200" : "T203");
 	if (l2->ch.st)
 		l2->ch.st->own.recv(&l2->ch.st->own, skb);
 }
@@ -309,8 +312,8 @@ static int
 l2mgr(struct layer2 *l2, u_int prim, void *arg) {
 	long c = (long)arg;
 
-	printk(KERN_WARNING
-	       "l2mgr: addr:%x prim %x %c\n", l2->id, prim, (char)c);
+	printk(KERN_WARNING "l2mgr: dev %s addr:%x prim %x %c\n",
+		mISDNDevName4ch(&l2->ch), l2->id, prim, (char)c);
 	if (test_bit(FLG_LAPD, &l2->flag) &&
 	    !test_bit(FLG_FIXED_TEI, &l2->flag)) {
 		switch (c) {
@@ -632,8 +635,8 @@ send_uframe(struct layer2 *l2, struct sk_buff *skb, u_char cmd, u_char cr)
 	else {
 		skb = mI_alloc_skb(i, GFP_ATOMIC);
 		if (!skb) {
-			printk(KERN_WARNING "%s: can't alloc skbuff\n",
-			       __func__);
+			printk(KERN_WARNING "%s: can't alloc skbuff in %s\n",
+				mISDNDevName4ch(&l2->ch), __func__);
 			return;
 		}
 	}
@@ -1118,8 +1121,8 @@ enquiry_cr(struct layer2 *l2, u_char typ, u_char cr, u_char pf)
 		tmp[i++] = (l2->vr << 5) | typ | (pf ? 0x10 : 0);
 	skb = mI_alloc_skb(i, GFP_ATOMIC);
 	if (!skb) {
-		printk(KERN_WARNING
-		       "isdnl2 can't alloc sbbuff for enquiry_cr\n");
+		printk(KERN_WARNING "%s: isdnl2 can't alloc sbbuff in %s\n",
+			mISDNDevName4ch(&l2->ch), __func__);
 		return;
 	}
 	memcpy(skb_put(skb, i), tmp, i);
@@ -1179,7 +1182,7 @@ invoke_retransmission(struct layer2 *l2, unsigned int nr)
 			else
 				printk(KERN_WARNING
 				       "%s: windowar[%d] is NULL\n",
-				       __func__, p1);
+				    mISDNDevName4ch(&l2->ch), p1);
 			l2->windowar[p1] = NULL;
 		}
 		mISDN_FsmEvent(&l2->l2m, EV_L2_ACK_PULL, NULL);
@@ -1490,8 +1493,8 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 		p1 = (l2->vs - l2->va) % 8;
 	p1 = (p1 + l2->sow) % l2->window;
 	if (l2->windowar[p1]) {
-		printk(KERN_WARNING "isdnl2 try overwrite ack queue entry %d\n",
-		       p1);
+		printk(KERN_WARNING "%s: l2 try overwrite ack queue entry %d\n",
+		    mISDNDevName4ch(&l2->ch), p1);
 		dev_kfree_skb(l2->windowar[p1]);
 	}
 	l2->windowar[p1] = skb;
@@ -1511,12 +1514,14 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 		memcpy(skb_push(nskb, i), header, i);
 	else {
 		printk(KERN_WARNING
-		       "isdnl2 pull_iqueue skb header(%d/%d) too short\n", i, p1);
+		    "%s: L2 pull_iqueue skb header(%d/%d) too short\n",
+		    mISDNDevName4ch(&l2->ch), i, p1);
 		oskb = nskb;
 		nskb = mI_alloc_skb(oskb->len + i, GFP_ATOMIC);
 		if (!nskb) {
 			dev_kfree_skb(oskb);
-			printk(KERN_WARNING "%s: no skb mem\n", __func__);
+			printk(KERN_WARNING "%s: no skb mem in %s\n",
+			    mISDNDevName4ch(&l2->ch), __func__);
 			return;
 		}
 		memcpy(skb_put(nskb, i), header, i);
@@ -1892,7 +1897,8 @@ ph_data_indication(struct layer2 *l2, struct mISDNhead *hh, struct sk_buff *skb)
 		ptei = *datap++;
 		if ((psapi & 1) || !(ptei & 1)) {
 			printk(KERN_WARNING
-			       "l2 D-channel frame wrong EA0/EA1\n");
+			    "%s l2 D-channel frame wrong EA0/EA1\n",
+			    mISDNDevName4ch(&l2->ch));
 			return ret;
 		}
 		psapi >>= 2;
@@ -1901,7 +1907,7 @@ ph_data_indication(struct layer2 *l2, struct mISDNhead *hh, struct sk_buff *skb)
 			/* not our business */
 			if (*debug & DEBUG_L2)
 				printk(KERN_DEBUG "%s: sapi %d/%d mismatch\n",
-				       __func__, psapi, l2->sapi);
+				    mISDNDevName4ch(&l2->ch), psapi, l2->sapi);
 			dev_kfree_skb(skb);
 			return 0;
 		}
@@ -1909,7 +1915,7 @@ ph_data_indication(struct layer2 *l2, struct mISDNhead *hh, struct sk_buff *skb)
 			/* not our business */
 			if (*debug & DEBUG_L2)
 				printk(KERN_DEBUG "%s: tei %d/%d mismatch\n",
-				       __func__, ptei, l2->tei);
+				    mISDNDevName4ch(&l2->ch), ptei, l2->tei);
 			dev_kfree_skb(skb);
 			return 0;
 		}
@@ -1950,7 +1956,8 @@ ph_data_indication(struct layer2 *l2, struct mISDNhead *hh, struct sk_buff *skb)
 	} else
 		c = 'L';
 	if (c) {
-		printk(KERN_WARNING "l2 D-channel frame error %c\n", c);
+		printk(KERN_WARNING "%s:l2 D-channel frame error %c\n",
+		    mISDNDevName4ch(&l2->ch), c);
 		mISDN_FsmEvent(&l2->l2m, EV_L2_FRAME_ERROR, (void *)(long)c);
 	}
 	return ret;
@@ -1964,15 +1971,16 @@ l2_send(struct mISDNchannel *ch, struct sk_buff *skb)
 	int			ret = -EINVAL;
 
 	if (*debug & DEBUG_L2_RECV)
-		printk(KERN_DEBUG "%s: prim(%x) id(%x) sapi(%d) tei(%d)\n",
-		       __func__, hh->prim, hh->id, l2->sapi, l2->tei);
+		printk(KERN_DEBUG "%s: %s prim(%x) id(%x) sapi(%d) tei(%d)\n",
+		    __func__, mISDNDevName4ch(&l2->ch), hh->prim, hh->id,
+		    l2->sapi, l2->tei);
 	if (hh->prim == DL_INTERN_MSG) {
 		struct mISDNhead *chh = hh + 1; /* saved copy */
 
 		*hh = *chh;
 		if (*debug & DEBUG_L2_RECV)
 			printk(KERN_DEBUG "%s: prim(%x) id(%x) internal msg\n",
-				__func__, hh->prim, hh->id);
+				mISDNDevName4ch(&l2->ch), hh->prim, hh->id);
 	}
 	switch (hh->prim) {
 	case PH_DATA_IND:
@@ -2053,7 +2061,8 @@ tei_l2(struct layer2 *l2, u_int cmd, u_long arg)
 	int		ret = -EINVAL;
 
 	if (*debug & DEBUG_L2_TEI)
-		printk(KERN_DEBUG "%s: cmd(%x)\n", __func__, cmd);
+		printk(KERN_DEBUG "%s: cmd(%x) in %s\n",
+		    mISDNDevName4ch(&l2->ch), cmd, __func__);
 	switch (cmd) {
 	case (MDL_ASSIGN_REQ):
 		ret = mISDN_FsmEvent(&l2->l2m, EV_L2_MDL_ASSIGN, (void *)arg);
@@ -2066,7 +2075,8 @@ tei_l2(struct layer2 *l2, u_int cmd, u_long arg)
 		break;
 	case (MDL_ERROR_RSP):
 		/* ETS 300-125 5.3.2.1 Test: TC13010 */
-		printk(KERN_NOTICE "MDL_ERROR|REQ (tei_l2)\n");
+		printk(KERN_NOTICE "%s: MDL_ERROR|REQ (tei_l2)\n",
+		    mISDNDevName4ch(&l2->ch));
 		ret = mISDN_FsmEvent(&l2->l2m, EV_L2_MDL_ERROR, NULL);
 		break;
 	}
@@ -2098,7 +2108,8 @@ l2_ctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 	u_int			info;
 
 	if (*debug & DEBUG_L2_CTRL)
-		printk(KERN_DEBUG "%s:(%x)\n", __func__, cmd);
+		printk(KERN_DEBUG "%s: %s cmd(%x)\n",
+		    mISDNDevName4ch(ch), __func__, cmd);
 
 	switch (cmd) {
 	case OPEN_CHANNEL:
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index 322d316..f474f40 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		27
+#define MISDN_RELEASE		28
 
 /* primitives for information exchange
  * generell format
@@ -598,6 +598,7 @@ static inline struct mISDNdevice *dev_to_mISDN(struct device *dev)
 extern void	set_channel_address(struct mISDNchannel *, u_int, u_int);
 extern void	mISDN_clock_update(struct mISDNclock *, int, struct timeval *);
 extern unsigned short mISDN_clock_get(void);
+extern const char *mISDNDevName4ch(struct mISDNchannel *);
 
 #endif /* __KERNEL__ */
 #endif /* mISDNIF_H */
-- 
1.7.3.4
