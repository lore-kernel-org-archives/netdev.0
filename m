From: kaber@trash.net
Subject: [PATCH 22/84] netfilter: xtables: make use of caller family rather than match family
Date: Mon, 10 May 2010 22:17:53 +0200
Message-ID: <1273522735-24672-23-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54507 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756572Ab0EJUTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:03 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

The matches can have .family = NFPROTO_UNSPEC, and though that is not
the case for the touched modules, it seems better to just use the
nfproto from the caller.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_dscp.c      |    2 +-
 net/netfilter/xt_hashlimit.c |   10 +++++-----
 net/netfilter/xt_policy.c    |    4 ++--
 net/netfilter/xt_recent.c    |    6 +++---
 net/netfilter/xt_state.c     |    6 +++---
 5 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/netfilter/xt_dscp.c b/net/netfilter/xt_dscp.c
index 0280d3a..fe58cd0 100644
--- a/net/netfilter/xt_dscp.c
+++ b/net/netfilter/xt_dscp.c
@@ -58,7 +58,7 @@ static bool tos_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	const struct xt_tos_match_info *info = par->matchinfo;
 
-	if (par->match->family == NFPROTO_IPV4)
+	if (par->family == NFPROTO_IPV4)
 		return ((ip_hdr(skb)->tos & info->tos_mask) ==
 		       info->tos_value) ^ !!info->invert;
 	else
diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index ba9601a..1fdb50a 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -703,8 +703,8 @@ static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 		return false;
 
 	mutex_lock(&hashlimit_mutex);
-	r->hinfo = htable_find_get(net, r->name, par->match->family);
-	if (!r->hinfo && htable_create_v0(net, r, par->match->family) != 0) {
+	r->hinfo = htable_find_get(net, r->name, par->family);
+	if (!r->hinfo && htable_create_v0(net, r, par->family) != 0) {
 		mutex_unlock(&hashlimit_mutex);
 		return false;
 	}
@@ -730,7 +730,7 @@ static bool hashlimit_mt_check(const struct xt_mtchk_param *par)
 		return false;
 	if (info->name[sizeof(info->name)-1] != '\0')
 		return false;
-	if (par->match->family == NFPROTO_IPV4) {
+	if (par->family == NFPROTO_IPV4) {
 		if (info->cfg.srcmask > 32 || info->cfg.dstmask > 32)
 			return false;
 	} else {
@@ -739,8 +739,8 @@ static bool hashlimit_mt_check(const struct xt_mtchk_param *par)
 	}
 
 	mutex_lock(&hashlimit_mutex);
-	info->hinfo = htable_find_get(net, info->name, par->match->family);
-	if (!info->hinfo && htable_create(net, info, par->match->family) != 0) {
+	info->hinfo = htable_find_get(net, info->name, par->family);
+	if (!info->hinfo && htable_create(net, info, par->family) != 0) {
 		mutex_unlock(&hashlimit_mutex);
 		return false;
 	}
diff --git a/net/netfilter/xt_policy.c b/net/netfilter/xt_policy.c
index 4cbfebd..cc033d2 100644
--- a/net/netfilter/xt_policy.c
+++ b/net/netfilter/xt_policy.c
@@ -116,9 +116,9 @@ policy_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	int ret;
 
 	if (info->flags & XT_POLICY_MATCH_IN)
-		ret = match_policy_in(skb, info, par->match->family);
+		ret = match_policy_in(skb, info, par->family);
 	else
-		ret = match_policy_out(skb, info, par->match->family);
+		ret = match_policy_out(skb, info, par->family);
 
 	if (ret < 0)
 		ret = info->flags & XT_POLICY_MATCH_NONE ? true : false;
diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index d2e7c80..a0ea1a2 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -233,7 +233,7 @@ recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	u_int8_t ttl;
 	bool ret = info->invert;
 
-	if (par->match->family == NFPROTO_IPV4) {
+	if (par->family == NFPROTO_IPV4) {
 		const struct iphdr *iph = ip_hdr(skb);
 
 		if (info->side == XT_RECENT_DEST)
@@ -259,12 +259,12 @@ recent_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 	spin_lock_bh(&recent_lock);
 	t = recent_table_lookup(recent_net, info->name);
-	e = recent_entry_lookup(t, &addr, par->match->family,
+	e = recent_entry_lookup(t, &addr, par->family,
 				(info->check_set & XT_RECENT_TTL) ? ttl : 0);
 	if (e == NULL) {
 		if (!(info->check_set & XT_RECENT_SET))
 			goto out;
-		e = recent_entry_init(t, &addr, par->match->family, ttl);
+		e = recent_entry_init(t, &addr, par->family, ttl);
 		if (e == NULL)
 			*par->hotdrop = true;
 		ret = !ret;
diff --git a/net/netfilter/xt_state.c b/net/netfilter/xt_state.c
index 4c946cb..ef09b2e 100644
--- a/net/netfilter/xt_state.c
+++ b/net/netfilter/xt_state.c
@@ -39,9 +39,9 @@ state_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 static bool state_mt_check(const struct xt_mtchk_param *par)
 {
-	if (nf_ct_l3proto_try_module_get(par->match->family) < 0) {
+	if (nf_ct_l3proto_try_module_get(par->family) < 0) {
 		printk(KERN_WARNING "can't load conntrack support for "
-				    "proto=%u\n", par->match->family);
+				    "proto=%u\n", par->family);
 		return false;
 	}
 	return true;
@@ -49,7 +49,7 @@ static bool state_mt_check(const struct xt_mtchk_param *par)
 
 static void state_mt_destroy(const struct xt_mtdtor_param *par)
 {
-	nf_ct_l3proto_module_put(par->match->family);
+	nf_ct_l3proto_module_put(par->family);
 }
 
 static struct xt_match state_mt_reg[] __read_mostly = {
-- 
1.7.0.4

