From: Karsten Keil <keil@b1-systems.de>
Subject: [mISDN PATCH v2 09/19] Fix TEI and SAPI handling
Date: Fri, 22 May 2009 23:04:50 +0200
Message-ID: <cbbb2723784ecf04bcec253c547a9464a2e722c7.1243024967.git.kkeil@pingi.linux-pingi.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758739AbZEVVHM@vger.kernel.org>
In-Reply-To: <cover.1243024967.git.kkeil@pingi.linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreas Eversberg <andreas@eversberg.eu>

Added SAPI value to use SAPIs different than 0.

Now fixed TEIs work in NT mode. This allows PTP endpoint to be connected
to PTMP ports together with other PTMP endpoints.

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/layer2.c |   13 +++++++------
 drivers/isdn/mISDN/layer2.h |    2 +-
 drivers/isdn/mISDN/tei.c    |   25 ++++++++++++-------------
 3 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index d6e2863..0628ef6 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -2068,7 +2068,8 @@ l2_ctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 }
 
 struct layer2 *
-create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_long arg)
+create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_int tei,
+		u_int sapi)
 {
 	struct layer2		*l2;
 	struct channel_req	rq;
@@ -2089,7 +2090,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_long arg)
 		test_and_set_bit(FLG_LAPD, &l2->flag);
 		test_and_set_bit(FLG_LAPD_NET, &l2->flag);
 		test_and_set_bit(FLG_MOD128, &l2->flag);
-		l2->sapi = 0;
+		l2->sapi = sapi;
 		l2->maxlen = MAX_DFRAME_LEN;
 		if (test_bit(OPTION_L2_PMX, &options))
 			l2->window = 7;
@@ -2099,7 +2100,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_long arg)
 			test_and_set_bit(FLG_PTP, &l2->flag);
 		if (test_bit(OPTION_L2_FIXEDTEI, &options))
 			test_and_set_bit(FLG_FIXED_TEI, &l2->flag);
-		l2->tei = (u_int)arg;
+		l2->tei = tei;
 		l2->T200 = 1000;
 		l2->N200 = 3;
 		l2->T203 = 10000;
@@ -2114,7 +2115,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_long arg)
 		test_and_set_bit(FLG_LAPD, &l2->flag);
 		test_and_set_bit(FLG_MOD128, &l2->flag);
 		test_and_set_bit(FLG_ORIG, &l2->flag);
-		l2->sapi = 0;
+		l2->sapi = sapi;
 		l2->maxlen = MAX_DFRAME_LEN;
 		if (test_bit(OPTION_L2_PMX, &options))
 			l2->window = 7;
@@ -2124,7 +2125,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_long arg)
 			test_and_set_bit(FLG_PTP, &l2->flag);
 		if (test_bit(OPTION_L2_FIXEDTEI, &options))
 			test_and_set_bit(FLG_FIXED_TEI, &l2->flag);
-		l2->tei = (u_int)arg;
+		l2->tei = tei;
 		l2->T200 = 1000;
 		l2->N200 = 3;
 		l2->T203 = 10000;
@@ -2180,7 +2181,7 @@ x75create(struct channel_req *crq)
 
 	if (crq->protocol != ISDN_P_B_X75SLP)
 		return -EPROTONOSUPPORT;
-	l2 = create_l2(crq->ch, crq->protocol, 0, 0);
+	l2 = create_l2(crq->ch, crq->protocol, 0, 0, 0);
 	if (!l2)
 		return -ENOMEM;
 	crq->ch = &l2->ch;
diff --git a/drivers/isdn/mISDN/layer2.h b/drivers/isdn/mISDN/layer2.h
index 6293f80..a85984e 100644
--- a/drivers/isdn/mISDN/layer2.h
+++ b/drivers/isdn/mISDN/layer2.h
@@ -90,7 +90,7 @@ enum {
 #define L2_STATE_COUNT (ST_L2_8+1)
 
 extern struct layer2	*create_l2(struct mISDNchannel *, u_int,
-				u_long, u_long);
+				u_long, u_int, u_int);
 extern int		tei_l2(struct layer2 *, u_int, u_long arg);
 
 
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index c75af76..9e88135 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -777,7 +777,7 @@ tei_ph_data_ind(struct teimgr *tm, u_int mt, u_char *dp, int len)
 }
 
 static struct layer2 *
