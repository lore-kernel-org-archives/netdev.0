From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: 18 Aug 2003 08:13:44 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061208824.16010.2119.camel@jzny.localdomain>
References: <20030818091312.GA4889@lapdog>
	 <20030818041911.358c3437.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-06lLkphgphFnvyYz4iyU"
Cc: Tommi Virtanen <tv@debian.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030818041911.358c3437.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-06lLkphgphFnvyYz4iyU
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Editing the header may be the better approach if you have a few hundred 
hhs already inserted (this was the issue i was faced with when VRRP was
failing over when i was playing with it). I tried to flush the cache but
it took longer to recover it. 
The patch posted may not be the better way to do this. It should be per
neighbour table owner - at the moment only ARP and ndisc really care
about this. 
Heres an old patch i have circa 2.4.2 that i have been sitting on
planning to convert it to latest kernels; the ndisc portion is missing;
If this is found agreeable Tommi you can clean it up and bring it to par
with latest kernel

cheers,
jamal


On Mon, 2003-08-18 at 07:19, David S. Miller wrote:
> On Mon, 18 Aug 2003 12:13:12 +0300
> Tommi Virtanen <tv@debian.org> wrote:
> 
> > 	Here's a patch that
> > 
> > 	1. makes eth_header_cache_update also update the source MAC in
> > 	   hh_cache.
> > 
> > 	2. adds a NETDEV_CHANGEADDR notifier in net/core/neighbour.c
> > 	   that walks through all the neighbour entries and updates
> > 	   the hh_cache's for all the neighbour entries related to
> > 	   given device.
> > 
> > 	3. adds neighbour_init() to allow registration of said notifier.
> 
> I would suggest to fix this by instead flushing the hh
> entries (just like neigh_destroy() does).
> 
> This way, we don't have to fix up every single header cache
> implementation, that's painful :(
> 
> 

--=-06lLkphgphFnvyYz4iyU
Content-Disposition: attachment; filename=neighp
Content-Type: text/plain; name=neighp; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 242/include/net/neighbour.h	2003-07-20 19:42:33.000000000 -0400
+++ 242/include/net/patchedneighbour.h	2003-07-20 19:42:38.000000000 -0400
@@ -180,6 +180,7 @@
 extern void			neigh_destroy(struct neighbour *neigh);
 extern int			__neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
 extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, int override, int arp);
+extern int			neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 extern int			neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 extern int			neigh_resolve_output(struct sk_buff *skb);
 extern int			neigh_connected_output(struct sk_buff *skb);
--- 242/net/core/neighbour.c	2003-07-20 19:38:19.000000000 -0400
+++ 242/net/core/patchedneighbour.c	2003-08-18 07:15:35.000000000 -0400
@@ -50,6 +50,7 @@
 static void neigh_app_notify(struct neighbour *n);
 #endif
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
+int neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 
 static int neigh_glbl_allocs;
 static struct neigh_table *neigh_tables;
@@ -410,6 +411,52 @@
 	return -ENOENT;
 }
 
+void update_neigh_hh(struct neighbour *neigh)
+{
+
+	struct hh_cache *hh;
+
+	int (*update)(struct neighbour *neigh, struct hh_cache *hh) =
+                neigh->dev->hard_header_cache;
+
+	if (update) {
+		for (hh=neigh->hh; hh; hh=hh->hh_next) {
+			write_lock_bh(&hh->hh_lock);
+			update(neigh, hh);
+			write_unlock_bh(&hh->hh_lock);
+		}
+	}
+	else {
+		printk("device neigh %p does not have a update method!\n",neigh);
+	}
+}
+
+int neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
+{
+	int i;
+
+	write_lock_bh(&tbl->lock);
+
+	for (i=0; i<=NEIGH_HASHMASK; i++) {
+		struct neighbour *n, **np;
+
+		np = &tbl->hash_buckets[i];
+		while ((n = *np) != NULL) {
+			if (dev && n->dev != dev) {
+				np = &n->next;
+				continue;
+			}
+			*np = n->next;
+			write_lock_bh(&n->lock);
+			update_neigh_hh(n);
+			write_unlock_bh(&n->lock);
+		}
+	}
+
+        write_unlock_bh(&tbl->lock);
+	return 0;
+}
+
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 {
 	struct pneigh_entry *n, **np;
@@ -432,6 +479,7 @@
 }
 
 
+
 /*
  *	neighbour must already be out of the table;
  *
@@ -488,8 +536,9 @@
 
 	neigh->output = neigh->ops->output;
 
-	for (hh = neigh->hh; hh; hh = hh->hh_next)
+	for (hh = neigh->hh; hh; hh = hh->hh_next) {
 		hh->hh_output = neigh->ops->output;
+	}
 }
 
 /* Neighbour state is OK;
@@ -507,8 +556,10 @@
 
 	neigh->output = neigh->ops->connected_output;
 
-	for (hh = neigh->hh; hh; hh = hh->hh_next)
+	for (hh = neigh->hh; hh; hh = hh->hh_next) {
 		hh->hh_output = neigh->ops->hh_output;
+	}
+
 }
 
 /*
@@ -924,6 +975,7 @@
 		atomic_inc(&hh->hh_refcnt);
 		dst->hh = hh;
 	}
+
 }
 
 /* This function can be used in contexts, where only old dev_queue_xmit
@@ -961,6 +1013,7 @@
 		int err;
 		struct net_device *dev = neigh->dev;
 		if (dev->hard_header_cache && dst->hh == NULL) {
+
 			write_lock_bh(&neigh->lock);
 			if (dst->hh == NULL)
 				neigh_hh_init(neigh, dst, dst->ops->protocol);
--- 242/net/ipv4/arp.c	2003-07-20 19:37:52.000000000 -0400
+++ 242/net/ipv4/patchedarp.c	2003-08-18 07:19:08.000000000 -0400
@@ -1,6 +1,6 @@
 /* linux/net/inet/arp.c
  *
- * Version:	$Id: arp.c,v 1.90 2000/10/04 09:20:56 anton Exp $
+ * Version:	$Id: arp.c,v 1.1 2003/07/04 14:04:46 root Exp root $
  *
  * Copyright (C) 1994 by Florian  La Roche
  *
@@ -123,6 +123,7 @@
 static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb);
 static void parp_redo(struct sk_buff *skb);
 
+static int arp_n_event(struct notifier_block *this, unsigned long event, void *ptr);
 static struct neigh_ops arp_generic_ops =
 {
 	AF_INET,
@@ -1140,6 +1141,30 @@
 }
 #endif
 
+
+struct notifier_block arp_netdev_notifier = {
+	arp_n_event,
+	NULL,
+	0
+};
+
+static int arp_n_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *dev = (struct net_device *)(ptr) ;
+
+	switch (event) {
+	default:
+		break;
+	case NETDEV_CHANGEADDR:
+		neigh_changeaddr(&arp_tbl, dev);
+		break;
+	}
+
+	return NOTIFY_DONE;
+
+}
+
+
 /* Note, that it is not on notifier chain.
    It is necessary, that this routine was called after route cache will be
    flushed.
@@ -1174,6 +1199,7 @@
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4, NET_IPV4_NEIGH, "ipv4");
 #endif
+	register_netdevice_notifier(&arp_netdev_notifier);
 }
 
 

--=-06lLkphgphFnvyYz4iyU--
