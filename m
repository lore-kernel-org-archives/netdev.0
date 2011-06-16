From: kaber@trash.net
Subject: [PATCH 08/20] netfilter: ipset: options and flags support added to the kernel API
Date: Thu, 16 Jun 2011 21:47:08 +0200
Message-ID: <1308253640-29942-9-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The support makes possible to specify the timeout value for
the SET target and a flag to reset the timeout for already existing
entries.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set.h         |   18 ++-
 include/linux/netfilter/ipset/ip_set_ahash.h   |    2 +-
 include/linux/netfilter/ipset/ip_set_timeout.h |    3 +
 include/linux/netfilter/xt_set.h               |   15 ++-
 net/netfilter/ipset/ip_set_bitmap_ip.c         |    6 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c      |    8 +-
 net/netfilter/ipset/ip_set_bitmap_port.c       |    7 +-
 net/netfilter/ipset/ip_set_core.c              |   26 ++--
 net/netfilter/ipset/ip_set_hash_ip.c           |   12 +-
 net/netfilter/ipset/ip_set_hash_ipport.c       |   16 ++--
 net/netfilter/ipset/ip_set_hash_ipportip.c     |   20 ++--
 net/netfilter/ipset/ip_set_hash_ipportnet.c    |   20 ++--
 net/netfilter/ipset/ip_set_hash_net.c          |   12 +-
 net/netfilter/ipset/ip_set_hash_netport.c      |   16 ++--
 net/netfilter/ipset/ip_set_list_set.c          |    8 +-
 net/netfilter/xt_set.c                         |  151 ++++++++++++++++--------
 16 files changed, 206 insertions(+), 134 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 277b7fb..68b21f5 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -217,6 +217,15 @@ struct ip_set;
 typedef int (*ipset_adtfn)(struct ip_set *set, void *value,
 			   u32 timeout, u32 flags);
 
+/* Kernel API function options */
+struct ip_set_adt_opt {
+	u8 family;		/* Actual protocol family */
+	u8 dim;			/* Dimension of match/target */
+	u8 flags;		/* Direction and negation flags */
+	u32 cmdflags;		/* Command-like flags */
+	u32 timeout;		/* Timeout value */
+};
+
 /* Set type, variant-specific part */
 struct ip_set_type_variant {
 	/* Kernelspace: test/add/del entries
@@ -224,7 +233,7 @@ struct ip_set_type_variant {
 	 *			zero for no match/success to add/delete
 	 *			positive for matching element */
 	int (*kadt)(struct ip_set *set, const struct sk_buff * skb,
-		    enum ipset_adt adt, u8 pf, u8 dim, u8 flags);
+		    enum ipset_adt adt, const struct ip_set_adt_opt *opt);
 
 	/* Userspace: test/add/del entries
 	 *		returns negative error code,
@@ -314,12 +323,13 @@ extern ip_set_id_t ip_set_nfnl_get_byindex(ip_set_id_t index);
 extern void ip_set_nfnl_put(ip_set_id_t index);
 
 /* API for iptables set match, and SET target */
+
 extern int ip_set_add(ip_set_id_t id, const struct sk_buff *skb,
-		      u8 family, u8 dim, u8 flags);
+		      const struct ip_set_adt_opt *opt);
 extern int ip_set_del(ip_set_id_t id, const struct sk_buff *skb,
-		      u8 family, u8 dim, u8 flags);
+		      const struct ip_set_adt_opt *opt);
 extern int ip_set_test(ip_set_id_t id, const struct sk_buff *skb,
-		       u8 family, u8 dim, u8 flags);
+		       const struct ip_set_adt_opt *opt);
 
 /* Utility functions */
 extern void * ip_set_alloc(size_t size);
diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index 36cf4dc..6c02193 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -586,7 +586,7 @@ nla_put_failure:
 
 static int
 type_pf_kadt(struct ip_set *set, const struct sk_buff * skb,
-	     enum ipset_adt adt, u8 pf, u8 dim, u8 flags);
+	     enum ipset_adt adt, const struct ip_set_adt_opt *opt);
 static int
 type_pf_uadt(struct ip_set *set, struct nlattr *tb[],
 	     enum ipset_adt adt, u32 *lineno, u32 flags);
