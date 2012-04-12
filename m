From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 4/4] caif-hsi: Postpone init of HSI until open()
Date: Thu, 12 Apr 2012 20:27:27 +0200
Message-ID: <1334255247-3372-5-git-send-email-sjur.brandeland@stericsson.com>
References: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:59270 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932281Ab2DLS1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:27:43 -0400
Received: by lahj13 with SMTP id j13so1796059lah.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:27:41 -0700 (PDT)
In-Reply-To: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do the initialization of the HSI interface when the
interface is opened, instead of upon registration.
When the interface is closed the HSI interface is
de-initialized, allowing other modules to use the
HSI interface.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---

Hi Dave,=20

This patch does not apply cleanly on net-next,
but depends on the bug-fix patch intended for 3.4:
  caif-hsi: Free flip_buffer at shutdown

I hope this don't cause trouble for you.

Thanks,
Sjur

 drivers/net/caif/caif_hsi.c |   97 ++++++++++++++++++++---------------=
--------
 1 files changed, 45 insertions(+), 52 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 4253991..1520814 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -6,6 +6,8 @@
  * License terms: GNU General Public License (GPL) version 2.
  */
=20
+#define pr_fmt(fmt) KBUILD_MODNAME fmt
+
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/device.h>
@@ -1127,21 +1129,7 @@ static int cfhsi_xmit(struct sk_buff *skb, struc=
t net_device *dev)
 	return 0;
 }
