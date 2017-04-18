From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next RFC] net: sched: mirred: move xmit to tasklet
Date: Tue, 18 Apr 2017 15:03:31 +0200
Message-ID: <20170418130331.14268-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:36254 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752802AbdDRNDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 09:03:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mirred is prone to deadlocks as it invokes dev_queue_xmit while
holding one or more qdisc locks.

Avoid lock recursions by moving tx context to a tasklet.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 This a stab at removing the lock recursions discussed during netconf.

 Taking the cost of the tasklet appears to be the only solution;
 i tried to use a percpu 'history' instead but its not clear to
 me that this avoids all corner cases.

 While this patch doesn't avoid loops we don't hang the kernel
 anymore and removing the 'looping' filter makes things calm
 down again (there are also other ways to create such loops anyway,
 including use of a cable... )

diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 1b5549ababd4..3dd61eba4741 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -17,6 +17,7 @@
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
+#include <linux/skb_array.h>
 #include <linux/rtnetlink.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -25,10 +26,19 @@
 #include <net/net_namespace.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
+#include <net/dst.h>
 #include <linux/tc_act/tc_mirred.h>
 #include <net/tc_act/tc_mirred.h>
 
+#define MIRRED_TXLEN	  512
 #define MIRRED_TAB_MASK     7
+
+struct mirred_tx_data {
+	struct tasklet_struct   mirred_tasklet;
+	struct skb_array	skb_array;
+};
+
+static DEFINE_PER_CPU(struct mirred_tx_data, mirred_tx_data);
 static LIST_HEAD(mirred_list);
 static DEFINE_SPINLOCK(mirred_list_lock);
 
@@ -158,6 +168,44 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	return ret;
 }
 
+static void mirred_tasklet(unsigned long data)
+{
+	struct mirred_tx_data *d = (void *)data;
+	struct sk_buff *skb;
+	int i;
+
+	for (i = 0; i < MIRRED_TXLEN; i++) {
+		struct net_device *dev;
+
+		skb = skb_array_consume(&d->skb_array);
+		if (!skb)
+			return;
+
+		dev = skb->dev;
+		dev_queue_xmit(skb);
+		dev_put(dev);
+	}
+
+	tasklet_schedule(&d->mirred_tasklet);
+}
+
+static int mirred_xmit(struct sk_buff *skb)
+{
+	struct mirred_tx_data *d = this_cpu_ptr(&mirred_tx_data);
+
+	skb_dst_force(skb);
+	dev_hold(skb->dev);
+
+	if (skb_array_produce_bh(&d->skb_array, skb)) {
+		dev_put(skb->dev);
+		kfree_skb(skb);
+		return -ENOBUFS;
+	}
+
+	tasklet_schedule(&d->mirred_tasklet);
+	return 0;
+}
+
 static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 		      struct tcf_result *res)
 {
@@ -217,7 +265,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 	skb2->skb_iif = skb->dev->ifindex;
 	skb2->dev = dev;
 	if (!tcf_mirred_act_wants_ingress(m_eaction))
-		err = dev_queue_xmit(skb2);
+		err = mirred_xmit(skb2);
 	else
 		err = netif_receive_skb(skb2);
 
@@ -365,20 +413,66 @@ MODULE_AUTHOR("Jamal Hadi Salim(2002)");
 MODULE_DESCRIPTION("Device Mirror/redirect actions");
 MODULE_LICENSE("GPL");
 
+static void mirred_cleanup_pcpu(void)
+{
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct mirred_tx_data *data;
+
+		data = per_cpu_ptr(&mirred_tx_data, cpu);
+
+		skb_array_cleanup(&data->skb_array);
+		tasklet_kill(&data->mirred_tasklet);
+	}
+}
+
 static int __init mirred_init_module(void)
 {
-	int err = register_netdevice_notifier(&mirred_device_notifier);
-	if (err)
+	int cpu, err;
+
+	for_each_possible_cpu(cpu) {
+		struct mirred_tx_data *data;
+
+		data = per_cpu_ptr(&mirred_tx_data, cpu);
+
+		tasklet_init(&data->mirred_tasklet, mirred_tasklet,
+			     (unsigned long)data);
+		err = skb_array_init(&data->skb_array, MIRRED_TXLEN, GFP_KERNEL);
+		if (err) {
+			unregister_netdevice_notifier(&mirred_device_notifier);
+
+			while (cpu) {
+				data = per_cpu_ptr(&mirred_tx_data, --cpu);
+				skb_array_cleanup(&data->skb_array);
+			}
+
+			return err;
+		}
+	}
+
+	err = register_netdevice_notifier(&mirred_device_notifier);
+	if (err) {
+		mirred_cleanup_pcpu();
+		return err;
+	}
+
+	err = tcf_register_action(&act_mirred_ops, &mirred_net_ops);
+	if (err) {
+		unregister_netdevice_notifier(&mirred_device_notifier);
+		mirred_cleanup_pcpu();
 		return err;
+	}
 
 	pr_info("Mirror/redirect action on\n");
-	return tcf_register_action(&act_mirred_ops, &mirred_net_ops);
+	return 0;
 }
 
 static void __exit mirred_cleanup_module(void)
 {
 	tcf_unregister_action(&act_mirred_ops, &mirred_net_ops);
 	unregister_netdevice_notifier(&mirred_device_notifier);
+	mirred_cleanup_pcpu();
 }
 
 module_init(mirred_init_module);
-- 
2.10.2
