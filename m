From: Matt Mackall <mpm@selenic.com>
Subject: [PATCH 3/7] netpoll: add netpoll point to net_device
Date: Thu, 03 Mar 2005 14:46:31 -0600
Message-ID: <4.454130102@selenic.com>
References: <3.454130102@selenic.com>
Cc: netdev@oss.sgi.com, Jeff Moyer <jmoyer@redhat.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add struct netpoll pointer to struct netdevice
Move netpoll rx flags to netpoll struct
Stop traversing rx_list and get np pointer from skb->dev->np
Remove now unneeded rx_list

Signed-off-by: Matt Mackall <mpm@selenic.com>

Index: rc4/include/linux/netdevice.h
===================================================================
--- rc4.orig/include/linux/netdevice.h	2005-02-17 22:32:12.000000000 -0600
+++ rc4/include/linux/netdevice.h	2005-02-17 22:32:20.000000000 -0600
@@ -41,7 +41,7 @@
 struct divert_blk;
 struct vlan_group;
 struct ethtool_ops;
-
+struct netpoll;
 					/* source back-compat hooks */
 #define SET_ETHTOOL_OPS(netdev,ops) \
 	( (netdev)->ethtool_ops = (ops) )
@@ -471,7 +471,7 @@
 	int			(*neigh_setup)(struct net_device *dev, struct neigh_parms *);
 	int			(*accept_fastpath)(struct net_device *, struct dst_entry*);
 #ifdef CONFIG_NETPOLL
-	int			netpoll_rx;
+	struct netpoll		*np;
 #endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*poll_controller)(struct net_device *dev);
Index: rc4/net/core/netpoll.c
===================================================================
--- rc4.orig/net/core/netpoll.c	2005-02-17 22:32:19.000000000 -0600
+++ rc4/net/core/netpoll.c	2005-02-17 22:39:59.000000000 -0600
@@ -35,9 +35,6 @@
 static int nr_skbs;
 static struct sk_buff *skbs;
 
-static DEFINE_SPINLOCK(rx_list_lock);
-static LIST_HEAD(rx_list);
-
 static atomic_t trapped;
 static DEFINE_SPINLOCK(netpoll_poll_lock);
 
@@ -84,13 +81,13 @@
 	queue = &__get_cpu_var(softnet_data);
 	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
 	    !list_empty(&queue->poll_list)) {
-		np->dev->netpoll_rx |= NETPOLL_RX_DROP;
+		np->rx_flags |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
 
 		np->dev->poll(np->dev, &budget);
 
 		atomic_dec(&trapped);
-		np->dev->netpoll_rx &= ~NETPOLL_RX_DROP;
+		np->rx_flags &= ~NETPOLL_RX_DROP;
 	}
 	spin_unlock_irqrestore(&netpoll_poll_lock, flags);
 }
@@ -279,18 +276,7 @@
 	int size, type = ARPOP_REPLY, ptype = ETH_P_ARP;
 	u32 sip, tip;
 	struct sk_buff *send_skb;
-	unsigned long flags;
-	struct list_head *p;
-	struct netpoll *np = NULL;
-
-	spin_lock_irqsave(&rx_list_lock, flags);
-	list_for_each(p, &rx_list) {
-		np = list_entry(p, struct netpoll, rx_list);
-		if ( np->dev == skb->dev )
-			break;
-		np = NULL;
-	}
-	spin_unlock_irqrestore(&rx_list_lock, flags);
+	struct netpoll *np = skb->dev->np;
 
 	if (!np) return;
 
@@ -373,10 +359,10 @@
 	int proto, len, ulen;
 	struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll *np;
-	struct list_head *p;
-	unsigned long flags;
+	struct netpoll *np = skb->dev->np;
 
+	if (!np->rx_hook)
+		goto out;
 	if (skb->dev->type != ARPHRD_ETHER)
 		goto out;
 
@@ -420,30 +406,19 @@
 		goto out;
 	if (checksum_udp(skb, uh, ulen, iph->saddr, iph->daddr) < 0)
 		goto out;
