From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net 2/2] fm10k: Implement ndo_gso_check()
Date: Thu, 13 Nov 2014 15:36:41 -0800
Message-ID: <1415921801-10452-2-git-send-email-joestringer@nicira.com>
References: <1415921801-10452-1-git-send-email-joestringer@nicira.com>
Cc: matthew.vick@intel.com, jeffrey.t.kirsher@intel.com,
	linux.nics@intel.com, therbert@google.com, gerlitz.or@gmail.com,
	alexander.duyck@gmail.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415921801-10452-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ndo_gso_check() was recently introduced to allow NICs to report the
offloading support that they have on a per-skb basis. Add an
implementation for this driver which checks for something that looks
like VXLAN.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Reuse fm10k_tx_encap_offload().
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |    1 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |    2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |    8 ++++++++
 3 files changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 42eb434..d38f088 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -443,6 +443,7 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 				  struct fm10k_ring *tx_ring);
 void fm10k_tx_timeout_reset(struct fm10k_intfc *interface);
 bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring);
+__be16 fm10k_tx_encap_offload(struct sk_buff *skb);
 void fm10k_alloc_rx_buffers(struct fm10k_ring *rx_ring, u16 cleaned_count);
 
 /* PCI */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 3a85291..1144e14 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -727,7 +727,7 @@ static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
 	return (struct ethhdr *)(&nvgre_hdr->tni);
 }
 
-static __be16 fm10k_tx_encap_offload(struct sk_buff *skb)
+__be16 fm10k_tx_encap_offload(struct sk_buff *skb)
 {
 	struct ethhdr *eth_hdr;
 	u8 l4_hdr = 0;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 8811364..6e8630a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1350,6 +1350,13 @@ static void fm10k_dfwd_del_station(struct net_device *dev, void *priv)
 	}
 }
 
+static bool fm10k_gso_check(struct sk_buff *skb, struct net_device *dev)
+{
+	return (!(skb_shinfo(skb)->gso_type &
+		  (SKB_GSO_UDP_TUNNEL | SKB_GSO_GRE)) ||
+		fm10k_tx_encap_offload(skb));
+}
+
 static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_open		= fm10k_open,
 	.ndo_stop		= fm10k_close,
@@ -1372,6 +1379,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_do_ioctl		= fm10k_ioctl,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
 	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
+	.ndo_gso_check		= fm10k_gso_check,
 };
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
-- 
1.7.10.4
