From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/2] netfilter: fix sparse warnings in reject handling
Date: Tue, 10 Mar 2015 16:46:20 +0100
Message-ID: <1426002381-20302-2-git-send-email-pablo@netfilter.org>
References: <1426002381-20302-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37543 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753836AbbCJPmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 11:42:37 -0400
In-Reply-To: <1426002381-20302-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

make C=1 CF=-D__CHECK_ENDIAN__ shows following:

net/bridge/netfilter/nft_reject_bridge.c:65:50: warning: incorrect type in argument 3 (different base types)
net/bridge/netfilter/nft_reject_bridge.c:65:50:    expected restricted __be16 [usertype] protocol [..]
net/bridge/netfilter/nft_reject_bridge.c:102:37: warning: cast from restricted __be16
net/bridge/netfilter/nft_reject_bridge.c:102:37: warning: incorrect type in argument 1 (different base types) [..]
net/bridge/netfilter/nft_reject_bridge.c:121:50: warning: incorrect type in argument 3 (different base types) [..]
net/bridge/netfilter/nft_reject_bridge.c:168:52: warning: incorrect type in argument 3 (different base types) [..]
net/bridge/netfilter/nft_reject_bridge.c:233:52: warning: incorrect type in argument 3 (different base types) [..]

Caused by two (harmless) errors:
1. htons() instead of ntohs()
2. __be16 for protocol in nf_reject_ipXhdr_put API, use u8 instead.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/ipv4/nf_reject.h   |    2 +-
 include/net/netfilter/ipv6/nf_reject.h   |    2 +-
 net/bridge/netfilter/nft_reject_bridge.c |    2 +-
 net/ipv4/netfilter/nf_reject_ipv4.c      |    2 +-
 net/ipv6/netfilter/nf_reject_ipv6.c      |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/netfilter/ipv4/nf_reject.h b/include/net/netfilter/ipv4/nf_reject.h
index 8641275..77862c3 100644
--- a/include/net/netfilter/ipv4/nf_reject.h
+++ b/include/net/netfilter/ipv4/nf_reject.h
@@ -12,7 +12,7 @@ const struct tcphdr *nf_reject_ip_tcphdr_get(struct sk_buff *oldskb,
 					     struct tcphdr *_oth, int hook);
 struct iphdr *nf_reject_iphdr_put(struct sk_buff *nskb,
 				  const struct sk_buff *oldskb,
-				  __be16 protocol, int ttl);
+				  __u8 protocol, int ttl);
 void nf_reject_ip_tcphdr_put(struct sk_buff *nskb, const struct sk_buff *oldskb,
 			     const struct tcphdr *oth);
 
diff --git a/include/net/netfilter/ipv6/nf_reject.h b/include/net/netfilter/ipv6/nf_reject.h
index 0ae445d..0ea4fa3 100644
--- a/include/net/netfilter/ipv6/nf_reject.h
+++ b/include/net/netfilter/ipv6/nf_reject.h
@@ -13,7 +13,7 @@ const struct tcphdr *nf_reject_ip6_tcphdr_get(struct sk_buff *oldskb,
 					      unsigned int *otcplen, int hook);
 struct ipv6hdr *nf_reject_ip6hdr_put(struct sk_buff *nskb,
 				     const struct sk_buff *oldskb,
-				     __be16 protocol, int hoplimit);
+				     __u8 protocol, int hoplimit);
 void nf_reject_ip6_tcphdr_put(struct sk_buff *nskb,
 			      const struct sk_buff *oldskb,
 			      const struct tcphdr *oth, unsigned int otcplen);
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index 5c6c965..54a2fdf 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -99,7 +99,7 @@ static void nft_reject_br_send_v4_unreach(struct sk_buff *oldskb,
 	if (!pskb_may_pull(oldskb, len))
 		return;
 
-	if (pskb_trim_rcsum(oldskb, htons(ip_hdr(oldskb)->tot_len)))
+	if (pskb_trim_rcsum(oldskb, ntohs(ip_hdr(oldskb)->tot_len)))
 		return;
 
 	if (ip_hdr(oldskb)->protocol == IPPROTO_TCP ||
diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
index b7405eb..c5b794d 100644
--- a/net/ipv4/netfilter/nf_reject_ipv4.c
+++ b/net/ipv4/netfilter/nf_reject_ipv4.c
@@ -43,7 +43,7 @@ EXPORT_SYMBOL_GPL(nf_reject_ip_tcphdr_get);
 
 struct iphdr *nf_reject_iphdr_put(struct sk_buff *nskb,
 				  const struct sk_buff *oldskb,
-				  __be16 protocol, int ttl)
+				  __u8 protocol, int ttl)
 {
 	struct iphdr *niph, *oiph = ip_hdr(oldskb);
 
diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
index 68e0bb4..3afdce0 100644
--- a/net/ipv6/netfilter/nf_reject_ipv6.c
+++ b/net/ipv6/netfilter/nf_reject_ipv6.c
@@ -65,7 +65,7 @@ EXPORT_SYMBOL_GPL(nf_reject_ip6_tcphdr_get);
 
 struct ipv6hdr *nf_reject_ip6hdr_put(struct sk_buff *nskb,
 				     const struct sk_buff *oldskb,
-				     __be16 protocol, int hoplimit)
+				     __u8 protocol, int hoplimit)
 {
 	struct ipv6hdr *ip6h;
 	const struct ipv6hdr *oip6h = ipv6_hdr(oldskb);
-- 
1.7.10.4
