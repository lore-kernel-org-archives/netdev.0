From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH 8/9] ipv6: sr: add support for SRH injection through setsockopt
Date: Mon, 17 Oct 2016 16:43:41 +0200
Message-ID: <1476715422-19151-4-git-send-email-david.lebrun@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59855 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754988AbcJQOvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:51:35 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id 4114367DC25
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:42:07 +0200 (CEST)
In-Reply-To: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for per-socket SRH injection with the setsockopt
system call through the IPPROTO_IPV6, IPV6_RTHDR options.
The SRH is pushed through the ipv6_push_nfrag_opts function.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/exthdrs.c       | 67 +++++++++++++++++++++++++++++++++++++++++++++---
 net/ipv6/ipv6_sockglue.c |  4 +++
 2 files changed, 67 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index c8a74a1..7fb8b3f 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -825,9 +825,9 @@ int ipv6_parse_hopopts(struct sk_buff *skb)
  *	for headers.
  */
 
-static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
-			    struct ipv6_rt_hdr *opt,
-			    struct in6_addr **addr_p, struct in6_addr *saddr)
+static void ipv6_push_rthdr0(struct sk_buff *skb, u8 *proto,
+			     struct ipv6_rt_hdr *opt,
+			     struct in6_addr **addr_p, struct in6_addr *saddr)
 {
 	struct rt0_hdr *phdr, *ihdr;
 	int hops;
@@ -850,6 +850,55 @@ static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 	*proto = NEXTHDR_ROUTING;
 }
 
+#ifdef CONFIG_IPV6_SEG6
+static void ipv6_push_rthdr4(struct sk_buff *skb, u8 *proto,
+			     struct ipv6_rt_hdr *opt,
+			     struct in6_addr **addr_p, struct in6_addr *saddr)
+{
+	struct ipv6_sr_hdr *sr_phdr, *sr_ihdr;
+	struct net *net = NULL;
+	int plen, hops;
+
+	if (skb->dev)
+		net = dev_net(skb->dev);
+	else if (skb->sk)
+		net = sock_net(skb->sk);
+
+	WARN_ON(!net);
+
+	sr_ihdr = (struct ipv6_sr_hdr *)opt;
+	plen = (sr_ihdr->hdrlen + 1) << 3;
+
+	sr_phdr = (struct ipv6_sr_hdr *)skb_push(skb, plen);
+	memcpy(sr_phdr, sr_ihdr, sizeof(struct ipv6_sr_hdr));
+
+	hops = sr_ihdr->first_segment + 1;
+	memcpy(sr_phdr->segments + 1, sr_ihdr->segments + 1,
+	       (hops - 1) * sizeof(struct in6_addr));
+
+	sr_phdr->segments[0] = **addr_p;
+	*addr_p = &sr_ihdr->segments[hops - 1];
+
+	if (net && (sr_get_flags(sr_phdr) & SR6_FLAG_HMAC))
+		seg6_push_hmac(net, saddr, sr_phdr);
+
+	sr_phdr->nexthdr = *proto;
+	*proto = NEXTHDR_ROUTING;
+}
+#endif
+
+static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
+			    struct ipv6_rt_hdr *opt,
+			    struct in6_addr **addr_p, struct in6_addr *saddr)
+{
+#ifdef CONFIG_IPV6_SEG6
+	if (opt->type == IPV6_SRCRT_TYPE_4)
+		ipv6_push_rthdr4(skb, proto, opt, addr_p, saddr);
+#endif
+	if (opt->type == IPV6_SRCRT_TYPE_0)
+		ipv6_push_rthdr0(skb, proto, opt, addr_p, saddr);
+}
+
 static void ipv6_push_exthdr(struct sk_buff *skb, u8 *proto, u8 type, struct ipv6_opt_hdr *opt)
 {
 	struct ipv6_opt_hdr *h = (struct ipv6_opt_hdr *)skb_push(skb, ipv6_optlen(opt));
@@ -1091,7 +1140,17 @@ struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 		return NULL;
 
 	*orig = fl6->daddr;
-	fl6->daddr = *((struct rt0_hdr *)opt->srcrt)->addr;
+
+#ifdef CONFIG_IPV6_SEG6
+	if (opt->srcrt->type == IPV6_SRCRT_TYPE_4) {
+		struct ipv6_sr_hdr *srh = (struct ipv6_sr_hdr *)opt->srcrt;
+
+		fl6->daddr = srh->segments[srh->first_segment];
+	}
+#endif
+	if (opt->srcrt->type == IPV6_SRCRT_TYPE_0)
+		fl6->daddr = *((struct rt0_hdr *)opt->srcrt)->addr;
+
 	return orig;
 }
 EXPORT_SYMBOL_GPL(fl6_update_dst);
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 5330262..f81f3db 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -429,6 +429,10 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 				break;
 #endif
+#ifdef CONFIG_IPV6_SEG6
+			case IPV6_SRCRT_TYPE_4:
+				break;
+#endif
 			default:
 				goto sticky_done;
 			}
-- 
2.7.3
