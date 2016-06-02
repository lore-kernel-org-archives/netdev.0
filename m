From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH 3/3] netfilter: iptables-restore does not work as expected
 with xt_hashlimit
Date: Wed, 1 Jun 2016 20:12:36 -0400
Message-ID: <20160602001236.GC1644@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: coreteam@netfilter.org, johunt@akamai.com, netdev@vger.kernel.org,
	pai.vishwain@gmail.com
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:34494 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752395AbcFBAMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 20:12:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netfilter: iptables-restore does not work as expected with xt_hashlimit

Add the following iptables rule.

$ iptables -A INPUT -m hashlimit --hashlimit-above 200/sec \
  --hashlimit-burst 5 --hashlimit-mode srcip --hashlimit-name hashlimit1 \
  --hashlimit-htable-expire 30000 -j DROP

$ iptables-save > save.txt

Edit save.txt and change the value of --hashlimit-above to 300:

-A INPUT -m hashlimit --hashlimit-above 300/sec --hashlimit-burst 5 \
--hashlimit-mode srcip --hashlimit-name hashlimit2 \
--hashlimit-htable-expire 30000 -j DROP

Now restore save.txt

$ iptables-restore < save.txt

Now userspace thinks that the value of --hashlimit-above is 300 but it is
actually 200 in the kernel. This happens because when we add multiple
hash-limit rules with the same name they will share the same hashtable
internally. The kernel module tries to re-use the old hashtable without
updating the values.

There are multiple problems here:
1) We can add two iptables rules with the same name, but kernel does not
   handle this well, one procfs file cannot work with two rules
2) If the second rule has no effect because the hashtable has values from
   rule 1
3) hashtable-restore does not work (as described above)

To fix this I have made the following design change:
1) If a second rule is added with the same name as an existing rule,
   append a number when we create the procfs, for example hashlimit_1,
   hashlimit_2 etc
2) Two rules will not share the same hashtable unless they are similar in
   every possible way
3) This behavior has to be forced with a new userspace flag:
   --hashlimit-ehanced-procfs, if this flag is not passed we default to
   the old behavior. This is to make sure we do not break existing scripts
   that rely on the existing behavior.

Signed-off-by: Vishwanath Pai <vpai@akamai.com>

