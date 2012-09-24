From: pablo@netfilter.org
Subject: [PATCH 12/16] netfilter: ipset: Support to match elements marked with "nomatch"
Date: Mon, 24 Sep 2012 21:19:24 +0200
Message-ID: <1348514369-3272-13-git-send-email-pablo@netfilter.org>
References: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58145 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932114Ab2IXTVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 15:21:10 -0400
In-Reply-To: <1348514369-3272-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Exceptions can now be matched and we can branch according to the
possible cases:

a. match in the set if the element is not flagged as "nomatch"
b. match in the set if the element is flagged with "nomatch"
c. no match

i.e.

iptables ... -m set --match-set ... -j ...
iptables ... -m set --match-set ... --nomatch-entries -j ...
...

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h      |    4 ++++
 net/netfilter/ipset/ip_set_core.c           |    6 ++++++
 net/netfilter/ipset/ip_set_hash_ipportnet.c |   11 ++++++-----
 net/netfilter/ipset/ip_set_hash_net.c       |   10 +++++-----
 net/netfilter/ipset/ip_set_hash_netiface.c  |   11 ++++++-----
 net/netfilter/ipset/ip_set_hash_netport.c   |   10 +++++-----
 net/netfilter/xt_set.c                      |   22 ++++++++++++++++++++++
 7 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 0c1e97b..528697b 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -190,6 +190,7 @@ enum ip_set_dim {
 	 * If changed, new revision of iptables match/target is required.
 	 */
 	IPSET_DIM_MAX = 6,
+	IPSET_BIT_RETURN_NOMATCH = 7,
 };
 
 /* Option flags for kernel operations */
@@ -198,6 +199,7 @@ enum ip_set_kopt {
 	IPSET_DIM_ONE_SRC = (1 << IPSET_DIM_ONE),
 	IPSET_DIM_TWO_SRC = (1 << IPSET_DIM_TWO),
 	IPSET_DIM_THREE_SRC = (1 << IPSET_DIM_THREE),
+	IPSET_RETURN_NOMATCH = (1 << IPSET_BIT_RETURN_NOMATCH),
 };
 
 #ifdef __KERNEL__
