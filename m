From: kaber@trash.net
Subject: [PATCH 16/20] netfilter: ipset: add xt_action_param to the variant level kadt functions, ipset API change
Date: Thu, 16 Jun 2011 21:47:16 +0200
Message-ID: <1308253640-29942-17-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

With the change the sets can use any parameter available for the match
and target extensions, like input/output interface. It's required for
the hash:net,iface set type.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set.h       |    5 +++++
 include/linux/netfilter/ipset/ip_set_ahash.h |    1 +
 net/netfilter/ipset/ip_set_bitmap_ip.c       |    1 +
 net/netfilter/ipset/ip_set_bitmap_ipmac.c    |    1 +
 net/netfilter/ipset/ip_set_bitmap_port.c     |    1 +
 net/netfilter/ipset/ip_set_core.c            |   12 ++++++++----
 net/netfilter/ipset/ip_set_hash_ip.c         |    2 ++
 net/netfilter/ipset/ip_set_hash_ipport.c     |    2 ++
 net/netfilter/ipset/ip_set_hash_ipportip.c   |    2 ++
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |    2 ++
 net/netfilter/ipset/ip_set_hash_net.c        |    2 ++
 net/netfilter/ipset/ip_set_hash_netport.c    |    2 ++
 net/netfilter/ipset/ip_set_list_set.c        |    7 ++++---
 net/netfilter/xt_set.c                       |   19 ++++++++++---------
 14 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index fd83f4f..8955165 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -170,6 +170,7 @@ enum ipset_adt {
 #include <linux/ipv6.h>
 #include <linux/netlink.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
 #include <linux/vmalloc.h>
 #include <net/netlink.h>
 
@@ -238,6 +239,7 @@ struct ip_set_type_variant {
 	 *			zero for no match/success to add/delete
 	 *			positive for matching element */
 	int (*kadt)(struct ip_set *set, const struct sk_buff * skb,
+		    const struct xt_action_param *par,
 		    enum ipset_adt adt, const struct ip_set_adt_opt *opt);
 
 	/* Userspace: test/add/del entries
@@ -332,10 +334,13 @@ extern void ip_set_nfnl_put(ip_set_id_t index);
 /* API for iptables set match, and SET target */
 
 extern int ip_set_add(ip_set_id_t id, const struct sk_buff *skb,
+		      const struct xt_action_param *par,
 		      const struct ip_set_adt_opt *opt);
 extern int ip_set_del(ip_set_id_t id, const struct sk_buff *skb,
+		      const struct xt_action_param *par,
 		      const struct ip_set_adt_opt *opt);
 extern int ip_set_test(ip_set_id_t id, const struct sk_buff *skb,
+		       const struct xt_action_param *par,
 		       const struct ip_set_adt_opt *opt);
 
 /* Utility functions */
diff --git a/include/linux/netfilter/ipset/ip_set_ahash.h b/include/linux/netfilter/ipset/ip_set_ahash.h
index a099d40..1c977e1 100644
--- a/include/linux/netfilter/ipset/ip_set_ahash.h
+++ b/include/linux/netfilter/ipset/ip_set_ahash.h
@@ -599,6 +599,7 @@ nla_put_failure:
 
 static int
 type_pf_kadt(struct ip_set *set, const struct sk_buff * skb,
+	     const struct xt_action_param *par,
 	     enum ipset_adt adt, const struct ip_set_adt_opt *opt);
 static int
 type_pf_uadt(struct ip_set *set, struct nlattr *tb[],
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index c46e344..e3e7399 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -219,6 +219,7 @@ nla_put_failure:
 
 static int
 bitmap_ip_kadt(struct ip_set *set, const struct sk_buff *skb,
+	       const struct xt_action_param *par,
 	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct bitmap_ip *map = set->data;
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index aa2cfa1..51ab664 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -338,6 +338,7 @@ nla_put_failure:
 
 static int
 bitmap_ipmac_kadt(struct ip_set *set, const struct sk_buff *skb,
+		  const struct xt_action_param *par,
 		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct bitmap_ipmac *map = set->data;
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index c3e906f..29ba93b 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -208,6 +208,7 @@ nla_put_failure:
 
 static int
 bitmap_port_kadt(struct ip_set *set, const struct sk_buff *skb,
+		 const struct xt_action_param *par,
 		 enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct bitmap_port *map = set->data;
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 6a82cc0..64e7b04 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -21,6 +21,7 @@
 #include <net/netlink.h>
 
 #include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/ipset/ip_set.h>
 
@@ -328,6 +329,7 @@ __ip_set_put(ip_set_id_t index)
 
 int
 ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
+	    const struct xt_action_param *par,
 	    const struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_list[index];
@@ -341,14 +343,14 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 		return 0;
 
 	read_lock_bh(&set->lock);
-	ret = set->variant->kadt(set, skb, IPSET_TEST, opt);
+	ret = set->variant->kadt(set, skb, par, IPSET_TEST, opt);
 	read_unlock_bh(&set->lock);
 
 	if (ret == -EAGAIN) {
 		/* Type requests element to be completed */
 		pr_debug("element must be competed, ADD is triggered\n");
 		write_lock_bh(&set->lock);
-		set->variant->kadt(set, skb, IPSET_ADD, opt);
+		set->variant->kadt(set, skb, par, IPSET_ADD, opt);
 		write_unlock_bh(&set->lock);
 		ret = 1;
 	}
@@ -360,6 +362,7 @@ EXPORT_SYMBOL_GPL(ip_set_test);
 
 int
 ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
+	   const struct xt_action_param *par,
 	   const struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_list[index];
@@ -373,7 +376,7 @@ ip_set_add(ip_set_id_t index, const struct sk_buff *skb,
 		return 0;
 
 	write_lock_bh(&set->lock);
-	ret = set->variant->kadt(set, skb, IPSET_ADD, opt);
+	ret = set->variant->kadt(set, skb, par, IPSET_ADD, opt);
 	write_unlock_bh(&set->lock);
 
 	return ret;
@@ -382,6 +385,7 @@ EXPORT_SYMBOL_GPL(ip_set_add);
 
 int
 ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
+	   const struct xt_action_param *par,
 	   const struct ip_set_adt_opt *opt)
 {
 	struct ip_set *set = ip_set_list[index];
@@ -395,7 +399,7 @@ ip_set_del(ip_set_id_t index, const struct sk_buff *skb,
 		return 0;
 
 	write_lock_bh(&set->lock);
-	ret = set->variant->kadt(set, skb, IPSET_DEL, opt);
+	ret = set->variant->kadt(set, skb, par, IPSET_DEL, opt);
 	write_unlock_bh(&set->lock);
 
 	return ret;
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index bdb432e..fa80bb9 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -116,6 +116,7 @@ hash_ip4_data_next(struct ip_set_hash *h, const struct hash_ip4_elem *d)
 
 static int
 hash_ip4_kadt(struct ip_set *set, const struct sk_buff *skb,
+	      const struct xt_action_param *par,
 	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
@@ -295,6 +296,7 @@ hash_ip6_data_next(struct ip_set_hash *h, const struct hash_ip6_elem *d)
 
 static int
 hash_ip6_kadt(struct ip_set *set, const struct sk_buff *skb,
+	      const struct xt_action_param *par,
 	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index bdeb716..bbf51b6 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -134,6 +134,7 @@ hash_ipport4_data_next(struct ip_set_hash *h,
 
 static int
 hash_ipport4_kadt(struct ip_set *set, const struct sk_buff *skb,
+		  const struct xt_action_param *par,
 		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
@@ -348,6 +349,7 @@ hash_ipport6_data_next(struct ip_set_hash *h,
 
 static int
 hash_ipport6_kadt(struct ip_set *set, const struct sk_buff *skb,
+		  const struct xt_action_param *par,
 		  enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index fb986fc..96525f5 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -137,6 +137,7 @@ hash_ipportip4_data_next(struct ip_set_hash *h,
 
 static int
 hash_ipportip4_kadt(struct ip_set *set, const struct sk_buff *skb,
+		    const struct xt_action_param *par,
 		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
@@ -361,6 +362,7 @@ hash_ipportip6_data_next(struct ip_set_hash *h,
 
 static int
 hash_ipportip6_kadt(struct ip_set *set, const struct sk_buff *skb,
+		    const struct xt_action_param *par,
 		    enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 2ed5e75..dcd351b 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -151,6 +151,7 @@ hash_ipportnet4_data_next(struct ip_set_hash *h,
 
 static int
 hash_ipportnet4_kadt(struct ip_set *set, const struct sk_buff *skb,
+		     const struct xt_action_param *par,
 		     enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
@@ -428,6 +429,7 @@ hash_ipportnet6_data_next(struct ip_set_hash *h,
 
 static int
 hash_ipportnet6_kadt(struct ip_set *set, const struct sk_buff *skb,
+		     const struct xt_action_param *par,
 		     enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 8d3c3ef..dcbb5d4 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -134,6 +134,7 @@ hash_net4_data_next(struct ip_set_hash *h,
 
 static int
 hash_net4_kadt(struct ip_set *set, const struct sk_buff *skb,
+	       const struct xt_action_param *par,
 	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
@@ -330,6 +331,7 @@ hash_net6_data_next(struct ip_set_hash *h,
 
 static int
 hash_net6_kadt(struct ip_set *set, const struct sk_buff *skb,
+	       const struct xt_action_param *par,
 	       enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 90adc2c..72961ba 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -147,6 +147,7 @@ hash_netport4_data_next(struct ip_set_hash *h,
 
 static int
 hash_netport4_kadt(struct ip_set *set, const struct sk_buff *skb,
+		   const struct xt_action_param *par,
 		   enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
@@ -390,6 +391,7 @@ hash_netport6_data_next(struct ip_set_hash *h,
 
 static int
 hash_netport6_kadt(struct ip_set *set, const struct sk_buff *skb,
+		   const struct xt_action_param *par,
 		   enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	const struct ip_set_hash *h = set->data;
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 898fe68..4d10819 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -72,6 +72,7 @@ list_set_expired(const struct list_set *map, u32 id)
 
 static int
 list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
+	      const struct xt_action_param *par,
 	      enum ipset_adt adt, const struct ip_set_adt_opt *opt)
 {
 	struct list_set *map = set->data;
@@ -87,17 +88,17 @@ list_set_kadt(struct ip_set *set, const struct sk_buff *skb,
 			continue;
 		switch (adt) {
 		case IPSET_TEST:
-			ret = ip_set_test(elem->id, skb, opt);
+			ret = ip_set_test(elem->id, skb, par, opt);
 			if (ret > 0)
 				return ret;
 			break;
 		case IPSET_ADD:
-			ret = ip_set_add(elem->id, skb, opt);
+			ret = ip_set_add(elem->id, skb, par, opt);
 			if (ret == 0)
 				return ret;
 			break;
 		case IPSET_DEL:
-			ret = ip_set_del(elem->id, skb, opt);
+			ret = ip_set_del(elem->id, skb, par, opt);
 			if (ret == 0)
 				return ret;
 			break;
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index eb265bd..453847f 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -29,9 +29,10 @@ MODULE_ALIAS("ip6t_SET");
 
 static inline int
 match_set(ip_set_id_t index, const struct sk_buff *skb,
+	  const struct xt_action_param *par,
 	  const struct ip_set_adt_opt *opt, int inv)
 {
-	if (ip_set_test(index, skb, opt))
+	if (ip_set_test(index, skb, par, opt))
 		inv = !inv;
 	return inv;
 }
@@ -54,7 +55,7 @@ set_match_v0(const struct sk_buff *skb, struct xt_action_param *par)
 	ADT_OPT(opt, par->family, info->match_set.u.compat.dim,
 		info->match_set.u.compat.flags, 0, UINT_MAX);
 
-	return match_set(info->match_set.index, skb, &opt,
+	return match_set(info->match_set.index, skb, par, &opt,
 			 info->match_set.u.compat.flags & IPSET_INV_MATCH);
 }
 
@@ -118,9 +119,9 @@ set_target_v0(struct sk_buff *skb, const struct xt_action_param *par)
 		info->del_set.u.compat.flags, 0, UINT_MAX);
 
 	if (info->add_set.index != IPSET_INVALID_ID)
-		ip_set_add(info->add_set.index, skb, &add_opt);
+		ip_set_add(info->add_set.index, skb, par, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-		ip_set_del(info->del_set.index, skb, &del_opt);
+		ip_set_del(info->del_set.index, skb, par, &del_opt);
 
 	return XT_CONTINUE;
 }
@@ -188,7 +189,7 @@ set_match_v1(const struct sk_buff *skb, struct xt_action_param *par)
 	ADT_OPT(opt, par->family, info->match_set.dim,
 		info->match_set.flags, 0, UINT_MAX);
 
-	return match_set(info->match_set.index, skb, &opt,
+	return match_set(info->match_set.index, skb, par, &opt,
 			 info->match_set.flags & IPSET_INV_MATCH);
 }
 
@@ -233,9 +234,9 @@ set_target_v1(struct sk_buff *skb, const struct xt_action_param *par)
 		info->del_set.flags, 0, UINT_MAX);
 
 	if (info->add_set.index != IPSET_INVALID_ID)
-		ip_set_add(info->add_set.index, skb, &add_opt);
+		ip_set_add(info->add_set.index, skb, par, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-		ip_set_del(info->del_set.index, skb, &del_opt);
+		ip_set_del(info->del_set.index, skb, par, &del_opt);
 
 	return XT_CONTINUE;
 }
@@ -302,9 +303,9 @@ set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 		info->del_set.flags, 0, UINT_MAX);
 
 	if (info->add_set.index != IPSET_INVALID_ID)
-		ip_set_add(info->add_set.index, skb, &add_opt);
+		ip_set_add(info->add_set.index, skb, par, &add_opt);
 	if (info->del_set.index != IPSET_INVALID_ID)
-		ip_set_del(info->del_set.index, skb, &del_opt);
+		ip_set_del(info->del_set.index, skb, par, &del_opt);
 
 	return XT_CONTINUE;
 }
-- 
1.7.2.3

