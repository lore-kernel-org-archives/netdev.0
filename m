From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/5] cxgb4/cxgb4vf/csiostor: Cleanup macros/register defines related to queues
Date: Fri, 21 Nov 2014 12:52:03 +0530
Message-ID: <1416554525-11844-4-git-send-email-hariprasad@chelsio.com>
References: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, hch@infradead.org,
	swise@opengridcomputing.com, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, praveen@chelsio.com,
	varun@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:33695
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752436AbaKUHR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 02:17:28 -0500
In-Reply-To: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleanups all queue related macros/register defines that are defined
in t4fw_api.h and the affected files.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c       |  115 ++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c     |   32 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h  |  690 ++++++++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4vf/sge.c     |   63 ++--
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c |    8 +-
 drivers/scsi/csiostor/csio_mb.c                |  119 ++--
 6 files changed, 684 insertions(+), 343 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 5cc5e19..433560b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -2299,18 +2299,18 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_IQ_CMD_PFN(adap->fn) | FW_IQ_CMD_VFN(0));
-	c.alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC | FW_IQ_CMD_IQSTART(1) |
+			    FW_IQ_CMD_PFN_V(adap->fn) | FW_IQ_CMD_VFN_V(0));
+	c.alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC_F | FW_IQ_CMD_IQSTART_F |
 				 FW_LEN16(c));
-	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE(FW_IQ_TYPE_FL_INT_CAP) |
-		FW_IQ_CMD_IQASYNCH(fwevtq) | FW_IQ_CMD_VIID(pi->viid) |
-		FW_IQ_CMD_IQANDST(intr_idx < 0) | FW_IQ_CMD_IQANUD(1) |
-		FW_IQ_CMD_IQANDSTINDEX(intr_idx >= 0 ? intr_idx :
+	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE_V(FW_IQ_TYPE_FL_INT_CAP) |
+		FW_IQ_CMD_IQASYNCH_V(fwevtq) | FW_IQ_CMD_VIID_V(pi->viid) |
+		FW_IQ_CMD_IQANDST_V(intr_idx < 0) | FW_IQ_CMD_IQANUD_V(1) |
+		FW_IQ_CMD_IQANDSTINDEX_V(intr_idx >= 0 ? intr_idx :
 							-intr_idx - 1));
-	c.iqdroprss_to_iqesize = htons(FW_IQ_CMD_IQPCIECH(pi->tx_chan) |
-		FW_IQ_CMD_IQGTSMODE |
-		FW_IQ_CMD_IQINTCNTTHRESH(iq->pktcnt_idx) |
-		FW_IQ_CMD_IQESIZE(ilog2(iq->iqe_len) - 4));
+	c.iqdroprss_to_iqesize = htons(FW_IQ_CMD_IQPCIECH_V(pi->tx_chan) |
+		FW_IQ_CMD_IQGTSMODE_F |
+		FW_IQ_CMD_IQINTCNTTHRESH_V(iq->pktcnt_idx) |
+		FW_IQ_CMD_IQESIZE_V(ilog2(iq->iqe_len) - 4));
 	c.iqsize = htons(iq->size);
 	c.iqaddr = cpu_to_be64(iq->phys_addr);
 
@@ -2323,12 +2323,12 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 			goto fl_nomem;
 
 		flsz = fl->size / 8 + s->stat_len / sizeof(struct tx_desc);
-		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_FL0PACKEN(1) |
-					    FW_IQ_CMD_FL0FETCHRO(1) |
-					    FW_IQ_CMD_FL0DATARO(1) |
-					    FW_IQ_CMD_FL0PADEN(1));
-		c.fl0dcaen_to_fl0cidxfthresh = htons(FW_IQ_CMD_FL0FBMIN(2) |
-				FW_IQ_CMD_FL0FBMAX(3));
+		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_FL0PACKEN_F |
+					    FW_IQ_CMD_FL0FETCHRO_F |
+					    FW_IQ_CMD_FL0DATARO_F |
+					    FW_IQ_CMD_FL0PADEN_F);
+		c.fl0dcaen_to_fl0cidxfthresh = htons(FW_IQ_CMD_FL0FBMIN_V(2) |
+				FW_IQ_CMD_FL0FBMAX_V(3));
 		c.fl0size = htons(flsz);
 		c.fl0addr = cpu_to_be64(fl->addr);
 	}
@@ -2425,19 +2425,20 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_ETH_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_EQ_ETH_CMD_PFN(adap->fn) | FW_EQ_ETH_CMD_VFN(0));
-	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_ALLOC |
-				 FW_EQ_ETH_CMD_EQSTART | FW_LEN16(c));
-	c.viid_pkd = htonl(FW_EQ_ETH_CMD_AUTOEQUEQE |
-			   FW_EQ_ETH_CMD_VIID(pi->viid));
-	c.fetchszm_to_iqid = htonl(FW_EQ_ETH_CMD_HOSTFCMODE(2) |
-				   FW_EQ_ETH_CMD_PCIECHN(pi->tx_chan) |
-				   FW_EQ_ETH_CMD_FETCHRO(1) |
-				   FW_EQ_ETH_CMD_IQID(iqid));
-	c.dcaen_to_eqsize = htonl(FW_EQ_ETH_CMD_FBMIN(2) |
-				  FW_EQ_ETH_CMD_FBMAX(3) |
-				  FW_EQ_ETH_CMD_CIDXFTHRESH(5) |
-				  FW_EQ_ETH_CMD_EQSIZE(nentries));
+			    FW_EQ_ETH_CMD_PFN_V(adap->fn) |
+			    FW_EQ_ETH_CMD_VFN_V(0));
+	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_ALLOC_F |
+				 FW_EQ_ETH_CMD_EQSTART_F | FW_LEN16(c));
+	c.viid_pkd = htonl(FW_EQ_ETH_CMD_AUTOEQUEQE_F |
+			   FW_EQ_ETH_CMD_VIID_V(pi->viid));
+	c.fetchszm_to_iqid = htonl(FW_EQ_ETH_CMD_HOSTFCMODE_V(2) |
+				   FW_EQ_ETH_CMD_PCIECHN_V(pi->tx_chan) |
+				   FW_EQ_ETH_CMD_FETCHRO_V(1) |
+				   FW_EQ_ETH_CMD_IQID_V(iqid));
+	c.dcaen_to_eqsize = htonl(FW_EQ_ETH_CMD_FBMIN_V(2) |
+				  FW_EQ_ETH_CMD_FBMAX_V(3) |
+				  FW_EQ_ETH_CMD_CIDXFTHRESH_V(5) |
+				  FW_EQ_ETH_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
 	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
@@ -2451,7 +2452,7 @@ int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
 		return ret;
 	}
 
-	init_txq(adap, &txq->q, FW_EQ_ETH_CMD_EQID_GET(ntohl(c.eqid_pkd)));
+	init_txq(adap, &txq->q, FW_EQ_ETH_CMD_EQID_G(ntohl(c.eqid_pkd)));
 	txq->txq = netdevq;
 	txq->tso = txq->tx_cso = txq->vlan_ins = 0;
 	txq->mapping_err = 0;
@@ -2478,20 +2479,20 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_EQ_CTRL_CMD_PFN(adap->fn) |
-			    FW_EQ_CTRL_CMD_VFN(0));
-	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_ALLOC |
-				 FW_EQ_CTRL_CMD_EQSTART | FW_LEN16(c));
-	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_CMPLIQID(cmplqid));
+			    FW_EQ_CTRL_CMD_PFN_V(adap->fn) |
+			    FW_EQ_CTRL_CMD_VFN_V(0));
+	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_ALLOC_F |
+				 FW_EQ_CTRL_CMD_EQSTART_F | FW_LEN16(c));
+	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_CMPLIQID_V(cmplqid));
 	c.physeqid_pkd = htonl(0);
-	c.fetchszm_to_iqid = htonl(FW_EQ_CTRL_CMD_HOSTFCMODE(2) |
-				   FW_EQ_CTRL_CMD_PCIECHN(pi->tx_chan) |
-				   FW_EQ_CTRL_CMD_FETCHRO |
-				   FW_EQ_CTRL_CMD_IQID(iqid));
-	c.dcaen_to_eqsize = htonl(FW_EQ_CTRL_CMD_FBMIN(2) |
-				  FW_EQ_CTRL_CMD_FBMAX(3) |
-				  FW_EQ_CTRL_CMD_CIDXFTHRESH(5) |
-				  FW_EQ_CTRL_CMD_EQSIZE(nentries));
+	c.fetchszm_to_iqid = htonl(FW_EQ_CTRL_CMD_HOSTFCMODE_V(2) |
+				   FW_EQ_CTRL_CMD_PCIECHN_V(pi->tx_chan) |
+				   FW_EQ_CTRL_CMD_FETCHRO_F |
+				   FW_EQ_CTRL_CMD_IQID_V(iqid));
+	c.dcaen_to_eqsize = htonl(FW_EQ_CTRL_CMD_FBMIN_V(2) |
+				  FW_EQ_CTRL_CMD_FBMAX_V(3) |
+				  FW_EQ_CTRL_CMD_CIDXFTHRESH_V(5) |
+				  FW_EQ_CTRL_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
 	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
@@ -2503,7 +2504,7 @@ int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
 		return ret;
 	}
 
-	init_txq(adap, &txq->q, FW_EQ_CTRL_CMD_EQID_GET(ntohl(c.cmpliqid_eqid)));
+	init_txq(adap, &txq->q, FW_EQ_CTRL_CMD_EQID_G(ntohl(c.cmpliqid_eqid)));
 	txq->adap = adap;
 	skb_queue_head_init(&txq->sendq);
 	tasklet_init(&txq->qresume_tsk, restart_ctrlq, (unsigned long)txq);
@@ -2532,18 +2533,18 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST_F |
 			    FW_CMD_WRITE_F | FW_CMD_EXEC_F |
-			    FW_EQ_OFLD_CMD_PFN(adap->fn) |
-			    FW_EQ_OFLD_CMD_VFN(0));
-	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC |
-				 FW_EQ_OFLD_CMD_EQSTART | FW_LEN16(c));
-	c.fetchszm_to_iqid = htonl(FW_EQ_OFLD_CMD_HOSTFCMODE(2) |
-				   FW_EQ_OFLD_CMD_PCIECHN(pi->tx_chan) |
-				   FW_EQ_OFLD_CMD_FETCHRO(1) |
-				   FW_EQ_OFLD_CMD_IQID(iqid));
-	c.dcaen_to_eqsize = htonl(FW_EQ_OFLD_CMD_FBMIN(2) |
-				  FW_EQ_OFLD_CMD_FBMAX(3) |
-				  FW_EQ_OFLD_CMD_CIDXFTHRESH(5) |
-				  FW_EQ_OFLD_CMD_EQSIZE(nentries));
+			    FW_EQ_OFLD_CMD_PFN_V(adap->fn) |
+			    FW_EQ_OFLD_CMD_VFN_V(0));
+	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC_F |
+				 FW_EQ_OFLD_CMD_EQSTART_F | FW_LEN16(c));
+	c.fetchszm_to_iqid = htonl(FW_EQ_OFLD_CMD_HOSTFCMODE_V(2) |
+				   FW_EQ_OFLD_CMD_PCIECHN_V(pi->tx_chan) |
+				   FW_EQ_OFLD_CMD_FETCHRO_F |
+				   FW_EQ_OFLD_CMD_IQID_V(iqid));
+	c.dcaen_to_eqsize = htonl(FW_EQ_OFLD_CMD_FBMIN_V(2) |
+				  FW_EQ_OFLD_CMD_FBMAX_V(3) |
+				  FW_EQ_OFLD_CMD_CIDXFTHRESH_V(5) |
+				  FW_EQ_OFLD_CMD_EQSIZE_V(nentries));
 	c.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
 	ret = t4_wr_mbox(adap, adap->fn, &c, sizeof(c), &c);
