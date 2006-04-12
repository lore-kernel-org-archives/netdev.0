From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] atm: clip causes unregister hang
Date: Wed, 12 Apr 2006 10:55:45 -0700
Message-ID: <20060412105545.3b089dd8@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16875 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932277AbWDLR4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2006 13:56:21 -0400
To: "David S. Miller" <davem@davemloft.net>, chas@cmf.nrl.navy.mil
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If Classical IP over ATM module is loaded or compile in to the kernel.
Its neighbor table gets populated when permanent neighbor entries are created;
but these entries are not flushed when the device is removed. 
Since the entry never gets flushed the unregister of the network device never
completes.

The problem is that the driver doesn't register a notify handler unless
ATM is started, and it doesn't do the proper cleanup in the event handler.

Please apply for 2.6.17 and 2.6.16 stable.

Bug-reference: http://bugzilla.kernel.org/show_bug.cgi?id=6295
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.16.2.orig/net/atm/clip.c	2006-04-12 10:10:43.000000000 -0700
+++ linux-2.6.16.2/net/atm/clip.c	2006-04-12 10:15:46.000000000 -0700
@@ -613,12 +613,19 @@
 
 
 static int clip_device_event(struct notifier_block *this,unsigned long event,
-    void *dev)
+			     void *arg)
 {
+	struct net_device *dev = arg;
+
+	if (event == NETDEV_DOWN) {
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
@@ -688,8 +695,7 @@
 	DPRINTK("atmarpd_close\n");
 	atmarpd = NULL; /* assumed to be atomic */
 	barrier();
-	unregister_inetaddr_notifier(&clip_inet_notifier);
-	unregister_netdevice_notifier(&clip_dev_notifier);
+
 	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
 		printk(KERN_ERR "atmarpd_close: closing with requests "
 		    "pending\n");
@@ -731,10 +737,6 @@
 	vcc->push = NULL;
 	vcc->pop = NULL; /* crash */
 	vcc->push_oam = NULL; /* crash */
-	if (register_netdevice_notifier(&clip_dev_notifier))
-		printk(KERN_ERR "register_netdevice_notifier failed\n");
-	if (register_inetaddr_notifier(&clip_inet_notifier))
-		printk(KERN_ERR "register_inetaddr_notifier failed\n");
 	return 0;
 }
 
@@ -992,6 +994,8 @@
 
 	clip_tbl_hook = &clip_tbl;
 	register_atm_ioctl(&clip_ioctl_ops);
+	register_netdevice_notifier(&clip_dev_notifier);
+	register_inetaddr_notifier(&clip_inet_notifier);
 
 #ifdef CONFIG_PROC_FS
 {
@@ -1012,6 +1016,9 @@
 
 	remove_proc_entry("arp", atm_proc_root);
 
+	unregister_inetaddr_notifier(&clip_inet_notifier);
+	unregister_netdevice_notifier(&clip_dev_notifier);
+
 	deregister_atm_ioctl(&clip_ioctl_ops);
 
 	/* First, stop the idle timer, so it stops banging
