From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/11) netrom - convert route/node tables to hlist
Date: Wed, 13 Aug 2003 15:42:34 -0700
Sender: linux-hams-owner@vger.kernel.org
Message-ID: <20030813154234.68497928.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>,
	Jeroen Vreeken <pe1rxq@amsat.org>
List-Id: netdev.vger.kernel.org

From: Jeroen Vreeken <pe1rxq@amsat.org>

Use hlist for the routing table information.

Note: there is a call to ax25_cb_put commented out, that
can be added back when ax25 refcount patches go in.

diff -Nru a/include/net/netrom.h b/include/net/netrom.h
--- a/include/net/netrom.h	Wed Aug 13 13:20:27 2003
+++ b/include/net/netrom.h	Wed Aug 13 13:20:27 2003
@@ -7,6 +7,7 @@
 #ifndef _NETROM_H
 #define _NETROM_H 
 #include <linux/netrom.h>
+#include <linux/list.h>
 
 #define	NR_NETWORK_LEN			15
 #define	NR_TRANSPORT_LEN		5
@@ -77,16 +78,17 @@
 #define nr_sk(__sk) ((nr_cb *)(__sk)->sk_protinfo)
 
 struct nr_neigh {
-	struct nr_neigh *next;
-	ax25_address    callsign;
-	ax25_digi       *digipeat;
-	ax25_cb		*ax25;
-	struct net_device   *dev;
-	unsigned char   quality;
-	unsigned char   locked;
-	unsigned short  count;
-	unsigned int    number;
-	unsigned char	failed;
+	struct hlist_node	neigh_node;
+	ax25_address		callsign;
+	ax25_digi		*digipeat;
+	ax25_cb			*ax25;
+	struct net_device	*dev;
+	unsigned char		quality;
+	unsigned char		locked;
+	unsigned short		count;
+	unsigned int		number;
+	unsigned char		failed;
+	atomic_t		refcount;
 };
 
 struct nr_route {
@@ -96,13 +98,73 @@
 };
 
 struct nr_node {
-	struct nr_node  *next;
-	ax25_address    callsign;
-	char		mnemonic[7];
-	unsigned char   which;
-	unsigned char   count;
-	struct nr_route routes[3];
+	struct hlist_node	node_node;
+	ax25_address		callsign;
+	char			mnemonic[7];
+	unsigned char		which;
+	unsigned char		count;
+	struct nr_route		routes[3];
+	atomic_t		refcount;
+	spinlock_t		node_lock;
 };
+
+/*********************************************************************
+ *	nr_node & nr_neigh lists, refcounting and locking
+ *********************************************************************/
+
+extern struct hlist_head nr_node_list;
+extern struct hlist_head nr_neigh_list;
+
+#define nr_node_hold(__nr_node) \
+	atomic_inc(&((__nr_node)->refcount))
+
+static __inline__ void nr_node_put(struct nr_node *nr_node)
+{
+	if (atomic_dec_and_test(&nr_node->refcount)) {
+		kfree(nr_node);
+	}
+}
+
+#define nr_neigh_hold(__nr_neigh) \
+	atomic_inc(&((__nr_neigh)->refcount))
+
+static __inline__ void nr_neigh_put(struct nr_neigh *nr_neigh)
+{
+	if (atomic_dec_and_test(&nr_neigh->refcount)) {
+		if (nr_neigh->digipeat != NULL)
+			kfree(nr_neigh->digipeat);
+		kfree(nr_neigh);
+	}
+}
+
+/* nr_node_lock and nr_node_unlock also hold/put the node's refcounter.
+ */
+static __inline__ void nr_node_lock(struct nr_node *nr_node)
+{
+	nr_node_hold(nr_node);
+	spin_lock_bh(&nr_node->node_lock);
+}
+
+static __inline__ void nr_node_unlock(struct nr_node *nr_node)
+{
+	spin_unlock_bh(&nr_node->node_lock);
+	nr_node_put(nr_node);
+}
+
+#define nr_neigh_for_each(__nr_neigh, node, list) \
+	hlist_for_each_entry(__nr_neigh, node, list, neigh_node)
+
+#define nr_neigh_for_each_safe(__nr_neigh, node, node2, list) \
+	hlist_for_each_entry_safe(__nr_neigh, node, node2, list, neigh_node)
+
+#define nr_node_for_each(__nr_node, node, list) \
+	hlist_for_each_entry(__nr_node, node, list, node_node)
+
+#define nr_node_for_each_safe(__nr_node, node, node2, list) \
+	hlist_for_each_entry_safe(__nr_node, node, node2, list, node_node)
+
+
+/*********************************************************************/
 
 /* af_netrom.c */
 extern int  sysctl_netrom_default_path_quality;
