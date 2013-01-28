From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] pktgen: support net namespace
Date: Mon, 28 Jan 2013 14:32:55 +0800
Message-ID: <1359354775-28344-1-git-send-email-amwang@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099Ab3A1GdJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 01:33:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This patch add net namespace to pktgen, so that
we can use pktgen in different namespaces.

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 net/core/pktgen.c |  132 +++++++++++++++++++++++++++++++++++------------------
 1 files changed, 87 insertions(+), 45 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index b29dacf..b6be493 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -164,6 +164,7 @@
 #ifdef CONFIG_XFRM
 #include <net/xfrm.h>
 #endif
+#include <net/netns/generic.h>
 #include <asm/byteorder.h>
 #include <linux/rcupdate.h>
 #include <linux/bitops.h>
@@ -212,7 +213,6 @@
 #define PKTGEN_MAGIC 0xbe9be955
 #define PG_PROC_DIR "pktgen"
 #define PGCTRL	    "pgctrl"
-static struct proc_dir_entry *pg_proc_dir;
 
 #define MAX_CFLOWS  65536
 
@@ -414,6 +414,15 @@ struct pktgen_thread {
 
 	wait_queue_head_t queue;
 	struct completion start_done;
+	struct pktgen_net *net;
+};
+
+static int pg_net_id __read_mostly;
+
+struct pktgen_net {
+	struct net		*net;
+	struct net_device	*dev;
+	struct proc_dir_entry	*proc_dir;
 };
 
 #define REMOVE 1
