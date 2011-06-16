From: kaber@trash.net
Subject: [PATCH 12/20] netfilter: ipset: support range for IPv4 at adding/deleting elements for hash:*net* types
Date: Thu, 16 Jun 2011 21:47:12 +0200
Message-ID: <1308253640-29942-13-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The range internally is converted to the network(s) equal to the range.
Example:

	# ipset new test hash:net
	# ipset add test 10.2.0.0-10.2.1.12
	# ipset list test
	Name: test
	Type: hash:net
	Header: family inet hashsize 1024 maxelem 65536
	Size in memory: 16888
	References: 0
	Members:
	10.2.1.12
	10.2.1.0/29
	10.2.0.0/24
	10.2.1.8/30

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set.h       |    1 +
 include/linux/netfilter/ipset/ip_set_ahash.h |    2 +-
 include/linux/netfilter/ipset/ip_set_hash.h  |    4 ++
 include/linux/netfilter/ipset/pfxlen.h       |    3 +
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |   69 +++++++++++++++++--------
 net/netfilter/ipset/ip_set_hash_net.c        |   51 +++++++++++++++----
 net/netfilter/ipset/ip_set_hash_netport.c    |   69 ++++++++++++++++++--------
 net/netfilter/ipset/pfxlen.c                 |   21 ++++++++
 8 files changed, 165 insertions(+), 55 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index ac31e38..fd83f4f 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -104,6 +104,7 @@ enum {
 	IPSET_ATTR_NAMEREF,
 	IPSET_ATTR_IP2,
 	IPSET_ATTR_CIDR2,
+	IPSET_ATTR_IP2_TO,
 	__IPSET_ATTR_ADT_MAX,
 };
 #define IPSET_ATTR_ADT_MAX	(__IPSET_ATTR_ADT_MAX - 1)
diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 8709bd9..905e2ac 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -353,7 +353,7 @@ retry:
 	return 0;
 }
 
-static inline void
+static void
 type_pf_data_next(struct ip_set_hash *h, const struct type_pf_elem *d);
 
 /* Add an element to a hash and update the internal counters when succeeded,
diff --git a/include/linux/netfilter/ipset/ip_set_hash.h b/include/linux/netfilter/ipset/ip_set_hash.h
index b86f15c..e2a9fae 100644
--- a/include/linux/netfilter/ipset/ip_set_hash.h
+++ b/include/linux/netfilter/ipset/ip_set_hash.h
@@ -11,6 +11,10 @@ enum {
 	IPSET_ERR_INVALID_PROTO,
 	/* Protocol missing but must be specified */
 	IPSET_ERR_MISSING_PROTO,
+	/* Range not supported */
+	IPSET_ERR_HASH_RANGE_UNSUPPORTED,
+	/* Invalid range */
+	IPSET_ERR_HASH_RANGE,
 };
 
 #ifdef __KERNEL__
diff --git a/include/linux/netfilter/ipset/pfxlen.h b/include/linux/netfilter/ipset/pfxlen.h
index 0e1fb50..84efa33 100644
--- a/include/linux/netfilter/ipset/pfxlen.h
+++ b/include/linux/netfilter/ipset/pfxlen.h
@@ -3,6 +3,7 @@
 
 #include <asm/byteorder.h>
 #include <linux/netfilter.h> 
+#include <net/tcp.h>
 
 /* Prefixlen maps, by Jan Engelhardt  */
 extern const union nf_inet_addr ip_set_netmask_map[];
@@ -32,4 +33,6 @@ ip_set_hostmask6(u8 pfxlen)
 	return &ip_set_hostmask_map[pfxlen].ip6[0];
 }
 
