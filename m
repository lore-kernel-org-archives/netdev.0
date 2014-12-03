From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/12] netfilter: xt_recent: relax ip_pkt_list_tot restrictions
Date: Wed,  3 Dec 2014 13:55:31 +0100
Message-ID: <1417611342-25257-2-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48589 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752306AbaLCMxa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 07:53:30 -0500
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The maximum value for the hitcount parameter is given by
"ip_pkt_list_tot" parameter (default: 20).

Exceeding this value on the command line will cause the rule to be
rejected.  The parameter is also readonly, i.e. it cannot be changed
without module unload or reboot.

Store size per table, then base nstamps[] size on the hitcount instead.

The module parameter is retained for backwards compatibility.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_recent.c |   64 +++++++++++++++++++++++++++++++++------------
 1 file changed, 47 insertions(+), 17 deletions(-)

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index a9faae8..30dbe34 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -43,25 +43,29 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_recent");
 MODULE_ALIAS("ip6t_recent");
 
-static unsigned int ip_list_tot = 100;
-static unsigned int ip_pkt_list_tot = 20;
-static unsigned int ip_list_hash_size = 0;
-static unsigned int ip_list_perms = 0644;
-static unsigned int ip_list_uid = 0;
-static unsigned int ip_list_gid = 0;
+static unsigned int ip_list_tot __read_mostly = 100;
+static unsigned int ip_list_hash_size __read_mostly;
+static unsigned int ip_list_perms __read_mostly = 0644;
+static unsigned int ip_list_uid __read_mostly;
+static unsigned int ip_list_gid __read_mostly;
 module_param(ip_list_tot, uint, 0400);
