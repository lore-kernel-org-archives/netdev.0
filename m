From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: [PATCH 1/1] net: ipv4: ipmr_expire_timer causes crash when removing
 net namespace
Date: Fri, 24 Aug 2012 10:38:35 -0700
Message-ID: <CA+HUmGhEaTD7QgYyfhDB22K1=Oj3RvDi2Ny217-YFXV03HJzqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:48361 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757287Ab2HXRig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:38:36 -0400
Received: by obbuo13 with SMTP id uo13so4754373obb.19
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2012 10:38:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When tearing down a net namespace, ipv4 mr_table structures are freed
without first deactivating their timers. This can result in a crash in
run_timer_softirq.
This patch mimics the corresponding behaviour in ipv6.
Locking and synchronization seem to be adequate.
We are about to kfree mrt, so existing code should already make sure that
no other references to mrt are pending or can be created by incoming traffic.
The functions invoked here do not cause new references to mrt or other
race conditions to be created.
Invoking del_timer_sync guarantees that ipmr_expire_timer is inactive.
Both ipmr_expire_process (whose completion we may have to wait in
del_timer_sync) and mroute_clean_tables internally use mfc_unres_lock
or other synchronizations when needed, and they both only modify mrt.

Tested in Linux 3.4.8.

Signed-off-by: Francesco Ruggeri <fruggeri@aristanetworks.com>

Index: linux-3.4.x86_64/net/ipv4/ipmr.c
===================================================================
--- linux-3.4.x86_64.orig/net/ipv4/ipmr.c
+++ linux-3.4.x86_64/net/ipv4/ipmr.c
@@ -124,6 +124,8 @@ static DEFINE_SPINLOCK(mfc_unres_lock);
 static struct kmem_cache *mrt_cachep __read_mostly;

 static struct mr_table *ipmr_new_table(struct net *net, u32 id);
+static void ipmr_free_table(struct mr_table *mrt);
+
 static int ip_mr_forward(struct net *net, struct mr_table *mrt,
 			 struct sk_buff *skb, struct mfc_cache *cache,
 			 int local);
@@ -131,6 +133,7 @@ static int ipmr_cache_report(struct mr_t
 			     struct sk_buff *pkt, vifi_t vifi, int assert);
 static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 			      struct mfc_cache *c, struct rtmsg *rtm);
+static void mroute_clean_tables(struct mr_table *mrt);
 static void ipmr_expire_process(unsigned long arg);

 #ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
@@ -271,7 +274,7 @@ static void __net_exit ipmr_rules_exit(s

 	list_for_each_entry_safe(mrt, next, &net->ipv4.mr_tables, list) {
 		list_del(&mrt->list);
-		kfree(mrt);
+		ipmr_free_table(mrt);
 	}
 	fib_rules_unregister(net->ipv4.mr_rules_ops);
 }
@@ -299,7 +302,7 @@ static int __net_init ipmr_rules_init(st

 static void __net_exit ipmr_rules_exit(struct net *net)
 {
-	kfree(net->ipv4.mrt);
+	ipmr_free_table(net->ipv4.mrt);
 }
 #endif

@@ -336,6 +339,13 @@ static struct mr_table *ipmr_new_table(s
 	return mrt;
 }

+static void ipmr_free_table(struct mr_table *mrt)
+{
+	del_timer_sync(&mrt->ipmr_expire_timer);
+	mroute_clean_tables(mrt);
+	kfree(mrt);
+}
+
 /* Service routines creating virtual interfaces: DVMRP tunnels and PIMREG */

 static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