diff --git a/include/linux/netfilter/ipset/ip_set_timeout.h b/include/linux/netfilter/ipset/ip_set_timeout.h
index bcdd40a..bae086a 100644
--- a/include/linux/netfilter/ipset/ip_set_timeout.h
+++ b/include/linux/netfilter/ipset/ip_set_timeout.h
@@ -22,6 +22,9 @@
 
 #define with_timeout(timeout)	((timeout) != IPSET_NO_TIMEOUT)
 
+#define opt_timeout(opt, map)	\
+	(with_timeout((opt)->timeout) ? (opt)->timeout : (map)->timeout)
+
 static inline unsigned int
 ip_set_timeout_uget(struct nlattr *tb)
 {
diff --git a/include/linux/netfilter/xt_set.h b/include/linux/netfilter/xt_set.h
index 081f1de..c0405ac 100644
--- a/include/linux/netfilter/xt_set.h
+++ b/include/linux/netfilter/xt_set.h
@@ -35,7 +35,7 @@ struct xt_set_info_target_v0 {
 	struct xt_set_info_v0 del_set;
 };
 
-/* Revision 1: current interface to netfilter/iptables */
+/* Revision 1  match and target */
 
 struct xt_set_info {
 	ip_set_id_t index;
@@ -44,13 +44,22 @@ struct xt_set_info {
 };
 
 /* match and target infos */
-struct xt_set_info_match {
+struct xt_set_info_match_v1 {
 	struct xt_set_info match_set;
 };
 
-struct xt_set_info_target {
+struct xt_set_info_target_v1 {
 	struct xt_set_info add_set;
 	struct xt_set_info del_set;
 };
 
+/* Revision 2 target */
+
+struct xt_set_info_target_v2 {
+	struct xt_set_info add_set;
+	struct xt_set_info del_set;
+	u32 flags;
+	u32 timeout;
+};
+
 #endif /*_XT_SET_H*/
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 85b1cdf..75990b3 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -219,19 +219,19 @@ nla_put_failure:
 
 static int
 bitmap_ip_kadt(struct ip_set *set, const struct sk_buff *skb,
-	       enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct bitmap_ip *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	u32 ip;
 
-	ip = ntohl(ip4addr(skb, flags & IPSET_DIM_ONE_SRC));
+	ip = ntohl(ip4addr(skb, opt->flags & IPSET_DIM_ONE_SRC));
 	if (ip < map->first_ip || ip > map->last_ip)
 		return -IPSET_ERR_BITMAP_RANGE;
 
 	ip = ip_to_id(map, ip);
 
-	return adtfn(set, &ip, map->timeout, flags);
+	return adtfn(set, &ip, opt_timeout(opt, map), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index 913a461..cbe77f3 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -338,17 +338,17 @@ nla_put_failure:
 
 static int
 bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
-		  enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct bitmap_ipmac *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct ipmac data;
 
 	/* MAC can be src only */
-	if (!(flags & IPSET_DIM_TWO_SRC))
+	if (!(opt->flags & IPSET_DIM_TWO_SRC))
 		return 0;
 
-	data.id = ntohl(ip4addr(skb, flags & IPSET_DIM_ONE_SRC));
+	data.id = ntohl(ip4addr(skb, opt->flags & IPSET_DIM_ONE_SRC));
 	if (data.id < map->first_ip || data.id > map->last_ip)
 		return -IPSET_ERR_BITMAP_RANGE;
 
@@ -360,7 +360,7 @@ bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
 	data.id -= map->first_ip;
 	data.ether = eth_hdr(skb)->h_source;
 
-	return adtfn(set, &data, map->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, map), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index a3935ee..0b0ae19 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -208,14 +208,15 @@ nla_put_failure:
 
 static int
 bitmap_port_kadt(struct ip_set *set, const struct sk_buff *skb,
-		 enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		 enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct bitmap_port *map = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	__be16 __port;
 	u16 port = 0;
 
-	if (!ip_set_get_ip_port(skb, pf, flags & IPSET_DIM_ONE_SRC, &__port))
+	if (!ip_set_get_ip_port(skb, opt->family,
+				opt->flags & IPSET_DIM_ONE_SRC, &__port))
 		return -EINVAL;
 
 	port = ntohs(__port);
@@ -225,7 +226,7 @@ bitmap_port_kadt(struct ip_set *set, const struct sk_buff *skb,
 
 	port -= map->first_port;
 
-	return adtfn(set, &port, map->timeout, flags);
+	return adtfn(set, &port, opt_timeout(opt, map), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 333b0be..c15c062 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -325,7 +325,7 @@ __ip_set_put(ip_set_id_t index)
 
 int
 ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
-	    u8 family, u8 dim, u8 flags)
+	    const struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_list[index];
 	int ret = 0;
@@ -333,19 +333,19 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 	BUG_ON(set == NULL);
 	pr_debug("set %s, index %u\n", set->name, index);
 
-	if (dim < set->type->dimension ||
-	    !(family == set->family || set->family == AF_UNSPEC))
+	if (opt->dim < set->type->dimension ||
+	    !(opt->family == set->family || set->family == AF_UNSPEC))
 		return 0;
 
 	read_lock_bh(&set->lock);
-	ret = set->variant->kadt(set, skb, IPSET_TEST, family, dim, flags);
+	ret = set->variant->kadt(set, skb, IPSET_TEST, opt);
 	read_unlock_bh(&set->lock);
 
 	if (ret == -EAGAIN) {
 		/* Type requests element to be completed */
 		pr_debug("element must be competed, ADD is triggered\n");
 		write_lock_bh(&set->lock);
-		set->variant->kadt(set, skb, IPSET_ADD, family, dim, flags);
+		set->variant->kadt(set, skb, IPSET_ADD, opt);
 		write_unlock_bh(&set->lock);
 		ret = 1;
 	}
@@ -357,7 +357,7 @@ EXPORT_SYMBOL_GPL(ip_set_test);
 
 int
 ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
-	   u8 family, u8 dim, u8 flags)
+	   const struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_list[index];
 	int ret;
@@ -365,12 +365,12 @@ ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 	BUG_ON(set == NULL);
 	pr_debug("set %s, index %u\n", set->name, index);
 
-	if (dim < set->type->dimension ||
-	    !(family == set->family || set->family == AF_UNSPEC))
+	if (opt->dim < set->type->dimension ||
+	    !(opt->family == set->family || set->family == AF_UNSPEC))
 		return 0;
 
 	write_lock_bh(&set->lock);
-	ret = set->variant->kadt(set, skb, IPSET_ADD, family, dim, flags);
+	ret = set->variant->kadt(set, skb, IPSET_ADD, opt);
 	write_unlock_bh(&set->lock);
 
 	return ret;
@@ -379,7 +379,7 @@ EXPORT_SYMBOL_GPL(ip_set_add);
 
 int
 ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
-	   u8 family, u8 dim, u8 flags)
+	   const struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_list[index];
 	int ret = 0;
@@ -387,12 +387,12 @@ ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 	BUG_ON(set == NULL);
 	pr_debug("set %s, index %u\n", set->name, index);
 
-	if (dim < set->type->dimension ||
-	    !(family == set->family || set->family == AF_UNSPEC))
+	if (opt->dim < set->type->dimension ||
+	    !(opt->family == set->family || set->family == AF_UNSPEC))
 		return 0;
 
 	write_lock_bh(&set->lock);
-	ret = set->variant->kadt(set, skb, IPSET_DEL, family, dim, flags);
+	ret = set->variant->kadt(set, skb, IPSET_DEL, opt);
 	write_unlock_bh(&set->lock);
 
 	return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 3683020..65a4454 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -110,18 +110,18 @@ nla_put_failure:
 
 static int
 hash_ip4_kadt(struct ip_set *set, const struct sk_buff *skb,
-	      enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	__be32 ip;
 
-	ip4addrptr(skb, flags & IPSET_DIM_ONE_SRC, &ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &ip);
 	ip &= ip_set_netmask(h->netmask);
 	if (ip == 0)
 		return -EINVAL;
 
-	return adtfn(set, &ip, h->timeout, flags);
+	return adtfn(set, &ip, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
@@ -283,18 +283,18 @@ nla_put_failure:
 
 static int
 hash_ip6_kadt(struct ip_set *set, const struct sk_buff *skb,
-	      enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	union nf_inet_addr ip;
 
-	ip6addrptr(skb, flags & IPSET_DIM_ONE_SRC, &ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &ip.in6);
 	ip6_netmask(&ip, h->netmask);
 	if (ipv6_addr_any(&ip.in6))
 		return -EINVAL;
 
-	return adtfn(set, &ip, h->timeout, flags);
+	return adtfn(set, &ip, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static const struct nla_policy hash_ip6_adt_policy[IPSET_ATTR_ADT_MAX + 1] = {
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 65c2ff4..9f179bb 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -126,19 +126,19 @@ nla_put_failure:
 
 static int
 hash_ipport4_kadt(struct ip_set *set, const struct sk_buff *skb,
-		  enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport4_elem data = { };
 
-	if (!ip_set_get_ip4_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
@@ -330,19 +330,19 @@ nla_put_failure:
 
 static int
 hash_ipport6_kadt(struct ip_set *set, const struct sk_buff *skb,
-		  enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipport6_elem data = { };
 
-	if (!ip_set_get_ip6_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 670e5e4..7cfa52b 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -129,20 +129,20 @@ nla_put_failure:
 
 static int
 hash_ipportip4_kadt(struct ip_set *set, const struct sk_buff *skb,
-		    enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip4_elem data = { };
 
-	if (!ip_set_get_ip4_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip);
-	ip4addrptr(skb, flags & IPSET_DIM_THREE_SRC, &data.ip2);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
@@ -343,20 +343,20 @@ nla_put_failure:
 
 static int
 hash_ipportip6_kadt(struct ip_set *set, const struct sk_buff *skb,
-		    enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
 	struct hash_ipportip6_elem data = { };
 
-	if (!ip_set_get_ip6_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6addrptr(skb, flags & IPSET_DIM_THREE_SRC, &data.ip2.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2.in6);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 4bb365c..104042a 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -142,7 +142,7 @@ nla_put_failure:
 
 static int
 hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
-		     enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		     enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
@@ -154,15 +154,15 @@ hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (adt == IPSET_TEST)
 		data.cidr = HOST_MASK;
 
-	if (!ip_set_get_ip4_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip);
-	ip4addrptr(skb, flags & IPSET_DIM_THREE_SRC, &data.ip2);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2);
 	data.ip2 &= ip_set_netmask(data.cidr);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
@@ -390,7 +390,7 @@ nla_put_failure:
 
 static int
 hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
-		     enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		     enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
@@ -402,15 +402,15 @@ hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (adt == IPSET_TEST)
 		data.cidr = HOST_MASK;
 
-	if (!ip_set_get_ip6_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
-	ip6addrptr(skb, flags & IPSET_DIM_THREE_SRC, &data.ip2.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_THREE_SRC, &data.ip2.in6);
 	ip6_netmask(&data.ip2, data.cidr);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 440b38f..0024053 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -127,7 +127,7 @@ nla_put_failure:
 
 static int
 hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
-	       enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
@@ -138,10 +138,10 @@ hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (adt == IPSET_TEST)
 		data.cidr = HOST_MASK;
 
-	ip4addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
 	data.ip &= ip_set_netmask(data.cidr);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
@@ -292,7 +292,7 @@ nla_put_failure:
 
 static int
 hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
-	       enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
@@ -303,10 +303,10 @@ hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (adt == IPSET_TEST)
 		data.cidr = HOST_MASK;
 
-	ip6addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
 	ip6_netmask(&data.ip, data.cidr);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 2d31291..7a2327b 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -139,7 +139,7 @@ nla_put_failure:
 
 static int
 hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
-		   enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		   enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
@@ -151,14 +151,14 @@ hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (adt == IPSET_TEST)
 		data.cidr = HOST_MASK;
 
-	if (!ip_set_get_ip4_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip4_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip4addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip);
+	ip4addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip);
 	data.ip &= ip_set_netmask(data.cidr);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
@@ -352,7 +352,7 @@ nla_put_failure:
 
 static int
 hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
-		   enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+		   enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
 	ipset_adtfn adtfn = set->variant->adt[adt];
@@ -364,14 +364,14 @@ hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
 	if (adt == IPSET_TEST)
 		data.cidr = HOST_MASK;
 
-	if (!ip_set_get_ip6_port(skb, flags & IPSET_DIM_TWO_SRC,
+	if (!ip_set_get_ip6_port(skb, opt->flags & IPSET_DIM_TWO_SRC,
 				 &data.port, &data.proto))
 		return -EINVAL;
 
-	ip6addrptr(skb, flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
+	ip6addrptr(skb, opt->flags & IPSET_DIM_ONE_SRC, &data.ip.in6);
 	ip6_netmask(&data.ip, data.cidr);
 
-	return adtfn(set, &data, h->timeout, flags);
+	return adtfn(set, &data, opt_timeout(opt, h), opt->cmdflags);
 }
 
 static int
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index c2c29da..f05e9eb 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -72,7 +72,7 @@ list_set_expired(const struct list_set *map, u32 id)
 
 static int
 list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
-	      enum ipset_adt adt, u8 pf, u8 dim, u8 flags)
+	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct list_set *map = set->data;
 	struct set_elem *elem;
@@ -87,17 +87,17 @@ list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
 			continue;
 		switch (adt) {
 		case IPSET_TEST:
-			ret = ip_set_test(elem->id, skb, pf, dim, flags);
+			ret = ip_set_test(elem->id, skb, opt);
 			if (ret > 0)
 				return ret;
 			break;
 		case IPSET_ADD:
-			ret = ip_set_add(elem->id, skb, pf, dim, flags);
+			ret = ip_set_add(elem->id, skb, opt);
 			if (ret == 0)
 				return ret;
 			break;
 		case IPSET_DEL:
-			ret = ip_set_del(elem->id, skb, pf, dim, flags);
+			ret = ip_set_del(elem->id, skb, opt);
 			if (ret == 0)
 				return ret;
 			break;
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index b3babae..eb265bd 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -29,23 +29,32 @@ MODULE_ALIAS("ip6t_SET");
 
 static inline int
 match_set(ip_set_id_t index, const struct sk_buff *skb,
-	  u8 pf, u8 dim, u8 flags, int inv)
+	  const struct ip_set_adt_opt *opt, int inv)
 {
-	if (ip_set_test(index, skb, pf, dim, flags))
+	if (ip_set_test(index, skb, opt))
 		inv = !inv;
 	return inv;
 }
 
+#define ADT_OPT(n, f, d, fs, cfs, t) 	\
+const struct ip_set_adt_opt n = {	\
+	.family	= f,			\
+	.dim = d,			\
+	.flags = fs,			\
+	.cmdflags = cfs,		\
+	.timeout = t,			\
+}
+
 /* Revision 0 interface: backward compatible with netfilter/iptables */
 
 static bool
 set_match_v0(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_set_info_match_v0 *info = par->matchinfo;
+	ADT_OPT(opt, par->family, info->match_set.u.compat.dim,
+		info->match_set.u.compat.flags, 0, UINT_MAX);
 
-	return match_set(info->match_set.index, skb, par->family,
-			 info->match_set.u.compat.dim,
-			 info->match_set.u.compat.flags,
+	return match_set(info->match_set.index, skb, &opt,
 			 info->match_set.u.compat.flags & IPSET_INV_MATCH);
 }
 
@@ -103,15 +112,15 @@ static unsigned int
 set_target_v0(struct sk_buff *skb, const struct xt_action_param *par)
 {
 	const struct xt_set_info_target_v0 *info = par->targinfo;
+	ADT_OPT(add_opt, par->family, info->add_set.u.compat.dim,
+		info->add_set.u.compat.flags, 0, UINT_MAX);
+	ADT_OPT(del_opt, par->family, info->del_set.u.compat.dim,
+		info->del_set.u.compat.flags, 0, UINT_MAX);
 
 	if (info->add_set.index != IPSET_INVALID_ID)
-		ip_set_add(info->add_set.index, skb, par->family,
-			   info->add_set.u.compat.dim,
-			   info->add_set.u.compat.flags);
+		ip_set_add(info->add_set.index, skb, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-		ip_set_del(info->del_set.index, skb, par->family,
-			   info->del_set.u.compat.dim,
-			   info->del_set.u.compat.flags);
+		ip_set_del(info->del_set.index, skb, &del_opt);
 
 	return XT_CONTINUE;
 }
@@ -170,23 +179,23 @@ set_target_v0_destroy(const struct xt_tgdtor_param *par)
 		ip_set_nfnl_put(info->del_set.index);
 }
 
-/* Revision 1: current interface to netfilter/iptables */
+/* Revision 1 match and target */
 
 static bool
-set_match(const struct sk_buff *skb, struct xt_action_param *par)
+set_match_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
-	const struct xt_set_info_match *info = par->matchinfo;
+	const struct xt_set_info_match_v1 *info = par->matchinfo;
+	ADT_OPT(opt, par->family, info->match_set.dim,
+		info->match_set.flags, 0, UINT_MAX);
 
-	return match_set(info->match_set.index, skb, par->family,
-			 info->match_set.dim,
-			 info->match_set.flags,
+	return match_set(info->match_set.index, skb, &opt,
 			 info->match_set.flags & IPSET_INV_MATCH);
 }
 
 static int
-set_match_checkentry(const struct xt_mtchk_param *par)
+set_match_v1_checkentry(const struct xt_mtchk_param *par)
 {
-	struct xt_set_info_match *info = par->matchinfo;
+	struct xt_set_info_match_v1 *info = par->matchinfo;
 	ip_set_id_t index;
 
 	index = ip_set_nfnl_get_byindex(info->match_set.index);
@@ -207,36 +216,34 @@ set_match_checkentry(const struct xt_mtchk_param *par)
 }
 
 static void
-set_match_destroy(const struct xt_mtdtor_param *par)
+set_match_v1_destroy(const struct xt_mtdtor_param *par)
 {
-	struct xt_set_info_match *info = par->matchinfo;
+	struct xt_set_info_match_v1 *info = par->matchinfo;
 
 	ip_set_nfnl_put(info->match_set.index);
 }
 
 static unsigned int
-set_target(struct sk_buff *skb, const struct xt_action_param *par)
+set_target_v1(struct sk_buff *skb, const struct xt_action_param *par)
 {
-	const struct xt_set_info_target *info = par->targinfo;
+	const struct xt_set_info_target_v1 *info = par->targinfo;
+	ADT_OPT(add_opt, par->family, info->add_set.dim,
+		info->add_set.flags, 0, UINT_MAX);
+	ADT_OPT(del_opt, par->family, info->del_set.dim,
+		info->del_set.flags, 0, UINT_MAX);
 
 	if (info->add_set.index != IPSET_INVALID_ID)
-		ip_set_add(info->add_set.index,
-			   skb, par->family,
-			   info->add_set.dim,
-			   info->add_set.flags);
+		ip_set_add(info->add_set.index, skb, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-		ip_set_del(info->del_set.index,
-			   skb, par->family,
-			   info->del_set.dim,
-			   info->del_set.flags);
+		ip_set_del(info->del_set.index, skb, &del_opt);
 
 	return XT_CONTINUE;
 }
 
 static int
-set_target_checkentry(const struct xt_tgchk_param *par)
+set_target_v1_checkentry(const struct xt_tgchk_param *par)
 {
-	const struct xt_set_info_target *info = par->targinfo;
+	const struct xt_set_info_target_v1 *info = par->targinfo;
 	ip_set_id_t index;
 
 	if (info->add_set.index != IPSET_INVALID_ID) {
@@ -273,9 +280,9 @@ set_target_checkentry(const struct xt_tgchk_param *par)
 }
 
 static void
-set_target_destroy(const struct xt_tgdtor_param *par)
+set_target_v1_destroy(const struct xt_tgdtor_param *par)
 {
-	const struct xt_set_info_target *info = par->targinfo;
+	const struct xt_set_info_target_v1 *info = par->targinfo;
 
 	if (info->add_set.index != IPSET_INVALID_ID)
 		ip_set_nfnl_put(info->add_set.index);
@@ -283,6 +290,28 @@ set_target_destroy(const struct xt_tgdtor_param *par)
 		ip_set_nfnl_put(info->del_set.index);
 }
 
+/* Revision 2 target */
+
+static unsigned int
+set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_set_info_target_v2 *info = par->targinfo;
+	ADT_OPT(add_opt, par->family, info->add_set.dim,
+		info->add_set.flags, info->flags, info->timeout);
+	ADT_OPT(del_opt, par->family, info->del_set.dim,
+		info->del_set.flags, 0, UINT_MAX);
+
+	if (info->add_set.index != IPSET_INVALID_ID)
+		ip_set_add(info->add_set.index, skb, &add_opt);
+	if (info->del_set.index != IPSET_INVALID_ID)
+		ip_set_del(info->del_set.index, skb, &del_opt);
+
+	return XT_CONTINUE;
+}
+
+#define set_target_v2_checkentry	set_target_v1_checkentry
+#define set_target_v2_destroy		set_target_v1_destroy
+
 static struct xt_match set_matches[] __read_mostly = {
 	{
 		.name		= "set",
@@ -298,20 +327,20 @@ static struct xt_match set_matches[] __read_mostly = {
 		.name		= "set",
 		.family		= NFPROTO_IPV4,
 		.revision	= 1,
-		.match		= set_match,
-		.matchsize	= sizeof(struct xt_set_info_match),
-		.checkentry	= set_match_checkentry,
-		.destroy	= set_match_destroy,
+		.match		= set_match_v1,
+		.matchsize	= sizeof(struct xt_set_info_match_v1),
+		.checkentry	= set_match_v1_checkentry,
+		.destroy	= set_match_v1_destroy,
 		.me		= THIS_MODULE
 	},
 	{
 		.name		= "set",
 		.family		= NFPROTO_IPV6,
 		.revision	= 1,
-		.match		= set_match,
-		.matchsize	= sizeof(struct xt_set_info_match),
-		.checkentry	= set_match_checkentry,
-		.destroy	= set_match_destroy,
+		.match		= set_match_v1,
+		.matchsize	= sizeof(struct xt_set_info_match_v1),
+		.checkentry	= set_match_v1_checkentry,
+		.destroy	= set_match_v1_destroy,
 		.me		= THIS_MODULE
 	},
 };
@@ -331,20 +360,40 @@ static struct xt_target set_targets[] __read_mostly = {
 		.name		= "SET",
 		.revision	= 1,
 		.family		= NFPROTO_IPV4,
-		.target		= set_target,
-		.targetsize	= sizeof(struct xt_set_info_target),
-		.checkentry	= set_target_checkentry,
-		.destroy	= set_target_destroy,
+		.target		= set_target_v1,
+		.targetsize	= sizeof(struct xt_set_info_target_v1),
+		.checkentry	= set_target_v1_checkentry,
+		.destroy	= set_target_v1_destroy,
 		.me		= THIS_MODULE
 	},
 	{
 		.name		= "SET",
 		.revision	= 1,
 		.family		= NFPROTO_IPV6,
-		.target		= set_target,
-		.targetsize	= sizeof(struct xt_set_info_target),
-		.checkentry	= set_target_checkentry,
-		.destroy	= set_target_destroy,
+		.target		= set_target_v1,
+		.targetsize	= sizeof(struct xt_set_info_target_v1),
+		.checkentry	= set_target_v1_checkentry,
+		.destroy	= set_target_v1_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "SET",
+		.revision	= 2,
+		.family		= NFPROTO_IPV4,
+		.target		= set_target_v2,
+		.targetsize	= sizeof(struct xt_set_info_target_v2),
+		.checkentry	= set_target_v2_checkentry,
+		.destroy	= set_target_v2_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "SET",
+		.revision	= 2,
+		.family		= NFPROTO_IPV6,
+		.target		= set_target_v2,
+		.targetsize	= sizeof(struct xt_set_info_target_v2),
+		.checkentry	= set_target_v2_checkentry,
+		.destroy	= set_target_v2_destroy,
 		.me		= THIS_MODULE
 	},
 };
-- 
1.7.2.3

