From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/12] netfilter: ipset: Alignment problem between 64bit kernel 32bit userspace
Date: Wed,  3 Dec 2014 13:55:38 +0100
Message-ID: <1417611342-25257-9-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Sven-Haegar Koch reported the issue:

sims:~# iptables -A OUTPUT -m set --match-set testset src -j ACCEPT
iptables: Invalid argument. Run `dmesg' for more information.

In syslog:
x_tables: ip_tables: set.3 match: invalid size 48 (kernel) != (user) 32

which was introduced by the counter extension in ipset.

The patch fixes the alignment issue with introducing a new set match
revision with the fixed underlying 'struct ip_set_counter_match'
structure.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/ipset/ip_set.h |    8 ++-
 include/uapi/linux/netfilter/xt_set.h       |   13 ++++-
 net/netfilter/xt_set.c                      |   73 +++++++++++++++++++++++++--
 3 files changed, 88 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/netfilter/ipset/ip_set.h b/include/uapi/linux/netfilter/ipset/ip_set.h
index ca03119..5ab4e60 100644
--- a/include/uapi/linux/netfilter/ipset/ip_set.h
+++ b/include/uapi/linux/netfilter/ipset/ip_set.h
@@ -256,11 +256,17 @@ enum {
 	IPSET_COUNTER_GT,
 };
 
-struct ip_set_counter_match {
+/* Backward compatibility for set match v3 */
+struct ip_set_counter_match0 {
 	__u8 op;
 	__u64 value;
 };
 
+struct ip_set_counter_match {
+	__aligned_u64 value;
+	__u8 op;
+};
+
 /* Interface to iptables/ip6tables */
 
 #define SO_IP_SET		83
diff --git a/include/uapi/linux/netfilter/xt_set.h b/include/uapi/linux/netfilter/xt_set.h
index d6a1df1..d4e0234 100644
--- a/include/uapi/linux/netfilter/xt_set.h
+++ b/include/uapi/linux/netfilter/xt_set.h
@@ -66,8 +66,8 @@ struct xt_set_info_target_v2 {
 
 struct xt_set_info_match_v3 {
 	struct xt_set_info match_set;
-	struct ip_set_counter_match packets;
-	struct ip_set_counter_match bytes;
+	struct ip_set_counter_match0 packets;
+	struct ip_set_counter_match0 bytes;
 	__u32 flags;
 };
 
@@ -81,4 +81,13 @@ struct xt_set_info_target_v3 {
 	__u32 timeout;
 };
 
+/* Revision 4 match */
+
+struct xt_set_info_match_v4 {
+	struct xt_set_info match_set;
+	struct ip_set_counter_match packets;
+	struct ip_set_counter_match bytes;
+	__u32 flags;
+};
+
 #endif /*_XT_SET_H*/
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index 5732cd6..0d47afe 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -157,7 +157,7 @@ set_match_v1_destroy(const struct xt_mtdtor_param *par)
 /* Revision 3 match */
 
 static bool
-match_counter(u64 counter, const struct ip_set_counter_match *info)
+match_counter0(u64 counter, const struct ip_set_counter_match0 *info)
 {
 	switch (info->op) {
 	case IPSET_COUNTER_NONE:
@@ -192,14 +192,60 @@ set_match_v3(const struct sk_buff *skb, struct xt_action_param *par)
 	if (!(ret && opt.cmdflags & IPSET_FLAG_MATCH_COUNTERS))
 		return ret;
 
-	if (!match_counter(opt.ext.packets, &info->packets))
+	if (!match_counter0(opt.ext.packets, &info->packets))
 		return 0;
-	return match_counter(opt.ext.bytes, &info->bytes);
+	return match_counter0(opt.ext.bytes, &info->bytes);
 }
 
 #define set_match_v3_checkentry	set_match_v1_checkentry
 #define set_match_v3_destroy	set_match_v1_destroy
 
+/* Revision 4 match */
+
+static bool
+match_counter(u64 counter, const struct ip_set_counter_match *info)
+{
+	switch (info->op) {
+	case IPSET_COUNTER_NONE:
+		return true;
+	case IPSET_COUNTER_EQ:
+		return counter == info->value;
+	case IPSET_COUNTER_NE:
+		return counter != info->value;
+	case IPSET_COUNTER_LT:
+		return counter < info->value;
+	case IPSET_COUNTER_GT:
+		return counter > info->value;
+	}
+	return false;
+}
+
+static bool
+set_match_v4(const struct sk_buff *skb, struct xt_action_param *par)
+{
+	const struct xt_set_info_match_v4 *info = par->matchinfo;
+	ADT_OPT(opt, par->family, info->match_set.dim,
+		info->match_set.flags, info->flags, UINT_MAX);
+	int ret;
+
+	if (info->packets.op != IPSET_COUNTER_NONE ||
+	    info->bytes.op != IPSET_COUNTER_NONE)
+		opt.cmdflags |= IPSET_FLAG_MATCH_COUNTERS;
+
+	ret = match_set(info->match_set.index, skb, par, &opt,
+			info->match_set.flags & IPSET_INV_MATCH);
+
+	if (!(ret && opt.cmdflags & IPSET_FLAG_MATCH_COUNTERS))
+		return ret;
+
+	if (!match_counter(opt.ext.packets, &info->packets))
+		return 0;
+	return match_counter(opt.ext.bytes, &info->bytes);
+}
+
+#define set_match_v4_checkentry	set_match_v1_checkentry
+#define set_match_v4_destroy	set_match_v1_destroy
+
 /* Revision 0 interface: backward compatible with netfilter/iptables */
 
 static unsigned int
@@ -573,6 +619,27 @@ static struct xt_match set_matches[] __read_mostly = {
 		.destroy	= set_match_v3_destroy,
 		.me		= THIS_MODULE
 	},
+	/* new revision for counters support: update, match */
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV4,
+		.revision	= 4,
+		.match		= set_match_v4,
+		.matchsize	= sizeof(struct xt_set_info_match_v4),
+		.checkentry	= set_match_v4_checkentry,
+		.destroy	= set_match_v4_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "set",
+		.family		= NFPROTO_IPV6,
+		.revision	= 4,
+		.match		= set_match_v4,
+		.matchsize	= sizeof(struct xt_set_info_match_v4),
+		.checkentry	= set_match_v4_checkentry,
+		.destroy	= set_match_v4_destroy,
+		.me		= THIS_MODULE
+	},
 };
 
 static struct xt_target set_targets[] __read_mostly = {
-- 
1.7.10.4

