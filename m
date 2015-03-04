From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4: Try and provide an RDMA CIQ per cpu
Date: Wed,  4 Mar 2015 18:16:28 +0530
Message-ID: <1425473188-13346-3-git-send-email-hariprasad@chelsio.com>
References: <1425473188-13346-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	swise@opengridcomputing.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31901 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759204AbbCDMlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 07:41:04 -0500
In-Reply-To: <1425473188-13346-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To allow for better scalability on systems with large core counts, we
will try and allocate enough RDMA Concentrator IQs and MSI/X vectors as
we have cores. If we cannot get enough MSI/X vectors, fall back to the
minimum required: 1 per adapter rx channel.

Also clean up cxgb_enable_msix() to make it readable and correct a bug
where the vectors are not correctly assigned if the driver doesn't get
the full amount requested.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    6 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |    4 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   53 ++++++++++++++-----
 3 files changed, 46 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index d6cda17..6e7eac1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -369,7 +369,7 @@ enum {
 	MAX_OFLD_QSETS = 16,          /* # of offload Tx/Rx queue sets */
 	MAX_CTRL_QUEUES = NCHAN,      /* # of control Tx queues */
 	MAX_RDMA_QUEUES = NCHAN,      /* # of streaming RDMA Rx queues */
-	MAX_RDMA_CIQS = NCHAN,        /* # of  RDMA concentrator IQs */
+	MAX_RDMA_CIQS = 32,        /* # of  RDMA concentrator IQs */
 	MAX_ISCSI_QUEUES = NCHAN,     /* # of streaming iSCSI Rx queues */
 };
 
