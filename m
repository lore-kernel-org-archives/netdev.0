From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next 4/8] net: thunderx: Receive hashing HW offload support
Date: Fri, 28 Aug 2015 17:59:56 +0300
Message-ID: <1440774004-27923-4-git-send-email-aleksey.makarov@auriga.com>
References: <1440774004-27923-1-git-send-email-aleksey.makarov@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Aleksey Makarov <aleksey.makarov@auriga.com>,
 Robert Richter <rric@kernel.org>, David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>,
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

Adding support for receive hashing HW offload by using RSS_ALG
and RSS_TAG fields of CQE_RX descriptor. Also removed dependency
on minimum receive queue count to configure RSS so that hash is
always generated.

This hash is used by RPS logic to distribute flows across multiple
CPUs. Offload can be disabled via ethtool.

Signed-off-by: Robert Richter <rrichter@cavium.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    | 14 ++++-----
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 35 ++++++++++++++++++++--
 2 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
index a961aa3..1eec2cd 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
@@ -525,17 +525,15 @@ static int nicvf_set_rxfh(struct net_device *dev, const u32 *indir,
 	struct nicvf_rss_info *rss = &nic->rss_info;
 	int idx;
 
-	if ((nic->qs->rq_cnt <= 1) || (nic->cpi_alg != CPI_ALG_NONE)) {
-		rss->enable = false;
-		rss->hash_bits = 0;
-		return -EIO;
-	}
-
-	/* We do not allow change in unsupported parameters */
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
-	rss->enable = true;
+	if (!rss->enable) {
+		netdev_err(nic->netdev,
+			   "RSS is disabled, cannot change settings\n");
+		return -EIO;
+	}
+
 	if (indir) {
 		for (idx = 0; idx < rss->rss_size; idx++)
 			rss->ind_tbl[idx] = indir[idx];
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index d4ad36e..afd8ad4 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -313,7 +313,7 @@ static int nicvf_rss_init(struct nicvf *nic)
 
 	nicvf_get_rss_size(nic);
 
-	if ((nic->qs->rq_cnt <= 1) || (cpi_alg != CPI_ALG_NONE)) {
+	if (cpi_alg != CPI_ALG_NONE) {
 		rss->enable = false;
 		rss->hash_bits = 0;
 		return 0;
@@ -416,6 +416,34 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 	}
 }
 
+static inline void nicvf_set_rxhash(struct net_device *netdev,
+				    struct cqe_rx_t *cqe_rx,
+				    struct sk_buff *skb)
+{
+	u8 hash_type;
+	u32 hash;
+
+	if (!(netdev->features & NETIF_F_RXHASH))
+		return;
+
+	switch (cqe_rx->rss_alg) {
+	case RSS_ALG_TCP_IP:
+	case RSS_ALG_UDP_IP:
+		hash_type = PKT_HASH_TYPE_L4;
+		hash = cqe_rx->rss_tag;
+		break;
+	case RSS_ALG_IP:
+		hash_type = PKT_HASH_TYPE_L3;
+		hash = cqe_rx->rss_tag;
+		break;
+	default:
+		hash_type = PKT_HASH_TYPE_NONE;
+		hash = 0;
+	}
+
+	skb_set_hash(skb, hash, hash_type);
+}
+
 static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 				  struct napi_struct *napi,
 				  struct cmp_queue *cq,
@@ -451,6 +479,8 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 
 	nicvf_set_rx_frame_cnt(nic, skb);
 
+	nicvf_set_rxhash(netdev, cqe_rx, skb);
+
 	skb_record_rx_queue(skb, cqe_rx->rq_idx);
 	if (netdev->hw_features & NETIF_F_RXCSUM) {
 		/* HW by default verifies TCP/UDP/SCTP checksums */
@@ -1272,7 +1302,8 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_free_netdev;
 
 	netdev->features |= (NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
-			     NETIF_F_TSO | NETIF_F_GRO);
+			     NETIF_F_TSO | NETIF_F_GRO | NETIF_F_RXHASH);
+
 	netdev->hw_features = netdev->features;
 
 	netdev->netdev_ops = &nicvf_netdev_ops;
-- 
2.5.0
