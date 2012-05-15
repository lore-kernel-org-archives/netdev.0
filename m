From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 2/8] net/mlx4_core: Fix init_port mask state for slaves
Date: Tue, 15 May 2012 10:24:44 +0300
Message-ID: <1337066690-2248-3-git-send-email-ogerlitz@mellanox.com>
References: <1337066690-2248-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, yevgenyp@mellanox.com,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:37441 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754419Ab2EOHZB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 03:25:01 -0400
In-Reply-To: <1337066690-2248-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

In function mlx4_INIT_PORT_wrapper, the port state mask for the
slave is only set if we are invoking the INIT_PORT fw command.

However, the reference count for the (initialized) port is
incremented anyway.

This creates a problem in that when we have multiple slaves,
then the CLOSE_PORT command will never be invoked. The
reason is that in the CLOSE_PORT wrapper, if the port-state
mask is zero for the slave (which it is), the wrapper returns
without doing anything. The only slave which will not return
immediately in the CLOSE_PORT wrapper is that slave for which
INIT_PORT was invoked.

The fix is to not have the port-state mask setting depend
on the logic for calling the INIT_PORT fw command.

Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 2a02ba5..24429a9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1164,9 +1164,8 @@ int mlx4_INIT_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			       MLX4_CMD_TIME_CLASS_A, MLX4_CMD_NATIVE);
 		if (err)
 			return err;
-		priv->mfunc.master.slave_state[slave].init_port_mask |=
-			(1 << port);
 	}
+	priv->mfunc.master.slave_state[slave].init_port_mask |= (1 << port);
 	++priv->mfunc.master.init_port_ref[port];
 	return 0;
 }
-- 
1.7.1
