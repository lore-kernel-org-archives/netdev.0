From: pablo@netfilter.org
Subject: [PATCH 09/16] netfilter: ipset: Add /0 network support to hash:net,iface type
Date: Mon, 24 Sep 2012 21:19:21 +0200
Message-ID: <1348514369-3272-10-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Now it is possible to setup a single hash:net,iface type of set and
a single ip6?tables match which covers all egress/ingress filtering.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_netiface.c |   44 +++++++++++++---------------
 1 file changed, 21 insertions(+), 23 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index 632693f..e7c671d 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -140,7 +140,7 @@ struct hash_netiface4_elem_hashed {
 	u8 physdev;
 	u8 cidr;
 	u8 nomatch;
-	u8 padding;
+	u8 elem;
 };
 
 #define HKEY_DATALEN	sizeof(struct hash_netiface4_elem_hashed)
@@ -151,7 +151,7 @@ struct hash_netiface4_elem {
 	u8 physdev;
 	u8 cidr;
 	u8 nomatch;
-	u8 padding;
+	u8 elem;
 	const char *iface;
 };
 
@@ -161,7 +161,7 @@ struct hash_netiface4_telem {
 	u8 physdev;
 	u8 cidr;
 	u8 nomatch;
-	u8 padding;
+	u8 elem;
 	const char *iface;
 	unsigned long timeout;
 };
@@ -181,18 +181,14 @@ hash_netiface4_data_equal(const struct hash_netiface4_elem *ip1,
 static inline bool
 hash_netiface4_data_isnull(const struct hash_netiface4_elem *elem)
 {
-	return elem->cidr == 0;
+	return elem->elem == 0;
 }
 
 static inline void
 hash_netiface4_data_copy(struct hash_netiface4_elem *dst,
 			 const struct hash_netiface4_elem *src)
 {
-	dst->ip = src->ip;
-	dst->cidr = src->cidr;
-	dst->physdev = src->physdev;
-	dst->iface = src->iface;
-	dst->nomatch = src->nomatch;
+	memcpy(dst, src, sizeof(*dst));
 }
 
 static inline void
@@ -217,7 +213,7 @@ hash_netiface4_data_netmask(struct hash_netiface4_elem *elem, u8 cidr)
 static inline void
 hash_netiface4_data_zero_out(struct hash_netiface4_elem *elem)
 {
-	elem->cidr = 0;
+	elem->elem = 0;
 }
 
 static bool
@@ -288,7 +284,8 @@ hash_netiface4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface4_elem data = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK,
+		.elem = 1,
 	};
 	int ret;
 
@@ -339,7 +336,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netiface4_elem data = { .cidr = HOST_MASK };
+	struct hash_netiface4_elem data = { .cidr = HOST_MASK, .elem = 1 };
 	u32 ip = 0, ip_to, last;
 	u32 timeout = h->timeout;
 	char iface[IFNAMSIZ];
@@ -360,7 +357,7 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_CIDR]) {
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-		if (!data.cidr || data.cidr > HOST_MASK)
+		if (data.cidr > HOST_MASK)
 			return -IPSET_ERR_INVALID_CIDR;
 	}
 
@@ -389,7 +386,6 @@ hash_netiface4_uadt(struct ip_set *set, struct nlattr *tb[],
 		if (adt == IPSET_ADD && (cadt_flags & IPSET_FLAG_NOMATCH))
 			flags |= (cadt_flags << 16);
 	}
-
 	if (adt == IPSET_TEST || !tb[IPSET_ATTR_IP_TO]) {
 		data.ip = htonl(ip & ip_set_hostmask(data.cidr));
 		ret = adtfn(set, &data, timeout, flags);
@@ -442,7 +438,7 @@ struct hash_netiface6_elem_hashed {
 	u8 physdev;
 	u8 cidr;
 	u8 nomatch;
-	u8 padding;
+	u8 elem;
 };
 
 #define HKEY_DATALEN	sizeof(struct hash_netiface6_elem_hashed)
@@ -452,7 +448,7 @@ struct hash_netiface6_elem {
 	u8 physdev;
 	u8 cidr;
 	u8 nomatch;
-	u8 padding;
+	u8 elem;
 	const char *iface;
 };
 
@@ -461,7 +457,7 @@ struct hash_netiface6_telem {
 	u8 physdev;
 	u8 cidr;
 	u8 nomatch;
-	u8 padding;
+	u8 elem;
 	const char *iface;
 	unsigned long timeout;
 };
@@ -481,7 +477,7 @@ hash_netiface6_data_equal(const struct hash_netiface6_elem *ip1,
 static inline bool
 hash_netiface6_data_isnull(const struct hash_netiface6_elem *elem)
 {
-	return elem->cidr == 0;
+	return elem->elem == 0;
 }
 
 static inline void
@@ -506,7 +502,7 @@ hash_netiface6_data_match(const struct hash_netiface6_elem *elem)
 static inline void
 hash_netiface6_data_zero_out(struct hash_netiface6_elem *elem)
 {
-	elem->cidr = 0;
+	elem->elem = 0;
 }
 
 static inline void
@@ -590,7 +586,8 @@ hash_netiface6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_netiface6_elem data = {
-		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK
+		.cidr = h->nets[0].cidr ? h->nets[0].cidr : HOST_MASK,
+		.elem = 1,
 	};
 	int ret;
 
@@ -637,7 +634,7 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 {
 	struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
-	struct hash_netiface6_elem data = { .cidr = HOST_MASK };
+	struct hash_netiface6_elem data = { .cidr = HOST_MASK, .elem = 1 };
 	u32 timeout = h->timeout;
 	char iface[IFNAMSIZ];
 	int ret;
@@ -659,7 +656,7 @@ hash_netiface6_uadt(struct ip_set *set, struct nlattr *tb[],
 
 	if (tb[IPSET_ATTR_CIDR])
 		data.cidr = nla_get_u8(tb[IPSET_ATTR_CIDR]);
-	if (!data.cidr || data.cidr > HOST_MASK)
+	if (data.cidr > HOST_MASK)
 		return -IPSET_ERR_INVALID_CIDR;
 	ip6_netmask(&data.ip, data.cidr);
 
@@ -777,7 +774,8 @@ static struct ip_set_type hash_netiface_type __read_mostly = {
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= 0,
-	.revision_max	= 1,	/* nomatch flag support added */
+	/*		= 1,	   nomatch flag support added */
+	.revision_max	= 2,	/* /0 support added */
 	.create		= hash_netiface_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
-- 
1.7.10.4

