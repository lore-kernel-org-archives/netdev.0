From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH v2 1/2] netfilter: Prepare xt_hashlimit.c for revision 2
Date: Thu, 7 Jul 2016 19:32:25 -0400
Message-ID: <20160707233225.GA5026@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johunt@akamai.com, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	pai.vishwain@gmail.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:12635 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753044AbcGGXc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 19:32:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am planning to add a revision 2 for the hashlimit xtables module to
support higher packets per second rates. This patch renames all the
functions and variables related to revision 1 by adding _v1 at the end of
the names.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>
Signed-off-by: Joshua Hunt <johunt@akamai.com>
---
 include/uapi/linux/netfilter/xt_hashlimit.h |  2 +-
 net/netfilter/xt_hashlimit.c                | 61 +++++++++++++++--------------
 2 files changed, 32 insertions(+), 31 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_hashlimit.h b/include/uapi/linux/netfilter/xt_hashlimit.h
index 6db9037..ea8c1c0 100644
--- a/include/uapi/linux/netfilter/xt_hashlimit.h
+++ b/include/uapi/linux/netfilter/xt_hashlimit.h
@@ -5,7 +5,7 @@
 #include <linux/if.h>
 
 /* timings are in milliseconds. */
-#define XT_HASHLIMIT_SCALE 10000
+#define XT_HASHLIMIT_SCALE_v1 10000
 /* 1/10,000 sec period => max of 10,000/sec.  Min rate is then 429490
  * seconds, or one packet every 59 hours.
  */
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 1786968..6b0ad93 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -56,7 +56,7 @@ static inline struct hashlimit_net *hashlimit_pernet(struct net *net)
 }
 
 /* need to declare this at the top */
-static const struct file_operations dl_file_ops;
+static const struct file_operations dl_file_ops_v1;
 
 /* hash table crap */
 struct dsthash_dst {
@@ -215,8 +215,8 @@ dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
 }
 static void htable_gc(struct work_struct *work);
 
-static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
-			 u_int8_t family)
+static int htable_create_v1(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
+			    u_int8_t family)
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
 	struct xt_hashlimit_htable *hinfo;
@@ -265,7 +265,7 @@ static int htable_create(struct net *net, struct xt_hashlimit_mtinfo1 *minfo,
 	hinfo->pde = proc_create_data(minfo->name, 0,
 		(family == NFPROTO_IPV4) ?
 		hashlimit_net->ipt_hashlimit : hashlimit_net->ip6t_hashlimit,
-		&dl_file_ops, hinfo);
+		&dl_file_ops_v1, hinfo);
 	if (hinfo->pde == NULL) {
 		kfree(hinfo->name);
 		vfree(hinfo);
@@ -398,7 +398,7 @@ static void htable_put(struct xt_hashlimit_htable *hinfo)
    (slowest userspace tool allows), which means
    CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32 ie.
 */
-#define MAX_CPJ (0xFFFFFFFF / (HZ*60*60*24))
+#define MAX_CPJ_v1 (0xFFFFFFFF / (HZ*60*60*24))
 
 /* Repeated shift and or gives us all 1s, final shift and add 1 gives
  * us the power of 2 below the theoretical max, so GCC simply does a
@@ -410,7 +410,7 @@ static void htable_put(struct xt_hashlimit_htable *hinfo)
 #define _POW2_BELOW32(x) (_POW2_BELOW16(x)|_POW2_BELOW16((x)>>16))
 #define POW2_BELOW32(x) ((_POW2_BELOW32(x)>>1) + 1)
 
-#define CREDITS_PER_JIFFY POW2_BELOW32(MAX_CPJ)
+#define CREDITS_PER_JIFFY_v1 POW2_BELOW32(MAX_CPJ_v1)
 
 /* in byte mode, the lowest possible rate is one packet/second.
  * credit_cap is used as a counter that tells us how many times we can
@@ -428,11 +428,12 @@ static u32 xt_hashlimit_len_to_chunks(u32 len)
 static u32 user2credits(u32 user)
 {
 	/* If multiplying would overflow... */
-	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
+	if (user > 0xFFFFFFFF / (HZ*CREDITS_PER_JIFFY_v1))
 		/* Divide first. */
-		return (user / XT_HASHLIMIT_SCALE) * HZ * CREDITS_PER_JIFFY;
+		return (user / XT_HASHLIMIT_SCALE_v1) *\
+					HZ * CREDITS_PER_JIFFY_v1;
 
-	return (user * HZ * CREDITS_PER_JIFFY) / XT_HASHLIMIT_SCALE;
+	return (user * HZ * CREDITS_PER_JIFFY_v1) / XT_HASHLIMIT_SCALE_v1;
 }
 
 static u32 user2credits_byte(u32 user)
@@ -461,7 +462,7 @@ static void rateinfo_recalc(struct dsthash_ent *dh, unsigned long now, u32 mode)
 			return;
 		}
 	} else {
-		dh->rateinfo.credit += delta * CREDITS_PER_JIFFY;
+		dh->rateinfo.credit += delta * CREDITS_PER_JIFFY_v1;
 		cap = dh->rateinfo.credit_cap;
 	}
 	if (dh->rateinfo.credit > cap)
