From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/7] neigh: Add infrastructure for allocating device neigh
 privates.
Date: Wed, 30 Nov 2011 22:41:39 -0500 (EST)
Message-ID: <20111130.224139.732085490934478953.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58061 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997Ab1LADll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:41 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13fdRm027321
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:40 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


netdev->neigh_priv_len records the private area length.

This will trigger for neigh_table objects which set tbl->entry_size
to zero, and the first instances of this will be forthcoming.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |    2 ++
 include/linux/netdevice.h                 |    1 +
 net/atm/clip.c                            |    1 +
 net/core/neighbour.c                      |   14 +++++++++++---
 4 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index efd7a96..57ae9b9 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1218,6 +1218,8 @@ static struct net_device *ipoib_add_port(const char *format,
 	priv->dev->mtu  = IPOIB_UD_MTU(priv->max_ib_mtu);
 	priv->mcast_mtu  = priv->admin_mtu = priv->dev->mtu;
 
+	priv->dev->neigh_priv_len = sizeof(struct ipoib_neigh);
+
 	result = ib_query_pkey(hca, port, 0, &priv->pkey);
 	if (result) {
 		printk(KERN_WARNING "%s: ib_query_pkey port %d failed (ret = %d)\n",
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97edb32..5462c2c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1080,6 +1080,7 @@ struct net_device {
 	unsigned char		perm_addr[MAX_ADDR_LEN]; /* permanent hw address */
 	unsigned char		addr_assign_type; /* hw address assignment type */
 	unsigned char		addr_len;	/* hardware address length	*/
+	unsigned char		neigh_priv_len;
 	unsigned short          dev_id;		/* for shared network cards */
 
 	spinlock_t		addr_list_lock;
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 11439a7..aea7cad 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -535,6 +535,7 @@ static void clip_setup(struct net_device *dev)
 {
 	dev->netdev_ops = &clip_netdev_ops;
 	dev->type = ARPHRD_ATM;
+	dev->neigh_priv_len = sizeof(struct atmarp_entry);
 	dev->hard_header_len = RFC1483LLC_LEN;
 	dev->mtu = RFC1626_MTU;
 	dev->tx_queue_len = 100;	/* "normal" queue (packets) */
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 661ad12..ef750ff 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -273,7 +273,7 @@ int neigh_ifdown(struct neigh_table *tbl, struct net_device *dev)
 }
 EXPORT_SYMBOL(neigh_ifdown);
 
-static struct neighbour *neigh_alloc(struct neigh_table *tbl)
+static struct neighbour *neigh_alloc(struct neigh_table *tbl, struct net_device *dev)
 {
 	struct neighbour *n = NULL;
 	unsigned long now = jiffies;
@@ -288,7 +288,15 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl)
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
 
@@ -463,7 +471,7 @@ struct neighbour *neigh_create(struct neigh_table *tbl, const void *pkey,
 	u32 hash_val;
 	int key_len = tbl->key_len;
 	int error;
-	struct neighbour *n1, *rc, *n = neigh_alloc(tbl);
+	struct neighbour *n1, *rc, *n = neigh_alloc(tbl, dev);
 	struct neigh_hash_table *nht;
 
 	if (!n) {
-- 
1.7.6.4
