From: sjur.brandeland@stericsson.com
Subject: [net-next 11/11] caif-hsi: Remove use of module parameters
Date: Mon, 25 Jun 2012 19:49:43 +0200
Message-ID: <1340646583-21059-12-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:58023 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754750Ab2FYRuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:50:13 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so6807294lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:50:12 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Remove use of module parameters on caif hsi device, as
rtnl configuration parameters are already supported.

All caif hsi configuration data is put in cfhsi_config,
and default values in hsi_default_config.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |  151 ++++++++++++++++++++---------------=
-------
 include/net/caif/caif_hsi.h |   14 +++-
 2 files changed, 82 insertions(+), 83 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 0927c10..1c2bd01 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -32,51 +32,39 @@ MODULE_DESCRIPTION("CAIF HSI driver");
 #define PAD_POW2(x, pow) ((((x)&((pow)-1)) =3D=3D 0) ? 0 :\
 				(((pow)-((x)&((pow)-1)))))
=20
-static int inactivity_timeout =3D 1000;
-module_param(inactivity_timeout, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(inactivity_timeout, "Inactivity timeout on HSI, ms.")=
;
+static const struct cfhsi_config  hsi_default_config =3D {
=20
-static int aggregation_timeout =3D 1;
-module_param(aggregation_timeout, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(aggregation_timeout, "Aggregation timeout on HSI, ms.=
");
+	/* Inactivity timeout on HSI, ms */
+	.inactivity_timeout =3D HZ,
=20
-/*
- * HSI padding options.
- * Warning: must be a base of 2 (& operation used) and can not be zero=
 !
- */
-static int hsi_head_align =3D 4;
-module_param(hsi_head_align, int, S_IRUGO);
-MODULE_PARM_DESC(hsi_head_align, "HSI head alignment.");
+	/* Aggregation timeout (ms) of zero means no aggregation is done*/
+	.aggregation_timeout =3D 1,
=20
-static int hsi_tail_align =3D 4;
-module_param(hsi_tail_align, int, S_IRUGO);
-MODULE_PARM_DESC(hsi_tail_align, "HSI tail alignment.");
-
-/*
- * HSI link layer flowcontrol thresholds.
- * Warning: A high threshold value migth increase throughput but it wi=
ll at
- * the same time prevent channel prioritization and increase the risk =
of
- * flooding the modem. The high threshold should be above the low.
- */
-static int hsi_high_threshold =3D 100;
-module_param(hsi_high_threshold, int, S_IRUGO);
-MODULE_PARM_DESC(hsi_high_threshold, "HSI high threshold (FLOW OFF).")=
;
+	/*
+	 * HSI link layer flow-control thresholds.
+	 * Threshold values for the HSI packet queue. Flow-control will be
+	 * asserted when the number of packets exceeds q_high_mark. It will
+	 * not be de-asserted before the number of packets drops below
+	 * q_low_mark.
+	 * Warning: A high threshold value might increase throughput but it
+	 * will at the same time prevent channel prioritization and increase
+	 * the risk of flooding the modem. The high threshold should be above
+	 * the low.
+	 */
+	.q_high_mark =3D 100,
+	.q_low_mark =3D 50,
=20
-static int hsi_low_threshold =3D 50;
-module_param(hsi_low_threshold, int, S_IRUGO);
-MODULE_PARM_DESC(hsi_low_threshold, "HSI high threshold (FLOW ON).");
+	/*
+	 * HSI padding options.
+	 * Warning: must be a base of 2 (& operation used) and can not be zer=
o !
+	 */
+	.head_align =3D 4,
+	.tail_align =3D 4,
+};
=20
 #define ON 1
 #define OFF 0
=20
-/*
- * Threshold values for the HSI packet queue. Flowcontrol will be asse=
rted
- * when the number of packets exceeds HIGH_WATER_MARK. It will not be
- * de-asserted before the number of packets drops below LOW_WATER_MARK=
=2E
- */
-#define LOW_WATER_MARK   hsi_low_threshold
-#define HIGH_WATER_MARK  hsi_high_threshold
-
 static LIST_HEAD(cfhsi_list);
=20
 static void cfhsi_inactivity_tout(unsigned long arg)
@@ -99,8 +87,8 @@ static void cfhsi_update_aggregation_stats(struct cfh=
si *cfhsi,
 	int hpad, tpad, len;
=20
 	info =3D (struct caif_payload_info *)&skb->cb;
-	hpad =3D 1 + PAD_POW2((info->hdr_len + 1), hsi_head_align);
-	tpad =3D PAD_POW2((skb->len + hpad), hsi_tail_align);
+	hpad =3D 1 + PAD_POW2((info->hdr_len + 1), cfhsi->cfg.head_align);
+	tpad =3D PAD_POW2((skb->len + hpad), cfhsi->cfg.tail_align);
 	len =3D skb->len + hpad + tpad;
=20
 	if (direction > 0)
@@ -113,7 +101,7 @@ static bool cfhsi_can_send_aggregate(struct cfhsi *=
cfhsi)
 {
 	int i;
=20
-	if (cfhsi->aggregation_timeout =3D=3D 0)
+	if (cfhsi->cfg.aggregation_timeout =3D=3D 0)
 		return true;
=20
 	for (i =3D 0; i < CFHSI_PRIO_BEBK; ++i) {
@@ -169,7 +157,7 @@ static void cfhsi_abort_tx(struct cfhsi *cfhsi)
 	cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
 	if (!test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		mod_timer(&cfhsi->inactivity_timer,
-			jiffies + cfhsi->inactivity_timeout);
+			jiffies + cfhsi->cfg.inactivity_timeout);
 	spin_unlock_bh(&cfhsi->lock);
 }
=20
@@ -250,8 +238,8 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 		/* Calculate needed head alignment and tail alignment. */
 		info =3D (struct caif_payload_info *)&skb->cb;
=20
-		hpad =3D 1 + PAD_POW2((info->hdr_len + 1), hsi_head_align);
-		tpad =3D PAD_POW2((skb->len + hpad), hsi_tail_align);
+		hpad =3D 1 + PAD_POW2((info->hdr_len + 1), cfhsi->cfg.head_align);
+		tpad =3D PAD_POW2((skb->len + hpad), cfhsi->cfg.tail_align);
=20
 		/* Check if frame still fits with added alignment. */
 		if ((skb->len + hpad + tpad) <=3D CFHSI_MAX_EMB_FRM_SZ) {
@@ -292,8 +280,8 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 		/* Calculate needed head alignment and tail alignment. */
 		info =3D (struct caif_payload_info *)&skb->cb;
=20
-		hpad =3D 1 + PAD_POW2((info->hdr_len + 1), hsi_head_align);
-		tpad =3D PAD_POW2((skb->len + hpad), hsi_tail_align);
+		hpad =3D 1 + PAD_POW2((info->hdr_len + 1), cfhsi->cfg.head_align);
+		tpad =3D PAD_POW2((skb->len + hpad), cfhsi->cfg.tail_align);
=20
 		/* Fill in CAIF frame length in descriptor. */
 		desc->cffrm_len[nfrms] =3D hpad + skb->len + tpad;
@@ -364,7 +352,7 @@ static void cfhsi_start_tx(struct cfhsi *cfhsi)
 			cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
 			/* Start inactivity timer. */
 			mod_timer(&cfhsi->inactivity_timer,
-				jiffies + cfhsi->inactivity_timeout);
+				jiffies + cfhsi->cfg.inactivity_timeout);
 			spin_unlock_bh(&cfhsi->lock);
 			break;
 		}
@@ -390,7 +378,7 @@ static void cfhsi_tx_done(struct cfhsi *cfhsi)
 	 */
 	spin_lock_bh(&cfhsi->lock);
 	if (cfhsi->flow_off_sent &&
-			cfhsi_tx_queue_len(cfhsi) <=3D cfhsi->q_low_mark &&
+			cfhsi_tx_queue_len(cfhsi) <=3D cfhsi->cfg.q_low_mark &&
 			cfhsi->cfdev.flowctrl) {
=20
 		cfhsi->flow_off_sent =3D 0;
@@ -402,7 +390,7 @@ static void cfhsi_tx_done(struct cfhsi *cfhsi)
 		cfhsi_start_tx(cfhsi);
 	} else {
 		mod_timer(&cfhsi->aggregation_timer,
-			jiffies + cfhsi->aggregation_timeout);
+			jiffies + cfhsi->cfg.aggregation_timeout);
 		spin_unlock_bh(&cfhsi->lock);
 	}
=20
@@ -645,7 +633,7 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 	/* Update inactivity timer if pending. */
 	spin_lock_bh(&cfhsi->lock);
 	mod_timer_pending(&cfhsi->inactivity_timer,
-			jiffies + cfhsi->inactivity_timeout);
+			jiffies + cfhsi->cfg.inactivity_timeout);
 	spin_unlock_bh(&cfhsi->lock);
=20
 	if (cfhsi->rx_state.state =3D=3D CFHSI_RX_STATE_DESC) {
@@ -880,7 +868,7 @@ wake_ack:
 			__func__);
 		/* Start inactivity timer. */
 		mod_timer(&cfhsi->inactivity_timer,
-				jiffies + cfhsi->inactivity_timeout);
+				jiffies + cfhsi->cfg.inactivity_timeout);
 		spin_unlock_bh(&cfhsi->lock);
 		return;
 	}
