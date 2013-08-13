From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net] ip_tunnel: Do not use inner ip-header-id for tunnel ip-header-id.
Date: Tue, 13 Aug 2013 01:41:06 -0700
Message-ID: <1376383266-6623-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Jarno Rajahalme <jrajahalme@nicira.com>,
	Ansis Atteka <aatteka@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog112.obsmtp.com ([74.125.149.207]:49587 "HELO
	na3sys009aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754264Ab3HMIlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 04:41:16 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so4573420pdj.31
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 01:41:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using inner-id for tunnel id is not safe in some rare cases.
E.g. packets coming from multiple sources entering same tunnel
can have same id. Therefore on tunnel packet receive we
could have packets from two different stream but with same
source and dst IP with same ip-id which could confuse ip packet
reassembly.

Following patch reverts optimization from commit
490ab08127 (IP_GRE: Fix IP-Identification.)

CC: Jarno Rajahalme <jrajahalme@nicira.com>
CC: Ansis Atteka <aatteka@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h  |   14 --------------
 net/ipv4/ip_tunnel_core.c |    4 +---
 2 files changed, 1 insertions(+), 17 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 781b3cf..a354db5 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -145,20 +145,6 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 	return INET_ECN_encapsulate(tos, inner);
 }
 
-static inline void tunnel_ip_select_ident(struct sk_buff *skb,
-					  const struct iphdr  *old_iph,
-					  struct dst_entry *dst)
-{
-	struct iphdr *iph = ip_hdr(skb);
-
-	/* Use inner packet iph-id if possible. */
-	if (skb->protocol == htons(ETH_P_IP) && old_iph->id)
-		iph->id	= old_iph->id;
-	else
-		__ip_select_ident(iph, dst,
-				  (skb_shinfo(skb)->gso_segs ?: 1) - 1);
-}
-
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
 int iptunnel_xmit(struct net *net, struct rtable *rt,
 		  struct sk_buff *skb,
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 7167b08..850525b 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -76,9 +76,7 @@ int iptunnel_xmit(struct net *net, struct rtable *rt,
 	iph->daddr	=	dst;
 	iph->saddr	=	src;
 	iph->ttl	=	ttl;
-	tunnel_ip_select_ident(skb,
-			       (const struct iphdr *)skb_inner_network_header(skb),
-			       &rt->dst);
+	__ip_select_ident(iph, &rt->dst, (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 
 	err = ip_local_out(skb);
 	if (unlikely(net_xmit_eval(err)))
-- 
1.7.1
