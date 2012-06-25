From: sjur.brandeland@stericsson.com
Subject: [net-next 10/11] caif-hsi: Replace platform device with ops structure.
Date: Mon, 25 Jun 2012 19:49:42 +0200
Message-ID: <1340646583-21059-11-git-send-email-sjur.brandeland@stericsson.com>
References: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34031 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754634Ab2FYRuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 13:50:10 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so6807265lbb.19
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2012 10:50:10 -0700 (PDT)
In-Reply-To: <1340646583-21059-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Remove use of struct platform_device, and replace it with
struct cfhsi_ops. Updated variable names in the same
spirit:
cfhsi_get_dev to cfhsi_get_ops,
cfhsi->dev to cfhsi->ops and,
cfhsi->dev.drv to cfhsi->ops->cb_ops.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |  109 ++++++++++++++++++++---------------=
--------
 include/net/caif/caif_hsi.h |   38 ++++++++--------
 2 files changed, 70 insertions(+), 77 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index a14f85c..0927c10 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -11,7 +11,6 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/device.h>
-#include <linux/platform_device.h>
 #include <linux/netdevice.h>
 #include <linux/string.h>
 #include <linux/list.h>
@@ -184,7 +183,7 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
 		__func__);
=20
 	do {
-		ret =3D cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
+		ret =3D cfhsi->ops->cfhsi_fifo_occupancy(cfhsi->ops,
 				&fifo_occupancy);
 		if (ret) {
 			netdev_warn(cfhsi->ndev,
@@ -197,8 +196,8 @@ static int cfhsi_flush_fifo(struct cfhsi *cfhsi)
=20
 		fifo_occupancy =3D min(sizeof(buffer), fifo_occupancy);
 		set_bit(CFHSI_FLUSH_FIFO, &cfhsi->bits);
-		ret =3D cfhsi->dev->cfhsi_rx(buffer, fifo_occupancy,
-				cfhsi->dev);
+		ret =3D cfhsi->ops->cfhsi_rx(buffer, fifo_occupancy,
+				cfhsi->ops);
 		if (ret) {
 			clear_bit(CFHSI_FLUSH_FIFO, &cfhsi->bits);
 			netdev_warn(cfhsi->ndev,
@@ -371,7 +370,7 @@ static void cfhsi_start_tx(struct cfhsi *cfhsi)
 		}
=20
 		/* Set up new transfer. */
-		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
+		res =3D cfhsi->ops->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->ops);
 		if (WARN_ON(res < 0))
 			netdev_err(cfhsi->ndev, "%s: TX error %d.\n",
 				__func__, res);
@@ -410,11 +409,11 @@ static void cfhsi_tx_done(struct cfhsi *cfhsi)
 	return;
 }
=20
-static void cfhsi_tx_done_cb(struct cfhsi_drv *drv)
+static void cfhsi_tx_done_cb(struct cfhsi_cb_ops *cb_ops)
 {
 	struct cfhsi *cfhsi;
=20
-	cfhsi =3D container_of(drv, struct cfhsi, drv);
+	cfhsi =3D container_of(cb_ops, struct cfhsi, cb_ops);
 	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
@@ -476,8 +475,8 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, s=
truct cfhsi *cfhsi)
 		skb->dev =3D cfhsi->ndev;
=20
 		/*
-		 * We are called from a arch specific platform device.
-		 * Unfortunately we don't know what context we're
+		 * We are in a callback handler and
+		 * unfortunately we don't know what context we're
 		 * running in.
 		 */
 		if (in_interrupt())
@@ -607,7 +606,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, st=
ruct cfhsi *cfhsi)
 		skb->dev =3D cfhsi->ndev;
=20
 		/*
-		 * We're called from a platform device,
+		 * We're called in callback from HSI
 		 * and don't know the context we're running in.
 		 */
 		if (in_interrupt())
@@ -711,8 +710,8 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 		netdev_dbg(cfhsi->ndev, "%s: Start RX.\n",
 				__func__);
=20
-		res =3D cfhsi->dev->cfhsi_rx(rx_ptr, rx_len,
-				cfhsi->dev);
+		res =3D cfhsi->ops->cfhsi_rx(rx_ptr, rx_len,
+				cfhsi->ops);
 		if (WARN_ON(res < 0)) {
 			netdev_err(cfhsi->ndev, "%s: RX error %d.\n",
 				__func__, res);
@@ -765,11 +764,11 @@ static void cfhsi_rx_slowpath(unsigned long arg)
 	cfhsi_rx_done(cfhsi);
 }
=20
-static void cfhsi_rx_done_cb(struct cfhsi_drv *drv)
+static void cfhsi_rx_done_cb(struct cfhsi_cb_ops *cb_ops)
 {
 	struct cfhsi *cfhsi;
=20
-	cfhsi =3D container_of(drv, struct cfhsi, drv);
+	cfhsi =3D container_of(cb_ops, struct cfhsi, cb_ops);
 	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
@@ -803,7 +802,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 	}
=20
 	/* Activate wake line. */
-	cfhsi->dev->cfhsi_wake_up(cfhsi->dev);
+	cfhsi->ops->cfhsi_wake_up(cfhsi->ops);
=20
 	netdev_dbg(cfhsi->ndev, "%s: Start waiting.\n",
 		__func__);
@@ -819,7 +818,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 			__func__, ret);
=20
 		clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
