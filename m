From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] net sched: fix race in mirred device removal
Date: Thu, 22 Jul 2010 21:45:04 -0700
Message-ID: <20100722214504.42e0e7de@nehalam>
References: <20100721162426.5aa4b646@nehalam>
	<20100721.163955.12041610.davem@davemloft.net>
	<20100721165247.6d1dd879@nehalam>
	<20100721.165802.111593910.davem@davemloft.net>
	<20100721170024.60cd9ef4@nehalam>
	<1279793481.2747.39.camel@bigi>
	<20100722104256.5a7e7cb6@nehalam>
	<1279821733.3808.0.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37960 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008Ab0GWEpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 00:45:08 -0400
In-Reply-To: <1279821733.3808.0.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes hang when target device of mirred packet classifier
action is removed.

If a mirror or redirection action is configured to cause packets
to go to another device, the classifier holds a ref count, but was assuming
the adminstrator cleaned up all redirections before removing. The fix
is to add a notifier and cleanup during unregister.

The new list is implicitly protected by RTNL mutex because
it is held during filter add/delete as well as notifier.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
Patch is against 2.6.35-rc6 (not net-next)

--- a/include/net/tc_act/tc_mirred.h	2010-07-22 21:32:40.944000510 -0700
+++ b/include/net/tc_act/tc_mirred.h	2010-07-22 21:32:44.280173100 -0700
@@ -9,6 +9,7 @@ struct tcf_mirred {
 	int			tcfm_ifindex;
 	int			tcfm_ok_push;
 	struct net_device	*tcfm_dev;
+	struct list_head	tcfm_list;
 };
 #define to_mirred(pc) \
 	container_of(pc, struct tcf_mirred, common)
--- a/net/sched/act_mirred.c	2010-07-22 21:32:40.927999682 -0700
+++ b/net/sched/act_mirred.c	2010-07-22 21:42:22.356826443 -0700
@@ -33,6 +33,7 @@
 static struct tcf_common *tcf_mirred_ht[MIRRED_TAB_MASK + 1];
 static u32 mirred_idx_gen;
 static DEFINE_RWLOCK(mirred_lock);
+static LIST_HEAD(mirred_list);
 
 static struct tcf_hashinfo mirred_hash_info = {
 	.htab	=	tcf_mirred_ht,
@@ -47,7 +48,9 @@ static inline int tcf_mirred_release(str
 			m->tcf_bindcnt--;
 		m->tcf_refcnt--;
 		if(!m->tcf_bindcnt && m->tcf_refcnt <= 0) {
-			dev_put(m->tcfm_dev);
+			list_del(&m->tcfm_list);
+			if (m->tcfm_dev)
+				dev_put(m->tcfm_dev);
 			tcf_hash_destroy(&m->common, &mirred_hash_info);
 			return 1;
 		}
@@ -134,8 +137,10 @@ static int tcf_mirred_init(struct nlattr
 		m->tcfm_ok_push = ok_push;
 	}
 	spin_unlock_bh(&m->tcf_lock);
-	if (ret == ACT_P_CREATED)
+	if (ret == ACT_P_CREATED) {
+		list_add(&m->tcfm_list, &mirred_list);
 		tcf_hash_insert(pc, &mirred_hash_info);
+	}
 
 	return ret;
 }
@@ -162,9 +167,14 @@ static int tcf_mirred(struct sk_buff *sk
 	m->tcf_tm.lastuse = jiffies;
 
 	dev = m->tcfm_dev;
+	if (!dev) {
+		printk_once(KERN_NOTICE "tc mirred: target device is gone\n");
+		goto out;
+	}
+
 	if (!(dev->flags & IFF_UP)) {
 		if (net_ratelimit())
-			pr_notice("tc mirred to Houston: device %s is gone!\n",
+			pr_notice("tc mirred to Houston: device %s is down\n",
 				  dev->name);
 		goto out;
 	}
@@ -232,6 +242,28 @@ nla_put_failure:
 	return -1;
 }
 
+static int mirred_device_event(struct notifier_block *unused,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct tcf_mirred *m;
+
+	if (event == NETDEV_UNREGISTER)
+		list_for_each_entry(m, &mirred_list, tcfm_list) {
+			if (m->tcfm_dev == dev) {
+				dev_put(dev);
+				m->tcfm_dev = NULL;
+			}
+		}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block mirred_device_notifier = {
+	.notifier_call = mirred_device_event,
+};
+
+
 static struct tc_action_ops act_mirred_ops = {
 	.kind		=	"mirred",
 	.hinfo		=	&mirred_hash_info,
@@ -252,12 +284,17 @@ MODULE_LICENSE("GPL");
 
 static int __init mirred_init_module(void)
 {
+	int err = register_netdevice_notifier(&mirred_device_notifier);
+	if (err)
+		return err;
+
 	pr_info("Mirror/redirect action on\n");
 	return tcf_register_action(&act_mirred_ops);
 }
 
 static void __exit mirred_cleanup_module(void)
 {
+	unregister_netdevice_notifier(&mirred_device_notifier);
 	tcf_unregister_action(&act_mirred_ops);
 }
 
