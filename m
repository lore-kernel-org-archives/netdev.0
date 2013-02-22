From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/2 v2] IP_GRE: Fix IP-Identification.
Date: Fri, 22 Feb 2013 09:30:30 -0800
Message-ID: <1361554230-1645-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, stephen@networkplumber.org,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog103.obsmtp.com ([74.125.149.71]:49485 "HELO
	na3sys009aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756963Ab3BVVt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 16:49:29 -0500
Received: by mail-qe0-f71.google.com with SMTP id 3so2035843qea.6
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 13:49:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE-GSO generates ip fragments with id 0,2,3,4... for every
GSO packet, which is not correct. Following patch fixes it
by setting ip-header id unique id of fragments are allowed.
As Eric Dumazet suggested it is optimized by using inner ip-header
whenever inner packet is ipv4.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ipip.h |   17 +++++++++++++++++
 net/ipv4/af_inet.c |    6 ++++--
 net/ipv4/ip_gre.c  |    3 ++-
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index 21947cf..fd19625 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -71,4 +71,21 @@ static inline void iptunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 }
 
+static inline void tunnel_ip_select_ident(struct sk_buff *skb,
+					  const struct iphdr  *old_iph,
+					  struct dst_entry *dst)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	if (iph->frag_off & htons(IP_DF))
+		iph->id	= 0;
+	else {
+		/* Use inner packet iph-id if possible. */
+		if (skb->protocol == htons(ETH_P_IP) && old_iph->id)
+			iph->id	= old_iph->id;
+		else
+			__ip_select_ident(iph, dst,
+					  (skb_shinfo(skb)->gso_segs ?: 1) - 1);
+	}
+}
 #endif
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
index 5ef4da7..b8bada0 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -970,7 +970,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	iph->daddr		=	fl4.daddr;
 	iph->saddr		=	fl4.saddr;
 	iph->ttl		=	ttl;
-	iph->id			=	0;
+
+	tunnel_ip_select_ident(skb, old_iph, &rt->dst);
 
 	if (ttl == 0) {
 		if (skb->protocol == htons(ETH_P_IP))
-- 
1.7.1
