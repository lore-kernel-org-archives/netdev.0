From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 04/10] qede: Don't use an internal MAC field
Date: Sun, 21 May 2017 12:10:55 +0300
Message-ID: <1495357860-28280-5-git-send-email-Yuval.Mintz@cavium.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0089.outbound.protection.outlook.com ([104.47.32.89]:35040
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752637AbdEUJLi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:11:38 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver maintains its primary MAC in a private field which
gets updated when ndo_dev_set_mac() gets called.

However, there are flows where the primary MAC of the device can change
without said NDO being called [bond device in TLB mode configuring
slaves' addresses], resulting in a configuration where there's a mismatch
between what's apparent to user [the netdevice's value] and what's
configured in the HW [the private value].

As we don't have any real motivation of maintaining this
private field, simply remove it and start using the netdevice's
field instead.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h        |  1 -
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 62 ++++++++++++++++----------
 drivers/net/ethernet/qlogic/qede/qede_main.c   |  3 --
 3 files changed, 38 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index 9b4f08b..694c09b 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -197,7 +197,6 @@ struct qede_dev {
 #define QEDE_TSS_COUNT(edev)	((edev)->num_queues - (edev)->fp_num_rx)
 
 	struct qed_int_info		int_info;
-	unsigned char			primary_mac[ETH_ALEN];
 
 	/* Smaller private varaiant of the RTNL lock */
 	struct mutex			qede_lock;
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 333876c..13955a3 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -495,12 +495,16 @@ void qede_force_mac(void *dev, u8 *mac, bool forced)
 {
 	struct qede_dev *edev = dev;
 
+	__qede_lock(edev);
+
 	/* MAC hints take effect only if we haven't set one already */
-	if (is_valid_ether_addr(edev->ndev->dev_addr) && !forced)
+	if (is_valid_ether_addr(edev->ndev->dev_addr) && !forced) {
+		__qede_unlock(edev);
 		return;
+	}
 
 	ether_addr_copy(edev->ndev->dev_addr, mac);
-	ether_addr_copy(edev->primary_mac, mac);
+	__qede_unlock(edev);
 }
 
 void qede_fill_rss_params(struct qede_dev *edev,
@@ -1061,41 +1065,51 @@ int qede_set_mac_addr(struct net_device *ndev, void *p)
 {
 	struct qede_dev *edev = netdev_priv(ndev);
 	struct sockaddr *addr = p;
-	int rc;
-
-	ASSERT_RTNL(); /* @@@TBD To be removed */
+	int rc = 0;
 
-	DP_INFO(edev, "Set_mac_addr called\n");
+	/* Make sure the state doesn't transition while changing the MAC.
+	 * Also, all flows accessing the dev_addr field are doing that under
+	 * this lock.
+	 */
+	__qede_lock(edev);
 
 	if (!is_valid_ether_addr(addr->sa_data)) {
 		DP_NOTICE(edev, "The MAC address is not valid\n");
-		return -EFAULT;
+		rc = -EFAULT;
+		goto out;
 	}
 
 	if (!edev->ops->check_mac(edev->cdev, addr->sa_data)) {
-		DP_NOTICE(edev, "qed prevents setting MAC\n");
-		return -EINVAL;
+		DP_NOTICE(edev, "qed prevents setting MAC %pM\n",
+			  addr->sa_data);
+		rc = -EINVAL;
+		goto out;
+	}
+
+	if (edev->state == QEDE_STATE_OPEN) {
+		/* Remove the previous primary mac */
+		rc = qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_DEL,
+					   ndev->dev_addr);
+		if (rc)
+			goto out;
 	}
 
 	ether_addr_copy(ndev->dev_addr, addr->sa_data);
+	DP_INFO(edev, "Setting device MAC to %pM\n", addr->sa_data);
 
-	if (!netif_running(ndev))  {
-		DP_NOTICE(edev, "The device is currently down\n");
-		return 0;
+	if (edev->state != QEDE_STATE_OPEN) {
+		DP_VERBOSE(edev, NETIF_MSG_IFDOWN,
+			   "The device is currently down\n");
+		goto out;
 	}
 
-	/* Remove the previous primary mac */
-	rc = qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_DEL,
-				   edev->primary_mac);
-	if (rc)
-		return rc;
-
-	edev->ops->common->update_mac(edev->cdev, addr->sa_data);
+	edev->ops->common->update_mac(edev->cdev, ndev->dev_addr);
 
-	/* Add MAC filter according to the new unicast HW MAC address */
-	ether_addr_copy(edev->primary_mac, ndev->dev_addr);
-	return qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_ADD,
-				      edev->primary_mac);
+	rc = qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_ADD,
+				   ndev->dev_addr);
+out:
+	__qede_unlock(edev);
+	return rc;
 }
 
 static int
@@ -1200,7 +1214,7 @@ void qede_config_rx_mode(struct net_device *ndev)
 	 * (configrue / leave the primary mac)
 	 */
 	rc = qede_set_ucast_rx_mac(edev, QED_FILTER_XCAST_TYPE_REPLACE,
-				   edev->primary_mac);
+				   edev->ndev->dev_addr);
 	if (rc)
 		goto out;
 
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index aea9dcf..a66bdfe 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1997,9 +1997,6 @@ static int qede_load(struct qede_dev *edev, enum qede_load_mode mode,
 		goto err4;
 	DP_INFO(edev, "Start VPORT, RXQ and TXQ succeeded\n");
 
-	/* Add primary mac and set Rx filters */
-	ether_addr_copy(edev->primary_mac, edev->ndev->dev_addr);
-
 	/* Program un-configured VLANs */
 	qede_configure_vlan_filters(edev);
 
-- 
1.9.3
