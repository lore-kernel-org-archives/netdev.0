From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v5 7/9] ipv6: add source address argument for ipv6_push_nfrag_opts
Date: Tue, 8 Nov 2016 14:59:20 +0100
Message-ID: <1478613562-27947-3-git-send-email-david.lebrun@uclouvain.be>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:44049 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752901AbcKHN5e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 08:57:34 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp5.sgsi.ucl.ac.be (Postfix) with ESMTPS id 95CF467DC44
        for <netdev@vger.kernel.org>; Tue,  8 Nov 2016 14:57:23 +0100 (CET)
In-Reply-To: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prepares for insertion of SRH through setsockopt().
The new source address argument is used when an HMAC field is
present in the SRH, which must be filled. The HMAC signature
process requires the source address as input text.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/net/ipv6.h    | 3 ++-
 net/ipv6/exthdrs.c    | 6 +++---
 net/ipv6/ip6_output.c | 5 +++--
 net/ipv6/ip6_tunnel.c | 2 +-
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 8fed1cd..0a3622b 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -932,7 +932,8 @@ int ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb);
  */
 
 void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
-			  u8 *proto, struct in6_addr **daddr_p);
+			  u8 *proto, struct in6_addr **daddr_p,
+			  struct in6_addr *saddr);
 void ipv6_push_frag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 			 u8 *proto);
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 541cfa6..72aadce 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -866,7 +866,7 @@ int ipv6_parse_hopopts(struct sk_buff *skb)
 
 static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 			    struct ipv6_rt_hdr *opt,
-			    struct in6_addr **addr_p)
+			    struct in6_addr **addr_p, struct in6_addr *saddr)
 {
 	struct rt0_hdr *phdr, *ihdr;
 	int hops;
@@ -900,10 +900,10 @@ static void ipv6_push_exthdr(struct sk_buff *skb, u8 *proto, u8 type, struct ipv
 
 void ipv6_push_nfrag_opts(struct sk_buff *skb, struct ipv6_txoptions *opt,
 			  u8 *proto,
-			  struct in6_addr **daddr)
+			  struct in6_addr **daddr, struct in6_addr *saddr)
 {
 	if (opt->srcrt) {
-		ipv6_push_rthdr(skb, proto, opt->srcrt, daddr);
+		ipv6_push_rthdr(skb, proto, opt->srcrt, daddr, saddr);
 		/*
 		 * IPV6_RTHDRDSTOPTS is ignored
 		 * unless IPV6_RTHDR is set (RFC3542).
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..ddc878d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -203,7 +203,8 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 		if (opt->opt_flen)
 			ipv6_push_frag_opts(skb, opt, &proto);
 		if (opt->opt_nflen)
-			ipv6_push_nfrag_opts(skb, opt, &proto, &first_hop);
+			ipv6_push_nfrag_opts(skb, opt, &proto, &first_hop,
+					     &fl6->saddr);
 	}
 
 	skb_push(skb, sizeof(struct ipv6hdr));
@@ -1672,7 +1673,7 @@ struct sk_buff *__ip6_make_skb(struct sock *sk,
 	if (opt && opt->opt_flen)
 		ipv6_push_frag_opts(skb, opt, &proto);
 	if (opt && opt->opt_nflen)
-		ipv6_push_nfrag_opts(skb, opt, &proto, &final_dst);
+		ipv6_push_nfrag_opts(skb, opt, &proto, &final_dst, &fl6->saddr);
 
 	skb_push(skb, sizeof(struct ipv6hdr));
 	skb_reset_network_header(skb);
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index bfa889c..259e850 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1157,7 +1157,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 
 	if (encap_limit >= 0) {
 		init_tel_txopt(&opt, encap_limit);
-		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL);
+		ipv6_push_nfrag_opts(skb, &opt.ops, &proto, NULL, NULL);
 	}
 
 	/* Calculate max headroom for all the headers and adjust
-- 
2.7.3
