From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 10/12] xdp: Add batching support to redirect map
Date: Mon, 17 Jul 2017 09:29:40 -0700
Message-ID: <20170717162940.24315.28829.stgit@john-Precision-Tower-5810>
References: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com, brouer@redhat.com, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34366 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751284AbdGQQ35 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 12:29:57 -0400
Received: by mail-pf0-f193.google.com with SMTP id o88so2008951pfk.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 09:29:56 -0700 (PDT)
In-Reply-To: <20170717160759.24315.7464.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For performance reasons we want to avoid updating the tail pointer in
the driver tx ring as much as possible. To accomplish this we add
batching support to the redirect path in XDP.

This adds another ndo op "xdp_flush" that is used to inform the driver
that it should bump the tail pointer on the TX ring.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   28 +++++++-
 include/linux/bpf.h                           |    2 +
 include/linux/filter.h                        |    7 ++
 include/linux/netdevice.h                     |    5 +
 kernel/bpf/devmap.c                           |   84 +++++++++++++++++++++++++
 net/core/filter.c                             |   55 +++++++++++++---
 6 files changed, 166 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 38f7ff9..0f867dc 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2415,6 +2415,8 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		 */
 		wmb();
 		writel(ring->next_to_use, ring->tail);
+
+		xdp_do_flush_map();
 	}
 
 	u64_stats_update_begin(&rx_ring->syncp);
@@ -5817,6 +5819,9 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 
 	usleep_range(10000, 20000);
 
+	/* synchronize_sched() needed for pending XDP buffers to drain */
+	if (adapter->xdp_ring[0])
+		synchronize_sched();
 	netif_tx_stop_all_queues(netdev);
 
 	/* call carrier off first to avoid false dev_watchdog timeouts */
@@ -9850,15 +9855,31 @@ static int ixgbe_xdp_xmit(struct net_device *dev, struct xdp_buff *xdp)
 	if (err != IXGBE_XDP_TX)
 		return -ENOMEM;
 
+	return 0;
+}
+
+static void ixgbe_xdp_flush(struct net_device *dev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_ring *ring;
+
+	/* Its possible the device went down between xdp xmit and flush so
+	 * we need to ensure device is still up.
+	 */
+	if (unlikely(test_bit(__IXGBE_DOWN, &adapter->state)))
+		return;
+
+	ring = adapter->xdp_prog ? adapter->xdp_ring[smp_processor_id()] : NULL;
+	if (unlikely(!ring))
+		return;
+
 	/* Force memory writes to complete before letting h/w know there
 	 * are new descriptors to fetch.
 	 */
 	wmb();
-
-	ring = adapter->xdp_ring[smp_processor_id()];
 	writel(ring->next_to_use, ring->tail);
 
-	return 0;
+	return;
 }
 
 static const struct net_device_ops ixgbe_netdev_ops = {
@@ -9908,6 +9929,7 @@ static int ixgbe_xdp_xmit(struct net_device *dev, struct xdp_buff *xdp)
 	.ndo_features_check	= ixgbe_features_check,
 	.ndo_xdp		= ixgbe_xdp,
 	.ndo_xdp_xmit		= ixgbe_xdp_xmit,
+	.ndo_xdp_flush		= ixgbe_xdp_flush,
 };
 
 /**
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index d0d3281..6850a76 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -381,5 +381,7 @@ static inline void __bpf_prog_uncharge(struct user_struct *user, u32 pages)
 
 /* Map specifics */
 struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key);
+void __dev_map_insert_ctx(struct bpf_map *map, u32 index);
+void __dev_map_flush(struct bpf_map *map);
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index ce8211f..3323ee9 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -712,10 +712,17 @@ int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
 
+/* The pair of xdp_do_redirect and xdp_do_flush_map MUST be called in the
+ * same cpu context. Further for best results no more than a single map
+ * for the do_redirect/do_flush pair should be used. This limitation is
+ * because we only track one map and force a flush when the map changes.
+ * This does not appear to be a real limiation for existing software.
+ */
 int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb);
 int xdp_do_redirect(struct net_device *dev,
 		    struct xdp_buff *xdp,
 		    struct bpf_prog *prog);
