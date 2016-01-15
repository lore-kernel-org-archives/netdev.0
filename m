From: Igor Gavrilov <i.o.gavrilov@gmail.com>
Subject: [PATCH net-next] sched/cls_flow.c : allow nfct-* keys work on ingress
 interfaces
Date: Fri, 15 Jan 2016 17:18:17 +0200
Message-ID: <56990DB9.4070605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f196.google.com ([209.85.217.196]:33238 "EHLO
	mail-lb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbcAOPSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2016 10:18:21 -0500
Received: by mail-lb0-f196.google.com with SMTP id bc4so21589151lbc.0
        for <netdev@vger.kernel.org>; Fri, 15 Jan 2016 07:18:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Improved CTTUPLE macro with code from sched/act_connmark.c, so it be
able to get unNATed addresses from nf_conntrack on ingress interface.


Signed-off-by: Igor Gavrilov <i.o.gavrilov@gmail.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
--- cls_flow.c.orig	2016-01-15 17:01:04.176871692 +0200
+++ cls_flow.c	2016-01-15 17:01:04.174871692 +0200
@@ -31,6 +31,8 @@

 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #endif

 struct flow_head {
@@ -133,16 +135,50 @@
 }

 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-#define CTTUPLE(skb, member)						\
+#define CTTUPLE(skb, direction, member)				\
 ({									\
 	enum ip_conntrack_info ctinfo;					\
-	const struct nf_conn *ct = nf_ct_get(skb, &ctinfo);		\
-	if (ct == NULL)							\
-		goto fallback;						\
-	ct->tuplehash[CTINFO2DIR(ctinfo)].tuple.member;			\
+	struct nf_conntrack_tuple tuple;				\
+	struct nf_conntrack_zone zone;					\
+	const struct nf_conntrack_tuple_hash *thash;			\
+	__be32 result;							\
+	int proto;							\
+	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);			\
+	if (ct == NULL) {						\
+		switch (tc_skb_protocol(skb)) {				\
+		case htons(ETH_P_IP):					\
+			proto = NFPROTO_IPV4;				\
+			break;						\
+		case htons(ETH_P_IPV6):					\
+			proto = NFPROTO_IPV6;				\
+			break;						\
+		default:						\
+			goto fallback;					\
+		}							\
+									\
+		if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),	\
+				proto, dev_net(skb->dev), &tuple))	\
+			goto fallback;					\
+		zone.id = NF_CT_DEFAULT_ZONE_ID;			\
+		zone.dir = NF_CT_DEFAULT_ZONE_DIR;			\
+									\
+		thash = nf_conntrack_find_get(dev_net(skb->dev),	\
+						 &zone,	&tuple);	\
+		if (!thash)						\
+			goto fallback;					\
+		ct = nf_ct_tuplehash_to_ctrack(thash);			\
+		result = ct->tuplehash[(thash->tuple.dst.dir ==		\
+				IP_CT_DIR_REPLY) ? IP_CT_DIR_ORIGINAL :	\
+				IP_CT_DIR_REPLY].tuple.src.member;	\
+		nf_ct_put(ct);						\
+	} else {							\
+		result =						\
+		ct->tuplehash[CTINFO2DIR(ctinfo)].tuple.direction.member;\
+	}								\
+	result;								\
 })
 #else
-#define CTTUPLE(skb, member)						\
+#define CTTUPLE(skb, direction, member)				\
 ({									\
 	goto fallback;							\
 	0;								\
@@ -153,9 +189,9 @@
 {
 	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
-		return ntohl(CTTUPLE(skb, src.u3.ip));
+		return ntohl(CTTUPLE(skb, src, u3.ip));
 	case htons(ETH_P_IPV6):
-		return ntohl(CTTUPLE(skb, src.u3.ip6[3]));
+		return ntohl(CTTUPLE(skb, src, u3.ip6[3]));
 	}
 fallback:
 	return flow_get_src(skb, flow);
@@ -165,9 +201,9 @@
 {
 	switch (tc_skb_protocol(skb)) {
 	case htons(ETH_P_IP):
-		return ntohl(CTTUPLE(skb, dst.u3.ip));
+		return ntohl(CTTUPLE(skb, dst, u3.ip));
 	case htons(ETH_P_IPV6):
-		return ntohl(CTTUPLE(skb, dst.u3.ip6[3]));
+		return ntohl(CTTUPLE(skb, dst, u3.ip6[3]));
 	}
 fallback:
 	return flow_get_dst(skb, flow);
@@ -175,14 +211,14 @@

 static u32 flow_get_nfct_proto_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	return ntohs(CTTUPLE(skb, src.u.all));
+	return ntohs(CTTUPLE(skb, src, u.all));
 fallback:
 	return flow_get_proto_src(skb, flow);
 }

 static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	return ntohs(CTTUPLE(skb, dst.u.all));
+	return ntohs(CTTUPLE(skb, dst, u.all));
 fallback:
 	return flow_get_proto_dst(skb, flow);
 }
