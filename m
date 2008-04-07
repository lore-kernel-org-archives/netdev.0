From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26 1/2] Shrink size of net_device by filling alignment
 holes in it.
Date: Mon, 07 Apr 2008 20:25:02 +0400
Message-ID: <47FA4ADE.1020308@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54876 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbYDGQBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 12:01:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've found a much easier way to shrink the net_device structure 
rather that moving all the operations out of it. However, since
the net_device may grow further, moving the operations into a
separate place may look reasonable.

The pahole tool showed, that there are a 124 and 80 bytes holes
before the queue_lock and the _xmit_lock respectively. Moving most
of the devices callbacks into the 2nd hole makes the sizeof of the
structure be 1024 bytes.

The hard_start_xmit callback is not moved to keep it in previous
cacheline.

I think it's OK to make such a reordering, since all these hooks
are a) read-only and b) not called on fast paths, so their place 
within the structure looks not very important.

Unfortunately diff makes the patch look like moving other fields,
rater than the ops :)

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 include/linux/netdevice.h |   47 +++++++++++++++++++++++----------------------
 1 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8b17ed4..3397919 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -483,9 +483,6 @@ struct net_device
 	struct list_head	napi_list;
 #endif
 	
-	/* The device initialization function. Called only once. */
-	int			(*init)(struct net_device *dev);
-
 	/* ------- Fields preinitialized in Space.c finish here ------- */
 
 	/* Net device features */
@@ -641,27 +638,9 @@ struct net_device
 	int			watchdog_timeo; /* used by dev_watchdog() */
 	struct timer_list	watchdog_timer;
 
-/*
- * refcnt is a very hot point, so align it on SMP
- */
-	/* Number of references to this device */
-	atomic_t		refcnt ____cacheline_aligned_in_smp;
-
-	/* delayed register/unregister */
-	struct list_head	todo_list;
-	/* device index hash chain */
-	struct hlist_node	index_hlist;
-
-	struct net_device	*link_watch_next;
-
-	/* register/unregister state machine */
-	enum { NETREG_UNINITIALIZED=0,
-	       NETREG_REGISTERED,	/* completed register_netdevice */
-	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
-	       NETREG_UNREGISTERED,	/* completed unregister todo */
-	       NETREG_RELEASED,		/* called free_netdev */
-	} reg_state;
 
+	/* The device initialization function. Called only once. */
+	int			(*init)(struct net_device *dev);
 	/* Called after device is detached from network. */
 	void			(*uninit)(struct net_device *dev);
 	/* Called after last user reference disappears. */
@@ -703,6 +682,28 @@ struct net_device
 						    unsigned short vid);
 
 	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
+
+/*
+ * refcnt is a very hot point, so align it on SMP
+ */
+	/* Number of references to this device */
+	atomic_t		refcnt ____cacheline_aligned_in_smp;
+
+	/* delayed register/unregister */
+	struct list_head	todo_list;
+	/* device index hash chain */
+	struct hlist_node	index_hlist;
+
+	struct net_device	*link_watch_next;
+
+	/* register/unregister state machine */
+	enum { NETREG_UNINITIALIZED=0,
+	       NETREG_REGISTERED,	/* completed register_netdevice */
+	       NETREG_UNREGISTERING,	/* called unregister_netdevice */
+	       NETREG_UNREGISTERED,	/* completed unregister todo */
+	       NETREG_RELEASED,		/* called free_netdev */
+	} reg_state;
+
 #ifdef CONFIG_NETPOLL
 	struct netpoll_info	*npinfo;
 #endif
-- 
1.5.3.4

