From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 2/3] qlcnic: Optimize ring count validations
Date: Wed, 11 Jun 2014 14:09:12 -0400
Message-ID: <1402510153-9928-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1402510153-9928-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:20769 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754582AbaFKSjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 14:39:20 -0400
In-Reply-To: <1402510153-9928-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

- Check interrupt mode at the start of qlcnic_set_channels().
- Do not validate ring count if they are not going to change.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c |  9 +++++++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 10 ----------
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 5bacf52..1b7f3db 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -726,6 +726,11 @@ static int qlcnic_set_channels(struct net_device *dev,
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
 	int err;
 
+	if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
+		netdev_err(dev, "No RSS/TSS support in non MSI-X mode\n");
+		return -EINVAL;
+	}
+
 	if (channel->other_count || channel->combined_count)
 		return -EINVAL;
 
@@ -734,7 +739,7 @@ static int qlcnic_set_channels(struct net_device *dev,
 	if (err)
 		return err;
 
-	if (channel->rx_count) {
+	if (adapter->drv_sds_rings != channel->rx_count) {
 		err = qlcnic_validate_rings(adapter, channel->rx_count,
 					    QLCNIC_RX_QUEUE);
 		if (err) {
@@ -745,7 +750,7 @@ static int qlcnic_set_channels(struct net_device *dev,
 		adapter->drv_rss_rings = channel->rx_count;
 	}
 
-	if (channel->tx_count) {
+	if (adapter->drv_tx_rings != channel->tx_count) {
 		err = qlcnic_validate_rings(adapter, channel->tx_count,
 					    QLCNIC_TX_QUEUE);
 		if (err) {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 1c18891..4fc1867 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -4003,16 +4003,6 @@ int qlcnic_validate_rings(struct qlcnic_adapter *adapter, __u32 ring_cnt,
 		strcpy(buf, "Tx");
 	}
 
-	if (!QLCNIC_IS_MSI_FAMILY(adapter)) {
-		netdev_err(netdev, "No RSS/TSS support in INT-x mode\n");
-		return -EINVAL;
-	}
-
-	if (adapter->flags & QLCNIC_MSI_ENABLED) {
-		netdev_err(netdev, "No RSS/TSS support in MSI mode\n");
-		return -EINVAL;
-	}
-
 	if (!is_power_of_2(ring_cnt)) {
 		netdev_err(netdev, "%s rings value should be a power of 2\n",
 			   buf);
-- 
1.8.1.4
