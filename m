From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 3/7] udp: Add socket lookup functions with noref
Date: Tue, 18 Oct 2016 10:02:39 -0700
Message-ID: <20161018170243.1369807-4-tom@herbertland.com>
References: <20161018170243.1369807-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57488 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760095AbcJRRCx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 13:02:53 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9IGwlmK007513
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 10:02:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 265qa8g6cn-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 10:02:53 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 b48cdb52955411e6a09924be0593f280-a0ffba50 for <netdev@vger.kernel.org>;        Tue,
 18 Oct 2016 10:02:52 -0700
In-Reply-To: <20161018170243.1369807-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create udp4_lib_lookup_noref and udp6_lib_lookup_noref. These perfrom
a socket lookup on addresses and ports without taking a reference.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/udp.h |  8 ++++++++
 net/ipv4/udp.c    |  8 ++++++++
 net/ipv6/udp.c    | 10 ++++++++++
 3 files changed, 26 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index ea53a87..717a972 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -275,6 +275,10 @@ struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			       struct udp_table *tbl, struct sk_buff *skb);
 struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
+struct sock *udp4_lib_lookup_noref(struct net *net,
+				   __be32 saddr, __be16 sport,
+				   __be32 daddr, __be16 dport,
+				   int dif);
 struct sock *udp6_lib_lookup(struct net *net,
 			     const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport,
@@ -286,6 +290,10 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			       struct sk_buff *skb);
 struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
 				 __be16 sport, __be16 dport);
+struct sock *udp6_lib_lookup_noref(struct net *net,
+				   const struct in6_addr *saddr, __be16 sport,
+				   const struct in6_addr *daddr, __be16 dport,
+				   int dif);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 7d96dc2..7f84c51 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -595,6 +595,14 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 EXPORT_SYMBOL_GPL(udp4_lib_lookup);
 #endif
 
+struct sock *udp4_lib_lookup_noref(struct net *net, __be32 saddr, __be16 sport,
+				   __be32 daddr, __be16 dport, int dif)
+{
+	return __udp4_lib_lookup(net, saddr, sport, daddr, dport,
+				 dif, &udp_table, NULL);
+}
+EXPORT_SYMBOL_GPL(udp4_lib_lookup_noref);
+
 static inline bool __udp_is_mcast_sock(struct net *net, struct sock *sk,
 				       __be16 loc_port, __be32 loc_addr,
 				       __be16 rmt_port, __be32 rmt_addr,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9aa7c1c..6e382d9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -317,6 +317,16 @@ struct sock *udp6_lib_lookup(struct net *net, const struct in6_addr *saddr, __be
 EXPORT_SYMBOL_GPL(udp6_lib_lookup);
 #endif
 
+struct sock *udp6_lib_lookup_noref(struct net *net,
+				   const struct in6_addr *saddr, __be16 sport,
+				   const struct in6_addr *daddr, __be16 dport,
+				   int dif)
+{
+	return __udp6_lib_lookup(net, saddr, sport, daddr, dport,
+				 dif, &udp_table, NULL);
+}
+EXPORT_SYMBOL_GPL(udp6_lib_lookup_noref);
+
 /*
  *	This should be easy, if there is something there we
  *	return it, otherwise we block.
-- 
2.9.3
