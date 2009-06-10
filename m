From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 11/31: xtables: print hook name instead of mask
Date: Wed, 10 Jun 2009 21:46:36 +0200 (MEST)
Message-ID: <20090610194635.11112.2127.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33167 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761104AbZFJTqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:35 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 451853645f3cb804b523227eca054701e4cbc589
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Apr 5 10:43:09 2009 +0200

    netfilter: xtables: print hook name instead of mask
    
    Users cannot make anything of these numbers. Let's just tell them
    directly.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 150e5cf..46dba5f 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -329,6 +329,32 @@ int xt_find_revision(u8 af, const char *name, u8 revision, int target,
 }
 EXPORT_SYMBOL_GPL(xt_find_revision);
 
+static char *textify_hooks(char *buf, size_t size, unsigned int mask)
+{
+	static const char *const names[] = {
+		"PREROUTING", "INPUT", "FORWARD",
+		"OUTPUT", "POSTROUTING", "BROUTING",
+	};
+	unsigned int i;
+	char *p = buf;
+	bool np = false;
+	int res;
+
+	*p = '\0';
+	for (i = 0; i < ARRAY_SIZE(names); ++i) {
+		if (!(mask & (1 << i)))
+			continue;
+		res = snprintf(p, size, "%s%s", np ? "/" : "", names[i]);
+		if (res > 0) {
+			size -= res;
+			p += res;
+		}
+		np = true;
+	}
+
+	return buf;
+}
+
 int xt_check_match(struct xt_mtchk_param *par,
 		   unsigned int size, u_int8_t proto, bool inv_proto)
 {
@@ -351,9 +377,13 @@ int xt_check_match(struct xt_mtchk_param *par,
 		return -EINVAL;
 	}
 	if (par->match->hooks && (par->hook_mask & ~par->match->hooks) != 0) {
-		printk("%s_tables: %s match: bad hook_mask %#x/%#x\n",
+		char used[64], allow[64];
+
+		printk("%s_tables: %s match: used from hooks %s, but only "
+		       "valid from %s\n",
 		       xt_prefix[par->family], par->match->name,
-		       par->hook_mask, par->match->hooks);
+		       textify_hooks(used, sizeof(used), par->hook_mask),
+		       textify_hooks(allow, sizeof(allow), par->match->hooks));
 		return -EINVAL;
 	}
 	if (par->match->proto && (par->match->proto != proto || inv_proto)) {
@@ -497,9 +527,13 @@ int xt_check_target(struct xt_tgchk_param *par,
 		return -EINVAL;
 	}
 	if (par->target->hooks && (par->hook_mask & ~par->target->hooks) != 0) {
-		printk("%s_tables: %s target: bad hook_mask %#x/%#x\n",
+		char used[64], allow[64];
+
+		printk("%s_tables: %s target: used from hooks %s, but only "
+		       "usable from %s\n",
 		       xt_prefix[par->family], par->target->name,
-		       par->hook_mask, par->target->hooks);
+		       textify_hooks(used, sizeof(used), par->hook_mask),
+		       textify_hooks(allow, sizeof(allow), par->target->hooks));
 		return -EINVAL;
 	}
 	if (par->target->proto && (par->target->proto != proto || inv_proto)) {