diff -Nru a/net/netrom/nr_route.c b/net/netrom/nr_route.c
--- a/net/netrom/nr_route.c	Wed Aug 13 13:20:27 2003
+++ b/net/netrom/nr_route.c	Wed Aug 13 13:20:27 2003
@@ -39,10 +39,45 @@
 
 static unsigned int nr_neigh_no = 1;
 
-static struct nr_node  *nr_node_list;
-static spinlock_t nr_node_lock;
-static struct nr_neigh *nr_neigh_list;
-static spinlock_t nr_neigh_lock;
+HLIST_HEAD(nr_node_list);
+spinlock_t nr_node_list_lock = SPIN_LOCK_UNLOCKED;
+HLIST_HEAD(nr_neigh_list);
+spinlock_t nr_neigh_list_lock = SPIN_LOCK_UNLOCKED;
+
+struct nr_node *nr_node_get(ax25_address *callsign)
+{
+	struct nr_node *found = NULL;
+	struct nr_node *nr_node;
+	struct hlist_node *node;
+
+	spin_lock_bh(&nr_node_list_lock);
+	nr_node_for_each(nr_node, node, &nr_node_list)
+		if (ax25cmp(callsign, &nr_node->callsign) == 0) {
+			nr_node_hold(nr_node);
+			found = nr_node;
+			break;
+		}
+	spin_unlock_bh(&nr_node_list_lock);
+	return found;
+}
+
+struct nr_neigh *nr_neigh_get_dev(ax25_address *callsign, struct net_device *dev)
+{
+	struct nr_neigh *found = NULL;
+	struct nr_neigh *nr_neigh;
+	struct hlist_node *node;
+
+	spin_lock_bh(&nr_neigh_list_lock);
+	nr_neigh_for_each(nr_neigh, node, &nr_neigh_list)
+		if (ax25cmp(callsign, &nr_neigh->callsign) == 0 &&
+		    nr_neigh->dev == dev) {
+			nr_neigh_hold(nr_neigh);
+			found = nr_neigh;
+			break;
+		}
+	spin_unlock_bh(&nr_neigh_list_lock);
+	return found;
+}
 
 static void nr_remove_neigh(struct nr_neigh *);
 
@@ -57,17 +92,16 @@
 	struct nr_neigh *nr_neigh;
 	struct nr_route nr_route;
 	int i, found;
+	struct net_device *odev;
 
-	if (nr_dev_get(nr) != NULL)	/* Can't add routes to ourself */
+	if ((odev=nr_dev_get(nr)) != NULL) {	/* Can't add routes to ourself */
+		dev_put(odev);
 		return -EINVAL;
+	}
 
-	for (nr_node = nr_node_list; nr_node != NULL; nr_node = nr_node->next)
-		if (ax25cmp(nr, &nr_node->callsign) == 0)
-			break;
+	nr_node = nr_node_get(nr);
 
-	for (nr_neigh = nr_neigh_list; nr_neigh != NULL; nr_neigh = nr_neigh->next)
-		if (ax25cmp(ax25, &nr_neigh->callsign) == 0 && nr_neigh->dev == dev)
-			break;
+	nr_neigh = nr_neigh_get_dev(ax25, dev);
 
 	/*
 	 * The L2 link to a neighbour has failed in the past
@@ -76,24 +110,36 @@
 	 * routes now (and not wait for a node broadcast).
 	 */
 	if (nr_neigh != NULL && nr_neigh->failed != 0 && quality == 0) {
-		struct nr_node *node;
+		struct nr_node *nr_nodet;
+		struct hlist_node *node;
 
-		for (node = nr_node_list; node != NULL; node = node->next)
-			for (i = 0; i < node->count; i++)
-				if (node->routes[i].neighbour == nr_neigh)
-					if (i < node->which)
-						node->which = i;
+		spin_lock_bh(&nr_node_list_lock);
+		nr_node_for_each(nr_nodet, node, &nr_node_list) {
+			nr_node_lock(nr_nodet);
+			for (i = 0; i < nr_nodet->count; i++)
+				if (nr_nodet->routes[i].neighbour == nr_neigh)
+					if (i < nr_nodet->which)
+						nr_nodet->which = i;
+			nr_node_unlock(nr_nodet);
+		}
+		spin_unlock_bh(&nr_node_list_lock);
 	}
 
 	if (nr_neigh != NULL)
 		nr_neigh->failed = 0;
 