@@ -1071,7 +1059,7 @@ static int cfhsi_xmit(struct sk_buff *skb, struct=
 net_device *dev)
=20
 	/* Send flow off if number of packets is above high water mark. */
 	if (!cfhsi->flow_off_sent &&
-		cfhsi_tx_queue_len(cfhsi) > cfhsi->q_high_mark &&
+		cfhsi_tx_queue_len(cfhsi) > cfhsi->cfg.q_high_mark &&
 		cfhsi->cfdev.flowctrl) {
 		cfhsi->flow_off_sent =3D 1;
 		cfhsi->cfdev.flowctrl(cfhsi->ndev, OFF);
@@ -1143,6 +1131,7 @@ static void cfhsi_setup(struct net_device *dev)
 	cfhsi->cfdev.use_stx =3D false;
 	cfhsi->cfdev.use_fcs =3D false;
 	cfhsi->ndev =3D dev;
+	cfhsi->cfg =3D hsi_default_config;
 }
=20
 static int cfhsi_open(struct net_device *ndev)
@@ -1158,9 +1147,6 @@ static int cfhsi_open(struct net_device *ndev)
=20
 	/* Set flow info */
 	cfhsi->flow_off_sent =3D 0;
-	cfhsi->q_low_mark =3D LOW_WATER_MARK;
-	cfhsi->q_high_mark =3D HIGH_WATER_MARK;
-
=20
 	/*
 	 * Allocate a TX buffer with the size of a HSI packet descriptors
@@ -1188,20 +1174,8 @@ static int cfhsi_open(struct net_device *ndev)
 		goto err_alloc_rx_flip;
 	}
=20
-	/* Pre-calculate inactivity timeout. */
-	if (inactivity_timeout !=3D -1) {
-		cfhsi->inactivity_timeout =3D
-				inactivity_timeout * HZ / 1000;
-		if (!cfhsi->inactivity_timeout)
-			cfhsi->inactivity_timeout =3D 1;
-		else if (cfhsi->inactivity_timeout > NEXT_TIMER_MAX_DELTA)
-			cfhsi->inactivity_timeout =3D NEXT_TIMER_MAX_DELTA;
-	} else {
-		cfhsi->inactivity_timeout =3D NEXT_TIMER_MAX_DELTA;
-	}
-
 	/* Initialize aggregation timeout */
