From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] bpf, mlx5: fix various refcount/prog issues in mlx5e_xdp_set
Date: Mon, 14 Nov 2016 01:43:41 +0100
Message-ID: <03741f7075af64e83d23add379bdab41204396b0.1479080215.git.daniel@iogearbox.net>
References: <cover.1479080215.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        tariqt@mellanox.com, zhiyisun@gmail.com, ranas@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33172 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751672AbcKNAoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 19:44:05 -0500
In-Reply-To: <cover.1479080215.git.daniel@iogearbox.net>
In-Reply-To: <cover.1479080215.git.daniel@iogearbox.net>
References: <cover.1479080215.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are multiple issues in mlx5e_xdp_set():

1) prog can be NULL, so calling unconditionally into bpf_prog_add(prog,
   priv->params.num_channels) can end badly.

2) The batched bpf_prog_add() should be done at an earlier point in
   time. This makes sure that we cannot fail anymore at the time we
   want to set the program for each channel. This only means that we
   have to undo the bpf_prog_add() in case we return early due to
   reset or device not in MLX5E_STATE_OPENED yet. Note, err is 0 here.

3) When swapping the priv->xdp_prog, then no extra reference count must
   be taken since we got that from call path via dev_change_xdp_fd()
   already. Otherwise, we'd never be able to free the program. Also,
   bpf_prog_add() without checking the return code could fail.

Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 25 ++++++++++++++++++-----
 include/linux/bpf.h                               |  5 +++++
 kernel/bpf/syscall.c                              | 11 ++++++++++
 3 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 2b83667..c90610a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3125,6 +3125,17 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 		goto unlock;
 	}
 
+	if (prog) {
+		/* num_channels is invariant here, so we can take the
+		 * batched reference right upfront.
+		 */
+		prog = bpf_prog_add(prog, priv->params.num_channels);
+		if (IS_ERR(prog)) {
+			err = PTR_ERR(prog);
+			goto unlock;
+		}
+	}
+
 	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
 	/* no need for full reset when exchanging programs */
 	reset = (!priv->xdp_prog || !prog);
@@ -3132,10 +3143,10 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	if (was_opened && reset)
 		mlx5e_close_locked(netdev);
 
-	/* exchange programs */
+	/* exchange programs, extra prog reference we got from caller
+	 * as long as we don't fail from this point onwards.
+	 */
 	old_prog = xchg(&priv->xdp_prog, prog);
-	if (prog)
-		bpf_prog_add(prog, 1);
 	if (old_prog)
 		bpf_prog_put(old_prog);
 
@@ -3146,12 +3157,11 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 		mlx5e_open_locked(netdev);
 
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state) || reset)
-		goto unlock;
+		goto unlock_put;
 
 	/* exchanging programs w/o reset, we update ref counts on behalf
 	 * of the channels RQs here.
 	 */
-	bpf_prog_add(prog, priv->params.num_channels);
 	for (i = 0; i < priv->params.num_channels; i++) {
 		struct mlx5e_channel *c = priv->channel[i];
 
@@ -3173,6 +3183,11 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 unlock:
 	mutex_unlock(&priv->state_lock);
 	return err;
+unlock_put:
+	/* reference on priv->xdp_prog is still held at this point */
+	if (prog)
+		bpf_prog_sub(prog, priv->params.num_channels);
+	goto unlock;
 }
 
 static bool mlx5e_xdp_attached(struct net_device *dev)
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index c201017..ca495fd 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -234,6 +234,7 @@ u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
 struct bpf_prog *bpf_prog_get(u32 ufd);
 struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
 struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i);
+void bpf_prog_sub(struct bpf_prog *prog, int i);
 struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog);
 void bpf_prog_put(struct bpf_prog *prog);
 
@@ -303,6 +304,10 @@ static inline struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
+static inline void bpf_prog_sub(struct bpf_prog *prog, int i)
+{
+}
+
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 751e806..a0fca9f 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -682,6 +682,17 @@ struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_add);
 
+void bpf_prog_sub(struct bpf_prog *prog, int i)
+{
+	/* Only to be used for undoing previous bpf_prog_add() in some
+	 * error path. We still know that another entity in our call
+	 * path holds a reference to the program, thus atomic_sub() can
+	 * be safely used in such cases!
+	 */
+	WARN_ON(atomic_sub_return(i, &prog->aux->refcnt) == 0);
+}
+EXPORT_SYMBOL_GPL(bpf_prog_sub);
+
 struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
 {
 	return bpf_prog_add(prog, 1);
-- 
1.9.3
