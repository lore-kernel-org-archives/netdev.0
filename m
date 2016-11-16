From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/4] bpf, mlx5: fix mlx5e_create_rq taking reference on prog
Date: Wed, 16 Nov 2016 01:04:08 +0100
Message-ID: <282a68462b423a5694a8cb7469aa0580475ec8eb.1479253024.git.daniel@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        zhiyisun@gmail.com, ranas@mellanox.com, saeedm@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36566 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752194AbcKPAEW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:04:22 -0500
In-Reply-To: <cover.1479253024.git.daniel@iogearbox.net>
In-Reply-To: <cover.1479253024.git.daniel@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In mlx5e_create_rq(), when creating a new queue, we call bpf_prog_add() but
without checking the return value. bpf_prog_add() can fail since 92117d8443bc
("bpf: fix refcnt overflow"), so we really must check it. Take the reference
right when we assign it to the rq from priv->xdp_prog, and just drop the
reference on error path. Destruction in mlx5e_destroy_rq() looks good, though.

Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 13 +++++++++----
 kernel/bpf/syscall.c                              |  1 +
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 16a9a10..ab0c336 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -513,7 +513,13 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	rq->channel = c;
 	rq->ix      = c->ix;
 	rq->priv    = c->priv;
-	rq->xdp_prog = priv->xdp_prog;
+
+	rq->xdp_prog = priv->xdp_prog ? bpf_prog_inc(priv->xdp_prog) : NULL;
+	if (IS_ERR(rq->xdp_prog)) {
+		err = PTR_ERR(rq->xdp_prog);
+		rq->xdp_prog = NULL;
+		goto err_rq_wq_destroy;
+	}
 
 	rq->buff.map_dir = DMA_FROM_DEVICE;
 	if (rq->xdp_prog)
@@ -590,12 +596,11 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
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
index ce1b7de..eb15498 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -696,6 +696,7 @@ struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
 {
 	return bpf_prog_add(prog, 1);
 }
+EXPORT_SYMBOL_GPL(bpf_prog_inc);
 
 static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
 {
-- 
1.9.3
