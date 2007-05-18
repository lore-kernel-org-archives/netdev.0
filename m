From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [patch 2/7] CAN: Add PF_CAN core module
Date: Fri, 18 May 2007 23:06:18 +0200
Message-ID: <464E154A.7020605@hartkopp.net>
References: <20070516145100.29877.0@janus.isnogud.escape.de> <20070516145121.29877.2@janus.isnogud.escape.de> <20070518005948.GA11737@linux.vnet.ibm.com> <464D6F85.9090202@hartkopp.net> <20070518143359.GA8876@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:35602 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612AbXERVGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 17:06:54 -0400
In-Reply-To: <20070518143359.GA8876@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Paul,

as you may see in the attached SVN-log i changed some code according 
your suggestions.
I additionally made some clarifications of function names.

If you would like to see the af_can.c completely please visit:
http://svn.berlios.de/svnroot/repos/socketcan/trunk/kernel/2.6/net/can/af_can.c

But this code in the projekt SVN is working for several kernel versions 
(which is removed by some scripts when creating a LKML netdev patch) - 
just for your information.

Best regards,
Oliver

-------- Original-Nachricht --------
Betreff: 	r311 - trunk/kernel/2.6/net/can
Datum: 	Fri, 18 May 2007 21:47:15 +0200
Von: 	hartkopp@mail.berlios.de
An: 	socketcan-commit@lists.berlios.de



Author: hartkopp
Date: 2007-05-18 21:47:14 +0200 (Fri, 18 May 2007)
New Revision: 311

Modified:
   trunk/kernel/2.6/net/can/af_can.c
Log:
Updated RCU removal of dev_rcv_lists structures in the case of CAN-interfaces
going down (in can_notifier). Thanks to Paul E. McKenny (IBM) who gave this
hint on netdev kernel mailinglist.


Modified: trunk/kernel/2.6/net/can/af_can.c
===================================================================
--- trunk/kernel/2.6/net/can/af_can.c	2007-05-16 09:03:21 UTC (rev 310)
+++ trunk/kernel/2.6/net/can/af_can.c	2007-05-18 19:47:14 UTC (rev 311)
@@ -454,31 +454,48 @@
 }
 EXPORT_SYMBOL(can_rx_register);
 
-static void can_rcv_lists_delete(struct rcu_head *rp)
+static void can_rx_delete_list(struct hlist_head *rl)
 {
+	struct receiver *r;
+	struct hlist_node *n;
+
+	hlist_for_each_entry_rcu(r, n, rl, list) {
+		hlist_del_rcu(&r->list);
+		kmem_cache_free(rcv_cache, r);
+	}
+}
+
+/*
+ * can_rx_delete_device - rcu callback for dev_rcv_lists structure removal
+ */
+static void can_rx_delete_device(struct rcu_head *rp)
+{
 	struct dev_rcv_lists *d = container_of(rp, struct dev_rcv_lists, rcu);
+	int i;
 
+	/* remove all receivers hooked at this netdevice */
+	can_rx_delete_list(&d->rx_err);
+	can_rx_delete_list(&d->rx_all);
+	can_rx_delete_list(&d->rx_fil);
+	can_rx_delete_list(&d->rx_inv);
+	can_rx_delete_list(&d->rx_eff);
+
+	for (i = 0; i < 2048; i++)
+		can_rx_delete_list(&d->rx_sff[i]);
+
 	kfree(d);
 }
 
-static void can_rx_delete(struct rcu_head *rp)
+/*
+ * can_rx_delete_receiver - rcu callback for single receiver entry removal
+ */
+static void can_rx_delete_receiver(struct rcu_head *rp)
 {
 	struct receiver *r = container_of(rp, struct receiver, rcu);
 
 	kmem_cache_free(rcv_cache, r);
 }
 
-static void can_rx_delete_all(struct hlist_head *rl)
-{
-	struct receiver *r;
-	struct hlist_node *n;
-
-	hlist_for_each_entry_rcu(r, n, rl, list) {
-		hlist_del_rcu(&r->list);
-		call_rcu(&r->rcu, can_rx_delete);
-	}
-}
-
 /**
  * can_rx_unregister - unsubscribe CAN frames from a specific interface
  * @dev: pointer to netdevice (NULL => unsubcribe from 'all' CAN devices list)
@@ -556,7 +573,7 @@
 
 	/* schedule the receiver item for deletion */
 	if (r)
-		call_rcu(&r->rcu, can_rx_delete);
+		call_rcu(&r->rcu, can_rx_delete_receiver);
 
 	return ret;
 }
@@ -945,7 +962,6 @@
 	struct net_device *dev = (struct net_device *)data;
 	struct notifier *n;
 	struct dev_rcv_lists *d;
-	int i;
 
 	DBG("called for %s, msg = %lu\n", dev->name, msg);
 
@@ -986,25 +1002,16 @@
 		spin_lock_bh(&rcv_lists_lock);
 
 		d = find_dev_rcv_lists(dev);
-		if (d) {
+		if (d)
 			hlist_del_rcu(&d->list);
-
-			/* remove all receivers hooked at this netdevice */
-			can_rx_delete_all(&d->rx_err);
-			can_rx_delete_all(&d->rx_all);
-			can_rx_delete_all(&d->rx_fil);
-			can_rx_delete_all(&d->rx_inv);
-			can_rx_delete_all(&d->rx_eff);
-			for (i = 0; i < 2048; i++)
-				can_rx_delete_all(&d->rx_sff[i]);
-		} else
+		else
 			printk(KERN_ERR "can: notifier: receive list not "
 			       "found for dev %s\n", dev->name);
 
 		spin_unlock_bh(&rcv_lists_lock);
 
 		if (d)
-			call_rcu(&d->rcu, can_rcv_lists_delete);
+			call_rcu(&d->rcu, can_rx_delete_device);
 
 		break;
 	}

_______________________________________________
Socketcan-commit mailing list
Socketcan-commit@lists.berlios.de
https://lists.berlios.de/mailman/listinfo/socketcan-commit


