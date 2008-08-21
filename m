From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 3/4] ctcm: netdev->priv vs. netdev->ml_priv
Date: Thu, 21 Aug 2008 17:10:24 +0200
Message-ID: <20080821151653.559725000@linux.vnet.ibm.com>
References: <20080821151021.069615000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:56604 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084AbYHUPRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:17:00 -0400
Content-Disposition: inline; filename=605-ctcm-mlpriv.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

Use netdev->ml_priv instead of netdev->priv

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>

---
 drivers/s390/net/ctcm_fsms.c |   56 +++++++++++++++++++++----------------------
 drivers/s390/net/ctcm_main.c |   24 +++++++++---------
 drivers/s390/net/ctcm_main.h |    9 +++---
 drivers/s390/net/ctcm_mpc.c  |   46 +++++++++++++++++------------------
 4 files changed, 68 insertions(+), 67 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_fsms.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
@@ -245,7 +245,7 @@ static void chx_txdone(fsm_instance *fi,
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct sk_buff *skb;
 	int first = 1;
 	int i;
@@ -336,7 +336,7 @@ void ctcm_chx_txidle(fsm_instance *fi, i
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCM_PR_DEBUG("%s(%s): %s\n", __func__, ch->id, dev->name);
 
@@ -357,7 +357,7 @@ static void chx_rx(fsm_instance *fi, int
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	int len = ch->max_bufsize - ch->irb->scsw.cmd.count;
 	struct sk_buff *skb = ch->trans_skb;
 	__u16 block_len = *((__u16 *)skb->data);
@@ -459,7 +459,7 @@ static void chx_firstio(fsm_instance *fi
 			chx_rxidle(fi, event, arg);
 		} else {
 			struct net_device *dev = ch->netdev;
-			struct ctcm_priv *priv = dev->priv;
+			struct ctcm_priv *priv = dev->ml_priv;
 			fsm_newstate(fi, CTC_STATE_TXIDLE);
 			fsm_event(priv->fsm, DEV_EVENT_TXUP, dev);
 		}
@@ -496,7 +496,7 @@ static void chx_firstio(fsm_instance *fi
 	if ((CHANNEL_DIRECTION(ch->flags) == READ) &&
 	    (ch->protocol == CTCM_PROTO_S390)) {
 		struct net_device *dev = ch->netdev;
-		struct ctcm_priv *priv = dev->priv;
+		struct ctcm_priv *priv = dev->ml_priv;
 		fsm_event(priv->fsm, DEV_EVENT_RXUP, dev);
 	}
 }
@@ -514,7 +514,7 @@ static void chx_rxidle(fsm_instance *fi,
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	__u16 buflen;
 	int rc;
 
@@ -699,7 +699,7 @@ static void ctcm_chx_cleanup(fsm_instanc
 		struct channel *ch)
 {
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCM_DBF_TEXT_(SETUP, CTC_DBF_NOTICE,
 			"%s(%s): %s[%d]\n",
@@ -784,7 +784,7 @@ static void ctcm_chx_setuperr(fsm_instan
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	/*
 	 * Special case: Got UC_RCRESET on setmode.
@@ -874,7 +874,7 @@ static void ctcm_chx_rxiniterr(fsm_insta
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	if (event == CTC_EVENT_TIMER) {
 		if (!IS_MPCDEV(dev))
@@ -902,7 +902,7 @@ static void ctcm_chx_rxinitfail(fsm_inst
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
 			"%s(%s): RX %s busy, init. fail",
@@ -923,7 +923,7 @@ static void ctcm_chx_rxdisc(fsm_instance
 	struct channel *ch = arg;
 	struct channel *ch2;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
 			"%s: %s: remote disconnect - re-init ...",
@@ -954,7 +954,7 @@ static void ctcm_chx_txiniterr(fsm_insta
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	if (event == CTC_EVENT_TIMER) {
 		fsm_deltimer(&ch->timer);
@@ -984,7 +984,7 @@ static void ctcm_chx_txretry(fsm_instanc
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct sk_buff *skb;
 
 	CTCM_PR_DEBUG("Enter: %s: cp=%i ch=0x%p id=%s\n",
@@ -1057,7 +1057,7 @@ static void ctcm_chx_iofatal(fsm_instanc
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	int rd = CHANNEL_DIRECTION(ch->flags);
 
 	fsm_deltimer(&ch->timer);
@@ -1207,7 +1207,7 @@ static void ctcmpc_chx_txdone(fsm_instan
 {
 	struct channel		*ch = arg;
 	struct net_device	*dev = ch->netdev;
-	struct ctcm_priv	*priv = dev->priv;
+	struct ctcm_priv	*priv = dev->ml_priv;
 	struct mpc_group	*grp = priv->mpcg;
 	struct sk_buff		*skb;
 	int		first = 1;
@@ -1368,7 +1368,7 @@ static void ctcmpc_chx_rx(fsm_instance *
 {
 	struct channel		*ch = arg;
 	struct net_device	*dev = ch->netdev;
-	struct ctcm_priv	*priv = dev->priv;
+	struct ctcm_priv	*priv = dev->ml_priv;
 	struct mpc_group	*grp = priv->mpcg;
 	struct sk_buff		*skb = ch->trans_skb;
 	struct sk_buff		*new_skb;
@@ -1471,7 +1471,7 @@ static void ctcmpc_chx_firstio(fsm_insta
 {
 	struct channel		*ch = arg;
 	struct net_device	*dev = ch->netdev;
-	struct ctcm_priv	*priv = dev->priv;
+	struct ctcm_priv	*priv = dev->ml_priv;
 	struct mpc_group	*gptr = priv->mpcg;
 
 	CTCM_PR_DEBUG("Enter %s: id=%s, ch=0x%p\n",
@@ -1525,7 +1525,7 @@ void ctcmpc_chx_rxidle(fsm_instance *fi,
 {
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv  *priv = dev->priv;
+	struct ctcm_priv  *priv = dev->ml_priv;
 	struct mpc_group  *grp = priv->mpcg;
 	int rc;
 	unsigned long saveflags = 0;	/* avoids compiler warning */
@@ -1580,7 +1580,7 @@ static void ctcmpc_chx_attn(fsm_instance
 {
 	struct channel	  *ch     = arg;
 	struct net_device *dev    = ch->netdev;
-	struct ctcm_priv  *priv   = dev->priv;
+	struct ctcm_priv  *priv   = dev->ml_priv;
 	struct mpc_group  *grp = priv->mpcg;
 
 	CTCM_PR_DEBUG("%s(%s): %s(ch=0x%p), cp=%i, ChStat:%s, GrpStat:%s\n",
@@ -1639,7 +1639,7 @@ static void ctcmpc_chx_attnbusy(fsm_inst
 {
 	struct channel	  *ch     = arg;
 	struct net_device *dev    = ch->netdev;
-	struct ctcm_priv  *priv   = dev->priv;
+	struct ctcm_priv  *priv   = dev->ml_priv;
 	struct mpc_group  *grp    = priv->mpcg;
 
 	CTCM_PR_DEBUG("%s(%s): %s\n  ChState:%s GrpState:%s\n",
@@ -1724,7 +1724,7 @@ static void ctcmpc_chx_resend(fsm_instan
 {
 	struct channel	   *ch	   = arg;
 	struct net_device  *dev    = ch->netdev;
-	struct ctcm_priv   *priv   = dev->priv;
+	struct ctcm_priv   *priv   = dev->ml_priv;
 	struct mpc_group   *grp    = priv->mpcg;
 
 	fsm_event(grp->fsm, MPCG_EVENT_XID0DO, ch);
@@ -1740,7 +1740,7 @@ static void ctcmpc_chx_send_sweep(fsm_in
 {
 	struct channel *ach = arg;
 	struct net_device *dev = ach->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
 	struct channel *wch = priv->channel[WRITE];
 	struct channel *rch = priv->channel[READ];
@@ -2050,7 +2050,7 @@ int mpc_ch_fsm_len = ARRAY_SIZE(ctcmpc_c
 static void dev_action_start(fsm_instance *fi, int event, void *arg)
 {
 	struct net_device *dev = arg;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	int direction;
 
 	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
@@ -2076,7 +2076,7 @@ static void dev_action_stop(fsm_instance
 {
 	int direction;
 	struct net_device *dev = arg;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
 
@@ -2096,7 +2096,7 @@ static void dev_action_restart(fsm_insta
 {
 	int restart_timer;
 	struct net_device *dev = arg;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCMY_DBF_DEV_NAME(TRACE, dev, "");
 
@@ -2133,12 +2133,12 @@ static void dev_action_restart(fsm_insta
 static void dev_action_chup(fsm_instance *fi, int event, void *arg)
 {
 	struct net_device *dev = arg;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	int dev_stat = fsm_getstate(fi);
 
 	CTCM_DBF_TEXT_(SETUP, CTC_DBF_NOTICE,
 			"%s(%s): priv = %p [%d,%d]\n ",	CTCM_FUNTAIL,
-				dev->name, dev->priv, dev_stat, event);
+				dev->name, dev->ml_priv, dev_stat, event);
 
 	switch (fsm_getstate(fi)) {
 	case DEV_STATE_STARTWAIT_RXTX:
@@ -2195,7 +2195,7 @@ static void dev_action_chdown(fsm_instan
 {
 
 	struct net_device *dev = arg;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
 
Index: linux-2.6-uschi/drivers/s390/net/ctcm_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_main.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_main.c
@@ -69,7 +69,7 @@ struct channel *channels;
 void ctcm_unpack_skb(struct channel *ch, struct sk_buff *pskb)
 {
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	__u16 len = *((__u16 *) pskb->data);
 
 	skb_put(pskb, 2 + LL_HEADER_LENGTH);
@@ -414,7 +414,7 @@ int ctcm_ch_alloc_buffer(struct channel 
  */
 int ctcm_open(struct net_device *dev)
 {
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
 	if (!IS_MPC(priv))
@@ -432,7 +432,7 @@ int ctcm_open(struct net_device *dev)
  */
 int ctcm_close(struct net_device *dev)
 {
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
 	if (!IS_MPC(priv))
@@ -573,7 +573,7 @@ static int ctcm_transmit_skb(struct chan
 		skb_pull(skb, LL_HEADER_LENGTH + 2);
 	} else if (ccw_idx == 0) {
 		struct net_device *dev = ch->netdev;
-		struct ctcm_priv *priv = dev->priv;
+		struct ctcm_priv *priv = dev->ml_priv;
 		priv->stats.tx_packets++;
 		priv->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
 	}
@@ -592,7 +592,7 @@ static void ctcmpc_send_sweep_req(struct
 	struct channel *ch;
 	/* int rc = 0; */
 
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	grp = priv->mpcg;
 	ch = priv->channel[WRITE];
 
@@ -652,7 +652,7 @@ static int ctcmpc_transmit_skb(struct ch
 {
 	struct pdu *p_header;
 	struct net_device *dev = ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
 	struct th_header *header;
 	struct sk_buff *nskb;
@@ -867,7 +867,7 @@ done:
 /* first merge version - leaving both functions separated */
 static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 
 	if (skb == NULL) {
 		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
@@ -911,7 +911,7 @@ static int ctcm_tx(struct sk_buff *skb, 
 static int ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	int len = 0;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp  = priv->mpcg;
 	struct sk_buff *newskb = NULL;
 
@@ -1025,7 +1025,7 @@ static int ctcm_change_mtu(struct net_de
 	if (new_mtu < 576 || new_mtu > 65527)
 		return -EINVAL;
 
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	max_bufsize = priv->channel[READ]->max_bufsize;
 
 	if (IS_MPC(priv)) {
@@ -1050,7 +1050,7 @@ static int ctcm_change_mtu(struct net_de
  */
 static struct net_device_stats *ctcm_stats(struct net_device *dev)
 {
-	return &((struct ctcm_priv *)dev->priv)->stats;
+	return &((struct ctcm_priv *)dev->ml_priv)->stats;
 }
 
 static void ctcm_free_netdevice(struct net_device *dev)
@@ -1060,7 +1060,7 @@ static void ctcm_free_netdevice(struct n
 
 	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
 			"%s(%s)", CTCM_FUNTAIL, dev->name);
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	if (priv) {
 		grp = priv->mpcg;
 		if (grp) {
@@ -1125,7 +1125,7 @@ static struct net_device *ctcm_init_netd
 			CTCM_FUNTAIL);
 		return NULL;
 	}
-	dev->priv = priv;
+	dev->ml_priv = priv;
 	priv->fsm = init_fsm("ctcmdev", dev_state_names, dev_event_names,
 				CTCM_NR_DEV_STATES, CTCM_NR_DEV_EVENTS,
 				dev_fsm, dev_fsm_len, GFP_KERNEL);
Index: linux-2.6-uschi/drivers/s390/net/ctcm_main.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_main.h
+++ linux-2.6-uschi/drivers/s390/net/ctcm_main.h
@@ -229,14 +229,14 @@ void ctcm_remove_files(struct device *de
  */
 static inline void ctcm_clear_busy_do(struct net_device *dev)
 {
-	clear_bit(0, &(((struct ctcm_priv *)dev->priv)->tbusy));
+	clear_bit(0, &(((struct ctcm_priv *)dev->ml_priv)->tbusy));
 	netif_wake_queue(dev);
 }
 
 static inline void ctcm_clear_busy(struct net_device *dev)
 {
 	struct mpc_group *grp;
-	grp = ((struct ctcm_priv *)dev->priv)->mpcg;
+	grp = ((struct ctcm_priv *)dev->ml_priv)->mpcg;
 
 	if (!(grp && grp->in_sweep))
 		ctcm_clear_busy_do(dev);
@@ -246,7 +246,8 @@ static inline void ctcm_clear_busy(struc
 static inline int ctcm_test_and_set_busy(struct net_device *dev)
 {
 	netif_stop_queue(dev);
-	return test_and_set_bit(0, &(((struct ctcm_priv *)dev->priv)->tbusy));
+	return test_and_set_bit(0,
+			&(((struct ctcm_priv *)dev->ml_priv)->tbusy));
 }
 
 extern int loglevel;
@@ -292,7 +293,7 @@ struct mpc_group *ctcmpc_init_mpc_group(
 #define IS_MPC(p) ((p)->protocol == CTCM_PROTO_MPC)
 
 /* test if struct ctcm_priv of struct net_device has MPC protocol setting */
-#define IS_MPCDEV(d) IS_MPC((struct ctcm_priv *)d->priv)
+#define IS_MPCDEV(dev) IS_MPC((struct ctcm_priv *)dev->ml_priv)
 
 static inline gfp_t gfp_type(void)
 {
Index: linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_mpc.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
@@ -313,10 +313,10 @@ static struct net_device *ctcmpc_get_dev
 					CTCM_FUNTAIL, device);
 		return NULL;
 	}
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	if (priv == NULL) {
 		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
-			"%s(%s): dev->priv is NULL",
+			"%s(%s): dev->ml_priv is NULL",
 					CTCM_FUNTAIL, device);
 		return NULL;
 	}
@@ -345,7 +345,7 @@ int ctc_mpc_alloc_channel(int port_num, 
 	dev = ctcmpc_get_dev(port_num);
 	if (dev == NULL)
 		return 1;
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	grp = priv->mpcg;
 
 	grp->allochanfunc = callback;
@@ -417,7 +417,7 @@ void ctc_mpc_establish_connectivity(int 
 	dev = ctcmpc_get_dev(port_num);
 	if (dev == NULL)
 		return;
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	grp = priv->mpcg;
 	rch = priv->channel[READ];
 	wch = priv->channel[WRITE];
@@ -535,7 +535,7 @@ void ctc_mpc_dealloc_ch(int port_num)
 	dev = ctcmpc_get_dev(port_num);
 	if (dev == NULL)
 		return;
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	grp = priv->mpcg;
 
 	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_DEBUG,
@@ -571,7 +571,7 @@ void ctc_mpc_flow_control(int port_num, 
 	dev = ctcmpc_get_dev(port_num);
 	if (dev == NULL)
 		return;
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	grp = priv->mpcg;
 
 	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
@@ -620,7 +620,7 @@ static void mpc_rcvd_sweep_resp(struct m
 {
 	struct channel	  *rch = mpcginfo->ch;
 	struct net_device *dev = rch->netdev;
-	struct ctcm_priv   *priv = dev->priv;
+	struct ctcm_priv   *priv = dev->ml_priv;
 	struct mpc_group  *grp = priv->mpcg;
 	struct channel	  *ch = priv->channel[WRITE];
 
@@ -651,7 +651,7 @@ static void mpc_rcvd_sweep_resp(struct m
 static void ctcmpc_send_sweep_resp(struct channel *rch)
 {
 	struct net_device *dev = rch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
 	int rc = 0;
 	struct th_sweep *header;
@@ -713,7 +713,7 @@ static void mpc_rcvd_sweep_req(struct mp
 {
 	struct channel	  *rch     = mpcginfo->ch;
 	struct net_device *dev     = rch->netdev;
-	struct ctcm_priv  *priv = dev->priv;
+	struct ctcm_priv  *priv = dev->ml_priv;
 	struct mpc_group  *grp  = priv->mpcg;
 	struct channel	  *ch	   = priv->channel[WRITE];
 
@@ -847,7 +847,7 @@ static int mpcg_fsm_len = ARRAY_SIZE(mpc
 static void mpc_action_go_ready(fsm_instance *fsm, int event, void *arg)
 {
 	struct net_device *dev = arg;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
 
 	if (grp == NULL) {
@@ -891,7 +891,7 @@ static void mpc_action_go_ready(fsm_inst
 void mpc_group_ready(unsigned long adev)
 {
 	struct net_device *dev = (struct net_device *)adev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
 	struct channel *ch = NULL;
 
@@ -947,7 +947,7 @@ void mpc_group_ready(unsigned long adev)
 void mpc_channel_action(struct channel *ch, int direction, int action)
 {
 	struct net_device  *dev  = ch->netdev;
-	struct ctcm_priv   *priv = dev->priv;
+	struct ctcm_priv   *priv = dev->ml_priv;
 	struct mpc_group   *grp  = priv->mpcg;
 
 	if (grp == NULL) {
@@ -1057,7 +1057,7 @@ done:
 static void ctcmpc_unpack_skb(struct channel *ch, struct sk_buff *pskb)
 {
 	struct net_device *dev	= ch->netdev;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
 	struct pdu *curr_pdu;
 	struct mpcg_info *mpcginfo;
@@ -1255,7 +1255,7 @@ void ctcmpc_bh(unsigned long thischan)
 	struct channel	  *ch	= (struct channel *)thischan;
 	struct sk_buff	  *skb;
 	struct net_device *dev	= ch->netdev;
-	struct ctcm_priv  *priv	= dev->priv;
+	struct ctcm_priv  *priv	= dev->ml_priv;
 	struct mpc_group  *grp	= priv->mpcg;
 
 	CTCM_PR_DEBUG("%s cp:%i enter:  %s() %s\n",
@@ -1377,7 +1377,7 @@ static void mpc_action_go_inop(fsm_insta
 	BUG_ON(dev == NULL);
 	CTCM_PR_DEBUG("Enter %s: %s\n",	__func__, dev->name);
 
-	priv  = dev->priv;
+	priv  = dev->ml_priv;
 	grp =  priv->mpcg;
 	grp->flow_off_called = 0;
 	fsm_deltimer(&grp->timer);
@@ -1483,7 +1483,7 @@ static void mpc_action_timeout(fsm_insta
 
 	BUG_ON(dev == NULL);
 
-	priv = dev->priv;
+	priv = dev->ml_priv;
 	grp = priv->mpcg;
 	wch = priv->channel[WRITE];
 	rch = priv->channel[READ];
@@ -1521,7 +1521,7 @@ void mpc_action_discontact(fsm_instance 
 	if (ch) {
 		dev = ch->netdev;
 		if (dev) {
-			priv = dev->priv;
+			priv = dev->ml_priv;
 			if (priv) {
 				CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_NOTICE,
 					"%s: %s: %s\n",
@@ -1569,7 +1569,7 @@ static int mpc_validate_xid(struct mpcg_
 {
 	struct channel	   *ch	 = mpcginfo->ch;
 	struct net_device  *dev  = ch->netdev;
-	struct ctcm_priv   *priv = dev->priv;
+	struct ctcm_priv   *priv = dev->ml_priv;
 	struct mpc_group   *grp  = priv->mpcg;
 	struct xid2	   *xid  = mpcginfo->xid;
 	int	rc	 = 0;
@@ -1866,7 +1866,7 @@ static void mpc_action_doxid0(fsm_instan
 {
 	struct channel	   *ch   = arg;
 	struct net_device  *dev  = ch->netdev;
-	struct ctcm_priv   *priv = dev->priv;
+	struct ctcm_priv   *priv = dev->ml_priv;
 	struct mpc_group   *grp  = priv->mpcg;
 
 	CTCM_PR_DEBUG("Enter %s: cp=%i ch=0x%p id=%s\n",
@@ -1906,7 +1906,7 @@ static void mpc_action_doxid0(fsm_instan
 static void mpc_action_doxid7(fsm_instance *fsm, int event, void *arg)
 {
 	struct net_device *dev = arg;
-	struct ctcm_priv  *priv = dev->priv;
+	struct ctcm_priv  *priv = dev->ml_priv;
 	struct mpc_group  *grp  = NULL;
 	int direction;
 	int send = 0;
@@ -1983,7 +1983,7 @@ static void mpc_action_rcvd_xid0(fsm_ins
 	struct mpcg_info   *mpcginfo  = arg;
 	struct channel	   *ch   = mpcginfo->ch;
 	struct net_device  *dev  = ch->netdev;
-	struct ctcm_priv   *priv = dev->priv;
+	struct ctcm_priv   *priv = dev->ml_priv;
 	struct mpc_group   *grp  = priv->mpcg;
 
 	CTCM_PR_DEBUG("%s: ch-id:%s xid2:%i xid7:%i xidt_p2:%i \n",
@@ -2045,7 +2045,7 @@ static void mpc_action_rcvd_xid7(fsm_ins
 	struct mpcg_info   *mpcginfo   = arg;
 	struct channel	   *ch	       = mpcginfo->ch;
 	struct net_device  *dev        = ch->netdev;
-	struct ctcm_priv   *priv    = dev->priv;
+	struct ctcm_priv   *priv    = dev->ml_priv;
 	struct mpc_group   *grp     = priv->mpcg;
 
 	CTCM_PR_DEBUG("Enter %s: cp=%i ch=0x%p id=%s\n",
@@ -2097,7 +2097,7 @@ static int mpc_send_qllc_discontact(stru
 	__u32	new_len	= 0;
 	struct sk_buff   *skb;
 	struct qllc      *qllcptr;
-	struct ctcm_priv *priv = dev->priv;
+	struct ctcm_priv *priv = dev->ml_priv;
 	struct mpc_group *grp = priv->mpcg;
 
 	CTCM_PR_DEBUG("%s: GROUP STATE: %s\n",

-- 
