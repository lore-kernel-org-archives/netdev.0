From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 1/7] qlcnic: Enhance channel configuration logs
Date: Wed, 24 Apr 2013 18:42:39 -0400
Message-ID: <1366843365-2787-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<shahed.shaikh@qlogic.com>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:35711 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757971Ab3DXXG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 19:06:57 -0400
In-Reply-To: <1366843365-2787-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Add logs for various failure conditions during channel configuration.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |   32 ++++++++++++++++----
 3 files changed, 28 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 8d02dd7..f699cce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1474,7 +1474,7 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 int qlcnic_set_max_rss(struct qlcnic_adapter *, u8, size_t);
-int qlcnic_validate_max_rss(u8, u8);
+int qlcnic_validate_max_rss(struct qlcnic_adapter *, __u32);
 void qlcnic_alloc_lb_filters_mem(struct qlcnic_adapter *adapter);
 int qlcnic_enable_msix(struct qlcnic_adapter *, u32);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 9f7aade..59350c2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -635,7 +635,7 @@ static int qlcnic_set_channels(struct net_device *dev,
 	    channel->tx_count != channel->max_tx)
 		return -EINVAL;
 
-	err = qlcnic_validate_max_rss(channel->max_rx, channel->rx_count);
+	err = qlcnic_validate_max_rss(adapter, channel->rx_count);
 	if (err)
 		return err;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 247a9f9..0052953 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -3273,20 +3273,40 @@ qlcnicvf_start_firmware(struct qlcnic_adapter *adapter)
 	return err;
 }
 
-int qlcnic_validate_max_rss(u8 max_hw, u8 val)
+int qlcnic_validate_max_rss(struct qlcnic_adapter *adapter,
+			    __u32 val)
 {
+	struct net_device *netdev = adapter->netdev;
+	u8 max_hw = adapter->ahw->max_rx_ques;
 	u32 max_allowed;
 
-	if (max_hw > QLC_MAX_SDS_RINGS) {
-		max_hw = QLC_MAX_SDS_RINGS;
-		pr_info("max rss reset to %d\n", QLC_MAX_SDS_RINGS);
+	if (val > QLC_MAX_SDS_RINGS) {
+		netdev_err(netdev, "RSS value should not be higher than %u\n",
+			   QLC_MAX_SDS_RINGS);
+		return -EINVAL;
 	}
 
 	max_allowed = rounddown_pow_of_two(min_t(int, max_hw,
 						 num_online_cpus()));
 	if ((val > max_allowed) || (val < 2) || !is_power_of_2(val)) {
-		pr_info("rss_ring valid range [2 - %x] in powers of 2\n",
-			max_allowed);
+		if (!is_power_of_2(val))
+			netdev_err(netdev, "RSS value should be a power of 2\n");
+
+		if (val < 2)
+			netdev_err(netdev, "RSS value should not be lower than 2\n");
+
+		if (val > max_hw)
+			netdev_err(netdev,
+				   "RSS value should not be higher than[%u], the max RSS rings supported by the adapter\n",
+				   max_hw);
+
+		if (val > num_online_cpus())
+			netdev_err(netdev,
+				   "RSS value should not be higher than[%u], number of online CPUs in the system\n",
+				   num_online_cpus());
+
+		netdev_err(netdev, "Unable to configure %u RSS rings\n", val);
+
 		return -EINVAL;
 	}
 	return 0;
-- 
1.7.6.rc1.1.g2c162b
