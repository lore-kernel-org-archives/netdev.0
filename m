From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.73] update teql scheduler to dynamic net device
Date: Mon, 23 Jun 2003 11:57:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030623115755.754205ab.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
   Alexey Kuznetsov
 <kuznet@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Change teql scheduler to:
	- dynamically allocate and free the network device.
	  previously, used static network device.
	- support multiple equalizers (default one) via module parameter (max_equalizers)
	  previously, limited to one.

Tested with 2.5.73 on SMP.

--- linux-2.5.73/net/sched/sch_teql.c	2003-06-23 11:39:54.000000000 -0700
+++ linux-2.5-sysfs/net/sched/sch_teql.c	2003-06-23 11:42:22.000000000 -0700
@@ -67,8 +67,9 @@
 struct teql_master
 {
 	struct Qdisc_ops qops;
-	struct net_device dev;
+	struct net_device *dev;
 	struct Qdisc *slaves;
+	struct list_head master_list;
 	struct net_device_stats stats;
 };
 
@@ -122,13 +123,13 @@ teql_dequeue(struct Qdisc* sch)
 
 	skb = __skb_dequeue(&dat->q);
 	if (skb == NULL) {
-		struct net_device *m = dat->m->dev.qdisc->dev;
+		struct net_device *m = dat->m->dev->qdisc->dev;
 		if (m) {
 			dat->m->slaves = sch;
 			netif_wake_queue(m);
 		}
 	}
-	sch->q.qlen = dat->q.qlen + dat->m->dev.qdisc->q.qlen;
+	sch->q.qlen = dat->q.qlen + dat->m->dev->qdisc->q.qlen;
 	return skb;
 }
 
@@ -165,9 +166,9 @@ teql_destroy(struct Qdisc* sch)
 					master->slaves = NEXT_SLAVE(q);
 					if (q == master->slaves) {
 						master->slaves = NULL;
-						spin_lock_bh(&master->dev.queue_lock);
-						qdisc_reset(master->dev.qdisc);
-						spin_unlock_bh(&master->dev.queue_lock);
+						spin_lock_bh(&master->dev->queue_lock);
+						qdisc_reset(master->dev->qdisc);
+						spin_unlock_bh(&master->dev->queue_lock);
 					}
 				}
 				skb_queue_purge(&dat->q);