@@ -2557,7 +2558,7 @@ int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
 		return ret;
 	}
 
-	init_txq(adap, &txq->q, FW_EQ_OFLD_CMD_EQID_GET(ntohl(c.eqid_pkd)));
+	init_txq(adap, &txq->q, FW_EQ_OFLD_CMD_EQID_G(ntohl(c.eqid_pkd)));
 	txq->adap = adap;
 	skb_queue_head_init(&txq->sendq);
 	tasklet_init(&txq->qresume_tsk, restart_ofldq, (unsigned long)txq);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 9f1b304..da72814 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3715,10 +3715,10 @@ int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_IQ_CMD_PFN(pf) |
-			    FW_IQ_CMD_VFN(vf));
-	c.alloc_to_len16 = htonl(FW_IQ_CMD_FREE | FW_LEN16(c));
-	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE(iqtype));
+			    FW_CMD_EXEC_F | FW_IQ_CMD_PFN_V(pf) |
+			    FW_IQ_CMD_VFN_V(vf));
+	c.alloc_to_len16 = htonl(FW_IQ_CMD_FREE_F | FW_LEN16(c));
+	c.type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE_V(iqtype));
 	c.iqid = htons(iqid);
 	c.fl0id = htons(fl0id);
 	c.fl1id = htons(fl1id);
@@ -3742,10 +3742,10 @@ int t4_eth_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_ETH_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_EQ_ETH_CMD_PFN(pf) |
-			    FW_EQ_ETH_CMD_VFN(vf));
-	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_FREE | FW_LEN16(c));
-	c.eqid_pkd = htonl(FW_EQ_ETH_CMD_EQID(eqid));
+			    FW_CMD_EXEC_F | FW_EQ_ETH_CMD_PFN_V(pf) |
+			    FW_EQ_ETH_CMD_VFN_V(vf));
+	c.alloc_to_len16 = htonl(FW_EQ_ETH_CMD_FREE_F | FW_LEN16(c));
+	c.eqid_pkd = htonl(FW_EQ_ETH_CMD_EQID_V(eqid));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -3766,10 +3766,10 @@ int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_CTRL_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_EQ_CTRL_CMD_PFN(pf) |
-			    FW_EQ_CTRL_CMD_VFN(vf));
-	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_FREE | FW_LEN16(c));
-	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_EQID(eqid));
+			    FW_CMD_EXEC_F | FW_EQ_CTRL_CMD_PFN_V(pf) |
+			    FW_EQ_CTRL_CMD_VFN_V(vf));
+	c.alloc_to_len16 = htonl(FW_EQ_CTRL_CMD_FREE_F | FW_LEN16(c));
+	c.cmpliqid_eqid = htonl(FW_EQ_CTRL_CMD_EQID_V(eqid));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
@@ -3790,10 +3790,10 @@ int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
 
 	memset(&c, 0, sizeof(c));
 	c.op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD) | FW_CMD_REQUEST_F |
-			    FW_CMD_EXEC_F | FW_EQ_OFLD_CMD_PFN(pf) |
-			    FW_EQ_OFLD_CMD_VFN(vf));
-	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_FREE | FW_LEN16(c));
-	c.eqid_pkd = htonl(FW_EQ_OFLD_CMD_EQID(eqid));
+			    FW_CMD_EXEC_F | FW_EQ_OFLD_CMD_PFN_V(pf) |
+			    FW_EQ_OFLD_CMD_VFN_V(vf));
+	c.alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_FREE_F | FW_LEN16(c));
+	c.eqid_pkd = htonl(FW_EQ_OFLD_CMD_EQID_V(eqid));
 	return t4_wr_mbox(adap, mbox, &c, sizeof(c), NULL);
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 5839b80..92a0df5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -1274,85 +1274,239 @@ struct fw_iq_cmd {
 	__be64 fl1addr;
 };
 