+extern u32 ip_set_range_to_cidr(u32 from, u32 to, u8 *cidr);
+
 #endif /*_PFXLEN_H */
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 0b54fde..ef068b0 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -146,6 +146,7 @@ hash_ipportnet4_data_next(struct ip_set_hash *h,
 {
 	h->next.ip = ntohl(d->ip);
 	h->next.port = ntohs(d->port);
+	h->next.ip2 = ntohl(d->ip2);
 }
 
 static int
@@ -181,6 +182,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet4_elem data = { .cidr = HOST_MASK };
 	u32 ip, ip_to, p = 0, port, port_to;
+	u32 ip2_from = 0, ip2_to, ip2_last, ip2;
 	u32 timeout = h->timeout;
 	bool with_ports = false;
 	int ret;
@@ -194,21 +196,19 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP2], &data.ip2);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2], &ip2_from);
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR2])
+	if (tb[IPSET_ATTR_CIDR2]) {
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
-
-	if (!data.cidr)
-		return -IPSET_ERR_INVALID_CIDR;
-
-	data.ip2 &= ip_set_netmask(data.cidr);
+		if (!data.cidr)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	if (tb[IPSET_ATTR_PORT])
 		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
@@ -233,14 +233,16 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
+	with_ports = with_ports && tb[IPSET_ATTR_PORT_TO];
 	if (adt == IPSET_TEST ||
-	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR] ||
-	      tb[IPSET_ATTR_PORT_TO])) {
+	    !(tb[IPSET_ATTR_CIDR] || tb[IPSET_ATTR_IP_TO] || with_ports ||
+	      tb[IPSET_ATTR_IP2_TO])) {
+		data.ip = htonl(ip);
+		data.ip2 = htonl(ip2_from & ip_set_hostmask(data.cidr));
 		ret = adtfn(set, &data, timeout, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	ip = ntohl(data.ip);
 	if (tb[IPSET_ATTR_IP_TO]) {
 		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &ip_to);
 		if (ret)
@@ -254,29 +256,48 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			return -IPSET_ERR_INVALID_CIDR;
 		ip &= ip_set_hostmask(cidr);
 		ip_to = ip | ~ip_set_hostmask(cidr);
-	} else
-		ip_to = ip;
+	}
 
 	port_to = port = ntohs(data.port);
-	if (with_ports && tb[IPSET_ATTR_PORT_TO]) {
+	if (tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port > port_to)
 			swap(port, port_to);
 	}
+	if (tb[IPSET_ATTR_IP2_TO]) {
+		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP2_TO], &ip2_to);
+		if (ret)
+			return ret;
+		if (ip2_from > ip2_to)
+			swap(ip2_from, ip2_to);
+		if (ip2_from + UINT_MAX == ip2_to)
+			return -IPSET_ERR_HASH_RANGE;
+	} else {
+		ip2_from &= ip_set_hostmask(data.cidr);
+		ip2_to = ip2_from | ~ip_set_hostmask(data.cidr);
+	}
 
 	if (retried)
 		ip = h->next.ip;
 	for (; !before(ip_to, ip); ip++) {
+		data.ip = htonl(ip);
 		p = retried && ip == h->next.ip ? h->next.port : port;
 		for (; p <= port_to; p++) {
-			data.ip = htonl(ip);
 			data.port = htons(p);
-			ret = adtfn(set, &data, timeout, flags);
-
-			if (ret && !ip_set_eexist(ret, flags))
-				return ret;
-			else
-				ret = 0;
+			ip2 = retried && ip == h->next.ip && p == h->next.port
+				? h->next.ip2 : ip2_from;
+			while (!after(ip2, ip2_to)) {
+				data.ip2 = htonl(ip2);
+				ip2_last = ip_set_range_to_cidr(ip2, ip2_to,
+								&data.cidr);
+				ret = adtfn(set, &data, timeout, flags);
+
+				if (ret && !ip_set_eexist(ret, flags))
+					return ret;
+				else
+					ret = 0;
+				ip2 = ip2_last + 1;
+			}
 		}
 	}
 	return ret;
@@ -451,6 +472,8 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
@@ -596,7 +619,8 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.dimension	= IPSET_DIM_THREE,
 	.family		= AF_UNSPEC,
 	.revision_min	= 0,
-	.revision_max	= 1,	/* SCTP and UDPLITE support added */
+	/*		  1	   SCTP and UDPLITE support added */
+	.revision_max	= 2,	/* Range as input support for IPv4 added */
 	.create		= hash_ipportnet_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
@@ -609,6 +633,7 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
 		[IPSET_ATTR_IP_TO]	= { .type = NLA_NESTED },
 		[IPSET_ATTR_IP2]	= { .type = NLA_NESTED },
