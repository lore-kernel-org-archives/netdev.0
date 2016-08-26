From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC 9/9] ipv6: sr: add support for SRH injection through setsockopt
Date: Fri, 26 Aug 2016 17:54:12 +0200
Message-ID: <1472226852-10075-5-git-send-email-david.lebrun@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36827 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752781AbcHZQEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 12:04:38 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id 0A26967DBC8
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:53:44 +0200 (CEST)
In-Reply-To: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for per-socket SRH injection with the setsockopt
system call through the IPPROTO_IPV6, IPV6_RTHDR options.
The SRH is pushed through the ipv6_push_nfrag_opts function.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/Kconfig         |  5 ++--
 net/ipv6/exthdrs.c       | 69 +++++++++++++++++++++++++++++++++++++++++++++---
 net/ipv6/ipv6_sockglue.c |  4 +++
 3 files changed, 72 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 94b3f04..85edee2 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -305,8 +305,9 @@ config IPV6_SEG6_CORE
 	depends on IPV6_SEG6
 	---help---
 	  Enable the core functionalities required for a control plane support
-	  of SR-IPv6. This option is not useful by itself, it rather provides
-	  the code base for a control plane support.
+	  of SR-IPv6. It also enables the support for per-socket SRH injection
+	  through the setsockopt() system call with the IPPROTO_IPV6,IPV6_RTHDR
+	  options.
 
 	  If unsure, say N.
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index ff469b5..c1cc80c 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -831,9 +831,9 @@ int ipv6_parse_hopopts(struct sk_buff *skb)
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
@@ -856,6 +856,57 @@ static void ipv6_push_rthdr(struct sk_buff *skb, u8 *proto,
 	*proto = NEXTHDR_ROUTING;
 }
 
+#if IS_ENABLED(CONFIG_IPV6_SEG6_CORE)
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
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (net && (sr_get_flags(sr_phdr) & SR6_FLAG_HMAC))
+		seg6_push_hmac(net, saddr, sr_phdr);
+#endif
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
+#if IS_ENABLED(CONFIG_IPV6_SEG6_CORE)
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
@@ -1097,7 +1148,17 @@ struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 		return NULL;
 
 	*orig = fl6->daddr;
-	fl6->daddr = *((struct rt0_hdr *)opt->srcrt)->addr;
+
+#if IS_ENABLED(CONFIG_IPV6_SEG6_CORE)
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
index 5330262..069b169 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -429,6 +429,10 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 
 				break;
 #endif
+#if IS_ENABLED(CONFIG_IPV6_SEG6_CORE)
+			case IPV6_SRCRT_TYPE_4:
+				break;
+#endif
 			default:
 				goto sticky_done;
 			}
-- 
2.3.6
