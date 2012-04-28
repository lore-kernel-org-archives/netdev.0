From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 2/8] mISDN: Fix refcounting bug
Date: Sat, 28 Apr 2012 13:43:18 +0200
Message-ID: <1335613404-10187-3-git-send-email-kkeil@linux-pingi.de>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:56645 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055Ab2D1LrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:47:23 -0400
In-Reply-To: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>

Under some configs it was still not possible to unload the driver,
because the module use count was srewed up.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/tei.c |   52 +++++++++++++++++++++++++++++++++------------
 1 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index 969766f..25ed826 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -790,18 +790,22 @@ tei_ph_data_ind(struct teimgr *tm, u_int mt, u_char *dp, int len)
 static struct layer2 *
 create_new_tei(struct manager *mgr, int tei, int sapi)
 {
-	u_long		opt = 0;
-	u_long		flags;
-	int		id;
-	struct layer2	*l2;
+	u_long			opt = 0;
+	u_long			flags;
+	int			id;
+	struct layer2		*l2;
+	struct channel_req	rq;
 
 	if (!mgr->up)
 		return NULL;
 	if ((tei >= 0) && (tei < 64))
 		test_and_set_bit(OPTION_L2_FIXEDTEI, &opt);
-	if (mgr->ch.st->dev->Dprotocols
-	    & ((1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1)))
+	if (mgr->ch.st->dev->Dprotocols & ((1 << ISDN_P_TE_E1) |
+	    (1 << ISDN_P_NT_E1))) {
 		test_and_set_bit(OPTION_L2_PMX, &opt);
+		rq.protocol = ISDN_P_NT_E1;
+	} else
+		rq.protocol = ISDN_P_NT_S0;
 	l2 = create_l2(mgr->up, ISDN_P_LAPD_NT, opt, tei, sapi);
 	if (!l2) {
 		printk(KERN_WARNING "%s:no memory for layer2\n", __func__);
@@ -836,6 +840,14 @@ create_new_tei(struct manager *mgr, int tei, int sapi)
 		l2->ch.recv = mgr->ch.recv;
 		l2->ch.peer = mgr->ch.peer;
 		l2->ch.ctrl(&l2->ch, OPEN_CHANNEL, NULL);
+		/* We need open here L1 for the manager as well (refcounting) */
+		rq.adr.dev = mgr->ch.st->dev->id;
+		id = mgr->ch.st->own.ctrl(&mgr->ch.st->own, OPEN_CHANNEL, &rq);
+		if (id < 0) {
+			printk(KERN_WARNING "%s: cannot open L1\n", __func__);
+			l2->ch.ctrl(&l2->ch, CLOSE_CHANNEL, NULL);
+			l2 = NULL;
+		}
 	}
 	return l2;
 }
@@ -978,10 +990,11 @@ TEIrelease(struct layer2 *l2)
 static int
 create_teimgr(struct manager *mgr, struct channel_req *crq)
 {
-	struct layer2	*l2;
-	u_long		opt = 0;
-	u_long		flags;
-	int		id;
+	struct layer2		*l2;
+	u_long			opt = 0;
+	u_long			flags;
+	int			id;
+	struct channel_req	l1rq;
 
 	if (*debug & DEBUG_L2_TEI)
 		printk(KERN_DEBUG "%s: %s proto(%x) adr(%d %d %d %d)\n",
@@ -1016,6 +1029,7 @@ create_teimgr(struct manager *mgr, struct channel_req *crq)
 		if (crq->protocol == ISDN_P_LAPD_TE)
 			test_and_set_bit(MGR_OPT_USER, &mgr->options);
 	}
+	l1rq.adr = crq->adr;
 	if (mgr->ch.st->dev->Dprotocols
 	    & ((1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1)))
 		test_and_set_bit(OPTION_L2_PMX, &opt);
@@ -1055,24 +1069,34 @@ create_teimgr(struct manager *mgr, struct channel_req *crq)
 		l2->tm->tei_m.fsm = &teifsmu;
 		l2->tm->tei_m.state = ST_TEI_NOP;
 		l2->tm->tval = 1000; /* T201  1 sec */
+		if (test_bit(OPTION_L2_PMX, &opt))
+			l1rq.protocol = ISDN_P_TE_E1;
+		else
+			l1rq.protocol = ISDN_P_TE_S0;
 	} else {
 		l2->tm->tei_m.fsm = &teifsmn;
 		l2->tm->tei_m.state = ST_TEI_NOP;
 		l2->tm->tval = 2000; /* T202  2 sec */
+		if (test_bit(OPTION_L2_PMX, &opt))
+			l1rq.protocol = ISDN_P_NT_E1;
+		else
+			l1rq.protocol = ISDN_P_NT_S0;
 	}
 	mISDN_FsmInitTimer(&l2->tm->tei_m, &l2->tm->timer);
 	write_lock_irqsave(&mgr->lock, flags);
 	id = get_free_id(mgr);
 	list_add_tail(&l2->list, &mgr->layer2);
 	write_unlock_irqrestore(&mgr->lock, flags);
-	if (id < 0) {
-		l2->ch.ctrl(&l2->ch, CLOSE_CHANNEL, NULL);
-	} else {
+	if (id >= 0) {
 		l2->ch.nr = id;
 		l2->up->nr = id;
 		crq->ch = &l2->ch;
-		id = 0;
+		/* We need open here L1 for the manager as well (refcounting) */
+		id = mgr->ch.st->own.ctrl(&mgr->ch.st->own, OPEN_CHANNEL,
+					  &l1rq);
 	}
+	if (id < 0)
+		l2->ch.ctrl(&l2->ch, CLOSE_CHANNEL, NULL);
 	return id;
 }
 
-- 
1.7.3.4