=20
-static int cfhsi_open(struct net_device *dev)
-{
-	return 0;
-}
-
-static int cfhsi_close(struct net_device *dev)
-{
-	return 0;
-}
-
-static const struct net_device_ops cfhsi_ops =3D {
-	.ndo_open =3D cfhsi_open,
-	.ndo_stop =3D cfhsi_close,
-	.ndo_start_xmit =3D cfhsi_xmit
-};
+static const struct net_device_ops cfhsi_ops;
=20
 static void cfhsi_setup(struct net_device *dev)
 {
@@ -1167,7 +1155,7 @@ int cfhsi_probe(struct platform_device *pdev)
 {
 	struct cfhsi *cfhsi =3D NULL;
 	struct net_device *ndev;
-	struct cfhsi_dev *dev;
+
 	int res;
=20
 	ndev =3D alloc_netdev(sizeof(struct cfhsi), "cfhsi%d", cfhsi_setup);
@@ -1178,6 +1166,34 @@ int cfhsi_probe(struct platform_device *pdev)
 	cfhsi->ndev =3D ndev;
 	cfhsi->pdev =3D pdev;
=20
+	/* Assign the HSI device. */
+	cfhsi->dev =3D pdev->dev.platform_data;
+
+	/* Assign the driver to this HSI device. */
+	cfhsi->dev->drv =3D &cfhsi->drv;
+
+	/* Register network device. */
+	res =3D register_netdev(ndev);
+	if (res) {
+		dev_err(&ndev->dev, "%s: Registration error: %d.\n",
+			__func__, res);
+		free_netdev(ndev);
+	}
+	/* Add CAIF HSI device to list. */
+	spin_lock(&cfhsi_list_lock);
+	list_add_tail(&cfhsi->list, &cfhsi_list);
+	spin_unlock(&cfhsi_list_lock);
+
+	return res;
+}
+
+static int cfhsi_open(struct net_device *ndev)
+{
+	struct cfhsi *cfhsi =3D netdev_priv(ndev);
+	int res;
+
+	clear_bit(CFHSI_SHUTDOWN, &cfhsi->bits);
+
 	/* Initialize state vaiables. */
 	cfhsi->tx_state =3D CFHSI_TX_STATE_IDLE;
 	cfhsi->rx_state.state =3D CFHSI_RX_STATE_DESC;
@@ -1187,12 +1203,6 @@ int cfhsi_probe(struct platform_device *pdev)
 	cfhsi->q_low_mark =3D LOW_WATER_MARK;
 	cfhsi->q_high_mark =3D HIGH_WATER_MARK;
=20
-	/* Assign the HSI device. */
-	dev =3D (struct cfhsi_dev *)pdev->dev.platform_data;
-	cfhsi->dev =3D dev;
-
-	/* Assign the driver to this HSI device. */
-	dev->drv =3D &cfhsi->drv;
=20
 	/*
 	 * Allocate a TX buffer with the size of a HSI packet descriptors
@@ -1260,9 +1270,9 @@ int cfhsi_probe(struct platform_device *pdev)
 	clear_bit(CFHSI_AWAKE, &cfhsi->bits);
=20
 	/* Create work thread. */
-	cfhsi->wq =3D create_singlethread_workqueue(pdev->name);
+	cfhsi->wq =3D create_singlethread_workqueue(cfhsi->pdev->name);
 	if (!cfhsi->wq) {
-		dev_err(&ndev->dev, "%s: Failed to create work queue.\n",
+		dev_err(&cfhsi->ndev->dev, "%s: Failed to create work queue.\n",
 			__func__);
 		res =3D -ENODEV;
 		goto err_create_wq;
@@ -1286,11 +1296,6 @@ int cfhsi_probe(struct platform_device *pdev)
 	cfhsi->aggregation_timer.data =3D (unsigned long)cfhsi;
 	cfhsi->aggregation_timer.function =3D cfhsi_aggregation_tout;
=20
-	/* Add CAIF HSI device to list. */
-	spin_lock(&cfhsi_list_lock);
-	list_add_tail(&cfhsi->list, &cfhsi_list);
-	spin_unlock(&cfhsi_list_lock);
-
 	/* Activate HSI interface. */
 	res =3D cfhsi->dev->cfhsi_up(cfhsi->dev);
 	if (res) {
@@ -1303,15 +1308,7 @@ int cfhsi_probe(struct platform_device *pdev)
 	/* Flush FIFO */
 	res =3D cfhsi_flush_fifo(cfhsi);
 	if (res) {
-		dev_err(&ndev->dev, "%s: Can't flush FIFO: %d.\n",
-			__func__, res);
-		goto err_net_reg;
-	}
-
-	/* Register network device. */
-	res =3D register_netdev(ndev);
-	if (res) {
-		dev_err(&ndev->dev, "%s: Registration error: %d.\n",
+		dev_err(&cfhsi->ndev->dev, "%s: Can't flush FIFO: %d.\n",
 			__func__, res);
 		goto err_net_reg;
 	}
@@ -1328,13 +1325,12 @@ int cfhsi_probe(struct platform_device *pdev)
  err_alloc_rx:
 	kfree(cfhsi->tx_buf);
  err_alloc_tx:
-	free_netdev(ndev);
-
 	return res;
 }
=20
-static void cfhsi_shutdown(struct cfhsi *cfhsi)
+static int cfhsi_close(struct net_device *ndev)
 {
+	struct cfhsi *cfhsi =3D netdev_priv(ndev);
 	u8 *tx_buf, *rx_buf, *flip_buf;
=20
 	/* going to shutdown driver */
@@ -1364,15 +1360,19 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi)
 	/* Deactivate interface */
 	cfhsi->dev->cfhsi_down(cfhsi->dev);
=20
-	/* Finally unregister the network device. */
-	unregister_netdev(cfhsi->ndev);
-
 	/* Free buffers. */
 	kfree(tx_buf);
 	kfree(rx_buf);
 	kfree(flip_buf);
+	return 0;
 }
=20
+static const struct net_device_ops cfhsi_ops =3D {
+	.ndo_open =3D cfhsi_open,
+	.ndo_stop =3D cfhsi_close,
+	.ndo_start_xmit =3D cfhsi_xmit
+};
+
 int cfhsi_remove(struct platform_device *pdev)
 {
 	struct list_head *list_node;
@@ -1389,10 +1389,6 @@ int cfhsi_remove(struct platform_device *pdev)
 			/* Remove from list. */
 			list_del(list_node);
 			spin_unlock(&cfhsi_list_lock);
-
-			/* Shutdown driver. */
-			cfhsi_shutdown(cfhsi);
-
 			return 0;
 		}
 	}
@@ -1423,8 +1419,7 @@ static void __exit cfhsi_exit_module(void)
 		list_del(list_node);
 		spin_unlock(&cfhsi_list_lock);
=20
-		/* Shutdown driver. */
-		cfhsi_shutdown(cfhsi);
+		unregister_netdevice(cfhsi->ndev);
=20
 		spin_lock(&cfhsi_list_lock);
 	}
@@ -1449,8 +1444,6 @@ static int __init cfhsi_init_module(void)
 		goto err_dev_register;
 	}
=20
-	return result;
-
  err_dev_register:
 	return result;
 }
--=20
1.7.5.4
