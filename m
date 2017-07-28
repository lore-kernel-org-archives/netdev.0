From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 10/10] net/smc: synchronize buffer usage with device
Date: Fri, 28 Jul 2017 13:56:22 +0200
Message-ID: <20170728115622.17247-11-ubraun@linux.vnet.ibm.com>
References: <20170728115622.17247-1-ubraun@linux.vnet.ibm.com>
Cc: hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:57602 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751973AbdG1L4q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 07:56:46 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6SBtW4h034532
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:56:46 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c0466j9s7-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:56:45 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 28 Jul 2017 12:56:43 +0100
In-Reply-To: <20170728115622.17247-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Usage of send buffer "sndbuf" is synced
(a) before filling sndbuf for cpu access
(b) after filling sndbuf for device access

Usage of receive buffer "RMB" is synced
(a) before reading RMB content for cpu access
(b) after reading RMB content for device access

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/af_smc.c   |  2 ++
 net/smc/smc_core.c | 32 ++++++++++++++++++++++++++++++++
 net/smc/smc_core.h |  4 ++++
 net/smc/smc_ib.c   | 41 +++++++++++++++++++++++++++++++++++++++++
 net/smc/smc_ib.h   |  6 ++++++
 net/smc/smc_rx.c   |  3 +++
 net/smc/smc_tx.c   |  3 +++
 7 files changed, 91 insertions(+)

diff --git a/net/smc/af_smc.c b/net/smc/af_smc.c
index 75518879b68a..8c6d24b2995d 100644
--- a/net/smc/af_smc.c
+++ b/net/smc/af_smc.c
@@ -474,6 +474,7 @@ static int smc_connect_rdma(struct smc_sock *smc)
 			}
 		}
 	}
+	smc_rmb_sync_sg_for_device(&smc->conn);
 
 	rc = smc_clc_send_confirm(smc);
 	if (rc)
@@ -832,6 +833,7 @@ static void smc_listen_work(struct work_struct *work)
 			}
 		}
 	}
+	smc_rmb_sync_sg_for_device(&new_smc->conn);
 
 	rc = smc_clc_send_accept(new_smc, local_contact);
 	if (rc)
diff --git a/net/smc/smc_core.c b/net/smc/smc_core.c
index 447bd52da0e2..1a16d51e2330 100644
--- a/net/smc/smc_core.c
+++ b/net/smc/smc_core.c
@@ -615,6 +615,38 @@ static int __smc_buf_create(struct smc_sock *smc, bool is_rmb)
 	return 0;
 }
 
