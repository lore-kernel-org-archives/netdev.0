From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 1/3] bpf, mlx5: fix mlx5e_create_rq taking reference on prog
Date: Mon, 14 Nov 2016 01:43:40 +0100
Message-ID: <0447a6161550c466ef799b46095440949ffc7df0.1479080215.git.daniel@iogearbox.net>
References: <cover.1479080215.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        tariqt@mellanox.com, zhiyisun@gmail.com, ranas@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33170 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751643AbcKNAoF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 19:44:05 -0500
In-Reply-To: <cover.1479080215.git.daniel@iogearbox.net>
In-Reply-To: <cover.1479080215.git.daniel@iogearbox.net>
References: <cover.1479080215.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In mlx5e_create_rq(), when creating a new queue, we call bpf_prog_add() but
without checking the return value. bpf_prog_add() can fail, so we really
must check it. Take the reference right when we assign it to the rq from
priv->xdp_prog, and just drop the reference on error path. Destruction in
mlx5e_destroy_rq() looks good, though.

Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 14 +++++++++++---
 kernel/bpf/syscall.c                              |  1 +
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 84e8b25..2b83667 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -489,7 +489,16 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->channel = c;
 	rq->ix      = c->ix;
 	rq->priv    = c->priv;
+
 	rq->xdp_prog = priv->xdp_prog;
+	if (rq->xdp_prog) {
+		rq->xdp_prog = bpf_prog_inc(rq->xdp_prog);
+		if (IS_ERR(rq->xdp_prog)) {
+			err = PTR_ERR(rq->xdp_prog);
+			rq->xdp_prog = NULL;
+			goto err_rq_wq_destroy;
+		}
+	}
 
 	rq->buff.map_dir = DMA_FROM_DEVICE;
 	if (rq->xdp_prog)
@@ -566,12 +575,11 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->page_cache.head = 0;
 	rq->page_cache.tail = 0;
 
-	if (rq->xdp_prog)
-		bpf_prog_add(rq->xdp_prog, 1);
-
 	return 0;
 
 err_rq_wq_destroy:
+	if (rq->xdp_prog)
+		bpf_prog_put(rq->xdp_prog);
 	mlx5_wq_destroy(&rq->wq_ctrl);
 
 	return err;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 237f3d6..751e806 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -686,6 +686,7 @@ struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
 {
 	return bpf_prog_add(prog, 1);
 }
+EXPORT_SYMBOL_GPL(bpf_prog_inc);
 
 static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
 {
-- 
1.9.3
