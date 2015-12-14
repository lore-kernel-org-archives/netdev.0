From: Igor Gavrilov <i.o.gavrilov@gmail.com>
Subject: [PATCH net-next] sched/cls_flow.c
Date: Mon, 14 Dec 2015 10:43:35 +0200
Message-ID: <CADo-kff8vOq8YzvB8R+LOCUyfhx9+=QRhsLLa-eP9M+i3m5rcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:34909 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbbLNIng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 03:43:36 -0500
Received: by mail-ig0-f169.google.com with SMTP id 9so1856080igl.0
        for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 00:43:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Gavrilov <i.o.gavrilov@gmail.com>

Improved CTTUPLE macro with code from sched/act_connmark.c, so it be
able to get unNATed addresses from nf_conntrack on ingress interface.

Signed-off-by: Igor Gavrilov <i.o.gavrilov@gmail.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
--- net/sched/cls_flow.c.orig   2015-12-11 12:51:32.541673211 +0200
+++ net/sched/cls_flow.c        2015-12-14 12:01:50.719174387 +0200
@@ -31,6 +31,8 @@

 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #endif

 struct flow_head {
@@ -133,16 +135,48 @@ static u32 flow_get_nfct(const struct sk
 }

 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-#define CTTUPLE(skb, member)                                           \
+#define CTTUPLE(skb, direction, member)
         \
 ({                                                                     \
        enum ip_conntrack_info ctinfo;                                  \
-       const struct nf_conn *ct = nf_ct_get(skb, &ctinfo);             \
-       if (ct == NULL)                                                 \
-               goto fallback;                                          \
-       ct->tuplehash[CTINFO2DIR(ctinfo)].tuple.member;                 \
+       struct nf_conntrack_tuple tuple;                                \
+       struct nf_conntrack_zone zone;                                  \
+       const struct nf_conntrack_tuple_hash *thash;                    \
+       __be32 result;                                                  \
+       int proto;                                                      \
+       struct nf_conn *ct = nf_ct_get(skb, &ctinfo);                   \
+       if (ct == NULL) {                                               \
+               switch (tc_skb_protocol(skb)) {                         \
+               case htons(ETH_P_IP):                                   \
+                       proto = NFPROTO_IPV4;                           \
+                       break;                                          \
+               case htons(ETH_P_IPV6):                                 \
+                       proto = NFPROTO_IPV6;                           \
+                       break;                                          \
+               default:                                                \
+                       goto fallback;                                  \
+               }                                                       \
+                                                                       \
+               if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb), proto,\
+                       dev_net(skb->dev), &tuple))                     \
+                       goto fallback;                                  \
+               zone.id = NF_CT_DEFAULT_ZONE_ID;                        \
+               zone.dir = NF_CT_DEFAULT_ZONE_DIR;                      \
+                                                                       \
+               thash = nf_conntrack_find_get(dev_net(skb->dev), &zone, \
+                       &tuple);                                        \
+               if (!thash)                                             \
+                       goto fallback;                                  \
+               ct = nf_ct_tuplehash_to_ctrack(thash);                  \
+               result = ct->tuplehash[(thash->tuple.dst.dir ==
IP_CT_DIR_REPLY) ? \
+                IP_CT_DIR_ORIGINAL : IP_CT_DIR_REPLY].tuple.src.member;\
+               nf_ct_put(ct);                                          \
+       } else {                                                        \
+               result =
ct->tuplehash[CTINFO2DIR(ctinfo)].tuple.direction.member;\
+       }                                                               \
+       result;                                                         \
 })
 #else
-#define CTTUPLE(skb, member)                                           \
+#define CTTUPLE(skb, direction, member)
         \
 ({                                                                     \
        goto fallback;                                                  \
        0;                                                              \
@@ -153,9 +187,9 @@ static u32 flow_get_nfct_src(const struc
 {
        switch (tc_skb_protocol(skb)) {
        case htons(ETH_P_IP):
-               return ntohl(CTTUPLE(skb, src.u3.ip));
+               return ntohl(CTTUPLE(skb, src, u3.ip));
        case htons(ETH_P_IPV6):
-               return ntohl(CTTUPLE(skb, src.u3.ip6[3]));
+               return ntohl(CTTUPLE(skb, src, u3.ip6[3]));
        }
 fallback:
        return flow_get_src(skb, flow);
@@ -165,9 +199,9 @@ static u32 flow_get_nfct_dst(const struc
 {
        switch (tc_skb_protocol(skb)) {
        case htons(ETH_P_IP):
-               return ntohl(CTTUPLE(skb, dst.u3.ip));
+               return ntohl(CTTUPLE(skb, dst, u3.ip));
        case htons(ETH_P_IPV6):
-               return ntohl(CTTUPLE(skb, dst.u3.ip6[3]));
+               return ntohl(CTTUPLE(skb, dst, u3.ip6[3]));
        }
 fallback:
        return flow_get_dst(skb, flow);
@@ -175,14 +209,14 @@ fallback:

 static u32 flow_get_nfct_proto_src(const struct sk_buff *skb, const
struct flow_keys *flow)
 {
-       return ntohs(CTTUPLE(skb, src.u.all));
+       return ntohs(CTTUPLE(skb, src, u.all));
 fallback:
        return flow_get_proto_src(skb, flow);
 }

 static u32 flow_get_nfct_proto_dst(const struct sk_buff *skb, const
struct flow_keys *flow)
 {
-       return ntohs(CTTUPLE(skb, dst.u.all));
+       return ntohs(CTTUPLE(skb, dst, u.all));
 fallback:
        return flow_get_proto_dst(skb, flow);
 }
