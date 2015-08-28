From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next 5/8] net: thunderx: Support for HW VLAN stripping
Date: Fri, 28 Aug 2015 17:59:57 +0300
Message-ID: <1440774004-27923-5-git-send-email-aleksey.makarov@auriga.com>
References: <1440774004-27923-1-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Aleksey Makarov <aleksey.makarov@auriga.com>,
 Robert Richter <rric@kernel.org>, David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1440774004-27923-1-git-send-email-aleksey.makarov@auriga.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch configures HW to strip 802.1Q header if found in a
receiving packet. The stripped VLAN ID and TCI information is
passed on to software via CQE_RX. Also sets netdev's 'vlan_features'
so that other HW offload features can be used for tagged packets.

This offload feature can be enabled or disabled via ethtool.

Network stack normally ignores RPS for 802.1Q packets and hence low
throughput. With this offload enabled throughput for tagged packets
will be almost same as normal packets.

Note: This patch doesn't enable HW VLAN insertion for transmit packets.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  4 ++++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 28 +++++++++++++++++++---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 28 ++++++++++++++++++----
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  2 ++
 4 files changed, 55 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 6e0c031..7dfec4a 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -329,6 +329,10 @@ static void nic_init_hw(struct nicpf *nic)
 
 	/* Timer config */
 	nic_reg_write(nic, NIC_PF_INTR_TIMER_CFG, NICPF_CLK_PER_INT_TICK);
+
+	/* Enable VLAN ethertype matching and stripping */
+	nic_reg_write(nic, NIC_PF_RX_ETYPE_0_7,
+		      (2 << 19) | (ETYPE_ALG_VLAN_STRIP << 16) | ETH_P_8021Q);
 }
 
 /* Channel parse index configuration */
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index afd8ad4..de51828 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -10,6 +10,7 @@
 #include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <linux/log2.h>
@@ -491,6 +492,11 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 
 	skb->protocol = eth_type_trans(skb, netdev);
 
+	/* Check for stripped VLAN */
+	if (cqe_rx->vlan_found && cqe_rx->vlan_stripped)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+				       ntohs((__force __be16)cqe_rx->vlan_tci));
+
 	if (napi && (netdev->features & NETIF_F_GRO))
 		napi_gro_receive(napi, skb);
 	else
@@ -1220,6 +1226,18 @@ static void nicvf_reset_task(struct work_struct *work)
 	nic->netdev->trans_start = jiffies;
 }
 
+static int nicvf_set_features(struct net_device *netdev,
+			      netdev_features_t features)
+{
+	struct nicvf *nic = netdev_priv(netdev);
+	netdev_features_t changed = features ^ netdev->features;
+
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
+		nicvf_config_vlan_stripping(nic, features);
+
+	return 0;
+}
+
 static const struct net_device_ops nicvf_netdev_ops = {
 	.ndo_open		= nicvf_open,
 	.ndo_stop		= nicvf_stop,
@@ -1228,6 +1246,7 @@ static const struct net_device_ops nicvf_netdev_ops = {
 	.ndo_set_mac_address	= nicvf_set_mac_address,
 	.ndo_get_stats64	= nicvf_get_stats64,
 	.ndo_tx_timeout         = nicvf_tx_timeout,
+	.ndo_set_features       = nicvf_set_features,
 };
 
 static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
@@ -1301,10 +1320,13 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_free_netdev;
 
-	netdev->features |= (NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
-			     NETIF_F_TSO | NETIF_F_GRO | NETIF_F_RXHASH);
+	netdev->hw_features = (NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
+			       NETIF_F_TSO | NETIF_F_GRO |
+			       NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_RXHASH);
+
+	netdev->features |= netdev->hw_features;
 
-	netdev->hw_features = netdev->features;
+	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
 
 	netdev->netdev_ops = &nicvf_netdev_ops;
 	netdev->watchdog_timeo = NICVF_TX_TIMEOUT;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 4fc40d83..b294d67 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -475,6 +475,27 @@ static void nicvf_reclaim_rbdr(struct nicvf *nic,
 		return;
 }
 
+void nicvf_config_vlan_stripping(struct nicvf *nic, netdev_features_t features)
+{
+	u64 rq_cfg;
+	int sqs;
+
+	rq_cfg = nicvf_queue_reg_read(nic, NIC_QSET_RQ_GEN_CFG, 0);
+
+	/* Enable first VLAN stripping */
+	if (features & NETIF_F_HW_VLAN_CTAG_RX)
+		rq_cfg |= (1ULL << 25);
+	else
+		rq_cfg &= ~(1ULL << 25);
+	nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, 0, rq_cfg);
+
+	/* Configure Secondary Qsets, if any */
+	for (sqs = 0; sqs < nic->sqs_count; sqs++)
+		if (nic->snicvf[sqs])
+			nicvf_queue_reg_write(nic->snicvf[sqs],
+					      NIC_QSET_RQ_GEN_CFG, 0, rq_cfg);
+}
+
 /* Configures receive queue */
 static void nicvf_rcv_queue_config(struct nicvf *nic, struct queue_set *qs,
 				   int qidx, bool enable)
@@ -524,7 +545,9 @@ static void nicvf_rcv_queue_config(struct nicvf *nic, struct queue_set *qs,
 	mbx.rq.cfg = (1ULL << 62) | (RQ_CQ_DROP << 8);
 	nicvf_send_msg_to_pf(nic, &mbx);
 
-	nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, qidx, 0x00);
+	nicvf_queue_reg_write(nic, NIC_QSET_RQ_GEN_CFG, 0, 0x00);
+	if (!nic->sqs_mode)
+		nicvf_config_vlan_stripping(nic, nic->netdev->features);
 
 	/* Enable Receive queue */
 	rq_cfg.ena = 1;
@@ -961,9 +984,6 @@ nicvf_sq_add_hdr_subdesc(struct snd_queue *sq, int qentry,
 
 	/* Offload checksum calculation to HW */
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		if (skb->protocol != htons(ETH_P_IP))
-			return;
-
 		hdr->csum_l3 = 1; /* Enable IP csum calculation */
 		hdr->l3_offset = skb_network_offset(skb);
 		hdr->l4_offset = skb_transport_offset(skb);
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index dc73872..8b93dd6 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -306,6 +306,8 @@ struct queue_set {
 
 #define	CQ_ERR_MASK	(CQ_WR_FULL | CQ_WR_DISABLE | CQ_WR_FAULT)
 
+void nicvf_config_vlan_stripping(struct nicvf *nic,
+				 netdev_features_t features);
 int nicvf_set_qset_resources(struct nicvf *nic);
 int nicvf_config_data_transfer(struct nicvf *nic, bool enable);
 void nicvf_qset_config(struct nicvf *nic, bool enable);
-- 
2.5.0
