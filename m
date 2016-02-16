From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/6] netfilter: conntrack: resched in nf_ct_iterate_cleanup
Date: Tue, 16 Feb 2016 18:02:32 +0100
Message-ID: <1455642157-6864-2-git-send-email-pablo@netfilter.org>
References: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52921 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933039AbcBPRES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 12:04:18 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 38EB06EF46
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 26D391B3066
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:17 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9612B1D5D23
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:11 +0100 (CET)
In-Reply-To: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

Ulrich reports soft lockup with following (shortened) callchain:

NMI watchdog: BUG: soft lockup - CPU#1 stuck for 22s!
__netif_receive_skb_core+0x6e4/0x774
process_backlog+0x94/0x160
net_rx_action+0x88/0x178
call_do_softirq+0x24/0x3c
do_softirq+0x54/0x6c
__local_bh_enable_ip+0x7c/0xbc
nf_ct_iterate_cleanup+0x11c/0x22c [nf_conntrack]
masq_inet_event+0x20/0x30 [nf_nat_masquerade_ipv6]
atomic_notifier_call_chain+0x1c/0x2c
ipv6_del_addr+0x1bc/0x220 [ipv6]

Problem is that nf_ct_iterate_cleanup can run for a very long time
since it can be interrupted by softirq processing.
Moreover, atomic_notifier_call_chain runs with rcu readlock held.

So lets call cond_resched() in nf_ct_iterate_cleanup and defer
the call to a work queue for the atomic_notifier_call_chain case.

We also need another cond_resched in get_next_corpse, since we
have to deal with iter() always returning false, in that case
get_next_corpse will walk entire conntrack table.

Reported-by: Ulrich Weber <uw@ocedo.com>
Tested-by: Ulrich Weber <uw@ocedo.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/nf_nat_masquerade_ipv6.c | 74 +++++++++++++++++++++++++++--
 net/netfilter/nf_conntrack_core.c           |  5 ++
 2 files changed, 76 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
index 31ba7ca..051b6a6 100644
--- a/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_masquerade_ipv6.c
@@ -21,6 +21,10 @@
 #include <net/ipv6.h>
 #include <net/netfilter/ipv6/nf_nat_masquerade.h>
 
+#define MAX_WORK_COUNT	16
+
+static atomic_t v6_worker_count;
+
 unsigned int
 nf_nat_masquerade_ipv6(struct sk_buff *skb, const struct nf_nat_range *range,
 		       const struct net_device *out)
@@ -78,14 +82,78 @@ static struct notifier_block masq_dev_notifier = {
 	.notifier_call	= masq_device_event,
 };
 
+struct masq_dev_work {
+	struct work_struct work;
+	struct net *net;
+	int ifindex;
+};
+
+static void iterate_cleanup_work(struct work_struct *work)
+{
+	struct masq_dev_work *w;
+	long index;
+
+	w = container_of(work, struct masq_dev_work, work);
+
+	index = w->ifindex;
+	nf_ct_iterate_cleanup(w->net, device_cmp, (void *)index, 0, 0);
+
+	put_net(w->net);
+	kfree(w);
+	atomic_dec(&v6_worker_count);
+	module_put(THIS_MODULE);
+}
+
+/* ipv6 inet notifier is an atomic notifier, i.e. we cannot
+ * schedule.
+ *
+ * Unfortunately, nf_ct_iterate_cleanup can run for a long
+ * time if there are lots of conntracks and the system
+ * handles high softirq load, so it frequently calls cond_resched
+ * while iterating the conntrack table.
+ *
+ * So we defer nf_ct_iterate_cleanup walk to the system workqueue.
+ *
+ * As we can have 'a lot' of inet_events (depending on amount
+ * of ipv6 addresses being deleted), we also need to add an upper
+ * limit to the number of queued work items.
+ */
 static int masq_inet_event(struct notifier_block *this,
 			   unsigned long event, void *ptr)
 {
 	struct inet6_ifaddr *ifa = ptr;
-	struct netdev_notifier_info info;
+	const struct net_device *dev;
+	struct masq_dev_work *w;
+	struct net *net;
+
+	if (event != NETDEV_DOWN ||
+	    atomic_read(&v6_worker_count) >= MAX_WORK_COUNT)
+		return NOTIFY_DONE;
+
+	dev = ifa->idev->dev;
+	net = maybe_get_net(dev_net(dev));
+	if (!net)
+		return NOTIFY_DONE;
 
-	netdev_notifier_info_init(&info, ifa->idev->dev);
-	return masq_device_event(this, event, &info);
+	if (!try_module_get(THIS_MODULE))
+		goto err_module;
+
+	w = kmalloc(sizeof(*w), GFP_ATOMIC);
+	if (w) {
+		atomic_inc(&v6_worker_count);
+
+		INIT_WORK(&w->work, iterate_cleanup_work);
+		w->ifindex = dev->ifindex;
+		w->net = net;
+		schedule_work(&w->work);
+
+		return NOTIFY_DONE;
+	}
+
+	module_put(THIS_MODULE);
+ err_module:
+	put_net(net);
+	return NOTIFY_DONE;
 }
 
 static struct notifier_block masq_inet_notifier = {
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 58882de..f60b4fd 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1412,6 +1412,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 		}
 		spin_unlock(lockp);
 		local_bh_enable();
+		cond_resched();
 	}
 
 	for_each_possible_cpu(cpu) {
@@ -1424,6 +1425,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 				set_bit(IPS_DYING_BIT, &ct->status);
 		}
 		spin_unlock_bh(&pcpu->lock);
+		cond_resched();
 	}
 	return NULL;
 found:
@@ -1440,6 +1442,8 @@ void nf_ct_iterate_cleanup(struct net *net,
 	struct nf_conn *ct;
 	unsigned int bucket = 0;
 
+	might_sleep();
+
 	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
 		/* Time to push up daises... */
 		if (del_timer(&ct->timeout))
@@ -1448,6 +1452,7 @@ void nf_ct_iterate_cleanup(struct net *net,
 		/* ... else the timer will get him soon. */
 
 		nf_ct_put(ct);
+		cond_resched();
 	}
 }
 EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup);
-- 
2.1.4
