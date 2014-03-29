From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 13/17] jme: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:26 +0100
Message-ID: <a90a56a2cc34308f6a43fd2032338875e0a946f7.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org, Guo-Fu Tseng <cooldavid@cooldavid.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60884 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbaC2L0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:55 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/ethernet/jme.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 14ff8d6..b0c6050 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2054,19 +2054,6 @@ jme_map_tx_skb(struct jme_adapter *jme, struct sk_buff *skb, int idx)
 }
 
 static int
-jme_expand_header(struct jme_adapter *jme, struct sk_buff *skb)
-{
-	if (unlikely(skb_shinfo(skb)->gso_size &&
-			skb_header_cloned(skb) &&
-			pskb_expand_head(skb, 0, 0, GFP_ATOMIC))) {
-		dev_kfree_skb_any(skb);
-		return -1;
-	}
-
-	return 0;
-}
-
-static int
 jme_tx_tso(struct sk_buff *skb, __le16 *mss, u8 *flags)
 {
 	*mss = cpu_to_le16(skb_shinfo(skb)->gso_size << TXDESC_MSS_SHIFT);
@@ -2225,7 +2212,8 @@ jme_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct jme_adapter *jme = netdev_priv(netdev);
 	int idx;
 
-	if (unlikely(jme_expand_header(jme, skb))) {
+	if (unlikely(skb_is_gso(skb) && skb_cow_head(skb, 0))) {
+		dev_kfree_skb_any(skb);
 		++(NET_STAT(jme).tx_dropped);
 		return NETDEV_TX_OK;
 	}
-- 
1.9.0