-#define FW_IQ_CMD_PFN(x) ((x) << 8)
-#define FW_IQ_CMD_VFN(x) ((x) << 0)
-
-#define FW_IQ_CMD_ALLOC (1U << 31)
-#define FW_IQ_CMD_FREE (1U << 30)
-#define FW_IQ_CMD_MODIFY (1U << 29)
-#define FW_IQ_CMD_IQSTART(x) ((x) << 28)
-#define FW_IQ_CMD_IQSTOP(x) ((x) << 27)
-
-#define FW_IQ_CMD_TYPE(x) ((x) << 29)
-#define FW_IQ_CMD_IQASYNCH(x) ((x) << 28)
-#define FW_IQ_CMD_VIID(x) ((x) << 16)
-#define FW_IQ_CMD_IQANDST(x) ((x) << 15)
-#define FW_IQ_CMD_IQANUS(x) ((x) << 14)
-#define FW_IQ_CMD_IQANUD(x) ((x) << 12)
-#define FW_IQ_CMD_IQANDSTINDEX(x) ((x) << 0)
-
-#define FW_IQ_CMD_IQDROPRSS (1U << 15)
-#define FW_IQ_CMD_IQGTSMODE (1U << 14)
-#define FW_IQ_CMD_IQPCIECH(x) ((x) << 12)
-#define FW_IQ_CMD_IQDCAEN(x) ((x) << 11)
-#define FW_IQ_CMD_IQDCACPU(x) ((x) << 6)
-#define FW_IQ_CMD_IQINTCNTTHRESH(x) ((x) << 4)
-#define FW_IQ_CMD_IQO (1U << 3)
-#define FW_IQ_CMD_IQCPRIO(x) ((x) << 2)
-#define FW_IQ_CMD_IQESIZE(x) ((x) << 0)
-
-#define FW_IQ_CMD_IQNS(x) ((x) << 31)
-#define FW_IQ_CMD_IQRO(x) ((x) << 30)
-#define FW_IQ_CMD_IQFLINTIQHSEN(x) ((x) << 28)
-#define FW_IQ_CMD_IQFLINTCONGEN(x) ((x) << 27)
-#define FW_IQ_CMD_IQFLINTISCSIC(x) ((x) << 26)
-#define FW_IQ_CMD_FL0CNGCHMAP(x) ((x) << 20)
-#define FW_IQ_CMD_FL0CACHELOCK(x) ((x) << 15)
-#define FW_IQ_CMD_FL0DBP(x) ((x) << 14)
-#define FW_IQ_CMD_FL0DATANS(x) ((x) << 13)
-#define FW_IQ_CMD_FL0DATARO(x) ((x) << 12)
-#define FW_IQ_CMD_FL0CONGCIF(x) ((x) << 11)
-#define FW_IQ_CMD_FL0ONCHIP(x) ((x) << 10)
-#define FW_IQ_CMD_FL0STATUSPGNS(x) ((x) << 9)
-#define FW_IQ_CMD_FL0STATUSPGRO(x) ((x) << 8)
-#define FW_IQ_CMD_FL0FETCHNS(x) ((x) << 7)
-#define FW_IQ_CMD_FL0FETCHRO(x) ((x) << 6)
-#define FW_IQ_CMD_FL0HOSTFCMODE(x) ((x) << 4)
-#define FW_IQ_CMD_FL0CPRIO(x) ((x) << 3)
-#define FW_IQ_CMD_FL0PADEN(x) ((x) << 2)
-#define FW_IQ_CMD_FL0PACKEN(x) ((x) << 1)
-#define FW_IQ_CMD_FL0CONGEN (1U << 0)
-
-#define FW_IQ_CMD_FL0DCAEN(x) ((x) << 15)
-#define FW_IQ_CMD_FL0DCACPU(x) ((x) << 10)
-#define FW_IQ_CMD_FL0FBMIN(x) ((x) << 7)
-#define FW_IQ_CMD_FL0FBMAX(x) ((x) << 4)
-#define FW_IQ_CMD_FL0CIDXFTHRESHO (1U << 3)
-#define FW_IQ_CMD_FL0CIDXFTHRESH(x) ((x) << 0)
-
-#define FW_IQ_CMD_FL1CNGCHMAP(x) ((x) << 20)
-#define FW_IQ_CMD_FL1CACHELOCK(x) ((x) << 15)
-#define FW_IQ_CMD_FL1DBP(x) ((x) << 14)
-#define FW_IQ_CMD_FL1DATANS(x) ((x) << 13)
-#define FW_IQ_CMD_FL1DATARO(x) ((x) << 12)
-#define FW_IQ_CMD_FL1CONGCIF(x) ((x) << 11)
-#define FW_IQ_CMD_FL1ONCHIP(x) ((x) << 10)
-#define FW_IQ_CMD_FL1STATUSPGNS(x) ((x) << 9)
-#define FW_IQ_CMD_FL1STATUSPGRO(x) ((x) << 8)
-#define FW_IQ_CMD_FL1FETCHNS(x) ((x) << 7)
-#define FW_IQ_CMD_FL1FETCHRO(x) ((x) << 6)
-#define FW_IQ_CMD_FL1HOSTFCMODE(x) ((x) << 4)
-#define FW_IQ_CMD_FL1CPRIO(x) ((x) << 3)
-#define FW_IQ_CMD_FL1PADEN (1U << 2)
-#define FW_IQ_CMD_FL1PACKEN (1U << 1)
-#define FW_IQ_CMD_FL1CONGEN (1U << 0)
-
-#define FW_IQ_CMD_FL1DCAEN(x) ((x) << 15)
-#define FW_IQ_CMD_FL1DCACPU(x) ((x) << 10)
-#define FW_IQ_CMD_FL1FBMIN(x) ((x) << 7)
-#define FW_IQ_CMD_FL1FBMAX(x) ((x) << 4)
-#define FW_IQ_CMD_FL1CIDXFTHRESHO (1U << 3)
-#define FW_IQ_CMD_FL1CIDXFTHRESH(x) ((x) << 0)
+#define FW_IQ_CMD_PFN_S		8
+#define FW_IQ_CMD_PFN_V(x)	((x) << FW_IQ_CMD_PFN_S)
+
+#define FW_IQ_CMD_VFN_S		0
+#define FW_IQ_CMD_VFN_V(x)	((x) << FW_IQ_CMD_VFN_S)
+
+#define FW_IQ_CMD_ALLOC_S	31
+#define FW_IQ_CMD_ALLOC_V(x)	((x) << FW_IQ_CMD_ALLOC_S)
+#define FW_IQ_CMD_ALLOC_F	FW_IQ_CMD_ALLOC_V(1U)
+
+#define FW_IQ_CMD_FREE_S	30
+#define FW_IQ_CMD_FREE_V(x)	((x) << FW_IQ_CMD_FREE_S)
+#define FW_IQ_CMD_FREE_F	FW_IQ_CMD_FREE_V(1U)
+
+#define FW_IQ_CMD_MODIFY_S	29
+#define FW_IQ_CMD_MODIFY_V(x)	((x) << FW_IQ_CMD_MODIFY_S)
+#define FW_IQ_CMD_MODIFY_F	FW_IQ_CMD_MODIFY_V(1U)
+
+#define FW_IQ_CMD_IQSTART_S	28
+#define FW_IQ_CMD_IQSTART_V(x)	((x) << FW_IQ_CMD_IQSTART_S)
+#define FW_IQ_CMD_IQSTART_F	FW_IQ_CMD_IQSTART_V(1U)
+
+#define FW_IQ_CMD_IQSTOP_S	27
+#define FW_IQ_CMD_IQSTOP_V(x)	((x) << FW_IQ_CMD_IQSTOP_S)
+#define FW_IQ_CMD_IQSTOP_F	FW_IQ_CMD_IQSTOP_V(1U)
+
+#define FW_IQ_CMD_TYPE_S	29
+#define FW_IQ_CMD_TYPE_V(x)	((x) << FW_IQ_CMD_TYPE_S)
+
+#define FW_IQ_CMD_IQASYNCH_S	28
+#define FW_IQ_CMD_IQASYNCH_V(x)	((x) << FW_IQ_CMD_IQASYNCH_S)
+
+#define FW_IQ_CMD_VIID_S	16
+#define FW_IQ_CMD_VIID_V(x)	((x) << FW_IQ_CMD_VIID_S)
+
+#define FW_IQ_CMD_IQANDST_S	15
+#define FW_IQ_CMD_IQANDST_V(x)	((x) << FW_IQ_CMD_IQANDST_S)
+
+#define FW_IQ_CMD_IQANUS_S	14
+#define FW_IQ_CMD_IQANUS_V(x)	((x) << FW_IQ_CMD_IQANUS_S)
+
+#define FW_IQ_CMD_IQANUD_S	12
+#define FW_IQ_CMD_IQANUD_V(x)	((x) << FW_IQ_CMD_IQANUD_S)
+
+#define FW_IQ_CMD_IQANDSTINDEX_S	0
+#define FW_IQ_CMD_IQANDSTINDEX_V(x)	((x) << FW_IQ_CMD_IQANDSTINDEX_S)
+
+#define FW_IQ_CMD_IQDROPRSS_S		15
+#define FW_IQ_CMD_IQDROPRSS_V(x)	((x) << FW_IQ_CMD_IQDROPRSS_S)
+#define FW_IQ_CMD_IQDROPRSS_F	FW_IQ_CMD_IQDROPRSS_V(1U)
+
+#define FW_IQ_CMD_IQGTSMODE_S		14
+#define FW_IQ_CMD_IQGTSMODE_V(x)	((x) << FW_IQ_CMD_IQGTSMODE_S)
+#define FW_IQ_CMD_IQGTSMODE_F		FW_IQ_CMD_IQGTSMODE_V(1U)
+
+#define FW_IQ_CMD_IQPCIECH_S	12
+#define FW_IQ_CMD_IQPCIECH_V(x)	((x) << FW_IQ_CMD_IQPCIECH_S)
+
+#define FW_IQ_CMD_IQDCAEN_S	11
+#define FW_IQ_CMD_IQDCAEN_V(x)	((x) << FW_IQ_CMD_IQDCAEN_S)
+
+#define FW_IQ_CMD_IQDCACPU_S	6
+#define FW_IQ_CMD_IQDCACPU_V(x)	((x) << FW_IQ_CMD_IQDCACPU_S)
+
+#define FW_IQ_CMD_IQINTCNTTHRESH_S	4
+#define FW_IQ_CMD_IQINTCNTTHRESH_V(x)	((x) << FW_IQ_CMD_IQINTCNTTHRESH_S)
+
+#define FW_IQ_CMD_IQO_S		3
+#define FW_IQ_CMD_IQO_V(x)	((x) << FW_IQ_CMD_IQO_S)
+#define FW_IQ_CMD_IQO_F		FW_IQ_CMD_IQO_V(1U)
+
+#define FW_IQ_CMD_IQCPRIO_S	2
+#define FW_IQ_CMD_IQCPRIO_V(x)	((x) << FW_IQ_CMD_IQCPRIO_S)
+
+#define FW_IQ_CMD_IQESIZE_S	0
+#define FW_IQ_CMD_IQESIZE_V(x)	((x) << FW_IQ_CMD_IQESIZE_S)
+
+#define FW_IQ_CMD_IQNS_S	31
+#define FW_IQ_CMD_IQNS_V(x)	((x) << FW_IQ_CMD_IQNS_S)
+
+#define FW_IQ_CMD_IQRO_S	30
+#define FW_IQ_CMD_IQRO_V(x)	((x) << FW_IQ_CMD_IQRO_S)
+
+#define FW_IQ_CMD_IQFLINTIQHSEN_S	28
+#define FW_IQ_CMD_IQFLINTIQHSEN_V(x)	((x) << FW_IQ_CMD_IQFLINTIQHSEN_S)
+
+#define FW_IQ_CMD_IQFLINTCONGEN_S	27
+#define FW_IQ_CMD_IQFLINTCONGEN_V(x)	((x) << FW_IQ_CMD_IQFLINTCONGEN_S)
+
+#define FW_IQ_CMD_IQFLINTISCSIC_S	26
+#define FW_IQ_CMD_IQFLINTISCSIC_V(x)	((x) << FW_IQ_CMD_IQFLINTISCSIC_S)
+
+#define FW_IQ_CMD_FL0CNGCHMAP_S		20
+#define FW_IQ_CMD_FL0CNGCHMAP_V(x)	((x) << FW_IQ_CMD_FL0CNGCHMAP_S)
+
+#define FW_IQ_CMD_FL0CACHELOCK_S	15
+#define FW_IQ_CMD_FL0CACHELOCK_V(x)	((x) << FW_IQ_CMD_FL0CACHELOCK_S)
+
+#define FW_IQ_CMD_FL0DBP_S	14
+#define FW_IQ_CMD_FL0DBP_V(x)	((x) << FW_IQ_CMD_FL0DBP_S)
+
+#define FW_IQ_CMD_FL0DATANS_S		13
+#define FW_IQ_CMD_FL0DATANS_V(x)	((x) << FW_IQ_CMD_FL0DATANS_S)
+
+#define FW_IQ_CMD_FL0DATARO_S		12
+#define FW_IQ_CMD_FL0DATARO_V(x)	((x) << FW_IQ_CMD_FL0DATARO_S)
+#define FW_IQ_CMD_FL0DATARO_F		FW_IQ_CMD_FL0DATARO_V(1U)
+
+#define FW_IQ_CMD_FL0CONGCIF_S		11
+#define FW_IQ_CMD_FL0CONGCIF_V(x)	((x) << FW_IQ_CMD_FL0CONGCIF_S)
+
+#define FW_IQ_CMD_FL0ONCHIP_S		10
+#define FW_IQ_CMD_FL0ONCHIP_V(x)	((x) << FW_IQ_CMD_FL0ONCHIP_S)
+
+#define FW_IQ_CMD_FL0STATUSPGNS_S	9
+#define FW_IQ_CMD_FL0STATUSPGNS_V(x)	((x) << FW_IQ_CMD_FL0STATUSPGNS_S)
+
+#define FW_IQ_CMD_FL0STATUSPGRO_S	8
+#define FW_IQ_CMD_FL0STATUSPGRO_V(x)	((x) << FW_IQ_CMD_FL0STATUSPGRO_S)
+
+#define FW_IQ_CMD_FL0FETCHNS_S		7
+#define FW_IQ_CMD_FL0FETCHNS_V(x)	((x) << FW_IQ_CMD_FL0FETCHNS_S)
+
+#define FW_IQ_CMD_FL0FETCHRO_S		6
+#define FW_IQ_CMD_FL0FETCHRO_V(x)	((x) << FW_IQ_CMD_FL0FETCHRO_S)
+#define FW_IQ_CMD_FL0FETCHRO_F		FW_IQ_CMD_FL0FETCHRO_V(1U)
+
+#define FW_IQ_CMD_FL0HOSTFCMODE_S	4
+#define FW_IQ_CMD_FL0HOSTFCMODE_V(x)	((x) << FW_IQ_CMD_FL0HOSTFCMODE_S)
+
+#define FW_IQ_CMD_FL0CPRIO_S	3
+#define FW_IQ_CMD_FL0CPRIO_V(x)	((x) << FW_IQ_CMD_FL0CPRIO_S)
+
+#define FW_IQ_CMD_FL0PADEN_S	2
+#define FW_IQ_CMD_FL0PADEN_V(x)	((x) << FW_IQ_CMD_FL0PADEN_S)
+#define FW_IQ_CMD_FL0PADEN_F	FW_IQ_CMD_FL0PADEN_V(1U)
+
+#define FW_IQ_CMD_FL0PACKEN_S		1
+#define FW_IQ_CMD_FL0PACKEN_V(x)	((x) << FW_IQ_CMD_FL0PACKEN_S)
+#define FW_IQ_CMD_FL0PACKEN_F		FW_IQ_CMD_FL0PACKEN_V(1U)
+
+#define FW_IQ_CMD_FL0CONGEN_S		0
+#define FW_IQ_CMD_FL0CONGEN_V(x)	((x) << FW_IQ_CMD_FL0CONGEN_S)
+#define FW_IQ_CMD_FL0CONGEN_F		FW_IQ_CMD_FL0CONGEN_V(1U)
+
+#define FW_IQ_CMD_FL0DCAEN_S	15
+#define FW_IQ_CMD_FL0DCAEN_V(x)	((x) << FW_IQ_CMD_FL0DCAEN_S)
+
+#define FW_IQ_CMD_FL0DCACPU_S		10
+#define FW_IQ_CMD_FL0DCACPU_V(x)	((x) << FW_IQ_CMD_FL0DCACPU_S)
+
+#define FW_IQ_CMD_FL0FBMIN_S	7
+#define FW_IQ_CMD_FL0FBMIN_V(x)	((x) << FW_IQ_CMD_FL0FBMIN_S)
+
+#define FW_IQ_CMD_FL0FBMAX_S	4
+#define FW_IQ_CMD_FL0FBMAX_V(x)	((x) << FW_IQ_CMD_FL0FBMAX_S)
+
+#define FW_IQ_CMD_FL0CIDXFTHRESHO_S	3
+#define FW_IQ_CMD_FL0CIDXFTHRESHO_V(x)	((x) << FW_IQ_CMD_FL0CIDXFTHRESHO_S)
+#define FW_IQ_CMD_FL0CIDXFTHRESHO_F	FW_IQ_CMD_FL0CIDXFTHRESHO_V(1U)
+
+#define FW_IQ_CMD_FL0CIDXFTHRESH_S	0
+#define FW_IQ_CMD_FL0CIDXFTHRESH_V(x)	((x) << FW_IQ_CMD_FL0CIDXFTHRESH_S)
+
+#define FW_IQ_CMD_FL1CNGCHMAP_S		20
+#define FW_IQ_CMD_FL1CNGCHMAP_V(x)	((x) << FW_IQ_CMD_FL1CNGCHMAP_S)
+
+#define FW_IQ_CMD_FL1CACHELOCK_S	15
+#define FW_IQ_CMD_FL1CACHELOCK_V(x)	((x) << FW_IQ_CMD_FL1CACHELOCK_S)
+
+#define FW_IQ_CMD_FL1DBP_S	14
+#define FW_IQ_CMD_FL1DBP_V(x)	((x) << FW_IQ_CMD_FL1DBP_S)
+
+#define FW_IQ_CMD_FL1DATANS_S		13
+#define FW_IQ_CMD_FL1DATANS_V(x)	((x) << FW_IQ_CMD_FL1DATANS_S)
+
+#define FW_IQ_CMD_FL1DATARO_S		12
+#define FW_IQ_CMD_FL1DATARO_V(x)	((x) << FW_IQ_CMD_FL1DATARO_S)
+
+#define FW_IQ_CMD_FL1CONGCIF_S		11
+#define FW_IQ_CMD_FL1CONGCIF_V(x)	((x) << FW_IQ_CMD_FL1CONGCIF_S)
+
+#define FW_IQ_CMD_FL1ONCHIP_S		10
+#define FW_IQ_CMD_FL1ONCHIP_V(x)	((x) << FW_IQ_CMD_FL1ONCHIP_S)
+
+#define FW_IQ_CMD_FL1STATUSPGNS_S	9
+#define FW_IQ_CMD_FL1STATUSPGNS_V(x)	((x) << FW_IQ_CMD_FL1STATUSPGNS_S)
+
+#define FW_IQ_CMD_FL1STATUSPGRO_S	8
+#define FW_IQ_CMD_FL1STATUSPGRO_V(x)	((x) << FW_IQ_CMD_FL1STATUSPGRO_S)
+
+#define FW_IQ_CMD_FL1FETCHNS_S		7
+#define FW_IQ_CMD_FL1FETCHNS_V(x)	((x) << FW_IQ_CMD_FL1FETCHNS_S)
+
+#define FW_IQ_CMD_FL1FETCHRO_S		6
+#define FW_IQ_CMD_FL1FETCHRO_V(x)	((x) << FW_IQ_CMD_FL1FETCHRO_S)
+
+#define FW_IQ_CMD_FL1HOSTFCMODE_S	4
+#define FW_IQ_CMD_FL1HOSTFCMODE_V(x)	((x) << FW_IQ_CMD_FL1HOSTFCMODE_S)
+
+#define FW_IQ_CMD_FL1CPRIO_S	3
+#define FW_IQ_CMD_FL1CPRIO_V(x)	((x) << FW_IQ_CMD_FL1CPRIO_S)
+
+#define FW_IQ_CMD_FL1PADEN_S	2
+#define FW_IQ_CMD_FL1PADEN_V(x)	((x) << FW_IQ_CMD_FL1PADEN_S)
+#define FW_IQ_CMD_FL1PADEN_F	FW_IQ_CMD_FL1PADEN_V(1U)
+
+#define FW_IQ_CMD_FL1PACKEN_S		1
+#define FW_IQ_CMD_FL1PACKEN_V(x)	((x) << FW_IQ_CMD_FL1PACKEN_S)
+#define FW_IQ_CMD_FL1PACKEN_F	FW_IQ_CMD_FL1PACKEN_V(1U)
+
+#define FW_IQ_CMD_FL1CONGEN_S		0
+#define FW_IQ_CMD_FL1CONGEN_V(x)	((x) << FW_IQ_CMD_FL1CONGEN_S)
+#define FW_IQ_CMD_FL1CONGEN_F	FW_IQ_CMD_FL1CONGEN_V(1U)
+
+#define FW_IQ_CMD_FL1DCAEN_S	15
+#define FW_IQ_CMD_FL1DCAEN_V(x)	((x) << FW_IQ_CMD_FL1DCAEN_S)
+
+#define FW_IQ_CMD_FL1DCACPU_S		10
+#define FW_IQ_CMD_FL1DCACPU_V(x)	((x) << FW_IQ_CMD_FL1DCACPU_S)
+
+#define FW_IQ_CMD_FL1FBMIN_S	7
+#define FW_IQ_CMD_FL1FBMIN_V(x)	((x) << FW_IQ_CMD_FL1FBMIN_S)
+
+#define FW_IQ_CMD_FL1FBMAX_S	4
+#define FW_IQ_CMD_FL1FBMAX_V(x)	((x) << FW_IQ_CMD_FL1FBMAX_S)
+
+#define FW_IQ_CMD_FL1CIDXFTHRESHO_S	3
+#define FW_IQ_CMD_FL1CIDXFTHRESHO_V(x)	((x) << FW_IQ_CMD_FL1CIDXFTHRESHO_S)
+#define FW_IQ_CMD_FL1CIDXFTHRESHO_F	FW_IQ_CMD_FL1CIDXFTHRESHO_V(1U)
+
+#define FW_IQ_CMD_FL1CIDXFTHRESH_S	0
+#define FW_IQ_CMD_FL1CIDXFTHRESH_V(x)	((x) << FW_IQ_CMD_FL1CIDXFTHRESH_S)
 
 struct fw_eq_eth_cmd {
 	__be32 op_to_vfn;
@@ -1367,40 +1521,102 @@ struct fw_eq_eth_cmd {
 	__be64 r9;
 };
 
-#define FW_EQ_ETH_CMD_PFN(x) ((x) << 8)
-#define FW_EQ_ETH_CMD_VFN(x) ((x) << 0)
-#define FW_EQ_ETH_CMD_ALLOC (1U << 31)
-#define FW_EQ_ETH_CMD_FREE (1U << 30)
-#define FW_EQ_ETH_CMD_MODIFY (1U << 29)
-#define FW_EQ_ETH_CMD_EQSTART (1U << 28)
-#define FW_EQ_ETH_CMD_EQSTOP (1U << 27)
-
-#define FW_EQ_ETH_CMD_EQID(x) ((x) << 0)
-#define FW_EQ_ETH_CMD_EQID_GET(x) (((x) >> 0) & 0xfffff)
-#define FW_EQ_ETH_CMD_PHYSEQID(x) ((x) << 0)
-#define FW_EQ_ETH_CMD_PHYSEQID_GET(x) (((x) >> 0) & 0xfffff)
-
-#define FW_EQ_ETH_CMD_FETCHSZM(x) ((x) << 26)
-#define FW_EQ_ETH_CMD_STATUSPGNS(x) ((x) << 25)
-#define FW_EQ_ETH_CMD_STATUSPGRO(x) ((x) << 24)
-#define FW_EQ_ETH_CMD_FETCHNS(x) ((x) << 23)
-#define FW_EQ_ETH_CMD_FETCHRO(x) ((x) << 22)
-#define FW_EQ_ETH_CMD_HOSTFCMODE(x) ((x) << 20)
-#define FW_EQ_ETH_CMD_CPRIO(x) ((x) << 19)
-#define FW_EQ_ETH_CMD_ONCHIP(x) ((x) << 18)
-#define FW_EQ_ETH_CMD_PCIECHN(x) ((x) << 16)
-#define FW_EQ_ETH_CMD_IQID(x) ((x) << 0)
-
-#define FW_EQ_ETH_CMD_DCAEN(x) ((x) << 31)
-#define FW_EQ_ETH_CMD_DCACPU(x) ((x) << 26)
-#define FW_EQ_ETH_CMD_FBMIN(x) ((x) << 23)
-#define FW_EQ_ETH_CMD_FBMAX(x) ((x) << 20)
-#define FW_EQ_ETH_CMD_CIDXFTHRESHO(x) ((x) << 19)
-#define FW_EQ_ETH_CMD_CIDXFTHRESH(x) ((x) << 16)
-#define FW_EQ_ETH_CMD_EQSIZE(x) ((x) << 0)
-
-#define FW_EQ_ETH_CMD_AUTOEQUEQE (1U << 30)
-#define FW_EQ_ETH_CMD_VIID(x) ((x) << 16)
+#define FW_EQ_ETH_CMD_PFN_S	8
+#define FW_EQ_ETH_CMD_PFN_V(x)	((x) << FW_EQ_ETH_CMD_PFN_S)
+
+#define FW_EQ_ETH_CMD_VFN_S	0
+#define FW_EQ_ETH_CMD_VFN_V(x)	((x) << FW_EQ_ETH_CMD_VFN_S)
+
+#define FW_EQ_ETH_CMD_ALLOC_S		31
+#define FW_EQ_ETH_CMD_ALLOC_V(x)	((x) << FW_EQ_ETH_CMD_ALLOC_S)
+#define FW_EQ_ETH_CMD_ALLOC_F	FW_EQ_ETH_CMD_ALLOC_V(1U)
+
+#define FW_EQ_ETH_CMD_FREE_S	30
+#define FW_EQ_ETH_CMD_FREE_V(x)	((x) << FW_EQ_ETH_CMD_FREE_S)
+#define FW_EQ_ETH_CMD_FREE_F	FW_EQ_ETH_CMD_FREE_V(1U)
+
+#define FW_EQ_ETH_CMD_MODIFY_S		29
+#define FW_EQ_ETH_CMD_MODIFY_V(x)	((x) << FW_EQ_ETH_CMD_MODIFY_S)
+#define FW_EQ_ETH_CMD_MODIFY_F	FW_EQ_ETH_CMD_MODIFY_V(1U)
+
+#define FW_EQ_ETH_CMD_EQSTART_S		28
+#define FW_EQ_ETH_CMD_EQSTART_V(x)	((x) << FW_EQ_ETH_CMD_EQSTART_S)
+#define FW_EQ_ETH_CMD_EQSTART_F	FW_EQ_ETH_CMD_EQSTART_V(1U)
+
+#define FW_EQ_ETH_CMD_EQSTOP_S		27
+#define FW_EQ_ETH_CMD_EQSTOP_V(x)	((x) << FW_EQ_ETH_CMD_EQSTOP_S)
+#define FW_EQ_ETH_CMD_EQSTOP_F	FW_EQ_ETH_CMD_EQSTOP_V(1U)
+
+#define FW_EQ_ETH_CMD_EQID_S	0
+#define FW_EQ_ETH_CMD_EQID_M	0xfffff
+#define FW_EQ_ETH_CMD_EQID_V(x)	((x) << FW_EQ_ETH_CMD_EQID_S)
+#define FW_EQ_ETH_CMD_EQID_G(x)	\
+	(((x) >> FW_EQ_ETH_CMD_EQID_S) & FW_EQ_ETH_CMD_EQID_M)
+
+#define FW_EQ_ETH_CMD_PHYSEQID_S	0
+#define FW_EQ_ETH_CMD_PHYSEQID_M	0xfffff
+#define FW_EQ_ETH_CMD_PHYSEQID_V(x)	((x) << FW_EQ_ETH_CMD_PHYSEQID_S)
+#define FW_EQ_ETH_CMD_PHYSEQID_G(x)	\
+	(((x) >> FW_EQ_ETH_CMD_PHYSEQID_S) & FW_EQ_ETH_CMD_PHYSEQID_M)
+
+#define FW_EQ_ETH_CMD_FETCHSZM_S	26
+#define FW_EQ_ETH_CMD_FETCHSZM_V(x)	((x) << FW_EQ_ETH_CMD_FETCHSZM_S)
+#define FW_EQ_ETH_CMD_FETCHSZM_F	FW_EQ_ETH_CMD_FETCHSZM_V(1U)
+
+#define FW_EQ_ETH_CMD_STATUSPGNS_S	25
+#define FW_EQ_ETH_CMD_STATUSPGNS_V(x)	((x) << FW_EQ_ETH_CMD_STATUSPGNS_S)
+
+#define FW_EQ_ETH_CMD_STATUSPGRO_S	24
+#define FW_EQ_ETH_CMD_STATUSPGRO_V(x)	((x) << FW_EQ_ETH_CMD_STATUSPGRO_S)
+
+#define FW_EQ_ETH_CMD_FETCHNS_S		23
+#define FW_EQ_ETH_CMD_FETCHNS_V(x)	((x) << FW_EQ_ETH_CMD_FETCHNS_S)
+
+#define FW_EQ_ETH_CMD_FETCHRO_S		22
+#define FW_EQ_ETH_CMD_FETCHRO_V(x)	((x) << FW_EQ_ETH_CMD_FETCHRO_S)
+
+#define FW_EQ_ETH_CMD_HOSTFCMODE_S	20
+#define FW_EQ_ETH_CMD_HOSTFCMODE_V(x)	((x) << FW_EQ_ETH_CMD_HOSTFCMODE_S)
+
+#define FW_EQ_ETH_CMD_CPRIO_S		19
+#define FW_EQ_ETH_CMD_CPRIO_V(x)	((x) << FW_EQ_ETH_CMD_CPRIO_S)
+
+#define FW_EQ_ETH_CMD_ONCHIP_S		18
+#define FW_EQ_ETH_CMD_ONCHIP_V(x)	((x) << FW_EQ_ETH_CMD_ONCHIP_S)
+
+#define FW_EQ_ETH_CMD_PCIECHN_S		16
+#define FW_EQ_ETH_CMD_PCIECHN_V(x)	((x) << FW_EQ_ETH_CMD_PCIECHN_S)
+
+#define FW_EQ_ETH_CMD_IQID_S	0
+#define FW_EQ_ETH_CMD_IQID_V(x)	((x) << FW_EQ_ETH_CMD_IQID_S)
+
+#define FW_EQ_ETH_CMD_DCAEN_S		31
+#define FW_EQ_ETH_CMD_DCAEN_V(x)	((x) << FW_EQ_ETH_CMD_DCAEN_S)
+
+#define FW_EQ_ETH_CMD_DCACPU_S		26
+#define FW_EQ_ETH_CMD_DCACPU_V(x)	((x) << FW_EQ_ETH_CMD_DCACPU_S)
+
+#define FW_EQ_ETH_CMD_FBMIN_S		23
+#define FW_EQ_ETH_CMD_FBMIN_V(x)	((x) << FW_EQ_ETH_CMD_FBMIN_S)
+
+#define FW_EQ_ETH_CMD_FBMAX_S		20
+#define FW_EQ_ETH_CMD_FBMAX_V(x)	((x) << FW_EQ_ETH_CMD_FBMAX_S)
+
+#define FW_EQ_ETH_CMD_CIDXFTHRESHO_S	19
+#define FW_EQ_ETH_CMD_CIDXFTHRESHO_V(x)	((x) << FW_EQ_ETH_CMD_CIDXFTHRESHO_S)
+
+#define FW_EQ_ETH_CMD_CIDXFTHRESH_S	16
+#define FW_EQ_ETH_CMD_CIDXFTHRESH_V(x)	((x) << FW_EQ_ETH_CMD_CIDXFTHRESH_S)
+
+#define FW_EQ_ETH_CMD_EQSIZE_S		0
+#define FW_EQ_ETH_CMD_EQSIZE_V(x)	((x) << FW_EQ_ETH_CMD_EQSIZE_S)
+
+#define FW_EQ_ETH_CMD_AUTOEQUEQE_S	30
+#define FW_EQ_ETH_CMD_AUTOEQUEQE_V(x)	((x) << FW_EQ_ETH_CMD_AUTOEQUEQE_S)
+#define FW_EQ_ETH_CMD_AUTOEQUEQE_F	FW_EQ_ETH_CMD_AUTOEQUEQE_V(1U)
+
+#define FW_EQ_ETH_CMD_VIID_S	16
+#define FW_EQ_ETH_CMD_VIID_V(x)	((x) << FW_EQ_ETH_CMD_VIID_S)
 
 struct fw_eq_ctrl_cmd {
 	__be32 op_to_vfn;
@@ -1412,38 +1628,102 @@ struct fw_eq_ctrl_cmd {
 	__be64 eqaddr;
 };
 
-#define FW_EQ_CTRL_CMD_PFN(x) ((x) << 8)
-#define FW_EQ_CTRL_CMD_VFN(x) ((x) << 0)
-
-#define FW_EQ_CTRL_CMD_ALLOC (1U << 31)
-#define FW_EQ_CTRL_CMD_FREE (1U << 30)
-#define FW_EQ_CTRL_CMD_MODIFY (1U << 29)
-#define FW_EQ_CTRL_CMD_EQSTART (1U << 28)
-#define FW_EQ_CTRL_CMD_EQSTOP (1U << 27)
-
-#define FW_EQ_CTRL_CMD_CMPLIQID(x) ((x) << 20)
-#define FW_EQ_CTRL_CMD_EQID(x) ((x) << 0)
-#define FW_EQ_CTRL_CMD_EQID_GET(x) (((x) >> 0) & 0xfffff)
-#define FW_EQ_CTRL_CMD_PHYSEQID_GET(x) (((x) >> 0) & 0xfffff)
-
-#define FW_EQ_CTRL_CMD_FETCHSZM (1U << 26)
-#define FW_EQ_CTRL_CMD_STATUSPGNS (1U << 25)
-#define FW_EQ_CTRL_CMD_STATUSPGRO (1U << 24)
-#define FW_EQ_CTRL_CMD_FETCHNS (1U << 23)
-#define FW_EQ_CTRL_CMD_FETCHRO (1U << 22)
-#define FW_EQ_CTRL_CMD_HOSTFCMODE(x) ((x) << 20)
-#define FW_EQ_CTRL_CMD_CPRIO(x) ((x) << 19)
-#define FW_EQ_CTRL_CMD_ONCHIP(x) ((x) << 18)
-#define FW_EQ_CTRL_CMD_PCIECHN(x) ((x) << 16)
-#define FW_EQ_CTRL_CMD_IQID(x) ((x) << 0)
-
-#define FW_EQ_CTRL_CMD_DCAEN(x) ((x) << 31)
-#define FW_EQ_CTRL_CMD_DCACPU(x) ((x) << 26)
-#define FW_EQ_CTRL_CMD_FBMIN(x) ((x) << 23)
-#define FW_EQ_CTRL_CMD_FBMAX(x) ((x) << 20)
-#define FW_EQ_CTRL_CMD_CIDXFTHRESHO(x) ((x) << 19)
-#define FW_EQ_CTRL_CMD_CIDXFTHRESH(x) ((x) << 16)
-#define FW_EQ_CTRL_CMD_EQSIZE(x) ((x) << 0)
+#define FW_EQ_CTRL_CMD_PFN_S	8
+#define FW_EQ_CTRL_CMD_PFN_V(x)	((x) << FW_EQ_CTRL_CMD_PFN_S)
+
+#define FW_EQ_CTRL_CMD_VFN_S	0
+#define FW_EQ_CTRL_CMD_VFN_V(x)	((x) << FW_EQ_CTRL_CMD_VFN_S)
+
+#define FW_EQ_CTRL_CMD_ALLOC_S		31
+#define FW_EQ_CTRL_CMD_ALLOC_V(x)	((x) << FW_EQ_CTRL_CMD_ALLOC_S)
+#define FW_EQ_CTRL_CMD_ALLOC_F		FW_EQ_CTRL_CMD_ALLOC_V(1U)
+
+#define FW_EQ_CTRL_CMD_FREE_S		30
+#define FW_EQ_CTRL_CMD_FREE_V(x)	((x) << FW_EQ_CTRL_CMD_FREE_S)
+#define FW_EQ_CTRL_CMD_FREE_F		FW_EQ_CTRL_CMD_FREE_V(1U)
+
+#define FW_EQ_CTRL_CMD_MODIFY_S		29
+#define FW_EQ_CTRL_CMD_MODIFY_V(x)	((x) << FW_EQ_CTRL_CMD_MODIFY_S)
+#define FW_EQ_CTRL_CMD_MODIFY_F		FW_EQ_CTRL_CMD_MODIFY_V(1U)
+
+#define FW_EQ_CTRL_CMD_EQSTART_S	28
+#define FW_EQ_CTRL_CMD_EQSTART_V(x)	((x) << FW_EQ_CTRL_CMD_EQSTART_S)
+#define FW_EQ_CTRL_CMD_EQSTART_F	FW_EQ_CTRL_CMD_EQSTART_V(1U)
+
+#define FW_EQ_CTRL_CMD_EQSTOP_S		27
+#define FW_EQ_CTRL_CMD_EQSTOP_V(x)	((x) << FW_EQ_CTRL_CMD_EQSTOP_S)
+#define FW_EQ_CTRL_CMD_EQSTOP_F		FW_EQ_CTRL_CMD_EQSTOP_V(1U)
+
+#define FW_EQ_CTRL_CMD_CMPLIQID_S	20
+#define FW_EQ_CTRL_CMD_CMPLIQID_V(x)	((x) << FW_EQ_CTRL_CMD_CMPLIQID_S)
+
+#define FW_EQ_CTRL_CMD_EQID_S		0
+#define FW_EQ_CTRL_CMD_EQID_M		0xfffff
+#define FW_EQ_CTRL_CMD_EQID_V(x)	((x) << FW_EQ_CTRL_CMD_EQID_S)
+#define FW_EQ_CTRL_CMD_EQID_G(x)	\
+	(((x) >> FW_EQ_CTRL_CMD_EQID_S) & FW_EQ_CTRL_CMD_EQID_M)
+
+#define FW_EQ_CTRL_CMD_PHYSEQID_S	0
+#define FW_EQ_CTRL_CMD_PHYSEQID_M	0xfffff
+#define FW_EQ_CTRL_CMD_PHYSEQID_G(x)	\
+	(((x) >> FW_EQ_CTRL_CMD_PHYSEQID_S) & FW_EQ_CTRL_CMD_PHYSEQID_M)
+
+#define FW_EQ_CTRL_CMD_FETCHSZM_S	26
+#define FW_EQ_CTRL_CMD_FETCHSZM_V(x)	((x) << FW_EQ_CTRL_CMD_FETCHSZM_S)
+#define FW_EQ_CTRL_CMD_FETCHSZM_F	FW_EQ_CTRL_CMD_FETCHSZM_V(1U)
+
+#define FW_EQ_CTRL_CMD_STATUSPGNS_S	25
+#define FW_EQ_CTRL_CMD_STATUSPGNS_V(x)	((x) << FW_EQ_CTRL_CMD_STATUSPGNS_S)
+#define FW_EQ_CTRL_CMD_STATUSPGNS_F	FW_EQ_CTRL_CMD_STATUSPGNS_V(1U)
+
+#define FW_EQ_CTRL_CMD_STATUSPGRO_S	24
+#define FW_EQ_CTRL_CMD_STATUSPGRO_V(x)	((x) << FW_EQ_CTRL_CMD_STATUSPGRO_S)
+#define FW_EQ_CTRL_CMD_STATUSPGRO_F	FW_EQ_CTRL_CMD_STATUSPGRO_V(1U)
+
+#define FW_EQ_CTRL_CMD_FETCHNS_S	23
+#define FW_EQ_CTRL_CMD_FETCHNS_V(x)	((x) << FW_EQ_CTRL_CMD_FETCHNS_S)
+#define FW_EQ_CTRL_CMD_FETCHNS_F	FW_EQ_CTRL_CMD_FETCHNS_V(1U)
+
+#define FW_EQ_CTRL_CMD_FETCHRO_S	22
+#define FW_EQ_CTRL_CMD_FETCHRO_V(x)	((x) << FW_EQ_CTRL_CMD_FETCHRO_S)
+#define FW_EQ_CTRL_CMD_FETCHRO_F	FW_EQ_CTRL_CMD_FETCHRO_V(1U)
+
+#define FW_EQ_CTRL_CMD_HOSTFCMODE_S	20
+#define FW_EQ_CTRL_CMD_HOSTFCMODE_V(x)	((x) << FW_EQ_CTRL_CMD_HOSTFCMODE_S)
+
+#define FW_EQ_CTRL_CMD_CPRIO_S		19
+#define FW_EQ_CTRL_CMD_CPRIO_V(x)	((x) << FW_EQ_CTRL_CMD_CPRIO_S)
+
+#define FW_EQ_CTRL_CMD_ONCHIP_S		18
+#define FW_EQ_CTRL_CMD_ONCHIP_V(x)	((x) << FW_EQ_CTRL_CMD_ONCHIP_S)
+
+#define FW_EQ_CTRL_CMD_PCIECHN_S	16
+#define FW_EQ_CTRL_CMD_PCIECHN_V(x)	((x) << FW_EQ_CTRL_CMD_PCIECHN_S)
+
+#define FW_EQ_CTRL_CMD_IQID_S		0
+#define FW_EQ_CTRL_CMD_IQID_V(x)	((x) << FW_EQ_CTRL_CMD_IQID_S)
+
+#define FW_EQ_CTRL_CMD_DCAEN_S		31
+#define FW_EQ_CTRL_CMD_DCAEN_V(x)	((x) << FW_EQ_CTRL_CMD_DCAEN_S)
+
+#define FW_EQ_CTRL_CMD_DCACPU_S		26
+#define FW_EQ_CTRL_CMD_DCACPU_V(x)	((x) << FW_EQ_CTRL_CMD_DCACPU_S)
+
+#define FW_EQ_CTRL_CMD_FBMIN_S		23
+#define FW_EQ_CTRL_CMD_FBMIN_V(x)	((x) << FW_EQ_CTRL_CMD_FBMIN_S)
+
+#define FW_EQ_CTRL_CMD_FBMAX_S		20
+#define FW_EQ_CTRL_CMD_FBMAX_V(x)	((x) << FW_EQ_CTRL_CMD_FBMAX_S)
+
+#define FW_EQ_CTRL_CMD_CIDXFTHRESHO_S		19
+#define FW_EQ_CTRL_CMD_CIDXFTHRESHO_V(x)	\
+	((x) << FW_EQ_CTRL_CMD_CIDXFTHRESHO_S)
+
+#define FW_EQ_CTRL_CMD_CIDXFTHRESH_S	16
+#define FW_EQ_CTRL_CMD_CIDXFTHRESH_V(x)	((x) << FW_EQ_CTRL_CMD_CIDXFTHRESH_S)
+
+#define FW_EQ_CTRL_CMD_EQSIZE_S		0
+#define FW_EQ_CTRL_CMD_EQSIZE_V(x)	((x) << FW_EQ_CTRL_CMD_EQSIZE_S)
 
 struct fw_eq_ofld_cmd {
 	__be32 op_to_vfn;
@@ -1455,37 +1735,95 @@ struct fw_eq_ofld_cmd {
 	__be64 eqaddr;
 };
 
-#define FW_EQ_OFLD_CMD_PFN(x) ((x) << 8)
-#define FW_EQ_OFLD_CMD_VFN(x) ((x) << 0)
-
-#define FW_EQ_OFLD_CMD_ALLOC (1U << 31)
-#define FW_EQ_OFLD_CMD_FREE (1U << 30)
-#define FW_EQ_OFLD_CMD_MODIFY (1U << 29)
-#define FW_EQ_OFLD_CMD_EQSTART (1U << 28)
-#define FW_EQ_OFLD_CMD_EQSTOP (1U << 27)
-
-#define FW_EQ_OFLD_CMD_EQID(x) ((x) << 0)
-#define FW_EQ_OFLD_CMD_EQID_GET(x) (((x) >> 0) & 0xfffff)
-#define FW_EQ_OFLD_CMD_PHYSEQID_GET(x) (((x) >> 0) & 0xfffff)
-
-#define FW_EQ_OFLD_CMD_FETCHSZM(x) ((x) << 26)
-#define FW_EQ_OFLD_CMD_STATUSPGNS(x) ((x) << 25)
-#define FW_EQ_OFLD_CMD_STATUSPGRO(x) ((x) << 24)
-#define FW_EQ_OFLD_CMD_FETCHNS(x) ((x) << 23)
-#define FW_EQ_OFLD_CMD_FETCHRO(x) ((x) << 22)
-#define FW_EQ_OFLD_CMD_HOSTFCMODE(x) ((x) << 20)
-#define FW_EQ_OFLD_CMD_CPRIO(x) ((x) << 19)
-#define FW_EQ_OFLD_CMD_ONCHIP(x) ((x) << 18)
-#define FW_EQ_OFLD_CMD_PCIECHN(x) ((x) << 16)
-#define FW_EQ_OFLD_CMD_IQID(x) ((x) << 0)
-
-#define FW_EQ_OFLD_CMD_DCAEN(x) ((x) << 31)
-#define FW_EQ_OFLD_CMD_DCACPU(x) ((x) << 26)
-#define FW_EQ_OFLD_CMD_FBMIN(x) ((x) << 23)
-#define FW_EQ_OFLD_CMD_FBMAX(x) ((x) << 20)
-#define FW_EQ_OFLD_CMD_CIDXFTHRESHO(x) ((x) << 19)
-#define FW_EQ_OFLD_CMD_CIDXFTHRESH(x) ((x) << 16)
-#define FW_EQ_OFLD_CMD_EQSIZE(x) ((x) << 0)
+#define FW_EQ_OFLD_CMD_PFN_S	8
+#define FW_EQ_OFLD_CMD_PFN_V(x)	((x) << FW_EQ_OFLD_CMD_PFN_S)
+
+#define FW_EQ_OFLD_CMD_VFN_S	0
+#define FW_EQ_OFLD_CMD_VFN_V(x)	((x) << FW_EQ_OFLD_CMD_VFN_S)
+
+#define FW_EQ_OFLD_CMD_ALLOC_S		31
+#define FW_EQ_OFLD_CMD_ALLOC_V(x)	((x) << FW_EQ_OFLD_CMD_ALLOC_S)
+#define FW_EQ_OFLD_CMD_ALLOC_F		FW_EQ_OFLD_CMD_ALLOC_V(1U)
+
+#define FW_EQ_OFLD_CMD_FREE_S		30
+#define FW_EQ_OFLD_CMD_FREE_V(x)	((x) << FW_EQ_OFLD_CMD_FREE_S)
+#define FW_EQ_OFLD_CMD_FREE_F		FW_EQ_OFLD_CMD_FREE_V(1U)
+
+#define FW_EQ_OFLD_CMD_MODIFY_S		29
+#define FW_EQ_OFLD_CMD_MODIFY_V(x)	((x) << FW_EQ_OFLD_CMD_MODIFY_S)
+#define FW_EQ_OFLD_CMD_MODIFY_F		FW_EQ_OFLD_CMD_MODIFY_V(1U)
+
+#define FW_EQ_OFLD_CMD_EQSTART_S	28
+#define FW_EQ_OFLD_CMD_EQSTART_V(x)	((x) << FW_EQ_OFLD_CMD_EQSTART_S)
+#define FW_EQ_OFLD_CMD_EQSTART_F	FW_EQ_OFLD_CMD_EQSTART_V(1U)
+
+#define FW_EQ_OFLD_CMD_EQSTOP_S		27
+#define FW_EQ_OFLD_CMD_EQSTOP_V(x)	((x) << FW_EQ_OFLD_CMD_EQSTOP_S)
+#define FW_EQ_OFLD_CMD_EQSTOP_F		FW_EQ_OFLD_CMD_EQSTOP_V(1U)
+
+#define FW_EQ_OFLD_CMD_EQID_S		0
+#define FW_EQ_OFLD_CMD_EQID_M		0xfffff
+#define FW_EQ_OFLD_CMD_EQID_V(x)	((x) << FW_EQ_OFLD_CMD_EQID_S)
+#define FW_EQ_OFLD_CMD_EQID_G(x)	\
+	(((x) >> FW_EQ_OFLD_CMD_EQID_S) & FW_EQ_OFLD_CMD_EQID_M)
+
+#define FW_EQ_OFLD_CMD_PHYSEQID_S	0
+#define FW_EQ_OFLD_CMD_PHYSEQID_M	0xfffff
+#define FW_EQ_OFLD_CMD_PHYSEQID_G(x)	\
+	(((x) >> FW_EQ_OFLD_CMD_PHYSEQID_S) & FW_EQ_OFLD_CMD_PHYSEQID_M)
+
+#define FW_EQ_OFLD_CMD_FETCHSZM_S	26
+#define FW_EQ_OFLD_CMD_FETCHSZM_V(x)	((x) << FW_EQ_OFLD_CMD_FETCHSZM_S)
+
+#define FW_EQ_OFLD_CMD_STATUSPGNS_S	25
+#define FW_EQ_OFLD_CMD_STATUSPGNS_V(x)	((x) << FW_EQ_OFLD_CMD_STATUSPGNS_S)
+
+#define FW_EQ_OFLD_CMD_STATUSPGRO_S	24
+#define FW_EQ_OFLD_CMD_STATUSPGRO_V(x)	((x) << FW_EQ_OFLD_CMD_STATUSPGRO_S)
+
+#define FW_EQ_OFLD_CMD_FETCHNS_S	23
+#define FW_EQ_OFLD_CMD_FETCHNS_V(x)	((x) << FW_EQ_OFLD_CMD_FETCHNS_S)
+
+#define FW_EQ_OFLD_CMD_FETCHRO_S	22
+#define FW_EQ_OFLD_CMD_FETCHRO_V(x)	((x) << FW_EQ_OFLD_CMD_FETCHRO_S)
+#define FW_EQ_OFLD_CMD_FETCHRO_F	FW_EQ_OFLD_CMD_FETCHRO_V(1U)
+
+#define FW_EQ_OFLD_CMD_HOSTFCMODE_S	20
+#define FW_EQ_OFLD_CMD_HOSTFCMODE_V(x)	((x) << FW_EQ_OFLD_CMD_HOSTFCMODE_S)
+
+#define FW_EQ_OFLD_CMD_CPRIO_S		19
+#define FW_EQ_OFLD_CMD_CPRIO_V(x)	((x) << FW_EQ_OFLD_CMD_CPRIO_S)
+
+#define FW_EQ_OFLD_CMD_ONCHIP_S		18
+#define FW_EQ_OFLD_CMD_ONCHIP_V(x)	((x) << FW_EQ_OFLD_CMD_ONCHIP_S)
+
+#define FW_EQ_OFLD_CMD_PCIECHN_S	16
+#define FW_EQ_OFLD_CMD_PCIECHN_V(x)	((x) << FW_EQ_OFLD_CMD_PCIECHN_S)
+
+#define FW_EQ_OFLD_CMD_IQID_S		0
+#define FW_EQ_OFLD_CMD_IQID_V(x)	((x) << FW_EQ_OFLD_CMD_IQID_S)
+
+#define FW_EQ_OFLD_CMD_DCAEN_S		31
+#define FW_EQ_OFLD_CMD_DCAEN_V(x)	((x) << FW_EQ_OFLD_CMD_DCAEN_S)
+
+#define FW_EQ_OFLD_CMD_DCACPU_S		26
+#define FW_EQ_OFLD_CMD_DCACPU_V(x)	((x) << FW_EQ_OFLD_CMD_DCACPU_S)
+
+#define FW_EQ_OFLD_CMD_FBMIN_S		23
+#define FW_EQ_OFLD_CMD_FBMIN_V(x)	((x) << FW_EQ_OFLD_CMD_FBMIN_S)
+
+#define FW_EQ_OFLD_CMD_FBMAX_S		20
+#define FW_EQ_OFLD_CMD_FBMAX_V(x)	((x) << FW_EQ_OFLD_CMD_FBMAX_S)
+
+#define FW_EQ_OFLD_CMD_CIDXFTHRESHO_S		19
+#define FW_EQ_OFLD_CMD_CIDXFTHRESHO_V(x)	\
+	((x) << FW_EQ_OFLD_CMD_CIDXFTHRESHO_S)
+
+#define FW_EQ_OFLD_CMD_CIDXFTHRESH_S	16
+#define FW_EQ_OFLD_CMD_CIDXFTHRESH_V(x)	((x) << FW_EQ_OFLD_CMD_CIDXFTHRESH_S)
+
+#define FW_EQ_OFLD_CMD_EQSIZE_S		0
+#define FW_EQ_OFLD_CMD_EQSIZE_V(x)	((x) << FW_EQ_OFLD_CMD_EQSIZE_S)
 
 /*
  * Macros for VIID parsing:
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
index 50b1b34..045301d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
@@ -2092,22 +2092,22 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 				    FW_CMD_REQUEST_F |
 				    FW_CMD_WRITE_F |
 				    FW_CMD_EXEC_F);
-	cmd.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_ALLOC |
-					 FW_IQ_CMD_IQSTART(1) |
+	cmd.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_ALLOC_F |
+					 FW_IQ_CMD_IQSTART_F |
 					 FW_LEN16(cmd));
 	cmd.type_to_iqandstindex =
-		cpu_to_be32(FW_IQ_CMD_TYPE(FW_IQ_TYPE_FL_INT_CAP) |
-			    FW_IQ_CMD_IQASYNCH(iqasynch) |
-			    FW_IQ_CMD_VIID(pi->viid) |
-			    FW_IQ_CMD_IQANDST(iqandst) |
-			    FW_IQ_CMD_IQANUS(1) |
-			    FW_IQ_CMD_IQANUD(SGE_UPDATEDEL_INTR) |
-			    FW_IQ_CMD_IQANDSTINDEX(intr_dest));
+		cpu_to_be32(FW_IQ_CMD_TYPE_V(FW_IQ_TYPE_FL_INT_CAP) |
+			    FW_IQ_CMD_IQASYNCH_V(iqasynch) |
+			    FW_IQ_CMD_VIID_V(pi->viid) |
+			    FW_IQ_CMD_IQANDST_V(iqandst) |
+			    FW_IQ_CMD_IQANUS_V(1) |
+			    FW_IQ_CMD_IQANUD_V(SGE_UPDATEDEL_INTR) |
+			    FW_IQ_CMD_IQANDSTINDEX_V(intr_dest));
 	cmd.iqdroprss_to_iqesize =
-		cpu_to_be16(FW_IQ_CMD_IQPCIECH(pi->port_id) |
-			    FW_IQ_CMD_IQGTSMODE |
-			    FW_IQ_CMD_IQINTCNTTHRESH(rspq->pktcnt_idx) |
-			    FW_IQ_CMD_IQESIZE(ilog2(rspq->iqe_len) - 4));
+		cpu_to_be16(FW_IQ_CMD_IQPCIECH_V(pi->port_id) |
+			    FW_IQ_CMD_IQGTSMODE_F |
+			    FW_IQ_CMD_IQINTCNTTHRESH_V(rspq->pktcnt_idx) |
+			    FW_IQ_CMD_IQESIZE_V(ilog2(rspq->iqe_len) - 4));
 	cmd.iqsize = cpu_to_be16(rspq->size);
 	cmd.iqaddr = cpu_to_be64(rspq->phys_addr);
 
@@ -2141,13 +2141,13 @@ int t4vf_sge_alloc_rxq(struct adapter *adapter, struct sge_rspq *rspq,
 		 */
 		cmd.iqns_to_fl0congen =
 			cpu_to_be32(
-				FW_IQ_CMD_FL0HOSTFCMODE(SGE_HOSTFCMODE_NONE) |
-				FW_IQ_CMD_FL0PACKEN(1) |
-				FW_IQ_CMD_FL0PADEN(1));
+				FW_IQ_CMD_FL0HOSTFCMODE_V(SGE_HOSTFCMODE_NONE) |
+				FW_IQ_CMD_FL0PACKEN_F |
+				FW_IQ_CMD_FL0PADEN_F);
 		cmd.fl0dcaen_to_fl0cidxfthresh =
 			cpu_to_be16(
-				FW_IQ_CMD_FL0FBMIN(SGE_FETCHBURSTMIN_64B) |
-				FW_IQ_CMD_FL0FBMAX(SGE_FETCHBURSTMAX_512B));
+				FW_IQ_CMD_FL0FBMIN_V(SGE_FETCHBURSTMIN_64B) |
+				FW_IQ_CMD_FL0FBMAX_V(SGE_FETCHBURSTMAX_512B));
 		cmd.fl0size = cpu_to_be16(flsz);
 		cmd.fl0addr = cpu_to_be64(fl->addr);
 	}
