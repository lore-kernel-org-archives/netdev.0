From: Tommi Virtanen <tv@debian.org>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 20:11:44 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818171144.GC1793@lapdog>
References: <20030818091312.GA4889@lapdog> <20030818041911.358c3437.davem@redhat.com> <1061208824.16010.2119.camel@jzny.localdomain> <20030818051227.4f35f2f3.davem@redhat.com> <20030818160422.GB1793@lapdog> <20030818090654.7f44a16e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030818090654.7f44a16e.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2003 at 09:06:54AM -0700, David S. Miller wrote:
> > ===== net/ipv6/ndisc.c 1.22 vs edited =====
> > --- 1.22/net/ipv6/ndisc.c	Tue Jun 24 02:21:28 2003
> > +++ edited/net/ipv6/ndisc.c	Mon Aug 18 18:51:40 2003
>  ...
> > +	case NETDEV_CHANGEADDR:
> > +		neigh_changeaddr(&nd_tbl, dev);
> > +		rt_cache_flush(0);
> 
> Don't flush the ipv4 routing cache from ipv6 please :-)

	Good point.

	I don't have an IPv6 test setup, so that side is..
	umm.. improvised ;)

	Here's the updated patch; I feel this is suitable for
	inclusion, performance can always be improved; remember, the
	current situation is either 10s..1min of no traffic passing
	because you had to bring down the interface, or cache lifetime
	of existing flows using the old MAC. This is a whole lot
	better.

===== include/net/neighbour.h 1.1 vs edited =====
--- 1.1/include/net/neighbour.h	Tue Feb  5 19:39:48 2002
+++ edited/include/net/neighbour.h	Mon Aug 18 18:52:30 2003
@@ -180,6 +180,7 @@
 extern void			neigh_destroy(struct neighbour *neigh);
 extern int			__neigh_event_send(struct neighbour *neigh, struct sk_buff *skb);
 extern int			neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new, int override, int arp);
+extern void			neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 extern int			neigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
 extern int			neigh_resolve_output(struct sk_buff *skb);
 extern int			neigh_connected_output(struct sk_buff *skb);
===== net/core/neighbour.c 1.9 vs edited =====
--- 1.9/net/core/neighbour.c	Thu Jun 12 09:24:41 2003
+++ edited/net/core/neighbour.c	Mon Aug 18 18:52:41 2003
@@ -50,6 +50,7 @@
 static void neigh_app_notify(struct neighbour *n);
 #endif
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *dev);
+void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev);
 
 static int neigh_glbl_allocs;
 static struct neigh_table *neigh_tables;
@@ -167,6 +168,33 @@
 		dev_put(skb->dev);
 		kfree_skb(skb);
 	}
+}
+
+void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
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
+			n->dead = 1;
+			neigh_del_timer(n);
+			write_unlock_bh(&n->lock);
+			neigh_release(n);
+		}
+	}
+
+        write_unlock_bh(&tbl->lock);
 }
 
 int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
===== net/ipv4/arp.c 1.11 vs edited =====
--- 1.11/net/ipv4/arp.c	Fri Jun 27 09:03:01 2003
+++ edited/net/ipv4/arp.c	Mon Aug 18 18:51:10 2003
@@ -1212,6 +1212,28 @@
 }
 #endif
 
+static int arp_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	switch (event) {
+	case NETDEV_CHANGEADDR:
+		neigh_changeaddr(&arp_tbl, dev);
+		rt_cache_flush(0);
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+struct notifier_block arp_netdev_notifier = {
+	arp_netdev_event,
+	NULL,
+	0
+};
+
 /* Note, that it is not on notifier chain.
    It is necessary, that this routine was called after route cache will be
    flushed.
@@ -1243,6 +1265,7 @@
 #ifdef CONFIG_SYSCTL
 	neigh_sysctl_register(NULL, &arp_tbl.parms, NET_IPV4, NET_IPV4_NEIGH, "ipv4");
 #endif
+	register_netdevice_notifier(&arp_netdev_notifier);
 }
 
 
===== net/ipv6/ndisc.c 1.22 vs edited =====
--- 1.22/net/ipv6/ndisc.c	Tue Jun 24 02:21:28 2003
+++ edited/net/ipv6/ndisc.c	Mon Aug 18 20:06:11 2003
@@ -1336,6 +1336,28 @@
 	return 0;
 }
 
+static int ndisc_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+
+	switch (event) {
+	case NETDEV_CHANGEADDR:
+		neigh_changeaddr(&nd_tbl, dev);
+		fib6_run_gc(0);
+		break;
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+struct notifier_block ndisc_netdev_notifier = {
+	ndisc_netdev_event,
+	NULL,
+	0
+};
+
 int __init ndisc_init(struct net_proto_family *ops)
 {
 	struct sock *sk;
@@ -1377,6 +1399,7 @@
 	neigh_sysctl_register(NULL, &nd_tbl.parms, NET_IPV6, NET_IPV6_NEIGH, "ipv6");
 #endif
 
+	register_netdevice_notifier(&ndisc_netdev_notifier);
 	return 0;
 }
 


-- 
:(){ :|:&};:
