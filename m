From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: mirred, redirect action vs. dev refcount issue
Date: Thu, 22 Jul 2010 10:42:56 -0700
Message-ID: <20100722104256.5a7e7cb6@nehalam>
References: <20100721162426.5aa4b646@nehalam>
	<20100721.163955.12041610.davem@davemloft.net>
	<20100721165247.6d1dd879@nehalam>
	<20100721.165802.111593910.davem@davemloft.net>
	<20100721170024.60cd9ef4@nehalam>
	<1279793481.2747.39.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39274 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260Ab0GVRm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 13:42:59 -0400
In-Reply-To: <1279793481.2747.39.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is what I am testing now.

--- a/include/net/tc_act/tc_mirred.h	2010-07-22 09:17:41.631561924 -0700
+++ b/include/net/tc_act/tc_mirred.h	2010-07-22 09:49:53.355325645 -0700
@@ -9,6 +9,7 @@ struct tcf_mirred {
 	int			tcfm_ifindex;
 	int			tcfm_ok_push;
 	struct net_device	*tcfm_dev;
+	struct list_head	tcfm_list;
 };
 #define to_mirred(pc) \
 	container_of(pc, struct tcf_mirred, common)
--- a/net/sched/act_mirred.c	2010-07-21 16:10:48.922308036 -0700
+++ b/net/sched/act_mirred.c	2010-07-22 09:52:32.229910928 -0700
@@ -1,3 +1,4 @@
+
 /*
  * net/sched/mirred.c	packet mirroring and redirect actions
  *
@@ -21,6 +22,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/gfp.h>
+#include <linux/notifier.h>
 #include <net/net_namespace.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
@@ -33,6 +35,7 @@
 static struct tcf_common *tcf_mirred_ht[MIRRED_TAB_MASK + 1];
 static u32 mirred_idx_gen;
 static DEFINE_RWLOCK(mirred_lock);
+static LIST_HEAD(mirred_list);
 
 static struct tcf_hashinfo mirred_hash_info = {
 	.htab	=	tcf_mirred_ht,
@@ -47,7 +50,10 @@ static inline int tcf_mirred_release(str
 			m->tcf_bindcnt--;
 		m->tcf_refcnt--;
 		if(!m->tcf_bindcnt && m->tcf_refcnt <= 0) {
-			dev_put(m->tcfm_dev);
+			ASSERT_RTNL();
+			list_del(&m->tcfm_list);
+			if (m->tcfm_dev)
+				dev_put(m->tcfm_dev);
 			tcf_hash_destroy(&m->common, &mirred_hash_info);
 			return 1;
 		}
@@ -134,8 +140,11 @@ static int tcf_mirred_init(struct nlattr
 		m->tcfm_ok_push = ok_push;
 	}
 	spin_unlock_bh(&m->tcf_lock);
-	if (ret == ACT_P_CREATED)
+	if (ret == ACT_P_CREATED) {
+		ASSERT_RTNL();
+		list_add(&m->tcfm_list, &mirred_list);
 		tcf_hash_insert(pc, &mirred_hash_info);
+	}
 
 	return ret;
 }
@@ -164,9 +173,14 @@ static int tcf_mirred(struct sk_buff *sk
 	m->tcf_bstats.packets++;
 
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
@@ -230,6 +244,28 @@ nla_put_failure:
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
@@ -250,12 +286,17 @@ MODULE_LICENSE("GPL");
 
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
 
