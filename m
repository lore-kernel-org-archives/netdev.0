From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] add init_dummy_netdev() for napi only dummy intefaces
Date: Tue, 12 Dec 2006 16:27:38 +1100
Message-ID: <1165901258.11914.32.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40999 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169AbWLLF1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 00:27:48 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds an init_dummy_netdev() function that gets a network device
structure (allocation and lifetime entirely under caller's control) and
initialize the minimum amount of fields so it can be used to schedule
NAPI polls without registering a full blown interface. This is to be
used by drivers that need to tie several hardware interfaces to a single
NAPI poll scheduler due to HW limitations.

It also updates the ibm_emac driver to use that instead of doing it's
own initializations by hand.

Symbol is exported GPL only a I don't think we want binary drivers doing
that sort of acrobatics (if we want them at all).

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

I'm shit at inventing function names so feel free to come up with
something nicer !

Index: linux-cell/drivers/net/ibm_emac/ibm_emac_mal.c
===================================================================
--- linux-cell.orig/drivers/net/ibm_emac/ibm_emac_mal.c	2006-12-12 16:13:27.000000000 +1100
+++ linux-cell/drivers/net/ibm_emac/ibm_emac_mal.c	2006-12-12 16:23:21.000000000 +1100
@@ -426,11 +426,10 @@ static int __init mal_probe(struct ocp_d
 	mal->def = ocpdev->def;
 
 	INIT_LIST_HEAD(&mal->poll_list);
-	set_bit(__LINK_STATE_START, &mal->poll_dev.state);
+	init_dummy_netdev(&mal->poll_dev);
 	mal->poll_dev.weight = CONFIG_IBM_EMAC_POLL_WEIGHT;
 	mal->poll_dev.poll = mal_poll;
 	mal->poll_dev.priv = mal;
-	atomic_set(&mal->poll_dev.refcnt, 1);
 
 	INIT_LIST_HEAD(&mal->list);
 
Index: linux-cell/include/linux/netdevice.h
===================================================================
--- linux-cell.orig/include/linux/netdevice.h	2006-12-12 16:06:24.000000000 +1100
+++ linux-cell/include/linux/netdevice.h	2006-12-12 16:12:17.000000000 +1100
@@ -454,6 +454,7 @@ struct net_device
 	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
 	       NETREG_UNREGISTERED,	/* completed unregister todo */
 	       NETREG_RELEASED,		/* called free_netdev */
+	       NETREG_DUMMY,		/* dummy device for NAPI poll */
 	} reg_state;
 
 	/* Called after device is detached from network. */
@@ -581,6 +582,7 @@ extern int		dev_close(struct net_device 
 extern int		dev_queue_xmit(struct sk_buff *skb);
 extern int		register_netdevice(struct net_device *dev);
 extern int		unregister_netdevice(struct net_device *dev);
+extern int		init_dummy_netdev(struct net_device *dev);
 extern void		free_netdev(struct net_device *dev);
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
Index: linux-cell/net/core/dev.c
===================================================================
--- linux-cell.orig/net/core/dev.c	2006-12-12 16:01:59.000000000 +1100
+++ linux-cell/net/core/dev.c	2006-12-12 16:23:23.000000000 +1100
@@ -3007,6 +3007,42 @@ out_err:
 }
 
 /**
+ *	init_dummy_netdev	- init a dummy network device for NAPI
+ *	@dev: device to init
+ *
+ *	This takes a network device structure and initialize the minimum
+ *	amount of fields so it can be used to schedule NAPI polls without
+ *	registering a full blown interface. This is to be used by drivers
+ *	that need to tie several hardware interfaces to a single NAPI
+ *	poll scheduler due to HW limitations.
+ */
+int init_dummy_netdev(struct net_device *dev)
+{
+	/* Clear everything. Note we don't initialize spinlocks
+	 * are they aren't supposed to be taken by any of the
+	 * NAPI code and this dummy netdev is supposed to be
+	 * only ever used for NAPI polls
+	 */
+	memset(dev, 0, sizeof(struct net_device));
+
+	/* make sure we BUG if trying to hit standard
+	 * register/unregister code path
+	 */
+	dev->reg_state = NETREG_DUMMY;
+
+	/* initialize the ref count */
+	atomic_set(&dev->refcnt, 1);
+
+	/* a dummy interface is started by default */
+	set_bit(__LINK_STATE_PRESENT, &dev->state);
+	set_bit(__LINK_STATE_START, &dev->state);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(init_dummy_netdev);
+
+
+/**
  *	register_netdev	- register a network device
  *	@dev: device to register
  *