-	cfhsi->aggregation_timeout =3D aggregation_timeout;
+	cfhsi->cfg.aggregation_timeout =3D hsi_default_config.aggregation_tim=
eout;
=20
 	/* Initialize recieve vaiables. */
 	cfhsi->rx_ptr =3D cfhsi->rx_buf;
@@ -1350,24 +1324,39 @@ static void cfhsi_netlink_parms(struct nlattr *=
data[], struct cfhsi *cfhsi)
 	}
=20
 	i =3D __IFLA_CAIF_HSI_INACTIVITY_TOUT;
-	if (data[i])
-		inactivity_timeout =3D nla_get_u32(data[i]);
+	/*
+	 * Inactivity timeout in millisecs. Lowest possible value is 1,
+	 * and highest possible is NEXT_TIMER_MAX_DELTA.
+	 */
+	if (data[i]) {
+		u32 inactivity_timeout =3D nla_get_u32(data[i]);
+		/* Pre-calculate inactivity timeout. */
+		cfhsi->cfg.inactivity_timeout =3D	inactivity_timeout * HZ / 1000;
+		if (cfhsi->cfg.inactivity_timeout =3D=3D 0)
+			cfhsi->cfg.inactivity_timeout =3D 1;
+		else if (cfhsi->cfg.inactivity_timeout > NEXT_TIMER_MAX_DELTA)
+			cfhsi->cfg.inactivity_timeout =3D NEXT_TIMER_MAX_DELTA;
+	}
=20
 	i =3D __IFLA_CAIF_HSI_AGGREGATION_TOUT;
 	if (data[i])
