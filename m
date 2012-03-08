From: pablo@netfilter.org
Subject: [PATCH 04/23] netfilter: ipset: Exceptions support added to hash:*net* types
Date: Thu,  8 Mar 2012 02:00:53 +0100
Message-ID: <1331168472-5820-5-git-send-email-pablo@netfilter.org>
References: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:56098 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491Ab2CHBB3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 20:01:29 -0500
In-Reply-To: <1331168472-5820-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The "nomatch" keyword and option is added to the hash:*net* types,
by which one can add exception entries to sets. Example:

        ipset create test hash:net
        ipset add test 192.168.0/24
        ipset add test 192.168.0/30 nomatch

In this case the IP addresses from 192.168.0/24 except 192.168.0/30
match the elements of the set.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/ipset/ip_set.h       |    4 +
 include/linux/netfilter/ipset/ip_set_ahash.h |   89 ++++++++++++-----
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |  135 +++++++++++++++++++-------
 net/netfilter/ipset/ip_set_hash_net.c        |   77 +++++++++++++--
 net/netfilter/ipset/ip_set_hash_netiface.c   |   72 +++++++++++---
 net/netfilter/ipset/ip_set_hash_netport.c    |  138 +++++++++++++++++++-------
 6 files changed, 399 insertions(+), 116 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index e921766..2f8e18a 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -150,6 +150,7 @@ enum ipset_cmd_flags {
 	IPSET_FLAG_LIST_SETNAME	= (1 << IPSET_FLAG_BIT_LIST_SETNAME),
 	IPSET_FLAG_BIT_LIST_HEADER = 2,
 	IPSET_FLAG_LIST_HEADER	= (1 << IPSET_FLAG_BIT_LIST_HEADER),
+	IPSET_FLAG_CMD_MAX = 15,	/* Lower half */
 };
 
 /* Flags at CADT attribute level */
@@ -158,6 +159,9 @@ enum ipset_cadt_flags {
 	IPSET_FLAG_BEFORE	= (1 << IPSET_FLAG_BIT_BEFORE),
 	IPSET_FLAG_BIT_PHYSDEV	= 1,
 	IPSET_FLAG_PHYSDEV	= (1 << IPSET_FLAG_BIT_PHYSDEV),
+	IPSET_FLAG_BIT_NOMATCH	= 2,
+	IPSET_FLAG_NOMATCH	= (1 << IPSET_FLAG_BIT_NOMATCH),
+	IPSET_FLAG_CADT_MAX	= 15,	/* Upper half */
 };
 
 /* Commands with settype-specific attributes */
diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index bd1fc8d..0e5c3cf 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -113,6 +113,12 @@ htable_bits(u32 hashsize)
 }
 
 #ifdef IP_SET_HASH_WITH_NETS
+#ifdef IP_SET_HASH_WITH_NETS_PACKED
+/* When cidr is packed with nomatch, cidr - 1 is stored in the entry */
+#define CIDR(cidr)	(cidr + 1)
+#else
+#define CIDR(cidr)	(cidr)
+#endif
 
 #define SET_HOST_MASK(family)	(family == AF_INET ? 32 : 128)
 
@@ -262,6 +268,12 @@ ip_set_hash_destroy(struct ip_set *set)
 #define type_pf_data_list	TOKEN(TYPE, PF, _data_list)
 #define type_pf_data_tlist	TOKEN(TYPE, PF, _data_tlist)
 #define type_pf_data_next	TOKEN(TYPE, PF, _data_next)
+#define type_pf_data_flags	TOKEN(TYPE, PF, _data_flags)
+#ifdef IP_SET_HASH_WITH_NETS
+#define type_pf_data_match	TOKEN(TYPE, PF, _data_match)
+#else
+#define type_pf_data_match(d)	1
+#endif
 
 #define type_pf_elem		TOKEN(TYPE, PF, _elem)
 #define type_pf_telem		TOKEN(TYPE, PF, _telem)
