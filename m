From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/2] qlcnic: Fix bug in TX statistics
Date: Thu, 9 Jan 2014 12:41:04 -0500
Message-ID: <1389289265-9586-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1389289265-9586-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:34192 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756417AbaAISOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 13:14:55 -0500
In-Reply-To: <1389289265-9586-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o Driver was not updating TX stats so it was not populating
  statistics in `ifconfig` command output.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h         | 1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c    | 3 +++
 3 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index ff80cd8..f2a7c71 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1711,6 +1711,7 @@ int qlcnic_83xx_init_mailbox_work(struct qlcnic_adapter *);
 void qlcnic_83xx_detach_mailbox_work(struct qlcnic_adapter *);
 void qlcnic_83xx_reinit_mbx_work(struct qlcnic_mailbox *mbx);
 void qlcnic_83xx_free_mailbox(struct qlcnic_mailbox *mbx);
+void qlcnic_update_stats(struct qlcnic_adapter *);
 
 /* Adapter hardware abstraction */
 struct qlcnic_hardware_ops {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index e3be276..7b36340 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1267,7 +1267,7 @@ static u64 *qlcnic_fill_stats(u64 *data, void *stats, int type)
 	return data;
 }
 
-static void qlcnic_update_stats(struct qlcnic_adapter *adapter)
+void qlcnic_update_stats(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b8a245a..550791b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2780,6 +2780,9 @@ static struct net_device_stats *qlcnic_get_stats(struct net_device *netdev)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	struct net_device_stats *stats = &netdev->stats;
 
+	if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
+		qlcnic_update_stats(adapter);
+
 	stats->rx_packets = adapter->stats.rx_pkts + adapter->stats.lro_pkts;
 	stats->tx_packets = adapter->stats.xmitfinished;
 	stats->rx_bytes = adapter->stats.rxbytes + adapter->stats.lrobytes;
-- 
1.8.1.4
