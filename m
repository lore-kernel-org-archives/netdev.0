From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/11) bridge -- relax locking on add/delete
Date: Fri, 21 May 2004 15:51:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040521155137.7f4f3250@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Relax the locking on add/delete interfaces to a bridge.  Since these operations
are already called with RTNL semaphore, only need to hold the bridge lock while
doing operations related to STP and processing path.  This is necessary for later
sysfs support where those operations might sleep.

Get rid of some old leftover debug asserts as well.

diff -Nru a/net/bridge/br_if.c b/net/bridge/br_if.c
--- a/net/bridge/br_if.c	2004-05-20 09:23:41 -07:00
+++ b/net/bridge/br_if.c	2004-05-20 09:23:41 -07:00
@@ -78,46 +78,44 @@
 static void destroy_nbp(void *arg)
 {
 	struct net_bridge_port *p = arg;
+	struct net_device *dev = p->dev;
 
-	p->dev->br_port = NULL;
-
-	BUG_ON(timer_pending(&p->message_age_timer));
-	BUG_ON(timer_pending(&p->forward_delay_timer));
-	BUG_ON(timer_pending(&p->hold_timer));
-
-	dev_put(p->dev);
+	dev->br_port = NULL;
+	dev_put(dev);
 	kfree(p);
 }
 
-/* called under bridge lock */
+/* called with RTNL */
 static void del_nbp(struct net_bridge_port *p)
 {
+	struct net_bridge *br = p->br;
 	struct net_device *dev = p->dev;
 
+	dev_set_promiscuity(dev, -1);
+
+	spin_lock_bh(&br->lock);
 	br_stp_disable_port(p);
+	spin_unlock_bh(&br->lock);
 
-	dev_set_promiscuity(dev, -1);
+	br_fdb_delete_by_port(br, p);
 
 	list_del_rcu(&p->list);
 
-	br_fdb_delete_by_port(p->br, p);
-
-	del_timer(&p->message_age_timer);
-	del_timer(&p->forward_delay_timer);
-	del_timer(&p->hold_timer);
+	del_timer_sync(&p->message_age_timer);
+	del_timer_sync(&p->forward_delay_timer);
+	del_timer_sync(&p->hold_timer);
 	
 	call_rcu(&p->rcu, destroy_nbp, p);
 }
 
+/* called with RTNL */
 static void del_br(struct net_bridge *br)
 {
 	struct list_head *p, *n;
 
-	spin_lock_bh(&br->lock);
 	list_for_each_safe(p, n, &br->port_list) {
 		del_nbp(list_entry(p, struct net_bridge_port, list));
 	}
-	spin_unlock_bh(&br->lock);
 
 	del_timer_sync(&br->gc_timer);
 
@@ -171,7 +169,7 @@
 	unsigned long *inuse;
 
 	inuse = kmalloc(BITS_TO_LONGS(BR_MAX_PORTS)*sizeof(unsigned long),
-			GFP_ATOMIC);
+			GFP_KERNEL);
 	if (!inuse)
 		return -ENOMEM;
 
@@ -186,7 +184,7 @@
 	return (index >= BR_MAX_PORTS) ? -EXFULL : index;
 }
 
-/* called under bridge lock */
+/* called with RTNL */
 static struct net_bridge_port *new_nbp(struct net_bridge *br, 
 				       struct net_device *dev,
 				       unsigned long cost)
@@ -198,7 +196,7 @@
 	if (index < 0)
 		return ERR_PTR(index);
 
-	p = kmalloc(sizeof(*p), GFP_ATOMIC);
+	p = kmalloc(sizeof(*p), GFP_KERNEL);
 	if (p == NULL)
 		return ERR_PTR(-ENOMEM);
 
@@ -258,10 +256,10 @@
 	return ret;
 }
 
+/* called with RTNL */
 int br_add_if(struct net_bridge *br, struct net_device *dev)
 {
 	struct net_bridge_port *p;
-	unsigned long cost;
 	int err = 0;
 
 	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
@@ -270,48 +268,45 @@
 	if (dev->hard_start_xmit == br_dev_xmit)
 		return -ELOOP;
 
-	cost = br_initial_port_cost(dev);
-
-	spin_lock_bh(&br->lock);
 	if (dev->br_port != NULL)
-		err = -EBUSY;
+		return -EBUSY;
 
-	else if (IS_ERR(p = new_nbp(br, dev, cost)))
-		err = PTR_ERR(p);
+	if (IS_ERR(p = new_nbp(br, dev, br_initial_port_cost(dev))))
+		return PTR_ERR(p);
 
- 	else if ((err = br_fdb_insert(br, p, dev->dev_addr, 1)))
- 		 destroy_nbp(p);
+ 	if ((err = br_fdb_insert(br, p, dev->dev_addr, 1)))
+		destroy_nbp(p);
  
 	else {
 		dev_set_promiscuity(dev, 1);
 
 		list_add_rcu(&p->list, &br->port_list);
 
+		spin_lock_bh(&br->lock);
 		br_stp_recalculate_bridge_id(br);
 		if ((br->dev->flags & IFF_UP) && (dev->flags & IFF_UP))
 			br_stp_enable_port(p);
-
+		spin_unlock_bh(&br->lock);
 	}
-	spin_unlock_bh(&br->lock);
+
 	return err;
 }
 
+/* called with RTNL */
 int br_del_if(struct net_bridge *br, struct net_device *dev)
 {
-	struct net_bridge_port *p;
-	int err = 0;
+	struct net_bridge_port *p = dev->br_port;
+	
+	if (!p || p->br != br) 
+		return -EINVAL;
+
+	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
-	p = dev->br_port;
-	if (!p || p->br != br) 
-		err = -EINVAL;
-	else {
-		del_nbp(p);
-		br_stp_recalculate_bridge_id(br);
-	}
+	br_stp_recalculate_bridge_id(br);
 	spin_unlock_bh(&br->lock);
 
-	return err;
+	return 0;
 }
 
 int br_get_bridge_ifindices(int *indices, int num)
