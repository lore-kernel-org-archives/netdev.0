From: Matt Mackall <mpm@selenic.com>
Subject: Re: serious netpoll bug w/NAPI
Date: Wed, 9 Feb 2005 17:11:04 -0800
Message-ID: <20050210011104.GF2366@waste.org>
References: <20050208201634.03074349.davem@davemloft.net> <20050209183219.GA2366@waste.org> <20050209164658.409f8950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Cc: jmoyer@redhat.com, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050209164658.409f8950.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Feb 09, 2005 at 04:46:58PM -0800, David S. Miller wrote:
> On Wed, 9 Feb 2005 10:32:19 -0800
> Matt Mackall <mpm@selenic.com> wrote:
> 
> > On closer inspection, there's a couple other related failure cases
> > with the new ->poll logic in netpoll. I'm afraid it looks like
> > CONFIG_NETPOLL will need to guard ->poll() with a per-device spinlock
> > on netpoll-enabled devices.
> > 
> > This will mean putting a pointer to struct netpoll in struct
> > net_device (which I should have done in the first place) and will take
> > a few patches to sort out.
> 
> Will this ->poll() guarding lock be acquired only in the netpoll
> code or system-wide?  If the latter, this introduced an incredible
> performance regression for devices using the LLTX locking scheme
> (ie. the most important high-performance gigabit drivers in the
> tree use this).

The lock will only be taken in net_rx_action iff netpoll is enabled
for the given device. Lock contention should be basically nil.

Here's my current patch (on top of -mm), which I'm struggling to find
an appropriate test box for (my dual box with NAPI got pressed into
service as a web server a couple weeks ago). I've attached the other
two patches it relies on as well.

--------------

Introduce a per-client poll lock and flag. The lock assures we never
have more than one caller in dev->poll(). The flag provides recursion
avoidance on UP where the lock disappears.

Index: mm1npc/include/linux/netpoll.h
===================================================================
--- mm1npc.orig/include/linux/netpoll.h	2005-02-09 14:15:12.471051000 -0800
+++ mm1npc/include/linux/netpoll.h	2005-02-09 14:46:22.374083000 -0800
@@ -21,6 +21,8 @@
 	u32 local_ip, remote_ip;
 	u16 local_port, remote_port;
 	unsigned char local_mac[6], remote_mac[6];
+	spinlock_t poll_lock;
+	int poll_flag;
 };
 
 void netpoll_poll(struct netpoll *np);
@@ -37,8 +39,27 @@
 {
 	return skb->dev->np && skb->dev->np->rx_flags && __netpoll_rx(skb);
 }
+
+static inline void netpoll_poll_lock(struct net_device *dev)
+{
+	if (dev->np) {
+		spin_lock(&dev->np->poll_lock);
+		dev->np->poll_flag = 1;
+	}
+}
+
+static inline void netpoll_poll_unlock(struct net_device *dev)
+{
+	if (dev->np) {
+		dev->np->poll_flag = 0;
+		spin_unlock(&dev->np->poll_lock);
+	}
+}
+
 #else
 #define netpoll_rx(a) 0
+#define netpoll_poll_lock(a)
+#define netpoll_poll_unlock(a)
 #endif
 
 #endif
Index: mm1npc/net/core/dev.c
===================================================================
--- mm1npc.orig/net/core/dev.c	2005-02-09 14:15:11.236086000 -0800
+++ mm1npc/net/core/dev.c	2005-02-09 14:15:13.710042000 -0800
@@ -1772,6 +1772,7 @@
 
 		dev = list_entry(queue->poll_list.next,
 				 struct net_device, poll_list);
+		netpoll_poll_lock(dev);
 
 		if (dev->quota <= 0 || dev->poll(dev, &budget)) {
 			local_irq_disable();
@@ -1782,9 +1783,11 @@
 			else
 				dev->quota = dev->weight;
 		} else {
+			netpoll_poll_unlock(dev);
 			dev_put(dev);
 			local_irq_disable();
 		}
+		netpoll_poll_unlock(dev);
 
 #ifdef CONFIG_KGDBOE
 		kgdb_process_breakpoint();
Index: mm1npc/net/core/netpoll.c
===================================================================
--- mm1npc.orig/net/core/netpoll.c	2005-02-09 14:15:12.466070000 -0800
+++ mm1npc/net/core/netpoll.c	2005-02-09 14:48:44.506107000 -0800
@@ -36,7 +36,6 @@
 static struct sk_buff *skbs;
 
 static atomic_t trapped;
