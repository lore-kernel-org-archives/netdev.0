From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 07/08: xtables: optimize call flow around xt_ematch_foreach
Date: Wed, 24 Feb 2010 18:49:37 +0100 (MET)
Message-ID: <20100224174937.16391.86109.sendpatchset@x2.localnet>
References: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100224174927.16391.59798.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 6bdb331bc6910d1ccb74dc9852fc858c5916c927
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Feb 24 18:35:37 2010 +0100

    netfilter: xtables: optimize call flow around xt_ematch_foreach
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3a7fc73..36edc7d 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -572,14 +572,10 @@ mark_source_chains(const struct xt_table_info *newinfo,
 	return 1;
 }
 
-static int
-cleanup_match(struct ipt_entry_match *m, struct net *net, unsigned int *i)
+static void cleanup_match(struct ipt_entry_match *m, struct net *net)
 {
 	struct xt_mtdtor_param par;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	par.net       = net;
 	par.match     = m->u.kernel.match;
 	par.matchinfo = m->data;
@@ -587,7 +583,6 @@ cleanup_match(struct ipt_entry_match *m, struct net *net, unsigned int *i)
 	if (par.match->destroy != NULL)
 		par.match->destroy(&par);
 	module_put(par.match->me);
-	return 0;
 }
 
 static int
@@ -612,8 +607,7 @@ check_entry(const struct ipt_entry *e, const char *name)
 }
 
 static int
-check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par,
-	    unsigned int *i)
+check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
 {
 	const struct ipt_ip *ip = par->entryinfo;
 	int ret;
@@ -628,13 +622,11 @@ check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par,
 			 par.match->name);
 		return ret;
 	}
-	++*i;
 	return 0;
 }
 
 static int
-find_check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par,
-		 unsigned int *i)
+find_check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par)
 {
 	struct xt_match *match;
 	int ret;
@@ -648,7 +640,7 @@ find_check_match(struct ipt_entry_match *m, struct xt_mtchk_param *par,
 	}
 	m->u.kernel.match = match;
 
-	ret = check_match(m, par, i);
+	ret = check_match(m, par);
 	if (ret)
 		goto err;
 
@@ -704,12 +696,11 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV4;
 	xt_ematch_foreach(ematch, e) {
-		ret = find_check_match(ematch, &mtpar, &j);
+		ret = find_check_match(ematch, &mtpar);
 		if (ret != 0)
-			break;
+			goto cleanup_matches;
+		++j;
 	}
-	if (ret != 0)
-		goto cleanup_matches;
 
 	t = ipt_get_target(e);
 	target = try_then_request_module(xt_find_target(AF_INET,
@@ -730,9 +721,11 @@ find_check_entry(struct ipt_entry *e, struct net *net, const char *name,
  err:
 	module_put(t->u.kernel.target->me);
  cleanup_matches:
-	xt_ematch_foreach(ematch, e)
-		if (cleanup_match(ematch, net, &j) != 0)
+	xt_ematch_foreach(ematch, e) {
+		if (j-- == 0)
 			break;
+		cleanup_match(ematch, net);
+	}
 	return ret;
 }
 
@@ -807,8 +800,7 @@ cleanup_entry(struct ipt_entry *e, struct net *net)
 
 	/* Cleanup all matches */
 	xt_ematch_foreach(ematch, e)
-		if (cleanup_match(ematch, net, NULL) != 0)
-			break;
+		cleanup_match(ematch, net);
 	t = ipt_get_target(e);
 
 	par.net      = net;
@@ -1064,13 +1056,6 @@ static int compat_standard_to_user(void __user *dst, const void *src)
 	return copy_to_user(dst, &cv, sizeof(cv)) ? -EFAULT : 0;
 }
 
-static inline int
-compat_calc_match(const struct ipt_entry_match *m, int *size)
-{
-	*size += xt_compat_match_offset(m->u.kernel.match);
-	return 0;
-}
-
 static int compat_calc_entry(const struct ipt_entry *e,
 			     const struct xt_table_info *info,
 			     const void *base, struct xt_table_info *newinfo)
@@ -1083,8 +1068,7 @@ static int compat_calc_entry(const struct ipt_entry *e,
 	off = sizeof(struct ipt_entry) - sizeof(struct compat_ipt_entry);
 	entry_offset = (void *)e - base;
 	xt_ematch_foreach(ematch, e)
-		if (compat_calc_match(ematch, &off) != 0)
-			break;
+		off += xt_compat_match_offset(ematch->u.kernel.match);
 	t = ipt_get_target_c(e);
 	off += xt_compat_target_offset(t->u.kernel.target);
 	newinfo->size -= off;
@@ -1475,11 +1459,9 @@ compat_copy_entry_to_user(struct ipt_entry *e, void __user **dstptr,
 	xt_ematch_foreach(ematch, e) {
 		ret = xt_compat_match_to_user(ematch, dstptr, size);
 		if (ret != 0)
-			break;
+			return ret;
 	}
 	target_offset = e->target_offset - (origsize - *size);
-	if (ret)
-		return ret;
 	t = ipt_get_target(e);
 	ret = xt_compat_target_to_user(t, dstptr, size);
 	if (ret)
@@ -1496,7 +1478,7 @@ compat_find_calc_match(struct ipt_entry_match *m,
 		       const char *name,
 		       const struct ipt_ip *ip,
 		       unsigned int hookmask,
-		       int *size, unsigned int *i)
+		       int *size)
 {
 	struct xt_match *match;
 
@@ -1510,18 +1492,6 @@ compat_find_calc_match(struct ipt_entry_match *m,
 	}
 	m->u.kernel.match = match;
 	*size += xt_compat_match_offset(match);
-
-	(*i)++;
-	return 0;
-}
-
-static int
-compat_release_match(struct ipt_entry_match *m, unsigned int *i)
-{
-	if (i && (*i)-- == 0)
-		return 1;
-
-	module_put(m->u.kernel.match->me);
 	return 0;
 }
 
@@ -1532,8 +1502,7 @@ static void compat_release_entry(struct compat_ipt_entry *e)
 
 	/* Cleanup all matches */
 	xt_ematch_foreach(ematch, e)
-		if (compat_release_match(ematch, NULL) != 0)
-			break;
+		module_put(ematch->u.kernel.match->me);
 	t = compat_ipt_get_target(e);
 	module_put(t->u.kernel.target->me);
 }
@@ -1579,12 +1548,11 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
 		ret = compat_find_calc_match(ematch, name,
-		      &e->ip, e->comefrom, &off, &j);
+		      &e->ip, e->comefrom, &off);
 		if (ret != 0)
-			break;
+			goto release_matches;
+		++j;
 	}