+void xdp_do_flush_map(void);
 
 void bpf_warn_invalid_xdp_action(u32 act);
 void bpf_warn_invalid_xdp_redirect(u32 ifindex);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 77f5376..03b1049 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1142,7 +1142,9 @@ struct xfrmdev_ops {
  * int (*ndo_xdp_xmit)(struct net_device *dev, struct xdp_buff *xdp);
  *	This function is used to submit a XDP packet for transmit on a
  *	netdevice.
- *
+ * void (*ndo_xdp_flush)(struct net_device *dev);
+ *	This function is used to inform the driver to flush a paticular
+ *	xpd tx queue. Must be called on same CPU as xdp_xmit.
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -1329,6 +1331,7 @@ struct net_device_ops {
 					   struct netdev_xdp *xdp);
 	int			(*ndo_xdp_xmit)(struct net_device *dev,
 						struct xdp_buff *xdp);
+	void			(*ndo_xdp_flush)(struct net_device *dev);
 };
 
 /**
diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index 36dc13de..b2ef04a 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -53,6 +53,7 @@ struct bpf_dtab_netdev {
 struct bpf_dtab {
 	struct bpf_map map;
 	struct bpf_dtab_netdev **netdev_map;
+	unsigned long int __percpu *flush_needed;
 };
 
 static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
@@ -87,6 +88,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 
 	/* make sure page count doesn't overflow */
 	cost = (u64) dtab->map.max_entries * sizeof(struct bpf_dtab_netdev *);
+	cost += BITS_TO_LONGS(attr->max_entries) * sizeof(unsigned long);
 	if (cost >= U32_MAX - PAGE_SIZE)
 		goto free_dtab;
 
@@ -97,6 +99,14 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	if (err)
 		goto free_dtab;
 
+	/* A per cpu bitfield with a bit per possible net device */
+	dtab->flush_needed = __alloc_percpu(
+				BITS_TO_LONGS(attr->max_entries) *
+				sizeof(unsigned long),
+				__alignof__(unsigned long));
+	if (!dtab->flush_needed)
+		goto free_dtab;
+
 	dtab->netdev_map = bpf_map_area_alloc(dtab->map.max_entries *
 					      sizeof(struct bpf_dtab_netdev *));
 	if (!dtab->netdev_map)
@@ -105,6 +115,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 	return &dtab->map;
 
 free_dtab:
+	free_percpu(dtab->flush_needed);
 	kfree(dtab);
 	return ERR_PTR(err);
 }
@@ -112,7 +123,7 @@ static struct bpf_map *dev_map_alloc(union bpf_attr *attr)
 static void dev_map_free(struct bpf_map *map)
 {
 	struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
-	int i;
+	int i, cpu;
 
 	/* At this point bpf_prog->aux->refcnt == 0 and this map->refcnt == 0,
 	 * so the programs (can be more than one that used this map) were
@@ -123,6 +134,18 @@ static void dev_map_free(struct bpf_map *map)
 	 */
 	synchronize_rcu();
 
+	/* To ensure all pending flush operations have completed wait for flush
+	 * bitmap to indicate all flush_needed bits to be zero on _all_ cpus.
+	 * Because the above synchronize_rcu() ensures the map is disconnected
+	 * from the program we can assume no new bits will be set.
+	 */
+	for_each_online_cpu(cpu) {
+		unsigned long *bitmap = per_cpu_ptr(dtab->flush_needed, cpu);
+
+		while (!bitmap_empty(bitmap, dtab->map.max_entries))
+			cpu_relax();
+	}
+
 	for (i = 0; i < dtab->map.max_entries; i++) {
 		struct bpf_dtab_netdev *dev;
 
@@ -137,6 +160,7 @@ static void dev_map_free(struct bpf_map *map)
 	/* At this point bpf program is detached and all pending operations
 	 * _must_ be complete
 	 */
+	free_percpu(dtab->flush_needed);
 	bpf_map_area_free(dtab->netdev_map);
 	kfree(dtab);
 }
@@ -159,6 +183,14 @@ static int dev_map_get_next_key(struct bpf_map *map, void *key, void *next_key)
 	return 0;
 }
 
+void __dev_map_insert_ctx(struct bpf_map *map, u32 key)
+{
+	struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
+	unsigned long *bitmap = this_cpu_ptr(dtab->flush_needed);
+
+	__set_bit(key, bitmap);
+}
+
 struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key)
 {
 	struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
@@ -171,6 +203,39 @@ struct net_device  *__dev_map_lookup_elem(struct bpf_map *map, u32 key)
 	return dev ? dev->dev : NULL;
 }
 
