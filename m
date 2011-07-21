From: kaber@trash.net
Subject: [PATCH 7/8] netfilter: ipset: hash:net,iface fixed to handle overlapping nets behind different interfaces
Date: Thu, 21 Jul 2011 12:17:55 +0200
Message-ID: <1311243476-18236-8-git-send-email-kaber@trash.net>
References: <1311243476-18236-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34525 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170Ab1GUKSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2011 06:18:03 -0400
In-Reply-To: <1311243476-18236-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

If overlapping networks with different interfaces was added to
the set, the type did not handle it properly. Example

    ipset create test hash:net,iface
    ipset add test 192.168.0.0/16,eth0
    ipset add test 192.168.0.0/24,eth1

Now, if a packet was sent from 192.168.0.0/24,eth0, the type returned
a match.

In the patch the algorithm is fixed in order to correctly handle
overlapping networks.

Limitation: the same network cannot be stored with more than 64 different
interfaces in a single set.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set_ahash.h |   92 +++++++++++++++++---------
 net/netfilter/ipset/ip_set_hash_ip.c         |    6 +-
 net/netfilter/ipset/ip_set_hash_ipport.c     |    6 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c   |    6 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |    6 +-
 net/netfilter/ipset/ip_set_hash_net.c        |    6 +-
 net/netfilter/ipset/ip_set_hash_netiface.c   |   40 +++++++++--
 net/netfilter/ipset/ip_set_hash_netport.c    |    6 +-
 8 files changed, 117 insertions(+), 51 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 42b7d25..1e7f759 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -28,7 +28,32 @@
 /* Number of elements to store in an initial array block */
 #define AHASH_INIT_SIZE			4
 /* Max number of elements to store in an array block */