-	if (ret != 0)
-		goto release_matches;
 
 	t = compat_ipt_get_target(e);
 	target = try_then_request_module(xt_find_target(AF_INET,
@@ -1621,9 +1589,11 @@ check_compat_entry_size_and_hooks(struct compat_ipt_entry *e,
 out:
 	module_put(t->u.kernel.target->me);
 release_matches:
-	xt_ematch_foreach(ematch, e)
-		if (compat_release_match(ematch, &j) != 0)
+	xt_ematch_foreach(ematch, e) {
+		if (j-- == 0)
 			break;
+		module_put(ematch->u.kernel.match->me);
+	}
 	return ret;
 }
 
@@ -1651,10 +1621,8 @@ compat_copy_entry_from_user(struct compat_ipt_entry *e, void **dstptr,
 	xt_ematch_foreach(ematch, e) {
 		ret = xt_compat_match_from_user(ematch, dstptr, size);
 		if (ret != 0)
-			break;
+			return ret;
 	}
-	if (ret)
-		return ret;
 	de->target_offset = e->target_offset - (origsize - *size);
 	t = compat_ipt_get_target(e);
 	target = t->u.kernel.target;
@@ -1685,12 +1653,11 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV4;
 	xt_ematch_foreach(ematch, e) {
-		ret = check_match(ematch, &mtpar, &j);
+		ret = check_match(ematch, &mtpar);
 		if (ret != 0)
-			break;
+			goto cleanup_matches;
+		++j;
 	}
-	if (ret)
-		goto cleanup_matches;
 
 	ret = check_target(e, net, name);
 	if (ret)
@@ -1698,9 +1665,11 @@ compat_check_entry(struct ipt_entry *e, struct net *net, const char *name)
 	return 0;
 
  cleanup_matches:
-	xt_ematch_foreach(ematch, e)
-		if (cleanup_match(ematch, net, &j) != 0)
+	xt_ematch_foreach(ematch, e) {
+		if (j-- == 0)
 			break;
+		cleanup_match(ematch, net);
+	}
 	return ret;
 }
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 1537e6b..c5a963e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -603,14 +603,10 @@ mark_source_chains(const struct xt_table_info *newinfo,
 	return 1;
 }
 
-static int
-cleanup_match(struct ip6t_entry_match *m, struct net *net, unsigned int *i)
+static void cleanup_match(struct ip6t_entry_match *m, struct net *net)
 {
 	struct xt_mtdtor_param par;
 
-	if (i && (*i)-- == 0)
-		return 1;
-
 	par.net       = net;
 	par.match     = m->u.kernel.match;
 	par.matchinfo = m->data;
@@ -618,7 +614,6 @@ cleanup_match(struct ip6t_entry_match *m, struct net *net, unsigned int *i)
 	if (par.match->destroy != NULL)
 		par.match->destroy(&par);
 	module_put(par.match->me);
-	return 0;
 }
 
 static int
@@ -642,8 +637,7 @@ check_entry(const struct ip6t_entry *e, const char *name)
 	return 0;
 }
 
-static int check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par,
-		       unsigned int *i)
+static int check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par)
 {
 	const struct ip6t_ip6 *ipv6 = par->entryinfo;
 	int ret;
@@ -658,13 +652,11 @@ static int check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par,
 			 par.match->name);
 		return ret;
 	}
