From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/2] ipip: capture inner headers during encapsulation
Date: Fri,  8 Mar 2013 17:12:52 -0800
Message-ID: <1362791572-1833-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:58725 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759941Ab3CIBLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 20:11:51 -0500
Received: by mail-oa0-f70.google.com with SMTP id h2so13897325oag.5
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 17:11:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow IPIP to make use of tx-checksum offloading.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/ipip.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 18f5352..b50435b 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -483,11 +483,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (skb->protocol != htons(ETH_P_IP))
 		goto tx_error;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    skb_checksum_help(skb))
-		goto tx_error;
-
 	old_iph = ip_hdr(skb);
 
 	if (tos & 1)
@@ -572,6 +567,13 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		old_iph = ip_hdr(skb);
 	}
 
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		skb->ip_summed = CHECKSUM_NONE;
+
 	skb->transport_header = skb->network_header;
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
@@ -599,7 +601,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		iph->ttl	=	old_iph->ttl;
 
 	nf_reset(skb);
-	skb->ip_summed = CHECKSUM_NONE;
 
 	pkt_len = skb->len - skb_transport_offset(skb);
 	err = ip_local_out(skb);
-- 
1.7.1
