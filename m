From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/8] udp: Add udp6_lib_lookup_skb and udp4_lib_lookup_skb
Date: Tue, 5 Apr 2016 08:22:50 -0700
Message-ID: <1459869776-2090500-3-git-send-email-tom@herbertland.com>
References: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49775 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758980AbcDEPXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:23:16 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u35FJElo021587
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:23:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 222xhceky2-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:23:09 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 4cb3c0a6fb4211e5b9fc24be05956610-e6fc13f0 for <netdev@vger.kernel.org>;	Tue,
 05 Apr 2016 08:23:08 -0700
In-Reply-To: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add externally visible functions to lookup a UDP socket by skb. This
will be used for GRO in UDP sockets. These functions also check
if skb->dst is set, and if it is not skb->dev is used to get dev_net.
This allows calling lookup functions before dst has been set on the
skbuff.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/udp.h |  4 ++++
 net/ipv4/udp.c    | 13 +++++++++++++
 net/ipv6/udp.c    | 13 +++++++++++++
 3 files changed, 30 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index d870ec1..e2e3803 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -260,6 +260,8 @@ struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
 			       __be32 daddr, __be16 dport, int dif,
 			       struct udp_table *tbl, struct sk_buff *skb);
+struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
+				 __be16 sport, __be16 dport);
 struct sock *udp6_lib_lookup(struct net *net,
 			     const struct in6_addr *saddr, __be16 sport,
 			     const struct in6_addr *daddr, __be16 dport,
@@ -269,6 +271,8 @@ struct sock *__udp6_lib_lookup(struct net *net,
 			       const struct in6_addr *daddr, __be16 dport,
 			       int dif, struct udp_table *tbl,
 			       struct sk_buff *skb);
+struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
+				 __be16 sport, __be16 dport);
 
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 355bdb2..b39c566 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -604,6 +604,19 @@ static inline struct sock *__udp4_lib_lookup_skb(struct sk_buff *skb,
 				 udptable, skb);
 }
 
+struct sock *udp4_lib_lookup_skb(struct sk_buff *skb,
+				 __be16 sport, __be16 dport)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	const struct net_device *dev =
+	    skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
+
+	return __udp4_lib_lookup(dev_net(dev), iph->saddr, sport,
+				 iph->daddr, dport, inet_iif(skb),
+				 &udp_table, skb);
+}
+EXPORT_SYMBOL_GPL(udp4_lib_lookup_skb);
+
 /* Must be called under rcu_read_lock().
  * Does increment socket refcount.
  */
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 78a7dfd..33a58eb 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -326,6 +326,19 @@ static struct sock *__udp6_lib_lookup_skb(struct sk_buff *skb,
 				 udptable, skb);
 }
 
+struct sock *udp6_lib_lookup_skb(struct sk_buff *skb,
+				 __be16 sport, __be16 dport)
+{
+	const struct ipv6hdr *iph = ipv6_hdr(skb);
+	const struct net_device *dev =
+	    skb_dst(skb) ? skb_dst(skb)->dev : skb->dev;
+
+	return __udp6_lib_lookup(dev_net(dev), &iph->saddr, sport,
+				 &iph->daddr, dport, inet6_iif(skb),
+				 &udp_table, skb);
+}
+EXPORT_SYMBOL_GPL(udp6_lib_lookup_skb);
+
 /* Must be called under rcu_read_lock().
  * Does increment socket refcount.
  */
-- 
2.8.0.rc2