-		aggregation_timeout =3D nla_get_u32(data[i]);
+		cfhsi->cfg.aggregation_timeout =3D nla_get_u32(data[i]);
=20
 	i =3D __IFLA_CAIF_HSI_HEAD_ALIGN;
 	if (data[i])
-		hsi_head_align =3D nla_get_u32(data[i]);
+		cfhsi->cfg.head_align =3D nla_get_u32(data[i]);
=20
 	i =3D __IFLA_CAIF_HSI_TAIL_ALIGN;
 	if (data[i])
-		hsi_tail_align =3D nla_get_u32(data[i]);
+		cfhsi->cfg.tail_align =3D nla_get_u32(data[i]);
=20
 	i =3D __IFLA_CAIF_HSI_QHIGH_WATERMARK;
 	if (data[i])
-		hsi_high_threshold =3D nla_get_u32(data[i]);
+		cfhsi->cfg.q_high_mark =3D nla_get_u32(data[i]);
+
+	i =3D __IFLA_CAIF_HSI_QLOW_WATERMARK;
+	if (data[i])
+		cfhsi->cfg.q_low_mark =3D nla_get_u32(data[i]);
 }
=20
 static int caif_hsi_changelink(struct net_device *dev, struct nlattr *=
tb[],
@@ -1398,16 +1387,20 @@ static size_t caif_hsi_get_size(const struct ne=
t_device *dev)
=20
 static int caif_hsi_fill_info(struct sk_buff *skb, const struct net_de=
vice *dev)
 {
+	struct cfhsi *cfhsi =3D netdev_priv(dev);
+
 	if (nla_put_u32(skb, __IFLA_CAIF_HSI_INACTIVITY_TOUT,
-			inactivity_timeout) ||
+			cfhsi->cfg.inactivity_timeout) ||
 	    nla_put_u32(skb, __IFLA_CAIF_HSI_AGGREGATION_TOUT,
-			aggregation_timeout) ||
-	    nla_put_u32(skb, __IFLA_CAIF_HSI_HEAD_ALIGN, hsi_head_align) ||
-	    nla_put_u32(skb, __IFLA_CAIF_HSI_TAIL_ALIGN, hsi_tail_align) ||
+			cfhsi->cfg.aggregation_timeout) ||
+	    nla_put_u32(skb, __IFLA_CAIF_HSI_HEAD_ALIGN,
+			cfhsi->cfg.head_align) ||
+	    nla_put_u32(skb, __IFLA_CAIF_HSI_TAIL_ALIGN,
+			cfhsi->cfg.tail_align) ||
 	    nla_put_u32(skb, __IFLA_CAIF_HSI_QHIGH_WATERMARK,
-			hsi_high_threshold) ||
+			cfhsi->cfg.q_high_mark) ||
 	    nla_put_u32(skb, __IFLA_CAIF_HSI_QLOW_WATERMARK,
-			hsi_low_threshold))
+			cfhsi->cfg.q_low_mark))
 		return -EMSGSIZE;
=20
 	return 0;
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 6dc7dc2..bcb9cc3 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -132,6 +132,15 @@ enum {
 	CFHSI_PRIO_LAST,
 };
=20
+struct cfhsi_config {
+	u32 inactivity_timeout;
+	u32 aggregation_timeout;
+	u32 head_align;
+	u32 tail_align;
+	u32 q_high_mark;
+	u32 q_low_mark;
+};
+
 /* Structure implemented by CAIF HSI drivers. */
 struct cfhsi {
 	struct caif_dev_common cfdev;
@@ -142,7 +151,7 @@ struct cfhsi {
 	struct cfhsi_ops *ops;
 	int tx_state;
 	struct cfhsi_rx_state rx_state;
-	unsigned long inactivity_timeout;
+	struct cfhsi_config cfg;
 	int rx_len;
 	u8 *rx_ptr;
 	u8 *tx_buf;
@@ -150,8 +159,6 @@ struct cfhsi {
 	u8 *rx_flip_buf;
 	spinlock_t lock;
 	int flow_off_sent;
-	u32 q_low_mark;
-	u32 q_high_mark;
 	struct list_head list;
 	struct work_struct wake_up_work;
 	struct work_struct wake_down_work;
@@ -164,7 +171,6 @@ struct cfhsi {
 	struct timer_list rx_slowpath_timer;
=20
 	/* TX aggregation */
-	unsigned long aggregation_timeout;
 	int aggregation_len;
 	struct timer_list aggregation_timer;
=20
--=20
1.7.5.4