+void smc_sndbuf_sync_sg_for_cpu(struct smc_connection *conn)
+{
+	struct smc_link_group *lgr = conn->lgr;
+
+	smc_ib_sync_sg_for_cpu(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+			       conn->sndbuf_desc, DMA_TO_DEVICE);
+}
+
+void smc_sndbuf_sync_sg_for_device(struct smc_connection *conn)
+{
+	struct smc_link_group *lgr = conn->lgr;
+
+	smc_ib_sync_sg_for_device(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+				  conn->sndbuf_desc, DMA_TO_DEVICE);
+}
+
+void smc_rmb_sync_sg_for_cpu(struct smc_connection *conn)
+{
+	struct smc_link_group *lgr = conn->lgr;
+
+	smc_ib_sync_sg_for_cpu(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+			       conn->rmb_desc, DMA_FROM_DEVICE);
+}
+
+void smc_rmb_sync_sg_for_device(struct smc_connection *conn)
+{
+	struct smc_link_group *lgr = conn->lgr;
+
+	smc_ib_sync_sg_for_device(lgr->lnk[SMC_SINGLE_LINK].smcibdev,
+				  conn->rmb_desc, DMA_FROM_DEVICE);
+}
+
 /* create the send and receive buffer for an SMC socket;
  * receive buffers are called RMBs;
  * (even though the SMC protocol allows more than one RMB-element per RMB,
diff --git a/net/smc/smc_core.h b/net/smc/smc_core.h
index 1d713e8e067c..19c44bf4e391 100644
--- a/net/smc/smc_core.h
+++ b/net/smc/smc_core.h
@@ -189,4 +189,8 @@ void smc_lgr_terminate(struct smc_link_group *lgr);
 int smc_buf_create(struct smc_sock *smc);
 int smc_rmb_rtoken_handling(struct smc_connection *conn,
 			    struct smc_clc_msg_accept_confirm *clc);
+void smc_sndbuf_sync_sg_for_cpu(struct smc_connection *conn);
+void smc_sndbuf_sync_sg_for_device(struct smc_connection *conn);
+void smc_rmb_sync_sg_for_cpu(struct smc_connection *conn);
+void smc_rmb_sync_sg_for_device(struct smc_connection *conn);
 #endif
diff --git a/net/smc/smc_ib.c b/net/smc/smc_ib.c
index 021f061609f5..547e0e113b17 100644
--- a/net/smc/smc_ib.c
+++ b/net/smc/smc_ib.c
@@ -13,6 +13,7 @@
 
 #include <linux/random.h>
 #include <linux/workqueue.h>
+#include <linux/scatterlist.h>
 #include <rdma/ib_verbs.h>
 
 #include "smc_pnet.h"
@@ -295,6 +296,46 @@ int smc_ib_get_memory_region(struct ib_pd *pd, int access_flags,
 	return 0;
 }
 
+/* synchronize buffer usage for cpu access */
+void smc_ib_sync_sg_for_cpu(struct smc_ib_device *smcibdev,
+			    struct smc_buf_desc *buf_slot,
+			    enum dma_data_direction data_direction)
+{
+	struct scatterlist *sg;
+	unsigned int i;
+
+	/* for now there is just one DMA address */
+	for_each_sg(buf_slot->sgt[SMC_SINGLE_LINK].sgl, sg,
+		    buf_slot->sgt[SMC_SINGLE_LINK].nents, i) {
+		if (!sg_dma_len(sg))
+			break;
+		ib_dma_sync_single_for_cpu(smcibdev->ibdev,
+					   sg_dma_address(sg),
+					   sg_dma_len(sg),
+					   data_direction);
+	}
+}
+
+/* synchronize buffer usage for device access */
+void smc_ib_sync_sg_for_device(struct smc_ib_device *smcibdev,
+			       struct smc_buf_desc *buf_slot,
+			       enum dma_data_direction data_direction)
+{
+	struct scatterlist *sg;
+	unsigned int i;
+
+	/* for now there is just one DMA address */
+	for_each_sg(buf_slot->sgt[SMC_SINGLE_LINK].sgl, sg,
+		    buf_slot->sgt[SMC_SINGLE_LINK].nents, i) {
+		if (!sg_dma_len(sg))
+			break;
+		ib_dma_sync_single_for_device(smcibdev->ibdev,
+					      sg_dma_address(sg),
+					      sg_dma_len(sg),
+					      data_direction);
+	}
+}
+
 /* Map a new TX or RX buffer SG-table to DMA */
 int smc_ib_buf_map_sg(struct smc_ib_device *smcibdev,
 		      struct smc_buf_desc *buf_slot,
diff --git a/net/smc/smc_ib.h b/net/smc/smc_ib.h
index 72acb19ffc67..9b927a33d5e6 100644
--- a/net/smc/smc_ib.h
+++ b/net/smc/smc_ib.h
@@ -68,4 +68,10 @@ long smc_ib_setup_per_ibdev(struct smc_ib_device *smcibdev);
 int smc_ib_get_memory_region(struct ib_pd *pd, int access_flags,
 			     struct smc_buf_desc *buf_slot);
 void smc_ib_put_memory_region(struct ib_mr *mr);
+void smc_ib_sync_sg_for_cpu(struct smc_ib_device *smcibdev,
+			    struct smc_buf_desc *buf_slot,
+			    enum dma_data_direction data_direction);
+void smc_ib_sync_sg_for_device(struct smc_ib_device *smcibdev,
+			       struct smc_buf_desc *buf_slot,
+			       enum dma_data_direction data_direction);
 #endif
diff --git a/net/smc/smc_rx.c b/net/smc/smc_rx.c
index f0c8b089f770..b17a333e9bb0 100644
--- a/net/smc/smc_rx.c
+++ b/net/smc/smc_rx.c
@@ -170,6 +170,7 @@ int smc_rx_recvmsg(struct smc_sock *smc, struct msghdr *msg, size_t len,
 				  copylen, conn->rmbe_size - cons.count);
 		chunk_len_sum = chunk_len;
 		chunk_off = cons.count;
+		smc_rmb_sync_sg_for_cpu(conn);
 		for (chunk = 0; chunk < 2; chunk++) {
 			if (!(flags & MSG_TRUNC)) {
 				rc = memcpy_to_msg(msg, rcvbuf_base + chunk_off,
@@ -177,6 +178,7 @@ int smc_rx_recvmsg(struct smc_sock *smc, struct msghdr *msg, size_t len,
 				if (rc) {
 					if (!read_done)
 						read_done = -EFAULT;
+					smc_rmb_sync_sg_for_device(conn);
 					goto out;
 				}
 			}
@@ -190,6 +192,7 @@ int smc_rx_recvmsg(struct smc_sock *smc, struct msghdr *msg, size_t len,
 			chunk_len_sum += chunk_len;
 			chunk_off = 0; /* modulo offset in recv ring buffer */
 		}
+		smc_rmb_sync_sg_for_device(conn);
 
 		/* update cursors */
 		if (!(flags & MSG_PEEK)) {
diff --git a/net/smc/smc_tx.c b/net/smc/smc_tx.c
index f4d58e2dd559..3c656beb8820 100644
--- a/net/smc/smc_tx.c
+++ b/net/smc/smc_tx.c
@@ -174,10 +174,12 @@ int smc_tx_sendmsg(struct smc_sock *smc, struct msghdr *msg, size_t len)
 				  copylen, conn->sndbuf_size - tx_cnt_prep);
 		chunk_len_sum = chunk_len;
 		chunk_off = tx_cnt_prep;
+		smc_sndbuf_sync_sg_for_cpu(conn);
 		for (chunk = 0; chunk < 2; chunk++) {
 			rc = memcpy_from_msg(sndbuf_base + chunk_off,
 					     msg, chunk_len);
 			if (rc) {
+				smc_sndbuf_sync_sg_for_device(conn);
 				if (send_done)
 					return send_done;
 				goto out_err;
@@ -192,6 +194,7 @@ int smc_tx_sendmsg(struct smc_sock *smc, struct msghdr *msg, size_t len)
 			chunk_len_sum += chunk_len;
 			chunk_off = 0; /* modulo offset in send ring buffer */
 		}
+		smc_sndbuf_sync_sg_for_device(conn);
 		/* update cursors */
 		smc_curs_add(conn->sndbuf_size, &prep, copylen);
 		smc_curs_write(&conn->tx_curs_prep,
-- 
2.11.2
