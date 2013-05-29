From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 4/7] ipv6: Correct comparisons and calculations using skb->tail and skb-transport_header
Date: Wed, 29 May 2013 14:27:45 +0900
Message-ID: <1369805268-6291-5-git-send-email-horms@verge.net.au>
References: <1369805268-6291-1-git-send-email-horms@verge.net.au>
Cc: netdev@vger.kernel.org, Simon Horman <horms@verge.net.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:46201 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246Ab3E2F1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 01:27:13 -0400
In-Reply-To: <1369805268-6291-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This corrects an regression introduced by "net: Use 16bits for *_headers
fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
that case skb->tail will be a pointer whereas skb->transport_header
will be an offset from head. This is corrected by using wrappers that
ensure that comparisons and calculations are always made using pointers.

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/ipv6/exthdrs_core.c |    2 +-
 net/ipv6/icmp.c         |    2 +-
 net/ipv6/mcast.c        |    5 +++--
 net/ipv6/mip6.c         |    6 ++++--
 net/ipv6/ndisc.c        |    9 +++++----
 net/ipv6/output_core.c  |    3 ++-
 net/ipv6/raw.c          |    3 ++-
 net/ipv6/route.c        |    2 +-
 8 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index c5e83fa..140748d 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -115,7 +115,7 @@ EXPORT_SYMBOL(ipv6_skip_exthdr);
 int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
 {
 	const unsigned char *nh = skb_network_header(skb);
-	int packet_len = skb->tail - skb->network_header;
+	int packet_len = skb_tail_pointer(skb) - skb_network_header(skb);
 	struct ipv6_opt_hdr *hdr;
 	int len;
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 1d2902e..4b4890b 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -399,7 +399,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	int err = 0;
 
 	if ((u8 *)hdr < skb->head ||
-	    (skb->network_header + sizeof(*hdr)) > skb->tail)
+	    (skb_network_header(skb) + sizeof(*hdr)) > skb_tail_pointer(skb))
 		return;
 
 	/*
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index bfa6cc3..72c8bfe 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1409,8 +1409,9 @@ static void mld_sendpack(struct sk_buff *skb)
 	idev = __in6_dev_get(skb->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
-	payload_len = (skb->tail - skb->network_header) - sizeof(*pip6);
-	mldlen = skb->tail - skb->transport_header;
+	payload_len = (skb_tail_pointer(skb) - skb_network_header(skb)) -
+		sizeof(*pip6);
+	mldlen = skb_tail_pointer(skb) - skb_transport_header(skb);
 	pip6->payload_len = htons(payload_len);
 
 	pmr->mld2r_cksum = csum_ipv6_magic(&pip6->saddr, &pip6->daddr, mldlen,
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 0f9bdc5..9ac01dc 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -268,7 +268,8 @@ static int mip6_destopt_offset(struct xfrm_state *x, struct sk_buff *skb,
 	struct ipv6_opt_hdr *exthdr =
 				   (struct ipv6_opt_hdr *)(ipv6_hdr(skb) + 1);
 	const unsigned char *nh = skb_network_header(skb);
-	unsigned int packet_len = skb->tail - skb->network_header;
+	unsigned int packet_len = skb_tail_pointer(skb) -
+		skb_network_header(skb);
 	int found_rhdr = 0;
 
 	*nexthdr = &ipv6_hdr(skb)->nexthdr;
@@ -404,7 +405,8 @@ static int mip6_rthdr_offset(struct xfrm_state *x, struct sk_buff *skb,
 	struct ipv6_opt_hdr *exthdr =
 				   (struct ipv6_opt_hdr *)(ipv6_hdr(skb) + 1);
 	const unsigned char *nh = skb_network_header(skb);
-	unsigned int packet_len = skb->tail - skb->network_header;
+	unsigned int packet_len = skb_tail_pointer(skb) -
+		skb_network_header(skb);
 	int found_rhdr = 0;
 
 	*nexthdr = &ipv6_hdr(skb)->nexthdr;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a096269..781dd3c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -693,7 +693,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
 	const struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
 	u8 *lladdr = NULL;
-	u32 ndoptlen = skb->tail - (skb->transport_header +
+	u32 ndoptlen = skb_tail_pointer(skb) - (skb_transport_header(skb) +
 				    offsetof(struct nd_msg, opt));
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
@@ -853,7 +853,7 @@ static void ndisc_recv_na(struct sk_buff *skb)
 	const struct in6_addr *saddr = &ipv6_hdr(skb)->saddr;
 	const struct in6_addr *daddr = &ipv6_hdr(skb)->daddr;
 	u8 *lladdr = NULL;
-	u32 ndoptlen = skb->tail - (skb->transport_header +
+	u32 ndoptlen = skb_tail_pointer(skb) - (skb_transport_header(skb) +
 				    offsetof(struct nd_msg, opt));
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
@@ -1069,7 +1069,8 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 
 	__u8 * opt = (__u8 *)(ra_msg + 1);
 
-	optlen = (skb->tail - skb->transport_header) - sizeof(struct ra_msg);
+	optlen = (skb_tail_pointer(skb) - skb_transport_header(skb)) -
+		sizeof(struct ra_msg);
 
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK(2, warn, "RA: source address is not link-local\n");
@@ -1346,7 +1347,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	u8 *hdr;
 	struct ndisc_options ndopts;
 	struct rd_msg *msg = (struct rd_msg *)skb_transport_header(skb);
-	u32 ndoptlen = skb->tail - (skb->transport_header +
+	u32 ndoptlen = skb_tail_pointer(skb) - (skb_transport_header(skb) +
 				    offsetof(struct rd_msg, opt));
 
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index c2e73e6..ab92a36 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -40,7 +40,8 @@ int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr)
 	u16 offset = sizeof(struct ipv6hdr);
 	struct ipv6_opt_hdr *exthdr =
 				(struct ipv6_opt_hdr *)(ipv6_hdr(skb) + 1);
-	unsigned int packet_len = skb->tail - skb->network_header;
+	unsigned int packet_len = skb_tail_pointer(skb) -
+		skb_network_header(skb);
 	int found_rhdr = 0;
 	*nexthdr = &ipv6_hdr(skb)->nexthdr;
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index eedff8c..4f8886a 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1132,7 +1132,8 @@ static int rawv6_ioctl(struct sock *sk, int cmd, unsigned long arg)
 		spin_lock_bh(&sk->sk_receive_queue.lock);
 		skb = skb_peek(&sk->sk_receive_queue);
 		if (skb != NULL)
-			amount = skb->tail - skb->transport_header;
+			amount = skb_tail_pointer(skb) -
+				skb_transport_header(skb);
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		return put_user(amount, (int __user *)arg);
 	}
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 194c3cd..2b87418 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1649,7 +1649,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	int optlen, on_link;
 	u8 *lladdr;
 
-	optlen = skb->tail - skb->transport_header;
+	optlen = skb_tail_pointer(skb) - skb_transport_header(skb);
 	optlen -= sizeof(*msg);
 
 	if (optlen < 0) {
-- 
1.7.10.4
