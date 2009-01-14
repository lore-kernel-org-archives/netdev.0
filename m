From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH] Add init_dummy_netdev() and fix EMAC driver using it
Date: Wed, 14 Jan 2009 15:14:55 +1100
Message-ID: <1231906495.22571.79.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:53860 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753366AbZANEP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 23:15:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds an init_dummy_netdev() function that gets a network device
structure (allocation and lifetime entirely under caller's control) and
initialize the minimum amount of fields so it can be used to schedule
NAPI polls without registering a full blown interface. This is to be
used by drivers that need to tie several hardware interfaces to a single
NAPI poll scheduler due to HW limitations.

It also updates the ibm_newemac driver to use that, this fixing the
oops on 2.6.29 due to passing NULL as "dev" to netif_napi_add()

Symbol is exported GPL only a I don't think we want binary drivers doing
that sort of acrobatics (if we want them at all).

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Index: linux-work/include/linux/netdevice.h
===================================================================
--- linux-work.orig/include/linux/netdevice.h	2009-01-13 16:13:41.000000000 +1100
+++ linux-work/include/linux/netdevice.h	2009-01-14 14:13:24.000000000 +1100
@@ -795,6 +795,7 @@ struct net_device
 	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
 	       NETREG_UNREGISTERED,	/* completed unregister todo */
 	       NETREG_RELEASED,		/* called free_netdev */
+	       NETREG_DUMMY,		/* dummy device for NAPI poll */
 	} reg_state;
 
 	/* Called from unregister, can be used to call free_netdev */
@@ -1077,6 +1078,8 @@ extern void		free_netdev(struct net_devi
 extern void		synchronize_net(void);
 extern int 		register_netdevice_notifier(struct notifier_block *nb);
 extern int		unregister_netdevice_notifier(struct notifier_block *nb);
+extern int		init_dummy_netdev(struct net_device *dev);
+
 extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
Index: linux-work/net/core/dev.c
===================================================================
--- linux-work.orig/net/core/dev.c	2009-01-13 16:17:52.000000000 +1100
+++ linux-work/net/core/dev.c	2009-01-14 14:24:03.000000000 +1100
@@ -4434,6 +4434,45 @@ err_uninit:
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
+	/* NAPI wants this */
+	INIT_LIST_HEAD(&dev->napi_list);
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
Index: linux-work/drivers/net/ibm_newemac/mal.c
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/mal.c	2009-01-14 14:25:10.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/mal.c	2009-01-14 14:25:30.000000000 +1100
@@ -613,7 +613,9 @@ static int __devinit mal_probe(struct of
 	INIT_LIST_HEAD(&mal->list);
 	spin_lock_init(&mal->lock);
 
-	netif_napi_add(NULL, &mal->napi, mal_poll,
+	init_dummy_netdev(&mal->dummy_dev);
+
+	netif_napi_add(&mal->dummy_dev, &mal->napi, mal_poll,
 		       CONFIG_IBM_NEW_EMAC_POLL_WEIGHT);
 
 	/* Load power-on reset defaults */
Index: linux-work/drivers/net/ibm_newemac/mal.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/mal.h	2009-01-14 14:24:40.000000000 +1100
+++ linux-work/drivers/net/ibm_newemac/mal.h	2009-01-14 14:24:58.000000000 +1100
@@ -214,6 +214,8 @@ struct mal_instance {
 	int			index;
 	spinlock_t		lock;
 
+	struct net_device	dummy_dev;
+
 	unsigned int features;
 };
 