-static DEFINE_SPINLOCK(netpoll_poll_lock);
 
 #define NETPOLL_RX_ENABLED  1
 #define NETPOLL_RX_DROP     2
@@ -63,8 +62,15 @@
 }
 
 /*
- * Check whether delayed processing was scheduled for our current CPU,
- * and then manually invoke NAPI polling to pump data off the card.
+ * Check whether delayed processing was scheduled for our NIC. If so,
+ * we attempt to grab the poll lock and use ->poll() to pump the card.
+ * If this fails, either we've recursed in ->poll() or it's already
+ * running on another CPU.
+ *
+ * Note: we don't mask interrupts with this lock because we're using
+ * trylock here and interrupts are already disabled in the softirq
+ * case. Further, we test the poll_flag to avoid recursion on UP
+ * systems where the lock doesn't exist.
  *
  * In cases where there is bi-directional communications, reading only
  * one message at a time can lead to packets being dropped by the
@@ -74,13 +80,9 @@
 static void poll_napi(struct netpoll *np)
 {
 	int budget = 16;
-	unsigned long flags;
-	struct softnet_data *queue;
 
-	spin_lock_irqsave(&netpoll_poll_lock, flags);
-	queue = &__get_cpu_var(softnet_data);
 	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
-	    !list_empty(&queue->poll_list)) {
+	    !np->poll_flag && spin_trylock(&np->poll_lock)) {
 		np->rx_flags |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
 
@@ -88,8 +90,8 @@
 
 		atomic_dec(&trapped);
 		np->rx_flags &= ~NETPOLL_RX_DROP;
+		spin_unlock(&np->poll_lock);
 	}
-	spin_unlock_irqrestore(&netpoll_poll_lock, flags);
 }
 
 void netpoll_poll(struct netpoll *np)
@@ -276,7 +278,6 @@
 	int size, type = ARPOP_REPLY, ptype = ETH_P_ARP;
 	u32 sip, tip;
 	struct sk_buff *send_skb;
-	unsigned long flags;
 	struct netpoll *np = skb->dev->np;
 
 	if (!np) return;
@@ -360,7 +361,7 @@
 	int proto, len, ulen;
 	struct iphdr *iph;
 	struct udphdr *uh;
-	struct netpoll *np;
+	struct netpoll *np = skb->dev->np;
 
 	if (!np->rx_hook)
 		goto out;
@@ -618,6 +619,7 @@
 
 	if(np->rx_hook)
 		np->rx_flags = NETPOLL_RX_ENABLED;
+	np->poll_lock = SPIN_LOCK_UNLOCKED;
 	np->dev = ndev;
 	ndev->np = np;
 

 
> I know you want to do anything except drop the packet.  What you
> may do instead, therefore, is add the packet to the normal device
> mid-layer queue and kick NET_TX_ACTION if netif_queue_stopped() is
> true.

Actually, I think it's better to keep the midlayer out of it. Netpoll
clients like netdump and kgdb basically stop the machine so queueing
to avoid deadlock is just not going to work. 

> As an aside, ipt_LOG is a great stress test for netpoll, because 4
> incoming packets can generate 8 outgoing packets worth of netconsole
> traffic :-)

-- 
Mathematics is the supreme nostalgia of our time.

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="netpoll-helpers.patch"

Add netpoll rx helpers 
Move skb_free for rx into __netpoll_rx

Index: mm1/net/core/netpoll.c
===================================================================
--- mm1.orig/net/core/netpoll.c	2005-02-09 10:51:43.000000000 -0800
+++ mm1/net/core/netpoll.c	2005-02-09 11:36:15.000000000 -0800
@@ -368,7 +368,7 @@
 	netpoll_send_skb(np, send_skb);
 }
 
-int netpoll_rx(struct sk_buff *skb)
+int __netpoll_rx(struct sk_buff *skb)
 {
 	int proto, len, ulen;
 	struct iphdr *iph;
@@ -440,12 +440,18 @@
 				    (char *)(uh+1),
 				    ulen - sizeof(struct udphdr));
 
+		kfree_skb(skb);
 		return 1;
 	}
 	spin_unlock_irqrestore(&rx_list_lock, flags);
 
 out:
-	return atomic_read(&trapped);
+	if (atomic_read(&trapped)) {
+		kfree_skb(skb);
+		return 1;
+	}
+
+	return 0;
 }
 
 int netpoll_parse_options(struct netpoll *np, char *opt)
Index: mm1/include/linux/netpoll.h
===================================================================
--- mm1.orig/include/linux/netpoll.h	2005-02-09 10:40:59.000000000 -0800
+++ mm1/include/linux/netpoll.h	2005-02-09 11:36:15.000000000 -0800
@@ -30,7 +30,15 @@
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
 void netpoll_cleanup(struct netpoll *np);
-int netpoll_rx(struct sk_buff *skb);
+int __netpoll_rx(struct sk_buff *skb);
 
+#ifdef CONFIG_NETPOLL
+static inline int netpoll_rx(struct sk_buff *skb)
+{
+	return skb->dev->netpoll_rx && __netpoll_rx(skb);
+}
+#else
+#define netpoll_rx(a) 0
+#endif
 
 #endif
Index: mm1/net/core/dev.c
===================================================================
--- mm1.orig/net/core/dev.c	2005-02-09 10:40:59.000000000 -0800
+++ mm1/net/core/dev.c	2005-02-09 11:36:20.000000000 -0800
@@ -1425,13 +1425,10 @@
 	struct softnet_data *queue;
 	unsigned long flags;
 
-#ifdef CONFIG_NETPOLL
-	if (skb->dev->netpoll_rx && netpoll_rx(skb)) {
-		kfree_skb(skb);
+	/* if netpoll wants it, pretend we never saw it */
+	if (netpoll_rx(skb))
 		return NET_RX_DROP;
