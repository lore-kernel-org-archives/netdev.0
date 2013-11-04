From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/20] netfilter: ipset: The unnamed union initialization may lead to compilation error
Date: Mon,  4 Nov 2013 22:50:34 +0100
Message-ID: <1383601842-4570-13-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55695 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753706Ab3KDVvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 16:51:00 -0500
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The unnamed union should be possible to be initialized directly, but
unfortunately it's not so:

/usr/src/ipset/kernel/net/netfilter/ipset/ip_set_hash_netnet.c: In
function ?hash_netnet4_kadt?:
/usr/src/ipset/kernel/net/netfilter/ipset/ip_set_hash_netnet.c:141:
error: unknown field ?cidr? specified in initializer

Reported-by: Husnu Demir <hdemir@metu.edu.tr>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_netnet.c     |   22 ++++++++++------------
 net/netfilter/ipset/ip_set_hash_netportnet.c |   22 ++++++++++------------
 2 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 4260327..2bc2dec 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -137,12 +137,11 @@ hash_netnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct hash_netnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet4_elem e = {
-		.cidr[0] = h->nets[0].cidr[0] ? h->nets[0].cidr[0] : HOST_MASK,
-		.cidr[1] = h->nets[0].cidr[1] ? h->nets[0].cidr[1] : HOST_MASK,
-	};
+	struct hash_netnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
+	e.cidr[0] = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK);
+	e.cidr[1] = IP_SET_INIT_CIDR(h->nets[0].cidr[1], HOST_MASK);
 	if (adt == IPSET_TEST)
 		e.ccmp = (HOST_MASK << (sizeof(e.cidr[0]) * 8)) | HOST_MASK;
 
@@ -160,14 +159,14 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet4_elem e = { .cidr[0] = HOST_MASK,
-				       .cidr[1] = HOST_MASK };
+	struct hash_netnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, last;
 	u32 ip2 = 0, ip2_from = 0, ip2_to = 0, last2;
 	u8 cidr, cidr2;
 	int ret;
 
+	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
@@ -364,12 +363,11 @@ hash_netnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct hash_netnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet6_elem e = {
-		.cidr[0] = h->nets[0].cidr[0] ? h->nets[0].cidr[0] : HOST_MASK,
-		.cidr[1] = h->nets[0].cidr[1] ? h->nets[0].cidr[1] : HOST_MASK
-	};
+	struct hash_netnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
+	e.cidr[0] = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK);
+	e.cidr[1] = IP_SET_INIT_CIDR(h->nets[0].cidr[1], HOST_MASK);
 	if (adt == IPSET_TEST)
 		e.ccmp = (HOST_MASK << (sizeof(u8)*8)) | HOST_MASK;
 
@@ -386,11 +384,11 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet6_elem e = { .cidr[0] = HOST_MASK,
-				       .cidr[1] = HOST_MASK };
+	struct hash_netnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
+	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 363fab9..703d119 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -147,12 +147,11 @@ hash_netportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet4_elem e = {
-		.cidr[0] = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
-		.cidr[1] = IP_SET_INIT_CIDR(h->nets[0].cidr[1], HOST_MASK),
-	};
+	struct hash_netportnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
+	e.cidr[0] = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK);
+	e.cidr[1] = IP_SET_INIT_CIDR(h->nets[0].cidr[1], HOST_MASK);
 	if (adt == IPSET_TEST)
 		e.ccmp = (HOST_MASK << (sizeof(e.cidr[0]) * 8)) | HOST_MASK;
 
@@ -174,8 +173,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet4_elem e = { .cidr[0] = HOST_MASK,
-					   .cidr[1] = HOST_MASK };
+	struct hash_netportnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, ip_last, p = 0, port, port_to;
 	u32 ip2_from = 0, ip2_to = 0, ip2_last, ip2;
@@ -183,6 +181,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	u8 cidr, cidr2;
 	int ret;
 
+	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
@@ -419,12 +418,11 @@ hash_netportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet6_elem e = {
-		.cidr[0] = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK),
-		.cidr[1] = IP_SET_INIT_CIDR(h->nets[0].cidr[1], HOST_MASK),
-	};
+	struct hash_netportnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_KEXT(skb, opt, set);
 
+	e.cidr[0] = IP_SET_INIT_CIDR(h->nets[0].cidr[0], HOST_MASK);
+	e.cidr[1] = IP_SET_INIT_CIDR(h->nets[0].cidr[1], HOST_MASK);
 	if (adt == IPSET_TEST)
 		e.ccmp = (HOST_MASK << (sizeof(u8) * 8)) | HOST_MASK;
 
@@ -446,13 +444,13 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet6_elem e = { .cidr[0] = HOST_MASK,
-					   .cidr[1] = HOST_MASK };
+	struct hash_netportnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
 	int ret;
 
+	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-- 
1.7.10.4
