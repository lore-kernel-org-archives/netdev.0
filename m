From: kaber@trash.net
Subject: [PATCH 11/20] netfilter: ipset: set type support with multiple revisions added
Date: Thu, 16 Jun 2011 21:47:11 +0200
Message-ID: <1308253640-29942-12-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

A set type may have multiple revisions, for example when syntax is
extended. Support continuous revision ranges in set types.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set.h      |    6 ++-
 net/netfilter/ipset/ip_set_bitmap_ip.c      |    3 +-
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |    3 +-
 net/netfilter/ipset/ip_set_bitmap_port.c    |    3 +-
 net/netfilter/ipset/ip_set_core.c           |   45 +++++++++++++++------------
 net/netfilter/ipset/ip_set_hash_ip.c        |    3 +-
 net/netfilter/ipset/ip_set_hash_ipport.c    |    3 +-
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    3 +-
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    3 +-
 net/netfilter/ipset/ip_set_hash_net.c       |    3 +-
 net/netfilter/ipset/ip_set_hash_netport.c   |    3 +-
 net/netfilter/ipset/ip_set_list_set.c       |    3 +-
 12 files changed, 49 insertions(+), 32 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 710ba00..ac31e38 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -282,8 +282,8 @@ struct ip_set_type {
 	u8 dimension;
 	/* Supported family: may be AF_UNSPEC for both AF_INET/AF_INET6 */
 	u8 family;
-	/* Type revision */
-	u8 revision;
+	/* Type revisions */
+	u8 revision_min, revision_max;
 
 	/* Create set */
 	int (*create)(struct ip_set *set, struct nlattr *tb[], u32 flags);
@@ -314,6 +314,8 @@ struct ip_set {
 	const struct ip_set_type_variant *variant;
 	/* The actual INET family of the set */
 	u8 family;
+	/* The type revision */
+	u8 revision;
 	/* The type specific data */
 	void *data;
 };
diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 3a71c8e..3b5920b 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -551,7 +551,8 @@ static struct ip_set_type bitmap_ip_type __read_mostly = {
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= AF_INET,
-	.revision	= 0,
+	.revision_min	= 0,
+	.revision_max	= 0,
 	.create		= bitmap_ip_create,
 	.create_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index fdd5f79..5deb7bb 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -623,7 +623,8 @@ static struct ip_set_type bitmap_ipmac_type = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_MAC,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= AF_INET,
-	.revision	= 0,
+	.revision_min	= 0,
+	.revision_max	= 0,
 	.create		= bitmap_ipmac_create,
 	.create_policy	= {
 		[IPSET_ATTR_IP]		= { .type = NLA_NESTED },
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index a6a5b35..c3e906f 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -483,7 +483,8 @@ static struct ip_set_type bitmap_port_type = {
 	.features	= IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision_min	= 0,
+	.revision_max	= 0,
 	.create		= bitmap_port_create,
 	.create_policy	= {
 		[IPSET_ATTR_PORT]	= { .type = NLA_U16 },
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 528a9b3..6a82cc0 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -70,7 +70,8 @@ find_set_type(const char *name, u8 family, u8 revision)
 	list_for_each_entry_rcu(type, &ip_set_type_list, list)
 		if (STREQ(type->name, name) &&
 		    (type->family == family || type->family == AF_UNSPEC) &&
-		    type->revision == revision)
+		    revision >= type->revision_min &&
+		    revision <= type->revision_max)
 			return type;
 	return NULL;
 }
@@ -135,10 +136,10 @@ find_set_type_minmax(const char *name, u8 family, u8 *min, u8 *max)
 		if (STREQ(type->name, name) &&
 		    (type->family == family || type->family == AF_UNSPEC)) {
 			found = true;
-			if (type->revision < *min)
-				*min = type->revision;
-			if (type->revision > *max)
-				*max = type->revision;
+			if (type->revision_min < *min)
+				*min = type->revision_min;
+			if (type->revision_max > *max)
+				*max = type->revision_max;
 		}
 	rcu_read_unlock();
 	if (found)
@@ -159,25 +160,27 @@ ip_set_type_register(struct ip_set_type *type)
 	int ret = 0;
 
 	if (type->protocol != IPSET_PROTOCOL) {
-		pr_warning("ip_set type %s, family %s, revision %u uses "
+		pr_warning("ip_set type %s, family %s, revision %u:%u uses "
 			   "wrong protocol version %u (want %u)\n",
 			   type->name, family_name(type->family),
-			   type->revision, type->protocol, IPSET_PROTOCOL);
+			   type->revision_min, type->revision_max,
+			   type->protocol, IPSET_PROTOCOL);
 		return -EINVAL;
 	}
 
 	ip_set_type_lock();
-	if (find_set_type(type->name, type->family, type->revision)) {
+	if (find_set_type(type->name, type->family, type->revision_min)) {
 		/* Duplicate! */
-		pr_warning("ip_set type %s, family %s, revision %u "
+		pr_warning("ip_set type %s, family %s with revision min %u "
 			   "already registered!\n", type->name,
-			   family_name(type->family), type->revision);
+			   family_name(type->family), type->revision_min);
 		ret = -EINVAL;
 		goto unlock;
 	}
 	list_add_rcu(&type->list, &ip_set_type_list);
-	pr_debug("type %s, family %s, revision %u registered.\n",
-		 type->name, family_name(type->family), type->revision);
+	pr_debug("type %s, family %s, revision %u:%u registered.\n",
+		 type->name, family_name(type->family),
+		 type->revision_min, type->revision_max);
 unlock:
 	ip_set_type_unlock();
 	return ret;
@@ -189,15 +192,15 @@ void
 ip_set_type_unregister(struct ip_set_type *type)
 {
 	ip_set_type_lock();
-	if (!find_set_type(type->name, type->family, type->revision)) {
-		pr_warning("ip_set type %s, family %s, revision %u "
+	if (!find_set_type(type->name, type->family, type->revision_min)) {
+		pr_warning("ip_set type %s, family %s with revision min %u "
 			   "not registered\n", type->name,
-			   family_name(type->family), type->revision);
+			   family_name(type->family), type->revision_min);
 		goto unlock;
 	}
 	list_del_rcu(&type->list);
-	pr_debug("type %s, family %s, revision %u unregistered.\n",
-		 type->name, family_name(type->family), type->revision);
+	pr_debug("type %s, family %s with revision min %u unregistered.\n",
+		 type->name, family_name(type->family), type->revision_min);
 unlock:
 	ip_set_type_unlock();
 
@@ -656,6 +659,7 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 	rwlock_init(&set->lock);
 	strlcpy(set->name, name, IPSET_MAXNAMELEN);
 	set->family = family;
+	set->revision = revision;
 
 	/*
 	 * Next, check that we know the type, and take
@@ -696,7 +700,8 @@ ip_set_create(struct sock *ctnl, struct sk_buff *skb,
 		    (flags & IPSET_FLAG_EXIST) &&
 		    STREQ(set->type->name, clash->type->name) &&
 		    set->type->family == clash->type->family &&
-		    set->type->revision == clash->type->revision &&
+		    set->type->revision_min == clash->type->revision_min &&
+		    set->type->revision_max == clash->type->revision_max &&
 		    set->variant->same_set(set, clash))
 			ret = 0;
 		goto cleanup;
@@ -1080,7 +1085,7 @@ dump_last:
 			NLA_PUT_U8(skb, IPSET_ATTR_FAMILY,
 				   set->family);
 			NLA_PUT_U8(skb, IPSET_ATTR_REVISION,
-				   set->type->revision);
+				   set->revision);
 			ret = set->variant->head(set, skb);
 			if (ret < 0)
 				goto release_refcount;
@@ -1385,7 +1390,7 @@ ip_set_header(struct sock *ctnl, struct sk_buff *skb,
 	NLA_PUT_STRING(skb2, IPSET_ATTR_SETNAME, set->name);
 	NLA_PUT_STRING(skb2, IPSET_ATTR_TYPENAME, set->type->name);
 	NLA_PUT_U8(skb2, IPSET_ATTR_FAMILY, set->family);
-	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION, set->type->revision);
+	NLA_PUT_U8(skb2, IPSET_ATTR_REVISION, set->revision);
 	nlmsg_end(skb2, nlh2);
 
 	ret = netlink_unicast(ctnl, skb2, NETLINK_CB(skb).pid, MSG_DONTWAIT);
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index c99e861..c3bc06d 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -441,7 +441,8 @@ static struct ip_set_type hash_ip_type __read_mostly = {
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision_min	= 0,
+	.revision_max	= 0,
 	.create		= hash_ip_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index aa91b2c..de2e351 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -512,7 +512,8 @@ static struct ip_set_type hash_ipport_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= AF_UNSPEC,
-	.revision	= 1,
+	.revision_min	= 0,
+	.revision_max	= 1,	/* SCTP and UDPLITE support added */
 	.create		= hash_ipport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index b88e74e..031ed05 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -530,7 +530,8 @@ static struct ip_set_type hash_ipportip_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
 	.family		= AF_UNSPEC,
-	.revision	= 1,
+	.revision_min	= 0,
+	.revision_max	= 1,	/* SCTP and UDPLITE support added */
 	.create		= hash_ipportip_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 605ef3b..0b54fde 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -595,7 +595,8 @@ static struct ip_set_type hash_ipportnet_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT | IPSET_TYPE_IP2,
 	.dimension	= IPSET_DIM_THREE,
 	.family		= AF_UNSPEC,
-	.revision	= 1,
+	.revision_min	= 0,
+	.revision_max	= 1,	/* SCTP and UDPLITE support added */
 	.create		= hash_ipportnet_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index e6f8bc5..360cf5b 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -437,7 +437,8 @@ static struct ip_set_type hash_net_type __read_mostly = {
 	.features	= IPSET_TYPE_IP,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision_min	= 0,
+	.revision_max	= 0,
 	.create		= hash_net_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 037b829..09f807f 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -544,7 +544,8 @@ static struct ip_set_type hash_netport_type __read_mostly = {
 	.features	= IPSET_TYPE_IP | IPSET_TYPE_PORT,
 	.dimension	= IPSET_DIM_TWO,
 	.family		= AF_UNSPEC,
-	.revision	= 1,
+	.revision_min	= 0,
+	.revision_max	= 1,	/* SCTP and UDPLITE support added */
 	.create		= hash_netport_create,
 	.create_policy	= {
 		[IPSET_ATTR_HASHSIZE]	= { .type = NLA_U32 },
diff --git a/net/netfilter/ipset/ip_set_list_set.c b/net/netfilter/ipset/ip_set_list_set.c
index 74f0dcc..898fe68 100644
--- a/net/netfilter/ipset/ip_set_list_set.c
+++ b/net/netfilter/ipset/ip_set_list_set.c
@@ -575,7 +575,8 @@ static struct ip_set_type list_set_type __read_mostly = {
 	.features	= IPSET_TYPE_NAME | IPSET_DUMP_LAST,
 	.dimension	= IPSET_DIM_ONE,
 	.family		= AF_UNSPEC,
-	.revision	= 0,
+	.revision_min	= 0,
+	.revision_max	= 0,
 	.create		= list_set_create,
 	.create_policy	= {
 		[IPSET_ATTR_SIZE]	= { .type = NLA_U32 },
-- 
1.7.2.3

