From: clsoto@linux.vnet.ibm.com
Subject: [PATCH v2] net/mlx4: Memcpy at slave_event should copy sizeof mlx4_eqe
Date: Mon, 26 Oct 2015 11:15:40 -0400
Message-ID: <1445872540-18605-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, jackm@dev.mellanox.co.il,
	Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:54396 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbbJZPPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 11:15:52 -0400
Received: from /spool/local
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Mon, 26 Oct 2015 13:15:48 -0200
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id EED271DC0060
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 11:14:41 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9QFGEC25193880
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 13:16:15 -0200
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9QFFipb007011
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2015 11:15:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

If the caps.eqe_size is bigger than the struct mlx4_eqe then there
is a potential for corrupting data at the master context. We can see
the message "Master failed to generate an EQE for slave: X" when the
event_eqe array wraps and we can see potential oops at the function
mlx4_GEN_EQE. Also correct a memset of cmd_eqe to use the sizeof
mlx4_eqe instead of eqe_size. 

Fixes: 08ff32352d6f ('mlx4: 64-byte CQE/EQE support')
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

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
1.8.3.1
