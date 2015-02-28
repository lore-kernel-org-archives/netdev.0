From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/18] fm10k: Implement ndo_features_check
Date: Sat, 28 Feb 2015 03:29:33 -0800
Message-ID: <1425122989-354-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:50492 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbbB1L3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Feb 2015 06:29:53 -0500
In-Reply-To: <1425122989-354-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

The introduction of ndo_features_check allows drivers to report their
offload capabilities per-skb. Implement this in fm10k to take advantage
of this new functionality.

Reported-by: Joe Stringer <joestringer@nicira.com>
Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h        |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_main.c   |  2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 11 +++++++++++
 3 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 42eb434..59edfd4 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -439,6 +439,7 @@ extern char fm10k_driver_name[];
 extern const char fm10k_driver_version[];
 int fm10k_init_queueing_scheme(struct fm10k_intfc *interface);
 void fm10k_clear_queueing_scheme(struct fm10k_intfc *interface);
+__be16 fm10k_tx_encap_offload(struct sk_buff *skb);
 netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 				  struct fm10k_ring *tx_ring);
 void fm10k_tx_timeout_reset(struct fm10k_intfc *interface);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index a7d3798..0cb6971b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -718,7 +718,7 @@ static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
 	return (struct ethhdr *)(&nvgre_hdr->tni);
 }
 
-static __be16 fm10k_tx_encap_offload(struct sk_buff *skb)
+__be16 fm10k_tx_encap_offload(struct sk_buff *skb)
 {
 	u8 l4_hdr = 0, inner_l4_hdr = 0, inner_l4_hlen;
 	struct ethhdr *eth_hdr;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index cfde8ba..2a9b467 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1350,6 +1350,16 @@ static void fm10k_dfwd_del_station(struct net_device *dev, void *priv)
 	}
 }
 
+static netdev_features_t fm10k_features_check(struct sk_buff *skb,
+					      struct net_device *dev,
+					      netdev_features_t features)
+{
+	if (!skb->encapsulation || fm10k_tx_encap_offload(skb))
+		return features;
+
+	return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+}
+
 static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_open		= fm10k_open,
 	.ndo_stop		= fm10k_close,
@@ -1372,6 +1382,7 @@ static const struct net_device_ops fm10k_netdev_ops = {
 	.ndo_do_ioctl		= fm10k_ioctl,
 	.ndo_dfwd_add_station	= fm10k_dfwd_add_station,
 	.ndo_dfwd_del_station	= fm10k_dfwd_del_station,
+	.ndo_features_check	= fm10k_features_check,
 };
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
-- 
1.9.3