@@ -185,10 +186,10 @@ static int teql_qdisc_init(struct Qdisc 
 	struct teql_master *m = (struct teql_master*)sch->ops;
 	struct teql_sched_data *q = (struct teql_sched_data *)sch->data;
 
-	if (dev->hard_header_len > m->dev.hard_header_len)
+	if (dev->hard_header_len > m->dev->hard_header_len)
 		return -EINVAL;
 
-	if (&m->dev == dev)
+	if (m->dev == dev)
 		return -ELOOP;
 
 	q->m = m;
@@ -196,29 +197,29 @@ static int teql_qdisc_init(struct Qdisc 
 	skb_queue_head_init(&q->q);
 
 	if (m->slaves) {
-		if (m->dev.flags & IFF_UP) {
-			if ((m->dev.flags&IFF_POINTOPOINT && !(dev->flags&IFF_POINTOPOINT))
-			    || (m->dev.flags&IFF_BROADCAST && !(dev->flags&IFF_BROADCAST))
-			    || (m->dev.flags&IFF_MULTICAST && !(dev->flags&IFF_MULTICAST))
-			    || dev->mtu < m->dev.mtu)
+		if (m->dev->flags & IFF_UP) {
+			if ((m->dev->flags&IFF_POINTOPOINT && !(dev->flags&IFF_POINTOPOINT))
+			    || (m->dev->flags&IFF_BROADCAST && !(dev->flags&IFF_BROADCAST))
+			    || (m->dev->flags&IFF_MULTICAST && !(dev->flags&IFF_MULTICAST))
+			    || dev->mtu < m->dev->mtu)
 				return -EINVAL;
 		} else {
 			if (!(dev->flags&IFF_POINTOPOINT))
-				m->dev.flags &= ~IFF_POINTOPOINT;
+				m->dev->flags &= ~IFF_POINTOPOINT;
 			if (!(dev->flags&IFF_BROADCAST))
-				m->dev.flags &= ~IFF_BROADCAST;
+				m->dev->flags &= ~IFF_BROADCAST;
 			if (!(dev->flags&IFF_MULTICAST))
-				m->dev.flags &= ~IFF_MULTICAST;
-			if (dev->mtu < m->dev.mtu)
-				m->dev.mtu = dev->mtu;
+				m->dev->flags &= ~IFF_MULTICAST;
+			if (dev->mtu < m->dev->mtu)
+				m->dev->mtu = dev->mtu;
 		}
 		q->next = NEXT_SLAVE(m->slaves);
 		NEXT_SLAVE(m->slaves) = sch;
 	} else {
 		q->next = sch;
 		m->slaves = sch;
-		m->dev.mtu = dev->mtu;
-		m->dev.flags = (m->dev.flags&~FMASK)|(dev->flags&FMASK);
+		m->dev->mtu = dev->mtu;
+		m->dev->flags = (m->dev->flags&~FMASK)|(dev->flags&FMASK);
 	}
 	return 0;
 }
@@ -379,9 +380,9 @@ static int teql_master_open(struct net_d
 			flags &= ~IFF_MULTICAST;
 	} while ((q = NEXT_SLAVE(q)) != m->slaves);
 
-	m->dev.mtu = mtu;
-	m->dev.flags = (m->dev.flags&~FMASK) | flags;
-	netif_start_queue(&m->dev);
+	m->dev->mtu = mtu;
+	m->dev->flags = (m->dev->flags&~FMASK) | flags;
+	netif_start_queue(m->dev);
 	return 0;
 }
 
@@ -417,8 +418,30 @@ static int teql_master_mtu(struct net_de
 	return 0;
 }
 
-static int teql_master_init(struct net_device *dev)
+static __init int teql_master_init(struct net_device *dev)
 {
+	struct teql_master *master = dev->priv;
+	struct Qdisc_ops *ops = &master->qops;
+
+	master->dev	= dev;
+
+	strlcpy(ops->id, dev->name, IFNAMSIZ);
+	ops->priv_size  = sizeof(struct teql_sched_data);
+	
+	ops->enqueue	=	teql_enqueue;
+	ops->dequeue	=	teql_dequeue;
+	ops->requeue	=	teql_requeue;
+	ops->init	=	teql_qdisc_init;
+	ops->reset	=	teql_reset;
+	ops->destroy	=	teql_destroy;
+	ops->owner	=	THIS_MODULE;
+
+	return register_qdisc(ops);
+}
+
+static __init void teql_master_setup(struct net_device *dev)
+{
+	dev->init		= teql_master_init;
 	dev->open		= teql_master_open;
 	dev->hard_start_xmit	= teql_master_xmit;
 	dev->stop		= teql_master_close;
@@ -429,62 +452,58 @@ static int teql_master_init(struct net_d
 	dev->tx_queue_len	= 100;
 	dev->flags		= IFF_NOARP;
 	dev->hard_header_len	= LL_MAX_HEADER;
-	return 0;
+	SET_MODULE_OWNER(dev);
 }
 
-static struct teql_master the_master = {
-{
-	.next		=	NULL,
-	.cl_ops		=	NULL,
-	.id		=	"",
-	.priv_size	=	sizeof(struct teql_sched_data),
-	.enqueue	=	teql_enqueue,
-	.dequeue	=	teql_dequeue,
-	.requeue	=	teql_requeue,
-	.drop		=	NULL,
-	.init		=	teql_qdisc_init,
-	.reset		=	teql_reset,
-	.destroy	=	teql_destroy,
-	.dump		=	NULL,
-	.owner		=	THIS_MODULE,
-},};
-
-
-#ifdef MODULE
-int init_module(void)
-#else
+static LIST_HEAD(master_dev_list);
+static spinlock_t master_dev_lock = SPIN_LOCK_UNLOCKED;
+static int max_equalizers = 1;
+MODULE_PARM(max_equalizers, "i");
+MODULE_PARM_DESC(max_equalizers, "Max number of link equalizers");
+
 int __init teql_init(void)
-#endif
 {
-	int err;
-
-	rtnl_lock();
+	int i;
+	int err = 0;
 
-	the_master.dev.priv = (void*)&the_master;
-	err = dev_alloc_name(&the_master.dev, "teql%d");
-	if (err < 0)
-		return err;
-	memcpy(the_master.qops.id, the_master.dev.name, IFNAMSIZ);
-	the_master.dev.init = teql_master_init;
-
-	SET_MODULE_OWNER(&the_master.dev);
-	err = register_netdevice(&the_master.dev);
-	if (err == 0) {
-		err = register_qdisc(&the_master.qops);
-		if (err)
-			unregister_netdevice(&the_master.dev);
+	for (i = 0; i < max_equalizers; i++) {
+		struct net_device *dev;
+		struct teql_master *master;
+
+		dev = alloc_netdev(sizeof(struct teql_master),
+				  "teql%d", teql_master_setup);
+		if (!dev)
+			return -ENOMEM;
+
+		if ((err = register_netdev(dev)))
+			goto out;
+
+		master = dev->priv;
+		spin_lock(&master_dev_lock);
+		list_add_tail(&master->master_list, &master_dev_list);
+		spin_unlock(&master_dev_lock);
 	}
-	rtnl_unlock();
+ out:
 	return err;
 }
 
-#ifdef MODULE
-void cleanup_module(void) 
+static void __exit teql_exit(void) 
 {
-	rtnl_lock();
-	unregister_qdisc(&the_master.qops);
-	unregister_netdevice(&the_master.dev);
-	rtnl_unlock();
+	struct teql_master *master, *nxt;
+
+	spin_lock(&master_dev_lock);
+	list_for_each_entry_safe(master, nxt, &master_dev_list, master_list) {
+
+		list_del(&master->master_list);
+
+		unregister_qdisc(&master->qops);
+		unregister_netdev(master->dev);
+		kfree(master->dev);
+	}
+	spin_unlock(&master_dev_lock);
 }
-#endif
+
+module_init(teql_init);
+module_exit(teql_exit);
+
 MODULE_LICENSE("GPL");
