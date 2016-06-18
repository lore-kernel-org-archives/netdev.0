From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/5] ipv6: RFC 4884 partial support for SIT/GRE tunnels
Date: Sat, 18 Jun 2016 16:26:40 -0700
Message-ID: <1466292400-3638-6-git-send-email-edumazet@google.com>
References: <1466292400-3638-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36604 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbcFRX1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 19:27:23 -0400
Received: by mail-pa0-f50.google.com with SMTP id wo6so2705499pac.3
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 16:27:23 -0700 (PDT)
In-Reply-To: <1466292400-3638-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving an ICMPv4 message containing extensions as
defined in RFC 4884, and translating it to ICMPv6 at SIT
or GRE tunnel, we need some extra manipulation in order
to properly forward the extensions.

This patch only takes care of Time Exceeded messages as they
are the ones that typically carry information from various
routers in a fabric during a traceroute session.

It also avoids complex skb logic if the data_len is not
a multiple of 8.

RFC states :

   The "original datagram" field MUST contain at least 128 octets.
   If the original datagram did not contain 128 octets, the
   "original datagram" field MUST be zero padded to 128 octets.

In practice routers use 128 bytes of original datagram, not more.

Initial translation was added in commit ca15a078bd90
("sit: generate icmpv6 error when receiving icmpv4 error")

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Oussama Ghorbel <ghorbel@pivasoftware.com>
---
 include/linux/icmpv6.h    |  3 ++-
 include/uapi/linux/icmp.h |  1 +
 net/ipv4/ip_gre.c         |  5 ++++-
 net/ipv6/icmp.c           | 28 ++++++++++++++++++++++++----
 net/ipv6/sit.c            |  4 +++-
 5 files changed, 34 insertions(+), 7 deletions(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 97ae98071a03..57086e9fc64c 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -18,7 +18,8 @@ typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 			     const struct in6_addr *force_saddr);
 extern int inet6_register_icmp_sender(ip6_icmp_send_t *fn);
 extern int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn);
-int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type);
+int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type,
+			       unsigned int data_len);
 
 #else
 
diff --git a/include/uapi/linux/icmp.h b/include/uapi/linux/icmp.h
index 16fff055f734..fddd9d736284 100644
--- a/include/uapi/linux/icmp.h
+++ b/include/uapi/linux/icmp.h
@@ -79,6 +79,7 @@ struct icmphdr {
 		__be16	__unused;
 		__be16	mtu;
 	} frag;
+	__u8	reserved[4];
   } un;
 };
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index b199a3c85dfc..24d1516ff6c5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -138,6 +138,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info,
 	const struct iphdr *iph;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
+	unsigned int data_len = 0;
 	struct ip_tunnel *t;
 
 	switch (type) {
@@ -163,6 +164,7 @@ static void ipgre_err(struct sk_buff *skb, u32 info,
 	case ICMP_TIME_EXCEEDED:
 		if (code != ICMP_EXC_TTL)
 			return;
+		data_len = icmp_hdr(skb)->un.reserved[1] * 4; /* RFC 4884 4.1 */
 		break;
 
 	case ICMP_REDIRECT:
@@ -183,7 +185,8 @@ static void ipgre_err(struct sk_buff *skb, u32 info,
 
 #if IS_ENABLED(CONFIG_IPV6)
        if (tpi->proto == htons(ETH_P_IPV6) &&
-           !ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4 + tpi->hdr_len, type))
+           !ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4 + tpi->hdr_len,
+				       type, data_len))
                return;
 #endif
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 867aebc34248..d2b157659e11 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -564,16 +564,22 @@ void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
  *  Either an IPv4 header for SIT encap
  *         an IPv4 header + GRE header for GRE encap
  */
-int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type)
+int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type,
+			       unsigned int data_len)
 {
 	struct in6_addr temp_saddr;
 	struct rt6_info *rt;
 	struct sk_buff *skb2;
+	u32 info = 0;
 
 	if (!pskb_may_pull(skb, nhs + sizeof(struct ipv6hdr) + 8))
 		return 1;
 
-	skb2 = skb_clone(skb, GFP_ATOMIC);
+	/* RFC 4884 (partial) support for ICMP extensions */
+	if (data_len < 128 || (data_len & 7) || skb->len < data_len)
+		data_len = 0;
+
+	skb2 = data_len ? skb_copy(skb, GFP_ATOMIC) : skb_clone(skb, GFP_ATOMIC);
 
 	if (!skb2)
 		return 1;
@@ -588,12 +594,26 @@ int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type)
 		skb2->dev = rt->dst.dev;
 
 	ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr, &temp_saddr);
+
+	if (data_len) {
+		/* RFC 4884 (partial) support :
+		 * insert 0 padding at the end, before the extensions
+		 */
+		__skb_push(skb2, nhs);
+		skb_reset_network_header(skb2);
+		memcpy(skb2->data, skb2->data + nhs, data_len - nhs);
+		memset(skb2->data + data_len - nhs, 0, nhs);
+		/* RFC 4884 4.5 : Length is measured in 64-bit words,
+		 * and stored in reserved[0]
+		 */
+		info = (data_len/8) << 24;
+	}
 	if (type == ICMP_TIME_EXCEEDED)
 		icmp6_send(skb2, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
-			   0, &temp_saddr);
+			   info, &temp_saddr);
 	else
 		icmp6_send(skb2, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH,
-			   0, &temp_saddr);
+			   info, &temp_saddr);
 	if (rt)
 		ip6_rt_put(rt);
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index d7a36114eb50..cdd714690f95 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -484,6 +484,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
+	unsigned int data_len = 0;
 	struct ip_tunnel *t;
 	int err;
 
@@ -508,6 +509,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	case ICMP_TIME_EXCEEDED:
 		if (code != ICMP_EXC_TTL)
 			return 0;
+		data_len = icmp_hdr(skb)->un.reserved[1] * 4; /* RFC 4884 4.1 */
 		break;
 	case ICMP_REDIRECT:
 		break;
@@ -536,7 +538,7 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 	}
 
 	err = 0;
-	if (!ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4, type))
+	if (!ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4, type, data_len))
 		goto out;
 
 	if (t->parms.iph.daddr == 0)
-- 
2.8.0.rc3.226.g39d4020
