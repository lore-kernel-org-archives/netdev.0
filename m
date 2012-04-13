From: xiong <xiong@qca.qualcomm.com>
Subject: [PATCH 15/37] atl1c: update right threshold for TSO
Date: Fri, 13 Apr 2012 08:14:40 +0800
Message-ID: <1334276102-15866-16-git-send-email-xiong@qca.qualcomm.com>
References: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <qca-linux-team@qualcomm.com>, <nic-devel@qualcomm.com>,
	xiong <xiong@qca.qualcomm.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1334276102-15866-1-git-send-email-xiong@qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atl1c_configure_tx used a wrong value of MAX_TX_OFFLOAD_THRESH(9KB)
for TSO threshold.
the right value should be 7KB
Fast Ethernet controller doesn't support Jumbo frame.

Signed-off-by: xiong <xiong@qca.qualcomm.com>
Tested-by: Liu David <dwliu@qca.qualcomm.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c.h      |    2 --
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.h   |    1 +
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c |   11 ++++++++---
 3 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c.h b/drivers/net/ethernet/atheros/atl1c/atl1c.h
index 6e5ae89..9f4fc41 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c.h
@@ -74,8 +74,6 @@
 
 #define AT_RX_BUF_SIZE		(ETH_FRAME_LEN + VLAN_HLEN + ETH_FCS_LEN)
 #define MAX_JUMBO_FRAME_SIZE	(6*1024)
-#define MAX_TSO_FRAME_SIZE      (7*1024)
-#define MAX_TX_OFFLOAD_THRESH	(9*1024)
 
 #define AT_MAX_RECEIVE_QUEUE    4
 #define AT_DEF_RECEIVE_QUEUE	1
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
index ec68611..b9fa854 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_hw.h
@@ -515,6 +515,7 @@ int atl1c_phy_power_saving(struct atl1c_hw *hw);
 /* Jumbo packet Threshold for task offload */
 #define REG_TX_TSO_OFFLOAD_THRESH	0x1594 /* In 8-bytes */
 #define TX_TSO_OFFLOAD_THRESH_MASK	0x07FF
+#define MAX_TSO_FRAME_SIZE		(7*1024)
 
 #define	REG_TXF_WATER_MARK		0x1598 /* In 8-bytes */
 #define TXF_WATER_MARK_MASK		0x0FFF
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 141fe67..0b15e1f 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -501,11 +501,16 @@ static int atl1c_set_features(struct net_device *netdev,
 static int atl1c_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
+	struct atl1c_hw *hw = &adapter->hw;
 	int old_mtu   = netdev->mtu;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
-			(max_frame > MAX_JUMBO_FRAME_SIZE)) {
+	/* Fast Etherent controller doesn't support Jumbo packet */
+	if (((hw->nic_type == athr_l2c ||
+	      hw->nic_type == athr_l2c_b ||
+	      hw->nic_type == athr_l2c_b2) && new_mtu > ETH_DATA_LEN) ||
+	      max_frame < ETH_ZLEN + ETH_FCS_LEN ||
+	      max_frame > MAX_JUMBO_FRAME_SIZE) {
 		if (netif_msg_link(adapter))
 			dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
 		return -EINVAL;
@@ -1050,7 +1055,7 @@ static void atl1c_configure_tx(struct atl1c_adapter *adapter)
 	u16 tx_offload_thresh;
 	u32 txq_ctrl_data;
 
-	tx_offload_thresh = MAX_TX_OFFLOAD_THRESH;
+	tx_offload_thresh = MAX_TSO_FRAME_SIZE;
 	AT_WRITE_REG(hw, REG_TX_TSO_OFFLOAD_THRESH,
 		(tx_offload_thresh >> 3) & TX_TSO_OFFLOAD_THRESH_MASK);
 	AT_READ_REGW(hw, REG_DEVICE_CTRL, &dev_ctrl_data);
-- 
1.7.7
