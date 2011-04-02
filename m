From: anirban.chakraborty@qlogic.com
Subject: [PATCH 6/9 net-next-2.6] qlcnic: Remove unused code
Date: Fri,  1 Apr 2011 17:07:13 -0700
Message-ID: <1301702836-3265-6-git-send-email-anirban.chakraborty@qlogic.com>
References: <1301702836-3265-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: davem@davemloft.com, Dept_NX_Linux_NIC_driver@qlogic.com,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:34117 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1756021Ab1DBAZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Apr 2011 20:25:16 -0400
In-Reply-To: <1301702836-3265-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com> 

Cleaned up unused codes for interrupt coalescence settings

Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |   56 +++++++++++++----------------------
 drivers/net/qlcnic/qlcnic_ethtool.c |   30 +++++++------------
 drivers/net/qlcnic/qlcnic_hw.c      |   20 +++++-------
 drivers/net/qlcnic/qlcnic_main.c    |   21 +++----------
 4 files changed, 46 insertions(+), 81 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index be9c329..9d2e630 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -392,6 +392,25 @@ struct qlcnic_rx_buffer {
 #define	QLCNIC_XGBE	0x02
 
 /*
+ * Interrupt coalescing defaults. The defaults are for 1500 MTU. It is
+ * adjusted based on configured MTU.
+ */
+#define QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US	3
+#define QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS	256
+
+#define QLCNIC_INTR_DEFAULT			0x04
+#define QLCNIC_CONFIG_INTR_COALESCE		3
+
+struct qlcnic_nic_intr_coalesce {
+	u8	type;
+	u8	sts_ring_mask;
+	u16	rx_packets;
+	u16	rx_time_us;
+	u16	flag;
+	u32	timer_out;
+};
+
+/*
  * One hardware_context{} per adapter
  * contains interrupt info as well shared hardware info.
  */
@@ -409,6 +428,8 @@ struct qlcnic_hardware_context {
 	u8 linkup;
 	u16 port_type;
 	u16 board_type;
+
+	struct qlcnic_nic_intr_coalesce coal;
 };
 
 struct qlcnic_adapter_stats {
@@ -721,40 +742,6 @@ struct qlcnic_mac_list_s {
 	uint8_t mac_addr[ETH_ALEN+2];
 };
 
-/*
- * Interrupt coalescing defaults. The defaults are for 1500 MTU. It is
- * adjusted based on configured MTU.
- */
-#define QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US	3
-#define QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS	256
-#define QLCNIC_DEFAULT_INTR_COALESCE_TX_PACKETS	64
-#define QLCNIC_DEFAULT_INTR_COALESCE_TX_TIME_US	4
-
-#define QLCNIC_INTR_DEFAULT			0x04
-
-union qlcnic_nic_intr_coalesce_data {
-	struct {
-		u16	rx_packets;
-		u16	rx_time_us;
-		u16	tx_packets;
-		u16	tx_time_us;
-	} data;
-	u64		word;
-};
-
-struct qlcnic_nic_intr_coalesce {
-	u16		stats_time_us;
-	u16		rate_sample_time;
-	u16		flags;
-	u16		rsvd_1;
-	u32		low_threshold;
-	u32		high_threshold;
-	union qlcnic_nic_intr_coalesce_data	normal;
-	union qlcnic_nic_intr_coalesce_data	low;
-	union qlcnic_nic_intr_coalesce_data	high;
-	union qlcnic_nic_intr_coalesce_data	irq;
-};
-
 #define QLCNIC_HOST_REQUEST	0x13
 #define QLCNIC_REQUEST		0x14
 
@@ -1002,7 +989,6 @@ struct qlcnic_adapter {
 
 	struct delayed_work fw_work;
 
-	struct qlcnic_nic_intr_coalesce coal;
 
 	struct qlcnic_filter_hash fhash;
 
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index b446045..e03108a 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -936,8 +936,8 @@ static int qlcnic_set_intr_coalesce(struct net_device *netdev,
 	*/
 	if (ethcoal->rx_coalesce_usecs > 0xffff ||
 		ethcoal->rx_max_coalesced_frames > 0xffff ||
-		ethcoal->tx_coalesce_usecs > 0xffff ||
-		ethcoal->tx_max_coalesced_frames > 0xffff ||
+		ethcoal->tx_coalesce_usecs ||
+		ethcoal->tx_max_coalesced_frames ||
 		ethcoal->rx_coalesce_usecs_irq ||
 		ethcoal->rx_max_coalesced_frames_irq ||
 		ethcoal->tx_coalesce_usecs_irq ||
@@ -959,21 +959,17 @@ static int qlcnic_set_intr_coalesce(struct net_device *netdev,
 
 	if (!ethcoal->rx_coalesce_usecs ||
 		!ethcoal->rx_max_coalesced_frames) {
-		adapter->coal.flags = QLCNIC_INTR_DEFAULT;
-		adapter->coal.normal.data.rx_time_us =
+		adapter->ahw->coal.flag = QLCNIC_INTR_DEFAULT;
+		adapter->ahw->coal.rx_time_us =
 			QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US;
-		adapter->coal.normal.data.rx_packets =
+		adapter->ahw->coal.rx_packets =
 			QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS;
 	} else {
-		adapter->coal.flags = 0;
-		adapter->coal.normal.data.rx_time_us =
-		ethcoal->rx_coalesce_usecs;
-		adapter->coal.normal.data.rx_packets =
-		ethcoal->rx_max_coalesced_frames;
+		adapter->ahw->coal.flag = 0;
+		adapter->ahw->coal.rx_time_us = ethcoal->rx_coalesce_usecs;
+		adapter->ahw->coal.rx_packets =
+			ethcoal->rx_max_coalesced_frames;
 	}
-	adapter->coal.normal.data.tx_time_us = ethcoal->tx_coalesce_usecs;
-	adapter->coal.normal.data.tx_packets =
-	ethcoal->tx_max_coalesced_frames;
 
 	qlcnic_config_intr_coalesce(adapter);
 
@@ -988,12 +984,8 @@ static int qlcnic_get_intr_coalesce(struct net_device *netdev,
 	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
 		return -EINVAL;
 
-	ethcoal->rx_coalesce_usecs = adapter->coal.normal.data.rx_time_us;
-	ethcoal->tx_coalesce_usecs = adapter->coal.normal.data.tx_time_us;
-	ethcoal->rx_max_coalesced_frames =
-		adapter->coal.normal.data.rx_packets;
-	ethcoal->tx_max_coalesced_frames =
-		adapter->coal.normal.data.tx_packets;
+	ethcoal->rx_coalesce_usecs = adapter->ahw->coal.rx_time_us;
+	ethcoal->rx_max_coalesced_frames = adapter->ahw->coal.rx_packets;
 
 	return 0;
 }
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 7e3f526..3901be8 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -532,33 +532,31 @@ void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter)
 	}
 }
 
-#define	QLCNIC_CONFIG_INTR_COALESCE	3
-
 /*
  * Send the interrupt coalescing parameter set by ethtool to the card.
  */
 int qlcnic_config_intr_coalesce(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_nic_req req;
-	u64 word[6];
-	int rv, i;
+	int rv;
 
 	memset(&req, 0, sizeof(struct qlcnic_nic_req));
 
 	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
 
-	word[0] = QLCNIC_CONFIG_INTR_COALESCE | ((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word[0]);
-
-	memcpy(&word[0], &adapter->coal, sizeof(adapter->coal));
-	for (i = 0; i < 6; i++)
-		req.words[i] = cpu_to_le64(word[i]);
+	req.req_hdr = cpu_to_le64(QLCNIC_CONFIG_INTR_COALESCE |
+		((u64) adapter->portnum << 16));
 
+	req.words[0] = cpu_to_le64(((u64) adapter->ahw->coal.flag) << 32);
+	req.words[2] = cpu_to_le64(adapter->ahw->coal.rx_packets |
+			((u64) adapter->ahw->coal.rx_time_us) << 16);
+	req.words[5] = cpu_to_le64(adapter->ahw->coal.timer_out |
+			((u64) adapter->ahw->coal.type) << 32 |
+			((u64) adapter->ahw->coal.sts_ring_mask) << 40);
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0)
 		dev_err(&adapter->netdev->dev,
 			"Could not send interrupt coalescing parameters\n");
-
 	return rv;
 }
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index b75aef0..8bf9a96 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1097,20 +1097,6 @@ qlcnic_free_irq(struct qlcnic_adapter *adapter)
 	}
 }
 
-static void
-qlcnic_init_coalesce_defaults(struct qlcnic_adapter *adapter)
-{
-	adapter->coal.flags = QLCNIC_INTR_DEFAULT;
-	adapter->coal.normal.data.rx_time_us =
-		QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US;
-	adapter->coal.normal.data.rx_packets =
-		QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS;
-	adapter->coal.normal.data.tx_time_us =
-		QLCNIC_DEFAULT_INTR_COALESCE_TX_TIME_US;
-	adapter->coal.normal.data.tx_packets =
-		QLCNIC_DEFAULT_INTR_COALESCE_TX_PACKETS;
-}
-
 static int
 __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 {
@@ -1244,8 +1230,6 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 		goto err_out_free_hw;
 	}
 
-	qlcnic_init_coalesce_defaults(adapter);
-
 	qlcnic_create_sysfs_entries(adapter);
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
@@ -1326,7 +1310,12 @@ static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 		kfree(adapter->ahw);
 		adapter->ahw = NULL;
 		err = -ENOMEM;
+		goto err_out;
 	}
+	/* Initialize interrupt coalesce parameters */
+	adapter->ahw->coal.flag = QLCNIC_INTR_DEFAULT;
+	adapter->ahw->coal.rx_time_us = QLCNIC_DEFAULT_INTR_COALESCE_RX_TIME_US;
+	adapter->ahw->coal.rx_packets = QLCNIC_DEFAULT_INTR_COALESCE_RX_PACKETS;
 err_out:
 	return err;
 }
-- 
1.7.1

