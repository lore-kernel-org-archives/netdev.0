From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] (3/3) vlan - use RCU
Date: Tue, 3 Aug 2004 13:43:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803134346.341e5636@dell_ss3.pdx.osdl.net>
References: <20040803105017.0774e1db@dell_ss3.pdx.osdl.net>
	<410FD348.9040301@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>,
        "David S. Miller"
 <davem@redhat.com>
In-Reply-To: <410FD348.9040301@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes VLAN use RCU for the group lookup and removes
the group_lock.  Since all operations that are done under group_lock
already have the rtnetlink semaphore (RTNL), the group_lock is unnecessary.
The result is the vlan code becomes basically lock free in the send/receive
path.


Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/if_vlan.h b/include/linux/if_vlan.h
--- a/include/linux/if_vlan.h	2004-08-03 13:38:50 -07:00
+++ b/include/linux/if_vlan.h	2004-08-03 13:38:50 -07:00
@@ -22,6 +22,7 @@
 struct packet_type;
 struct vlan_collection;
 struct vlan_dev_info;
+struct hlist_node;
 
 #include <linux/proc_fs.h> /* for proc_dir_entry */
 #include <linux/netdevice.h>
@@ -67,9 +68,9 @@
 
 struct vlan_group {
 	int real_dev_ifindex; /* The ifindex of the ethernet(like) device the vlan is attached to. */
+	struct hlist_node	hlist;	/* linked list */
 	struct net_device *vlan_devices[VLAN_GROUP_ARRAY_LEN];
-
-	struct vlan_group *next; /* the next in the list */
+	struct rcu_head		rcu;
 };
 
 struct vlan_priority_tci_mapping {
diff -Nru a/net/8021q/vlan.c b/net/8021q/vlan.c
--- a/net/8021q/vlan.c	2004-08-03 13:38:50 -07:00
+++ b/net/8021q/vlan.c	2004-08-03 13:38:50 -07:00
@@ -38,8 +38,7 @@
 /* Global VLAN variables */
 
 /* Our listing of VLAN group(s) */
-struct vlan_group *vlan_group_hash[VLAN_GRP_HASH_SIZE];
-spinlock_t vlan_group_lock = SPIN_LOCK_UNLOCKED;
+struct hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
 #define vlan_grp_hashfn(IDX)	((((IDX) >> VLAN_GRP_HASH_SHIFT) ^ (IDX)) & VLAN_GRP_HASH_MASK)
 
 static char vlan_fullname[] = "802.1Q VLAN Support";
@@ -150,8 +149,7 @@
 	 * references left.
 	 */
 	for (i = 0; i < VLAN_GRP_HASH_SIZE; i++) {
-		if (vlan_group_hash[i] != NULL)
-			BUG();
+		BUG_ON(!hlist_empty(&vlan_group_hash[i]));
 	}
 	vlan_proc_cleanup();
 
@@ -161,48 +159,24 @@
 module_init(vlan_proto_init);
 module_exit(vlan_cleanup_module);
 
-/* Must be invoked with vlan_group_lock held. */
+/* Must be invoked with RCU read lock (no preempt) */
 static struct vlan_group *__vlan_find_group(int real_dev_ifindex)
 {
 	struct vlan_group *grp;
+	struct hlist_node *n;
+	int hash = vlan_grp_hashfn(real_dev_ifindex);
 
-	for (grp = vlan_group_hash[vlan_grp_hashfn(real_dev_ifindex)];
-	     grp != NULL;
-	     grp = grp->next) {
+	hlist_for_each_entry_rcu(grp, n, &vlan_group_hash[hash], hlist) {
 		if (grp->real_dev_ifindex == real_dev_ifindex)
-			break;
+			return grp;
 	}
 
-	return grp;
-}
-
-/* Must hold vlan_group_lock. */
-static void __grp_hash(struct vlan_group *grp)
-{
-	struct vlan_group **head;
-
-	head = &vlan_group_hash[vlan_grp_hashfn(grp->real_dev_ifindex)];
-	grp->next = *head;
-	*head = grp;
-}
-
-/* Must hold vlan_group_lock. */
-static void __grp_unhash(struct vlan_group *grp)
-{
-	struct vlan_group *next, **pprev;
-
-	pprev = &vlan_group_hash[vlan_grp_hashfn(grp->real_dev_ifindex)];
-	next = *pprev;
-	while (next != grp) {
-		pprev = &next->next;
-		next = *pprev;
-	}
-	*pprev = grp->next;
+	return NULL;
 }
 
 /*  Find the protocol handler.  Assumes VID < VLAN_VID_MASK.
  *
- * Must be invoked with vlan_group_lock held.
+ * Must be invoked with RCU read lock (no preempt)
  */
 struct net_device *__find_vlan_dev(struct net_device *real_dev,
 				   unsigned short VID)
@@ -215,6 +189,12 @@
 	return NULL;
 }
 
+static void vlan_rcu_free(struct rcu_head *rcu)
+{
+	kfree(container_of(rcu, struct vlan_group, rcu));
+}
+
+
 /* This returns 0 if everything went fine.
  * It will return 1 if the group was killed as a result.
  * A negative return indicates failure.
@@ -237,9 +217,8 @@
 	if (vlan_id >= VLAN_VID_MASK)
 		return -EINVAL;
 
-	spin_lock_bh(&vlan_group_lock);
+	ASSERT_RTNL();
 	grp = __vlan_find_group(real_dev_ifindex);
-	spin_unlock_bh(&vlan_group_lock);
 
 	ret = 0;
 
@@ -279,16 +258,12 @@
 				if (real_dev->features & NETIF_F_HW_VLAN_RX)
 					real_dev->vlan_rx_register(real_dev, NULL);
 
-				spin_lock_bh(&vlan_group_lock);
-				__grp_unhash(grp);
-				spin_unlock_bh(&vlan_group_lock);
-
-				/* Free the group, after we have removed it
-				 * from the hash.
-				 */
-				kfree(grp);
-				grp = NULL;
+				hlist_del_rcu(&grp->hlist);
 
+				/* Free the group, after all cpu's are done. */
+				call_rcu(&grp->rcu, vlan_rcu_free);
+
+				grp = NULL;
 				ret = 1;
 			}
 		}
