From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v3 2/4] bpf, mlx5: fix various refcount issues in mlx5e_xdp_set
Date: Sat, 19 Nov 2016 01:45:01 +0100
Message-ID: <6030d6a2d31ce68280138ac7ed33c3fc6ba585b2.1479514784.git.daniel@iogearbox.net>
References: <cover.1479514784.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, bblanco@plumgrid.com,
        zhiyisun@gmail.com, ranas@mellanox.com, saeedm@mellanox.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58646 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752496AbcKSApZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 19:45:25 -0500
In-Reply-To: <cover.1479514784.git.daniel@iogearbox.net>
In-Reply-To: <cover.1479514784.git.daniel@iogearbox.net>
References: <cover.1479514784.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are multiple issues in mlx5e_xdp_set():

1) The batched bpf_prog_add() is currently not checked for errors. When
   doing so, it should be done at an earlier point in time to makes sure
   that we cannot fail anymore at the time we want to set the program for
   each channel. The batched refs short-cut can only be performed when we
   don't need to perform a reset for changing the rq type and the device
   was in opened state. In case the device was not in opened state, then
   the next mlx5e_open_locked() will aquire the refs from the control prog
   via mlx5e_create_rq(), same when we need to perform a reset.

2) When swapping the priv->xdp_prog, then no extra reference count must be
   taken since we got that from call path via dev_change_xdp_fd() already.
   Otherwise, we'd never be able to release the program. Also, bpf_prog_add()
   without checking the return code could fail.

Fixes: 86994156c736 ("net/mlx5e: XDP fast RX drop bpf programs support")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 54bae79..491cff9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3144,11 +3144,21 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 
 	if (was_opened && reset)
 		mlx5e_close_locked(netdev);
+	if (was_opened && !reset) {
+		/* num_channels is invariant here, so we can take the
+		 * batched reference right upfront.
+		 */
+		prog = bpf_prog_add(prog, priv->params.num_channels);
+		if (IS_ERR(prog)) {
+			err = PTR_ERR(prog);
+			goto unlock;
+		}
+	}
 
-	/* exchange programs */
+	/* exchange programs, extra prog reference we got from caller
+	 * as long as we don't fail from this point onwards.
+	 */
 	old_prog = xchg(&priv->xdp_prog, prog);
-	if (prog)
-		bpf_prog_add(prog, 1);
 	if (old_prog)
 		bpf_prog_put(old_prog);
 
@@ -3164,7 +3174,6 @@ static int mlx5e_xdp_set(struct net_device *netdev, struct bpf_prog *prog)
 	/* exchanging programs w/o reset, we update ref counts on behalf
 	 * of the channels RQs here.
 	 */
-	bpf_prog_add(prog, priv->params.num_channels);
 	for (i = 0; i < priv->params.num_channels; i++) {
 		struct mlx5e_channel *c = priv->channel[i];
 
-- 
1.9.3