@@ -308,8 +320,10 @@ ip_set_hash_destroy(struct ip_set *set)
  * we spare the maintenance of the internal counters. */
 static int
 type_pf_elem_add(struct hbucket *n, const struct type_pf_elem *value,
-		 u8 ahash_max)
+		 u8 ahash_max, u32 cadt_flags)
 {
+	struct type_pf_elem *data;
+
 	if (n->pos >= n->size) {
 		void *tmp;
 
@@ -330,7 +344,13 @@ type_pf_elem_add(struct hbucket *n, const struct type_pf_elem *value,
 		n->value = tmp;
 		n->size += AHASH_INIT_SIZE;
 	}
-	type_pf_data_copy(ahash_data(n, n->pos++), value);
+	data = ahash_data(n, n->pos++);
+	type_pf_data_copy(data, value);
+#ifdef IP_SET_HASH_WITH_NETS
+	/* Resizing won't overwrite stored flags */
+	if (cadt_flags)
+		type_pf_data_flags(data, cadt_flags);
+#endif
 	return 0;
 }
 
@@ -371,7 +391,7 @@ retry:
 		for (j = 0; j < n->pos; j++) {
 			data = ahash_data(n, j);
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
-			ret = type_pf_elem_add(m, data, AHASH_MAX(h));
+			ret = type_pf_elem_add(m, data, AHASH_MAX(h), 0);
 			if (ret < 0) {
 				read_unlock_bh(&set->lock);
 				ahash_destroy(t);
@@ -409,6 +429,7 @@ type_pf_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	struct hbucket *n;
 	int i, ret = 0;
 	u32 key, multi = 0;
+	u32 cadt_flags = flags >> 16;
 
 	if (h->elements >= h->maxelem) {
 		if (net_ratelimit())
@@ -423,11 +444,17 @@ type_pf_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++)
 		if (type_pf_data_equal(ahash_data(n, i), d, &multi)) {
+#ifdef IP_SET_HASH_WITH_NETS
+			if (flags & IPSET_FLAG_EXIST)
+				/* Support overwriting just the flags */
+				type_pf_data_flags(ahash_data(n, i),
+						   cadt_flags);
+#endif
 			ret = -IPSET_ERR_EXIST;
 			goto out;
 		}
 	TUNE_AHASH_MAX(h, multi);
-	ret = type_pf_elem_add(n, value, AHASH_MAX(h));
+	ret = type_pf_elem_add(n, value, AHASH_MAX(h), cadt_flags);
 	if (ret != 0) {
 		if (ret == -EAGAIN)
 			type_pf_data_next(h, d);
@@ -435,7 +462,7 @@ type_pf_add(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	}
 
 #ifdef IP_SET_HASH_WITH_NETS
-	add_cidr(h, d->cidr, HOST_MASK);
+	add_cidr(h, CIDR(d->cidr), HOST_MASK);
 #endif
 	h->elements++;
 out:
@@ -470,7 +497,7 @@ type_pf_del(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		n->pos--;
 		h->elements--;
 #ifdef IP_SET_HASH_WITH_NETS
-		del_cidr(h, d->cidr, HOST_MASK);
+		del_cidr(h, CIDR(d->cidr), HOST_MASK);
 #endif
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
@@ -513,7 +540,7 @@ type_pf_test_cidrs(struct ip_set *set, struct type_pf_elem *d, u32 timeout)
 		for (i = 0; i < n->pos; i++) {
 			data = ahash_data(n, i);
 			if (type_pf_data_equal(data, d, &multi))
-				return 1;
+				return type_pf_data_match(data);
 		}
 	}
 	return 0;
@@ -535,7 +562,7 @@ type_pf_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
 #ifdef IP_SET_HASH_WITH_NETS
 	/* If we test an IP address and not a network address,
 	 * try all possible network sizes */
-	if (d->cidr == SET_HOST_MASK(set->family))
+	if (CIDR(d->cidr) == SET_HOST_MASK(set->family))
 		return type_pf_test_cidrs(set, d, timeout);
 #endif
 
@@ -544,7 +571,7 @@ type_pf_test(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	for (i = 0; i < n->pos; i++) {
 		data = ahash_data(n, i);
 		if (type_pf_data_equal(data, d, &multi))
-			return 1;
+			return type_pf_data_match(data);
 	}
 	return 0;
 }
@@ -700,7 +727,7 @@ type_pf_data_timeout_set(struct type_pf_elem *data, u32 timeout)
 
 static int
 type_pf_elem_tadd(struct hbucket *n, const struct type_pf_elem *value,
-		  u8 ahash_max, u32 timeout)
+		  u8 ahash_max, u32 cadt_flags, u32 timeout)
 {
 	struct type_pf_elem *data;
 
@@ -727,6 +754,11 @@ type_pf_elem_tadd(struct hbucket *n, const struct type_pf_elem *value,
 	data = ahash_tdata(n, n->pos++);
 	type_pf_data_copy(data, value);
 	type_pf_data_timeout_set(data, timeout);
+#ifdef IP_SET_HASH_WITH_NETS
+	/* Resizing won't overwrite stored flags */
+	if (cadt_flags)
+		type_pf_data_flags(data, cadt_flags);
+#endif
 	return 0;
 }
 
@@ -747,7 +779,7 @@ type_pf_expire(struct ip_set_hash *h)
 			if (type_pf_data_expired(data)) {
 				pr_debug("expired %u/%u\n", i, j);
 #ifdef IP_SET_HASH_WITH_NETS
-				del_cidr(h, data->cidr, HOST_MASK);
+				del_cidr(h, CIDR(data->cidr), HOST_MASK);
 #endif
 				if (j != n->pos - 1)
 					/* Not last one */
@@ -815,7 +847,7 @@ retry:
 		for (j = 0; j < n->pos; j++) {
 			data = ahash_tdata(n, j);
 			m = hbucket(t, HKEY(data, h->initval, htable_bits));
-			ret = type_pf_elem_tadd(m, data, AHASH_MAX(h),
+			ret = type_pf_elem_tadd(m, data, AHASH_MAX(h), 0,
 						type_pf_data_timeout(data));
 			if (ret < 0) {
 				read_unlock_bh(&set->lock);
@@ -849,6 +881,7 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	int ret = 0, i, j = AHASH_MAX(h) + 1;
 	bool flag_exist = flags & IPSET_FLAG_EXIST;
 	u32 key, multi = 0;
+	u32 cadt_flags = flags >> 16;
 
 	if (h->elements >= h->maxelem)
 		/* FIXME: when set is full, we slow down here */
@@ -868,6 +901,7 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		data = ahash_tdata(n, i);
 		if (type_pf_data_equal(data, d, &multi)) {
 			if (type_pf_data_expired(data) || flag_exist)
+				/* Just timeout value may be updated */
 				j = i;
 			else {
 				ret = -IPSET_ERR_EXIST;
@@ -880,15 +914,18 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	if (j != AHASH_MAX(h) + 1) {
 		data = ahash_tdata(n, j);
 #ifdef IP_SET_HASH_WITH_NETS
-		del_cidr(h, data->cidr, HOST_MASK);
-		add_cidr(h, d->cidr, HOST_MASK);
+		del_cidr(h, CIDR(data->cidr), HOST_MASK);
+		add_cidr(h, CIDR(d->cidr), HOST_MASK);
 #endif
 		type_pf_data_copy(data, d);
 		type_pf_data_timeout_set(data, timeout);
+#ifdef IP_SET_HASH_WITH_NETS
+		type_pf_data_flags(data, cadt_flags);
+#endif
 		goto out;
 	}
 	TUNE_AHASH_MAX(h, multi);
-	ret = type_pf_elem_tadd(n, d, AHASH_MAX(h), timeout);
+	ret = type_pf_elem_tadd(n, d, AHASH_MAX(h), cadt_flags, timeout);
 	if (ret != 0) {
 		if (ret == -EAGAIN)
 			type_pf_data_next(h, d);
@@ -896,7 +933,7 @@ type_pf_tadd(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	}
 
 #ifdef IP_SET_HASH_WITH_NETS
-	add_cidr(h, d->cidr, HOST_MASK);
+	add_cidr(h, CIDR(d->cidr), HOST_MASK);
 #endif
 	h->elements++;
 out:
@@ -930,7 +967,7 @@ type_pf_tdel(struct ip_set *set, void *value, u32 timeout, u32 flags)
 		n->pos--;
 		h->elements--;
 #ifdef IP_SET_HASH_WITH_NETS
-		del_cidr(h, d->cidr, HOST_MASK);
+		del_cidr(h, CIDR(d->cidr), HOST_MASK);
 #endif
 		if (n->pos + AHASH_INIT_SIZE < n->size) {
 			void *tmp = kzalloc((n->size - AHASH_INIT_SIZE)
@@ -968,8 +1005,9 @@ type_pf_ttest_cidrs(struct ip_set *set, struct type_pf_elem *d, u32 timeout)
 		n = hbucket(t, key);
 		for (i = 0; i < n->pos; i++) {
 			data = ahash_tdata(n, i);
-			if (type_pf_data_equal(data, d, &multi))
-				return !type_pf_data_expired(data);
+			if (type_pf_data_equal(data, d, &multi) &&
+			    !type_pf_data_expired(data))
+				return type_pf_data_match(data);
 		}
 	}
 	return 0;
@@ -987,15 +1025,16 @@ type_pf_ttest(struct ip_set *set, void *value, u32 timeout, u32 flags)
 	u32 key, multi = 0;
 
 #ifdef IP_SET_HASH_WITH_NETS
-	if (d->cidr == SET_HOST_MASK(set->family))
+	if (CIDR(d->cidr) == SET_HOST_MASK(set->family))
 		return type_pf_ttest_cidrs(set, d, timeout);
 #endif
 	key = HKEY(d, h->initval, t->htable_bits);
 	n = hbucket(t, key);
 	for (i = 0; i < n->pos; i++) {
 		data = ahash_tdata(n, i);
-		if (type_pf_data_equal(data, d, &multi))
-			return !type_pf_data_expired(data);
+		if (type_pf_data_equal(data, d, &multi) &&
+		    !type_pf_data_expired(data))
+			return type_pf_data_match(data);
 	}
 	return 0;
 }
@@ -1108,14 +1147,17 @@ type_pf_gc_init(struct ip_set *set)
 #undef type_pf_data_isnull
 #undef type_pf_data_copy
 #undef type_pf_data_zero_out
+#undef type_pf_data_netmask
 #undef type_pf_data_list
 #undef type_pf_data_tlist
+#undef type_pf_data_next
+#undef type_pf_data_flags
+#undef type_pf_data_match
 
 #undef type_pf_elem
 #undef type_pf_telem
 #undef type_pf_data_timeout
 #undef type_pf_data_expired
-#undef type_pf_data_netmask
 #undef type_pf_data_timeout_set
 
 #undef type_pf_elem_add
@@ -1125,6 +1167,7 @@ type_pf_gc_init(struct ip_set *set)
 #undef type_pf_test
 
 #undef type_pf_elem_tadd
+#undef type_pf_del_telem
 #undef type_pf_expire
 #undef type_pf_tadd
 #undef type_pf_tdel
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 0edb35b..5d05e69 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -41,12 +41,19 @@ hash_ipportnet_same_set(const struct ip_set *a, const struct ip_set *b);
 
 /* The type variant functions: IPv4 */
 
+/* We squeeze the "nomatch" flag into cidr: we don't support cidr == 0
+ * However this way we have to store internally cidr - 1,
+ * dancing back and forth.
+ */
+#define IP_SET_HASH_WITH_NETS_PACKED
+
 /* Member elements without timeout */
 struct hash_ipportnet4_elem {
 	__be32 ip;
 	__be32 ip2;
 	__be16 port;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 	u8 proto;
 };
 
@@ -55,7 +62,8 @@ struct hash_ipportnet4_telem {
 	__be32 ip;
 	__be32 ip2;
 	__be16 port;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 	u8 proto;
 	unsigned long timeout;
 };
@@ -86,10 +94,22 @@ hash_ipportnet4_data_copy(struct hash_ipportnet4_elem *dst,
 }
 
 static inline void
+hash_ipportnet4_data_flags(struct hash_ipportnet4_elem *dst, u32 flags)
+{
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+}
+
+static inline bool
+hash_ipportnet4_data_match(const struct hash_ipportnet4_elem *elem)
+{
+	return !elem->nomatch;
+}
+
+static inline void
 hash_ipportnet4_data_netmask(struct hash_ipportnet4_elem *elem, u8 cidr)
 {
 	elem->ip2 &= ip_set_netmask(cidr);
-	elem->cidr = cidr;
+	elem->cidr = cidr - 1;
 }
 
 static inline void
@@ -102,11 +122,15 @@ static bool
 hash_ipportnet4_data_list(struct sk_buff *skb,
 			  const struct hash_ipportnet4_elem *data)
 {
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP2, data->ip2);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -119,14 +143,17 @@ hash_ipportnet4_data_tlist(struct sk_buff *skb,
 {
 	const struct hash_ipportnet4_telem *tdata =
 		(const struct hash_ipportnet4_telem *)data;
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP2, tdata->ip2);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, tdata->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(tdata->timeout)));
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 
 	return 0;
 
@@ -158,13 +185,11 @@ hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet4_elem data = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
 	};
 
-	if (data.cidr == 0)
-		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		data.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
@@ -172,7 +197,7 @@ hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 
 	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
 	ip4addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2);
-	data.ip2 &= ip_set_netmask(data.cidr);
+	data.ip2 &= ip_set_netmask(data.cidr + 1);
 
 	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
@@ -183,17 +208,19 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet4_elem data = { .cidr = HOST_MASK };
+	struct hash_ipportnet4_elem data = { .cidr = HOST_MASK - 1 };
 	u32 ip, ip_to = 0, p = 0, port, port_to;
 	u32 ip2_from = 0, ip2_to, ip2_last, ip2;
 	u32 timeout = h->timeout;
 	bool with_ports = false;
+	u8 cidr;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -208,9 +235,10 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR2]) {
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
-		if (!data.cidr)
+		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
+		data.cidr = cidr - 1;
 	}
 
 	if (tb[IPSET_ATTR_PORT])
@@ -236,12 +264,18 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
+	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (cadt_flags << 16);
+	}
+
 	with_ports = with_ports && tb[IPSET_ATTR_PORT_TO];
 	if (adt == IPSET_TEST ||
 	    !(tb[IPSET_ATTR_CIDR] || tb[IPSET_ATTR_IP_TO] || with_ports ||
 	      tb[IPSET_ATTR_IP2_TO])) {
 		data.ip = htonl(ip);
-		data.ip2 = htonl(ip2_from & ip_set_hostmask(data.cidr));
+		data.ip2 = htonl(ip2_from & ip_set_hostmask(data.cidr + 1));
 		ret = adtfn(set, &data, timeout, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
@@ -275,7 +309,7 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 		if (ip2_from + UINT_MAX == ip2_to)
 			return -IPSET_ERR_HASH_RANGE;
 	} else {
-		ip_set_mask_from_to(ip2_from, ip2_to, data.cidr);
+		ip_set_mask_from_to(ip2_from, ip2_to, data.cidr + 1);
 	}
 
 	if (retried)
@@ -290,7 +324,8 @@ hash_ipportnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 			while (!after(ip2, ip2_to)) {
 				data.ip2 = htonl(ip2);
 				ip2_last = ip_set_range_to_cidr(ip2, ip2_to,
-								&data.cidr);
+								&cidr);
+				data.cidr = cidr - 1;
 				ret = adtfn(set, &data, timeout, flags);
 
 				if (ret && !ip_set_eexist(ret, flags))
@@ -321,7 +356,8 @@ struct hash_ipportnet6_elem {
 	union nf_inet_addr ip;
 	union nf_inet_addr ip2;
 	__be16 port;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 	u8 proto;
 };
 
@@ -329,7 +365,8 @@ struct hash_ipportnet6_telem {
 	union nf_inet_addr ip;
 	union nf_inet_addr ip2;
 	__be16 port;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 	u8 proto;
 	unsigned long timeout;
 };
@@ -360,6 +397,18 @@ hash_ipportnet6_data_copy(struct hash_ipportnet6_elem *dst,
 }
 
 static inline void
+hash_ipportnet6_data_flags(struct hash_ipportnet6_elem *dst, u32 flags)
+{
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+}
+
+static inline bool
+hash_ipportnet6_data_match(const struct hash_ipportnet6_elem *elem)
+{
+	return !elem->nomatch;
+}
+
+static inline void
 hash_ipportnet6_data_zero_out(struct hash_ipportnet6_elem *elem)
 {
 	elem->proto = 0;
@@ -378,18 +427,22 @@ static inline void
 hash_ipportnet6_data_netmask(struct hash_ipportnet6_elem *elem, u8 cidr)
 {
 	ip6_netmask(&elem->ip2, cidr);
-	elem->cidr = cidr;
+	elem->cidr = cidr - 1;
 }
 
 static bool
 hash_ipportnet6_data_list(struct sk_buff *skb,
 			  const struct hash_ipportnet6_elem *data)
 {
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP2, &data->ip2);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -402,14 +455,17 @@ hash_ipportnet6_data_tlist(struct sk_buff *skb,
 {
 	const struct hash_ipportnet6_telem *e =
 		(const struct hash_ipportnet6_telem *)data;
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP2, &data->ip2);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR2, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(e->timeout)));
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -438,13 +494,11 @@ hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportnet6_elem data = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
 	};
 
-	if (data.cidr == 0)
-		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		data.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
@@ -452,7 +506,7 @@ hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 
 	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
 	ip6addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2.in6);
-	ip6_netmask(&data.ip2, data.cidr);
+	ip6_netmask(&data.ip2, data.cidr + 1);
 
 	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
@@ -463,16 +517,18 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_ipportnet6_elem data = { .cidr = HOST_MASK };
+	struct hash_ipportnet6_elem data = { .cidr = HOST_MASK - 1 };
 	u32 port, port_to;
 	u32 timeout = h->timeout;
 	bool with_ports = false;
+	u8 cidr;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] || !tb[IPSET_ATTR_IP2] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS) ||
 		     tb[IPSET_ATTR_IP_TO] ||
 		     tb[IPSET_ATTR_CIDR]))
 		return -IPSET_ERR_PROTOCOL;
