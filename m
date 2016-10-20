From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next v2 8/9] s390/net: use net core MTU range checking
Date: Thu, 20 Oct 2016 13:55:23 -0400
Message-ID: <20161020175524.6184-9-jarod@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161020175524.6184-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        linux-s390@vger.kernel.org,
        Ursula Braun <ubraun@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161020175524.6184-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ctcm:
- min_mtu = 576, max_mtu = 65527

netiucv:
- min_mtu = 576, max_mtu = 65535

qeth:
- min_mtu = 64, max_mtu = 65535

CC: netdev@vger.kernel.org
CC: linux-s390@vger.kernel.org
CC: Ursula Braun <ubraun@linux.vnet.ibm.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/s390/net/ctcm_main.c      |  5 ++---
 drivers/s390/net/netiucv.c        | 24 ++----------------------
 drivers/s390/net/qeth_core_main.c |  4 ----
 drivers/s390/net/qeth_l2_main.c   |  2 ++
 drivers/s390/net/qeth_l3_main.c   |  2 ++
 5 files changed, 8 insertions(+), 29 deletions(-)

diff --git a/drivers/s390/net/ctcm_main.c b/drivers/s390/net/ctcm_main.c
index ad17fc5..ac65f12 100644
--- a/drivers/s390/net/ctcm_main.c
+++ b/drivers/s390/net/ctcm_main.c
@@ -1032,9 +1032,6 @@ static int ctcm_change_mtu(struct net_device *dev, int new_mtu)
 	struct ctcm_priv *priv;
 	int max_bufsize;
 
-	if (new_mtu < 576 || new_mtu > 65527)
-		return -EINVAL;
-
 	priv = dev->ml_priv;
 	max_bufsize = priv->channel[CTCM_READ]->max_bufsize;
 
@@ -1123,6 +1120,8 @@ void static ctcm_dev_setup(struct net_device *dev)
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 100;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
+	dev->min_mtu = 576;
+	dev->max_mtu = 65527;
 }
 
 /*
diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index 2f0f391..2981024 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1428,27 +1428,6 @@ static struct net_device_stats *netiucv_stats (struct net_device * dev)
 	return &priv->stats;
 }
 
-/**
- * netiucv_change_mtu
- * @dev: Pointer to interface struct.
- * @new_mtu: The new MTU to use for this interface.
- *
- * Sets MTU of an interface.
- *
- * Returns 0 on success, -EINVAL if MTU is out of valid range.
- *         (valid range is 576 .. NETIUCV_MTU_MAX).
- */
-static int netiucv_change_mtu(struct net_device * dev, int new_mtu)
-{
-	IUCV_DBF_TEXT(trace, 3, __func__);
-	if (new_mtu < 576 || new_mtu > NETIUCV_MTU_MAX) {
-		IUCV_DBF_TEXT(setup, 2, "given MTU out of valid range\n");
-		return -EINVAL;
-	}
-	dev->mtu = new_mtu;
-	return 0;
-}
-
 /*
  * attributes in sysfs
  */
@@ -1986,12 +1965,13 @@ static const struct net_device_ops netiucv_netdev_ops = {
 	.ndo_stop		= netiucv_close,
 	.ndo_get_stats		= netiucv_stats,
 	.ndo_start_xmit		= netiucv_tx,
-	.ndo_change_mtu	   	= netiucv_change_mtu,
 };
 
 static void netiucv_setup_netdevice(struct net_device *dev)
 {
 	dev->mtu	         = NETIUCV_MTU_DEFAULT;
+	dev->min_mtu		 = 576;
+	dev->max_mtu		 = NETIUCV_MTU_MAX;
 	dev->destructor          = netiucv_free_netdevice;
 	dev->hard_header_len     = NETIUCV_HDRLEN;
 	dev->addr_len            = 0;
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 20cf296..e335583 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4202,10 +4202,6 @@ int qeth_change_mtu(struct net_device *dev, int new_mtu)
 	sprintf(dbf_text, "%8x", new_mtu);
 	QETH_CARD_TEXT(card, 4, dbf_text);
 
-	if (new_mtu < 64)
-		return -EINVAL;
-	if (new_mtu > 65535)
-		return -EINVAL;
 	if ((!qeth_is_supported(card, IPA_IP_FRAGMENTATION)) &&
 	    (!qeth_mtu_is_valid(card, new_mtu)))
 		return -EINVAL;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index bb27058..9c921c28 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1107,6 +1107,8 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	card->dev->ml_priv = card;
 	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
 	card->dev->mtu = card->info.initial_mtu;
+	card->dev->min_mtu = 64;
+	card->dev->max_mtu = ETH_MAX_MTU;
 	card->dev->netdev_ops = &qeth_l2_netdev_ops;
 	card->dev->ethtool_ops =
 		(card->info.type != QETH_CARD_TYPE_OSN) ?
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 272d9e7..ac37d05 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3140,6 +3140,8 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 	card->dev->ml_priv = card;
 	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
 	card->dev->mtu = card->info.initial_mtu;
+	card->dev->min_mtu = 64;
+	card->dev->max_mtu = ETH_MAX_MTU;
 	card->dev->ethtool_ops = &qeth_l3_ethtool_ops;
 	card->dev->features |=	NETIF_F_HW_VLAN_CTAG_TX |
 				NETIF_F_HW_VLAN_CTAG_RX |
-- 
2.10.0