+		[IPSET_ATTR_IP2_TO]	= { .type = NLA_NESTED },
 		[IPSET_ATTR_PORT]	= { .type = NLA_U16 },
 		[IPSET_ATTR_PORT_TO]	= { .type = NLA_U16 },
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 360cf5b..8d3c3ef 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -129,6 +129,7 @@ static inline void
 hash_net4_data_next(struct ip_set_hash *h,
 		    const struct hash_net4_elem *d)
 {
+	h->next.ip = ntohl(d->ip);
 }
 
 static int
@@ -158,6 +159,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_net4_elem data = { .cidr = HOST_MASK };
 	u32 timeout = h->timeout;
+	u32 ip = 0, ip_to, last;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -167,27 +169,51 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR])
+	if (tb[IPSET_ATTR_CIDR]) {
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-
-	if (!data.cidr)
-		return -IPSET_ERR_INVALID_CIDR;
-
-	data.ip &= ip_set_netmask(data.cidr);
+		if (!data.cidr)
+			return -IPSET_ERR_INVALID_CIDR;
+	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
 			return -IPSET_ERR_TIMEOUT;
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
+	
+	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
+		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
+		ret = adtfn(set, &data, timeout, flags);
+		return ip_set_eexist(ret, flags) ? 0 : ret;
+	}
 
-	ret = adtfn(set, &data, timeout, flags);
-
-	return ip_set_eexist(ret, flags) ? 0 : ret;
+	ip_to = ip;
+	if (tb[IPSET_ATTR_IP_TO]) {
+		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &ip_to);
+		if (ret)
+			return ret;
+		if (ip_to < ip)
+			swap(ip, ip_to);
+		if (ip + UINT_MAX == ip_to)
+			return -IPSET_ERR_HASH_RANGE;
+	}
+	if (retried)
+		ip = h->next.ip;		
+	while (!after(ip, ip_to)) {
+		data.ip = htonl(ip);
+		last = ip_set_range_to_cidr(ip, ip_to, &data.cidr);
+		ret = adtfn(set, &data, timeout, flags);
+		if (ret && !ip_set_eexist(ret, flags))
+			return ret;
+		else
+			ret = 0;
+		ip = last + 1;
+	}
+	return ret;
 }
 
 static bool
@@ -334,6 +360,8 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
 		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
@@ -438,7 +466,7 @@ static struct ip_set_type hash_net_type __read_mostly = {
 	.dimension	= IPSET_DIM_ONE,
 	.family		= AF_UNSPEC,
 	.revision_min	= 0,
-	.revision_max	= 0,
+	.revision_max	= 1,	/* Range as input support for IPv4 added */
 	.create		= hash_net_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
@@ -449,6 +477,7 @@ static struct ip_set_type hash_net_type __read_mostly = {
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
+		[IPSET_ATTR_IP_TO]	= { .type = NLA_NESTED },
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 	},
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 09f807f..3001030 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -141,6 +141,7 @@ static inline void
 hash_netport4_data_next(struct ip_set_hash *h,
 			const struct hash_netport4_elem *d)
 {
+	h->next.ip = ntohl(d->ip);
 	h->next.port = ntohs(d->port);
 }
 
@@ -175,7 +176,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem data = { .cidr = HOST_MASK };
-	u32 port, port_to;
+	u32 port, port_to, p = 0, ip = 0, ip_to, last;
 	u32 timeout = h->timeout;
 	bool with_ports = false;
 	int ret;
@@ -189,15 +190,15 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
 
-	ret = ip_set_get_ipaddr4(tb[IPSET_ATTR_IP], &data.ip);
+	ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP], &ip);
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR])
+	if (tb[IPSET_ATTR_CIDR]) {
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-	if (!data.cidr)
-		return -IPSET_ERR_INVALID_CIDR;
-	data.ip &= ip_set_netmask(data.cidr);
+		if (!data.cidr)
+			return -IPSET_ERR_INVALID_CIDR; 
+	}
 
 	if (tb[IPSET_ATTR_PORT])
 		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