-	++*i;
 	return 0;
 }
 
 static int
-find_check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par,
-		 unsigned int *i)
+find_check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par)
 {
 	struct xt_match *match;
 	int ret;
@@ -678,7 +670,7 @@ find_check_match(struct ip6t_entry_match *m, struct xt_mtchk_param *par,
 	}
 	m->u.kernel.match = match;
 
-	ret = check_match(m, par, i);
+	ret = check_match(m, par);
 	if (ret)
 		goto err;
 
@@ -735,12 +727,11 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV6;
 	xt_ematch_foreach(ematch, e) {
-		ret = find_check_match(ematch, &mtpar, &j);
+		ret = find_check_match(ematch, &mtpar);
 		if (ret != 0)
-			break;
+			goto cleanup_matches;
+		++j;
 	}
-	if (ret != 0)
-		goto cleanup_matches;
 
 	t = ip6t_get_target(e);
 	target = try_then_request_module(xt_find_target(AF_INET6,
@@ -761,9 +752,11 @@ find_check_entry(struct ip6t_entry *e, struct net *net, const char *name,
  err:
 	module_put(t->u.kernel.target->me);
  cleanup_matches:
-	xt_ematch_foreach(ematch, e)
-		if (cleanup_match(ematch, net, &j) != 0)
+	xt_ematch_foreach(ematch, e) {
+		if (j-- == 0)
 			break;
+		cleanup_match(ematch, net);
+	}
 	return ret;
 }
 
@@ -837,8 +830,7 @@ static void cleanup_entry(struct ip6t_entry *e, struct net *net)
 
 	/* Cleanup all matches */
 	xt_ematch_foreach(ematch, e)
-		if (cleanup_match(ematch, net, NULL) != 0)
-			break;
+		cleanup_match(ematch, net);
 	t = ip6t_get_target(e);
 
 	par.net      = net;
@@ -1094,13 +1086,6 @@ static int compat_standard_to_user(void __user *dst, const void *src)
 	return copy_to_user(dst, &cv, sizeof(cv)) ? -EFAULT : 0;
 }
 
-static inline int
-compat_calc_match(const struct ip6t_entry_match *m, int *size)
-{
-	*size += xt_compat_match_offset(m->u.kernel.match);
-	return 0;
-}
-
 static int compat_calc_entry(const struct ip6t_entry *e,
 			     const struct xt_table_info *info,
 			     const void *base, struct xt_table_info *newinfo)
@@ -1113,8 +1098,7 @@ static int compat_calc_entry(const struct ip6t_entry *e,
 	off = sizeof(struct ip6t_entry) - sizeof(struct compat_ip6t_entry);
 	entry_offset = (void *)e - base;
 	xt_ematch_foreach(ematch, e)
-		if (compat_calc_match(ematch, &off) != 0)
-			break;
+		off += xt_compat_match_offset(ematch->u.kernel.match);
 	t = ip6t_get_target_c(e);
 	off += xt_compat_target_offset(t->u.kernel.target);
 	newinfo->size -= off;
@@ -1508,11 +1492,9 @@ compat_copy_entry_to_user(struct ip6t_entry *e, void __user **dstptr,
 	xt_ematch_foreach(ematch, e) {
 		ret = xt_compat_match_to_user(ematch, dstptr, size);
 		if (ret != 0)
-			break;
+			return ret;
 	}
 	target_offset = e->target_offset - (origsize - *size);
-	if (ret)
-		return ret;
 	t = ip6t_get_target(e);
 	ret = xt_compat_target_to_user(t, dstptr, size);
 	if (ret)
@@ -1529,7 +1511,7 @@ compat_find_calc_match(struct ip6t_entry_match *m,
 		       const char *name,
 		       const struct ip6t_ip6 *ipv6,
 		       unsigned int hookmask,
-		       int *size, unsigned int *i)
+		       int *size)
 {
 	struct xt_match *match;
 
@@ -1543,18 +1525,6 @@ compat_find_calc_match(struct ip6t_entry_match *m,
 	}
 	m->u.kernel.match = match;
 	*size += xt_compat_match_offset(match);
-
-	(*i)++;
-	return 0;
-}
-
-static int
-compat_release_match(struct ip6t_entry_match *m, unsigned int *i)
-{
-	if (i && (*i)-- == 0)
-		return 1;
-
-	module_put(m->u.kernel.match->me);
 	return 0;
 }
 
@@ -1565,8 +1535,7 @@ static void compat_release_entry(struct compat_ip6t_entry *e)
 
 	/* Cleanup all matches */
 	xt_ematch_foreach(ematch, e)
-		if (compat_release_match(ematch, NULL) != 0)
-			break;
+		module_put(ematch->u.kernel.match->me);
 	t = compat_ip6t_get_target(e);
 	module_put(t->u.kernel.target->me);
 }
@@ -1612,12 +1581,11 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 	j = 0;
 	xt_ematch_foreach(ematch, e) {
 		ret = compat_find_calc_match(ematch, name,
-		      &e->ipv6, e->comefrom, &off, &j);
+		      &e->ipv6, e->comefrom, &off);
 		if (ret != 0)
-			break;
+			goto release_matches;
+		++j;
 	}
-	if (ret != 0)
-		goto release_matches;
 
 	t = compat_ip6t_get_target(e);
 	target = try_then_request_module(xt_find_target(AF_INET6,
@@ -1654,9 +1622,11 @@ check_compat_entry_size_and_hooks(struct compat_ip6t_entry *e,
 out:
 	module_put(t->u.kernel.target->me);
 release_matches:
-	xt_ematch_foreach(ematch, e)
-		if (compat_release_match(ematch, &j) != 0)
+	xt_ematch_foreach(ematch, e) {
+		if (j-- == 0)
 			break;
+		module_put(ematch->u.kernel.match->me);
+	}
 	return ret;
 }
 
@@ -1684,10 +1654,8 @@ compat_copy_entry_from_user(struct compat_ip6t_entry *e, void **dstptr,
 	xt_ematch_foreach(ematch, e) {
 		ret = xt_compat_match_from_user(ematch, dstptr, size);
 		if (ret != 0)
-			break;
+			return ret;
 	}
-	if (ret)
-		return ret;
 	de->target_offset = e->target_offset - (origsize - *size);
 	t = compat_ip6t_get_target(e);
 	target = t->u.kernel.target;
@@ -1718,12 +1686,11 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 	mtpar.hook_mask = e->comefrom;
 	mtpar.family    = NFPROTO_IPV6;
 	xt_ematch_foreach(ematch, e) {
-		ret = check_match(ematch, &mtpar, &j);
+		ret = check_match(ematch, &mtpar);
 		if (ret != 0)
-			break;
+			goto cleanup_matches;
+		++j;
 	}
-	if (ret)
-		goto cleanup_matches;
 
 	ret = check_target(e, net, name);
 	if (ret)
@@ -1731,9 +1698,11 @@ static int compat_check_entry(struct ip6t_entry *e, struct net *net,
 	return 0;
 
  cleanup_matches:
-	xt_ematch_foreach(ematch, e)
-		if (cleanup_match(ematch, net, &j) != 0)
+	xt_ematch_foreach(ematch, e) {
+		if (j-- == 0)
 			break;
+		cleanup_match(ematch, net);
+	}
 	return ret;
 }
 