-		cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
+		cfhsi->ops->cfhsi_wake_down(cfhsi->ops);
 		return;
 	} else if (!ret) {
 		bool ca_wake =3D false;
@@ -830,14 +829,14 @@ static void cfhsi_wake_up(struct work_struct *wor=
k)
 			__func__);
=20
 		/* Check FIFO to check if modem has sent something. */
-		WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
+		WARN_ON(cfhsi->ops->cfhsi_fifo_occupancy(cfhsi->ops,
 					&fifo_occupancy));
=20
 		netdev_dbg(cfhsi->ndev, "%s: Bytes in FIFO: %u.\n",
 				__func__, (unsigned) fifo_occupancy);
=20
 		/* Check if we misssed the interrupt. */
-		WARN_ON(cfhsi->dev->cfhsi_get_peer_wake(cfhsi->dev,
+		WARN_ON(cfhsi->ops->cfhsi_get_peer_wake(cfhsi->ops,
 							&ca_wake));
=20
 		if (ca_wake) {
@@ -852,7 +851,7 @@ static void cfhsi_wake_up(struct work_struct *work)
 		}
=20
 		clear_bit(CFHSI_WAKE_UP, &cfhsi->bits);
-		cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
+		cfhsi->ops->cfhsi_wake_down(cfhsi->ops);
 		return;
 	}
 wake_ack:
@@ -865,7 +864,7 @@ wake_ack:
=20
 	/* Resume read operation. */
 	netdev_dbg(cfhsi->ndev, "%s: Start RX.\n", __func__);
-	res =3D cfhsi->dev->cfhsi_rx(cfhsi->rx_ptr, cfhsi->rx_len, cfhsi->dev=
);
+	res =3D cfhsi->ops->cfhsi_rx(cfhsi->rx_ptr, cfhsi->rx_len, cfhsi->ops=
);
=20
 	if (WARN_ON(res < 0))
 		netdev_err(cfhsi->ndev, "%s: RX err %d.\n", __func__, res);
@@ -896,7 +895,7 @@ wake_ack:
=20
 	if (likely(len > 0)) {
 		/* Set up new transfer. */
-		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
+		res =3D cfhsi->ops->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->ops);
 		if (WARN_ON(res < 0)) {
 			netdev_err(cfhsi->ndev, "%s: TX error %d.\n",
 				__func__, res);
@@ -923,7 +922,7 @@ static void cfhsi_wake_down(struct work_struct *wor=
k)
 		return;
=20
 	/* Deactivate wake line. */
-	cfhsi->dev->cfhsi_wake_down(cfhsi->dev);
+	cfhsi->ops->cfhsi_wake_down(cfhsi->ops);
=20
 	/* Wait for acknowledge. */
 	ret =3D CFHSI_WAKE_TOUT;
@@ -942,7 +941,7 @@ static void cfhsi_wake_down(struct work_struct *wor=
k)
 		netdev_err(cfhsi->ndev, "%s: Timeout.\n", __func__);
=20
 		/* Check if we misssed the interrupt. */
-		WARN_ON(cfhsi->dev->cfhsi_get_peer_wake(cfhsi->dev,
+		WARN_ON(cfhsi->ops->cfhsi_get_peer_wake(cfhsi->ops,
 							&ca_wake));
 		if (!ca_wake)
 			netdev_err(cfhsi->ndev, "%s: CA Wake missed !.\n",
@@ -951,7 +950,7 @@ static void cfhsi_wake_down(struct work_struct *wor=
k)
=20
 	/* Check FIFO occupancy. */
 	while (retry) {
-		WARN_ON(cfhsi->dev->cfhsi_fifo_occupancy(cfhsi->dev,
+		WARN_ON(cfhsi->ops->cfhsi_fifo_occupancy(cfhsi->ops,
 							&fifo_occupancy));
=20
 		if (!fifo_occupancy)
@@ -969,8 +968,7 @@ static void cfhsi_wake_down(struct work_struct *wor=
k)
 	clear_bit(CFHSI_AWAKE, &cfhsi->bits);
=20
 	/* Cancel pending RX requests. */
-	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
-
+	cfhsi->ops->cfhsi_rx_cancel(cfhsi->ops);
 }
=20
 static void cfhsi_out_of_sync(struct work_struct *work)
@@ -984,11 +982,11 @@ static void cfhsi_out_of_sync(struct work_struct =
*work)
 	rtnl_unlock();
 }
=20
-static void cfhsi_wake_up_cb(struct cfhsi_drv *drv)
+static void cfhsi_wake_up_cb(struct cfhsi_cb_ops *cb_ops)
 {
 	struct cfhsi *cfhsi =3D NULL;
=20
-	cfhsi =3D container_of(drv, struct cfhsi, drv);
+	cfhsi =3D container_of(cb_ops, struct cfhsi, cb_ops);
 	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
@@ -1003,11 +1001,11 @@ static void cfhsi_wake_up_cb(struct cfhsi_drv *=
drv)
 		queue_work(cfhsi->wq, &cfhsi->wake_up_work);
 }
=20
-static void cfhsi_wake_down_cb(struct cfhsi_drv *drv)
+static void cfhsi_wake_down_cb(struct cfhsi_cb_ops *cb_ops)
 {
 	struct cfhsi *cfhsi =3D NULL;
=20
-	cfhsi =3D container_of(drv, struct cfhsi, drv);
+	cfhsi =3D container_of(cb_ops, struct cfhsi, cb_ops);
 	netdev_dbg(cfhsi->ndev, "%s.\n",
 		__func__);
=20
@@ -1110,7 +1108,7 @@ static int cfhsi_xmit(struct sk_buff *skb, struct=
 net_device *dev)
 		WARN_ON(!len);
=20
 		/* Set up new transfer. */
-		res =3D cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
+		res =3D cfhsi->ops->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->ops);
 		if (WARN_ON(res < 0)) {
 			netdev_err(cfhsi->ndev, "%s: TX error %d.\n",
 				__func__, res);
@@ -1125,19 +1123,19 @@ static int cfhsi_xmit(struct sk_buff *skb, stru=
ct net_device *dev)
 	return 0;
 }
=20
-static const struct net_device_ops cfhsi_ops;
+static const struct net_device_ops cfhsi_netdevops;
=20
 static void cfhsi_setup(struct net_device *dev)
 {
 	int i;
 	struct cfhsi *cfhsi =3D netdev_priv(dev);
 	dev->features =3D 0;
-	dev->netdev_ops =3D &cfhsi_ops;
 	dev->type =3D ARPHRD_CAIF;
 	dev->flags =3D IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu =3D CFHSI_MAX_CAIF_FRAME_SZ;
 	dev->tx_queue_len =3D 0;
 	dev->destructor =3D free_netdev;
+	dev->netdev_ops =3D &cfhsi_netdevops;
 	for (i =3D 0; i < CFHSI_PRIO_LAST; ++i)
 		skb_queue_head_init(&cfhsi->qhead[i]);
 	cfhsi->cfdev.link_select =3D CAIF_LINK_HIGH_BANDW;
@@ -1213,10 +1211,10 @@ static int cfhsi_open(struct net_device *ndev)
 	spin_lock_init(&cfhsi->lock);
=20
 	/* Set up the driver. */
-	cfhsi->drv.tx_done_cb =3D cfhsi_tx_done_cb;
-	cfhsi->drv.rx_done_cb =3D cfhsi_rx_done_cb;
-	cfhsi->drv.wake_up_cb =3D cfhsi_wake_up_cb;
-	cfhsi->drv.wake_down_cb =3D cfhsi_wake_down_cb;
+	cfhsi->cb_ops.tx_done_cb =3D cfhsi_tx_done_cb;
+	cfhsi->cb_ops.rx_done_cb =3D cfhsi_rx_done_cb;
+	cfhsi->cb_ops.wake_up_cb =3D cfhsi_wake_up_cb;
+	cfhsi->cb_ops.wake_down_cb =3D cfhsi_wake_down_cb;
=20
 	/* Initialize the work queues. */
 	INIT_WORK(&cfhsi->wake_up_work, cfhsi_wake_up);
@@ -1230,7 +1228,7 @@ static int cfhsi_open(struct net_device *ndev)
 	clear_bit(CFHSI_AWAKE, &cfhsi->bits);
=20
 	/* Create work thread. */
-	cfhsi->wq =3D create_singlethread_workqueue(cfhsi->pdev->name);
+	cfhsi->wq =3D create_singlethread_workqueue(cfhsi->ndev->name);
 	if (!cfhsi->wq) {
 		netdev_err(cfhsi->ndev, "%s: Failed to create work queue.\n",
 			__func__);
@@ -1257,7 +1255,7 @@ static int cfhsi_open(struct net_device *ndev)
 	cfhsi->aggregation_timer.function =3D cfhsi_aggregation_tout;
=20
 	/* Activate HSI interface. */
-	res =3D cfhsi->dev->cfhsi_up(cfhsi->dev);
+	res =3D cfhsi->ops->cfhsi_up(cfhsi->ops);
 	if (res) {
 		netdev_err(cfhsi->ndev,
 			"%s: can't activate HSI interface: %d.\n",
@@ -1275,7 +1273,7 @@ static int cfhsi_open(struct net_device *ndev)
 	return res;
=20
  err_net_reg:
-	cfhsi->dev->cfhsi_down(cfhsi->dev);
+	cfhsi->ops->cfhsi_down(cfhsi->ops);
  err_activate:
 	destroy_workqueue(cfhsi->wq);
  err_create_wq:
@@ -1305,7 +1303,7 @@ static int cfhsi_close(struct net_device *ndev)
 	del_timer_sync(&cfhsi->aggregation_timer);
=20
 	/* Cancel pending RX request (if any) */
-	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
+	cfhsi->ops->cfhsi_rx_cancel(cfhsi->ops);
=20
 	/* Destroy workqueue */
 	destroy_workqueue(cfhsi->wq);
@@ -1318,7 +1316,7 @@ static int cfhsi_close(struct net_device *ndev)
 	cfhsi_abort_tx(cfhsi);
=20
 	/* Deactivate interface */
-	cfhsi->dev->cfhsi_down(cfhsi->dev);
+	cfhsi->ops->cfhsi_down(cfhsi->ops);
=20
 	/* Free buffers. */
 	kfree(tx_buf);
@@ -1335,7 +1333,7 @@ static void cfhsi_uninit(struct net_device *dev)
 	list_del(&cfhsi->list);
 }
=20
-static const struct net_device_ops cfhsi_ops =3D {
+static const struct net_device_ops cfhsi_netdevops =3D {
 	.ndo_uninit =3D cfhsi_uninit,
 	.ndo_open =3D cfhsi_open,
 	.ndo_stop =3D cfhsi_close,
@@ -1419,7 +1417,7 @@ static int caif_hsi_newlink(struct net *src_net, =
struct net_device *dev,
 			  struct nlattr *tb[], struct nlattr *data[])
 {
 	struct cfhsi *cfhsi =3D NULL;
-	struct platform_device *(*get_dev)(void);
+	struct cfhsi_ops *(*get_ops)(void);
=20
 	ASSERT_RTNL();
=20
@@ -1427,36 +1425,31 @@ static int caif_hsi_newlink(struct net *src_net=
, struct net_device *dev,
 	cfhsi_netlink_parms(data, cfhsi);
 	dev_net_set(cfhsi->ndev, src_net);
=20
-	get_dev =3D symbol_get(cfhsi_get_device);
-	if (!get_dev) {
-		pr_err("%s: failed to get the cfhsi device symbol\n", __func__);
+	get_ops =3D symbol_get(cfhsi_get_ops);
+	if (!get_ops) {
+		pr_err("%s: failed to get the cfhsi_ops\n", __func__);
 		return -ENODEV;
 	}
=20
 	/* Assign the HSI device. */
-	cfhsi->pdev =3D (*get_dev)();
-	if (!cfhsi->pdev) {
-		pr_err("%s: failed to get the cfhsi device\n", __func__);
+	cfhsi->ops =3D (*get_ops)();
+	if (!cfhsi->ops) {
+		pr_err("%s: failed to get the cfhsi_ops\n", __func__);
 		goto err;
 	}
=20
-	/* Assign the HSI device. */
-	cfhsi->dev =3D cfhsi->pdev->dev.platform_data;
-
 	/* Assign the driver to this HSI device. */
-	cfhsi->dev->drv =3D &cfhsi->drv;
-
+	cfhsi->ops->cb_ops =3D &cfhsi->cb_ops;
 	if (register_netdevice(dev)) {
-		pr_warn("%s: device rtml registration failed\n", __func__);
+		pr_warn("%s: caif_hsi device registration failed\n", __func__);
 		goto err;
-
 	}
 	/* Add CAIF HSI device to list. */
 	list_add_tail(&cfhsi->list, &cfhsi_list);
=20
 	return 0;
 err:
-	symbol_put(cfhsi_get_device);
+	symbol_put(cfhsi_get_ops);
 	return -ENODEV;
 }
=20
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index a77b2bd..6dc7dc2 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -93,25 +93,25 @@ struct cfhsi_desc {
 #endif
=20
 /* Structure implemented by the CAIF HSI driver. */
-struct cfhsi_drv {
-	void (*tx_done_cb) (struct cfhsi_drv *drv);
-	void (*rx_done_cb) (struct cfhsi_drv *drv);
-	void (*wake_up_cb) (struct cfhsi_drv *drv);
-	void (*wake_down_cb) (struct cfhsi_drv *drv);
+struct cfhsi_cb_ops {
+	void (*tx_done_cb) (struct cfhsi_cb_ops *drv);
+	void (*rx_done_cb) (struct cfhsi_cb_ops *drv);
+	void (*wake_up_cb) (struct cfhsi_cb_ops *drv);
+	void (*wake_down_cb) (struct cfhsi_cb_ops *drv);
 };
=20
 /* Structure implemented by HSI device. */
-struct cfhsi_dev {
-	int (*cfhsi_up) (struct cfhsi_dev *dev);
-	int (*cfhsi_down) (struct cfhsi_dev *dev);
-	int (*cfhsi_tx) (u8 *ptr, int len, struct cfhsi_dev *dev);
-	int (*cfhsi_rx) (u8 *ptr, int len, struct cfhsi_dev *dev);
-	int (*cfhsi_wake_up) (struct cfhsi_dev *dev);
-	int (*cfhsi_wake_down) (struct cfhsi_dev *dev);
-	int (*cfhsi_get_peer_wake) (struct cfhsi_dev *dev, bool *status);
-	int (*cfhsi_fifo_occupancy)(struct cfhsi_dev *dev, size_t *occupancy)=
;
-	int (*cfhsi_rx_cancel)(struct cfhsi_dev *dev);
-	struct cfhsi_drv *drv;
+struct cfhsi_ops {
+	int (*cfhsi_up) (struct cfhsi_ops *dev);
+	int (*cfhsi_down) (struct cfhsi_ops *dev);
+	int (*cfhsi_tx) (u8 *ptr, int len, struct cfhsi_ops *dev);
+	int (*cfhsi_rx) (u8 *ptr, int len, struct cfhsi_ops *dev);
+	int (*cfhsi_wake_up) (struct cfhsi_ops *dev);
+	int (*cfhsi_wake_down) (struct cfhsi_ops *dev);
+	int (*cfhsi_get_peer_wake) (struct cfhsi_ops *dev, bool *status);
+	int (*cfhsi_fifo_occupancy) (struct cfhsi_ops *dev, size_t *occupancy=
);
+	int (*cfhsi_rx_cancel)(struct cfhsi_ops *dev);
+	struct cfhsi_cb_ops *cb_ops;
 };
=20
 /* Structure holds status of received CAIF frames processing */
@@ -138,8 +138,8 @@ struct cfhsi {
 	struct net_device *ndev;
 	struct platform_device *pdev;
 	struct sk_buff_head qhead[CFHSI_PRIO_LAST];
-	struct cfhsi_drv drv;
-	struct cfhsi_dev *dev;
+	struct cfhsi_cb_ops cb_ops;
+	struct cfhsi_ops *ops;
 	int tx_state;
 	struct cfhsi_rx_state rx_state;
 	unsigned long inactivity_timeout;
@@ -190,6 +190,6 @@ enum ifla_caif_hsi {
 	__IFLA_CAIF_HSI_MAX
 };
=20
-extern struct platform_device *cfhsi_get_device(void);
+extern struct cfhsi_ops *cfhsi_get_ops(void);
=20
 #endif		/* CAIF_HSI_H_ */
--=20
1.7.5.4
