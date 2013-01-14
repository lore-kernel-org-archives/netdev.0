From: pablo@netfilter.org
Subject: [PATCH 3/3] netfilter: x_tables: print correct hook names for ARP
Date: Tue, 15 Jan 2013 00:24:05 +0100
Message-ID: <1358205845-8522-4-git-send-email-pablo@netfilter.org>
References: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1358205845-8522-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@inai.de>

arptables 0.0.4 (released on 10th Jan 2013) supports calling the
CLASSIFY target, but on adding a rule to the wrong chain, the
diagnostic is as follows:

	# arptables -A INPUT -j CLASSIFY --set-class 0:0
	arptables: Invalid argument
	# dmesg | tail -n1
	x_tables: arp_tables: CLASSIFY target: used from hooks
	PREROUTING, but only usable from INPUT/FORWARD

This is incorrect, since xt_CLASSIFY.c does specify
(1 << NF_ARP_OUT) | (1 << NF_ARP_FORWARD).

This patch corrects the x_tables diagnostic message to print the
proper hook names for the NFPROTO_ARP case.

Affects all kernels down to and including v2.6.31.

Signed-off-by: Jan Engelhardt <jengelh@inai.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/x_tables.c |   28 ++++++++++++++++++++--------
 1 file changed, 20 insertions(+), 8 deletions(-)

diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 8d987c3..7b3a9e5 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -345,19 +345,27 @@ int xt_find_revision(u8 af, const char *name, u8 revision, int target,
 }
 EXPORT_SYMBOL_GPL(xt_find_revision);
 
-static char *textify_hooks(char *buf, size_t size, unsigned int mask)
+static char *
+textify_hooks(char *buf, size_t size, unsigned int mask, uint8_t nfproto)
 {
-	static const char *const names[] = {
+	static const char *const inetbr_names[] = {
 		"PREROUTING", "INPUT", "FORWARD",
 		"OUTPUT", "POSTROUTING", "BROUTING",
 	};
-	unsigned int i;
+	static const char *const arp_names[] = {
+		"INPUT", "FORWARD", "OUTPUT",
+	};
+	const char *const *names;
+	unsigned int i, max;
 	char *p = buf;
 	bool np = false;
 	int res;
 
+	names = (nfproto == NFPROTO_ARP) ? arp_names : inetbr_names;
+	max   = (nfproto == NFPROTO_ARP) ? ARRAY_SIZE(arp_names) :
+	                                   ARRAY_SIZE(inetbr_names);
 	*p = '\0';
-	for (i = 0; i < ARRAY_SIZE(names); ++i) {
+	for (i = 0; i < max; ++i) {
 		if (!(mask & (1 << i)))
 			continue;
 		res = snprintf(p, size, "%s%s", np ? "/" : "", names[i]);
@@ -402,8 +410,10 @@ int xt_check_match(struct xt_mtchk_param *par,
 		pr_err("%s_tables: %s match: used from hooks %s, but only "
 		       "valid from %s\n",
 		       xt_prefix[par->family], par->match->name,
-		       textify_hooks(used, sizeof(used), par->hook_mask),
-		       textify_hooks(allow, sizeof(allow), par->match->hooks));
+		       textify_hooks(used, sizeof(used), par->hook_mask,
+		                     par->family),
+		       textify_hooks(allow, sizeof(allow), par->match->hooks,
+		                     par->family));
 		return -EINVAL;
 	}
 	if (par->match->proto && (par->match->proto != proto || inv_proto)) {
@@ -575,8 +585,10 @@ int xt_check_target(struct xt_tgchk_param *par,
 		pr_err("%s_tables: %s target: used from hooks %s, but only "
 		       "usable from %s\n",
 		       xt_prefix[par->family], par->target->name,
-		       textify_hooks(used, sizeof(used), par->hook_mask),
-		       textify_hooks(allow, sizeof(allow), par->target->hooks));
+		       textify_hooks(used, sizeof(used), par->hook_mask,
+		                     par->family),
+		       textify_hooks(allow, sizeof(allow), par->target->hooks,
+		                     par->family));
 		return -EINVAL;
 	}
 	if (par->target->proto && (par->target->proto != proto || inv_proto)) {
-- 
1.7.10.4

