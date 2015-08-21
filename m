From: Elad Raz <eladr@mellanox.com>
Subject: [PATCH net-next] netfilter: ipset: Fixing unnamed union init
Date: Fri, 21 Aug 2015 18:53:18 +0300
Message-ID: <1440172398-23090-1-git-send-email-eladr@mellanox.com>
Cc: Elad Raz <eladr@mellanox.com>, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Sergey Popovich <popovich_sergei@mail.ua>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Anton Danilov <littlesmilingcloud@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Akemi Yagi <amyagi@gmail.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Vinson Lee <vlee@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51236 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751239AbbHUPxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 11:53:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In continue to proposed Vinson Lee's post [1], this patch fixes compilation
issues founded at gcc 4.4.7. The initialization of .cidr field of unnamed
unions causes compilation error in gcc 4.4.x.

References

Visible links
[1] https://lkml.org/lkml/2015/7/5/74

Signed-off-by: Elad Raz <eladr@mellanox.com>
---
 net/netfilter/ipset/ip_set_hash_netnet.c     | 23 +++++++++++++++++++++--
 net/netfilter/ipset/ip_set_hash_netportnet.c | 23 +++++++++++++++++++++--
 2 files changed, 42 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 3c862c0..2bff1f0 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -131,6 +131,14 @@ hash_netnet4_data_next(struct hash_netnet4_elem *next,
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
+static void
+hash_netnet4_init(struct hash_netnet4_elem *e)
+{
+	e->ipcmp = 0;
+	e->cidr[0] = HOST_MASK;
+	e->cidr[1] = HOST_MASK;
+}
+
 static int
 hash_netnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
@@ -160,7 +168,7 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet4_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
+	struct hash_netnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, last;
 	u32 ip2 = 0, ip2_from = 0, ip2_to = 0, last2;
@@ -169,6 +177,7 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	hash_netnet4_init(&e);
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
@@ -357,6 +366,15 @@ hash_netnet6_data_next(struct hash_netnet4_elem *next,
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
 
+static void
+hash_netnet6_init(struct hash_netnet6_elem *e)
+{
+	ipv6_addr_set(&e->ip[0].in6, 0, 0, 0, 0);
+	ipv6_addr_set(&e->ip[1].ip6, 0, 0, 0, 0);
+	e->cidr[0] = HOST_MASK;
+	e->cidr[1] = HOST_MASK;
+}
+
 static int
 hash_netnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		  const struct xt_action_param *par,
@@ -385,13 +403,14 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		  enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet6_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
+	struct hash_netnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	hash_netnet6_init(&e);
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 0c68734..0695c5c 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -142,6 +142,14 @@ hash_netportnet4_data_next(struct hash_netportnet4_elem *next,
 #define HOST_MASK	32
 #include "ip_set_hash_gen.h"
 
+static void
+hash_netportnet4_init(struct hash_netportnet4_elem *e)
+{
+	e->ipcmp = 0;
+	e->cidr[0] = HOST_MASK;
+	e->cidr[1] = HOST_MASK;
+}
+
 static int
 hash_netportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 		      const struct xt_action_param *par,
@@ -175,7 +183,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet4_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
+	struct hash_netportnet4_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, ip_last, p = 0, port, port_to;
 	u32 ip2_from = 0, ip2_to = 0, ip2_last, ip2;
@@ -185,6 +193,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	hash_netportnet4_init(&e);
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
@@ -412,6 +421,15 @@ hash_netportnet6_data_next(struct hash_netportnet4_elem *next,
 #define IP_SET_EMIT_CREATE
 #include "ip_set_hash_gen.h"
 
+static void
+hash_netportnet6_init(struct hash_netportnet6_elem *e)
+{
+	ipv6_addr_set(&e->ip[0].in6, 0, 0, 0, 0);
+	ipv6_addr_set(&e->ip[1].in6, 0, 0, 0, 0);
+	e->cidr[0] = HOST_MASK;
+	e->cidr[1] = HOST_MASK;
+}
+
 static int
 hash_netportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 		      const struct xt_action_param *par,
@@ -445,7 +463,7 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet6_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
+	struct hash_netportnet6_elem e = { };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
@@ -454,6 +472,7 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
+	hash_netportnet6_init(&e);
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-- 
2.3.5