@@ -490,13 +546,14 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR2])
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
-
-	if (!data.cidr)
-		return -IPSET_ERR_INVALID_CIDR;
+	if (tb[IPSET_ATTR_CIDR2]) {
+		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR2]);
+		if (!cidr || cidr > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+		data.cidr = cidr - 1;
+	}
 
-	ip6_netmask(&data.ip2, data.cidr);
+	ip6_netmask(&data.ip2, data.cidr + 1);
 
 	if (tb[IPSET_ATTR_PORT])
 		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
@@ -521,6 +578,12 @@ hash_ipportnet6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
+	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (cadt_flags << 16);
+	}
+
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
@@ -624,7 +687,8 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	/*		  1	   SCTP and UDPLITE support added */
-	.revision_max	= 2,	/* Range as input support for IPv4 added */
+	/*		  2	   Range as input support for IPv4 added */
+	.revision_max	= 3,	/* nomatch flag support added */
 	.create		= hash_ipportnet_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
@@ -643,6 +707,7 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_CIDR2]	= { .type = NLA_U8 },
 		[IPSET_ATTR_PROTO]	= { .type = NLA_U8 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
 	},
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 5a4457a..7c3d945 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -43,7 +43,7 @@ hash_net_same_set(const struct ip_set *a, const struct ip_set *b);
 struct hash_net4_elem {
 	__be32 ip;
 	u16 padding0;
-	u8 padding1;
+	u8 nomatch;
 	u8 cidr;
 };
 
