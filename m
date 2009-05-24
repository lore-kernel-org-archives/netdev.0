From: Karsten Keil <keil@b1-systems.de>
Subject: Re: [mISDN PATCH v2 09/19] Fix TEI and SAPI handling
Date: Sun, 24 May 2009 17:39:48 +0200
Message-ID: <200905241739.48679.keil@b1-systems.de>
References: <cover.1243024967.git.kkeil@pingi.linux-pingi.de> <200905231500.38092.keil@b1-systems.de> <20090523231022.GA13203@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756163AbZEXPj6@vger.kernel.org>
In-Reply-To: <20090523231022.GA13203@uranus.ravnborg.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

new version of this patch:

Subject: [mISDN PATCH v3 09/19] Fix TEI and SAPI handling
From: Karsten Keil <keil@b1-systems.de>
To: linux-kernel@vger.kernel.org
Cc: netdev@vger.kernel.org,
    David Miller <davem@davemloft.net>,
    i4ldeveloper@listserv.isdn4linux.de

From: Andreas Eversberg <andreas@eversberg.eu>

Added SAPI value to use SAPIs different than 0.

Now fixed TEIs work in NT mode. This allows PTP endpoint to be connected
to PTMP ports together with other PTMP endpoints.

New enhanced version, thanks to Sam Ravnborg <sam@ravnborg.org> for the
hints. 

David if you pull from:
"git://master.kernel.org/pub/scm/linux/kernel/git/kkeil/ISDN-2.6-net-next.git 
for_david"
you get the new version.

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index d6e2863..2d2f581 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -2068,7 +2068,8 @@ l2_ctrl(struct mISDNchannel *ch, u_int cmd, void *arg)
 }
 
 struct layer2 *
-create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, u_long 
arg)
+create_l2(struct mISDNchannel *ch, u_int protocol, u_long options, int tei,
+		int sapi)
 {
 	struct layer2		*l2;
 	struct channel_req	rq;
@@ -2089,7 +2090,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, 
u_long options, u_long arg)
 		test_and_set_bit(FLG_LAPD, &l2->flag);
 		test_and_set_bit(FLG_LAPD_NET, &l2->flag);
 		test_and_set_bit(FLG_MOD128, &l2->flag);
-		l2->sapi = 0;
+		l2->sapi = sapi;
 		l2->maxlen = MAX_DFRAME_LEN;
 		if (test_bit(OPTION_L2_PMX, &options))
 			l2->window = 7;
@@ -2099,7 +2100,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, 
u_long options, u_long arg)
 			test_and_set_bit(FLG_PTP, &l2->flag);
 		if (test_bit(OPTION_L2_FIXEDTEI, &options))
 			test_and_set_bit(FLG_FIXED_TEI, &l2->flag);
-		l2->tei = (u_int)arg;
+		l2->tei = tei;
 		l2->T200 = 1000;
 		l2->N200 = 3;
 		l2->T203 = 10000;
@@ -2114,7 +2115,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, 
u_long options, u_long arg)
 		test_and_set_bit(FLG_LAPD, &l2->flag);
 		test_and_set_bit(FLG_MOD128, &l2->flag);
 		test_and_set_bit(FLG_ORIG, &l2->flag);
-		l2->sapi = 0;
+		l2->sapi = sapi;
 		l2->maxlen = MAX_DFRAME_LEN;
 		if (test_bit(OPTION_L2_PMX, &options))
 			l2->window = 7;
@@ -2124,7 +2125,7 @@ create_l2(struct mISDNchannel *ch, u_int protocol, 
u_long options, u_long arg)
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
index 6293f80..9547fb3 100644
--- a/drivers/isdn/mISDN/layer2.h
+++ b/drivers/isdn/mISDN/layer2.h
@@ -90,7 +90,7 @@ enum {
 #define L2_STATE_COUNT (ST_L2_8+1)
 
 extern struct layer2	*create_l2(struct mISDNchannel *, u_int,
-				u_long, u_long);
+				u_long, int, int);
 extern int		tei_l2(struct layer2 *, u_int, u_long arg);
 
 
diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index c75af76..55a7c3d 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -426,7 +426,7 @@ done:
 }
 
 static void
