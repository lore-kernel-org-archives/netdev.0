From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/26] netfilter: xt_TRACE: add explicitly nf_logger_find_get call
Date: Wed,  6 Jul 2016 16:23:47 +0200
Message-ID: <1467815048-2240-6-git-send-email-pablo@netfilter.org>
References: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34209 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754441AbcGFO0h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 10:26:37 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 2B13A17DB6E
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 1A8F3FAB53
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:36 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 028F69EBC9
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2016 16:26:31 +0200 (CEST)
In-Reply-To: <1467815048-2240-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Consider such situation, if nf_log_ipv4 kernel module is not installed,
and the user add a following iptables rule:
  # iptables -t raw -I PREROUTING -j TRACE

There will be no trace log generated until the user install nf_log_ipv4
module manully. So we should add request related nf_log module
appropriately here.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_TRACE.c | 25 +++++++++++++++++++------
 1 file changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_TRACE.c b/net/netfilter/xt_TRACE.c
index df48967..858d189 100644
--- a/net/netfilter/xt_TRACE.c
+++ b/net/netfilter/xt_TRACE.c
@@ -4,12 +4,23 @@
 #include <linux/skbuff.h>
 
 #include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_log.h>
 
 MODULE_DESCRIPTION("Xtables: packet flow tracing");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("ipt_TRACE");
 MODULE_ALIAS("ip6t_TRACE");
 
+static int trace_tg_check(const struct xt_tgchk_param *par)
+{
+	return nf_logger_find_get(par->family, NF_LOG_TYPE_LOG);
+}
+
+static void trace_tg_destroy(const struct xt_tgdtor_param *par)
+{
+	nf_logger_put(par->family, NF_LOG_TYPE_LOG);
+}
+
 static unsigned int
 trace_tg(struct sk_buff *skb, const struct xt_action_param *par)
 {
@@ -18,12 +29,14 @@ trace_tg(struct sk_buff *skb, const struct xt_action_param *par)
 }
 
 static struct xt_target trace_tg_reg __read_mostly = {
-	.name       = "TRACE",
-	.revision   = 0,
-	.family     = NFPROTO_UNSPEC,
-	.table      = "raw",
-	.target     = trace_tg,
-	.me         = THIS_MODULE,
+	.name		= "TRACE",
+	.revision	= 0,
+	.family		= NFPROTO_UNSPEC,
+	.table		= "raw",
+	.target		= trace_tg,
+	.checkentry	= trace_tg_check,
+	.destroy	= trace_tg_destroy,
+	.me		= THIS_MODULE,
 };
 
 static int __init trace_tg_init(void)
-- 
2.1.4