-create_new_tei(struct manager *mgr, int tei)
+create_new_tei(struct manager *mgr, int tei, int sapi)
 {
 	u_long		opt = 0;
 	u_long		flags;
@@ -791,7 +791,7 @@ create_new_tei(struct manager *mgr, int tei)
 	if (mgr->ch.st->dev->Dprotocols
 	  & ((1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1)))
 		test_and_set_bit(OPTION_L2_PMX, &opt);
-	l2 = create_l2(mgr->up, ISDN_P_LAPD_NT, (u_int)opt, (u_long)tei);
+	l2 = create_l2(mgr->up, ISDN_P_LAPD_NT, (u_int)opt, tei, sapi);
 	if (!l2) {
 		printk(KERN_WARNING "%s:no memory for layer2\n", __func__);
 		return NULL;
@@ -839,12 +839,15 @@ new_tei_req(struct manager *mgr, u_char *dp)
 	ri += dp[1];
 	if (!mgr->up)
 		goto denied;
-	tei = get_free_tei(mgr);
+	if (dp[3] != 0xff)
+		tei = dp[3] >> 1; /* 3GPP TS 08.56 6.1.11.2 */
+	else
+		tei = get_free_tei(mgr);
 	if (tei < 0) {
 		printk(KERN_WARNING "%s:No free tei\n", __func__);
 		goto denied;
 	}
-	l2 = create_new_tei(mgr, tei);
+	l2 = create_new_tei(mgr, tei, 0);
 	if (!l2)
 		goto denied;
 	else
@@ -976,8 +979,6 @@ create_teimgr(struct manager *mgr, struct channel_req *crq)
 			__func__, dev_name(&mgr->ch.st->dev->dev),
 			crq->protocol, crq->adr.dev, crq->adr.channel,
 			crq->adr.sapi, crq->adr.tei);
-	if (crq->adr.sapi != 0) /* not supported yet */
-		return -EINVAL;
 	if (crq->adr.tei > GROUP_TEI)
 		return -EINVAL;
 	if (crq->adr.tei < 64)
@@ -1025,7 +1026,7 @@ create_teimgr(struct manager *mgr, struct channel_req *crq)
 		return 0;
 	}
 	l2 = create_l2(crq->ch, crq->protocol, (u_int)opt,
-		(u_long)crq->adr.tei);
+		crq->adr.tei, crq->adr.sapi);
 	if (!l2)
 		return -ENOMEM;
 	l2->tm = kzalloc(sizeof(struct teimgr), GFP_KERNEL);
@@ -1166,7 +1167,7 @@ static int
 check_data(struct manager *mgr, struct sk_buff *skb)
 {
 	struct mISDNhead	*hh =  mISDN_HEAD_P(skb);
-	int			ret, tei;
+	int			ret, tei, sapi;
 	struct layer2		*l2;
 
 	if (*debug & DEBUG_L2_CTRL)
@@ -1178,18 +1179,16 @@ check_data(struct manager *mgr, struct sk_buff *skb)
 		return -ENOTCONN;
 	if (skb->len != 3)
 		return -ENOTCONN;
-	if (skb->data[0] != 0)
-		/* only SAPI 0 command */
-		return -ENOTCONN;
+	sapi = skb->data[0] >> 2;
 	if (!(skb->data[1] & 1)) /* invalid EA1 */
 		return -EINVAL;
-	tei = skb->data[1] >> 0;
+	tei = skb->data[1] >> 1;
 	if (tei > 63) /* not a fixed tei */
 		return -ENOTCONN;
 	if ((skb->data[2] & ~0x10) != SABME)
 		return -ENOTCONN;
 	/* We got a SABME for a fixed TEI */
-	l2 = create_new_tei(mgr, tei);
+	l2 = create_new_tei(mgr, tei, sapi);
 	if (!l2)
 		return -ENOMEM;
 	ret = l2->ch.send(&l2->ch, skb);
-- 
1.6.0.2