-	if (quality == 0 && nr_neigh != NULL && nr_node != NULL)
+	if (quality == 0 && nr_neigh != NULL && nr_node != NULL) {
+		nr_neigh_put(nr_neigh);
+		nr_node_put(nr_node);
 		return 0;
+	}
 
 	if (nr_neigh == NULL) {
-		if ((nr_neigh = kmalloc(sizeof(*nr_neigh), GFP_ATOMIC)) == NULL)
+		if ((nr_neigh = kmalloc(sizeof(*nr_neigh), GFP_ATOMIC)) == NULL) {
+			if (nr_node)
+				nr_node_put(nr_node);
 			return -ENOMEM;
+		}
 
 		nr_neigh->callsign = *ax25;
 		nr_neigh->digipeat = NULL;
@@ -104,48 +150,58 @@
 		nr_neigh->count    = 0;
 		nr_neigh->number   = nr_neigh_no++;
 		nr_neigh->failed   = 0;
+		atomic_set(&nr_neigh->refcount, 1);
 
 		if (ax25_digi != NULL && ax25_digi->ndigi > 0) {
 			if ((nr_neigh->digipeat = kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
 				kfree(nr_neigh);
+				if (nr_node)
+					nr_node_put(nr_node);
 				return -ENOMEM;
 			}
 			memcpy(nr_neigh->digipeat, ax25_digi,
 					sizeof(*ax25_digi));
 		}
 
-		spin_lock_bh(&nr_neigh_lock);
-		nr_neigh->next = nr_neigh_list;
-		nr_neigh_list  = nr_neigh;
-		spin_unlock_bh(&nr_neigh_lock);
+		spin_lock_bh(&nr_neigh_list_lock);
+		hlist_add_head(&nr_neigh->neigh_node, &nr_neigh_list);
+		nr_neigh_hold(nr_neigh);
+		spin_unlock_bh(&nr_neigh_list_lock);
 	}
 
 	if (quality != 0 && ax25cmp(nr, ax25) == 0 && !nr_neigh->locked)
 		nr_neigh->quality = quality;
 
 	if (nr_node == NULL) {
-		if ((nr_node = kmalloc(sizeof(*nr_node), GFP_ATOMIC)) == NULL)
+		if ((nr_node = kmalloc(sizeof(*nr_node), GFP_ATOMIC)) == NULL) {
+			if (nr_neigh)
+				nr_neigh_put(nr_neigh);
 			return -ENOMEM;
+		}
 
 		nr_node->callsign = *nr;
 		strcpy(nr_node->mnemonic, mnemonic);
 
 		nr_node->which = 0;
 		nr_node->count = 1;
+		atomic_set(&nr_node->refcount, 1);
+		nr_node->node_lock = SPIN_LOCK_UNLOCKED;
 
 		nr_node->routes[0].quality   = quality;
 		nr_node->routes[0].obs_count = obs_count;
 		nr_node->routes[0].neighbour = nr_neigh;
 
-		spin_lock_bh(&nr_node_lock);
-		nr_node->next = nr_node_list;
-		nr_node_list  = nr_node;
-		spin_unlock_bh(&nr_node_lock);
-
+		nr_neigh_hold(nr_neigh);
 		nr_neigh->count++;
 
+		spin_lock_bh(&nr_node_list_lock);
+		hlist_add_head(&nr_node->node_node, &nr_node_list);
+		/* refcount initialized at 1 */
+		spin_unlock_bh(&nr_node_list_lock);
+
 		return 0;
 	}
+	nr_node_lock(nr_node);
 
 	if (quality != 0)
 		strcpy(nr_node->mnemonic, mnemonic);
@@ -171,11 +227,13 @@
 
 			nr_node->which++;
 			nr_node->count++;
+			nr_neigh_hold(nr_neigh);
 			nr_neigh->count++;
 		} else {
 			/* It must be better than the worst */
 			if (quality > nr_node->routes[2].quality) {
 				nr_node->routes[2].neighbour->count--;
+				nr_neigh_put(nr_node->routes[2].neighbour);
 
 				if (nr_node->routes[2].neighbour->count == 0 && !nr_node->routes[2].neighbour->locked)
 					nr_remove_neigh(nr_node->routes[2].neighbour);
@@ -184,6 +242,7 @@
 				nr_node->routes[2].obs_count = obs_count;
 				nr_node->routes[2].neighbour = nr_neigh;
 
+				nr_neigh_hold(nr_neigh);
 				nr_neigh->count++;
 			}
 		}
