From: avivh@mellanox.com
Subject: [PATCH net-next 2/3] xfrm: Fix offload dev state addition to occur after insertion
Date: Tue, 24 Oct 2017 18:10:30 +0300
Message-ID: <1508857831-55824-2-git-send-email-avivh@mellanox.com>
References: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Boris Pismenny <borisp@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        netdev@vger.kernel.org, Aviv Heller <avivh@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0069.outbound.protection.outlook.com ([104.47.1.69]:35072
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751772AbdJXPK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 11:10:56 -0400
In-Reply-To: <1508857831-55824-1-git-send-email-avivh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aviv Heller <avivh@mellanox.com>

Adding the state to the offload device prior to replay init in
xfrm_state_construct() will result in NULL dereference if a matching
ESP packet is received in between.

Adding it after insertion also has the benefit of the driver not having
to check whether a state with the same match criteria already exists,
but forces us to use an atomic type for the offload_handle, to make
certain a stack-read/driver-write race won't result in reading corrupt
data.

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Signed-off-by: Aviv Heller <avivh@mellanox.com>
Signed-off-by: Yevgeny Kliteynik <kliteyn@mellanox.com>
---
 .../ethernet/mellanox/mlx5/core/en_accel/ipsec.c   | 12 +++++------
 .../mellanox/mlx5/core/en_accel/ipsec_rxtx.c       |  4 ++--
 include/net/xfrm.h                                 | 25 ++++++++++++++++++++--
 net/ipv4/esp4.c                                    |  4 ++--
 net/ipv4/esp4_offload.c                            |  2 +-
 net/ipv6/esp6.c                                    |  4 ++--
 net/ipv6/esp6_offload.c                            |  2 +-
 net/xfrm/xfrm_device.c                             |  2 +-
 net/xfrm/xfrm_user.c                               | 21 +++++++++---------
 9 files changed, 48 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.c b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.c
index bac5103..07846fe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec.c
@@ -304,7 +304,7 @@ static int mlx5e_xfrm_add_state(struct xfrm_state *x)
 	if (err)
 		goto err_sadb_rx;
 
-	x->xso.offload_handle = (unsigned long)sa_entry;
+	xfrm_dev_set_offload_handle(x, (u64)sa_entry);
 	goto out;
 
 err_sadb_rx:
@@ -320,14 +320,13 @@ static int mlx5e_xfrm_add_state(struct xfrm_state *x)
 
 static void mlx5e_xfrm_del_state(struct xfrm_state *x)
 {
-	struct mlx5e_ipsec_sa_entry *sa_entry;
+	struct mlx5e_ipsec_sa_entry *sa_entry = (void *)xfrm_dev_offload_handle(x);
 	struct mlx5_accel_ipsec_sa hw_sa;
 	void *context;
 
-	if (!x->xso.offload_handle)
+	if (!sa_entry)
 		return;
 
-	sa_entry = (struct mlx5e_ipsec_sa_entry *)x->xso.offload_handle;
 	WARN_ON(sa_entry->x != x);
 
 	if (x->xso.flags & XFRM_OFFLOAD_INBOUND)
@@ -343,13 +342,12 @@ static void mlx5e_xfrm_del_state(struct xfrm_state *x)
 
 static void mlx5e_xfrm_free_state(struct xfrm_state *x)
 {
-	struct mlx5e_ipsec_sa_entry *sa_entry;
+	struct mlx5e_ipsec_sa_entry *sa_entry = (void *)xfrm_dev_offload_handle(x);
 	int res;
 
-	if (!x->xso.offload_handle)
+	if (!sa_entry)
 		return;
 
-	sa_entry = (struct mlx5e_ipsec_sa_entry *)x->xso.offload_handle;
 	WARN_ON(sa_entry->x != x);
 
 	res = mlx5_accel_ipsec_sa_cmd_wait(sa_entry->context);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
index 4614ddf..c5d4e8f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_accel/ipsec_rxtx.c
@@ -243,7 +243,7 @@ struct sk_buff *mlx5e_ipsec_handle_tx_skb(struct net_device *netdev,
 		goto drop;
 	}
 
-	if (unlikely(!x->xso.offload_handle ||
+	if (unlikely(!xfrm_dev_offload_handle(x) ||
 		     (skb->protocol != htons(ETH_P_IP) &&
 		      skb->protocol != htons(ETH_P_IPV6)))) {
 		atomic64_inc(&priv->ipsec->sw_stats.ipsec_tx_drop_not_ip);
@@ -353,7 +353,7 @@ bool mlx5e_ipsec_feature_check(struct sk_buff *skb, struct net_device *netdev,
 
 	if (skb->sp && skb->sp->len) {
 		x = skb->sp->xvec[0];
-		if (x && x->xso.offload_handle)
+		if (x && xfrm_dev_offload_handle(x))
 			return true;
 	}
 	return false;
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 3cb618b..41a1afc 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -125,7 +125,7 @@ struct xfrm_state_walk {
 
 struct xfrm_state_offload {
 	struct net_device	*dev;
-	unsigned long		offload_handle;
+	atomic64_t		offload_handle;
 	unsigned int		num_exthdrs;
 	u8			flags;
 };
@@ -1862,6 +1862,17 @@ int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
 		       struct xfrm_user_offload *xuo);
 bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x);
 
+static inline void xfrm_dev_set_offload_handle(struct xfrm_state *x,
+					       u64 offload_handle)
+{
+	atomic64_set(&x->xso.offload_handle, offload_handle);
+}
+
+static inline u64 xfrm_dev_offload_handle(struct xfrm_state *x)
+{
+	return atomic64_read(&x->xso.offload_handle);
+}
+
 static inline bool xfrm_dst_offload_ok(struct dst_entry *dst)
 {
 	struct xfrm_state *x = dst->xfrm;
@@ -1869,7 +1880,7 @@ static inline bool xfrm_dst_offload_ok(struct dst_entry *dst)
 	if (!x || !x->type_offload)
 		return false;
 
-	if (x->xso.offload_handle && (x->xso.dev == dst->path->dev) &&
+	if (xfrm_dev_offload_handle(x) && (x->xso.dev == dst->path->dev) &&
 	    !dst->child->xfrm)
 		return true;
 
@@ -1919,6 +1930,16 @@ static inline bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x
 	return false;
 }
 
+static inline void xfrm_dev_set_offload_handle(struct xfrm_state *x,
+					       u64 offload_handle)
+{
+}
+
+static inline u64 xfrm_dev_offload_handle(struct xfrm_state *x)
+{
+	return 0;
+}
+
 static inline bool xfrm_dst_offload_ok(struct dst_entry *dst)
 {
 	return false;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index b00e4a4..250796f 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -832,7 +832,7 @@ static int esp_init_aead(struct xfrm_state *x)
 		     x->geniv, x->aead->alg_name) >= CRYPTO_MAX_ALG_NAME)
 		goto error;
 
-	if (x->xso.offload_handle)
+	if (xfrm_dev_offload_handle(x))
 		mask |= CRYPTO_ALG_ASYNC;
 
 	aead = crypto_alloc_aead(aead_name, 0, mask);
@@ -891,7 +891,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 			goto error;
 	}
 
-	if (x->xso.offload_handle)
+	if (xfrm_dev_offload_handle(x))
 		mask |= CRYPTO_ALG_ASYNC;
 
 	aead = crypto_alloc_aead(authenc_name, 0, mask);
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index f8b918c..ddeb5c1 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -211,7 +211,7 @@ static int esp_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features_
 	if (!xo)
 		return -EINVAL;
 
-	if (!(features & NETIF_F_HW_ESP) || !x->xso.offload_handle ||
+	if (!(features & NETIF_F_HW_ESP) || !xfrm_dev_offload_handle(x) ||
 	    (x->xso.dev != skb->dev)) {
 		xo->flags |= CRYPTO_FALLBACK;
 		hw_offload = false;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 1696401..fd9daac 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -741,7 +741,7 @@ static int esp_init_aead(struct xfrm_state *x)
 		     x->geniv, x->aead->alg_name) >= CRYPTO_MAX_ALG_NAME)
 		goto error;
 
-	if (x->xso.offload_handle)
+	if (xfrm_dev_offload_handle(x))
 		mask |= CRYPTO_ALG_ASYNC;
 
 	aead = crypto_alloc_aead(aead_name, 0, mask);
@@ -800,7 +800,7 @@ static int esp_init_authenc(struct xfrm_state *x)
 			goto error;
 	}
 
-	if (x->xso.offload_handle)
+	if (xfrm_dev_offload_handle(x))
 		mask |= CRYPTO_ALG_ASYNC;
 
 	aead = crypto_alloc_aead(authenc_name, 0, mask);
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index 333a478..5103efd 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -238,7 +238,7 @@ static int esp6_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features
 	if (!xo)
 		return -EINVAL;
 
-	if (!(features & NETIF_F_HW_ESP) || !x->xso.offload_handle ||
+	if (!(features & NETIF_F_HW_ESP) || !xfrm_dev_offload_handle(x) ||
 	    (x->xso.dev != skb->dev)) {
 		xo->flags |= CRYPTO_FALLBACK;
 		hw_offload = false;
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index acf0010..0e7b6a4 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -119,7 +119,7 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
 	if (!x->type_offload || x->encap)
 		return false;
 
-	if ((x->xso.offload_handle && (dev == dst->path->dev)) &&
+	if ((xfrm_dev_offload_handle(x) && (dev == dst->path->dev)) &&
 	     !dst->child->xfrm && x->type->get_mtu) {
 		mtu = x->type->get_mtu(x, xdst->child_mtu_cached);
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index f7a12aa..a80ccfb 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -598,13 +598,6 @@ static struct xfrm_state *xfrm_state_construct(struct net *net,
 			goto error;
 	}
 
-	if (attrs[XFRMA_OFFLOAD_DEV]) {
-		err = xfrm_dev_state_add(net, x,
-					 nla_data(attrs[XFRMA_OFFLOAD_DEV]));
-		if (err)
-			goto error;
-	}
-
 	if ((err = xfrm_alloc_replay_state_esn(&x->replay_esn, &x->preplay_esn,
 					       attrs[XFRMA_REPLAY_ESN_VAL])))
 		goto error;
@@ -653,20 +646,28 @@ static int xfrm_add_sa(struct sk_buff *skb, struct nlmsghdr *nlh,
 	else
 		err = xfrm_state_update(x);
 
-	xfrm_audit_state_add(x, err ? 0 : 1, true);
-
-	if (err < 0) {
+	if (err) {
 		x->km.state = XFRM_STATE_DEAD;
 		__xfrm_state_put(x);
 		goto out;
 	}
 
+	if (attrs[XFRMA_OFFLOAD_DEV])
+		err = xfrm_dev_state_add(net, x,
+					 nla_data(attrs[XFRMA_OFFLOAD_DEV]));
+
+	if (err) {
+		xfrm_state_delete(x);
+		goto out;
+	}
+
 	c.seq = nlh->nlmsg_seq;
 	c.portid = nlh->nlmsg_pid;
 	c.event = nlh->nlmsg_type;
 
 	km_state_notify(x, &c);
 out:
+	xfrm_audit_state_add(x, err ? 0 : 1, true);
 	xfrm_state_put(x);
 	return err;
 }
-- 
1.8.3.1
