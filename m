From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/5] ipv6: translate ICMP_TIME_EXCEEDED to ICMPV6_TIME_EXCEED
Date: Sat, 18 Jun 2016 16:26:38 -0700
Message-ID: <1466292400-3638-4-git-send-email-edumazet@google.com>
References: <1466292400-3638-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Oussama Ghorbel <ghorbel@pivasoftware.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33331 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751090AbcFRX1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 19:27:17 -0400
Received: by mail-pa0-f48.google.com with SMTP id b13so39065258pat.0
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2016 16:27:16 -0700 (PDT)
In-Reply-To: <1466292400-3638-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For better traceroute/mtr support for SIT and GRE tunnels,
we translate IPV4 ICMP ICMP_TIME_EXCEEDED to ICMPV6_TIME_EXCEED

We also have to translate the IPv4 source IP address of ICMP
message to IPv6 v4mapped.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/icmpv6.h |  2 +-
 net/ipv6/icmp.c        | 12 +++++++++---
 net/ipv6/sit.c         |  6 +++---
 3 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
index 9796481edbdb..97ae98071a03 100644
--- a/include/linux/icmpv6.h
+++ b/include/linux/icmpv6.h
@@ -18,7 +18,7 @@ typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info,
 			     const struct in6_addr *force_saddr);
 extern int inet6_register_icmp_sender(ip6_icmp_send_t *fn);
 extern int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn);
-int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs);
+int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type);
 
 #else
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 07bc63c23712..867aebc34248 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -564,8 +564,9 @@ void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
  *  Either an IPv4 header for SIT encap
  *         an IPv4 header + GRE header for GRE encap
  */
-int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs)
+int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs, int type)
 {
+	struct in6_addr temp_saddr;
 	struct rt6_info *rt;
 	struct sk_buff *skb2;
 
@@ -586,8 +587,13 @@ int ip6_err_gen_icmpv6_unreach(struct sk_buff *skb, int nhs)
 	if (rt && rt->dst.dev)
 		skb2->dev = rt->dst.dev;
 
-	icmpv6_send(skb2, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH, 0);
-
+	ipv6_addr_set_v4mapped(ip_hdr(skb)->saddr, &temp_saddr);
+	if (type == ICMP_TIME_EXCEEDED)
+		icmp6_send(skb2, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
+			   0, &temp_saddr);
+	else
+		icmp6_send(skb2, ICMPV6_DEST_UNREACH, ICMPV6_ADDR_UNREACH,
+			   0, &temp_saddr);
 	if (rt)
 		ip6_rt_put(rt);
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 78e84d6793ee..d7a36114eb50 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -535,11 +535,11 @@ static int ipip6_err(struct sk_buff *skb, u32 info)
 		goto out;
 	}
 
-	if (t->parms.iph.daddr == 0)
+	err = 0;
+	if (!ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4, type))
 		goto out;
 
-	err = 0;
-	if (!ip6_err_gen_icmpv6_unreach(skb, iph->ihl * 4))
+	if (t->parms.iph.daddr == 0)
 		goto out;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-- 
2.8.0.rc3.226.g39d4020
