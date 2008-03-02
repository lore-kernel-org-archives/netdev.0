From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 04/11][NETNS][IPV6] ip6_fib - add net to gc timer parameter
Date: Sun, 02 Mar 2008 10:37:24 +0100
Message-ID: <20080302094153.627158693@mai.toulouse-stg.fr.ibm.com>
References: <20080302093720.649869114@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:23280 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbYCBJoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 04:44:04 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.8/8.13.8) with ESMTP id m229i3J1194224
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 09:44:03 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m229i3kw536600
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:03 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m229i2v4021727
	for <netdev@vger.kernel.org>; Sun, 2 Mar 2008 10:44:03 +0100
Content-Disposition: inline; filename=04_11-ip6-fib-add-net-to-gc-timer-parameter.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fib tables are now relative to the network namespace. When the 
garbage collector timer expires, we must have a network namespace 
parameter in order to retrieve the tables. For now this is the 
init_net, but we should be able to have a timer per namespace and 
use the timer callback parameter to pass the network namespace from 
the expired timer.

The timer callback, fib6_run_gc, is actually used to be called 
synchronously by some functions and asynchronously when the timer 
expires.

When the timer expires, the delay specified for fib6_run_gc parameter
is always zero. So, I changed fib6_run_gc to not be a timer callback
but a function called by the timer callback and I added a timer callback
where its work is just to retrieve from the data arg of the timer the 
network namespace and call fib6_run_gc with zero expiring time and
the network namespace parameters. That makes the code cleaner for the
fib6_run_gc callers.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 include/net/ip6_fib.h |    3 ++-
 net/ipv6/ip6_fib.c    |   24 ++++++++++++++++--------
 net/ipv6/ndisc.c      |    5 +++--
 net/ipv6/route.c      |    8 +++++---
 4 files changed, 26 insertions(+), 14 deletions(-)

