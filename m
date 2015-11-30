From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 09/13] net: thunderx: HW TSO support for pass2 silicon
Date: Mon, 30 Nov 2015 23:49:05 +0530
Message-ID: <1448907549-5296-10-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Added support to offload TSO to HW for ThunderX pass2 chips.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h          |   12 ++++++--
 drivers/net/ethernet/cavium/thunder/nic_main.c     |   11 ++-----
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |    3 ++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |   19 ++++++++----
 drivers/net/ethernet/cavium/thunder/q_struct.h     |   30 ++++++++++---------
 5 files changed, 44 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 39ca674..02571f4 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -262,9 +262,10 @@ struct nicvf {
 	struct pci_dev		*pdev;
 	u8			vf_id;
 	u8			node;
-	u8			tns_mode:1;
-	u8			sqs_mode:1;
-	u8			loopback_supported:1;
+	bool			tns_mode:1;
+	bool			sqs_mode:1;
+	bool			loopback_supported:1;
+	bool			hw_tso:1;
 	u16			mtu;
 	struct queue_set	*qs;
 #define	MAX_SQS_PER_VF_SINGLE_NODE		5
@@ -489,6 +490,11 @@ static inline int nic_get_node_id(struct pci_dev *pdev)
 	return ((addr >> NIC_NODE_ID_SHIFT) & NIC_NODE_ID_MASK);
 }
 
+static inline bool pass1_silicon(struct pci_dev *pdev)
+{
+	return pdev->revision < 8;
+}
+
 int nicvf_set_real_num_queues(struct net_device *netdev,
 			      int tx_queues, int rx_queues);
 int nicvf_open(struct net_device *netdev);
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 4b7fd63..9f80de4 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -55,11 +55,6 @@ struct nicpf {
 	bool			irq_allocated[NIC_PF_MSIX_VECTORS];
 };
 
-static inline bool pass1_silicon(struct nicpf *nic)
-{
-	return nic->pdev->revision < 8;
-}
-
 /* Supported devices */
 static const struct pci_device_id nic_id_table[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_CAVIUM, PCI_DEVICE_ID_THUNDER_NIC_PF) },
@@ -123,7 +118,7 @@ static void nic_send_msg_to_vf(struct nicpf *nic, int vf, union nic_mbx *mbx)
 	 * when PF writes to MBOX(1), in next revisions when
 	 * PF writes to MBOX(0)
 	 */