+/* __dev_map_flush is called from xdp_do_flush_map() which _must_ be signaled
+ * from the driver before returning from its napi->poll() routine. The poll()
+ * routine is called either from busy_poll context or net_rx_action signaled
+ * from NET_RX_SOFTIRQ. Either way the poll routine must complete before the
+ * net device can be torn down. On devmap tear down we ensure the ctx bitmap
+ * is zeroed before completing to ensure all flush operations have completed.
+ */
+void __dev_map_flush(struct bpf_map *map)
+{
+	struct bpf_dtab *dtab = container_of(map, struct bpf_dtab, map);
+	unsigned long *bitmap = this_cpu_ptr(dtab->flush_needed);
+	u32 bit;
+
+	for_each_set_bit(bit, bitmap, map->max_entries) {
+		struct bpf_dtab_netdev *dev = READ_ONCE(dtab->netdev_map[bit]);
+		struct net_device *netdev;
+
+		/* This is possible if the dev entry is removed by user space
+		 * between xdp redirect and flush op.
+		 */
+		if (unlikely(!dev))
+			continue;
+
+		netdev = dev->dev;
+
+		__clear_bit(bit, bitmap);
+		if (unlikely(!netdev || !netdev->netdev_ops->ndo_xdp_flush))
+			continue;
+
+		netdev->netdev_ops->ndo_xdp_flush(netdev);
+	}
+}
+
 /* rcu_read_lock (from syscall and BPF contexts) ensures that if a delete and/or
  * update happens in parallel here a dev_put wont happen until after reading the
  * ifindex.
@@ -188,11 +253,28 @@ static void *dev_map_lookup_elem(struct bpf_map *map, void *key)
 	return dev ? &dev->dev->ifindex : NULL;
 }
 
+static void dev_map_flush_old(struct bpf_dtab_netdev *old_dev)
+{
+	if (old_dev->dev->netdev_ops->ndo_xdp_flush) {
+		struct net_device *fl = old_dev->dev;
+		unsigned long *bitmap;
+		int cpu;
+
+		for_each_online_cpu(cpu) {
+			bitmap = per_cpu_ptr(old_dev->dtab->flush_needed, cpu);
+			__clear_bit(old_dev->key, bitmap);
+
+			fl->netdev_ops->ndo_xdp_flush(old_dev->dev);
+		}
+	}
+}
+
 static void __dev_map_entry_free(struct rcu_head *rcu)
 {
 	struct bpf_dtab_netdev *old_dev;
 
 	old_dev = container_of(rcu, struct bpf_dtab_netdev, rcu);
+	dev_map_flush_old(old_dev);
 	dev_put(old_dev->dev);
 	kfree(old_dev);
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index e93a558..e23aa6f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1780,6 +1780,7 @@ struct redirect_info {
 	u32 ifindex;
 	u32 flags;
 	struct bpf_map *map;
+	struct bpf_map *map_to_flush;
 };
 
 static DEFINE_PER_CPU(struct redirect_info, redirect_info);
@@ -2438,34 +2439,68 @@ static int bpf_skb_trim_rcsum(struct sk_buff *skb, unsigned int new_len)
 	.arg2_type	= ARG_ANYTHING,
 };
 
-static int __bpf_tx_xdp(struct net_device *dev, struct xdp_buff *xdp)
+static int __bpf_tx_xdp(struct net_device *dev,
+			struct bpf_map *map,
+			struct xdp_buff *xdp,
+			u32 index)
 {
-	if (dev->netdev_ops->ndo_xdp_xmit) {
-		dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
-		return 0;
+	int err;
+
+	if (!dev->netdev_ops->ndo_xdp_xmit) {
+		bpf_warn_invalid_xdp_redirect(dev->ifindex);
+		return -EOPNOTSUPP;
 	}
-	bpf_warn_invalid_xdp_redirect(dev->ifindex);
-	return -EOPNOTSUPP;
+
+	err = dev->netdev_ops->ndo_xdp_xmit(dev, xdp);
+	if (err)
+		return err;
+
+	if (map)
+		__dev_map_insert_ctx(map, index);
+	else
+		dev->netdev_ops->ndo_xdp_flush(dev);
+
+	return err;
 }
 
+void xdp_do_flush_map(void)
+{
+	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
+	struct bpf_map *map = ri->map_to_flush;
+
+	ri->map = NULL;
+	ri->map_to_flush = NULL;
+
+	if (map)
+		__dev_map_flush(map);
+}
+EXPORT_SYMBOL_GPL(xdp_do_flush_map);
+
 int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 			struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 	struct bpf_map *map = ri->map;
+	u32 index = ri->ifindex;
 	struct net_device *fwd;
 	int err = -EINVAL;
 
 	ri->ifindex = 0;
 	ri->map = NULL;
 
-	fwd = __dev_map_lookup_elem(map, ri->ifindex);
+	fwd = __dev_map_lookup_elem(map, index);
 	if (!fwd)
 		goto out;
 
-	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
-	err = __bpf_tx_xdp(fwd, xdp);
+	if (ri->map_to_flush && (ri->map_to_flush != map))
+		xdp_do_flush_map();
+
+	err = __bpf_tx_xdp(fwd, map, xdp, index);
+	if (likely(!err))
+		ri->map_to_flush = map;
+
 out:
+	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
 	return err;
 }
 
@@ -2488,7 +2523,7 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
 
 	trace_xdp_redirect(dev, fwd, xdp_prog, XDP_REDIRECT);
 
-	return __bpf_tx_xdp(fwd, xdp);
+	return __bpf_tx_xdp(fwd, NULL, xdp, 0);
 }
 EXPORT_SYMBOL_GPL(xdp_do_redirect);
 
