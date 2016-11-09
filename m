From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, mlx4: fix prog refcount in mlx4_en_try_alloc_resources error path
Date: Wed,  9 Nov 2016 22:02:34 +0100
Message-ID: <9d5b1ed1b70a8a4db545c308bcb5b28280564798.1478724690.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        tariqt@mellanox.com, zhiyisun@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60264 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752627AbcKIVCl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 16:02:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings
scheme") added a bug in that the prog's reference count is not dropped
in the error path when mlx4_en_try_alloc_resources() is failing from
mlx4_xdp_set().

We previously took bpf_prog_add(prog, priv->rx_ring_num - 1), that we
need to release again. Earlier in the call path, dev_change_xdp_fd()
itself holds a reference to the prog as well (hence the '- 1' in the
bpf_prog_add()), so a simple atomic_sub() is safe to use here. When
an error is propagated, then bpf_prog_put() is called eventually from
dev_change_xdp_fd()

Fixes: 67f8b1dcb9ee ("net/mlx4_en: Refactor the XDP forwarding rings scheme")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  5 ++++-
 include/linux/bpf.h                            |  5 +++++
 kernel/bpf/syscall.c                           | 11 +++++++++++
 3 files changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 0f6225c..9bf7320 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2747,8 +2747,11 @@ static int mlx4_xdp_set(struct net_device *dev, struct bpf_prog *prog)
 	}
 
 	err = mlx4_en_try_alloc_resources(priv, tmp, &new_prof);
-	if (err)
+	if (err) {
+		if (prog)
+			bpf_prog_sub(prog, priv->rx_ring_num - 1);
 		goto unlock_out;
+	}
 
 	if (priv->port_up) {
 		port_up = 1;
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index edcd96d..01c1487 100644
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
index 228f962..23eb205 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -680,6 +680,17 @@ struct bpf_prog *bpf_prog_add(struct bpf_prog *prog, int i)
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
