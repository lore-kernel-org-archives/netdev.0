From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 08/10] netfilter: bridge: register hooks only when bridge interface is added
Date: Tue,  8 Mar 2016 11:00:48 +0100
Message-ID: <1457431250-3086-9-git-send-email-pablo@netfilter.org>
References: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This moves bridge hooks to a register-when-needed scheme.

We use a device notifier to register the 'call-iptables' netfilter hooks
only once a bridge gets added.

This means that if the initial namespace uses a bridge, newly created
network namespaces no longer get the PRE_ROUTING ipt_sabotage hook.

It will registered in that network namespace once a bridge is created
within that namespace.

A few modules still use global hooks:

- conntrack
- bridge PF_BRIDGE hooks
- IPVS
- CLUSTER match (deprecated)
- SYNPROXY

As long as these modules are not loaded/used, a new network namespace has
empty hook list and NF_HOOK() will boil down to single list_empty test even
if initial namespace does stateless packet filtering.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter_hooks.c | 68 +++++++++++++++++++++++++++++++++++++++--
 1 file changed, 65 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 7ddbe7e..44114a9 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -37,6 +37,7 @@
 #include <net/addrconf.h>
 #include <net/route.h>
 #include <net/netfilter/br_netfilter.h>
+#include <net/netns/generic.h>
 
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -44,6 +45,12 @@
 #include <linux/sysctl.h>
 #endif
 
+static int brnf_net_id __read_mostly;
+
+struct brnf_net {
+	bool enabled;
+};
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
@@ -938,6 +945,53 @@ static struct nf_hook_ops br_nf_ops[] __read_mostly = {
 	},
 };
 
+static int brnf_device_event(struct notifier_block *unused, unsigned long event,
+			     void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct brnf_net *brnet;
+	struct net *net;
+	int ret;
+
+	if (event != NETDEV_REGISTER || !(dev->priv_flags & IFF_EBRIDGE))
+		return NOTIFY_DONE;
+
+	ASSERT_RTNL();
+
+	net = dev_net(dev);
+	brnet = net_generic(net, brnf_net_id);
+	if (brnet->enabled)
+		return NOTIFY_OK;
+
+	ret = nf_register_net_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	if (ret)
+		return NOTIFY_BAD;
+
+	brnet->enabled = true;
+	return NOTIFY_OK;
+}
+
+static void __net_exit brnf_exit_net(struct net *net)
+{
+	struct brnf_net *brnet = net_generic(net, brnf_net_id);
+
+	if (!brnet->enabled)
+		return;
+
+	nf_unregister_net_hooks(net, br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	brnet->enabled = false;
+}
+
+static struct pernet_operations brnf_net_ops __read_mostly = {
+	.exit = brnf_exit_net,
+	.id   = &brnf_net_id,
+	.size = sizeof(struct brnf_net),
+};
+
+static struct notifier_block brnf_notifier __read_mostly = {
+	.notifier_call = brnf_device_event,
+};
+
 #ifdef CONFIG_SYSCTL
 static
 int brnf_sysctl_call_tables(struct ctl_table *ctl, int write,
@@ -1003,16 +1057,23 @@ static int __init br_netfilter_init(void)
 {
 	int ret;
 
-	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	ret = register_pernet_subsys(&brnf_net_ops);
 	if (ret < 0)
 		return ret;
 
+	ret = register_netdevice_notifier(&brnf_notifier);
+	if (ret < 0) {
+		unregister_pernet_subsys(&brnf_net_ops);
+		return ret;
+	}
+
 #ifdef CONFIG_SYSCTL
 	brnf_sysctl_header = register_net_sysctl(&init_net, "net/bridge", brnf_table);
 	if (brnf_sysctl_header == NULL) {
 		printk(KERN_WARNING
 		       "br_netfilter: can't register to sysctl.\n");
-		nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+		unregister_netdevice_notifier(&brnf_notifier);
+		unregister_pernet_subsys(&brnf_net_ops);
 		return -ENOMEM;
 	}
 #endif
@@ -1024,7 +1085,8 @@ static int __init br_netfilter_init(void)
 static void __exit br_netfilter_fini(void)
 {
 	RCU_INIT_POINTER(nf_br_ops, NULL);
-	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
+	unregister_netdevice_notifier(&brnf_notifier);
+	unregister_pernet_subsys(&brnf_net_ops);
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
 #endif
-- 
2.1.4