@@ -51,7 +51,7 @@ struct hash_net4_elem {
 struct hash_net4_telem {
 	__be32 ip;
 	u16 padding0;
-	u8 padding1;
+	u8 nomatch;
 	u8 cidr;
 	unsigned long timeout;
 };
@@ -61,7 +61,8 @@ hash_net4_data_equal(const struct hash_net4_elem *ip1,
 		     const struct hash_net4_elem *ip2,
 		     u32 *multi)
 {
-	return ip1->ip == ip2->ip && ip1->cidr == ip2->cidr;
+	return ip1->ip == ip2->ip &&
+	       ip1->cidr == ip2->cidr;
 }
 
 static inline bool
@@ -76,6 +77,19 @@ hash_net4_data_copy(struct hash_net4_elem *dst,
 {
 	dst->ip = src->ip;
 	dst->cidr = src->cidr;
+	dst->nomatch = src->nomatch;
+}
+
+static inline void
+hash_net4_data_flags(struct hash_net4_elem *dst, u32 flags)
+{
+	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+}
+
+static inline bool
+hash_net4_data_match(const struct hash_net4_elem *elem)
+{
+	return !elem->nomatch;
 }
 
 static inline void
@@ -95,8 +109,12 @@ hash_net4_data_zero_out(struct hash_net4_elem *elem)
 static bool
 hash_net4_data_list(struct sk_buff *skb, const struct hash_net4_elem *data)
 {
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -108,11 +126,14 @@ hash_net4_data_tlist(struct sk_buff *skb, const struct hash_net4_elem *data)
 {
 	const struct hash_net4_telem *tdata =
 		(const struct hash_net4_telem *)data;
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, tdata->cidr);
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(tdata->timeout)));
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 
 	return 0;
 
@@ -167,7 +188,8 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -179,7 +201,7 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_CIDR]) {
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (!data.cidr)
+		if (!data.cidr || data.cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
@@ -189,6 +211,12 @@ hash_net4_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
+	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (cadt_flags << 16);
+	}
+
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
 		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
 		ret = adtfn(set, &data, timeout, flags);
@@ -236,14 +264,14 @@ hash_net_same_set(const struct ip_set *a, const struct ip_set *b)
 struct hash_net6_elem {
 	union nf_inet_addr ip;
 	u16 padding0;
-	u8 padding1;
+	u8 nomatch;
 	u8 cidr;
 };
 
 struct hash_net6_telem {
 	union nf_inet_addr ip;
 	u16 padding0;
-	u8 padding1;
+	u8 nomatch;
 	u8 cidr;
 	unsigned long timeout;
 };
@@ -269,6 +297,19 @@ hash_net6_data_copy(struct hash_net6_elem *dst,
 {
 	dst->ip.in6 = src->ip.in6;
 	dst->cidr = src->cidr;
+	dst->nomatch = src->nomatch;
+}
+
+static inline void
+hash_net6_data_flags(struct hash_net6_elem *dst, u32 flags)
+{
+	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+}
+
+static inline bool
+hash_net6_data_match(const struct hash_net6_elem *elem)
+{
+	return !elem->nomatch;
 }
 
 static inline void
@@ -296,8 +337,12 @@ hash_net6_data_netmask(struct hash_net6_elem *elem, u8 cidr)
 static bool
 hash_net6_data_list(struct sk_buff *skb, const struct hash_net6_elem *data)
 {
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -309,11 +354,14 @@ hash_net6_data_tlist(struct sk_buff *skb, const struct hash_net6_elem *data)
 {
 	const struct hash_net6_telem *e =
 		(const struct hash_net6_telem *)data;
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, e->cidr);
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(e->timeout)));
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -366,7 +414,8 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -381,7 +430,7 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (tb[IPSET_ATTR_CIDR])
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
 
-	if (!data.cidr)
+	if (!data.cidr || data.cidr > HOST_MASK)
 		return -IPSET_ERR_INVALID_CIDR;
 
 	ip6_netmask(&data.ip, data.cidr);
@@ -392,6 +441,12 @@ hash_net6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
+	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (cadt_flags << 16);
+	}
+
 	ret = adtfn(set, &data, timeout, flags);
 
 	return ip_set_eexist(ret, flags) ? 0 : ret;
