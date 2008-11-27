From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 26/29: nfmark routing in OUTPUT, mangle, NFQUEUE
Date: Thu, 27 Nov 2008 17:15:38 +0100 (MET)
Message-ID: <20081127161538.13891.14939.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 5f145e44ae09f629d25536b2947a91e9c01bddcb
Author: Eric Leblond <eric@inl.fr>
Date:   Tue Nov 25 12:15:16 2008 +0100

    netfilter: nfmark routing in OUTPUT, mangle, NFQUEUE
    
    This patch let nfmark to be evaluated for routing decision for OUTPUT
    packet, in mangle table, when process paquet in NFQUEUE
    Until now, only change (in NFQUEUE process) on fields src_addr,
    dest_addr and tos could make netfilter to reevalute the routing.
    
    From: Laurent Licour <laurent@licour.com>
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 6efdb70..7c145d7 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -125,6 +125,7 @@ struct ip_rt_info {
 	__be32 daddr;
 	__be32 saddr;
 	u_int8_t tos;
+	u_int32_t mark;
 };
 
 static void nf_ip_saveroute(const struct sk_buff *skb,
@@ -138,6 +139,7 @@ static void nf_ip_saveroute(const struct sk_buff *skb,
 		rt_info->tos = iph->tos;
 		rt_info->daddr = iph->daddr;
 		rt_info->saddr = iph->saddr;
+		rt_info->mark = skb->mark;
 	}
 }
 
@@ -150,6 +152,7 @@ static int nf_ip_reroute(struct sk_buff *skb,
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (!(iph->tos == rt_info->tos
+		      && skb->mark == rt_info->mark
 		      && iph->daddr == rt_info->daddr
 		      && iph->saddr == rt_info->saddr))
 			return ip_route_me_harder(skb, RTN_UNSPEC);