Index: net-2.6.26/net/ipv6/ip6_fib.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ip6_fib.c
+++ net-2.6.26/net/ipv6/ip6_fib.c
@@ -93,7 +93,10 @@ static int fib6_walk_continue(struct fib
 
 static __u32 rt_sernum;
 
-static DEFINE_TIMER(ip6_fib_timer, fib6_run_gc, 0, 0);
+static void fib6_gc_timer_cb(unsigned long arg);
+
+static DEFINE_TIMER(ip6_fib_timer, fib6_gc_timer_cb, 0,
+		    (unsigned long)&init_net);
 
 static struct fib6_walker_t fib6_walker_list = {
 	.prev	= &fib6_walker_list,
@@ -1432,12 +1435,12 @@ static int fib6_age(struct rt6_info *rt,
 
 static DEFINE_SPINLOCK(fib6_gc_lock);
 
-void fib6_run_gc(unsigned long dummy)
+void fib6_run_gc(unsigned long expires, struct net *net)
 {
-	if (dummy != ~0UL) {
+	if (expires != ~0UL) {
 		spin_lock_bh(&fib6_gc_lock);
-		gc_args.timeout = dummy ? (int)dummy :
-			init_net.ipv6.sysctl.ip6_rt_gc_interval;
+		gc_args.timeout = expires ? (int)expires :
+			net->ipv6.sysctl.ip6_rt_gc_interval;
 	} else {
 		local_bh_disable();
 		if (!spin_trylock(&fib6_gc_lock)) {
@@ -1445,17 +1448,17 @@ void fib6_run_gc(unsigned long dummy)
 			local_bh_enable();
 			return;
 		}
-		gc_args.timeout = init_net.ipv6.sysctl.ip6_rt_gc_interval;
+		gc_args.timeout = net->ipv6.sysctl.ip6_rt_gc_interval;
 	}
 	gc_args.more = 0;
 
 	ndisc_dst_gc(&gc_args.more);
 
-	fib6_clean_all(&init_net, fib6_age, 0, NULL);
+	fib6_clean_all(net, fib6_age, 0, NULL);
 
 	if (gc_args.more)
 		mod_timer(&ip6_fib_timer, jiffies +
-			  init_net.ipv6.sysctl.ip6_rt_gc_interval);
+			  net->ipv6.sysctl.ip6_rt_gc_interval);
 	else {
 		del_timer(&ip6_fib_timer);
 		ip6_fib_timer.expires = 0;
@@ -1463,6 +1466,11 @@ void fib6_run_gc(unsigned long dummy)
 	spin_unlock_bh(&fib6_gc_lock);
 }
 
+static void fib6_gc_timer_cb(unsigned long arg)
+{
+	fib6_run_gc(0, (struct net *)arg);
+}
+
 static int fib6_net_init(struct net *net)
 {
 	int ret;
Index: net-2.6.26/include/net/ip6_fib.h
===================================================================
--- net-2.6.26.orig/include/net/ip6_fib.h
+++ net-2.6.26/include/net/ip6_fib.h
@@ -209,7 +209,8 @@ extern int			fib6_del(struct rt6_info *r
 extern void			inet6_rt_notify(int event, struct rt6_info *rt,
 						struct nl_info *info);
 
-extern void			fib6_run_gc(unsigned long dummy);
+extern void			fib6_run_gc(unsigned long expires,
+					    struct net *net);
 
 extern void			fib6_gc_cleanup(void);
 
Index: net-2.6.26/net/ipv6/ndisc.c
===================================================================
--- net-2.6.26.orig/net/ipv6/ndisc.c
+++ net-2.6.26/net/ipv6/ndisc.c
@@ -1613,6 +1613,7 @@ int ndisc_rcv(struct sk_buff *skb)
 static int ndisc_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
 {
 	struct net_device *dev = ptr;
+	struct net *net = dev->nd_net;
 
 	if (dev->nd_net != &init_net)
 		return NOTIFY_DONE;
@@ -1620,11 +1621,11 @@ static int ndisc_netdev_event(struct not
 	switch (event) {
 	case NETDEV_CHANGEADDR:
 		neigh_changeaddr(&nd_tbl, dev);
-		fib6_run_gc(~0UL);
+		fib6_run_gc(~0UL, net);
 		break;
 	case NETDEV_DOWN:
 		neigh_ifdown(&nd_tbl, dev);
-		fib6_run_gc(~0UL);
+		fib6_run_gc(~0UL, net);
 		break;
 	default:
 		break;
Index: net-2.6.26/net/ipv6/route.c
===================================================================
--- net-2.6.26.orig/net/ipv6/route.c
+++ net-2.6.26/net/ipv6/route.c
@@ -40,6 +40,7 @@
 #include <linux/if_arp.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
+#include <linux/nsproxy.h>
 #include <net/net_namespace.h>
 #include <net/snmp.h>
 #include <net/ipv6.h>
@@ -996,7 +997,7 @@ static int ip6_dst_gc(struct dst_ops *op
 		goto out;
 
 	expire++;
-	fib6_run_gc(expire);
+	fib6_run_gc(expire, &init_net);
 	last_gc = now;
 	if (atomic_read(&ip6_dst_ops.entries) < ip6_dst_ops.gc_thresh)
 		expire = init_net.ipv6.sysctl.ip6_rt_gc_timeout>>1;
@@ -2413,10 +2414,11 @@ static
 int ipv6_sysctl_rtcache_flush(ctl_table *ctl, int write, struct file * filp,
 			      void __user *buffer, size_t *lenp, loff_t *ppos)
 {
-	int delay = init_net.ipv6.sysctl.flush_delay;
+	struct net *net = current->nsproxy->net_ns;
+	int delay = net->ipv6.sysctl.flush_delay;
 	if (write) {
 		proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
-		fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay);
+		fib6_run_gc(delay <= 0 ? ~0UL : (unsigned long)delay, net);
 		return 0;
 	} else
 		return -EINVAL;

-- 