@@ -474,7 +529,8 @@ static struct ip_set_type hash_net_type __read_mostly = {
 	.dimension	= IPSET_DIM_ONE,
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
-	.revision_max	= 1,	/* Range as input support for IPv4 added */
+	/*		= 1 	   Range as input support for IPv4 added */
+	.revision_max	= 2,	/* nomatch flag support added */
 	.create		= hash_net_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
@@ -488,6 +544,7 @@ static struct ip_set_type hash_net_type __read_mostly = {
 		[IPSET_ATTR_IP_TO]	= { .type = NLA_NESTED },
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.me		= THIS_MODULE,
 };
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index a9fb4af..f24037f 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -163,7 +163,8 @@ struct hash_netiface4_elem_hashed {
 	__be32 ip;
 	u8 physdev;
 	u8 cidr;
-	u16 padding;
+	u8 nomatch;
+	u8 padding;
 };
 
 #define HKEY_DATALEN	sizeof(struct hash_netiface4_elem_hashed)
@@ -173,7 +174,8 @@ struct hash_netiface4_elem {
 	__be32 ip;
 	u8 physdev;
 	u8 cidr;
-	u16 padding;
+	u8 nomatch;
+	u8 padding;
 	const char *iface;
 };
 
@@ -182,7 +184,8 @@ struct hash_netiface4_telem {
 	__be32 ip;
 	u8 physdev;
 	u8 cidr;
-	u16 padding;
+	u8 nomatch;
+	u8 padding;
 	const char *iface;
 	unsigned long timeout;
 };
@@ -207,11 +210,25 @@ hash_netiface4_data_isnull(const struct hash_netiface4_elem *elem)
 
 static inline void
 hash_netiface4_data_copy(struct hash_netiface4_elem *dst,
-			 const struct hash_netiface4_elem *src) {
+			 const struct hash_netiface4_elem *src)
+{
 	dst->ip = src->ip;
 	dst->cidr = src->cidr;
 	dst->physdev = src->physdev;
 	dst->iface = src->iface;
+	dst->nomatch = src->nomatch;
+}
+
+static inline void
+hash_netiface4_data_flags(struct hash_netiface4_elem *dst, u32 flags)
+{
+	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+}
+
+static inline bool
+hash_netiface4_data_match(const struct hash_netiface4_elem *elem)
+{
+	return !elem->nomatch;
 }
 
 static inline void
@@ -233,11 +250,13 @@ hash_netiface4_data_list(struct sk_buff *skb,
 {
 	u32 flags = data->physdev ? IPSET_FLAG_PHYSDEV : 0;
 
+	if (data->nomatch)
+		flags |= IPSET_FLAG_NOMATCH;
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
 	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
 	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, flags);
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -252,11 +271,13 @@ hash_netiface4_data_tlist(struct sk_buff *skb,
 		(const struct hash_netiface4_telem *)data;
 	u32 flags = data->physdev ? IPSET_FLAG_PHYSDEV : 0;
 
+	if (data->nomatch)
+		flags |= IPSET_FLAG_NOMATCH;
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
 	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
 	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, flags);
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(tdata->timeout)));
 