@@ -603,7 +604,7 @@ static u32 hashlimit_byte_cost(unsigned int len, struct dsthash_ent *dh)
 }
 
 static bool
-hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
+hashlimit_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = info->hinfo;
@@ -660,7 +661,7 @@ hashlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	return false;
 }
 
-static int hashlimit_mt_check(const struct xt_mtchk_param *par)
+static int hashlimit_mt_check_v1(const struct xt_mtchk_param *par)
 {
 	struct net *net = par->net;
 	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
@@ -701,7 +702,7 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 	mutex_lock(&hashlimit_mutex);
 	info->hinfo = htable_find_get(net, info->name, par->family);
 	if (info->hinfo == NULL) {
-		ret = htable_create(net, info, par->family);
+		ret = htable_create_v1(net, info, par->family);
 		if (ret < 0) {
 			mutex_unlock(&hashlimit_mutex);
 			return ret;
@@ -711,7 +712,7 @@ static int hashlimit_mt_check(const struct xt_mtchk_param *par)
 	return 0;
 }
 
-static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
+static void hashlimit_mt_destroy_v1(const struct xt_mtdtor_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 
@@ -723,10 +724,10 @@ static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 		.name           = "hashlimit",
 		.revision       = 1,
 		.family         = NFPROTO_IPV4,
-		.match          = hashlimit_mt,
+		.match          = hashlimit_mt_v1,
 		.matchsize      = sizeof(struct xt_hashlimit_mtinfo1),
-		.checkentry     = hashlimit_mt_check,
-		.destroy        = hashlimit_mt_destroy,
+		.checkentry     = hashlimit_mt_check_v1,
+		.destroy        = hashlimit_mt_destroy_v1,
 		.me             = THIS_MODULE,
 	},
 #if IS_ENABLED(CONFIG_IP6_NF_IPTABLES)
@@ -734,10 +735,10 @@ static struct xt_match hashlimit_mt_reg[] __read_mostly = {
 		.name           = "hashlimit",
 		.revision       = 1,
 		.family         = NFPROTO_IPV6,
-		.match          = hashlimit_mt,
+		.match          = hashlimit_mt_v1,
 		.matchsize      = sizeof(struct xt_hashlimit_mtinfo1),
-		.checkentry     = hashlimit_mt_check,
-		.destroy        = hashlimit_mt_destroy,
+		.checkentry     = hashlimit_mt_check_v1,
+		.destroy        = hashlimit_mt_destroy_v1,
 		.me             = THIS_MODULE,
 	},
 #endif
@@ -786,8 +787,8 @@ static void dl_seq_stop(struct seq_file *s, void *v)
 	spin_unlock_bh(&htable->lock);
 }
 
-static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
-				   struct seq_file *s)
+static int dl_seq_real_show_v1(struct dsthash_ent *ent, u_int8_t family,
+			       struct seq_file *s)
 {
 	const struct xt_hashlimit_htable *ht = s->private;
 
@@ -825,7 +826,7 @@ static int dl_seq_real_show(struct dsthash_ent *ent, u_int8_t family,
 	return seq_has_overflowed(s);
 }
 
-static int dl_seq_show(struct seq_file *s, void *v)
+static int dl_seq_show_v1(struct seq_file *s, void *v)
 {
 	struct xt_hashlimit_htable *htable = s->private;
 	unsigned int *bucket = (unsigned int *)v;
@@ -833,22 +834,22 @@ static int dl_seq_show(struct seq_file *s, void *v)
 
 	if (!hlist_empty(&htable->hash[*bucket])) {
 		hlist_for_each_entry(ent, &htable->hash[*bucket], node)
-			if (dl_seq_real_show(ent, htable->family, s))
+			if (dl_seq_real_show_v1(ent, htable->family, s))
 				return -1;
 	}
 	return 0;
 }
 
-static const struct seq_operations dl_seq_ops = {
+static const struct seq_operations dl_seq_ops_v1 = {
 	.start = dl_seq_start,
 	.next  = dl_seq_next,
 	.stop  = dl_seq_stop,
-	.show  = dl_seq_show
+	.show  = dl_seq_show_v1
 };
 
-static int dl_proc_open(struct inode *inode, struct file *file)
+static int dl_proc_open_v1(struct inode *inode, struct file *file)
 {
-	int ret = seq_open(file, &dl_seq_ops);
+	int ret = seq_open(file, &dl_seq_ops_v1);
 
 	if (!ret) {
 		struct seq_file *sf = file->private_data;
@@ -857,9 +858,9 @@ static int dl_proc_open(struct inode *inode, struct file *file)
 	return ret;
 }
 
-static const struct file_operations dl_file_ops = {
+static const struct file_operations dl_file_ops_v1 = {
 	.owner   = THIS_MODULE,
-	.open    = dl_proc_open,
+	.open    = dl_proc_open_v1,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
 	.release = seq_release
-- 
1.9.1
