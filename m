From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next-2.6] be2net: enable ipv6 tso support
Date: Mon, 14 Jun 2010 20:26:07 +0530
Message-ID: <20100614145557.GA12552@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:33039 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752580Ab0FNO4J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 10:56:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ipv6 support to the be2net driver.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_hw.h   |    2 +-
 drivers/net/benet/be_main.c |    6 ++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be_hw.h b/drivers/net/benet/be_hw.h
index 063026d..0683967 100644
--- a/drivers/net/benet/be_hw.h
+++ b/drivers/net/benet/be_hw.h
@@ -192,7 +192,7 @@ struct amap_eth_hdr_wrb {
 	u8 event;
 	u8 crc;
 	u8 forward;
-	u8 ipsec;
+	u8 lso6;
 	u8 mgmt;
 	u8 ipcs;
 	u8 udpcs;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 3225774..01eb447 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -373,10 +373,12 @@ static void wrb_fill_hdr(struct be_eth_hdr_wrb *hdr, struct sk_buff *skb,
 
 	AMAP_SET_BITS(struct amap_eth_hdr_wrb, crc, hdr, 1);
 
-	if (skb_shinfo(skb)->gso_segs > 1 && skb_shinfo(skb)->gso_size) {
+	if (skb_is_gso(skb)) {
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso, hdr, 1);
 		AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso_mss,
 			hdr, skb_shinfo(skb)->gso_size);
+		if (skb_is_gso_v6(skb))
+			AMAP_SET_BITS(struct amap_eth_hdr_wrb, lso6, hdr, 1);
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		if (is_tcp_pkt(skb))
 			AMAP_SET_BITS(struct amap_eth_hdr_wrb, tcpcs, hdr, 1);
@@ -2186,7 +2188,7 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->features |= NETIF_F_SG | NETIF_F_HW_VLAN_RX | NETIF_F_TSO |
 		NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER | NETIF_F_HW_CSUM |
-		NETIF_F_GRO;
+		NETIF_F_GRO | NETIF_F_TSO6;
 
 	netdev->vlan_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_HW_CSUM;
 
-- 
1.7.0.4

