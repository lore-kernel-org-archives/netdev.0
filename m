From: Roman Kapl <roman.kapl@sysgo.com>
Subject: [PATCH v2] net: move somaxconn init from sysctl code
Date: Wed, 24 May 2017 10:22:22 +0200
Message-ID: <20170524082222.14208-1-roman.kapl@sysgo.com>
Cc: Roman Kapl <roman.kapl@sysgo.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sysgo.com ([176.9.12.79]:53102 "EHLO mail.sysgo.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936668AbdEXIWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 May 2017 04:22:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default value for somaxconn is set in sysctl_core_net_init(), but this
function is not called when kernel is configured without CONFIG_SYSCTL.

This results in the kernel not being able to accept TCP connections,
because the backlog has zero size. Usually, the user ends up with:
"TCP: request_sock_TCP: Possible SYN flooding on port 7. Dropping request.  Check SNMP counters."
If SYN cookies are not enabled the connection is rejected.

Before ef547f2ac16 (tcp: remove max_qlen_log), the effects were less
severe, because the backlog was always at least eight slots long.

Signed-off-by: Roman Kapl <roman.kapl@sysgo.com>
---
 net/core/net_namespace.c   | 19 +++++++++++++++++++
 net/core/sysctl_net_core.c |  2 --
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 1934efd..26bbfab 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -315,6 +315,25 @@ static __net_init int setup_net(struct net *net, struct user_namespace *user_ns)
 	goto out;
 }
 
+static int __net_init net_defaults_init_net(struct net *net)
+{
+	net->core.sysctl_somaxconn = SOMAXCONN;
+	return 0;
+}
+
+static struct pernet_operations net_defaults_ops = {
+	.init = net_defaults_init_net,
+};
+
+static __init int net_defaults_init(void)
+{
+	if (register_pernet_subsys(&net_defaults_ops))
+		panic("Cannot initialize net default settings");
+
+	return 0;
+}
+
+core_initcall(net_defaults_init);
 
 #ifdef CONFIG_NET_NS
 static struct ucounts *inc_net_namespaces(struct user_namespace *ns)
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index ea23254..b7cd9aa 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -479,8 +479,6 @@ static __net_init int sysctl_core_net_init(struct net *net)
 {
 	struct ctl_table *tbl;
 
-	net->core.sysctl_somaxconn = SOMAXCONN;
-
 	tbl = netns_core_table;
 	if (!net_eq(net, &init_net)) {
 		tbl = kmemdup(tbl, sizeof(netns_core_table), GFP_KERNEL);
-- 
2.10.1
