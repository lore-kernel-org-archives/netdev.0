From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4: Free completed tx skbs promptly
Date: Thu, 21 Aug 2014 17:04:46 +0530
Message-ID: <1408620886-20065-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:32857
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754583AbaHUL3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 07:29:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Description of problem:
The NIC card is not reporting back to the driver the transmitted skbs,
so they get stuck in the TX ring causing issues with reference
counters in other kernel components.

Developed a new Automatic Egress Queue Update firmware facility to slowly tick
through Egress Queues and send back any outstanding CIDX Updates which are
laying around.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c      |    3 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h |    1 +
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c    |    3 ++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index b0bba32..d22d728 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2303,7 +2303,8 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 			    FW_EQ_ETH_CMD_PFN(adap->fn) | FW_EQ_ETH_CMD_VFN(0));
 	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_ALLOC |
 				 FW_EQ_ETH_CMD_EQSTART | FW_LEN16(c));
-	c.viid_pkd = htonl(FW_EQ_ETH_CMD_VIID(pi->viid));
+	c.viid_pkd = htonl(FW_EQ_ETH_CMD_AUTOEQUEQE |
+			   FW_EQ_ETH_CMD_VIID(pi->viid));
 	c.fetchszm_to_iqid = htonl(FW_EQ_ETH_CMD_HOSTFCMODE(2) |
 				   FW_EQ_ETH_CMD_PCIECHN(pi->tx_chan) |
 				   FW_EQ_ETH_CMD_FETCHRO(1) |
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 0549170..5f2729e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1227,6 +1227,7 @@ struct fw_eq_eth_cmd {
 #define FW_EQ_ETH_CMD_CIDXFTHRESH(x) ((x) << 16)
 #define FW_EQ_ETH_CMD_EQSIZE(x) ((x) << 0)
 
+#define FW_EQ_ETH_CMD_AUTOEQUEQE (1U << 30)
 #define FW_EQ_ETH_CMD_VIID(x) ((x) << 16)
 
 struct fw_eq_ctrl_cmd {
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index bdfa80c..a5fb949 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2250,7 +2250,8 @@ int t4vf_sge_alloc_eth_txq(struct adapter *adapter, struct sge_eth_txq *txq,
 	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_ALLOC |
 					 FW_EQ_ETH_CMD_EQSTART |
 					 FW_LEN16(cmd));
-	cmd.viid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_VIID(pi->viid));
+	cmd.viid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_AUTOEQUEQE |
+				   FW_EQ_ETH_CMD_VIID(pi->viid));
 	cmd.fetchszm_to_iqid =
 		cpu_to_be32(FW_EQ_ETH_CMD_HOSTFCMODE(SGE_HOSTFCMODE_STPG) |
 			    FW_EQ_ETH_CMD_PCIECHN(pi->port_id) |
-- 
1.7.1