-module_param(ip_pkt_list_tot, uint, 0400);
 module_param(ip_list_hash_size, uint, 0400);
 module_param(ip_list_perms, uint, 0400);
 module_param(ip_list_uid, uint, S_IRUGO | S_IWUSR);
 module_param(ip_list_gid, uint, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(ip_list_tot, "number of IPs to remember per list");
-MODULE_PARM_DESC(ip_pkt_list_tot, "number of packets per IP address to remember (max. 255)");
 MODULE_PARM_DESC(ip_list_hash_size, "size of hash table used to look up IPs");
 MODULE_PARM_DESC(ip_list_perms, "permissions on /proc/net/xt_recent/* files");
 MODULE_PARM_DESC(ip_list_uid, "default owner of /proc/net/xt_recent/* files");
 MODULE_PARM_DESC(ip_list_gid, "default owning group of /proc/net/xt_recent/* files");
 
+/* retained for backwards compatibility */
+static unsigned int ip_pkt_list_tot __read_mostly;
+module_param(ip_pkt_list_tot, uint, 0400);
+MODULE_PARM_DESC(ip_pkt_list_tot, "number of packets per IP address to remember (max. 255)");
+
+#define XT_RECENT_MAX_NSTAMPS	256
+
 struct recent_entry {
 	struct list_head	list;
 	struct list_head	lru_list;
@@ -79,6 +83,7 @@ struct recent_table {
 	union nf_inet_addr	mask;
 	unsigned int		refcnt;
 	unsigned int		entries;
+	u8			nstamps_max_mask;
 	struct list_head	lru_list;
 	struct list_head	iphash[0];
 };
@@ -90,7 +95,8 @@ struct recent_net {
 #endif
 };
 
-static int recent_net_id;
+static int recent_net_id __read_mostly;
+
 static inline struct recent_net *recent_pernet(struct net *net)
 {
 	return net_generic(net, recent_net_id);
@@ -171,12 +177,15 @@ recent_entry_init(struct recent_table *t, const union nf_inet_addr *addr,
 		  u_int16_t family, u_int8_t ttl)
 {
 	struct recent_entry *e;
+	unsigned int nstamps_max = t->nstamps_max_mask;
 
 	if (t->entries >= ip_list_tot) {
 		e = list_entry(t->lru_list.next, struct recent_entry, lru_list);
 		recent_entry_remove(t, e);
 	}
-	e = kmalloc(sizeof(*e) + sizeof(e->stamps[0]) * ip_pkt_list_tot,
+
+	nstamps_max += 1;
+	e = kmalloc(sizeof(*e) + sizeof(e->stamps[0]) * nstamps_max,
 		    GFP_ATOMIC);
 	if (e == NULL)
 		return NULL;
@@ -197,7 +206,7 @@ recent_entry_init(struct recent_table *t, const union nf_inet_addr *addr,
 
 static void recent_entry_update(struct recent_table *t, struct recent_entry *e)
 {
-	e->index %= ip_pkt_list_tot;
+	e->index &= t->nstamps_max_mask;
 	e->stamps[e->index++] = jiffies;
 	if (e->index > e->nstamps)
 		e->nstamps = e->index;
@@ -326,6 +335,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 	kuid_t uid;
 	kgid_t gid;
 #endif
+	unsigned int nstamp_mask;
 	unsigned int i;
 	int ret = -EINVAL;
 	size_t sz;
@@ -349,19 +359,33 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 		return -EINVAL;
 	if ((info->check_set & XT_RECENT_REAP) && !info->seconds)
 		return -EINVAL;
-	if (info->hit_count > ip_pkt_list_tot) {
-		pr_info("hitcount (%u) is larger than "
-			"packets to be remembered (%u)\n",
-			info->hit_count, ip_pkt_list_tot);
+	if (info->hit_count >= XT_RECENT_MAX_NSTAMPS) {
+		pr_info("hitcount (%u) is larger than allowed maximum (%u)\n",
+			info->hit_count, XT_RECENT_MAX_NSTAMPS - 1);
 		return -EINVAL;
 	}
 	if (info->name[0] == '\0' ||
 	    strnlen(info->name, XT_RECENT_NAME_LEN) == XT_RECENT_NAME_LEN)
 		return -EINVAL;
 
+	if (ip_pkt_list_tot && info->hit_count < ip_pkt_list_tot)
+		nstamp_mask = roundup_pow_of_two(ip_pkt_list_tot) - 1;
+	else if (info->hit_count)
+		nstamp_mask = roundup_pow_of_two(info->hit_count) - 1;
+	else
+		nstamp_mask = 32 - 1;
+
 	mutex_lock(&recent_mutex);
 	t = recent_table_lookup(recent_net, info->name);
 	if (t != NULL) {
+		if (info->hit_count > t->nstamps_max_mask) {
+			pr_info("hitcount (%u) is larger than packets to be remembered (%u) for table %s\n",
+				info->hit_count, t->nstamps_max_mask + 1,
+				info->name);
+			ret = -EINVAL;
+			goto out;
+		}
+
 		t->refcnt++;
 		ret = 0;
 		goto out;
@@ -377,6 +401,7 @@ static int recent_mt_check(const struct xt_mtchk_param *par,
 		goto out;
 	}
 	t->refcnt = 1;
+	t->nstamps_max_mask = nstamp_mask;
 
 	memcpy(&t->mask, &info->mask, sizeof(t->mask));
 	strcpy(t->name, info->name);
@@ -497,9 +522,12 @@ static void recent_seq_stop(struct seq_file *s, void *v)
 static int recent_seq_show(struct seq_file *seq, void *v)
 {
 	const struct recent_entry *e = v;
+	struct recent_iter_state *st = seq->private;
+	const struct recent_table *t = st->table;
 	unsigned int i;
 
-	i = (e->index - 1) % ip_pkt_list_tot;
+	i = (e->index - 1) & t->nstamps_max_mask;
+
 	if (e->family == NFPROTO_IPV4)
 		seq_printf(seq, "src=%pI4 ttl: %u last_seen: %lu oldest_pkt: %u",
 			   &e->addr.ip, e->ttl, e->stamps[i], e->index);
@@ -717,7 +745,9 @@ static int __init recent_mt_init(void)
 {
 	int err;
 
-	if (!ip_list_tot || !ip_pkt_list_tot || ip_pkt_list_tot > 255)
+	BUILD_BUG_ON_NOT_POWER_OF_2(XT_RECENT_MAX_NSTAMPS);
+
+	if (!ip_list_tot || ip_pkt_list_tot >= XT_RECENT_MAX_NSTAMPS)
 		return -EINVAL;
 	ip_list_hash_size = 1 << fls(ip_list_tot);
 
-- 
1.7.10.4
