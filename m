From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix wrong info about vf rx/tx ring
 parameters reported to ethtool
Date: Mon, 7 Aug 2017 10:39:00 -0700
Message-ID: <20170807173900.GA1078@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0050.outbound.protection.outlook.com ([104.47.38.50]:17920
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751505AbdHGRjN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 7 Aug 2017 13:39:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Information reported to ethtool about vf rx/tx ring parameters is wrong.
Fix it by adding the missing initializations.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 30 +++++++---------------
 1 file changed, 9 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 09e2875..b78e296 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -649,33 +649,21 @@ lio_ethtool_get_ringparam(struct net_device *netdev,
 		rx_max_pending = CN6XXX_MAX_OQ_DESCRIPTORS;
 		rx_pending = CFG_GET_NUM_RX_DESCS_NIC_IF(conf6x, lio->ifidx);
 		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf6x, lio->ifidx);
-	} else if (OCTEON_CN23XX_PF(oct)) {
-		struct octeon_config *conf23 = CHIP_CONF(oct, cn23xx_pf);
-
+	} else if (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct)) {
 		tx_max_pending = CN23XX_MAX_IQ_DESCRIPTORS;
 		rx_max_pending = CN23XX_MAX_OQ_DESCRIPTORS;
-		rx_pending = CFG_GET_NUM_RX_DESCS_NIC_IF(conf23, lio->ifidx);
-		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf23, lio->ifidx);
-	}
-
-	if (lio->mtu > OCTNET_DEFAULT_FRM_SIZE - OCTNET_FRM_HEADER_SIZE) {
-		ering->rx_pending = 0;
-		ering->rx_max_pending = 0;
-		ering->rx_mini_pending = 0;
-		ering->rx_jumbo_pending = rx_pending;
-		ering->rx_mini_max_pending = 0;
-		ering->rx_jumbo_max_pending = rx_max_pending;
-	} else {
-		ering->rx_pending = rx_pending;
-		ering->rx_max_pending = rx_max_pending;
-		ering->rx_mini_pending = 0;
-		ering->rx_jumbo_pending = 0;
-		ering->rx_mini_max_pending = 0;
-		ering->rx_jumbo_max_pending = 0;
+		rx_pending = oct->droq[0]->max_count;
+		tx_pending = oct->instr_queue[0]->max_count;
 	}
 
 	ering->tx_pending = tx_pending;
 	ering->tx_max_pending = tx_max_pending;
+	ering->rx_pending = rx_pending;
+	ering->rx_max_pending = rx_max_pending;
+	ering->rx_mini_pending = 0;
+	ering->rx_jumbo_pending = 0;
+	ering->rx_mini_max_pending = 0;
+	ering->rx_jumbo_max_pending = 0;
 }
 
 static u32 lio_get_msglevel(struct net_device *netdev)