@@ -244,62 +303,42 @@
 		}
 	}
 
+	nr_neigh_put(nr_neigh);
+	nr_node_unlock(nr_node);
+	nr_node_put(nr_node);
 	return 0;
 }
 
-static void nr_remove_node(struct nr_node *nr_node)
+static inline void __nr_remove_node(struct nr_node *nr_node)
 {
-	struct nr_node *s;
-
-	spin_lock_bh(&nr_node_lock);
-	if ((s = nr_node_list) == nr_node) {
-		nr_node_list = nr_node->next;
-		spin_unlock_bh(&nr_node_lock);
-		kfree(nr_node);
-		return;
-	}
-
-	while (s != NULL && s->next != NULL) {
-		if (s->next == nr_node) {
-			s->next = nr_node->next;
-			spin_unlock_bh(&nr_node_lock);
-			kfree(nr_node);
-			return;
-		}
+	hlist_del_init(&nr_node->node_node);
+	nr_node_put(nr_node);
+}
 
-		s = s->next;
-	}
+#define nr_remove_node_locked(__node) \
+	__nr_remove_node(__node)
 
-	spin_unlock_bh(&nr_node_lock);
+static void nr_remove_node(struct nr_node *nr_node)
+{
+	spin_lock_bh(&nr_node_list_lock);
+	__nr_remove_node(nr_node);
+	spin_unlock_bh(&nr_node_list_lock);
 }
 
-static void nr_remove_neigh(struct nr_neigh *nr_neigh)
+static inline void __nr_remove_neigh(struct nr_neigh *nr_neigh)
 {
-	struct nr_neigh *s;
+	hlist_del_init(&nr_neigh->neigh_node);
+	nr_neigh_put(nr_neigh);
+}
 
-	spin_lock_bh(&nr_neigh_lock);
-	if ((s = nr_neigh_list) == nr_neigh) {
-		nr_neigh_list = nr_neigh->next;
-		spin_unlock_bh(&nr_neigh_lock);
-		if (nr_neigh->digipeat != NULL)
-			kfree(nr_neigh->digipeat);
-		kfree(nr_neigh);
-		return;
-	}
+#define nr_remove_neigh_locked(__neigh) \
+	__nr_remove_neigh(__neigh)
 
