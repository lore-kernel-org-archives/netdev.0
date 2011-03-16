From: kaber@trash.net
Subject: [PATCH 01/01] netfilter ebtables: fix xt_AUDIT to work with ebtables
Date: Wed, 16 Mar 2011 18:38:31 +0100
Message-ID: <1300297111-28116-2-git-send-email-kaber@trash.net>
References: <1300297111-28116-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300297111-28116-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@redhat.com>

Even though ebtables uses xtables it still requires targets to
return EBT_CONTINUE instead of XT_CONTINUE. This prevented
xt_AUDIT to work as ebt module.

Upon Jan's suggestion, use a separate struct xt_target for
NFPROTO_BRIDGE having its own target callback returning
EBT_CONTINUE instead of cloning the module.

Signed-off-by: Thomas Graf <tgraf@redhat.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_AUDIT.c |   36 +++++++++++++++++++++++++++---------
 1 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/xt_AUDIT.c b/net/netfilter/xt_AUDIT.c
index 81802d2..363a99e 100644
--- a/net/netfilter/xt_AUDIT.c
+++ b/net/netfilter/xt_AUDIT.c
@@ -19,6 +19,7 @@
 #include <linux/if_arp.h>
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_AUDIT.h>
+#include <linux/netfilter_bridge/ebtables.h>
 #include <net/ipv6.h>
 #include <net/ip.h>
 
@@ -168,6 +169,13 @@ errout:
 	return XT_CONTINUE;
 }
 
+static unsigned int
+audit_tg_ebt(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	audit_tg(skb, par);
+	return EBT_CONTINUE;
+}
+
 static int audit_tg_check(const struct xt_tgchk_param *par)
 {
 	const struct xt_audit_info *info = par->targinfo;
@@ -181,23 +189,33 @@ static int audit_tg_check(const struct xt_tgchk_param *par)
 	return 0;
 }
 
-static struct xt_target audit_tg_reg __read_mostly = {
-	.name		= "AUDIT",
-	.family		= NFPROTO_UNSPEC,
-	.target		= audit_tg,
-	.targetsize	= sizeof(struct xt_audit_info),
-	.checkentry	= audit_tg_check,
-	.me		= THIS_MODULE,
+static struct xt_target audit_tg_reg[] __read_mostly = {
+	{
+		.name		= "AUDIT",
+		.family		= NFPROTO_UNSPEC,
+		.target		= audit_tg,
+		.targetsize	= sizeof(struct xt_audit_info),
+		.checkentry	= audit_tg_check,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "AUDIT",
+		.family		= NFPROTO_BRIDGE,
+		.target		= audit_tg_ebt,
+		.targetsize	= sizeof(struct xt_audit_info),
+		.checkentry	= audit_tg_check,
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init audit_tg_init(void)
 {
-	return xt_register_target(&audit_tg_reg);
+	return xt_register_targets(audit_tg_reg, ARRAY_SIZE(audit_tg_reg));
 }
 
 static void __exit audit_tg_exit(void)
 {
-	xt_unregister_target(&audit_tg_reg);
+	xt_unregister_targets(audit_tg_reg, ARRAY_SIZE(audit_tg_reg));
 }
 
 module_init(audit_tg_init);
-- 
1.7.2.3