@@ -2255,20 +2255,21 @@ int t4vf_sge_alloc_eth_txq(struct adapter *adapter, struct sge_eth_txq *txq,
 				    FW_CMD_REQUEST_F |
 				    FW_CMD_WRITE_F |
 				    FW_CMD_EXEC_F);
-	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_ALLOC |
-					 FW_EQ_ETH_CMD_EQSTART |
+	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_ALLOC_F |
+					 FW_EQ_ETH_CMD_EQSTART_F |
 					 FW_LEN16(cmd));
-	cmd.viid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_AUTOEQUEQE |
-				   FW_EQ_ETH_CMD_VIID(pi->viid));
+	cmd.viid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_AUTOEQUEQE_F |
+				   FW_EQ_ETH_CMD_VIID_V(pi->viid));
 	cmd.fetchszm_to_iqid =
-		cpu_to_be32(FW_EQ_ETH_CMD_HOSTFCMODE(SGE_HOSTFCMODE_STPG) |
-			    FW_EQ_ETH_CMD_PCIECHN(pi->port_id) |
-			    FW_EQ_ETH_CMD_IQID(iqid));
+		cpu_to_be32(FW_EQ_ETH_CMD_HOSTFCMODE_V(SGE_HOSTFCMODE_STPG) |
+			    FW_EQ_ETH_CMD_PCIECHN_V(pi->port_id) |
+			    FW_EQ_ETH_CMD_IQID_V(iqid));
 	cmd.dcaen_to_eqsize =
