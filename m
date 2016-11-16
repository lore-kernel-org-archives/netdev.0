From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 2/4] bpf, mlx5: fix various refcount issues in mlx5e_xdp_set
Date: Wed, 16 Nov 2016 01:04:09 +0100
Message-ID: <0899adb6ace97b7e7f94b04dd11a0e55270d2b54.1479253024.git.daniel@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        zhiyisun@gmail.com, ranas@mellanox.com, saeedm@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36568 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752604AbcKPAEW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:04:22 -0500
In-Reply-To: <cover.1479253024.git.daniel@iogearbox.net>
In-Reply-To: <cover.1479253024.git.daniel@iogearbox.net>
References: <cover.1479253024.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are multiple issues in mlx5e_xdp_set():

1) The batched bpf_prog_add() is currently not checked for errors! When
   doing so, it should be done at an earlier point in time to makes sure
   that we cannot fail anymore at the time we want to set the program for
   each channel. This only means that we have to undo the bpf_prog_add()
   in case we return due to required reset.

2) When swapping the priv->xdp_prog, then no extra reference count must be
   taken since we got that from call path via dev_change_xdp_fd() already.
   Otherwise, we'd never be able to free the program. Also, bpf_prog_add()
   without checking the return code could fail.

Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 25 ++++++++++++++++++-----
 1 file changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index ab0c336..cf26672 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3142,6 +3142,17 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
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
@@ -3149,10 +3160,10 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
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
 
@@ -3163,12 +3174,11 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
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
 
@@ -3190,6 +3200,11 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
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
-- 
1.9.3