@@ -361,7 +382,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_CIDR]) {
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (!data.cidr)
+		if (!data.cidr || data.cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
@@ -387,6 +408,8 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_PHYSDEV)
 			data.physdev = 1;
+		if (adt == IPSET_ADD && (cadt_flags & IPSET_FLAG_NOMATCH))
+			flags |= (cadt_flags << 16);
 	}
 
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
@@ -440,7 +463,8 @@ struct hash_netiface6_elem_hashed {
 	union nf_inet_addr ip;
 	u8 physdev;
 	u8 cidr;
-	u16 padding;
+	u8 nomatch;
+	u8 padding;
 };
 
 #define HKEY_DATALEN	sizeof(struct hash_netiface6_elem_hashed)
@@ -449,7 +473,8 @@ struct hash_netiface6_elem {
 	union nf_inet_addr ip;
 	u8 physdev;
 	u8 cidr;
-	u16 padding;
+	u8 nomatch;
+	u8 padding;
 	const char *iface;
 };
 
@@ -457,7 +482,8 @@ struct hash_netiface6_telem {
 	union nf_inet_addr ip;
 	u8 physdev;
 	u8 cidr;
-	u16 padding;
+	u8 nomatch;
+	u8 padding;
 	const char *iface;
 	unsigned long timeout;
 };
@@ -488,8 +514,21 @@ hash_netiface6_data_copy(struct hash_netiface6_elem *dst,
 }
 
 static inline void
+hash_netiface6_data_flags(struct hash_netiface6_elem *dst, u32 flags)
+{
+	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
+}
+
+static inline bool
+hash_netiface6_data_match(const struct hash_netiface6_elem *elem)
+{
+	return !elem->nomatch;
+}
+
+static inline void
 hash_netiface6_data_zero_out(struct hash_netiface6_elem *elem)
 {
+	elem->cidr = 0;
 }
 
 static inline void
@@ -514,11 +553,13 @@ hash_netiface6_data_list(struct sk_buff *skb,
 {
 	u32 flags = data->physdev ? IPSET_FLAG_PHYSDEV : 0;
 
+	if (data->nomatch)
+		flags |= IPSET_FLAG_NOMATCH;
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
 	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
 	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, flags);
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -533,11 +574,13 @@ hash_netiface6_data_tlist(struct sk_buff *skb,
 		(const struct hash_netiface6_telem *)data;
 	u32 flags = data->physdev ? IPSET_FLAG_PHYSDEV : 0;
 
+	if (data->nomatch)
+		flags |= IPSET_FLAG_NOMATCH;
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
 	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
 	NLA_PUT_STRING(skb, IPSET_ATTR_IFACE, data->iface);
 	if (flags)
-		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, flags);
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(e->timeout)));
 	return 0;