-		cpu_to_be32(FW_EQ_ETH_CMD_FBMIN(SGE_FETCHBURSTMIN_64B) |
-			    FW_EQ_ETH_CMD_FBMAX(SGE_FETCHBURSTMAX_512B) |
-			    FW_EQ_ETH_CMD_CIDXFTHRESH(SGE_CIDXFLUSHTHRESH_32) |
-			    FW_EQ_ETH_CMD_EQSIZE(nentries));
+		cpu_to_be32(FW_EQ_ETH_CMD_FBMIN_V(SGE_FETCHBURSTMIN_64B) |
+			    FW_EQ_ETH_CMD_FBMAX_V(SGE_FETCHBURSTMAX_512B) |
+			    FW_EQ_ETH_CMD_CIDXFTHRESH_V(
+						SGE_CIDXFLUSHTHRESH_32) |
+			    FW_EQ_ETH_CMD_EQSIZE_V(nentries));
 	cmd.eqaddr = cpu_to_be64(txq->q.phys_addr);
 
 	/*
@@ -2294,9 +2295,9 @@ int t4vf_sge_alloc_eth_txq(struct adapter *adapter, struct sge_eth_txq *txq,
 	txq->q.cidx = 0;
 	txq->q.pidx = 0;
 	txq->q.stat = (void *)&txq->q.desc[txq->q.size];
-	txq->q.cntxt_id = FW_EQ_ETH_CMD_EQID_GET(be32_to_cpu(rpl.eqid_pkd));
+	txq->q.cntxt_id = FW_EQ_ETH_CMD_EQID_G(be32_to_cpu(rpl.eqid_pkd));
 	txq->q.abs_id =
-		FW_EQ_ETH_CMD_PHYSEQID_GET(be32_to_cpu(rpl.physeqid_pkd));
+		FW_EQ_ETH_CMD_PHYSEQID_G(be32_to_cpu(rpl.physeqid_pkd));
 	txq->txq = devq;
 	txq->tso = 0;
 	txq->tx_cso = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index f2087eb..5d3bd8d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -1302,10 +1302,10 @@ int t4vf_iq_free(struct adapter *adapter, unsigned int iqtype,
 	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_IQ_CMD) |
 				    FW_CMD_REQUEST_F |
 				    FW_CMD_EXEC_F);
-	cmd.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_FREE |
+	cmd.alloc_to_len16 = cpu_to_be32(FW_IQ_CMD_FREE_F |
 					 FW_LEN16(cmd));
 	cmd.type_to_iqandstindex =
-		cpu_to_be32(FW_IQ_CMD_TYPE(iqtype));
+		cpu_to_be32(FW_IQ_CMD_TYPE_V(iqtype));
 
 	cmd.iqid = cpu_to_be16(iqid);
 	cmd.fl0id = cpu_to_be16(fl0id);
@@ -1328,9 +1328,9 @@ int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
 	cmd.op_to_vfn = cpu_to_be32(FW_CMD_OP_V(FW_EQ_ETH_CMD) |
 				    FW_CMD_REQUEST_F |
 				    FW_CMD_EXEC_F);
-	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_FREE |
+	cmd.alloc_to_len16 = cpu_to_be32(FW_EQ_ETH_CMD_FREE_F |
 					 FW_LEN16(cmd));
-	cmd.eqid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_EQID(eqid));
+	cmd.eqid_pkd = cpu_to_be32(FW_EQ_ETH_CMD_EQID_V(eqid));
 	return t4vf_wr_mbox(adapter, &cmd, sizeof(cmd), NULL);
 }
 
diff --git a/drivers/scsi/csiostor/csio_mb.c b/drivers/scsi/csiostor/csio_mb.c
index a1e0568..5a514b6 100644
--- a/drivers/scsi/csiostor/csio_mb.c
+++ b/drivers/scsi/csiostor/csio_mb.c
@@ -445,16 +445,16 @@ csio_mb_iq_alloc(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD)		|
 				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
-				FW_IQ_CMD_PFN(iq_params->pfn)	|
-				FW_IQ_CMD_VFN(iq_params->vfn));
+				FW_IQ_CMD_PFN_V(iq_params->pfn)	|
+				FW_IQ_CMD_VFN_V(iq_params->vfn));
 
-	cmdp->alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC		|
+	cmdp->alloc_to_len16 = htonl(FW_IQ_CMD_ALLOC_F		|
 				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 	cmdp->type_to_iqandstindex = htonl(
-				FW_IQ_CMD_VIID(iq_params->viid)	|
-				FW_IQ_CMD_TYPE(iq_params->type)	|
-				FW_IQ_CMD_IQASYNCH(iq_params->iqasynch));
+				FW_IQ_CMD_VIID_V(iq_params->viid)	|
+				FW_IQ_CMD_TYPE_V(iq_params->type)	|
+				FW_IQ_CMD_IQASYNCH_V(iq_params->iqasynch));
 
 	cmdp->fl0size = htons(iq_params->fl0size);
 	cmdp->fl0size = htons(iq_params->fl1size);
@@ -488,8 +488,8 @@ csio_mb_iq_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 	struct fw_iq_cmd *cmdp = (struct fw_iq_cmd *)(mbp->mb);
 
 	uint32_t iq_start_stop = (iq_params->iq_start)	?
-					FW_IQ_CMD_IQSTART(1) :
-					FW_IQ_CMD_IQSTOP(1);
+					FW_IQ_CMD_IQSTART_F :
+					FW_IQ_CMD_IQSTOP_F;
 
 	/*
 	 * If this IQ write is cascaded with IQ alloc request, do not
@@ -501,49 +501,49 @@ csio_mb_iq_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	cmdp->op_to_vfn |= htonl(FW_CMD_OP_V(FW_IQ_CMD)		|
 				FW_CMD_REQUEST_F | FW_CMD_WRITE_F	|
-				FW_IQ_CMD_PFN(iq_params->pfn)	|
-				FW_IQ_CMD_VFN(iq_params->vfn));
+				FW_IQ_CMD_PFN_V(iq_params->pfn)	|
+				FW_IQ_CMD_VFN_V(iq_params->vfn));
 	cmdp->alloc_to_len16 |= htonl(iq_start_stop |
 				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 	cmdp->iqid |= htons(iq_params->iqid);
 	cmdp->fl0id |= htons(iq_params->fl0id);
 	cmdp->fl1id |= htons(iq_params->fl1id);
 	cmdp->type_to_iqandstindex |= htonl(
-			FW_IQ_CMD_IQANDST(iq_params->iqandst)	|
-			FW_IQ_CMD_IQANUS(iq_params->iqanus)	|
-			FW_IQ_CMD_IQANUD(iq_params->iqanud)	|
-			FW_IQ_CMD_IQANDSTINDEX(iq_params->iqandstindex));
+			FW_IQ_CMD_IQANDST_V(iq_params->iqandst)	|
+			FW_IQ_CMD_IQANUS_V(iq_params->iqanus)	|
+			FW_IQ_CMD_IQANUD_V(iq_params->iqanud)	|
+			FW_IQ_CMD_IQANDSTINDEX_V(iq_params->iqandstindex));
 	cmdp->iqdroprss_to_iqesize |= htons(
-			FW_IQ_CMD_IQPCIECH(iq_params->iqpciech)		|
-			FW_IQ_CMD_IQDCAEN(iq_params->iqdcaen)		|
-			FW_IQ_CMD_IQDCACPU(iq_params->iqdcacpu)		|
-			FW_IQ_CMD_IQINTCNTTHRESH(iq_params->iqintcntthresh) |
-			FW_IQ_CMD_IQCPRIO(iq_params->iqcprio)		|
-			FW_IQ_CMD_IQESIZE(iq_params->iqesize));
+			FW_IQ_CMD_IQPCIECH_V(iq_params->iqpciech)	|
+			FW_IQ_CMD_IQDCAEN_V(iq_params->iqdcaen)		|
+			FW_IQ_CMD_IQDCACPU_V(iq_params->iqdcacpu)	|
+			FW_IQ_CMD_IQINTCNTTHRESH_V(iq_params->iqintcntthresh) |
+			FW_IQ_CMD_IQCPRIO_V(iq_params->iqcprio)		|
+			FW_IQ_CMD_IQESIZE_V(iq_params->iqesize));
 
 	cmdp->iqsize |= htons(iq_params->iqsize);
 	cmdp->iqaddr |= cpu_to_be64(iq_params->iqaddr);
 
 	if (iq_params->type == 0) {
 		cmdp->iqns_to_fl0congen |= htonl(
-			FW_IQ_CMD_IQFLINTIQHSEN(iq_params->iqflintiqhsen)|
-			FW_IQ_CMD_IQFLINTCONGEN(iq_params->iqflintcongen));
+			FW_IQ_CMD_IQFLINTIQHSEN_V(iq_params->iqflintiqhsen)|
+			FW_IQ_CMD_IQFLINTCONGEN_V(iq_params->iqflintcongen));
 	}
 
 	if (iq_params->fl0size && iq_params->fl0addr &&
 	    (iq_params->fl0id != 0xFFFF)) {
 
 		cmdp->iqns_to_fl0congen |= htonl(
-			FW_IQ_CMD_FL0HOSTFCMODE(iq_params->fl0hostfcmode)|
-			FW_IQ_CMD_FL0CPRIO(iq_params->fl0cprio)		|
-			FW_IQ_CMD_FL0PADEN(iq_params->fl0paden)		|
-			FW_IQ_CMD_FL0PACKEN(iq_params->fl0packen));
+			FW_IQ_CMD_FL0HOSTFCMODE_V(iq_params->fl0hostfcmode)|
+			FW_IQ_CMD_FL0CPRIO_V(iq_params->fl0cprio)	|
+			FW_IQ_CMD_FL0PADEN_V(iq_params->fl0paden)	|
+			FW_IQ_CMD_FL0PACKEN_V(iq_params->fl0packen));
 		cmdp->fl0dcaen_to_fl0cidxfthresh |= htons(
-			FW_IQ_CMD_FL0DCAEN(iq_params->fl0dcaen)		|
-			FW_IQ_CMD_FL0DCACPU(iq_params->fl0dcacpu)	|
-			FW_IQ_CMD_FL0FBMIN(iq_params->fl0fbmin)		|
-			FW_IQ_CMD_FL0FBMAX(iq_params->fl0fbmax)		|
-			FW_IQ_CMD_FL0CIDXFTHRESH(iq_params->fl0cidxfthresh));
+			FW_IQ_CMD_FL0DCAEN_V(iq_params->fl0dcaen)	|
+			FW_IQ_CMD_FL0DCACPU_V(iq_params->fl0dcacpu)	|
+			FW_IQ_CMD_FL0FBMIN_V(iq_params->fl0fbmin)	|
+			FW_IQ_CMD_FL0FBMAX_V(iq_params->fl0fbmax)	|
+			FW_IQ_CMD_FL0CIDXFTHRESH_V(iq_params->fl0cidxfthresh));
 		cmdp->fl0size |= htons(iq_params->fl0size);
 		cmdp->fl0addr |= cpu_to_be64(iq_params->fl0addr);
 	}
@@ -624,11 +624,11 @@ csio_mb_iq_free(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_IQ_CMD)		|
 				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
-				FW_IQ_CMD_PFN(iq_params->pfn)	|
-				FW_IQ_CMD_VFN(iq_params->vfn));
-	cmdp->alloc_to_len16 = htonl(FW_IQ_CMD_FREE		|
+				FW_IQ_CMD_PFN_V(iq_params->pfn)	|
+				FW_IQ_CMD_VFN_V(iq_params->vfn));
+	cmdp->alloc_to_len16 = htonl(FW_IQ_CMD_FREE_F		|
 				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
-	cmdp->type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE(iq_params->type));
+	cmdp->type_to_iqandstindex = htonl(FW_IQ_CMD_TYPE_V(iq_params->type));
 
 	cmdp->iqid = htons(iq_params->iqid);
 	cmdp->fl0id = htons(iq_params->fl0id);
@@ -659,9 +659,9 @@ csio_mb_eq_ofld_alloc(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 	CSIO_INIT_MBP(mbp, cmdp, mb_tmo, priv, cbfn, 1);
 	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD)		|
 				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
-				FW_EQ_OFLD_CMD_PFN(eq_ofld_params->pfn) |
-				FW_EQ_OFLD_CMD_VFN(eq_ofld_params->vfn));
-	cmdp->alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC	|
+				FW_EQ_OFLD_CMD_PFN_V(eq_ofld_params->pfn) |
+				FW_EQ_OFLD_CMD_VFN_V(eq_ofld_params->vfn));
+	cmdp->alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_ALLOC_F	|
 				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
 } /* csio_mb_eq_ofld_alloc */