+	if (np->local_ip && np->local_ip != ntohl(iph->daddr))
+		goto out;
+	if (np->remote_ip && np->remote_ip != ntohl(iph->saddr))
+		goto out;
+	if (np->local_port && np->local_port != ntohs(uh->dest))
+		goto out;
 
-	spin_lock_irqsave(&rx_list_lock, flags);
-	list_for_each(p, &rx_list) {
-		np = list_entry(p, struct netpoll, rx_list);
-		if (np->dev && np->dev != skb->dev)
-			continue;
-		if (np->local_ip && np->local_ip != ntohl(iph->daddr))
-			continue;
-		if (np->remote_ip && np->remote_ip != ntohl(iph->saddr))
-			continue;
-		if (np->local_port && np->local_port != ntohs(uh->dest))
-			continue;
-
-		spin_unlock_irqrestore(&rx_list_lock, flags);
-
-		if (np->rx_hook)
-			np->rx_hook(np, ntohs(uh->source),
-				    (char *)(uh+1),
-				    ulen - sizeof(struct udphdr));
+	np->rx_hook(np, ntohs(uh->source),
+		    (char *)(uh+1),
+		    ulen - sizeof(struct udphdr));
 
-		kfree_skb(skb);
-		return 1;
-	}
-	spin_unlock_irqrestore(&rx_list_lock, flags);
+	kfree_skb(skb);
+	return 1;
 
 out:
 	if (atomic_read(&trapped)) {
@@ -574,6 +549,10 @@
 		       np->name, np->dev_name);
 		return -1;
 	}
+
+	np->dev = ndev;
+	ndev->np = np;
+
 	if (!ndev->poll_controller) {
 		printk(KERN_ERR "%s: %s doesn't support polling, aborting.\n",
 		       np->name, np->dev_name);
@@ -639,36 +618,22 @@
 		       np->name, HIPQUAD(np->local_ip));
 	}
 
-	np->dev = ndev;
-
-	if(np->rx_hook) {
-		unsigned long flags;
-
-		np->dev->netpoll_rx = NETPOLL_RX_ENABLED;
-
-		spin_lock_irqsave(&rx_list_lock, flags);
-		list_add(&np->rx_list, &rx_list);
-		spin_unlock_irqrestore(&rx_list_lock, flags);
-	}
+	if(np->rx_hook)
+		np->rx_flags = NETPOLL_RX_ENABLED;
 
 	return 0;
+
  release:
+	ndev->np = NULL;
+	np->dev = NULL;
 	dev_put(ndev);
 	return -1;
 }
 
 void netpoll_cleanup(struct netpoll *np)
 {
-	if (np->rx_hook) {
-		unsigned long flags;
-
-		spin_lock_irqsave(&rx_list_lock, flags);
-		list_del(&np->rx_list);
-		spin_unlock_irqrestore(&rx_list_lock, flags);
-	}
-
 	if (np->dev)
-		np->dev->netpoll_rx = 0;
+		np->dev->np = NULL;
 	dev_put(np->dev);
 	np->dev = NULL;
 }
Index: rc4/include/linux/netpoll.h
===================================================================
--- rc4.orig/include/linux/netpoll.h	2005-02-17 22:32:19.000000000 -0600
+++ rc4/include/linux/netpoll.h	2005-02-17 22:39:59.000000000 -0600
@@ -16,11 +16,11 @@
 struct netpoll {
 	struct net_device *dev;
 	char dev_name[16], *name;
+	int rx_flags;
 	void (*rx_hook)(struct netpoll *, int, char *, int);
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	unsigned char local_mac[6], remote_mac[6];
-	struct list_head rx_list;
 };
 
 void netpoll_poll(struct netpoll *np);
@@ -35,7 +35,7 @@
 #ifdef CONFIG_NETPOLL
 static inline int netpoll_rx(struct sk_buff *skb)
 {
-	return skb->dev->netpoll_rx && __netpoll_rx(skb);
+	return skb->dev->np && skb->dev->np->rx_flags && __netpoll_rx(skb);
 }
 #else
 #define netpoll_rx(a) 0
