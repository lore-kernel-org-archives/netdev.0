From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] atm: clip causes unregister hang
Date: Wed, 12 Apr 2006 14:52:54 -0700
Message-ID: <20060412145254.4dd21be6@localhost.localdomain>
References: <20060412105545.3b089dd8@localhost.localdomain>
	<E1FTjlM-00050V-00@gondolin.me.apana.org.au>
	<20060412124533.14e0c4ff@localhost.localdomain>
	<20060412200015.GA19878@gondor.apana.org.au>
	<20060412131527.71f42d58@localhost.localdomain>
	<20060412202551.GA20085@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48070 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932331AbWDLVxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 17:53:44 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
In-Reply-To: <20060412202551.GA20085@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If Classical IP over ATM module is loaded, its neighbor table gets
populated when permanent neighbor entries are created; but these entries
are not flushed when the device is removed. Since the entry never gets
flushed the unregister of the network device never completes.

This version of the patch also adds locking around the reference to
the atm arp daemon to avoid races with events and daemon state changes.
(Note: barrier() was never really safe)

Bug-reference: http://bugzilla.kernel.org/show_bug.cgi?id=6295
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- clip.orig/net/atm/clip.c	2006-04-12 14:10:45.000000000 -0700
+++ clip/net/atm/clip.c	2006-04-12 14:21:41.000000000 -0700
@@ -613,12 +613,19 @@
 
 
 static int clip_device_event(struct notifier_block *this,unsigned long event,
-    void *dev)
+			     void *arg)
 {
+	struct net_device *dev = arg;
+
+	if (event == NETDEV_UNREGISTER) {
+		neigh_ifdown(&clip_tbl, dev);
+		return NOTIFY_DONE;
+	}
+
 	/* ignore non-CLIP devices */
-	if (((struct net_device *) dev)->type != ARPHRD_ATM ||
-	    ((struct net_device *) dev)->hard_start_xmit != clip_start_xmit)
+	if (dev->type != ARPHRD_ATM || dev->hard_start_xmit != clip_start_xmit)
 		return NOTIFY_DONE;
+
 	switch (event) {
 		case NETDEV_UP:
 			DPRINTK("clip_device_event NETDEV_UP\n");
@@ -686,14 +693,12 @@
 static void atmarpd_close(struct atm_vcc *vcc)
 {
 	DPRINTK("atmarpd_close\n");
-	atmarpd = NULL; /* assumed to be atomic */
-	barrier();
-	unregister_inetaddr_notifier(&clip_inet_notifier);
-	unregister_netdevice_notifier(&clip_dev_notifier);
-	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
-		printk(KERN_ERR "atmarpd_close: closing with requests "
-		    "pending\n");
+
+	rtnl_lock();
+	atmarpd = NULL;
 	skb_queue_purge(&sk_atm(vcc)->sk_receive_queue);
+	rtnl_unlock();
+
 	DPRINTK("(done)\n");
 	module_put(THIS_MODULE);
 }
@@ -714,7 +719,12 @@
 
 static int atm_init_atmarp(struct atm_vcc *vcc)
 {
-	if (atmarpd) return -EADDRINUSE;
+	rtnl_lock();
+	if (atmarpd) {
+		rtnl_unlock();
+		return -EADDRINUSE;
+	}
+
 	if (start_timer) {
 		start_timer = 0;
 		init_timer(&idle_timer);
@@ -731,10 +741,7 @@
 	vcc->push = NULL;
 	vcc->pop = NULL; /* crash */
 	vcc->push_oam = NULL; /* crash */
-	if (register_netdevice_notifier(&clip_dev_notifier))
-		printk(KERN_ERR "register_netdevice_notifier failed\n");
-	if (register_inetaddr_notifier(&clip_inet_notifier))
-		printk(KERN_ERR "register_inetaddr_notifier failed\n");
+	rtnl_unlock();
 	return 0;
 }
 
@@ -992,6 +999,8 @@
 
 	clip_tbl_hook = &clip_tbl;
 	register_atm_ioctl(&clip_ioctl_ops);
+	register_netdevice_notifier(&clip_dev_notifier);
+	register_inetaddr_notifier(&clip_inet_notifier);
 
 #ifdef CONFIG_PROC_FS
 {
@@ -1012,6 +1021,9 @@
 
 	remove_proc_entry("arp", atm_proc_root);
 
+	unregister_inetaddr_notifier(&clip_inet_notifier);
+	unregister_netdevice_notifier(&clip_dev_notifier);
+
 	deregister_atm_ioctl(&clip_ioctl_ops);
 
 	/* First, stop the idle timer, so it stops banging
