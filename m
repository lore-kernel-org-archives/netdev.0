From: kaber@trash.net
Subject: [PATCH 1/4] netfilter: ipset: fix address ranges at hash:*port* types
Date: Sun, 20 Mar 2011 16:32:25 +0100
Message-ID: <1300635148-22648-2-git-send-email-kaber@trash.net>
References: <1300635148-22648-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300635148-22648-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The hash:*port* types with IPv4 silently ignored when address ranges
with non TCP/UDP were added/deleted from the set and used the first
address from the range only.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set_getport.h |   10 +++++++
 net/netfilter/ipset/ip_set_hash_ipport.c       |   34 +++++++-----------------
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   34 +++++++-----------------
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   34 +++++++-----------------
 net/netfilter/ipset/ip_set_hash_netport.c      |   30 +++++---------------
 5 files changed, 48 insertions(+), 94 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_getport.h b/include/linux/netfilter/ipset/ip_set_getport.h
index 3882a81..5aebd17 100644
--- a/include/linux/netfilter/ipset/ip_set_getport.h
+++ b/include/linux/netfilter/ipset/ip_set_getport.h
@@ -18,4 +18,14 @@ static inline bool ip_set_get_ip6_port(const struct sk_buff *skb, bool src,
 extern bool ip_set_get_ip_port(const struct sk_buff *skb, u8 pf, bool src,
 				__be16 *port);
 
+static inline bool ip_set_proto_with_ports(u8 proto)
+{
+	switch (proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+		return true;
+	}
+	return false;
+}
+
 #endif /*_IP_SET_GETPORT_H*/
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index adbe787..b921414 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -150,6 +150,7 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_ipport4_elem data = { };
 	u32 ip, ip_to, p, port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -172,21 +173,15 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMP:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMP))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -195,7 +190,6 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
 	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR] ||
 	      tb[IPSET_ATTR_PORT_TO])) {
 		ret = adtfn(set, &data, timeout);
@@ -219,13 +213,12 @@ hash_ipport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else
 		ip_to = ip;
 
-	port = ntohs(data.port);
-	if (tb[IPSET_ATTR_PORT_TO]) {
+	port_to = port = ntohs(data.port);
+	if (with_ports && tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port > port_to)
 			swap(port, port_to);
-	} else
-		port_to = port;
+	}
 
 	for (; !before(ip_to, ip); ip++)
 		for (p = port; p <= port_to; p++) {
@@ -361,6 +354,7 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_ipport6_elem data = { };
 	u32 port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -385,21 +379,15 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMPV6:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -407,9 +395,7 @@ hash_ipport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
-	    !tb[IPSET_ATTR_PORT_TO]) {
+	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 22e23ab..4642872 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -154,6 +154,7 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_ipportip4_elem data = { };
 	u32 ip, ip_to, p, port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
@@ -180,21 +181,15 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMP:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMP))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -203,7 +198,6 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
 	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR] ||
 	      tb[IPSET_ATTR_PORT_TO])) {
 		ret = adtfn(set, &data, timeout);
@@ -227,13 +221,12 @@ hash_ipportip4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else
 		ip_to = ip;
 
-	port = ntohs(data.port);
-	if (tb[IPSET_ATTR_PORT_TO]) {
+	port_to = port = ntohs(data.port);
+	if (with_ports && tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port > port_to)
 			swap(port, port_to);
-	} else
-		port_to = port;
+	}
 
 	for (; !before(ip_to, ip); ip++)
 		for (p = port; p <= port_to; p++) {
@@ -375,6 +368,7 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_ipportip6_elem data = { };
 	u32 port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
@@ -403,21 +397,15 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMPV6:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -425,9 +413,7 @@ hash_ipportip6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
-	    !tb[IPSET_ATTR_PORT_TO]) {
+	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 6033e8b..2cb84a5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -174,6 +174,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_ipportnet4_elem data = { .cidr = HOST_MASK };
 	u32 ip, ip_to, p, port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
@@ -208,21 +209,15 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMP:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMP))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -231,7 +226,6 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
 	    !(tb[IPSET_ATTR_IP_TO] || tb[IPSET_ATTR_CIDR] ||
 	      tb[IPSET_ATTR_PORT_TO])) {
 		ret = adtfn(set, &data, timeout);
@@ -255,13 +249,12 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 	} else
 		ip_to = ip;
 
-	port = ntohs(data.port);
-	if (tb[IPSET_ATTR_PORT_TO]) {
+	port_to = port = ntohs(data.port);
+	if (with_ports && tb[IPSET_ATTR_PORT_TO]) {
 		port_to = ip_set_get_h16(tb[IPSET_ATTR_PORT_TO]);
 		if (port > port_to)
 			swap(port, port_to);
-	} else
-		port_to = port;
+	}
 
 	for (; !before(ip_to, ip); ip++)
 		for (p = port; p <= port_to; p++) {
@@ -429,6 +422,7 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_ipportnet6_elem data = { .cidr = HOST_MASK };
 	u32 port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
@@ -465,21 +459,15 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMPV6:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -487,9 +475,7 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
-	    !tb[IPSET_ATTR_PORT_TO]) {
+	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 34a1656..8598676 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -170,6 +170,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_netport4_elem data = { .cidr = HOST_MASK };
 	u32 port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -198,21 +199,15 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMP:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMP))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -220,9 +215,7 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
-	    !tb[IPSET_ATTR_PORT_TO]) {
+	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
@@ -390,6 +383,7 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	struct hash_netport6_elem data = { .cidr = HOST_MASK };
 	u32 port, port_to;
 	u32 timeout = h->timeout;
+	bool with_ports = false;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
@@ -418,21 +412,15 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_PROTO]) {
 		data.proto = nla_get_u8(tb[IPSET_ATTR_PROTO]);
+		with_ports = ip_set_proto_with_ports(data.proto);
 
 		if (data.proto == 0)
 			return -IPSET_ERR_INVALID_PROTO;
 	} else
 		return -IPSET_ERR_MISSING_PROTO;
 
-	switch (data.proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_ICMPV6:
-		break;
-	default:
+	if (!(with_ports || data.proto == IPPROTO_ICMPV6))
 		data.port = 0;
-		break;
-	}
 
 	if (tb[IPSET_ATTR_TIMEOUT]) {
 		if (!with_timeout(h->timeout))
@@ -440,9 +428,7 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
-	if (adt == IPSET_TEST ||
-	    !(data.proto == IPPROTO_TCP || data.proto == IPPROTO_UDP) ||
-	    !tb[IPSET_ATTR_PORT_TO]) {
+	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
-- 
1.7.4

