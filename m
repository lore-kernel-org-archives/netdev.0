From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/2] net/mlx4: Copy/set only sizeof struct mlx4_eqe bytes
Date: Tue, 27 Oct 2015 17:36:20 +0200
Message-ID: <1445960180-3450-3-git-send-email-ogerlitz@mellanox.com>
References: <1445960180-3450-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Carol L Soto <clsoto@linux.vnet.ibm.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45146 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751957AbbJ0Pgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 11:36:54 -0400
In-Reply-To: <1445960180-3450-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

When doing memcpy/memset of EQEs, we should use sizeof struct
mlx4_eqe as the base size and not caps.eqe_size which could be bigger.

If caps.eqe_size is bigger than the struct mlx4_eqe then we corrupt
data in the master context.

When using a 64 byte stride, the memcpy copied over 63 bytes to the
slave_eq structure.  This resulted in copying over the entire eqe of
interest, including its ownership bit -- and also 31 bytes of garbage
into the next WQE in the slave EQ -- which did NOT include the ownership
bit (and therefore had no impact).

However, once the stride is increased to 128, we are overwriting the
ownership bits of *three* eqes in the slave_eq struct.  This results
in an incorrect ownership bit for those eqes, which causes the eq to
seem to be full. The issue therefore surfaced only once 128-byte EQEs
started being used in SRIOV and (overarchitectures that have 128/256
byte cache-lines such as PPC) - e.g after commit 77507aa249ae
"net/mlx4_core: Enable CQE/EQE stride support".

Fixes: 08ff32352d6f ('mlx4: 64-byte CQE/EQE support')
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/cmd.c | 2 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
index 0a32020..2177e56 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cmd.c
@@ -2398,7 +2398,7 @@ int mlx4_multi_func_init(struct mlx4_dev *dev)
 			}
 		}
 
-		memset(&priv->mfunc.master.cmd_eqe, 0, dev->caps.eqe_size);
+		memset(&priv->mfunc.master.cmd_eqe, 0, sizeof(struct mlx4_eqe));
 		priv->mfunc.master.cmd_eqe.type = MLX4_EVENT_TYPE_CMD;
 		INIT_WORK(&priv->mfunc.master.comm_work,
 			  mlx4_master_comm_channel);
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index c344884..603d1c3 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -196,7 +196,7 @@ static void slave_event(struct mlx4_dev *dev, u8 slave, struct mlx4_eqe *eqe)
 		return;
 	}
 
-	memcpy(s_eqe, eqe, dev->caps.eqe_size - 1);
+	memcpy(s_eqe, eqe, sizeof(struct mlx4_eqe) - 1);
 	s_eqe->slave_id = slave;
 	/* ensure all information is written before setting the ownersip bit */
 	dma_wmb();
-- 
2.3.7