@@ -1886,15 +1895,16 @@ static void pktgen_change_name(struct net_device *dev)
 
 	list_for_each_entry(t, &pktgen_threads, th_list) {
 		struct pktgen_dev *pkt_dev;
+		struct pktgen_net *pn = t->net;
 
 		list_for_each_entry(pkt_dev, &t->if_list, list) {
 			if (pkt_dev->odev != dev)
 				continue;
 
-			remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
+			remove_proc_entry(pkt_dev->entry->name, pn->proc_dir);
 
 			pkt_dev->entry = proc_create_data(dev->name, 0600,
-							  pg_proc_dir,
+							  pn->proc_dir,
 							  &pktgen_if_fops,
 							  pkt_dev);
 			if (!pkt_dev->entry)
@@ -1909,8 +1919,9 @@ static int pktgen_device_event(struct notifier_block *unused,
 			       unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
+	struct pktgen_net *pn = net_generic(dev_net(dev), pg_net_id);
 
-	if (!net_eq(dev_net(dev), &init_net) || pktgen_exiting)
+	if (pn->dev != dev || pktgen_exiting)
 		return NOTIFY_DONE;
 
 	/* It is OK that we do not hold the group lock right now,
@@ -1930,7 +1941,8 @@ static int pktgen_device_event(struct notifier_block *unused,
 	return NOTIFY_DONE;
 }
 
-static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev,
+static struct net_device *pktgen_dev_get_by_name(const struct pktgen_net *pn,
+						 struct pktgen_dev *pkt_dev,
 						 const char *ifname)
 {
 	char b[IFNAMSIZ+5];
@@ -1944,13 +1956,14 @@ static struct net_device *pktgen_dev_get_by_name(struct pktgen_dev *pkt_dev,
 	}
 	b[i] = 0;
 
-	return dev_get_by_name(&init_net, b);
+	return dev_get_by_name(pn->net, b);
 }
 
 
 /* Associate pktgen_dev with a device. */
 
-static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
+static int pktgen_setup_dev(const struct pktgen_net *pn,
+			    struct pktgen_dev *pkt_dev, const char *ifname)
 {
 	struct net_device *odev;
 	int err;
@@ -1961,7 +1974,7 @@ static int pktgen_setup_dev(struct pktgen_dev *pkt_dev, const char *ifname)
 		pkt_dev->odev = NULL;
 	}
 
-	odev = pktgen_dev_get_by_name(pkt_dev, ifname);
+	odev = pktgen_dev_get_by_name(pn, pkt_dev, ifname);
 	if (!odev) {
 		pr_err("no such netdevice: \"%s\"\n", ifname);
 		return -ENODEV;
@@ -2203,9 +2216,10 @@ static inline int f_pick(struct pktgen_dev *pkt_dev)
 static void get_ipsec_sa(struct pktgen_dev *pkt_dev, int flow)
 {
 	struct xfrm_state *x = pkt_dev->flows[flow].x;
+	struct pktgen_net *pn = net_generic(dev_net(pkt_dev->odev), pg_net_id);
 	if (!x) {
 		/*slow path: we dont already have xfrm_state*/
-		x = xfrm_stateonly_find(&init_net, DUMMY_MARK,
+		x = xfrm_stateonly_find(pn->net, DUMMY_MARK,
 					(xfrm_address_t *)&pkt_dev->cur_daddr,
 					(xfrm_address_t *)&pkt_dev->cur_saddr,
 					AF_INET,
@@ -3154,9 +3168,7 @@ static void pktgen_rem_all_ifs(struct pktgen_thread *t)
 static void pktgen_rem_thread(struct pktgen_thread *t)
 {
 	/* Remove from the thread list */
-
-	remove_proc_entry(t->tsk->comm, pg_proc_dir);
-
+	remove_proc_entry(t->tsk->comm, t->net->proc_dir);
 }
 
 static void pktgen_resched(struct pktgen_dev *pkt_dev)
@@ -3459,13 +3471,14 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 	pkt_dev->svlan_id = 0xffff;
 	pkt_dev->node = -1;
 
-	err = pktgen_setup_dev(pkt_dev, ifname);
+	err = pktgen_setup_dev(t->net, pkt_dev, ifname);
 	if (err)
 		goto out1;
 	if (pkt_dev->odev->priv_flags & IFF_TX_SKB_SHARING)
 		pkt_dev->clone_skb = pg_clone_skb_d;
 
-	pkt_dev->entry = proc_create_data(ifname, 0600, pg_proc_dir,
+	t->net->dev = pkt_dev->odev;
+	pkt_dev->entry = proc_create_data(ifname, 0600, t->net->proc_dir,
 					  &pktgen_if_fops, pkt_dev);
 	if (!pkt_dev->entry) {
 		pr_err("cannot create %s/%s procfs entry\n",
@@ -3490,7 +3503,7 @@ out1:
 	return err;
 }
 
-static int __init pktgen_create_thread(int cpu)
+static int __net_init pktgen_create_thread(int cpu, struct pktgen_net *pn)
 {
 	struct pktgen_thread *t;
 	struct proc_dir_entry *pe;
@@ -3524,7 +3537,7 @@ static int __init pktgen_create_thread(int cpu)
 	kthread_bind(p, cpu);
 	t->tsk = p;
 
-	pe = proc_create_data(t->tsk->comm, 0600, pg_proc_dir,
+	pe = proc_create_data(t->tsk->comm, 0600, pn->proc_dir,
 			      &pktgen_thread_fops, t);
 	if (!pe) {
 		pr_err("cannot create %s/%s procfs entry\n",
@@ -3535,6 +3548,7 @@ static int __init pktgen_create_thread(int cpu)
 		return -EINVAL;
 	}
 
+	t->net = pn;
 	wake_up_process(p);
 	wait_for_completion(&t->start_done);
 
@@ -3560,6 +3574,7 @@ static void _rem_dev_from_if_list(struct pktgen_thread *t,
 static int pktgen_remove_device(struct pktgen_thread *t,
 				struct pktgen_dev *pkt_dev)
 {
+	struct pktgen_net *pn = t->net;
 
 	pr_debug("remove_device pkt_dev=%p\n", pkt_dev);
 
@@ -3580,7 +3595,7 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	_rem_dev_from_if_list(t, pkt_dev);
 
 	if (pkt_dev->entry)
-		remove_proc_entry(pkt_dev->entry->name, pg_proc_dir);
+		remove_proc_entry(pkt_dev->entry->name, pn->proc_dir);
 
 #ifdef CONFIG_XFRM
 	free_SAs(pkt_dev);
@@ -3592,49 +3607,78 @@ static int pktgen_remove_device(struct pktgen_thread *t,
 	return 0;
 }
 
-static int __init pg_init(void)
+static int __net_init pg_net_init(struct net *net)
 {
-	int cpu;
-	struct proc_dir_entry *pe;
-	int ret = 0;
-
-	pr_info("%s", version);
+	struct pktgen_net *pn = net_generic(net, pg_net_id);
+	int cpu, ret = 0;
 
-	pg_proc_dir = proc_mkdir(PG_PROC_DIR, init_net.proc_net);
-	if (!pg_proc_dir)
-		return -ENODEV;
+	pn->net = net;
+	if (!pn->proc_dir) {
+		struct proc_dir_entry *pe;
+		pn->proc_dir = proc_mkdir(PG_PROC_DIR, pn->net->proc_net);
+		if (!pn->proc_dir) {
+			pr_warn("cannot create /proc/net/%s\n", PG_PROC_DIR);
+			return -ENODEV;
+		}
+		pe = proc_create(PGCTRL, 0600, pn->proc_dir, &pktgen_fops);
+		if (pe == NULL) {
+			pr_err("cannot create %s procfs entry\n", PGCTRL);
+			ret = -EINVAL;
+			goto remove;
+		}
 
-	pe = proc_create(PGCTRL, 0600, pg_proc_dir, &pktgen_fops);
-	if (pe == NULL) {
-		pr_err("ERROR: cannot create %s procfs entry\n", PGCTRL);
-		ret = -EINVAL;
-		goto remove_dir;
 	}
 
-	register_netdevice_notifier(&pktgen_notifier_block);
-
 	for_each_online_cpu(cpu) {
 		int err;
 
-		err = pktgen_create_thread(cpu);
+		err = pktgen_create_thread(cpu, pn);
 		if (err)
-			pr_warning("WARNING: Cannot create thread for cpu %d (%d)\n",
+			pr_warn("Cannot create thread for cpu %d (%d)\n",
 				   cpu, err);
 	}
 
 	if (list_empty(&pktgen_threads)) {
-		pr_err("ERROR: Initialization failed for all threads\n");
+		pr_err("Initialization failed for all threads\n");
 		ret = -ENODEV;
-		goto unregister;
+		goto remove_entry;
 	}
 
 	return 0;
 
- unregister:
-	unregister_netdevice_notifier(&pktgen_notifier_block);
-	remove_proc_entry(PGCTRL, pg_proc_dir);
- remove_dir:
-	proc_net_remove(&init_net, PG_PROC_DIR);
+remove_entry:
+	remove_proc_entry(PGCTRL, pn->proc_dir);
+remove:
+	proc_net_remove(pn->net, PG_PROC_DIR);
+	return ret;
+}
+
+static void __net_exit pg_net_exit(struct net *net)
+{
+	struct pktgen_net *pn = net_generic(net, pg_net_id);
+	remove_proc_entry(PGCTRL, pn->proc_dir);
+	proc_net_remove(pn->net, PG_PROC_DIR);
+}
+
+static struct pernet_operations pg_net_ops = {
+	.init = pg_net_init,
+	.exit = pg_net_exit,
+	.id   = &pg_net_id,
+	.size = sizeof(struct pktgen_net),
+};
+
+static int __init pg_init(void)
+{
+	int ret = 0;
+
+	pr_info("%s", version);
+	ret = register_pernet_subsys(&pg_net_ops);
+	if (ret)
+		return ret;
+	ret = register_netdevice_notifier(&pktgen_notifier_block);
+	if (ret)
+		unregister_pernet_subsys(&pg_net_ops);
+
 	return ret;
 }
 
@@ -3661,9 +3705,7 @@ static void __exit pg_cleanup(void)
 	/* Un-register us from receiving netdevice events */
 	unregister_netdevice_notifier(&pktgen_notifier_block);
 
-	/* Clean up proc file system */
-	remove_proc_entry(PGCTRL, pg_proc_dir);
-	proc_net_remove(&init_net, PG_PROC_DIR);
+	unregister_pernet_subsys(&pg_net_ops);
 }
 
 module_init(pg_init);
