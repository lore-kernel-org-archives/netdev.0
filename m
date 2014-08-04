From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net 1/3] qlcnic: Fix update of ethtool stats.
Date: Mon, 4 Aug 2014 11:51:16 -0400
Message-ID: <1407167478-22277-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:22375 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752110AbaHDQXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 12:23:23 -0400
In-Reply-To: <1407167478-22277-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Aggregating tx stats in adapter variable was resulting in
  an increase in stats even after no traffic was run and
  user runs ifconfig/ethtool command.
o qlcnic_update_stats used to accumulate stats in adapter
  struct at each function call, instead accumulate tx stats
  in local variable and then assign it to adapter structure.

Reported-by: Holger Kiehl <holger.kiehl@dwd.de>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 1b7f3db..141f116 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1290,17 +1290,25 @@ static u64 *qlcnic_fill_stats(u64 *data, void *stats, int type)
 
 void qlcnic_update_stats(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_tx_queue_stats tx_stats;
 	struct qlcnic_host_tx_ring *tx_ring;
 	int ring;
 
+	memset(&tx_stats, 0, sizeof(tx_stats));
 	for (ring = 0; ring < adapter->drv_tx_rings; ring++) {
 		tx_ring = &adapter->tx_ring[ring];
-		adapter->stats.xmit_on += tx_ring->tx_stats.xmit_on;
-		adapter->stats.xmit_off += tx_ring->tx_stats.xmit_off;
-		adapter->stats.xmitcalled += tx_ring->tx_stats.xmit_called;
-		adapter->stats.xmitfinished += tx_ring->tx_stats.xmit_finished;
-		adapter->stats.txbytes += tx_ring->tx_stats.tx_bytes;
+		tx_stats.xmit_on += tx_ring->tx_stats.xmit_on;
+		tx_stats.xmit_off += tx_ring->tx_stats.xmit_off;
+		tx_stats.xmit_called += tx_ring->tx_stats.xmit_called;
+		tx_stats.xmit_finished += tx_ring->tx_stats.xmit_finished;
+		tx_stats.tx_bytes += tx_ring->tx_stats.tx_bytes;
 	}
+
+	adapter->stats.xmit_on = tx_stats.xmit_on;
+	adapter->stats.xmit_off = tx_stats.xmit_off;
+	adapter->stats.xmitcalled = tx_stats.xmit_called;
+	adapter->stats.xmitfinished = tx_stats.xmit_finished;
+	adapter->stats.txbytes = tx_stats.tx_bytes;
 }
 
 static u64 *qlcnic_fill_tx_queue_stats(u64 *data, void *stats)
-- 
1.6.3.3