-	if (pass1_silicon(nic)) {
+	if (pass1_silicon(nic->pdev)) {
 		/* see the comment for nic_reg_write()/nic_reg_read()
 		 * functions above
 		 */
@@ -400,7 +395,7 @@ static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 			padd = cpi % 8; /* 3 bits CS out of 6bits DSCP */
 
 		/* Leave RSS_SIZE as '0' to disable RSS */
-		if (pass1_silicon(nic)) {
+		if (pass1_silicon(nic->pdev)) {
 			nic_reg_write(nic, NIC_PF_CPI_0_2047_CFG | (cpi << 3),
 				      (vnic << 24) | (padd << 16) |
 				      (rssi_base + rssi));
@@ -470,7 +465,7 @@ static void nic_config_rss(struct nicpf *nic, struct rss_cfg_msg *cfg)
 	}
 
 	cpi_base = nic->cpi_base[cfg->vf_id];
-	if (pass1_silicon(nic))
+	if (pass1_silicon(nic->pdev))
 		idx_addr = NIC_PF_CPI_0_2047_CFG;
 	else
 		idx_addr = NIC_PF_MPI_0_2047_CFG;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index dde8dc7..df07bd7 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1549,6 +1549,9 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 
+	if (!pass1_silicon(nic->pdev))
+		nic->hw_tso = true;
+
 	netdev->netdev_ops = &nicvf_netdev_ops;
 	netdev->watchdog_timeo = NICVF_TX_TIMEOUT;
 
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 1fbd908..209e495 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -925,7 +925,7 @@ static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
 {
 	int subdesc_cnt = MIN_SQ_DESC_PER_PKT_XMIT;
 
-	if (skb_shinfo(skb)->gso_size) {
+	if (skb_shinfo(skb)->gso_size && !nic->hw_tso) {
 		subdesc_cnt = nicvf_tso_count_subdescs(skb);
 		return subdesc_cnt;
 	}
@@ -940,8 +940,8 @@ static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
  * First subdescriptor for every send descriptor.
  */
 static inline void
-nicvf_sq_add_hdr_subdesc(struct snd_queue *sq, int qentry,
-			 int subdesc_cnt, struct sk_buff *skb, int len)
+nicvf_sq_add_hdr_subdesc(struct snd_queue *sq, int qentry, int subdesc_cnt,
+			 struct sk_buff *skb, int len, bool hw_tso)
 {
 	int proto;
 	struct sq_hdr_subdesc *hdr;
@@ -976,6 +976,12 @@ nicvf_sq_add_hdr_subdesc(struct snd_queue *sq, int qentry,
 			break;
 		}
 	}
+
+	if (hw_tso && skb_shinfo(skb)->gso_size) {
+		hdr->tso = 1;
+		hdr->tso_start = skb_transport_offset(skb) + tcp_hdrlen(skb);
+		hdr->tso_max_paysize = skb_shinfo(skb)->gso_size;
+	}
 }
 
 /* SQ GATHER subdescriptor
@@ -1046,7 +1052,7 @@ static int nicvf_sq_append_tso(struct nicvf *nic, struct snd_queue *sq,
 			tso_build_data(skb, &tso, size);
 		}
 		nicvf_sq_add_hdr_subdesc(sq, hdr_qentry,
-					 seg_subdescs - 1, skb, seg_len);
+					 seg_subdescs - 1, skb, seg_len, false);
 		sq->skbuff[hdr_qentry] = (u64)NULL;
 		qentry = nicvf_get_nxt_sqentry(sq, qentry);
 
@@ -1098,11 +1104,12 @@ int nicvf_sq_append_skb(struct nicvf *nic, struct sk_buff *skb)
 	qentry = nicvf_get_sq_desc(sq, subdesc_cnt);
 
 	/* Check if its a TSO packet */
-	if (skb_shinfo(skb)->gso_size)
+	if (skb_shinfo(skb)->gso_size && !nic->hw_tso)
 		return nicvf_sq_append_tso(nic, sq, sq_num, qentry, skb);
 
 	/* Add SQ header subdesc */
-	nicvf_sq_add_hdr_subdesc(sq, qentry, subdesc_cnt - 1, skb, skb->len);
+	nicvf_sq_add_hdr_subdesc(sq, qentry, subdesc_cnt - 1, skb,
+				 skb->len, nic->hw_tso);
 
 	/* Add SQ gather subdescs */
 	qentry = nicvf_get_nxt_sqentry(sq, qentry);
diff --git a/drivers/net/ethernet/cavium/thunder/q_struct.h b/drivers/net/ethernet/cavium/thunder/q_struct.h
index 3c1de97..9e6d987 100644
--- a/drivers/net/ethernet/cavium/thunder/q_struct.h
+++ b/drivers/net/ethernet/cavium/thunder/q_struct.h
@@ -545,25 +545,28 @@ struct sq_hdr_subdesc {
 	u64    subdesc_cnt:8;
 	u64    csum_l4:2;
 	u64    csum_l3:1;
-	u64    rsvd0:5;
+	u64    csum_inner_l4:2;
+	u64    csum_inner_l3:1;
+	u64    rsvd0:2;
 	u64    l4_offset:8;
 	u64    l3_offset:8;
 	u64    rsvd1:4;
 	u64    tot_len:20; /* W0 */
 
-	u64    tso_sdc_cont:8;
-	u64    tso_sdc_first:8;
-	u64    tso_l4_offset:8;
-	u64    tso_flags_last:12;
-	u64    tso_flags_first:12;
-	u64    rsvd2:2;
+	u64    rsvd2:24;
+	u64    inner_l4_offset:8;
+	u64    inner_l3_offset:8;
+	u64    tso_start:8;
+	u64    rsvd3:2;
 	u64    tso_max_paysize:14; /* W1 */
 #elif defined(__LITTLE_ENDIAN_BITFIELD)
 	u64    tot_len:20;
 	u64    rsvd1:4;
 	u64    l3_offset:8;
 	u64    l4_offset:8;
-	u64    rsvd0:5;
+	u64    rsvd0:2;
+	u64    csum_inner_l3:1;
+	u64    csum_inner_l4:2;
 	u64    csum_l3:1;
 	u64    csum_l4:2;
 	u64    subdesc_cnt:8;
@@ -574,12 +577,11 @@ struct sq_hdr_subdesc {
 	u64    subdesc_type:4; /* W0 */
 
 	u64    tso_max_paysize:14;
-	u64    rsvd2:2;
-	u64    tso_flags_first:12;
-	u64    tso_flags_last:12;
-	u64    tso_l4_offset:8;
-	u64    tso_sdc_first:8;
-	u64    tso_sdc_cont:8; /* W1 */
+	u64    rsvd3:2;
+	u64    tso_start:8;
+	u64    inner_l3_offset:8;
+	u64    inner_l4_offset:8;
+	u64    rsvd2:24; /* W1 */
 #endif
 };
 
-- 
1.7.1