@@ -636,7 +679,7 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_CIDR])
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-	if (!data.cidr)
+	if (!data.cidr || data.cidr > HOST_MASK)
 		return -IPSET_ERR_INVALID_CIDR;
 	ip6_netmask(&data.ip, data.cidr);
 
@@ -662,6 +705,8 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
 		if (cadt_flags & IPSET_FLAG_PHYSDEV)
 			data.physdev = 1;
+		if (adt == IPSET_ADD && (cadt_flags & IPSET_FLAG_NOMATCH))
+			flags |= (cadt_flags << 16);
 	}
 
 	ret = adtfn(set, &data, timeout, flags);
@@ -748,6 +793,7 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
+	.revision_max	= 1,	/* nomatch flag support added */
 	.create		= hash_netiface_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 1fcc102..ce2e771 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -40,12 +40,19 @@ hash_netport_same_set(const struct ip_set *a, const struct ip_set *b);
 
 /* The type variant functions: IPv4 */
 
+/* We squeeze the "nomatch" flag into cidr: we don't support cidr == 0
+ * However this way we have to store internally cidr - 1,
+ * dancing back and forth.
+ */
+#define IP_SET_HASH_WITH_NETS_PACKED
+
 /* Member elements without timeout */
 struct hash_netport4_elem {
 	__be32 ip;
 	__be16 port;
 	u8 proto;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 };
 
 /* Member elements with timeout support */
@@ -53,7 +60,8 @@ struct hash_netport4_telem {
 	__be32 ip;
 	__be16 port;
 	u8 proto;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 	unsigned long timeout;
 };
 
@@ -82,13 +90,26 @@ hash_netport4_data_copy(struct hash_netport4_elem *dst,
 	dst->port = src->port;
 	dst->proto = src->proto;
 	dst->cidr = src->cidr;
+	dst->nomatch = src->nomatch;
+}
+
+static inline void
+hash_netport4_data_flags(struct hash_netport4_elem *dst, u32 flags)
+{
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+}
+
+static inline bool
+hash_netport4_data_match(const struct hash_netport4_elem *elem)
+{
+	return !elem->nomatch;
 }
 
 static inline void
 hash_netport4_data_netmask(struct hash_netport4_elem *elem, u8 cidr)
 {
 	elem->ip &= ip_set_netmask(cidr);
-	elem->cidr = cidr;
+	elem->cidr = cidr - 1;
 }
 
 static inline void
@@ -101,10 +122,14 @@ static bool
 hash_netport4_data_list(struct sk_buff *skb,
 			const struct hash_netport4_elem *data)
 {
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, data->ip);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -117,13 +142,16 @@ hash_netport4_data_tlist(struct sk_buff *skb,
 {
 	const struct hash_netport4_telem *tdata =
 		(const struct hash_netport4_telem *)data;
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
 	NLA_PUT_IPADDR4(skb, IPSET_ATTR_IP, tdata->ip);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, tdata->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(tdata->timeout)));
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 
 	return 0;
 
@@ -154,20 +182,18 @@ hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport4_elem data = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1
 	};
 
-	if (data.cidr == 0)
-		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		data.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
 	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
-	data.ip &= ip_set_netmask(data.cidr);
+	data.ip &= ip_set_netmask(data.cidr + 1);
 
 	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
@@ -178,16 +204,18 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netport4_elem data = { .cidr = HOST_MASK };
+	struct hash_netport4_elem data = { .cidr = HOST_MASK - 1 };
 	u32 port, port_to, p = 0, ip = 0, ip_to, last;
 	u32 timeout = h->timeout;
 	bool with_ports = false;
+	u8 cidr;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 
 	if (tb[IPSET_ATTR_LINENO])
@@ -198,9 +226,10 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		return ret;
 
 	if (tb[IPSET_ATTR_CIDR]) {
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (!data.cidr)
+		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!cidr || cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
+		data.cidr = cidr - 1;
 	}
 
 	if (tb[IPSET_ATTR_PORT])
@@ -227,8 +256,15 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 	}
 
 	with_ports = with_ports && tb[IPSET_ATTR_PORT_TO];
