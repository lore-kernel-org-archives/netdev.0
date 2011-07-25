From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 3/7] neigh: Add infrastructure for allocating device neigh
 privates.
Date: Mon, 25 Jul 2011 03:01:25 -0700 (PDT)
Message-ID: <20110725.030125.1424724892207997787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


netdev->neigh_priv_len records the private area length.

This will trigger for neigh_table objects which set tbl->entry_size
to zero, and the first instances of this will be forthcoming.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    2 ++
 include/linux/netdevice.h                 |    1 +
 net/atm/clip.c                            |    1 +
 net/core/neighbour.c                      |   14 +++++++++++---
 4 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 43f89ba..7b96105 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1216,6 +1216,8 @@ static struct net_device *ipoib_add_port(const char *format,
 	priv->dev->mtu  = IPOIB_UD_MTU(priv->max_ib_mtu);
 	priv->mcast_mtu  = priv->admin_mtu = priv->dev->mtu;
 
+	priv->dev->neigh_priv_len = sizeof(struct ipoib_neigh);
+
 	result = ib_query_pkey(hca, port, 0, &priv->pkey);
 	if (result) {
 		printk(KERN_WARNING "%s: ib_query_pkey port %d failed (ret = %d)\n",
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 34f3abc..a50f6d6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1127,6 +1127,7 @@ struct net_device {
 	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
 	unsigned char		addr_assign_type; /* hw address assignment type */
 	unsigned char		addr_len;	/* hardware address length	*/
+	unsigned char		neigh_priv_len;
 	unsigned short          dev_id;		/* for shared network cards */
 
 	spinlock_t		addr_list_lock;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 4bc8c67..5dc4f4e 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -551,6 +551,7 @@ static void clip_setup(struct net_device *dev)
 {
 	dev->netdev_ops = &clip_netdev_ops;
 	dev->type = ARPHRD_ATM;
+	dev->neigh_priv_len = sizeof(struct atmarp_entry);
 	dev->hard_header_len = RFC1483LLC_LEN;
 	dev->mtu = RFC1626_MTU;
 	dev->tx_queue_len = 100;	/* "normal" queue (packets) */
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 493703c..96ae4e4 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -272,7 +272,7 @@ int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 }
 EXPORT_SYMBOL(neigh_ifdown);
 
-static struct neighbour *neigh_alloc(struct neigh_table *tbl)
+static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device *dev)
 {
 	struct neighbour *n = NULL;
 	unsigned long now = jiffies;
@@ -287,7 +287,15 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl)
 			goto out_entries;
 	}
 
-	n = kzalloc(tbl->entry_size, GFP_ATOMIC);
+	if (tbl->entry_size)
+		n = kzalloc(tbl->entry_size, GFP_ATOMIC);
+	else {
+		int sz = sizeof(*n) + tbl->key_len;
+
+		sz = ALIGN(sz, NEIGH_PRIV_ALIGN);
+		sz += dev->neigh_priv_len;
+		n = kzalloc(sz, GFP_ATOMIC);
+	}
 	if (!n)
 		goto out_entries;
 
@@ -462,7 +470,7 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 	u32 hash_val;
 	int key_len = tbl->key_len;
 	int error;
-	struct neighbour *n1, *rc, *n = neigh_alloc(tbl);
+	struct neighbour *n1, *rc, *n = neigh_alloc(tbl, dev);
 	struct neigh_hash_table *nht;
 
 	if (!n) {
-- 
1.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
