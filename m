From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/32] netfilter: ipset: Check CIDR value only when attribute is given
Date: Mon, 15 Jun 2015 23:26:15 +0200
Message-ID: <1434403589-24796-19-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergey Popovich <popovich_sergei@mail.ua>

There is no reason to check CIDR value regardless attribute
specifying CIDR is given.

Initialize cidr array in element structure on element structure
declaration to let more freedom to the compiler to optimize
initialization right before element structure is used.

Remove local variables cidr and cidr2 for netnet and netportnet
hashes as we do not use packed cidr value for such set types and
can store value directly in e.cidr[].

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ua>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_net.c        |    8 +++---
 net/netfilter/ipset/ip_set_hash_netiface.c   |    8 +++---
 net/netfilter/ipset/ip_set_hash_netnet.c     |   37 +++++++++++---------------
 net/netfilter/ipset/ip_set_hash_netportnet.c |   37 +++++++++++---------------
 4 files changed, 41 insertions(+), 49 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 2988ec5..d19926a 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -329,11 +329,11 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR])
+	if (tb[IPSET_ATTR_CIDR]) {
 		e.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-
-	if (!e.cidr || e.cidr > HOST_MASK)
-		return -IPSET_ERR_INVALID_CIDR;
+		if (!e.cidr || e.cidr > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	ip6_netmask(&e.ip, e.cidr);
 
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index c80588c..7b69fa2 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -541,10 +541,12 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR])
+	if (tb[IPSET_ATTR_CIDR]) {
 		e.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-	if (e.cidr > HOST_MASK)
-		return -IPSET_ERR_INVALID_CIDR;
+		if (e.cidr > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
+
 	ip6_netmask(&e.ip, e.cidr);
 
 	strcpy(iface, nla_data(tb[IPSET_ATTR_IFACE]));
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 2e6a1ae..11eee00 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -160,17 +160,15 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet4_elem e = { };
+	struct hash_netnet4_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, last;
 	u32 ip2 = 0, ip2_from = 0, ip2_to = 0, last2;
-	u8 cidr, cidr2;
 	int ret;
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
@@ -188,17 +186,15 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR]) {
-		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (!cidr || cidr > HOST_MASK)
+		e.cidr[0] = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!e.cidr[0] || e.cidr[0] > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		e.cidr[0] = cidr;
 	}
 
 	if (tb[IPSET_ATTR_CIDR2]) {
-		cidr2 = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
-		if (!cidr2 || cidr2 > HOST_MASK)
+		e.cidr[1] = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
+		if (!e.cidr[1] || e.cidr[1] > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		e.cidr[1] = cidr2;
 	}
 
 	if (tb[IPSET_ATTR_CADT_FLAGS]) {
@@ -245,15 +241,13 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	while (!after(ip, ip_to)) {
 		e.ip[0] = htonl(ip);
-		last = ip_set_range_to_cidr(ip, ip_to, &cidr);
-		e.cidr[0] = cidr;
+		last = ip_set_range_to_cidr(ip, ip_to, &e.cidr[0]);
 		ip2 = (retried &&
 		       ip == ntohl(h->next.ip[0])) ? ntohl(h->next.ip[1])
 						   : ip2_from;
 		while (!after(ip2, ip2_to)) {
 			e.ip[1] = htonl(ip2);
-			last2 = ip_set_range_to_cidr(ip2, ip2_to, &cidr2);
-			e.cidr[1] = cidr2;
+			last2 = ip_set_range_to_cidr(ip2, ip2_to, &e.cidr[1]);
 			ret = adtfn(set, &e, &ext, &ext, flags);
 			if (ret && !ip_set_eexist(ret, flags))
 				return ret;
@@ -388,14 +382,13 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	       enum ipset_adt adt, u32 *lineno, u32 flags, bool retried)
 {
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netnet6_elem e = { };
+	struct hash_netnet6_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	int ret;
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
@@ -414,15 +407,17 @@ hash_netnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR])
+	if (tb[IPSET_ATTR_CIDR]) {
 		e.cidr[0] = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!e.cidr[0] || e.cidr[0] > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
-	if (tb[IPSET_ATTR_CIDR2])
+	if (tb[IPSET_ATTR_CIDR2]) {
 		e.cidr[1] = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
-
-	if (!e.cidr[0] || e.cidr[0] > HOST_MASK || !e.cidr[1] ||
-	    e.cidr[1] > HOST_MASK)
-		return -IPSET_ERR_INVALID_CIDR;
+		if (!e.cidr[1] || e.cidr[1] > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	ip6_netmask(&e.ip[0], e.cidr[0]);
 	ip6_netmask(&e.ip[1], e.cidr[1]);
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 7ad9a77..6eb5f87 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -175,18 +175,16 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet4_elem e = { };
+	struct hash_netportnet4_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 ip = 0, ip_to = 0, ip_last, p = 0, port, port_to;
 	u32 ip2_from = 0, ip2_to = 0, ip2_last, ip2;
 	bool with_ports = false;
-	u8 cidr, cidr2;
 	int ret;
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
@@ -206,17 +204,15 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR]) {
-		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (!cidr || cidr > HOST_MASK)
+		e.cidr[0] = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!e.cidr[0] || e.cidr[0] > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		e.cidr[0] = cidr;
 	}
 
 	if (tb[IPSET_ATTR_CIDR2]) {
-		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
-		if (!cidr || cidr > HOST_MASK)
+		e.cidr[1] = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
+		if (!e.cidr[1] || e.cidr[1] > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
-		e.cidr[1] = cidr;
 	}
 
 	e.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
@@ -285,8 +281,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	while (!after(ip, ip_to)) {
 		e.ip[0] = htonl(ip);
-		ip_last = ip_set_range_to_cidr(ip, ip_to, &cidr);
-		e.cidr[0] = cidr;
+		ip_last = ip_set_range_to_cidr(ip, ip_to, &e.cidr[0]);
 		p = retried && ip == ntohl(h->next.ip[0]) ? ntohs(h->next.port)
 							  : port;
 		for (; p <= port_to; p++) {
@@ -297,8 +292,7 @@ hash_netportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			while (!after(ip2, ip2_to)) {
 				e.ip[1] = htonl(ip2);
 				ip2_last = ip_set_range_to_cidr(ip2, ip2_to,
-								&cidr2);
-				e.cidr[1] = cidr2;
+								&e.cidr[1]);
 				ret = adtfn(set, &e, &ext, &ext, flags);
 				if (ret && !ip_set_eexist(ret, flags))
 					return ret;
@@ -447,7 +441,7 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct hash_netportnet *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netportnet6_elem e = { };
+	struct hash_netportnet6_elem e = { .cidr = { HOST_MASK, HOST_MASK, }, };
 	struct ip_set_ext ext = IP_SET_INIT_UEXT(set);
 	u32 port, port_to;
 	bool with_ports = false;
@@ -456,7 +450,6 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	e.cidr[0] = e.cidr[1] = HOST_MASK;
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
@@ -477,15 +470,17 @@ hash_netportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR])
+	if (tb[IPSET_ATTR_CIDR]) {
 		e.cidr[0] = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!e.cidr[0] || e.cidr[0] > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
-	if (tb[IPSET_ATTR_CIDR2])
+	if (tb[IPSET_ATTR_CIDR2]) {
 		e.cidr[1] = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
-
-	if (unlikely(!e.cidr[0] || e.cidr[0] > HOST_MASK || !e.cidr[1] ||
-		     e.cidr[1] > HOST_MASK))
-		return -IPSET_ERR_INVALID_CIDR;
+		if (!e.cidr[1] || e.cidr[1] > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	ip6_netmask(&e.ip[0], e.cidr[0]);
 	ip6_netmask(&e.ip[1], e.cidr[1]);
-- 
1.7.10.4