-	while (s != NULL && s->next != NULL) {
-		if (s->next == nr_neigh) {
-			s->next = nr_neigh->next;
-			spin_unlock_bh(&nr_neigh_lock);
-			if (nr_neigh->digipeat != NULL)
-				kfree(nr_neigh->digipeat);
-			kfree(nr_neigh);
-			return;
-		}
-
-		s = s->next;
-	}
-	spin_unlock_bh(&nr_neigh_lock);
+static void nr_remove_neigh(struct nr_neigh *nr_neigh)
+{
+	spin_lock_bh(&nr_neigh_list_lock);
+	__nr_remove_neigh(nr_neigh);
+	spin_unlock_bh(&nr_neigh_list_lock);
 }
 
 /*
@@ -312,26 +351,27 @@
 	struct nr_neigh *nr_neigh;
 	int i;
 
-	for (nr_node = nr_node_list; nr_node != NULL; nr_node = nr_node->next)
-		if (ax25cmp(callsign, &nr_node->callsign) == 0)
-			break;
+	nr_node = nr_node_get(callsign);
 
 	if (nr_node == NULL)
 		return -EINVAL;
 
-	for (nr_neigh = nr_neigh_list; nr_neigh != NULL; nr_neigh = nr_neigh->next)
-		if (ax25cmp(neighbour, &nr_neigh->callsign) == 0 && nr_neigh->dev == dev)
-			break;
+	nr_neigh = nr_neigh_get_dev(neighbour, dev);
 
-	if (nr_neigh == NULL)
+	if (nr_neigh == NULL) {
+		nr_node_put(nr_node);
 		return -EINVAL;
+	}
 
+	nr_node_lock(nr_node);
 	for (i = 0; i < nr_node->count; i++) {
 		if (nr_node->routes[i].neighbour == nr_neigh) {
 			nr_neigh->count--;
+			nr_neigh_put(nr_neigh);
 
 			if (nr_neigh->count == 0 && !nr_neigh->locked)
 				nr_remove_neigh(nr_neigh);
+			nr_neigh_put(nr_neigh);
 
 			nr_node->count--;
 
@@ -346,11 +386,16 @@
 				case 2:
 					break;
 				}
+				nr_node_put(nr_node);
 			}
+			nr_node_unlock(nr_node);
 
 			return 0;
 		}
 	}
+	nr_neigh_put(nr_neigh);
+	nr_node_unlock(nr_node);
+	nr_node_put(nr_node);
 
 	return -EINVAL;
 }
@@ -362,12 +407,12 @@
 {
 	struct nr_neigh *nr_neigh;
 
-	for (nr_neigh = nr_neigh_list; nr_neigh != NULL; nr_neigh = nr_neigh->next) {
-		if (ax25cmp(callsign, &nr_neigh->callsign) == 0 && nr_neigh->dev == dev) {
-			nr_neigh->quality = quality;
-			nr_neigh->locked  = 1;
-			return 0;
-		}
+	nr_neigh = nr_neigh_get_dev(callsign, dev);
+	if (nr_neigh) {
+		nr_neigh->quality = quality;
+		nr_neigh->locked  = 1;
+		nr_neigh_put(nr_neigh);
+		return 0;
 	}
 
 	if ((nr_neigh = kmalloc(sizeof(*nr_neigh), GFP_ATOMIC)) == NULL)
@@ -382,6 +427,7 @@
 	nr_neigh->count    = 0;
 	nr_neigh->number   = nr_neigh_no++;
 	nr_neigh->failed   = 0;
+	atomic_set(&nr_neigh->refcount, 1);
 
 	if (ax25_digi != NULL && ax25_digi->ndigi > 0) {
 		if ((nr_neigh->digipeat = kmalloc(sizeof(*ax25_digi), GFP_KERNEL)) == NULL) {
@@ -391,10 +437,10 @@
 		memcpy(nr_neigh->digipeat, ax25_digi, sizeof(*ax25_digi));
 	}
 
-	spin_lock_bh(&nr_neigh_lock);
-	nr_neigh->next = nr_neigh_list;
-	nr_neigh_list  = nr_neigh;
-	spin_unlock_bh(&nr_neigh_lock);
+	spin_lock_bh(&nr_neigh_list_lock);
+	hlist_add_head(&nr_neigh->neigh_node, &nr_neigh_list);
+	/* refcount is initialized at 1 */
+	spin_unlock_bh(&nr_neigh_list_lock);
 
 	return 0;
 }
@@ -407,9 +453,7 @@
 {
 	struct nr_neigh *nr_neigh;
 
-	for (nr_neigh = nr_neigh_list; nr_neigh != NULL; nr_neigh = nr_neigh->next)
-		if (ax25cmp(callsign, &nr_neigh->callsign) == 0 && nr_neigh->dev == dev)
-			break;
+	nr_neigh = nr_neigh_get_dev(callsign, dev);
 
 	if (nr_neigh == NULL) return -EINVAL;
 
@@ -418,6 +462,7 @@
 
 	if (nr_neigh->count == 0)
 		nr_remove_neigh(nr_neigh);
+	nr_neigh_put(nr_neigh);
 
 	return 0;
 }