@@ -229,6 +231,8 @@ enum ip_set_feature {
 	IPSET_TYPE_NAME = (1 << IPSET_TYPE_NAME_FLAG),
 	IPSET_TYPE_IFACE_FLAG = 5,
 	IPSET_TYPE_IFACE = (1 << IPSET_TYPE_IFACE_FLAG),
+	IPSET_TYPE_NOMATCH_FLAG = 6,
+	IPSET_TYPE_NOMATCH = (1 << IPSET_TYPE_NOMATCH_FLAG),
 	/* Strictly speaking not a feature, but a flag for dumping:
 	 * this settype must be dumped last */
 	IPSET_DUMP_LAST_FLAG = 7,
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 72e9bf0..778465f 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -370,6 +370,12 @@ ip_set_test(ip_set_id_t index, const struct sk_buff *skb,
 		set->variant->kadt(set, skb, par, IPSET_ADD, opt);
 		write_unlock_bh(&set->lock);
 		ret = 1;
+	} else {
+		/* --return-nomatch: invert matched element */
+		if ((opt->flags & IPSET_RETURN_NOMATCH) &&
+		    (set->type->features & IPSET_TYPE_NOMATCH) &&
+		    (ret > 0 || ret == -ENOTEMPTY))
+			ret = -ret;
 	}
 
 	/* Convert error codes to nomatch */
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 8ee9168..cb71f9a 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -104,10 +104,10 @@ hash_ipportnet4_data_flags(struct hash_ipportnet4_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
-static inline bool
+static inline int
 hash_ipportnet4_data_match(const struct hash_ipportnet4_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -411,10 +411,10 @@ hash_ipportnet6_data_flags(struct hash_ipportnet6_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
-static inline bool
+static inline int
 hash_ipportnet6_data_match(const struct hash_ipportnet6_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -697,7 +697,8 @@ hash_ipportnet_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.name		= "hash:ip,port,net",
 	.protocol	= IPSET_PROTOCOL,
-	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
+	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2 |
+			  IPSET_TYPE_NOMATCH,
 	.dimension	= IPSET_DIM_THREE,
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= REVISION_MIN,
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 014ff72..29e94b9 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -90,10 +90,10 @@ hash_net4_data_flags(struct hash_net4_elem *dst, u32 flags)
 	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
 }
 
-static inline bool
+static inline int
 hash_net4_data_match(const struct hash_net4_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -311,10 +311,10 @@ hash_net6_data_flags(struct hash_net6_elem *dst, u32 flags)
 	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
 }
 
-static inline bool
+static inline int
 hash_net6_data_match(const struct hash_net6_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -536,7 +536,7 @@ hash_net_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 static struct ip_set_type hash_net_type __read_mostly = {
 	.name		= "hash:net",
 	.protocol	= IPSET_PROTOCOL,
-	.features	= IPSET_TYPE_IP,
+	.features	= IPSET_TYPE_IP | IPSET_TYPE_NOMATCH,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= REVISION_MIN,
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index a5c8491..b9a6338 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -201,10 +201,10 @@ hash_netiface4_data_flags(struct hash_netiface4_elem *dst, u32 flags)
 	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
 }
 
-static inline bool
+static inline int
 hash_netiface4_data_match(const struct hash_netiface4_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -497,10 +497,10 @@ hash_netiface6_data_flags(struct hash_netiface6_elem *dst, u32 flags)
 	dst->nomatch = flags & IPSET_FLAG_NOMATCH;
 }
 
-static inline bool
+static inline int
 hash_netiface6_data_match(const struct hash_netiface6_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -774,7 +774,8 @@ hash_netiface_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 static struct ip_set_type hash_netiface_type __read_mostly = {
 	.name		= "hash:net,iface",
 	.protocol	= IPSET_PROTOCOL,
-	.features	= IPSET_TYPE_IP | IPSET_TYPE_IFACE,
+	.features	= IPSET_TYPE_IP | IPSET_TYPE_IFACE |
+			  IPSET_TYPE_NOMATCH,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= REVISION_MIN,
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 7ca357a..7ef700d 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -104,10 +104,10 @@ hash_netport4_data_flags(struct hash_netport4_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
-static inline bool
+static inline int
 hash_netport4_data_match(const struct hash_netport4_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -375,10 +375,10 @@ hash_netport6_data_flags(struct hash_netport6_elem *dst, u32 flags)
 	dst->nomatch = !!(flags & IPSET_FLAG_NOMATCH);
 }
 
-static inline bool
+static inline int
 hash_netport6_data_match(const struct hash_netport6_elem *elem)
 {
-	return !elem->nomatch;
+	return elem->nomatch ? -ENOTEMPTY : 1;
 }
 
 static inline void
@@ -650,7 +650,7 @@ hash_netport_create(struct ip_set *set, struct nlattr *tb[], u32 flags)
 static struct ip_set_type hash_netport_type __read_mostly = {
 	.name		= "hash:net,port",
 	.protocol	= IPSET_PROTOCOL,
-	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
+	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_NOMATCH,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= NFPROTO_UNSPEC,
 	.revision_min	= REVISION_MIN,
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index c6f7db7..865a9e5 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -356,6 +356,27 @@ static struct xt_match set_matches[] __read_mostly = {
 		.destroy	= set_match_v1_destroy,
 		.me		= THIS_MODULE
 	},
+	/* --return-nomatch flag support */
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV4,
+		.revision	= 2,
+		.match		= set_match_v1,
+		.matchsize	= sizeof(struct xt_set_info_match_v1),
+		.checkentry	= set_match_v1_checkentry,
+		.destroy	= set_match_v1_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV6,
+		.revision	= 2,
+		.match		= set_match_v1,
+		.matchsize	= sizeof(struct xt_set_info_match_v1),
+		.checkentry	= set_match_v1_checkentry,
+		.destroy	= set_match_v1_destroy,
+		.me		= THIS_MODULE
+	},
 };
 
 static struct xt_target set_targets[] __read_mostly = {
@@ -389,6 +410,7 @@ static struct xt_target set_targets[] __read_mostly = {
 		.destroy	= set_target_v1_destroy,
 		.me		= THIS_MODULE
 	},
+	/* --timeout and --exist flags support */
 	{
 		.name		= "SET",
 		.revision	= 2,
-- 
1.7.10.4