@@ -694,7 +694,8 @@ csio_mb_eq_ofld_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 	struct fw_eq_ofld_cmd *cmdp = (struct fw_eq_ofld_cmd *)(mbp->mb);
 
 	uint32_t eq_start_stop = (eq_ofld_params->eqstart)	?
-				FW_EQ_OFLD_CMD_EQSTART	: FW_EQ_OFLD_CMD_EQSTOP;
+				FW_EQ_OFLD_CMD_EQSTART_F :
+				FW_EQ_OFLD_CMD_EQSTOP_F;
 
 	/*
 	 * If this EQ write is cascaded with EQ alloc request, do not
@@ -706,27 +707,27 @@ csio_mb_eq_ofld_write(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	cmdp->op_to_vfn |= htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD)	|
 				FW_CMD_REQUEST_F | FW_CMD_WRITE_F	|
-				FW_EQ_OFLD_CMD_PFN(eq_ofld_params->pfn) |
-				FW_EQ_OFLD_CMD_VFN(eq_ofld_params->vfn));
+				FW_EQ_OFLD_CMD_PFN_V(eq_ofld_params->pfn) |
+				FW_EQ_OFLD_CMD_VFN_V(eq_ofld_params->vfn));
 	cmdp->alloc_to_len16 |= htonl(eq_start_stop		|
 				      FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
 
-	cmdp->eqid_pkd |= htonl(FW_EQ_OFLD_CMD_EQID(eq_ofld_params->eqid));
+	cmdp->eqid_pkd |= htonl(FW_EQ_OFLD_CMD_EQID_V(eq_ofld_params->eqid));
 
 	cmdp->fetchszm_to_iqid |= htonl(
-		FW_EQ_OFLD_CMD_HOSTFCMODE(eq_ofld_params->hostfcmode)	|
-		FW_EQ_OFLD_CMD_CPRIO(eq_ofld_params->cprio)		|
-		FW_EQ_OFLD_CMD_PCIECHN(eq_ofld_params->pciechn)		|
-		FW_EQ_OFLD_CMD_IQID(eq_ofld_params->iqid));
+		FW_EQ_OFLD_CMD_HOSTFCMODE_V(eq_ofld_params->hostfcmode)	|
+		FW_EQ_OFLD_CMD_CPRIO_V(eq_ofld_params->cprio)		|
+		FW_EQ_OFLD_CMD_PCIECHN_V(eq_ofld_params->pciechn)	|
+		FW_EQ_OFLD_CMD_IQID_V(eq_ofld_params->iqid));
 
 	cmdp->dcaen_to_eqsize |= htonl(
-		FW_EQ_OFLD_CMD_DCAEN(eq_ofld_params->dcaen)		|
-		FW_EQ_OFLD_CMD_DCACPU(eq_ofld_params->dcacpu)		|
-		FW_EQ_OFLD_CMD_FBMIN(eq_ofld_params->fbmin)		|
-		FW_EQ_OFLD_CMD_FBMAX(eq_ofld_params->fbmax)		|
-		FW_EQ_OFLD_CMD_CIDXFTHRESHO(eq_ofld_params->cidxfthresho) |
-		FW_EQ_OFLD_CMD_CIDXFTHRESH(eq_ofld_params->cidxfthresh) |
-		FW_EQ_OFLD_CMD_EQSIZE(eq_ofld_params->eqsize));
+		FW_EQ_OFLD_CMD_DCAEN_V(eq_ofld_params->dcaen)		|
+		FW_EQ_OFLD_CMD_DCACPU_V(eq_ofld_params->dcacpu)		|
+		FW_EQ_OFLD_CMD_FBMIN_V(eq_ofld_params->fbmin)		|
+		FW_EQ_OFLD_CMD_FBMAX_V(eq_ofld_params->fbmax)		|
+		FW_EQ_OFLD_CMD_CIDXFTHRESHO_V(eq_ofld_params->cidxfthresho) |
+		FW_EQ_OFLD_CMD_CIDXFTHRESH_V(eq_ofld_params->cidxfthresh) |
+		FW_EQ_OFLD_CMD_EQSIZE_V(eq_ofld_params->eqsize));
 
 	cmdp->eqaddr |= cpu_to_be64(eq_ofld_params->eqaddr);
 
@@ -776,9 +777,9 @@ csio_mb_eq_ofld_alloc_write_rsp(struct csio_hw *hw,
 	*ret_val = FW_CMD_RETVAL_G(ntohl(rsp->alloc_to_len16));
 
 	if (*ret_val == FW_SUCCESS) {
-		eq_ofld_params->eqid = FW_EQ_OFLD_CMD_EQID_GET(
+		eq_ofld_params->eqid = FW_EQ_OFLD_CMD_EQID_G(
 						ntohl(rsp->eqid_pkd));
-		eq_ofld_params->physeqid = FW_EQ_OFLD_CMD_PHYSEQID_GET(
+		eq_ofld_params->physeqid = FW_EQ_OFLD_CMD_PHYSEQID_G(
 						ntohl(rsp->physeqid_pkd));
 	} else
 		eq_ofld_params->eqid = 0;
@@ -809,11 +810,11 @@ csio_mb_eq_ofld_free(struct csio_hw *hw, struct csio_mb *mbp, void *priv,
 
 	cmdp->op_to_vfn = htonl(FW_CMD_OP_V(FW_EQ_OFLD_CMD)	|
 				FW_CMD_REQUEST_F | FW_CMD_EXEC_F	|
-				FW_EQ_OFLD_CMD_PFN(eq_ofld_params->pfn) |
-				FW_EQ_OFLD_CMD_VFN(eq_ofld_params->vfn));
-	cmdp->alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_FREE |
+				FW_EQ_OFLD_CMD_PFN_V(eq_ofld_params->pfn) |
+				FW_EQ_OFLD_CMD_VFN_V(eq_ofld_params->vfn));
+	cmdp->alloc_to_len16 = htonl(FW_EQ_OFLD_CMD_FREE_F |
 				FW_CMD_LEN16_V(sizeof(*cmdp) / 16));
-	cmdp->eqid_pkd = htonl(FW_EQ_OFLD_CMD_EQID(eq_ofld_params->eqid));
+	cmdp->eqid_pkd = htonl(FW_EQ_OFLD_CMD_EQID_V(eq_ofld_params->eqid));
 
 } /* csio_mb_eq_ofld_free */
 
-- 
1.7.1
