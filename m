From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 2/4] qlcnic: Fix memory corruption while reading stats using ethtool.
Date: Mon, 22 Sep 2014 05:51:51 -0400
Message-ID: <1411379513-26902-3-git-send-email-manish.chopra@qlogic.com>
References: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43056 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753229AbaIVKZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 06:25:47 -0400
In-Reply-To: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o  Driver is doing memset with zero for total number of stats bytes when
   it has already filled some data in the stats buffer, which can overwrite
   memory area beyond the length of stats buffer.

o  Fix this by initializing stats buffer with zero before filling any data in it.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 141f116..2d77b76 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1333,12 +1333,11 @@ static void qlcnic_get_ethtool_stats(struct net_device *dev,
 	struct qlcnic_host_tx_ring *tx_ring;
 	struct qlcnic_esw_statistics port_stats;
 	struct qlcnic_mac_statistics mac_stats;
-	int index, ret, length, size, tx_size, ring;
+	int index, ret, length, size, ring;
 	char *p;
 
-	tx_size = adapter->drv_tx_rings * QLCNIC_TX_STATS_LEN;
+	memset(data, 0, stats->n_stats * sizeof(u64));
 
-	memset(data, 0, tx_size * sizeof(u64));
 	for (ring = 0, index = 0; ring < adapter->drv_tx_rings; ring++) {
 		if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
 			tx_ring = &adapter->tx_ring[ring];
@@ -1347,7 +1346,6 @@ static void qlcnic_get_ethtool_stats(struct net_device *dev,
 		}
 	}
 
-	memset(data, 0, stats->n_stats * sizeof(u64));
 	length = QLCNIC_STATS_LEN;
 	for (index = 0; index < length; index++) {
 		p = (char *)adapter + qlcnic_gstrings_stats[index].stat_offset;
-- 
1.7.1
