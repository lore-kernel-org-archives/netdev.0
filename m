From: Suresh Reddy <suresh.reddy@broadcom.com>
Subject: [PATCH net] be2net: fix TSO6/GSO issue causing TX-stall on Lancer/BEx
Date: Wed, 13 Sep 2017 11:12:42 -0400
Message-ID: <20170913151242.16303-1-suresh.reddy@broadcom.com>
References: <Suresh.Reddy@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:40323 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751123AbdIMPUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 11:20:35 -0400
Received: from Sathya-S84.localdomain (unknown [10.192.238.84])
        by relay.smtp.broadcom.com (Postfix) with ESMTP id 67D76280093
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 08:12:44 -0700 (PDT)
In-Reply-To: <Suresh.Reddy@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 TSO requests with extension hdrs are a problem to the
Lancer and BEx chips. Workaround is to disable TSO6 feature
for such packets.

Also in Lancer chips, MSS less than 256 was resulting in TX stall.
Fix this by disabling GSO when MSS less than 256.

Signed-off-by: Suresh Reddy <suresh.reddy@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  8 ++++++++
 drivers/net/ethernet/emulex/benet/be_main.c | 14 ++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 674cf9d..8984c49 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -930,6 +930,14 @@ static inline bool is_ipv4_pkt(struct sk_buff *skb)
 	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
 }
 
+static inline bool is_ipv6_ext_hdr(struct sk_buff *skb)
+{
+	if (ip_hdr(skb)->version == 6)
+		return ipv6_ext_hdr(ipv6_hdr(skb)->nexthdr);
+	else
+		return false;
+}
+
 #define be_error_recovering(adapter)	\
 		(adapter->flags & BE_FLAGS_TRY_RECOVERY)
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 319eee3..0e3d9f39 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5089,6 +5089,20 @@ static netdev_features_t be_features_check(struct sk_buff *skb,
 	struct be_adapter *adapter = netdev_priv(dev);
 	u8 l4_hdr = 0;
 
+	if (skb_is_gso(skb)) {
+		/* IPv6 TSO requests with extension hdrs are a problem
+		 * to Lancer and BE3 HW. Disable TSO6 feature.
+		 */
+		if (!skyhawk_chip(adapter) && is_ipv6_ext_hdr(skb))
+			features &= ~NETIF_F_TSO6;
+
+		/* Lancer cannot handle the packet with MSS less than 256.
+		 * Disable the GSO support in such cases
+		 */
+		if (lancer_chip(adapter) && skb_shinfo(skb)->gso_size < 256)
+			features &= ~NETIF_F_GSO_MASK;
+	}
+
 	/* The code below restricts offload features for some tunneled and
 	 * Q-in-Q packets.
 	 * Offload features for normal (non tunnel) packets are unchanged.
-- 
1.8.3.1