-	}
-#endif
-	
+
 	if (!skb->stamp.tv_sec)
 		net_timestamp(&skb->stamp);
 
@@ -1627,12 +1624,9 @@
 	int ret = NET_RX_DROP;
 	unsigned short type;
 
-#ifdef CONFIG_NETPOLL
-	if (skb->dev->netpoll_rx && skb->dev->poll && netpoll_rx(skb)) {
-		kfree_skb(skb);
+	/* if we've gotten here through NAPI, check netpoll */
+	if (skb->dev->poll && netpoll_rx(skb))
 		return NET_RX_DROP;
-	}
-#endif
 
 	if (!skb->stamp.tv_sec)
 		net_timestamp(&skb->stamp);

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="netpoll-in-dev.patch"

Add struct netpoll pointer to struct netdevice
Move netpoll rx flags to netpoll struct
Stop traversing rx_list and get np pointer from skb->dev->np
Remove now unneeded rx_list

Index: mm1/include/linux/netdevice.h
===================================================================
--- mm1.orig/include/linux/netdevice.h	2005-02-09 11:36:15.000000000 -0800
+++ mm1/include/linux/netdevice.h	2005-02-09 11:36:39.000000000 -0800
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
Index: mm1/net/core/netpoll.c
===================================================================
--- mm1.orig/net/core/netpoll.c	2005-02-09 11:36:15.000000000 -0800
+++ mm1/net/core/netpoll.c	2005-02-09 11:37:38.000000000 -0800
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
@@ -280,17 +277,7 @@
 	u32 sip, tip;
 	struct sk_buff *send_skb;
 	unsigned long flags;
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
 
@@ -374,9 +361,9 @@
 	struct iphdr *iph;
 	struct udphdr *uh;
 	struct netpoll *np;
-	struct list_head *p;
-	unsigned long flags;
 
+	if (!np->rx_hook)
+		goto out;
 	if (skb->dev->type != ARPHRD_ETHER)
 		goto out;
 
@@ -420,30 +407,19 @@
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
@@ -639,17 +615,11 @@
 		       np->name, HIPQUAD(np->local_ip));
 	}
 
-	np->dev = ndev;
-
-	if(np->rx_hook) {
-		unsigned long flags;
-
-		np->dev->netpoll_rx = NETPOLL_RX_ENABLED;
 
-		spin_lock_irqsave(&rx_list_lock, flags);
-		list_add(&np->rx_list, &rx_list);
-		spin_unlock_irqrestore(&rx_list_lock, flags);
-	}
+	if(np->rx_hook)
+		np->rx_flags = NETPOLL_RX_ENABLED;
+	np->dev = ndev;
+	ndev->np = np;
 
 	return 0;
  release:
@@ -659,16 +629,8 @@
 
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
Index: mm1/include/linux/netpoll.h
===================================================================
--- mm1.orig/include/linux/netpoll.h	2005-02-09 11:36:15.000000000 -0800
+++ mm1/include/linux/netpoll.h	2005-02-09 11:36:39.000000000 -0800
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

--opJtzjQTFsWo+cga--
