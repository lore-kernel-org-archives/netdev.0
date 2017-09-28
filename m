From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 1/8] flow_dissector: Change skbuf argument to be non const
Date: Thu, 28 Sep 2017 16:52:23 -0700
Message-ID: <20170928235230.22158-2-tom@quantonium.net>
References: <20170928235230.22158-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:49183 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751880AbdI1Xwx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:52:53 -0400
Received: by mail-pg0-f48.google.com with SMTP id v13so1206871pgq.6
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:52:53 -0700 (PDT)
In-Reply-To: <20170928235230.22158-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the skbuf argument of __skb_flow_dissect to be non constant so
that the function can call functions that take non constant skbuf
arguments. This is needed if we are to call socket lookup or BPF in the
flow dissector path.

The changes include unraveling the call chain into __skb_flow_dissect so
that those also use non constant skbufs.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  2 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.c       |  2 +-
 drivers/net/ethernet/cisco/enic/enic_clsf.h       |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c |  2 +-
 drivers/net/ethernet/qlogic/qede/qede.h           |  2 +-
 drivers/net/ethernet/qlogic/qede/qede_filter.c    |  2 +-
 drivers/net/ethernet/sfc/efx.h                    |  2 +-
 drivers/net/ethernet/sfc/falcon/efx.h             |  2 +-
 drivers/net/ethernet/sfc/falcon/rx.c              |  2 +-
 drivers/net/ethernet/sfc/rx.c                     |  2 +-
 include/linux/netdevice.h                         |  4 ++--
 include/linux/skbuff.h                            | 12 ++++++------
 include/net/ip_fib.h                              |  4 ++--
 include/net/route.h                               |  4 ++--
 net/core/flow_dissector.c                         | 10 +++++-----
 net/ipv4/fib_semantics.c                          |  2 +-
 net/ipv4/route.c                                  |  6 +++---
 net/sched/sch_sfq.c                               |  2 +-
 20 files changed, 34 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5ba49938ba55..29f5cf6bea4a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7344,7 +7344,7 @@ static bool bnxt_fltr_match(struct bnxt_ntuple_filter *f1,
 	return false;
 }
 
