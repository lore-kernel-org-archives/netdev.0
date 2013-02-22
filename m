From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] IP_GRE: Fix IP-Identification.
Date: Thu, 21 Feb 2013 18:18:39 -0800
Message-ID: <1361499519-1715-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:41398 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754865Ab3BVCRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 21:17:25 -0500
Received: by mail-ye0-f200.google.com with SMTP id r13so305211yen.3
        for <netdev@vger.kernel.org>; Thu, 21 Feb 2013 18:17:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ip_select_ident_more() to generate and account ids for all
segments that can be used for segments of a gso packet.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/af_inet.c |    6 ++++--
 net/ipv4/ip_gre.c  |    4 +++-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e225a4e..2992f37 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1327,8 +1327,10 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 			if (skb->next != NULL)
 				iph->frag_off |= htons(IP_MF);
 			offset += (skb->len - skb->mac_len - iph->ihl * 4);
-		} else
-			iph->id = htons(id++);
+		} else  {
+			if (!(iph->frag_off & htons(IP_DF)))
+				iph->id = htons(id++);
+		}
 		iph->tot_len = htons(skb->len - skb->mac_len);
 		iph->check = 0;
 		iph->check = ip_fast_csum(skb_network_header(skb), iph->ihl);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 5ef4da7..3c6f2e2 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -970,7 +970,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	iph->daddr		=	fl4.daddr;
 	iph->saddr		=	fl4.saddr;
 	iph->ttl		=	ttl;
-	iph->id			=	0;
+
+	ip_select_ident_more(iph, &rt->dst, NULL,
+			     (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
 	if (ttl == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
-- 
1.7.1
