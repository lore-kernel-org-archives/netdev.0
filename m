From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/5] net: export udp and gre gro_complete() APIs
Date: Wed, 22 Jun 2016 04:25:22 -0400
Message-ID: <1466583926-27762-2-git-send-email-manish.chopra@qlogic.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@qlogic.com>,
	<Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:43047 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750880AbcFVJJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 05:09:38 -0400
In-Reply-To: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports relevant APIs needed to be used by this driver
to handle hardware assisted encapsulated GRO packets.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 include/net/gre.h      | 3 +++
 include/net/udp.h      | 6 ++++++
 net/ipv4/gre_offload.c | 3 ++-
 net/ipv4/udp_offload.c | 3 ++-
 net/ipv6/udp_offload.c | 3 ++-
 5 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 5dce30a..a5fe689 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -23,6 +23,9 @@ struct gre_protocol {
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
+/* gre_gro_complete exported for drivers implementing hardware GRO */
+int gre_gro_complete(struct sk_buff *skb, int nhoff);
+
 struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 				       u8 name_assign_type);
 int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
diff --git a/include/net/udp.h b/include/net/udp.h
index 8894d71..ac6b19b 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -174,6 +174,12 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 				 struct udphdr *uh, udp_lookup_t lookup);
 int udp_gro_complete(struct sk_buff *skb, int nhoff, udp_lookup_t lookup);
 
+/* udp4_gro_complete exported for drivers implementing hardware GRO */
+int udp4_gro_complete(struct sk_buff *skb, int nhoff);
+
+/* udp6_gro_complete exported for drivers implementing hardware GRO */
+int udp6_gro_complete(struct sk_buff *skb, int nhoff);
+
 static inline struct udphdr *udp_gro_udphdr(struct sk_buff *skb)
 {
 	struct udphdr *uh;
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index ecd1e09..c09c7e9 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -238,7 +238,7 @@ out:
 	return pp;
 }
 
-static int gre_gro_complete(struct sk_buff *skb, int nhoff)
+int gre_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	struct gre_base_hdr *greh = (struct gre_base_hdr *)(skb->data + nhoff);
 	struct packet_offload *ptype;
@@ -267,6 +267,7 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 
 	return err;
 }
+EXPORT_SYMBOL(gre_gro_complete);
 
 static const struct net_offload gre_offload = {
 	.callbacks = {
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 81f253b..b4899bb 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -359,7 +359,7 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff,
 }
 EXPORT_SYMBOL(udp_gro_complete);
 
-static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
+int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
@@ -374,6 +374,7 @@ static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 
 	return udp_gro_complete(skb, nhoff, udp4_lib_lookup_skb);
 }
+EXPORT_SYMBOL(udp4_gro_complete);
 
 static const struct net_offload udpv4_offload = {
 	.callbacks = {
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index ac858c4..827cd20 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -147,7 +147,7 @@ flush:
 	return NULL;
 }
 
-static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
+int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
@@ -162,6 +162,7 @@ static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 
 	return udp_gro_complete(skb, nhoff, udp6_lib_lookup_skb);
 }
+EXPORT_SYMBOL(udp6_gro_complete);
 
 static const struct net_offload udpv6_offload = {
 	.callbacks = {
-- 
2.7.2