@@ -222,26 +223,48 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
+	with_ports = with_ports && tb[IPSET_ATTR_PORT_TO];
+	if (adt == IPSET_TEST || !(with_ports || tb[IPSET_ATTR_IP_TO])) {
+		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
 		ret = adtfn(set, &data, timeout, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
 
-	port = ntohs(data.port);
-	port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
-	if (port > port_to)
-		swap(port, port_to);
+	port = port_to = ntohs(data.port);
+	if (tb[IPSET_ATTR_PORT_TO]) {
+		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
+		if (port_to < port)
+			swap(port, port_to);
+	}
+	if (tb[IPSET_ATTR_IP_TO]) {
+		ret = ip_set_get_hostipaddr4(tb[IPSET_ATTR_IP_TO], &ip_to);
+		if (ret)
+			return ret;
+		if (ip_to < ip)
+			swap(ip, ip_to);
+		if (ip + UINT_MAX == ip_to)
+			return -IPSET_ERR_HASH_RANGE;
+	} else {
+		ip &= ip_set_hostmask(data.cidr);
+		ip_to = ip | ~ip_set_hostmask(data.cidr);
+	}
 
 	if (retried)
-		port = h->next.port;
-	for (; port <= port_to; port++) {
-		data.port = htons(port);
-		ret = adtfn(set, &data, timeout, flags);
-
-		if (ret && !ip_set_eexist(ret, flags))
-			return ret;
-		else
-			ret = 0;
+		ip = h->next.ip;
+	while (!after(ip, ip_to)) {
+		data.ip = htonl(ip);
+		last = ip_set_range_to_cidr(ip, ip_to, &data.cidr);
+		p = retried && ip == h->next.ip ? h->next.port : port;
+		for (; p <= port_to; p++) {
+			data.port = htons(p);
+			ret = adtfn(set, &data, timeout, flags);
+
+			if (ret && !ip_set_eexist(ret, flags))
+				return ret;
+			else
+				ret = 0;
+		}
+		ip = last + 1;
 	}
 	return ret;
 }
@@ -407,6 +430,8 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
 		return -IPSET_ERR_PROTOCOL;
+	if (unlikely(tb[IPSET_ATTR_IP_TO]))
+		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
 
 	if (tb[IPSET_ATTR_LINENO])
 		*lineno = nla_get_u32(tb[IPSET_ATTR_LINENO]);
@@ -545,7 +570,8 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 	.dimension	= IPSET_DIM_TWO,
 	.family		= AF_UNSPEC,
 	.revision_min	= 0,
-	.revision_max	= 1,	/* SCTP and UDPLITE support added */
+	/*		  1	   SCTP and UDPLITE support added */
+	.revision_max	= 2,	/* Range as input support for IPv4 added */
 	.create		= hash_netport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
@@ -557,6 +583,7 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 	},
 	.adt_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
+		[IPSET_ATTR_IP_TO]	= { .type = NLA_NESTED },
 		[IPSET_ATTR_PORT]	= { .type = NLA_U16 },
 		[IPSET_ATTR_PORT_TO]	= { .type = NLA_U16 },
 		[IPSET_ATTR_PROTO]	= { .type = NLA_U8 },
diff --git a/net/netfilter/ipset/pfxlen.c b/net/netfilter/ipset/pfxlen.c
index 23f8c81..b57a856 100644
--- a/net/netfilter/ipset/pfxlen.c
+++ b/net/netfilter/ipset/pfxlen.c
@@ -289,3 +289,24 @@ const union nf_inet_addr ip_set_hostmask_map[] = {
 	E(0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF),
 };
 EXPORT_SYMBOL_GPL(ip_set_hostmask_map);
+
+/* Find the largest network which matches the range from left, in host order. */
+u32
+ip_set_range_to_cidr(u32 from, u32 to, u8 *cidr)
+{
+	u32 last;
+	u8 i;
+
+	for (i = 1; i < 32; i++) {
+		if ((from & ip_set_hostmask(i)) != from)
+			continue;
+		last = from | ~ip_set_hostmask(i);
+		if (!after(last, to)) {
+			*cidr = i;
+			return last;
+		}
+	}
+	*cidr = 32;
+	return from;
+}
+EXPORT_SYMBOL_GPL(ip_set_range_to_cidr);
-- 
1.7.2.3