@@ -599,8 +599,8 @@ struct sge {
 	u16 rdmaqs;                 /* # of available RDMA Rx queues */
 	u16 rdmaciqs;               /* # of available RDMA concentrator IQs */
 	u16 ofld_rxq[MAX_OFLD_QSETS];
-	u16 rdma_rxq[NCHAN];
-	u16 rdma_ciq[NCHAN];
+	u16 rdma_rxq[MAX_RDMA_QUEUES];
+	u16 rdma_ciq[MAX_RDMA_CIQS];
 	u16 timer_val[SGE_NTIMERS];
 	u8 counter_val[SGE_NCOUNTERS];
 	u32 fl_pg_order;            /* large page allocation size */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 78854ce..0918c16 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1769,6 +1769,8 @@ do { \
 		int n = min(4, adap->sge.rdmaqs - 4 * rdma_idx);
 
 		S("QType:", "RDMA-CPL");
+		S("Interface:",
+		  rx[i].rspq.netdev ? rx[i].rspq.netdev->name : "N/A");
 		R("RspQ ID:", rspq.abs_id);
 		R("RspQ size:", rspq.size);
 		R("RspQE size:", rspq.iqe_len);
@@ -1788,6 +1790,8 @@ do { \
 		int n = min(4, adap->sge.rdmaciqs - 4 * ciq_idx);
 
 		S("QType:", "RDMA-CIQ");
+		S("Interface:",
+		  rx[i].rspq.netdev ? rx[i].rspq.netdev->name : "N/A");
 		R("RspQ ID:", rspq.abs_id);
 		R("RspQ size:", rspq.size);
 		R("RspQE size:", rspq.iqe_len);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 836e411..e344bdc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1057,7 +1057,8 @@ freeout:	t4_free_sge_resources(adap);
 
 	ALLOC_OFLD_RXQS(s->ofldrxq, s->ofldqsets, j, s->ofld_rxq);
 	ALLOC_OFLD_RXQS(s->rdmarxq, s->rdmaqs, 1, s->rdma_rxq);
-	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, 1, s->rdma_ciq);
+	j = s->rdmaciqs / adap->params.nports; /* rdmaq queues per channel */
+	ALLOC_OFLD_RXQS(s->rdmaciq, s->rdmaciqs, j, s->rdma_ciq);
 
 #undef ALLOC_OFLD_RXQS
 
@@ -5702,7 +5703,16 @@ static void cfg_queues(struct adapter *adap)
 			s->ofldqsets = adap->params.nports;
 		/* For RDMA one Rx queue per channel suffices */
 		s->rdmaqs = adap->params.nports;
-		s->rdmaciqs = adap->params.nports;
+		/* Try and allow at least 1 CIQ per cpu rounding down
+		 * to the number of ports, with a minimum of 1 per port.
+		 * A 2 port card in a 6 cpu system: 6 CIQs, 3 / port.
+		 * A 4 port card in a 6 cpu system: 4 CIQs, 1 / port.
+		 * A 4 port card in a 2 cpu system: 4 CIQs, 1 / port.
+		 */
+		s->rdmaciqs = min_t(int, MAX_RDMA_CIQS, num_online_cpus());
+		s->rdmaciqs = (s->rdmaciqs / adap->params.nports) *
+				adap->params.nports;
+		s->rdmaciqs = max_t(int, s->rdmaciqs, adap->params.nports);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(s->ethrxq); i++) {
@@ -5788,12 +5798,17 @@ static void reduce_ethqs(struct adapter *adap, int n)
 static int enable_msix(struct adapter *adap)
 {
 	int ofld_need = 0;
-	int i, want, need;
+	int i, want, need, allocated;
 	struct sge *s = &adap->sge;
 	unsigned int nchan = adap->params.nports;
-	struct msix_entry entries[MAX_INGQ + 1];
+	struct msix_entry *entries;
+
+	entries = kmalloc(sizeof(*entries) * (MAX_INGQ + 1),
+			  GFP_KERNEL);
+	if (!entries)
+		return -ENOMEM;
 
-	for (i = 0; i < ARRAY_SIZE(entries); ++i)
+	for (i = 0; i < MAX_INGQ + 1; ++i)
 		entries[i].entry = i;
 
 	want = s->max_ethqsets + EXTRA_VECS;
@@ -5810,29 +5825,39 @@ static int enable_msix(struct adapter *adap)
 #else
 	need = adap->params.nports + EXTRA_VECS + ofld_need;
 #endif
-	want = pci_enable_msix_range(adap->pdev, entries, need, want);
-	if (want < 0)
-		return want;
+	allocated = pci_enable_msix_range(adap->pdev, entries, need, want);
+	if (allocated < 0) {
+		dev_info(adap->pdev_dev, "not enough MSI-X vectors left,"
+			 " not using MSI-X\n");
+		kfree(entries);
+		return allocated;
+	}
 
-	/*
-	 * Distribute available vectors to the various queue groups.
+	/* Distribute available vectors to the various queue groups.
 	 * Every group gets its minimum requirement and NIC gets top
 	 * priority for leftovers.
 	 */
-	i = want - EXTRA_VECS - ofld_need;
+	i = allocated - EXTRA_VECS - ofld_need;
 	if (i < s->max_ethqsets) {
 		s->max_ethqsets = i;
 		if (i < s->ethqsets)
 			reduce_ethqs(adap, i);
 	}
 	if (is_offload(adap)) {
-		i = want - EXTRA_VECS - s->max_ethqsets;
-		i -= ofld_need - nchan;
+		if (allocated < want) {
+			s->rdmaqs = nchan;
+			s->rdmaciqs = nchan;
+		}
+
+		/* leftovers go to OFLD */
+		i = allocated - EXTRA_VECS - s->max_ethqsets -
+		    s->rdmaqs - s->rdmaciqs;
 		s->ofldqsets = (i / nchan) * nchan;  /* round down */
 	}
-	for (i = 0; i < want; ++i)
+	for (i = 0; i < allocated; ++i)
 		adap->msix_info[i].vec = entries[i].vector;
 
+	kfree(entries);
 	return 0;
 }
 
-- 
1.7.1
