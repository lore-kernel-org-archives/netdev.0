From: Thomas Graf <tgraf@suug.ch>
Subject: [NEIGH]: Netlink notifications
Date: Sun, 22 Jul 2007 12:35:55 +0200
Message-ID: <20070722103555.GI3651@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:52988 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753730AbXGVKff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jul 2007 06:35:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently neighbour event notifications are limited to update
notifications and only sent if the ARP daemon is enabled. This
patch extends the existing notification code by also reporting
neighbours being removed due to gc or administratively and
removes the dependency on the ARP daemon. This allows to keep
track of neighbour states without periodically fetching the
complete neighbour table.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/core/neighbour.c
===================================================================
--- net-2.6.orig/net/core/neighbour.c	2007-07-22 11:42:02.000000000 +0200
+++ net-2.6/net/core/neighbour.c	2007-07-22 11:49:15.000000000 +0200
@@ -54,9 +54,8 @@
 #define PNEIGH_HASHMASK		0xF
 
 static void neigh_timer_handler(unsigned long arg);
-#ifdef CONFIG_ARPD
-static void neigh_app_notify(struct neighbour *n);
-#endif
+static void __neigh_notify(struct neighbour *n, int type, int flags);
+static void neigh_update_notify(struct neighbour *neigh);
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 
@@ -109,6 +108,7 @@ static void neigh_cleanup_and_release(st
 	if (neigh->parms->neigh_cleanup)
 		neigh->parms->neigh_cleanup(neigh);
 
+	__neigh_notify(neigh, RTM_DELNEIGH, 0);
 	neigh_release(neigh);
 }
 
@@ -829,13 +829,10 @@ static void neigh_timer_handler(unsigned
 out:
 		write_unlock(&neigh->lock);
 	}
+
 	if (notify)
-		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
+		neigh_update_notify(neigh);
 
-#ifdef CONFIG_ARPD
-	if (notify && neigh->parms->app_probes)
-		neigh_app_notify(neigh);
-#endif
 	neigh_release(neigh);
 }
 
@@ -1064,11 +1061,8 @@ out:
 	write_unlock_bh(&neigh->lock);
 
 	if (notify)
-		call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
-#ifdef CONFIG_ARPD
-	if (notify && neigh->parms->app_probes)
-		neigh_app_notify(neigh);
-#endif
+		neigh_update_notify(neigh);
+
 	return err;
 }
 
@@ -2001,6 +1995,11 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
+static void neigh_update_notify(struct neighbour *neigh)
+{
+	call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
+	__neigh_notify(neigh, RTM_NEWNEIGH, 0);
+}
 
 static int neigh_dump_table(struct neigh_table *tbl, struct sk_buff *skb,
 			    struct netlink_callback *cb)
@@ -2420,7 +2419,6 @@ static const struct file_operations neig
 
 #endif /* CONFIG_PROC_FS */
 
-#ifdef CONFIG_ARPD
 static inline size_t neigh_nlmsg_size(void)
 {
 	return NLMSG_ALIGN(sizeof(struct ndmsg))
@@ -2452,16 +2450,11 @@ errout:
 		rtnl_set_sk_err(RTNLGRP_NEIGH, err);
 }
 
+#ifdef CONFIG_ARPD
 void neigh_app_ns(struct neighbour *n)
 {
 	__neigh_notify(n, RTM_GETNEIGH, NLM_F_REQUEST);
 }
-
-static void neigh_app_notify(struct neighbour *n)
-{
-	__neigh_notify(n, RTM_NEWNEIGH, 0);
-}
-
 #endif /* CONFIG_ARPD */
 
 #ifdef CONFIG_SYSCTL