-static int bnxt_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+static int bnxt_rx_flow_steer(struct net_device *dev, struct sk_buff *skb,
 			      u16 rxq_index, u32 flow_id)
 {
 	struct bnxt *bp = netdev_priv(dev);
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index 3c677ed3c29e..7ee2aa1c3184 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -167,7 +167,7 @@ static struct enic_rfs_fltr_node *htbl_key_search(struct hlist_head *h,
 	return NULL;
 }
 
-int enic_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+int enic_rx_flow_steer(struct net_device *dev, struct sk_buff *skb,
 		       u16 rxq_index, u32 flow_id)
 {
 	struct flow_keys keys;
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.h b/drivers/net/ethernet/cisco/enic/enic_clsf.h
index 4bfbf25f9ddc..0e7f533f81b9 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.h
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.h
@@ -13,7 +13,7 @@ void enic_rfs_flw_tbl_free(struct enic *enic);
 struct enic_rfs_fltr_node *htbl_fltr_search(struct enic *enic, u16 fltr_id);
 
 #ifdef CONFIG_RFS_ACCEL
-int enic_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+int enic_rx_flow_steer(struct net_device *dev, struct sk_buff *skb,
 		       u16 rxq_index, u32 flow_id);
 void enic_flow_may_expire(unsigned long data);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9c218f1cfc6c..9f7afbfb09f9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -348,7 +348,7 @@ mlx4_en_filter_find(struct mlx4_en_priv *priv, __be32 src_ip, __be32 dst_ip,
 }
 
 static int
-mlx4_en_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+mlx4_en_filter_rfs(struct net_device *net_dev, struct sk_buff *skb,
 		   u16 rxq_index, u32 flow_id)
 {
 	struct mlx4_en_priv *priv = netdev_priv(net_dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index cc13d3dbd366..897c9d46702c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1017,7 +1017,7 @@ int mlx5e_arfs_create_tables(struct mlx5e_priv *priv);
 void mlx5e_arfs_destroy_tables(struct mlx5e_priv *priv);
 int mlx5e_arfs_enable(struct mlx5e_priv *priv);
 int mlx5e_arfs_disable(struct mlx5e_priv *priv);
-int mlx5e_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+int mlx5e_rx_flow_steer(struct net_device *dev, struct sk_buff *skb,
 			u16 rxq_index, u32 flow_id);
 #endif
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index 12d3ced61114..f5e182bd613d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -699,7 +699,7 @@ static struct arfs_rule *arfs_find_rule(struct arfs_table *arfs_t,
 	return NULL;
 }
 
-int mlx5e_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+int mlx5e_rx_flow_steer(struct net_device *dev, struct sk_buff *skb,
 			u16 rxq_index, u32 flow_id)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index adb700512baa..56c364811929 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -445,7 +445,7 @@ struct qede_fastpath {
 #define QEDE_SP_RX_MODE			1
 
 #ifdef CONFIG_RFS_ACCEL
-int qede_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+int qede_rx_flow_steer(struct net_device *dev, struct sk_buff *skb,
 		       u16 rxq_index, u32 flow_id);
 #define QEDE_SP_ARFS_CONFIG	4
 #define QEDE_SP_TASK_POLL_DELAY	(5 * HZ)
diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index f79e36e4060a..2d2b473fbff8 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -411,7 +411,7 @@ qede_alloc_filter(struct qede_dev *edev, int min_hlen)
 	return n;
 }
 
-int qede_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
+int qede_rx_flow_steer(struct net_device *dev, struct sk_buff *skb,
 		       u16 rxq_index, u32 flow_id)
 {
 	struct qede_dev *edev = netdev_priv(dev);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index d407adf59610..805c7880df8d 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -171,7 +171,7 @@ static inline s32 efx_filter_get_rx_ids(struct efx_nic *efx,
 	return efx->type->filter_get_rx_ids(efx, priority, buf, size);
 }
 #ifdef CONFIG_RFS_ACCEL
-int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+int efx_filter_rfs(struct net_device *net_dev, struct sk_buff *skb,
 		   u16 rxq_index, u32 flow_id);
 bool __efx_filter_rfs_expire(struct efx_nic *efx, unsigned quota);
 static inline void efx_filter_rfs_expire(struct efx_channel *channel)
diff --git a/drivers/net/ethernet/sfc/falcon/efx.h b/drivers/net/ethernet/sfc/falcon/efx.h
index 4f3bb30661ea..e3b9b7cbbb39 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.h
+++ b/drivers/net/ethernet/sfc/falcon/efx.h
@@ -164,7 +164,7 @@ static inline s32 ef4_filter_get_rx_ids(struct ef4_nic *efx,
 	return efx->type->filter_get_rx_ids(efx, priority, buf, size);
 }
 #ifdef CONFIG_RFS_ACCEL
-int ef4_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+int ef4_filter_rfs(struct net_device *net_dev, struct sk_buff *skb,
 		   u16 rxq_index, u32 flow_id);
 bool __ef4_filter_rfs_expire(struct ef4_nic *efx, unsigned quota);
 static inline void ef4_filter_rfs_expire(struct ef4_channel *channel)
diff --git a/drivers/net/ethernet/sfc/falcon/rx.c b/drivers/net/ethernet/sfc/falcon/rx.c
index 6a8406dc0c2b..d5d2816b30dd 100644
--- a/drivers/net/ethernet/sfc/falcon/rx.c
+++ b/drivers/net/ethernet/sfc/falcon/rx.c
@@ -833,7 +833,7 @@ MODULE_PARM_DESC(rx_refill_threshold,
 
 #ifdef CONFIG_RFS_ACCEL
 
-int ef4_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+int ef4_filter_rfs(struct net_device *net_dev, struct sk_buff *skb,
 		   u16 rxq_index, u32 flow_id)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 42443f434569..35898054aced 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -827,7 +827,7 @@ MODULE_PARM_DESC(rx_refill_threshold,
 
 #ifdef CONFIG_RFS_ACCEL
 
-int efx_filter_rfs(struct net_device *net_dev, const struct sk_buff *skb,
+int efx_filter_rfs(struct net_device *net_dev, struct sk_buff *skb,
 		   u16 rxq_index, u32 flow_id)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1..06b173200e23 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1010,7 +1010,7 @@ struct xfrmdev_ops {
  *	protocol stack to use.
  *
  *	RFS acceleration.
- * int (*ndo_rx_flow_steer)(struct net_device *dev, const struct sk_buff *skb,
+ * int (*ndo_rx_flow_steer)(struct net_device *dev, struct sk_buff *skb,
  *			    u16 rxq_index, u32 flow_id);
  *	Set hardware filter for RFS.  rxq_index is the target queue index;
  *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
@@ -1236,7 +1236,7 @@ struct net_device_ops {
 
 #ifdef CONFIG_RFS_ACCEL
 	int			(*ndo_rx_flow_steer)(struct net_device *dev,
-						     const struct sk_buff *skb,
+						     struct sk_buff *skb,
 						     u16 rxq_index,
 						     u32 flow_id);
 #endif
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 19e64bfb1a66..5a6e765e120f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1155,8 +1155,8 @@ __skb_set_sw_hash(struct sk_buff *skb, __u32 hash, bool is_l4)
 }
 
 void __skb_get_hash(struct sk_buff *skb);
-u32 __skb_get_hash_symmetric(const struct sk_buff *skb);
-u32 skb_get_poff(const struct sk_buff *skb);
+u32 __skb_get_hash_symmetric(struct sk_buff *skb);
+u32 skb_get_poff(struct sk_buff *skb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen);
 __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
@@ -1172,13 +1172,13 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 			     const struct flow_dissector_key *key,
 			     unsigned int key_count);
 
-bool __skb_flow_dissect(const struct sk_buff *skb,
+bool __skb_flow_dissect(struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
 			void *target_container,
 			void *data, __be16 proto, int nhoff, int hlen,
 			unsigned int flags);
 
-static inline bool skb_flow_dissect(const struct sk_buff *skb,
+static inline bool skb_flow_dissect(struct sk_buff *skb,
 				    struct flow_dissector *flow_dissector,
 				    void *target_container, unsigned int flags)
 {
@@ -1186,7 +1186,7 @@ static inline bool skb_flow_dissect(const struct sk_buff *skb,
 				  NULL, 0, 0, 0, flags);
 }
 
-static inline bool skb_flow_dissect_flow_keys(const struct sk_buff *skb,
+static inline bool skb_flow_dissect_flow_keys(struct sk_buff *skb,
 					      struct flow_keys *flow,
 					      unsigned int flags)
 {
@@ -1225,7 +1225,7 @@ static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6
 	return skb->hash;
 }
 
-__u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb);
+__u32 skb_get_hash_perturb(struct sk_buff *skb, u32 perturb);
 
 static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
 {
diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 1a7f7e424320..a376dfe1ad44 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -374,11 +374,11 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags);
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
-		       const struct sk_buff *skb);
+		       struct sk_buff *skb);
 #endif
 void fib_select_multipath(struct fib_result *res, int hash);
 void fib_select_path(struct net *net, struct fib_result *res,
-		     struct flowi4 *fl4, const struct sk_buff *skb);
+		     struct flowi4 *fl4, struct sk_buff *skb);
 
 /* Exported by fib_trie.c */
 void fib_trie_init(void);
diff --git a/include/net/route.h b/include/net/route.h
index 57dfc6850d37..cb95b79f0117 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -114,10 +114,10 @@ int ip_rt_init(void);
 void rt_cache_flush(struct net *net);
 void rt_flush_dev(struct net_device *dev);
 struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *flp,
-					const struct sk_buff *skb);
+					struct sk_buff *skb);
 struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *flp,
 					    struct fib_result *res,
-					    const struct sk_buff *skb);
+					    struct sk_buff *skb);
 
 static inline struct rtable *__ip_route_output_key(struct net *net,
 						   struct flowi4 *flp)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 0a977373d003..76f5e5bc3177 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -424,7 +424,7 @@ static bool skb_flow_dissect_allowed(int *num_hdrs)
  *
  * Caller must take care of zeroing target container memory.
  */
-bool __skb_flow_dissect(const struct sk_buff *skb,
+bool __skb_flow_dissect(struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
 			void *target_container,
 			void *data, __be16 proto, int nhoff, int hlen,
@@ -1015,7 +1015,7 @@ u32 flow_hash_from_keys(struct flow_keys *keys)
 }
 EXPORT_SYMBOL(flow_hash_from_keys);
 
-static inline u32 ___skb_get_hash(const struct sk_buff *skb,
+static inline u32 ___skb_get_hash(struct sk_buff *skb,
 				  struct flow_keys *keys, u32 keyval)
 {
 	skb_flow_dissect_flow_keys(skb, keys,
@@ -1053,7 +1053,7 @@ EXPORT_SYMBOL(make_flow_keys_digest);
 
 static struct flow_dissector flow_keys_dissector_symmetric __read_mostly;
 
-u32 __skb_get_hash_symmetric(const struct sk_buff *skb)
+u32 __skb_get_hash_symmetric(struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
@@ -1090,7 +1090,7 @@ void __skb_get_hash(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
-__u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb)
+__u32 skb_get_hash_perturb(struct sk_buff *skb, u32 perturb)
 {
 	struct flow_keys keys;
 
@@ -1158,7 +1158,7 @@ u32 __skb_get_poff(const struct sk_buff *skb, void *data,
  * truncate packets without needing to push actual payload to the user
  * space and can analyze headers only, instead.
  */
-u32 skb_get_poff(const struct sk_buff *skb)
+u32 skb_get_poff(struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 57a5d48acee8..dc610646bc4c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1759,7 +1759,7 @@ void fib_select_multipath(struct fib_result *res, int hash)
 #endif
 
 void fib_select_path(struct net *net, struct fib_result *res,
-		     struct flowi4 *fl4, const struct sk_buff *skb)
+		     struct flowi4 *fl4, struct sk_buff *skb)
 {
 	bool oif_check;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94d4cd2d5ea4..94c5b81d8f2b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1791,7 +1791,7 @@ static void ip_multipath_l3_keys(const struct sk_buff *skb,
 
 /* if skb is set it will be used and fl4 can be NULL */
 int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
-		       const struct sk_buff *skb)
+		       struct sk_buff *skb)
 {
 	struct net *net = fi->fib_net;
 	struct flow_keys hash_keys;
@@ -2270,7 +2270,7 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
  */
 
 struct rtable *ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
-					const struct sk_buff *skb)
+					struct sk_buff *skb)
 {
 	__u8 tos = RT_FL_TOS(fl4);
 	struct fib_result res;
@@ -2295,7 +2295,7 @@ EXPORT_SYMBOL_GPL(ip_route_output_key_hash);
 
 struct rtable *ip_route_output_key_hash_rcu(struct net *net, struct flowi4 *fl4,
 					    struct fib_result *res,
-					    const struct sk_buff *skb)
+					    struct sk_buff *skb)
 {
 	struct net_device *dev_out = NULL;
 	int orig_oif = fl4->flowi4_oif;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 74ea863b8240..0d2d3a8d03f0 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -158,7 +158,7 @@ static inline struct sfq_head *sfq_dep_head(struct sfq_sched_data *q, sfq_index
 }
 
 static unsigned int sfq_hash(const struct sfq_sched_data *q,
-			     const struct sk_buff *skb)
+			     struct sk_buff *skb)
 {
 	return skb_get_hash_perturb(skb, q->perturbation) & (q->divisor - 1);
 }
-- 
2.11.0
