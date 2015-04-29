From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v2 2/3] ipvlan: Process fragmented multicast frames correctly
Date: Wed, 29 Apr 2015 11:19:18 -0700
Message-ID: <1430331558-20286-1-git-send-email-maheshb@google.com>
Cc: Dan Willems <dcbw@redhat.com>, David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f74.google.com ([209.85.192.74]:33712 "EHLO
	mail-qg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbbD2SsC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 14:48:02 -0400
Received: by qgdz60 with SMTP id z60so1090580qgd.0
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 11:48:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multicast processing in IPvlan was faulty as is. Eric Dumazet
pointed out that fragmented packets won't be processed correctly
unless defrag step is introduced.

This patch adds the defrag step before driver attempts to process
multicast frame(s).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 8 ++++++++
 include/net/ip.h                 | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index c5297d1f1e1c..3b86a4eee7ab 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -521,6 +521,10 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		return dev_forward_skb(ipvlan->phy_dev, skb);
 
 	} else if (is_multicast_ether_addr(eth->h_dest)) {
+		skb = ip_check_defrag(skb, IP_DEFRAG_IPVLAN);
+		if (!skb)
+			return RX_HANDLER_CONSUMED;
+
 		ipvlan_multicast_enqueue(ipvlan->port, skb);
 		return NET_XMIT_SUCCESS;
 	}
@@ -606,6 +610,10 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 	int addr_type;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
+		skb = ip_check_defrag(skb, IP_DEFRAG_IPVLAN);
+		if (!skb)
+			return RX_HANDLER_CONSUMED;
+
 		if (ipvlan_external_frame(skb, port)) {
 			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
 
diff --git a/include/net/ip.h b/include/net/ip.h
index d14af7edd197..1fb432b346a8 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -476,6 +476,7 @@ enum ip_defrag_users {
 	IP_DEFRAG_VS_FWD,
 	IP_DEFRAG_AF_PACKET,
 	IP_DEFRAG_MACVLAN,
+	IP_DEFRAG_IPVLAN,
 };
 
 int ip_defrag(struct sk_buff *skb, u32 user);
-- 
2.2.0.rc0.207.ga3a616c
