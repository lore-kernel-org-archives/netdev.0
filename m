From: ahendry <ahendry@tusc.com.au>
Subject: [PATCH 1/3] [RESEND] X.25: Add call forwarding
Date: Thu, 08 Feb 2007 10:14:25 +1100
Message-ID: <1170890065.5189.39.camel@localhost>
References: <1167881822.5124.88.camel@localhost>
	 <20070104102702.30630a9d@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-x25@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, eis@baty.hanse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from ricci.tusc.com.au ([203.2.177.24]:14069 "EHLO ricci.tusc.com.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161333AbXBGXOe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Feb 2007 18:14:34 -0500
In-Reply-To: <20070104102702.30630a9d@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds call forwarding to X.25, allowing it to operate like an X.25 router.
Useful if one needs to manipulate X.25 traffic with tools like tc.
This is an update/cleanup based off a patch submitted by Daniel Ferenci a few years ago.

Thanks Alan for the feedback.
Added the null check to the clones.
Moved the skb_clone's into the forwarding functions.

Worked ok with Cisco XoT, linux X.25 back to back, and some old NTUs/PADs.

Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>


diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla.clean/include/net/x25.h linux-2.6.20/include/net/x25.h
--- linux-2.6.20-vanilla.clean/include/net/x25.h	2007-02-05 05:44:54.000000000 +1100
+++ linux-2.6.20/include/net/x25.h	2007-02-08 10:00:06.000000000 +1100
@@ -161,6 +161,14 @@ struct x25_sock {
 	unsigned long 		vc_facil_mask;	/* inc_call facilities mask */
 };
 
+struct x25_forward {
+	struct list_head	node;
+	unsigned int		lci;
+	struct net_device	*dev1;
+	struct net_device	*dev2;
+	atomic_t		refcnt;
+};
+
 static inline struct x25_sock *x25_sk(const struct sock *sk)
 {
 	return (struct x25_sock *)sk;
@@ -198,6 +206,13 @@ extern int x25_negotiate_facilities(stru
 				struct x25_dte_facilities *);
 extern void x25_limit_facilities(struct x25_facilities *, struct x25_neigh *);
 
+/* x25_forward.c */
+extern void x25_clear_forward_by_lci(unsigned int lci);
+extern void x25_clear_forward_by_dev(struct net_device *);
+extern int x25_forward_data(int, struct x25_neigh *, struct sk_buff *);
+extern int x25_forward_call(struct x25_address *, struct x25_neigh *,
+				struct sk_buff *, int);
+
 /* x25_in.c */
 extern int  x25_process_rx_frame(struct sock *, struct sk_buff *);
 extern int  x25_backlog_rcv(struct sock *, struct sk_buff *);
@@ -282,6 +297,8 @@ extern struct hlist_head x25_list;
 extern rwlock_t x25_list_lock;
 extern struct list_head x25_route_list;
 extern rwlock_t x25_route_list_lock;
+extern struct list_head x25_forward_list;
+extern rwlock_t x25_forward_list_lock;
 
 extern int x25_proc_init(void);
 extern void x25_proc_exit(void);
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla.clean/net/x25/af_x25.c linux-2.6.20/net/x25/af_x25.c
--- linux-2.6.20-vanilla.clean/net/x25/af_x25.c	2007-02-05 05:44:54.000000000 +1100
+++ linux-2.6.20/net/x25/af_x25.c	2007-02-08 10:00:06.000000000 +1100
@@ -846,7 +846,7 @@ int x25_rx_call_request(struct sk_buff *
 	struct x25_address source_addr, dest_addr;
 	struct x25_facilities facilities;
 	struct x25_dte_facilities dte_facilities;
-	int len, rc;
+	int len, addr_len, rc;
 
 	/*
 	 *	Remove the LCI and frame type.
@@ -857,7 +857,8 @@ int x25_rx_call_request(struct sk_buff *
 	 *	Extract the X.25 addresses and convert them to ASCII strings,
 	 *	and remove them.
 	 */
-	skb_pull(skb, x25_addr_ntoa(skb->data, &source_addr, &dest_addr));
+	addr_len = x25_addr_ntoa(skb->data, &source_addr, &dest_addr);
+	skb_pull(skb, addr_len);
 
 	/*
 	 *	Get the length of the facilities, skip past them for the moment
@@ -873,11 +874,27 @@ int x25_rx_call_request(struct sk_buff *
 	sk = x25_find_listener(&source_addr,skb);
 	skb_push(skb,len);
 
+	if (sk != NULL && sk_acceptq_is_full(sk)) {
+		goto out_sock_put;
+	}
+
 	/*
-	 *	We can't accept the Call Request.
+	 *	We dont have any listeners for this incoming call.
+	 *	Try forwarding it.
 	 */
-	if (sk == NULL || sk_acceptq_is_full(sk))
-		goto out_clear_request;
+	if (sk == NULL) {
+		skb_push(skb, addr_len + X25_STD_MIN_LEN);
+		if (x25_forward_call(&dest_addr, nb, skb, lci) > 0)
+		{
+			/* Call was forwarded, dont process it any more */
+			kfree_skb(skb);
+			rc = 1;
+			goto out;
+		} else {
+			/* No listeners, can't forward, clear the call */
+			goto out_clear_request;
+		}
+	}
 
 	/*
 	 *	Try to reach a compromise on the requested facilities.
@@ -1598,6 +1615,9 @@ void x25_kill_by_neigh(struct x25_neigh 
 			x25_disconnect(s, ENETUNREACH, 0, 0);
 
 	write_unlock_bh(&x25_list_lock);
+
+	/* Remove any related forwards */
+	x25_clear_forward_by_dev(nb->dev);
 }
 
 static int __init x25_init(void)
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla.clean/net/x25/Makefile linux-2.6.20/net/x25/Makefile
--- linux-2.6.20-vanilla.clean/net/x25/Makefile	2007-02-05 05:44:54.000000000 +1100
+++ linux-2.6.20/net/x25/Makefile	2007-02-08 10:00:06.000000000 +1100
@@ -6,5 +6,5 @@ obj-$(CONFIG_X25) += x25.o
 
 x25-y			:= af_x25.o x25_dev.o x25_facilities.o x25_in.o \
 			   x25_link.o x25_out.o x25_route.o x25_subr.o \
-			   x25_timer.o x25_proc.o
+			   x25_timer.o x25_proc.o x25_forward.o
 x25-$(CONFIG_SYSCTL)	+= sysctl_net_x25.o
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla.clean/net/x25/x25_dev.c linux-2.6.20/net/x25/x25_dev.c
--- linux-2.6.20-vanilla.clean/net/x25/x25_dev.c	2007-02-05 05:44:54.000000000 +1100
+++ linux-2.6.20/net/x25/x25_dev.c	2007-02-08 10:00:06.000000000 +1100
@@ -67,9 +67,18 @@ static int x25_receive_data(struct sk_bu
 		return x25_rx_call_request(skb, nb, lci);
 
 	/*
-	 *	Its not a Call Request, nor is it a control frame.
-	 *      Let caller throw it away.
+	 * 	Its not a Call Request, nor is it a control frame.
+	 *	Can we forward it?
 	 */
+
+	if (x25_forward_data(lci, nb, skb)) {
+		if (frametype == X25_CLEAR_CONFIRMATION) {
+			x25_clear_forward_by_lci(lci);
+		}
+		kfree_skb(skb);
+		return 1;
+	}
+
 /*
 	x25_transmit_clear_request(nb, lci, 0x0D);
 */
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla.clean/net/x25/x25_forward.c linux-2.6.20/net/x25/x25_forward.c
--- linux-2.6.20-vanilla.clean/net/x25/x25_forward.c	1970-01-01 10:00:00.000000000 +1000
+++ linux-2.6.20/net/x25/x25_forward.c	2007-02-08 10:00:48.000000000 +1100
@@ -0,0 +1,163 @@
+/*
+ *	This module:
+ *		This module is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ *	History
+ *	03-01-2007	Added forwarding for x.25	Andrew Hendry
+ */
+#include <linux/if_arp.h>
+#include <linux/init.h>
+#include <net/x25.h>
+
+struct list_head x25_forward_list = LIST_HEAD_INIT(x25_forward_list);
+DEFINE_RWLOCK(x25_forward_list_lock);
+
+int x25_forward_call(struct x25_address *dest_addr, struct x25_neigh *from,
+			struct sk_buff *skb, int lci)
+{
+	struct x25_route *rt;
+	struct x25_neigh *neigh_new = NULL;
+	struct list_head *entry;
+	struct x25_forward *x25_frwd, *new_frwd;
+	struct sk_buff *skbn;
+	short same_lci = 0;
+	int rc = 0;
+
+	if ((rt = x25_get_route(dest_addr)) != NULL) {
+
+		if ((neigh_new = x25_get_neigh(rt->dev)) == NULL) {
+			/* This shouldnt happen, if it occurs somehow
+			 * do something sensible
+			 */
+			goto out_put_route;
+		}
+
+		/* Avoid a loop. This is the normal exit path for a
+		 * system with only one x.25 iface and default route
+		 */
+		if (rt->dev == from->dev) {
+			goto out_put_nb;
+		}
+
+		/* Remote end sending a call request on an already
+		 * established LCI? It shouldnt happen, just in case..
+		 */
+		read_lock_bh(&x25_forward_list_lock);
+		list_for_each(entry, &x25_forward_list) {
+			x25_frwd = list_entry(entry, struct x25_forward, node);
+			if (x25_frwd->lci == lci) {
+				printk(KERN_WARNING "X.25: call request for lci which is already registered!, transmitting but not registering new pair\n");
+				same_lci = 1;
+			}
+		}
+		read_unlock_bh(&x25_forward_list_lock);
+
+		/* Save the forwarding details for future traffic */
+		if (!same_lci){
+			if ((new_frwd = kmalloc(sizeof(struct x25_forward),
+							GFP_ATOMIC)) == NULL){
+				rc = -ENOMEM;
+				goto out_put_nb;
+			}
+			new_frwd->lci = lci;
+			new_frwd->dev1 = rt->dev;
+			new_frwd->dev2 = from->dev;
+			write_lock_bh(&x25_forward_list_lock);
+			list_add(&new_frwd->node, &x25_forward_list);
+			write_unlock_bh(&x25_forward_list_lock);
+		}
+
+		/* Forward the call request */
+		if ( (skbn = skb_clone(skb, GFP_ATOMIC)) == NULL){
+			goto out_put_nb;
+		}
+		x25_transmit_link(skbn, neigh_new);
+		rc = 1;
+	}
+
+
+out_put_nb:
+	x25_neigh_put(neigh_new);
+
+out_put_route:
+	x25_route_put(rt);	
+	return rc;
+}
+
+
+int x25_forward_data(int lci, struct x25_neigh *from, struct sk_buff *skb) {
+
+	struct x25_forward *frwd;
+	struct list_head *entry;
+	struct net_device *peer = NULL;
+	struct x25_neigh *nb;
+	struct sk_buff *skbn;
+	int rc = 0;
+
+	read_lock_bh(&x25_forward_list_lock);
+	list_for_each(entry, &x25_forward_list) {
+		frwd = list_entry(entry, struct x25_forward, node);
+		if (frwd->lci == lci) {
+			/* The call is established, either side can send */
+			if (from->dev == frwd->dev1) {
+				peer = frwd->dev2;
+			} else {
+				peer = frwd->dev1;
+			}
+			break;
+		}
+	}
+	read_unlock_bh(&x25_forward_list_lock);
+
+	if ( (nb = x25_get_neigh(peer)) == NULL)
+		goto out;
+	
+	if ( (skbn = pskb_copy(skb, GFP_ATOMIC)) == NULL){
+		goto out;
+
+	}
+	x25_transmit_link(skbn, nb);
+
+	x25_neigh_put(nb);
+	rc = 1;
+out:
+	return rc;
+}
+
+void x25_clear_forward_by_lci(unsigned int lci)
+{
+	struct x25_forward *fwd;
+	struct list_head *entry, *tmp;
+
+	write_lock_bh(&x25_forward_list_lock);
+
+	list_for_each_safe(entry, tmp, &x25_forward_list) {
+		fwd = list_entry(entry, struct x25_forward, node);
+		if (fwd->lci == lci) {
+			list_del(&fwd->node);
+			kfree(fwd);
+		}
+	}
+	write_unlock_bh(&x25_forward_list_lock);
+}
+
+
+void x25_clear_forward_by_dev(struct net_device *dev)
+{
+	struct x25_forward *fwd;
+	struct list_head *entry, *tmp;
+
+	write_lock_bh(&x25_forward_list_lock);
+
+	list_for_each_safe(entry, tmp, &x25_forward_list) {
+		fwd = list_entry(entry, struct x25_forward, node);
+		if ((fwd->dev1 == dev) || (fwd->dev2 == dev)){
+			list_del(&fwd->node);
+			kfree(fwd);
+		}
+	}
+	write_unlock_bh(&x25_forward_list_lock);
+}
diff -uprN -X linux-2.6.20/Documentation/dontdiff linux-2.6.20-vanilla.clean/net/x25/x25_route.c linux-2.6.20/net/x25/x25_route.c
--- linux-2.6.20-vanilla.clean/net/x25/x25_route.c	2007-02-05 05:44:54.000000000 +1100
+++ linux-2.6.20/net/x25/x25_route.c	2007-02-08 10:00:06.000000000 +1100
@@ -119,6 +119,9 @@ void x25_route_device_down(struct net_de
 			__x25_remove_route(rt);
 	}
 	write_unlock_bh(&x25_route_list_lock);
+
+	/* Remove any related forwarding */
+	x25_clear_forward_by_dev(dev);
 }
 
 /*

