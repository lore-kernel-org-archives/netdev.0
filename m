From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next 2/3] ipvlan: Process fragmented multicast frames correctly
Date: Thu, 23 Apr 2015 14:29:53 -0700
Message-ID: <1429824593-23704-1-git-send-email-maheshb@google.com>
Cc: Dan Willems <dcbw@redhat.com>, David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:33298 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932841AbbDWXLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 19:11:23 -0400
Received: by pablj1 with SMTP id lj1so2563990pab.0
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 16:11:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multicast processing in IPvlan was faulty as is. Eric Dumazet
pointed out that fragmented packets wont be processed correctly
unless defrag step is introduced.

This patch adds the defrag step before driver attempts to process
multicast frame(s).

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 8 ++++++++
 include/net/ip.h                 | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 58891666088c..282d32b16a87 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -532,6 +532,10 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		return dev_forward_skb(ipvlan->phy_dev, skb);
 
 	} else if (is_multicast_ether_addr(eth->h_dest)) {
+		skb = ip_check_defrag(skb, IP_DEFRAG_IPVLAN);
+		if (!skb)
+			return RX_HANDLER_CONSUMED;
+
 		ipvlan_multicast_enqueue(ipvlan->port, skb);
 		return NET_XMIT_SUCCESS;
 	}
@@ -617,6 +621,10 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 	int addr_type;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
+		skb = ip_check_defrag(skb, IP_DEFRAG_IPVLAN);
+		if (!skb)
+			return RX_HANDLER_CONSUMED;
+
 		if (ipvlan_external_frame(skb, port)) {
 			ipvlan_multicast_enqueue(port, skb);
 			return RX_HANDLER_CONSUMED;
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
