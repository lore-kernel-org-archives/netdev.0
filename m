From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 8/9] cxgb4: Update SGE context congestion map change for T6 adapter
Date: Wed, 23 Dec 2015 22:47:18 +0530
Message-ID: <1450891039-17196-9-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:30645 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933296AbbLWRQN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:13 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGE context congestion map changed from 4 to 8 priority per port
in T6 as there are only 2 channels.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h | 1 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c   | 7 ++++---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c | 9 +++++++++
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 5c193a5..ec6e849 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -302,6 +302,7 @@ struct devlog_params {
 struct arch_specific_params {
 	u8 nchan;
 	u8 pm_stats_cnt;
+	u8 cng_ch_bits_log;		/* congestion channel map bits width */
 	u16 mps_rplc_size;
 	u16 vfcount;
 	u32 sge_fl_db;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 5829c9c..b4eb468 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2670,8 +2670,9 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	 * simple (and hopefully less wrong).
 	 */
 	if (!is_t4(adap->params.chip) && cong >= 0) {
-		u32 param, val;
+		u32 param, val, ch_map = 0;
 		int i;
+		u16 cng_ch_bits_log = adap->params.arch.cng_ch_bits_log;
 
 		param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DMAQ) |
 			 FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DMAQ_CONM_CTXT) |
@@ -2683,9 +2684,9 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 			    CONMCTXT_CNGTPMODE_V(CONMCTXT_CNGTPMODE_CHANNEL_X);
 			for (i = 0; i < 4; i++) {
 				if (cong & (1 << i))
-					val |=
-					     CONMCTXT_CNGCHMAP_V(1 << (i << 2));
+					ch_map |= 1 << (i << cng_ch_bits_log);
 			}
+			val |= CONMCTXT_CNGCHMAP_V(ch_map);
 		}
 		ret = t4_set_params(adap, adap->mbox, adap->pf, 0, 1,
 				    &param, &val);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 0132b64..636b469 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -7194,6 +7194,10 @@ int t4_prep_adapter(struct adapter *adapter)
 		adapter->params.arch.nchan = NCHAN;
 		adapter->params.arch.pm_stats_cnt = PM_NSTATS;
 		adapter->params.arch.vfcount = 128;
+		/* Congestion map is for 4 channels so that
+		 * MPS can have 4 priority per port.
+		 */
+		adapter->params.arch.cng_ch_bits_log = 2;
 		break;
 	case CHELSIO_T5:
 		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, pl_rev);
@@ -7204,6 +7208,7 @@ int t4_prep_adapter(struct adapter *adapter)
 		adapter->params.arch.nchan = NCHAN;
 		adapter->params.arch.pm_stats_cnt = PM_NSTATS;
 		adapter->params.arch.vfcount = 128;
+		adapter->params.arch.cng_ch_bits_log = 2;
 		break;
 	case CHELSIO_T6:
 		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T6, pl_rev);
@@ -7214,6 +7219,10 @@ int t4_prep_adapter(struct adapter *adapter)
 		adapter->params.arch.nchan = 2;
 		adapter->params.arch.pm_stats_cnt = T6_PM_NSTATS;
 		adapter->params.arch.vfcount = 256;
+		/* Congestion map will be for 2 channels so that
+		 * MPS can have 8 priority per port.
+		 */
+		adapter->params.arch.cng_ch_bits_log = 3;
 		break;
 	default:
 		dev_err(adapter->pdev_dev, "Device %d is not supported\n",
-- 
2.3.4