+
+	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (cadt_flags << 16);
+	}
+
 	if (adt == IPSET_TEST || !(with_ports || tb[IPSET_ATTR_IP_TO])) {
-		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
+		data.ip = htonl(ip & ip_set_hostmask(data.cidr + 1));
 		ret = adtfn(set, &data, timeout, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
 	}
@@ -248,14 +284,15 @@ hash_netport4_uadt(struct ip_set *set, struct nlattr *tb[],
 		if (ip + UINT_MAX == ip_to)
 			return -IPSET_ERR_HASH_RANGE;
 	} else {
-		ip_set_mask_from_to(ip, ip_to, data.cidr);
+		ip_set_mask_from_to(ip, ip_to, data.cidr + 1);
 	}
 
 	if (retried)
 		ip = h->next.ip;
 	while (!after(ip, ip_to)) {
 		data.ip = htonl(ip);
-		last = ip_set_range_to_cidr(ip, ip_to, &data.cidr);
+		last = ip_set_range_to_cidr(ip, ip_to, &cidr);
+		data.cidr = cidr - 1;
 		p = retried && ip == h->next.ip ? h->next.port : port;
 		for (; p <= port_to; p++) {
 			data.port = htons(p);
@@ -288,14 +325,16 @@ struct hash_netport6_elem {
 	union nf_inet_addr ip;
 	__be16 port;
 	u8 proto;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 };
 
 struct hash_netport6_telem {
 	union nf_inet_addr ip;
 	__be16 port;
 	u8 proto;
-	u8 cidr;
+	u8 cidr:7;
+	u8 nomatch:1;
 	unsigned long timeout;
 };
 
@@ -324,6 +363,18 @@ hash_netport6_data_copy(struct hash_netport6_elem *dst,
 }
 
 static inline void
+hash_netport6_data_flags(struct hash_netport6_elem *dst, u32 flags)
+{
+	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
+}
+
+static inline bool
+hash_netport6_data_match(const struct hash_netport6_elem *elem)
+{
+	return !elem->nomatch;
+}
+
+static inline void
 hash_netport6_data_zero_out(struct hash_netport6_elem *elem)
 {
 	elem->proto = 0;
@@ -342,17 +393,21 @@ static inline void
 hash_netport6_data_netmask(struct hash_netport6_elem *elem, u8 cidr)
 {
 	ip6_netmask(&elem->ip, cidr);
-	elem->cidr = cidr;
+	elem->cidr = cidr - 1;
 }
 
 static bool
 hash_netport6_data_list(struct sk_buff *skb,
 			const struct hash_netport6_elem *data)
 {
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
+
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &data->ip);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -365,13 +420,16 @@ hash_netport6_data_tlist(struct sk_buff *skb,
 {
 	const struct hash_netport6_telem *e =
 		(const struct hash_netport6_telem *)data;
+	u32 flags = data->nomatch ? IPSET_FLAG_NOMATCH : 0;
 
 	NLA_PUT_IPADDR6(skb, IPSET_ATTR_IP, &e->ip);
 	NLA_PUT_NET16(skb, IPSET_ATTR_PORT, data->port);
-	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr);
+	NLA_PUT_U8(skb, IPSET_ATTR_CIDR, data->cidr + 1);
 	NLA_PUT_U8(skb, IPSET_ATTR_PROTO, data->proto);
 	NLA_PUT_NET32(skb, IPSET_ATTR_TIMEOUT,
 		      htonl(ip_set_timeout_get(e->timeout)));
+	if (flags)
+		NLA_PUT_NET32(skb, IPSET_ATTR_CADT_FLAGS, htonl(flags));
 	return 0;
 
 nla_put_failure:
@@ -400,20 +458,18 @@ hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netport6_elem data = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr - 1 : HOST_MASK - 1,
 	};
 
-	if (data.cidr == 0)
-		return -EINVAL;
 	if (adt == IPSET_TEST)
-		data.cidr = HOST_MASK;
+		data.cidr = HOST_MASK - 1;
 
 	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
 	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6_netmask(&data.ip, data.cidr);
+	ip6_netmask(&data.ip, data.cidr + 1);
 
 	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
@@ -424,16 +480,18 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netport6_elem data = { .cidr = HOST_MASK };
+	struct hash_netport6_elem data = { .cidr = HOST_MASK  - 1 };
 	u32 port, port_to;
 	u32 timeout = h->timeout;
 	bool with_ports = false;
+	u8 cidr;
 	int ret;
 
 	if (unlikely(!tb[IPSET_ATTR_IP] ||
 		     !ip_set_attr_netorder(tb, IPSET_ATTR_PORT) ||
 		     !ip_set_optattr_netorder(tb, IPSET_ATTR_PORT_TO) ||
-		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT)))
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_TIMEOUT) ||
+		     !ip_set_optattr_netorder(tb, IPSET_ATTR_CADT_FLAGS)))
 		return -IPSET_ERR_PROTOCOL;
 	if (unlikely(tb[IPSET_ATTR_IP_TO]))
 		return -IPSET_ERR_HASH_RANGE_UNSUPPORTED;
@@ -445,11 +503,13 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 	if (ret)
 		return ret;
 
-	if (tb[IPSET_ATTR_CIDR])
-		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-	if (!data.cidr)
-		return -IPSET_ERR_INVALID_CIDR;
-	ip6_netmask(&data.ip, data.cidr);
+	if (tb[IPSET_ATTR_CIDR]) {
+		cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
+		if (!cidr || cidr > HOST_MASK)
+			return -IPSET_ERR_INVALID_CIDR;
+		data.cidr = cidr - 1;
+	}
+	ip6_netmask(&data.ip, data.cidr + 1);
 
 	if (tb[IPSET_ATTR_PORT])
 		data.port = nla_get_be16(tb[IPSET_ATTR_PORT]);
@@ -474,6 +534,12 @@ hash_netport6_uadt(struct ip_set *set, struct nlattr *tb[],
 		timeout = ip_set_timeout_uget(tb[IPSET_ATTR_TIMEOUT]);
 	}
 
+	if (tb[IPSET_ATTR_CADT_FLAGS] && adt == IPSET_ADD) {
+		u32 cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+		if (cadt_flags & IPSET_FLAG_NOMATCH)
+			flags |= (cadt_flags << 16);
+	}
+
 	if (adt == IPSET_TEST || !with_ports || !tb[IPSET_ATTR_PORT_TO]) {
 		ret = adtfn(set, &data, timeout, flags);
 		return ip_set_eexist(ret, flags) ? 0 : ret;
@@ -576,7 +642,8 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
 	/*		  1	   SCTP and UDPLITE support added */
-	.revision_max	= 2,	/* Range as input support for IPv4 added */
+	/*		  2,	   Range as input support for IPv4 added */
+	.revision_max	= 3,	/* nomatch flag support added */
 	.create		= hash_netport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
@@ -595,6 +662,7 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 		[IPSET_ATTR_CIDR]	= { .type = NLA_U8 },
 		[IPSET_ATTR_TIMEOUT]	= { .type = NLA_U32 },
 		[IPSET_ATTR_LINENO]	= { .type = NLA_U32 },
+		[IPSET_ATTR_CADT_FLAGS]	= { .type = NLA_U32 },
 	},
 	.me		= THIS_MODULE,
 };
-- 
1.7.7.3