@@ -375,7 +350,6 @@
 	struct vlan_group *grp;
 	struct net_device *new_dev;
 	struct net_device *real_dev; /* the ethernet device */
-	int r;
 	char name[IFNAMSIZ];
 
 #ifdef VLAN_DEBUG
@@ -424,11 +398,7 @@
 	if (!(real_dev->flags & IFF_UP))
 		goto out_unlock;
 
-	spin_lock_bh(&vlan_group_lock);
-	r = (__find_vlan_dev(real_dev, VLAN_ID) != NULL);
-	spin_unlock_bh(&vlan_group_lock);
-
-	if (r) {
+	if (__find_vlan_dev(real_dev, VLAN_ID) != NULL) {
 		/* was already registered. */
 		printk(VLAN_DBG "%s: ALREADY had VLAN registered\n", __FUNCTION__);
 		goto out_unlock;
@@ -527,9 +497,7 @@
 	/* So, got the sucker initialized, now lets place
 	 * it into our local structure.
 	 */
-	spin_lock_bh(&vlan_group_lock);
 	grp = __vlan_find_group(real_dev->ifindex);
-	spin_unlock_bh(&vlan_group_lock);
 
 	/* Note, we are running under the RTNL semaphore
 	 * so it cannot "appear" on us.
@@ -543,9 +511,8 @@
 		memset(grp, 0, sizeof(struct vlan_group));
 		grp->real_dev_ifindex = real_dev->ifindex;
 
-		spin_lock_bh(&vlan_group_lock);
-		__grp_hash(grp);
-		spin_unlock_bh(&vlan_group_lock);
+		hlist_add_head_rcu(&grp->hlist, 
+				   &vlan_group_hash[vlan_grp_hashfn(real_dev->ifindex)]);
 
 		if (real_dev->features & NETIF_F_HW_VLAN_RX)
 			real_dev->vlan_rx_register(real_dev, grp);
@@ -587,14 +554,10 @@
 
 static int vlan_device_event(struct notifier_block *unused, unsigned long event, void *ptr)
 {
-	struct net_device *dev = (struct net_device *)(ptr);
-	struct vlan_group *grp = NULL;
+	struct net_device *dev = ptr;
+	struct vlan_group *grp = __vlan_find_group(dev->ifindex);
 	int i, flgs;
-	struct net_device *vlandev = NULL;
-
-	spin_lock_bh(&vlan_group_lock);
-	grp = __vlan_find_group(dev->ifindex);
-	spin_unlock_bh(&vlan_group_lock);
+	struct net_device *vlandev;
 
 	if (!grp)
 		goto out;
diff -Nru a/net/8021q/vlan.h b/net/8021q/vlan.h
--- a/net/8021q/vlan.h	2004-08-03 13:38:50 -07:00
+++ b/net/8021q/vlan.h	2004-08-03 13:38:50 -07:00
@@ -33,8 +33,7 @@
 #define VLAN_GRP_HASH_SHIFT	5
 #define VLAN_GRP_HASH_SIZE	(1 << VLAN_GRP_HASH_SHIFT)
 #define VLAN_GRP_HASH_MASK	(VLAN_GRP_HASH_SIZE - 1)
-extern struct vlan_group *vlan_group_hash[VLAN_GRP_HASH_SIZE];
-extern spinlock_t vlan_group_lock;
+extern struct  hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
 
 /*  Find a VLAN device by the MAC address of its Ethernet device, and
  *  it's VLAN ID.  The default configuration is to have VLAN's scope
@@ -44,10 +43,8 @@
  *  NOT follow the spec for VLANs, but may be useful for doing very
  *  large quantities of VLAN MUX/DEMUX onto FrameRelay or ATM PVCs.
  *
- *  Must be invoked with vlan_group_lock held and that lock MUST NOT
- *  be dropped until a reference is obtained on the returned device.
- *  You may drop the lock earlier if you are running under the RTNL
- *  semaphore, however.
+ *  Must be invoked with rcu_read_lock (ie preempt disabled)
+ *  or with RTNL.
  */
 struct net_device *__find_vlan_dev(struct net_device* real_dev,
 				   unsigned short VID); /* vlan.c */
diff -Nru a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
--- a/net/8021q/vlan_dev.c	2004-08-03 13:38:50 -07:00
+++ b/net/8021q/vlan_dev.c	2004-08-03 13:38:50 -07:00
@@ -138,15 +138,15 @@
 
 	/* We have 12 bits of vlan ID.
 	 *
-	 * We must not drop the vlan_group_lock until we hold a
+	 * We must not drop allow preempt until we hold a
 	 * reference to the device (netif_rx does that) or we
 	 * fail.
 	 */
 
-	spin_lock_bh(&vlan_group_lock);
+	rcu_read_lock();
 	skb->dev = __find_vlan_dev(dev, vid);
 	if (!skb->dev) {
-		spin_unlock_bh(&vlan_group_lock);
+		rcu_read_unlock();
 
 #ifdef VLAN_DEBUG
 		printk(VLAN_DBG "%s: ERROR: No net_device for VID: %i on dev: %s [%i]\n",
@@ -170,7 +170,7 @@
 	 */
 
 	if (dev != VLAN_DEV_INFO(skb->dev)->real_dev) {
-		spin_unlock_bh(&vlan_group_lock);
+		rcu_read_unlock();
 
 #ifdef VLAN_DEBUG
 		printk(VLAN_DBG "%s: dropping skb: %p because came in on wrong device, dev: %s  real_dev: %s, skb_dev: %s\n",
@@ -244,7 +244,7 @@
 			/* TODO:  Add a more specific counter here. */
 			stats->rx_errors++;
 		}
-		spin_unlock_bh(&vlan_group_lock);
+		rcu_read_lock();
 		return 0;
 	}
 
@@ -273,7 +273,7 @@
 			/* TODO:  Add a more specific counter here. */
 			stats->rx_errors++;
 		}
-		spin_unlock_bh(&vlan_group_lock);
+		rcu_read_unlock();
 		return 0;
 	}
 
@@ -296,7 +296,7 @@
 		/* TODO:  Add a more specific counter here. */
 		stats->rx_errors++;
 	}
-	spin_unlock_bh(&vlan_group_lock);
+	rcu_read_unlock();
 	return 0;
 }
 
