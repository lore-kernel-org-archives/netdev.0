From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix wrong information about channels
 reported to ethtool
Date: Wed, 4 Jan 2017 16:18:50 -0800
Message-ID: <20170105001850.GA20747@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0060.outbound.protection.outlook.com ([104.47.34.60]:63586
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754521AbdAEAVF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 19:21:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilin Chang <weilin.chang@cavium.com>

Information reported to ethtool about channels is sometimes wrong for PF,
and always wrong for VF.  Fix them by getting the information from the
right fields from the right structs.

Signed-off-by: Weilin Chang <weilin.chang@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index b00c300..50384ce 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -296,12 +296,16 @@ lio_ethtool_get_channels(struct net_device *dev,
 		rx_count = CFG_GET_NUM_RXQS_NIC_IF(conf6x, lio->ifidx);
 		tx_count = CFG_GET_NUM_TXQS_NIC_IF(conf6x, lio->ifidx);
 	} else if (OCTEON_CN23XX_PF(oct)) {
-		struct octeon_config *conf23 = CHIP_CONF(oct, cn23xx_pf);
 
-		max_rx = CFG_GET_OQ_MAX_Q(conf23);
-		max_tx = CFG_GET_IQ_MAX_Q(conf23);
-		rx_count = CFG_GET_NUM_RXQS_NIC_IF(conf23, lio->ifidx);
-		tx_count = CFG_GET_NUM_TXQS_NIC_IF(conf23, lio->ifidx);
+		max_rx = oct->sriov_info.num_pf_rings;
+		max_tx = oct->sriov_info.num_pf_rings;
+		rx_count = lio->linfo.num_rxpciq;
+		tx_count = lio->linfo.num_txpciq;
+	} else if (OCTEON_CN23XX_VF(oct)) {
+		max_tx = oct->sriov_info.rings_per_vf;
+		max_rx = oct->sriov_info.rings_per_vf;
+		rx_count = lio->linfo.num_rxpciq;
+		tx_count = lio->linfo.num_txpciq;
 	}
 
 	channel->max_rx = max_rx;
