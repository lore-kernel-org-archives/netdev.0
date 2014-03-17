From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 17/38] netfilter: ipset: add forceadd kernel support for hash set types
Date: Mon, 17 Mar 2014 13:42:37 +0100
Message-ID: <1395060178-11833-18-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:59415 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933131AbaCQMng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 08:43:36 -0400
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Hunt <johunt@akamai.com>

Adds a new property for hash set types, where if a set is created
with the 'forceadd' option and the set becomes full the next addition
to the set may succeed and evict a random entry from the set.

To keep overhead low eviction is done very simply. It checks to see
which bucket the new entry would be added. If the bucket's pos value
is non-zero (meaning there's at least one entry in the bucket) it
replaces the first entry in the bucket. If pos is zero, then it continues
down the normal add process.

This property is useful if you have a set for 'ban' lists where it may
not matter if you release some entries from the set early.

Signed-off-by: Josh Hunt <johunt@akamai.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/linux/netfilter/ipset/ip_set.h       |    3 +++
 include/uapi/linux/netfilter/ipset/ip_set.h  |    7 +++++--
 net/netfilter/ipset/ip_set_core.c            |    2 ++
 net/netfilter/ipset/ip_set_hash_gen.h        |   12 ++++++++++++
 net/netfilter/ipset/ip_set_hash_ip.c         |    3 ++-
 net/netfilter/ipset/ip_set_hash_ipmark.c     |    2 +-
 net/netfilter/ipset/ip_set_hash_ipport.c     |    3 ++-
 net/netfilter/ipset/ip_set_hash_ipportip.c   |    3 ++-
 net/netfilter/ipset/ip_set_hash_ipportnet.c  |    3 ++-
 net/netfilter/ipset/ip_set_hash_net.c        |    3 ++-
 net/netfilter/ipset/ip_set_hash_netiface.c   |    3 ++-
 net/netfilter/ipset/ip_set_hash_netnet.c     |    2 +-
 net/netfilter/ipset/ip_set_hash_netport.c    |    3 ++-
 net/netfilter/ipset/ip_set_hash_netportnet.c |    3 ++-
 14 files changed, 40 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index f476bce..96afc29 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -65,6 +65,7 @@ enum ip_set_extension {
 #define SET_WITH_TIMEOUT(s)	((s)->extensions & IPSET_EXT_TIMEOUT)
 #define SET_WITH_COUNTER(s)	((s)->extensions & IPSET_EXT_COUNTER)
 #define SET_WITH_COMMENT(s)	((s)->extensions & IPSET_EXT_COMMENT)
+#define SET_WITH_FORCEADD(s)	((s)->flags & IPSET_CREATE_FLAG_FORCEADD)
 
 /* Extension id, in size order */
 enum ip_set_ext_id {
@@ -255,6 +256,8 @@ ip_set_put_flags(struct sk_buff *skb, struct ip_set *set)
 		cadt_flags |= IPSET_FLAG_WITH_COUNTERS;
 	if (SET_WITH_COMMENT(set))
 		cadt_flags |= IPSET_FLAG_WITH_COMMENT;
+	if (SET_WITH_FORCEADD(set))
+		cadt_flags |= IPSET_FLAG_WITH_FORCEADD;
 
 	if (!cadt_flags)
 		return 0;
diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index a1ca244..78c2f2e 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -185,13 +185,16 @@ enum ipset_cadt_flags {
 	IPSET_FLAG_WITH_COUNTERS = (1 << IPSET_FLAG_BIT_WITH_COUNTERS),
 	IPSET_FLAG_BIT_WITH_COMMENT = 4,
 	IPSET_FLAG_WITH_COMMENT = (1 << IPSET_FLAG_BIT_WITH_COMMENT),
+	IPSET_FLAG_BIT_WITH_FORCEADD = 5,
+	IPSET_FLAG_WITH_FORCEADD = (1 << IPSET_FLAG_BIT_WITH_FORCEADD),
 	IPSET_FLAG_CADT_MAX	= 15,
 };
 
 /* The flag bits which correspond to the non-extension create flags */
 enum ipset_create_flags {
-	IPSET_CREATE_FLAG_NONE = 0,
-	IPSET_CREATE_FLAG_MAX = 7,
+	IPSET_CREATE_FLAG_BIT_FORCEADD = 0,
+	IPSET_CREATE_FLAG_FORCEADD = (1 << IPSET_CREATE_FLAG_BIT_FORCEADD),
+	IPSET_CREATE_FLAG_BIT_MAX = 7,
 };
 
 /* Commands with settype-specific attributes */
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 636cb8d..1172083 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -368,6 +368,8 @@ ip_set_elem_len(struct ip_set *set, struct nlattr *tb[], size_t len)
 
 	if (tb[IPSET_ATTR_CADT_FLAGS])
 		cadt_flags = ip_set_get_h32(tb[IPSET_ATTR_CADT_FLAGS]);
+	if (cadt_flags & IPSET_FLAG_WITH_FORCEADD)
+		set->flags |= IPSET_CREATE_FLAG_FORCEADD;
 	for (id = 0; id < IPSET_EXT_ID_MAX; id++) {
 		if (!add_extension(id, cadt_flags, tb))
 			continue;
diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index b1eed81..61c7fb0 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -633,6 +633,18 @@ mtype_add(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	bool flag_exist = flags & IPSET_FLAG_EXIST;
 	u32 key, multi = 0;
 
+	if (h->elements >= h->maxelem && SET_WITH_FORCEADD(set)) {
+		rcu_read_lock_bh();
+		t = rcu_dereference_bh(h->table);
+		key = HKEY(value, h->initval, t->htable_bits);
+		n = hbucket(t,key);
+		if (n->pos) {
+			/* Choosing the first entry in the array to replace */
+			j = 0;
+			goto reuse_slot;
+		}
+		rcu_read_unlock_bh();
+	}
 	if (SET_WITH_TIMEOUT(set) && h->elements >= h->maxelem)
 		/* FIXME: when set is full, we slow down here */
 		mtype_expire(set, h, NLEN(set->family), set->dsize);
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index e65fc24..dd40607 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -25,7 +25,8 @@
 
 #define IPSET_TYPE_REV_MIN	0
 /*				1	   Counters support */
-#define IPSET_TYPE_REV_MAX	2	/* Comments support */
+/*				2	   Comments support */
+#define IPSET_TYPE_REV_MAX	3	/* Forceadd support */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
diff --git a/net/netfilter/ipset/ip_set_hash_ipmark.c b/net/netfilter/ipset/ip_set_hash_ipmark.c
index 1bf8e85..4eff0a2 100644
--- a/net/netfilter/ipset/ip_set_hash_ipmark.c
+++ b/net/netfilter/ipset/ip_set_hash_ipmark.c
@@ -25,7 +25,7 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	0
+#define IPSET_TYPE_REV_MAX	1	/* Forceadd support */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Vytas Dauksa <vytas.dauksa@smoothwall.net>");
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index 525a595..7597b82 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -27,7 +27,8 @@
 #define IPSET_TYPE_REV_MIN	0
 /*				1    SCTP and UDPLITE support added */
 /*				2    Counters support added */
-#define IPSET_TYPE_REV_MAX	3 /* Comments support added */
+/*				3    Comments support added */
+#define IPSET_TYPE_REV_MAX	4 /* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index f563663..672655f 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -27,7 +27,8 @@
 #define IPSET_TYPE_REV_MIN	0
 /*				1    SCTP and UDPLITE support added */
 /*				2    Counters support added */
-#define IPSET_TYPE_REV_MAX	3 /* Comments support added */
+/*				3    Comments support added */
+#define IPSET_TYPE_REV_MAX	4 /* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 5d87fe8..7308d84 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -29,7 +29,8 @@
 /*				2    Range as input support for IPv4 added */
 /*				3    nomatch flag support added */
 /*				4    Counters support added */
-#define IPSET_TYPE_REV_MAX	5 /* Comments support added */
+/*				5    Comments support added */
+#define IPSET_TYPE_REV_MAX	6 /* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index 8295cf4..4c7d495 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -26,7 +26,8 @@
 /*				1    Range as input support for IPv4 added */
 /*				2    nomatch flag support added */
 /*				3    Counters support added */
-#define IPSET_TYPE_REV_MAX	4 /* Comments support added */
+/*				4    Comments support added */
+#define IPSET_TYPE_REV_MAX	5 /* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
diff --git a/net/netfilter/ipset/ip_set_hash_netiface.c b/net/netfilter/ipset/ip_set_hash_netiface.c
index b827a0f..db26068 100644
--- a/net/netfilter/ipset/ip_set_hash_netiface.c
+++ b/net/netfilter/ipset/ip_set_hash_netiface.c
@@ -27,7 +27,8 @@
 /*				1    nomatch flag support added */
 /*				2    /0 support added */
 /*				3    Counters support added */
-#define IPSET_TYPE_REV_MAX	4 /* Comments support added */
+/*				4    Comments support added */
+#define IPSET_TYPE_REV_MAX	5 /* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index 4e7261d..3e99987 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -24,7 +24,7 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	0
+#define IPSET_TYPE_REV_MAX	1	/* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>");
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 7097fb0..1c645fb 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -28,7 +28,8 @@
 /*				2    Range as input support for IPv4 added */
 /*				3    nomatch flag support added */
 /*				4    Counters support added */
-#define IPSET_TYPE_REV_MAX	5 /* Comments support added */
+/*				5    Comments support added */
+#define IPSET_TYPE_REV_MAX	6 /* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>");
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index 703d119..c0d2ba7 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -25,7 +25,8 @@
 #include <linux/netfilter/ipset/ip_set_hash.h>
 
 #define IPSET_TYPE_REV_MIN	0
-#define IPSET_TYPE_REV_MAX	0 /* Comments support added */
+/*				0    Comments support added */
+#define IPSET_TYPE_REV_MAX	1 /* Forceadd support added */
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Oliver Smith <oliver@8.c.9.b.0.7.4.0.1.0.0.2.ip6.arpa>");
-- 
1.7.10.4