-#define AHASH_MAX_SIZE			(3*4)
+#define AHASH_MAX_SIZE			(3*AHASH_INIT_SIZE)
+
+/* Max number of elements can be tuned */
+#ifdef IP_SET_HASH_WITH_MULTI
+#define AHASH_MAX(h)			((h)->ahash_max)
+
+static inline u8
+tune_ahash_max(u8 curr, u32 multi)
+{
+	u32 n;
+
+	if (multi < curr)
+		return curr;
+
+	n = curr + AHASH_INIT_SIZE;
+	/* Currently, at listing one hash bucket must fit into a message.
+	 * Therefore we have a hard limit here.
+	 */
+	return n > curr && n <= 64 ? n : curr;
+}
+#define TUNE_AHASH_MAX(h, multi)	\
+	((h)->ahash_max = tune_ahash_max((h)->ahash_max, multi))
+#else
+#define AHASH_MAX(h)			AHASH_MAX_SIZE
+#define TUNE_AHASH_MAX(h, multi)
+#endif
 
 /* A hash bucket */
 struct hbucket {
@@ -60,6 +85,9 @@ struct ip_set_hash {
 	u32 timeout;		/* timeout value, if enabled */
 	struct timer_list gc;	/* garbage collection when timeout enabled */
 	struct type_pf_next next; /* temporary storage for uadd */
+#ifdef IP_SET_HASH_WITH_MULTI
+	u8 ahash_max;		/* max elements in an array block */
+#endif
 #ifdef IP_SET_HASH_WITH_NETMASK
 	u8 netmask;		/* netmask value for subnets to store */
 #endif
@@ -279,12 +307,13 @@ ip_set_hash_destroy(struct ip_set *set)
 /* Add an element to the hash table when resizing the set:
  * we spare the maintenance of the internal counters. */
 static int
-type_pf_elem_add(struct hbucket *n, const struct type_pf_elem *value)
+type_pf_elem_add(struct hbucket *n, const struct type_pf_elem *value,
+		 u8 ahash_max)
 {
 	if (n->pos >= n->size) {
 		void *tmp;
 
-		if (n->size >= AHASH_MAX_SIZE)
+		if (n->size >= ahash_max)
 			/* Trigger rehashing */
 			return -EAGAIN;
 
@@ -339,7 +368,7 @@ retry:
 		for (j = 0; j < n->pos; j++) {
 			data = ahash_data(n, j);
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
-			ret = type_pf_elem_add(m, data);
+			ret = type_pf_elem_add(m, data, AHASH_MAX(h));
 			if (ret < 0) {
 				read_unlock_bh(&set->lock);
 				ahash_destroy(t);
@@ -376,7 +405,7 @@ type_pf_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	const struct type_pf_elem *d = value;
 	struct hbucket *n;
 	int i, ret = 0;
-	u32 key;
+	u32 key, multi = 0;
 
 	if (h->elements >= h->maxelem)
 		return -IPSET_ERR_HASH_FULL;
@@ -386,12 +415,12 @@ type_pf_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	key = HKEY(value, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++)
-		if (type_pf_data_equal(ahash_data(n, i), d)) {
+		if (type_pf_data_equal(ahash_data(n, i), d, &multi)) {
 			ret = -IPSET_ERR_EXIST;
 			goto out;
 		}
-
-	ret = type_pf_elem_add(n, value);
+	TUNE_AHASH_MAX(h, multi);
+	ret = type_pf_elem_add(n, value, AHASH_MAX(h));
 	if (ret != 0) {
 		if (ret == -EAGAIN)
 			type_pf_data_next(h, d);
@@ -419,13 +448,13 @@ type_pf_del(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	struct hbucket *n;
 	int i;
 	struct type_pf_elem *data;
-	u32 key;
+	u32 key, multi = 0;
 
 	key = HKEY(value, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
 		data = ahash_data(n, i);
-		if (!type_pf_data_equal(data, d))
+		if (!type_pf_data_equal(data, d, &multi))
 			continue;
 		if (i != n->pos - 1)
 			/* Not last one */
@@ -466,17 +495,17 @@ type_pf_test_cidrs(struct ip_set *set, struct type_pf_elem *d, u32 timeout)
 	struct hbucket *n;
 	const struct type_pf_elem *data;
 	int i, j = 0;
-	u32 key;
+	u32 key, multi = 0;
 	u8 host_mask = SET_HOST_MASK(set->family);
 
 	pr_debug("test by nets\n");
-	for (; j < host_mask && h->nets[j].cidr; j++) {
+	for (; j < host_mask && h->nets[j].cidr && !multi; j++) {
 		type_pf_data_netmask(d, h->nets[j].cidr);
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
 		for (i = 0; i < n->pos; i++) {
 			data = ahash_data(n, i);
-			if (type_pf_data_equal(data, d))
+			if (type_pf_data_equal(data, d, &multi))
 				return 1;
 		}
 	}
@@ -494,7 +523,7 @@ type_pf_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	struct hbucket *n;
 	const struct type_pf_elem *data;
 	int i;
-	u32 key;
+	u32 key, multi = 0;
 
 #ifdef IP_SET_HASH_WITH_NETS
 	/* If we test an IP address and not a network address,
@@ -507,7 +536,7 @@ type_pf_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
 		data = ahash_data(n, i);
-		if (type_pf_data_equal(data, d))
+		if (type_pf_data_equal(data, d, &multi))
 			return 1;
 	}
 	return 0;
@@ -664,14 +693,14 @@ type_pf_data_timeout_set(struct type_pf_elem *data, u32 timeout)
 
 static int
 type_pf_elem_tadd(struct hbucket *n, const struct type_pf_elem *value,
-		  u32 timeout)
+		  u8 ahash_max, u32 timeout)
 {
 	struct type_pf_elem *data;
 
 	if (n->pos >= n->size) {
 		void *tmp;
 
-		if (n->size >= AHASH_MAX_SIZE)
+		if (n->size >= ahash_max)
 			/* Trigger rehashing */
 			return -EAGAIN;
 
@@ -776,7 +805,7 @@ retry:
 		for (j = 0; j < n->pos; j++) {
 			data = ahash_tdata(n, j);
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
-			ret = type_pf_elem_tadd(m, data,
+			ret = type_pf_elem_tadd(m, data, AHASH_MAX(h),
 						type_pf_data_timeout(data));
 			if (ret < 0) {
 				read_unlock_bh(&set->lock);
@@ -807,9 +836,9 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	const struct type_pf_elem *d = value;
 	struct hbucket *n;
 	struct type_pf_elem *data;
-	int ret = 0, i, j = AHASH_MAX_SIZE + 1;
+	int ret = 0, i, j = AHASH_MAX(h) + 1;
 	bool flag_exist = flags & IPSET_FLAG_EXIST;
-	u32 key;
+	u32 key, multi = 0;
 
 	if (h->elements >= h->maxelem)
 		/* FIXME: when set is full, we slow down here */
@@ -823,18 +852,18 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
 		data = ahash_tdata(n, i);
-		if (type_pf_data_equal(data, d)) {
+		if (type_pf_data_equal(data, d, &multi)) {
 			if (type_pf_data_expired(data) || flag_exist)
 				j = i;
 			else {
 				ret = -IPSET_ERR_EXIST;
 				goto out;
 			}
-		} else if (j == AHASH_MAX_SIZE + 1 &&
+		} else if (j == AHASH_MAX(h) + 1 &&
 			   type_pf_data_expired(data))
 			j = i;
 	}
-	if (j != AHASH_MAX_SIZE + 1) {
+	if (j != AHASH_MAX(h) + 1) {
 		data = ahash_tdata(n, j);
 #ifdef IP_SET_HASH_WITH_NETS
 		del_cidr(h, data->cidr, HOST_MASK);
@@ -844,7 +873,8 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		type_pf_data_timeout_set(data, timeout);
 		goto out;
 	}
-	ret = type_pf_elem_tadd(n, d, timeout);
+	TUNE_AHASH_MAX(h, multi);
+	ret = type_pf_elem_tadd(n, d, AHASH_MAX(h), timeout);
 	if (ret != 0) {
 		if (ret == -EAGAIN)
 			type_pf_data_next(h, d);
@@ -869,13 +899,13 @@ type_pf_tdel(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	struct hbucket *n;
 	int i;
 	struct type_pf_elem *data;
-	u32 key;
+	u32 key, multi = 0;
 
 	key = HKEY(value, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
 		data = ahash_tdata(n, i);
-		if (!type_pf_data_equal(data, d))
+		if (!type_pf_data_equal(data, d, &multi))
 			continue;
 		if (type_pf_data_expired(data))
 			return -IPSET_ERR_EXIST;
@@ -915,16 +945,16 @@ type_pf_ttest_cidrs(struct ip_set *set, struct type_pf_elem *d, u32 timeout)
 	struct type_pf_elem *data;
 	struct hbucket *n;
 	int i, j = 0;
-	u32 key;
+	u32 key, multi = 0;
 	u8 host_mask = SET_HOST_MASK(set->family);
 
-	for (; j < host_mask && h->nets[j].cidr; j++) {
+	for (; j < host_mask && h->nets[j].cidr && !multi; j++) {
 		type_pf_data_netmask(d, h->nets[j].cidr);
 		key = HKEY(d, h->initval, t->htable_bits);
 		n = hbucket(t, key);
 		for (i = 0; i < n->pos; i++) {
 			data = ahash_tdata(n, i);
-			if (type_pf_data_equal(data, d))
+			if (type_pf_data_equal(data, d, &multi))
 				return !type_pf_data_expired(data);
 		}
 	}
@@ -940,7 +970,7 @@ type_pf_ttest(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	struct type_pf_elem *data, *d = value;
 	struct hbucket *n;
 	int i;
-	u32 key;
+	u32 key, multi = 0;
 
 #ifdef IP_SET_HASH_WITH_NETS
 	if (d->cidr == SET_HOST_MASK(set->family))
@@ -950,7 +980,7 @@ type_pf_ttest(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
 		data = ahash_tdata(n, i);
-		if (type_pf_data_equal(data, d))
+		if (type_pf_data_equal(data, d, &multi))
 			return !type_pf_data_expired(data);
 	}
 	return 0;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index fa80bb9..f2d576e 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -53,7 +53,8 @@ struct hash_ip4_telem {
 
 static inline bool
 hash_ip4_data_equal(const struct hash_ip4_elem *ip1,
-		    const struct hash_ip4_elem *ip2)
+		    const struct hash_ip4_elem *ip2,
+		    u32 *multi)
 {
 	return ip1->ip == ip2->ip;
 }
@@ -225,7 +226,8 @@ struct hash_ip6_telem {
 
 static inline bool
 hash_ip6_data_equal(const struct hash_ip6_elem *ip1,
-		    const struct hash_ip6_elem *ip2)
+		    const struct hash_ip6_elem *ip2,
+		    u32 *multi)
 {
 	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0;
 }
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index bbf51b6..6ee10f5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -60,7 +60,8 @@ struct hash_ipport4_telem {
 
 static inline bool
 hash_ipport4_data_equal(const struct hash_ipport4_elem *ip1,
-			const struct hash_ipport4_elem *ip2)
+			const struct hash_ipport4_elem *ip2,
+			u32 *multi)
 {
 	return ip1->ip == ip2->ip &&
 	       ip1->port == ip2->port &&
@@ -276,7 +277,8 @@ struct hash_ipport6_telem {
 
 static inline bool
 hash_ipport6_data_equal(const struct hash_ipport6_elem *ip1,
-			const struct hash_ipport6_elem *ip2)
+			const struct hash_ipport6_elem *ip2,
+			u32 *multi)
 {
 	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
 	       ip1->port == ip2->port &&
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 96525f5..fb90e34 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -62,7 +62,8 @@ struct hash_ipportip4_telem {
 
 static inline bool
 hash_ipportip4_data_equal(const struct hash_ipportip4_elem *ip1,
-			  const struct hash_ipportip4_elem *ip2)
+			  const struct hash_ipportip4_elem *ip2,
+			  u32 *multi)
 {
 	return ip1->ip == ip2->ip &&
 	       ip1->ip2 == ip2->ip2 &&
@@ -286,7 +287,8 @@ struct hash_ipportip6_telem {
 
 static inline bool
 hash_ipportip6_data_equal(const struct hash_ipportip6_elem *ip1,
-			  const struct hash_ipportip6_elem *ip2)
+			  const struct hash_ipportip6_elem *ip2,
+			  u32 *multi)
 {
 	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
 	       ipv6_addr_cmp(&ip1->ip2.in6, &ip2->ip2.in6) == 0 &&
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index d2d6ab8..deb3e3d 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -62,7 +62,8 @@ struct hash_ipportnet4_telem {
 
 static inline bool
 hash_ipportnet4_data_equal(const struct hash_ipportnet4_elem *ip1,
-			   const struct hash_ipportnet4_elem *ip2)
+			   const struct hash_ipportnet4_elem *ip2,
+			   u32 *multi)
 {
 	return ip1->ip == ip2->ip &&
 	       ip1->ip2 == ip2->ip2 &&
@@ -335,7 +336,8 @@ struct hash_ipportnet6_telem {
 
 static inline bool
 hash_ipportnet6_data_equal(const struct hash_ipportnet6_elem *ip1,
-			   const struct hash_ipportnet6_elem *ip2)
+			   const struct hash_ipportnet6_elem *ip2,
+			   u32 *multi)
 {
 	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
 	       ipv6_addr_cmp(&ip1->ip2.in6, &ip2->ip2.in6) == 0 &&
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 2d4b1f4..60d0165 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -58,7 +58,8 @@ struct hash_net4_telem {
 
 static inline bool
 hash_net4_data_equal(const struct hash_net4_elem *ip1,
-		    const struct hash_net4_elem *ip2)
+		     const struct hash_net4_elem *ip2,
+		     u32 *multi)
 {
 	return ip1->ip == ip2->ip && ip1->cidr == ip2->cidr;
 }
@@ -249,7 +250,8 @@ struct hash_net6_telem {
 
 static inline bool
 hash_net6_data_equal(const struct hash_net6_elem *ip1,
-		     const struct hash_net6_elem *ip2)
+		     const struct hash_net6_elem *ip2,
+		     u32 *multi)
 {
 	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
 	       ip1->cidr == ip2->cidr;
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 3d6c53b..e13095d 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -99,7 +99,7 @@ iface_test(struct rb_root *root, const char **iface)
 
 	while (n) {
 		const char *d = iface_data(n);
-		int res = ifname_compare(*iface, d);
+		long res = ifname_compare(*iface, d);
 
 		if (res < 0)
 			n = n->rb_left;
@@ -121,7 +121,7 @@ iface_add(struct rb_root *root, const char **iface)
 
 	while (*n) {
 		char *ifname = iface_data(*n);
-		int res = ifname_compare(*iface, ifname);
+		long res = ifname_compare(*iface, ifname);
 
 		p = *n;
 		if (res < 0)
@@ -159,31 +159,42 @@ hash_netiface_same_set(const struct ip_set *a, const struct ip_set *b);
 
 /* The type variant functions: IPv4 */
 
+struct hash_netiface4_elem_hashed {
+	__be32 ip;
+	u8 physdev;
+	u8 cidr;
+	u16 padding;
+};
+
+#define HKEY_DATALEN	sizeof(struct hash_netiface4_elem_hashed)
+
 /* Member elements without timeout */
 struct hash_netiface4_elem {
 	__be32 ip;
-	const char *iface;
 	u8 physdev;
 	u8 cidr;
 	u16 padding;
+	const char *iface;
 };
 
 /* Member elements with timeout support */
 struct hash_netiface4_telem {
 	__be32 ip;
-	const char *iface;
 	u8 physdev;
 	u8 cidr;
 	u16 padding;
+	const char *iface;
 	unsigned long timeout;
 };
 
 static inline bool
 hash_netiface4_data_equal(const struct hash_netiface4_elem *ip1,
-			  const struct hash_netiface4_elem *ip2)
+			  const struct hash_netiface4_elem *ip2,
+			  u32 *multi)
 {
 	return ip1->ip == ip2->ip &&
 	       ip1->cidr == ip2->cidr &&
+	       (++*multi) &&
 	       ip1->physdev == ip2->physdev &&
 	       ip1->iface == ip2->iface;
 }
@@ -257,6 +268,7 @@ nla_put_failure:
 
 #define IP_SET_HASH_WITH_NETS
 #define IP_SET_HASH_WITH_RBTREE
+#define IP_SET_HASH_WITH_MULTI
 
 #define PF		4
 #define HOST_MASK	32
@@ -424,29 +436,40 @@ hash_netiface_same_set(const struct ip_set *a, const struct ip_set *b)
 
 /* The type variant functions: IPv6 */
 
+struct hash_netiface6_elem_hashed {
+	union nf_inet_addr ip;
+	u8 physdev;
+	u8 cidr;
+	u16 padding;
+};
+
+#define HKEY_DATALEN	sizeof(struct hash_netiface6_elem_hashed)
+
 struct hash_netiface6_elem {
 	union nf_inet_addr ip;
-	const char *iface;
 	u8 physdev;
 	u8 cidr;
 	u16 padding;
+	const char *iface;
 };
 
 struct hash_netiface6_telem {
 	union nf_inet_addr ip;
-	const char *iface;
 	u8 physdev;
 	u8 cidr;
 	u16 padding;
+	const char *iface;
 	unsigned long timeout;
 };
 
 static inline bool
 hash_netiface6_data_equal(const struct hash_netiface6_elem *ip1,
-			  const struct hash_netiface6_elem *ip2)
+			  const struct hash_netiface6_elem *ip2,
+			  u32 *multi)
 {
 	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
 	       ip1->cidr == ip2->cidr &&
+	       (++*multi) &&
 	       ip1->physdev == ip2->physdev &&
 	       ip1->iface == ip2->iface;
 }
@@ -681,6 +704,7 @@ hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 	h->maxelem = maxelem;
 	get_random_bytes(&h->initval, sizeof(h->initval));
 	h->timeout = IPSET_NO_TIMEOUT;
+	h->ahash_max = AHASH_MAX_SIZE;
 
 	hbits = htable_bits(hashsize);
 	h->table = ip_set_alloc(
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index fe203d1..8f9de72 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -59,7 +59,8 @@ struct hash_netport4_telem {
 
 static inline bool
 hash_netport4_data_equal(const struct hash_netport4_elem *ip1,
-			 const struct hash_netport4_elem *ip2)
+			 const struct hash_netport4_elem *ip2,
+			 u32 *multi)
 {
 	return ip1->ip == ip2->ip &&
 	       ip1->port == ip2->port &&
@@ -300,7 +301,8 @@ struct hash_netport6_telem {
 
 static inline bool
 hash_netport6_data_equal(const struct hash_netport6_elem *ip1,
-			 const struct hash_netport6_elem *ip2)
+			 const struct hash_netport6_elem *ip2,
+			 u32 *multi)
 {
 	return ipv6_addr_cmp(&ip1->ip.in6, &ip2->ip.in6) == 0 &&
 	       ip1->port == ip2->port &&
-- 
1.7.2.3