-put_tei_msg(struct manager *mgr, u_char m_id, unsigned int ri, u_char tei)
+put_tei_msg(struct manager *mgr, u_char m_id, unsigned int ri, int tei)
 {
 	struct sk_buff *skb;
 	u_char bp[8];
@@ -440,9 +440,8 @@ put_tei_msg(struct manager *mgr, u_char m_id, unsigned int 
ri, u_char tei)
 	bp[4] = ri >> 8;
 	bp[5] = ri & 0xff;
 	bp[6] = m_id;
-	bp[7] = (tei << 1) | 1;
-	skb = _alloc_mISDN_skb(PH_DATA_REQ, new_id(mgr),
-	    8, bp, GFP_ATOMIC);
+	bp[7] = ((tei << 1) & 0xff) | 1;
+	skb = _alloc_mISDN_skb(PH_DATA_REQ, new_id(mgr), 8, bp, GFP_ATOMIC);
 	if (!skb) {
 		printk(KERN_WARNING "%s: no skb for tei msg\n", __func__);
 		return;
@@ -777,7 +776,7 @@ tei_ph_data_ind(struct teimgr *tm, u_int mt, u_char *dp, 
int len)
 }
 
 static struct layer2 *
-create_new_tei(struct manager *mgr, int tei)
+create_new_tei(struct manager *mgr, int tei, int sapi)
 {
 	u_long		opt = 0;
 	u_long		flags;
@@ -786,12 +785,12 @@ create_new_tei(struct manager *mgr, int tei)
 
 	if (!mgr->up)
 		return NULL;
-	if (tei < 64)
+	if ((tei >= 0) && (tei < 64))
 		test_and_set_bit(OPTION_L2_FIXEDTEI, &opt);
 	if (mgr->ch.st->dev->Dprotocols
 	  & ((1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1)))
 		test_and_set_bit(OPTION_L2_PMX, &opt);
-	l2 = create_l2(mgr->up, ISDN_P_LAPD_NT, (u_int)opt, (u_long)tei);
+	l2 = create_l2(mgr->up, ISDN_P_LAPD_NT, opt, tei, sapi);
 	if (!l2) {
 		printk(KERN_WARNING "%s:no memory for layer2\n", __func__);
 		return NULL;
@@ -839,12 +838,17 @@ new_tei_req(struct manager *mgr, u_char *dp)
 	ri += dp[1];
 	if (!mgr->up)
 		goto denied;
-	tei = get_free_tei(mgr);
+	if (!(dp[3] & 1)) /* Extension bit != 1 */
+		goto denied;
+	if (dp[3] != 0xff)
+		tei = dp[3] >> 1; /* 3GPP TS 08.56 6.1.11.2 */
+	else
+		tei = get_free_tei(mgr);
 	if (tei < 0) {
 		printk(KERN_WARNING "%s:No free tei\n", __func__);
 		goto denied;
 	}
-	l2 = create_new_tei(mgr, tei);
+	l2 = create_new_tei(mgr, tei, CTRL_SAPI);
 	if (!l2)
 		goto denied;
 	else
@@ -976,8 +980,6 @@ create_teimgr(struct manager *mgr, struct channel_req 
*crq)
 			__func__, dev_name(&mgr->ch.st->dev->dev),
 			crq->protocol, crq->adr.dev, crq->adr.channel,
 			crq->adr.sapi, crq->adr.tei);
-	if (crq->adr.sapi != 0) /* not supported yet */
-		return -EINVAL;
 	if (crq->adr.tei > GROUP_TEI)
 		return -EINVAL;
 	if (crq->adr.tei < 64)
@@ -1024,8 +1026,8 @@ create_teimgr(struct manager *mgr, struct channel_req 
*crq)
 		}
 		return 0;
 	}
-	l2 = create_l2(crq->ch, crq->protocol, (u_int)opt,
-		(u_long)crq->adr.tei);
+	l2 = create_l2(crq->ch, crq->protocol, opt,
+		crq->adr.tei, crq->adr.sapi);
 	if (!l2)
 		return -ENOMEM;
 	l2->tm = kzalloc(sizeof(struct teimgr), GFP_KERNEL);
@@ -1166,7 +1168,7 @@ static int
 check_data(struct manager *mgr, struct sk_buff *skb)
 {
 	struct mISDNhead	*hh =  mISDN_HEAD_P(skb);
-	int			ret, tei;
+	int			ret, tei, sapi;
 	struct layer2		*l2;
 
 	if (*debug & DEBUG_L2_CTRL)
@@ -1178,18 +1180,18 @@ check_data(struct manager *mgr, struct sk_buff *skb)
 		return -ENOTCONN;
 	if (skb->len != 3)
 		return -ENOTCONN;
-	if (skb->data[0] != 0)
-		/* only SAPI 0 command */
-		return -ENOTCONN;
+	if (skb->data[0] & 3) /* EA0 and CR must be  0 */
+		return -EINVAL;
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