@@ -430,15 +475,13 @@
 static int nr_dec_obs(void)
 {
 	struct nr_neigh *nr_neigh;
-	struct nr_node  *s, *nr_node;
+	struct nr_node  *s;
+	struct hlist_node *node, *nodet;
 	int i;
 
-	nr_node = nr_node_list;
-
-	while (nr_node != NULL) {
-		s       = nr_node;
-		nr_node = nr_node->next;
-
+	spin_lock_bh(&nr_node_list_lock);
+	nr_node_for_each_safe(s, node, nodet, &nr_node_list) {
+		nr_node_lock(s);
 		for (i = 0; i < s->count; i++) {
 			switch (s->routes[i].obs_count) {
 			case 0:		/* A locked entry */
@@ -448,6 +491,7 @@
 				nr_neigh = s->routes[i].neighbour;
 
 				nr_neigh->count--;
+				nr_neigh_put(nr_neigh);
 
 				if (nr_neigh->count == 0 && !nr_neigh->locked)
 					nr_remove_neigh(nr_neigh);
@@ -472,8 +516,10 @@
 		}
 
 		if (s->count <= 0)
-			nr_remove_node(s);
+			nr_remove_node_locked(s);
+		nr_node_unlock(s);
 	}
+	spin_unlock_bh(&nr_node_list_lock);
 
 	return 0;
 }
@@ -483,21 +529,17 @@
  */
 void nr_rt_device_down(struct net_device *dev)
 {
-	struct nr_neigh *s, *nr_neigh = nr_neigh_list;
-	struct nr_node  *t, *nr_node;
+	struct nr_neigh *s;
+	struct hlist_node *node, *nodet, *node2, *node2t;
+	struct nr_node  *t;
 	int i;
 
-	while (nr_neigh != NULL) {
-		s        = nr_neigh;
-		nr_neigh = nr_neigh->next;
-
+	spin_lock_bh(&nr_neigh_list_lock);
+	nr_neigh_for_each_safe(s, node, nodet, &nr_neigh_list) {
 		if (s->dev == dev) {
-			nr_node = nr_node_list;
-
-			while (nr_node != NULL) {
-				t       = nr_node;
-				nr_node = nr_node->next;
-
+			spin_lock_bh(&nr_node_list_lock);
+			nr_node_for_each_safe(t, node2, node2t, &nr_node_list) {
+				nr_node_lock(t);
 				for (i = 0; i < t->count; i++) {
 					if (t->routes[i].neighbour == s) {
 						t->count--;
@@ -514,12 +556,15 @@
 				}
 
 				if (t->count <= 0)
-					nr_remove_node(t);
+					nr_remove_node_locked(t);
+				nr_node_unlock(t);
 			}
+			spin_unlock_bh(&nr_node_list_lock);
 
-			nr_remove_neigh(s);
+			nr_remove_neigh_locked(s);
 		}
 	}
+	spin_unlock_bh(&nr_neigh_list_lock);
 }
 
 /*
@@ -553,6 +598,8 @@
 			if (first == NULL || strncmp(dev->name, first->name, 3) < 0)
 				first = dev;
 	}
+	if (first)
+		dev_hold(first);
 	read_unlock(&dev_base_lock);
 
 	return first;
@@ -603,6 +650,7 @@
 {
 	struct nr_route_struct nr_route;
 	struct net_device *dev;
+	int ret;
 
 	switch (cmd) {
 	case SIOCADDRT:
@@ -610,23 +658,29 @@
 			return -EFAULT;
 		if ((dev = nr_ax25_dev_get(nr_route.device)) == NULL)
 			return -EINVAL;
-		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS)
+		if (nr_route.ndigis < 0 || nr_route.ndigis > AX25_MAX_DIGIS) {
+			dev_put(dev);
 			return -EINVAL;
+		}
 		switch (nr_route.type) {
 		case NETROM_NODE:
-			return nr_add_node(&nr_route.callsign,
+			ret = nr_add_node(&nr_route.callsign,
 				nr_route.mnemonic,
 				&nr_route.neighbour,
 				nr_call_to_digi(nr_route.ndigis, nr_route.digipeaters),
 				dev, nr_route.quality,
 				nr_route.obs_count);
+			break;
 		case NETROM_NEIGH:
-			return nr_add_neigh(&nr_route.callsign,
+			ret = nr_add_neigh(&nr_route.callsign,
 				nr_call_to_digi(nr_route.ndigis, nr_route.digipeaters),
 				dev, nr_route.quality);
+			break;
 		default:
-			return -EINVAL;
+			ret = -EINVAL;
 		}
+		dev_put(dev);
+		return ret;
 
 	case SIOCDELRT:
 		if (copy_from_user(&nr_route, arg, sizeof(struct nr_route_struct)))
@@ -635,14 +689,18 @@
 			return -EINVAL;
 		switch (nr_route.type) {
 		case NETROM_NODE:
-			return nr_del_node(&nr_route.callsign,
+			ret = nr_del_node(&nr_route.callsign,
 				&nr_route.neighbour, dev);
+			break;
 		case NETROM_NEIGH:
-			return nr_del_neigh(&nr_route.callsign,
+			ret = nr_del_neigh(&nr_route.callsign,
 				dev, nr_route.quality);
+			break;
 		default:
-			return -EINVAL;
+			ret = -EINVAL;
 		}
+		dev_put(dev);
+		return ret;
 
 	case SIOCNRDECOBS:
 		return nr_dec_obs();
@@ -660,22 +718,36 @@
  */
 void nr_link_failed(ax25_cb *ax25, int reason)
 {
-	struct nr_neigh *nr_neigh;
-	struct nr_node  *nr_node;
-
-	for (nr_neigh = nr_neigh_list; nr_neigh != NULL; nr_neigh = nr_neigh->next)
-		if (nr_neigh->ax25 == ax25)
+	struct nr_neigh *s, *nr_neigh = NULL;
+	struct hlist_node *node;
+	struct nr_node  *nr_node = NULL;
+
+	spin_lock_bh(&nr_neigh_list_lock);
+	nr_neigh_for_each(s, node, &nr_neigh_list)
+		if (s->ax25 == ax25) {
+			nr_neigh_hold(s);
+			nr_neigh = s;
 			break;
+		}
+	spin_unlock_bh(&nr_neigh_list_lock);
 
 	if (nr_neigh == NULL) return;
 
 	nr_neigh->ax25 = NULL;
+	// ax25_cb_put(ax25);
 
-	if (++nr_neigh->failed < sysctl_netrom_link_fails_count) return;
-
-	for (nr_node = nr_node_list; nr_node != NULL; nr_node = nr_node->next)
+	if (++nr_neigh->failed < sysctl_netrom_link_fails_count) {
+		nr_neigh_put(nr_neigh);
+		return;
+	}
+	spin_lock_bh(&nr_node_list_lock);
+	nr_node_for_each(nr_node, node, &nr_node_list)
+		nr_node_lock(nr_node);
 		if (nr_node->which < nr_node->count && nr_node->routes[nr_node->which].neighbour == nr_neigh)
 			nr_node->which++;
+		nr_node_unlock(nr_node);
+	spin_unlock_bh(&nr_node_list_lock);
+	nr_neigh_put(nr_neigh);
 }
 
 /*
@@ -689,6 +761,9 @@
 	struct nr_node  *nr_node;
 	struct net_device *dev;
 	unsigned char *dptr;
+	ax25_cb *ax25s;
+	int ret;
+	struct sk_buff *skbn;
 
 
 	nr_src  = (ax25_address *)(skb->data + 0);
@@ -700,50 +775,84 @@
 
 	if ((dev = nr_dev_get(nr_dest)) != NULL) {	/* Its for me */
 		if (ax25 == NULL)			/* Its from me */
-			return nr_loopback_queue(skb);
+			ret = nr_loopback_queue(skb);
 		else
-			return nr_rx_frame(skb, dev);
+			ret = nr_rx_frame(skb, dev);
+		dev_put(dev);
+		return ret;
 	}
 
 	if (!sysctl_netrom_routing_control && ax25 != NULL)
 		return 0;
 
 	/* Its Time-To-Live has expired */
-	if (--skb->data[14] == 0)
+	if (skb->data[14] == 1) {
 		return 0;
+	}
 
-	for (nr_node = nr_node_list; nr_node != NULL; nr_node = nr_node->next)
-		if (ax25cmp(nr_dest, &nr_node->callsign) == 0)
-			break;
+	nr_node = nr_node_get(nr_dest);
+	if (nr_node == NULL)
+		return 0;
+	nr_node_lock(nr_node);
 
-	if (nr_node == NULL || nr_node->which >= nr_node->count)
+	if (nr_node->which >= nr_node->count) {
+		nr_node_unlock(nr_node);
+		nr_node_put(nr_node);
 		return 0;
+	}
 
 	nr_neigh = nr_node->routes[nr_node->which].neighbour;
 
-	if ((dev = nr_dev_first()) == NULL)
+	if ((dev = nr_dev_first()) == NULL) {
+		nr_node_unlock(nr_node);
+		nr_node_put(nr_node);
+		return 0;
+	}
+
+	/* We are going to change the netrom headers so we should get our
+	   own skb, we also did not know until now how much header space
+	   we had to reserve... - RXQ */
+	if ((skbn=skb_copy_expand(skb, dev->hard_header_len, 0, GFP_ATOMIC)) == NULL) {
+		nr_node_unlock(nr_node);
+		nr_node_put(nr_node);
+		dev_put(dev);
 		return 0;
+	}
+	kfree_skb(skb);
+	skb=skbn;
+	skb->data[14]--;
 
 	dptr  = skb_push(skb, 1);
 	*dptr = AX25_P_NETROM;
 
-	nr_neigh->ax25 = ax25_send_frame(skb, 256, (ax25_address *)dev->dev_addr, &nr_neigh->callsign, nr_neigh->digipeat, nr_neigh->dev);
+	ax25s = ax25_send_frame(skb, 256, (ax25_address *)dev->dev_addr, &nr_neigh->callsign, nr_neigh->digipeat, nr_neigh->dev);
+	if (nr_neigh->ax25 && ax25s) {
+		/* We were already holding this ax25_cb */
+		// ax25_cb_put(ax25s);
+	}
+	nr_neigh->ax25 = ax25s;
 
-	return (nr_neigh->ax25 != NULL);
+	dev_put(dev);
+	ret = (nr_neigh->ax25 != NULL);
+	nr_node_unlock(nr_node);
+	nr_node_put(nr_node);
+	return ret;
 }
 
 int nr_nodes_get_info(char *buffer, char **start, off_t offset, int length)
 {
 	struct nr_node *nr_node;
+	struct hlist_node *node;
 	int len     = 0;
 	off_t pos   = 0;
 	off_t begin = 0;
 	int i;
 
-	spin_lock_bh(&nr_node_lock);
+	spin_lock_bh(&nr_node_list_lock);
 	len += sprintf(buffer, "callsign  mnemonic w n qual obs neigh qual obs neigh qual obs neigh\n");
 
-	for (nr_node = nr_node_list; nr_node != NULL; nr_node = nr_node->next) {
+	nr_node_for_each(nr_node, node, &nr_node_list) {
+		nr_node_lock(nr_node);
 		len += sprintf(buffer + len, "%-9s %-7s  %d %d",
 			ax2asc(&nr_node->callsign),
 			(nr_node->mnemonic[0] == '\0') ? "*" : nr_node->mnemonic,
@@ -756,6 +865,7 @@
 				nr_node->routes[i].obs_count,
 				nr_node->routes[i].neighbour->number);
 		}
+		nr_node_unlock(nr_node);
 
 		len += sprintf(buffer + len, "\n");
 
@@ -769,7 +879,7 @@
 		if (pos > offset + length)
 			break;
 	}
-	spin_unlock_bh(&nr_node_lock);
+	spin_unlock_bh(&nr_node_list_lock);
 
 	*start = buffer + (offset - begin);
 	len   -= (offset - begin);
@@ -782,15 +892,16 @@
 int nr_neigh_get_info(char *buffer, char **start, off_t offset, int length)
 {
 	struct nr_neigh *nr_neigh;
+	struct hlist_node *node;
 	int len     = 0;
 	off_t pos   = 0;
 	off_t begin = 0;
 	int i;
 
-	spin_lock_bh(&nr_neigh_lock);
+	spin_lock_bh(&nr_neigh_list_lock);
 	len += sprintf(buffer, "addr  callsign  dev  qual lock count failed digipeaters\n");
 
-	for (nr_neigh = nr_neigh_list; nr_neigh != NULL; nr_neigh = nr_neigh->next) {
+	nr_neigh_for_each(nr_neigh, node, &nr_neigh_list) {
 		len += sprintf(buffer + len, "%05d %-9s %-4s  %3d    %d   %3d    %3d",
 			nr_neigh->number,
 			ax2asc(&nr_neigh->callsign),
@@ -818,7 +929,7 @@
 			break;
 	}
 
-	spin_unlock_bh(&nr_neigh_lock);
+	spin_unlock_bh(&nr_neigh_list_lock);
 
 	*start = buffer + (offset - begin);
 	len   -= (offset - begin);
@@ -833,20 +944,24 @@
  */
 void __exit nr_rt_free(void)
 {
-	struct nr_neigh *s, *nr_neigh = nr_neigh_list;
-	struct nr_node  *t, *nr_node  = nr_node_list;
-
-	while (nr_node != NULL) {
-		t       = nr_node;
-		nr_node = nr_node->next;
-
-		nr_remove_node(t);
-	}
-
-	while (nr_neigh != NULL) {
-		s        = nr_neigh;
-		nr_neigh = nr_neigh->next;
-
-		nr_remove_neigh(s);
+	struct nr_neigh *s = NULL;
+	struct nr_node  *t = NULL;
+	struct hlist_node *node, *nodet;
+
+	spin_lock_bh(&nr_neigh_list_lock);
+	spin_lock_bh(&nr_node_list_lock);
+	nr_node_for_each_safe(t, node, nodet, &nr_node_list) {
+		nr_node_lock(t);
+		nr_remove_node_locked(t);
+		nr_node_unlock(t);
+	}
+	nr_neigh_for_each_safe(s, node, nodet, &nr_neigh_list) {
+		while(s->count) {
+			s->count--;
+			nr_neigh_put(s);
+		}
+		nr_remove_neigh_locked(s);
 	}
+	spin_unlock_bh(&nr_node_list_lock);
+	spin_unlock_bh(&nr_neigh_list_lock);
 }
