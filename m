From: kaber@trash.net
Subject: [PATCH 09/20] netfilter: ipset: support listing setnames and headers too
Date: Thu, 16 Jun 2011 21:47:09 +0200
Message-ID: <1308253640-29942-10-git-send-email-kaber@trash.net>
References: <1308253640-29942-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308253640-29942-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Current listing makes possible to list sets with full content only.
The patch adds support partial listings, i.e. listing just
the existing setnames or listing set headers, without set members.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/ipset/ip_set.h |    4 ++
 net/netfilter/ipset/ip_set_core.c      |   73 ++++++++++++++++++++------------
 2 files changed, 50 insertions(+), 27 deletions(-)

diff --git a/include/linux/netfilter/ipset/ip_set.h b/include/linux/netfilter/ipset/ip_set.h
index 68b21f5..e677c4d 100644
--- a/include/linux/netfilter/ipset/ip_set.h
+++ b/include/linux/netfilter/ipset/ip_set.h
@@ -142,6 +142,10 @@ enum ipset_errno {
 enum ipset_cmd_flags {
 	IPSET_FLAG_BIT_EXIST	= 0,
 	IPSET_FLAG_EXIST	= (1 << IPSET_FLAG_BIT_EXIST),
+	IPSET_FLAG_BIT_LIST_SETNAME = 1,
+	IPSET_FLAG_LIST_SETNAME	= (1 << IPSET_FLAG_BIT_LIST_SETNAME),
+	IPSET_FLAG_BIT_LIST_HEADER = 2,
+	IPSET_FLAG_LIST_HEADER	= (1 << IPSET_FLAG_BIT_LIST_HEADER),
 };
 
 /* Flags at CADT attribute level */
diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index c15c062..8446c7d 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -939,10 +939,13 @@ ip_set_swap(struct sock *ctnl, struct sk_buff *skb,
 
 /* List/save set data */
 
-#define DUMP_INIT	0L
-#define DUMP_ALL	1L
-#define DUMP_ONE	2L
-#define DUMP_LAST	3L
+#define DUMP_INIT	0
+#define DUMP_ALL	1
+#define DUMP_ONE	2
+#define DUMP_LAST	3
+
+#define DUMP_TYPE(arg)		(((u32)(arg)) & 0x0000FFFF)
+#define DUMP_FLAGS(arg)		(((u32)(arg)) >> 16)
 
 static int
 ip_set_dump_done(struct netlink_callback *cb)
@@ -973,6 +976,7 @@ dump_init(struct netlink_callback *cb)
 	int min_len = NLMSG_SPACE(sizeof(struct nfgenmsg));
 	struct nlattr *cda[IPSET_ATTR_CMD_MAX+1];
 	struct nlattr *attr = (void *)nlh + min_len;
+	u32 dump_type;
 	ip_set_id_t index;
 
 	/* Second pass, so parser can't fail */
@@ -984,17 +988,22 @@ dump_init(struct netlink_callback *cb)
 	 *         [..]: type specific
 	 */
 
-	if (!cda[IPSET_ATTR_SETNAME]) {
-		cb->args[0] = DUMP_ALL;
-		return 0;
-	}
+	if (cda[IPSET_ATTR_SETNAME]) {
+		index = find_set_id(nla_data(cda[IPSET_ATTR_SETNAME]));
+		if (index == IPSET_INVALID_ID)
+			return -ENOENT;
 
-	index = find_set_id(nla_data(cda[IPSET_ATTR_SETNAME]));
-	if (index == IPSET_INVALID_ID)
-		return -ENOENT;
+		dump_type = DUMP_ONE;
+		cb->args[1] = index;
+	} else
+		dump_type = DUMP_ALL;
+
+	if (cda[IPSET_ATTR_FLAGS]) {
+		u32 f = ip_set_get_h32(cda[IPSET_ATTR_FLAGS]);
+		dump_type |= (f << 16);
+	}
+	cb->args[0] = dump_type;
 
-	cb->args[0] = DUMP_ONE;
-	cb->args[1] = index;
 	return 0;
 }
 
@@ -1005,9 +1014,10 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 	struct ip_set *set = NULL;
 	struct nlmsghdr *nlh = NULL;
 	unsigned int flags = NETLINK_CB(cb->skb).pid ? NLM_F_MULTI : 0;
+	u32 dump_type, dump_flags;
 	int ret = 0;
 
-	if (cb->args[0] == DUMP_INIT) {
+	if (!cb->args[0]) {
 		ret = dump_init(cb);
 		if (ret < 0) {
 			nlh = nlmsg_hdr(cb->skb);
@@ -1022,14 +1032,17 @@ ip_set_dump_start(struct sk_buff *skb, struct netlink_callback *cb)
 	if (cb->args[1] >= ip_set_max)
 		goto out;
 
-	max = cb->args[0] == DUMP_ONE ? cb->args[1] + 1 : ip_set_max;
+	dump_type = DUMP_TYPE(cb->args[0]);
+	dump_flags = DUMP_FLAGS(cb->args[0]);
+	max = dump_type == DUMP_ONE ? cb->args[1] + 1 : ip_set_max;
 dump_last:
-	pr_debug("args[0]: %ld args[1]: %ld\n", cb->args[0], cb->args[1]);
+	pr_debug("args[0]: %u %u args[1]: %ld\n",
+		 dump_type, dump_flags, cb->args[1]);
 	for (; cb->args[1] < max; cb->args[1]++) {
 		index = (ip_set_id_t) cb->args[1];
 		set = ip_set_list[index];
 		if (set == NULL) {
-			if (cb->args[0] == DUMP_ONE) {
+			if (dump_type == DUMP_ONE) {
 				ret = -ENOENT;
 				goto out;
 			}
@@ -1038,8 +1051,8 @@ dump_last:
 		/* When dumping all sets, we must dump "sorted"
 		 * so that lists (unions of sets) are dumped last.
 		 */
-		if (cb->args[0] != DUMP_ONE &&
-		    ((cb->args[0] == DUMP_ALL) ==
+		if (dump_type != DUMP_ONE &&
+		    ((dump_type == DUMP_ALL) ==
 		     !!(set->type->features & IPSET_DUMP_LAST)))
 			continue;
 		pr_debug("List set: %s\n", set->name);
@@ -1057,6 +1070,8 @@ dump_last:
 		}
 		NLA_PUT_U8(skb, IPSET_ATTR_PROTOCOL, IPSET_PROTOCOL);
 		NLA_PUT_STRING(skb, IPSET_ATTR_SETNAME, set->name);
+		if (dump_flags & IPSET_FLAG_LIST_SETNAME)
+			goto next_set;
 		switch (cb->args[2]) {
 		case 0:
 			/* Core header data */
@@ -1069,24 +1084,23 @@ dump_last:
 			ret = set->variant->head(set, skb);
 			if (ret < 0)
 				goto release_refcount;
+			if (dump_flags & IPSET_FLAG_LIST_HEADER)
+				goto next_set;
 			/* Fall through and add elements */
 		default:
 			read_lock_bh(&set->lock);
 			ret = set->variant->list(set, skb, cb);
 			read_unlock_bh(&set->lock);
-			if (!cb->args[2]) {
+			if (!cb->args[2])
 				/* Set is done, proceed with next one */
-				if (cb->args[0] == DUMP_ONE)
-					cb->args[1] = IPSET_INVALID_ID;
-				else
-					cb->args[1]++;
-			}
+				goto next_set;
 			goto release_refcount;
 		}
 	}
 	/* If we dump all sets, continue with dumping last ones */
-	if (cb->args[0] == DUMP_ALL) {
-		cb->args[0] = DUMP_LAST;
+	if (dump_type == DUMP_ALL) {
+		dump_type = DUMP_LAST;
+		cb->args[0] = dump_type | (dump_flags << 16);
 		cb->args[1] = 0;
 		goto dump_last;
 	}
@@ -1094,6 +1108,11 @@ dump_last:
 
 nla_put_failure:
 	ret = -EFAULT;
+next_set:
+	if (dump_type == DUMP_ONE)
+		cb->args[1] = IPSET_INVALID_ID;
+	else
+		cb->args[1]++;
 release_refcount:
 	/* If there was an error or set is done, release set */
 	if (ret || !cb->args[2]) {
-- 
1.7.2.3