diff --git a/include/uapi/linux/netfilter/xt_hashlimit.h b/include/uapi/linux/netfilter/xt_hashlimit.h
index be5d2e1..74444c7 100644
--- a/include/uapi/linux/netfilter/xt_hashlimit.h
+++ b/include/uapi/linux/netfilter/xt_hashlimit.h
@@ -18,6 +18,10 @@
 struct xt_hashlimit_htable;
 
 enum {
+	XT_HASHLIMIT_FLAG_PROCFS = 1
+};
+
+enum {
 	XT_HASHLIMIT_HASH_DIP = 1 << 0,
 	XT_HASHLIMIT_HASH_DPT = 1 << 1,
 	XT_HASHLIMIT_HASH_SIP = 1 << 2,
@@ -76,6 +80,9 @@ struct hashlimit_cfg2 {
 	__u32 expire;	/* when do entries expire? */
 
 	__u8 srcmask, dstmask;
+
+	__u8 procfs_suffix;
+	__u32 flags;
 };
 
 struct xt_hashlimit_mtinfo1 {
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 412e6ef..79d6745 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -238,6 +238,74 @@ dsthash_free(struct xt_hashlimit_htable *ht, struct dsthash_ent *ent)
 }
 static void htable_gc(struct work_struct *work);
 
+static int
+generate_procfs_suffix(struct net *net, const char *name,
+		       struct hashlimit_cfg2 *cfg, u_int8_t family)
+{
+	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
+	struct xt_hashlimit_htable *hinfo;
+	unsigned long bitarray = 0;
+
+	hlist_for_each_entry(hinfo, &hashlimit_net->htables, node) {
+		if (!strcmp(name, hinfo->name) && hinfo->family == family)
+			__set_bit(hinfo->cfg.procfs_suffix, &bitarray);
+	}
+
+	/* Too many name clashes, bail out
+	 */
+	if (bitarray == ~0UL)
+		return -1;
+
+	cfg->procfs_suffix = ffz(bitarray);
+
+	return 0;
+}
+
+static bool
+htable_compare(struct hashlimit_cfg2 *newcfg, const char *newname,
+	       struct xt_hashlimit_htable *hinfo, u_int8_t family)
+{
+	struct hashlimit_cfg2 *oldcfg = &hinfo->cfg;
+
+	if (!(newcfg->flags & XT_HASHLIMIT_FLAG_PROCFS)) {
+		return (!strcmp(newname, hinfo->name) &&
+				family == hinfo->family);
+	}
+
+	if (!strcmp(newname, hinfo->name) &&
+		family == hinfo->family &&
+		newcfg->mode == oldcfg->mode &&
+		newcfg->avg == oldcfg->avg &&
+		newcfg->burst == oldcfg->burst &&
+		newcfg->size == oldcfg->size &&
+		newcfg->max == oldcfg->max &&
+		newcfg->gc_interval == oldcfg->gc_interval &&
+		newcfg->expire == oldcfg->expire &&
+		newcfg->srcmask == oldcfg->srcmask &&
+		newcfg->dstmask == oldcfg->dstmask) {
+		return true;
+	}
+
+	return false;
+}
+
+static void
+htable_cfg_init(struct hashlimit_cfg2 *cfg) {
+	if (!cfg->size) {
+		cfg->size = (totalram_pages << PAGE_SHIFT) / 16384 /
+				sizeof(struct list_head);
+		if (totalram_pages > 1024 * 1024 * 1024 / PAGE_SIZE)
+			cfg->size = 8192;
+		if (cfg->size < 16)
+			cfg->size = 16;
+	}
+
+	if (cfg->max == 0)
+		cfg->max = 8 * cfg->size;
+	else if (cfg->max < cfg->size)
+		cfg->max = cfg->size;
+}
+
 static int htable_create(struct net *net, struct hashlimit_cfg2 *cfg,
 			 const char *name, u_int8_t family,
 			 struct xt_hashlimit_htable **out_hinfo,
@@ -245,6 +313,7 @@ static int htable_create(struct net *net, struct hashlimit_cfg2 *cfg,
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
 	struct xt_hashlimit_htable *hinfo;
+	char newname[NAME_MAX];
 	unsigned int size, i;
 
 	if (cfg->size) {
@@ -286,7 +355,13 @@ static int htable_create(struct net *net, struct hashlimit_cfg2 *cfg,
 	}
 	spin_lock_init(&hinfo->lock);
 
-	hinfo->pde = proc_create_data(name, 0,
+	/* if procfs_suffix !=0 and flags then generate new name */
+	if (cfg->procfs_suffix && (cfg->flags || true))
+		snprintf(newname, NAME_MAX, "%s_%u", name, cfg->procfs_suffix);
+	else
+		strcpy(newname, name);
+
+	hinfo->pde = proc_create_data(newname, 0,
 		(family == NFPROTO_IPV4) ?
 		hashlimit_net->ipt_hashlimit : hashlimit_net->ip6t_hashlimit,
 		(revision == 1) ? &dl_file_ops_v1 : &dl_file_ops,
@@ -355,14 +430,47 @@ static void htable_remove_proc_entry(struct xt_hashlimit_htable *hinfo)
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(hinfo->net);
 	struct proc_dir_entry *parent;
+	char newname[NAME_MAX];
 
 	if (hinfo->family == NFPROTO_IPV4)
 		parent = hashlimit_net->ipt_hashlimit;
 	else
 		parent = hashlimit_net->ip6t_hashlimit;
 
+	if (hinfo->cfg.procfs_suffix)
+		snprintf(newname, NAME_MAX, "%s_%u", hinfo->name,
+						hinfo->cfg.procfs_suffix);
+	else
+		strcpy(newname, hinfo->name);
+
 	if (parent != NULL)
-		remove_proc_entry(hinfo->name, parent);
+		remove_proc_entry(newname, parent);
+}
+
+static void htable_reorganize_procfs(const struct xt_mtdtor_param *par,
+				     const char *name) {
+	struct hashlimit_net *hashlimit_net = hashlimit_pernet(par->net);
+	struct xt_hashlimit_htable *hinfo, *hinfo_rename;
+	u_int8_t family = par->family;
+	int count = 0;
+
+	hlist_for_each_entry(hinfo, &hashlimit_net->htables, node) {
+		if (!strcmp(name, hinfo->name) && hinfo->family == family) {
+			hinfo_rename = hinfo;
+			count++;
+		}
+	}
+
+	if (count != 1 || hinfo_rename->cfg.procfs_suffix == 0)
+		return;
+
+	htable_remove_proc_entry(hinfo_rename);
+
+	hinfo_rename->cfg.procfs_suffix = 0;
+	hinfo_rename->pde = proc_create_data(name, 0,
+		(family == NFPROTO_IPV4) ?
+		hashlimit_net->ipt_hashlimit : hashlimit_net->ip6t_hashlimit,
+		&dl_file_ops, hinfo_rename);
 }
 
 static void htable_destroy(struct xt_hashlimit_htable *hinfo)
@@ -374,16 +482,18 @@ static void htable_destroy(struct xt_hashlimit_htable *hinfo)
 	vfree(hinfo);
 }
 
-static struct xt_hashlimit_htable *htable_find_get(struct net *net,
-						   const char *name,
-						   u_int8_t family)
+static struct
+xt_hashlimit_htable *htable_find_get(struct net *net, const char *name,
+				     struct hashlimit_cfg2 cfg,
+				     u_int8_t family)
 {
 	struct hashlimit_net *hashlimit_net = hashlimit_pernet(net);
 	struct xt_hashlimit_htable *hinfo;
 
+	htable_cfg_init(&cfg);
+
 	hlist_for_each_entry(hinfo, &hashlimit_net->htables, node) {
-		if (!strcmp(name, hinfo->name) &&
-		    hinfo->family == family) {
+		if (htable_compare(&cfg, name, hinfo, family)) {
 			hinfo->use++;
 			return hinfo;
 		}
@@ -707,7 +817,7 @@ hashlimit_mt_v1(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = info->hinfo;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg2 cfg = {};
 
 	cfg_copy(&cfg, (void *)&info->cfg, 1);
 
@@ -762,8 +872,12 @@ static int hashlimit_mt_check_common(const struct xt_mtchk_param *par,
 	}
 
 	mutex_lock(&hashlimit_mutex);
-	*hinfo = htable_find_get(net, name, par->family);
+	*hinfo = htable_find_get(net, name, *cfg, par->family);
 	if (*hinfo == NULL) {
+		if ((cfg->flags & XT_HASHLIMIT_FLAG_PROCFS) && revision == 2)
+			if (generate_procfs_suffix(net, name, cfg, par->family))
+				return -EINVAL;
+
 		ret = htable_create(net, cfg, name, par->family,
 				    hinfo, revision);
 		if (ret < 0) {
@@ -779,7 +893,7 @@ static int hashlimit_mt_check_common(const struct xt_mtchk_param *par,
 static int hashlimit_mt_check_v1(const struct xt_mtchk_param *par)
 {
 	struct xt_hashlimit_mtinfo1 *info = par->matchinfo;
-	struct hashlimit_cfg2 cfg;
+	struct hashlimit_cfg2 cfg = {};
 
 	if (info->name[sizeof(info->name) - 1] != '\0')
 		return -EINVAL;
@@ -813,6 +927,8 @@ static void hashlimit_mt_destroy(const struct xt_mtdtor_param *par)
 	const struct xt_hashlimit_mtinfo2 *info = par->matchinfo;
 
 	htable_put(info->hinfo);
+
+	htable_reorganize_procfs(par, info->name);
 }
 
 static struct xt_match hashlimit_mt_reg[] __read_mostly = {
