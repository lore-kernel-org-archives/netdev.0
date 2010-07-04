From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/4] bnx2: Add support for skb->rxhash.
Date: Sat, 3 Jul 2010 23:42:16 -0700
Message-ID: <1278225738-7795-2-git-send-email-mchan@broadcom.com>
References: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3308 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987Ab0GDGjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jul 2010 02:39:49 -0400
In-Reply-To: <1278225738-7795-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb->rxhash support for TCP packets only because the bnx2 RSS hash
does not hash UDP ports.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   15 ++++++++++++++-
 drivers/net/bnx2.h |    3 +++
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 0614ca0..1450c75 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -3219,6 +3219,10 @@ bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 					      L2_FHDR_ERRORS_UDP_XSUM)) == 0))
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 		}
+		if ((bp->dev->features & NETIF_F_RXHASH) &&
+		    ((status & L2_FHDR_STATUS_USE_RXHASH) ==
+		     L2_FHDR_STATUS_USE_RXHASH))
+			skb->rxhash = rx_hdr->l2_fhdr_hash;
 
 		skb_record_rx_queue(skb, bnapi - &bp->bnx2_napi[0]);
 
@@ -7558,6 +7562,12 @@ bnx2_set_tx_csum(struct net_device *dev, u32 data)
 		return (ethtool_op_set_tx_csum(dev, data));
 }
 
+static int
+bnx2_set_flags(struct net_device *dev, u32 data)
+{
+	return ethtool_op_set_flags(dev, data, ETH_FLAG_RXHASH);
+}
+
 static const struct ethtool_ops bnx2_ethtool_ops = {
 	.get_settings		= bnx2_get_settings,
 	.set_settings		= bnx2_set_settings,
@@ -7587,6 +7597,8 @@ static const struct ethtool_ops bnx2_ethtool_ops = {
 	.phys_id		= bnx2_phys_id,
 	.get_ethtool_stats	= bnx2_get_ethtool_stats,
 	.get_sset_count		= bnx2_get_sset_count,
+	.set_flags		= bnx2_set_flags,
+	.get_flags		= ethtool_op_get_flags,
 };
 
 /* Called with rtnl_lock */
@@ -8333,7 +8345,8 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	memcpy(dev->dev_addr, bp->mac_addr, 6);
 	memcpy(dev->perm_addr, bp->mac_addr, 6);
 
-	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_GRO;
+	dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_GRO |
+			 NETIF_F_RXHASH;
 	vlan_features_add(dev, NETIF_F_IP_CSUM | NETIF_F_SG);
 	if (CHIP_NUM(bp) == CHIP_NUM_5709) {
 		dev->features |= NETIF_F_IPV6_CSUM;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index ddaa3fc..b9af6bc 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -295,6 +295,9 @@ struct l2_fhdr {
 		#define L2_FHDR_ERRORS_TCP_XSUM		(1<<28)
 		#define L2_FHDR_ERRORS_UDP_XSUM		(1<<31)
 
+		#define L2_FHDR_STATUS_USE_RXHASH	\
+			(L2_FHDR_STATUS_TCP_SEGMENT | L2_FHDR_STATUS_RSS_HASH)
+
 	u32 l2_fhdr_hash;
 #if defined(__BIG_ENDIAN)
 	u16 l2_fhdr_pkt_len;
-- 
1.6.4.GIT


