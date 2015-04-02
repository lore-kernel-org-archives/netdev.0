From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: [PATCH net-next 09/16] net/mlx5_core: Avoid usage command work entry after writing command doorbell
Date: Thu,  2 Apr 2015 17:07:27 +0300
Message-ID: <1427983654-971-10-git-send-email-eli@mellanox.com>
References: <1427983654-971-1-git-send-email-eli@mellanox.com>
Cc: netdev@vger.kernel.org, idos@mellaox.com, amirv@mellanox.com,
	Ira Gusinsky <irenag@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eli Cohen <eli@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:35605 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753521AbbDBOIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 10:08:04 -0400
Received: by wgdm6 with SMTP id m6so86625786wgd.2
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 07:08:03 -0700 (PDT)
In-Reply-To: <1427983654-971-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ira Gusinsky <irenag@mellanox.com>

Avoid usage of command work entry in cmd_work_handler since it can be released
by mlx5_cmd_invoke before the work handler returns to running.

Signed-off-by: Ira Gusinsky <irenag@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Eli Cohen <eli@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
index 290ae87fdef7..0d862696b876 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
@@ -515,10 +515,11 @@ static void cmd_work_handler(struct work_struct *work)
 	ent->ts1 = ktime_get_ns();
 
 	/* ring doorbell after the descriptor is valid */
+	mlx5_core_dbg(dev, "writing 0x%x to command doorbell\n", 1 << ent->idx);
 	wmb();
 	iowrite32be(1 << ent->idx, &dev->iseg->cmd_dbell);
-	mlx5_core_dbg(dev, "write 0x%x to command doorbell\n", 1 << ent->idx);
 	mmiowb();
+	/* if not in polling don't use ent after this point */
 	if (cmd->mode == CMD_MODE_POLLING) {
 		poll_timeout(ent);
 		/* make sure we read the descriptor after ownership is SW */
-- 
2.3.1
