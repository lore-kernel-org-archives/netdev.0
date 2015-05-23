From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next v5 01/11] ipv6: Clean up ipv6_select_ident() and ip6_fragment()
Date: Fri, 22 May 2015 20:55:56 -0700
Message-ID: <1432353366-2296465-2-git-send-email-kafai@fb.com>
References: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Julian Anastasov <ja@ssi.bg>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Kernel Team <Kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:53384 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757176AbbEWD4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 23:56:15 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4N3rNGk028980
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 20:56:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1ujcx68c77-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 20:56:15 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a6aff5e000ff11e580230002c9521c9e-a67f23a0 for <netdev@vger.kernel.org>;	Fri,
 22 May 2015 20:56:12 -0700
In-Reply-To: <1432353366-2296465-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the ipv6_select_ident() signature to return a
fragment id instead of taking a whole frag_hdr as a param to
only set the frag_hdr->identification.

It also cleans up ip6_fragment() to obtain the fragment id at the
beginning instead of using multiple "if" later to check fragment id
has been generated or not.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Cc: Julian Anastasov <ja@ssi.bg>
---
 include/net/ipv6.h     |  3 +--
 net/ipv6/ip6_output.c  | 17 ++++++-----------
 net/ipv6/output_core.c |  5 ++---
 3 files changed, 9 insertions(+), 16 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index aab8190..8c4f881 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -671,8 +671,7 @@ static inline int ipv6_addr_diff(const struct in6_addr *a1, const struct in6_add
 	return __ipv6_addr_diff(a1, a2, sizeof(struct in6_addr));
 }
 
-void ipv6_select_ident(struct net *net, struct frag_hdr *fhdr,
-		       struct rt6_info *rt);
+u32 ipv6_select_ident(struct net *net, struct rt6_info *rt);
 void ipv6_proxy_select_ident(struct net *net, struct sk_buff *skb);
 
 int ip6_dst_hoplimit(struct dst_entry *dst);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index c217775..e4772ab 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -551,7 +551,7 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 	struct frag_hdr *fh;
 	unsigned int mtu, hlen, left, len;
 	int hroom, troom;
-	__be32 frag_id = 0;
+	__be32 frag_id;
 	int ptr, offset = 0, err = 0;
 	u8 *prevhdr, nexthdr = 0;
 	struct net *net = dev_net(skb_dst(skb)->dev);
@@ -584,6 +584,8 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 	}
 	mtu -= hlen + sizeof(struct frag_hdr);
 
+	frag_id = ipv6_select_ident(net, rt);
+
 	if (skb_has_frag_list(skb)) {
 		int first_len = skb_pagelen(skb);
 		struct sk_buff *frag2;
@@ -632,11 +634,10 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 		skb_reset_network_header(skb);
 		memcpy(skb_network_header(skb), tmp_hdr, hlen);
 
-		ipv6_select_ident(net, fh, rt);
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
 		fh->frag_off = htons(IP6_MF);
-		frag_id = fh->identification;
+		fh->identification = frag_id;
 
 		first_len = skb_pagelen(skb);
 		skb->data_len = first_len - skb_headlen(skb);
@@ -778,11 +779,7 @@ slow_path:
 		 */
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
-		if (!frag_id) {
-			ipv6_select_ident(net, fh, rt);
-			frag_id = fh->identification;
-		} else
-			fh->identification = frag_id;
+		fh->identification = frag_id;
 
 		/*
 		 *	Copy a block of the IP datagram.
@@ -1064,7 +1061,6 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 
 {
 	struct sk_buff *skb;
-	struct frag_hdr fhdr;
 	int err;
 
 	/* There is support for UDP large send offload by network
@@ -1106,8 +1102,7 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 	skb_shinfo(skb)->gso_size = (mtu - fragheaderlen -
 				     sizeof(struct frag_hdr)) & ~7;
 	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
-	ipv6_select_ident(sock_net(sk), &fhdr, rt);
-	skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
+	skb_shinfo(skb)->ip6_frag_id = ipv6_select_ident(sock_net(sk), rt);
 
 append:
 	return skb_append_datato_frags(sk, skb, getfrag, from,
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 85892af..ef0e232 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -60,8 +60,7 @@ void ipv6_proxy_select_ident(struct net *net, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(ipv6_proxy_select_ident);
 
-void ipv6_select_ident(struct net *net, struct frag_hdr *fhdr,
-		       struct rt6_info *rt)
+u32 ipv6_select_ident(struct net *net, struct rt6_info *rt)
 {
 	static u32 ip6_idents_hashrnd __read_mostly;
 	u32 id;
@@ -70,7 +69,7 @@ void ipv6_select_ident(struct net *net, struct frag_hdr *fhdr,
 
 	id = __ipv6_select_ident(net, ip6_idents_hashrnd, &rt->rt6i_dst.addr,
 				 &rt->rt6i_src.addr);
-	fhdr->identification = htonl(id);
+	return htonl(id);
 }
 EXPORT_SYMBOL(ipv6_select_ident);
 
-- 
1.8.1
