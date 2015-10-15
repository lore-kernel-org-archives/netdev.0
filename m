From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: core: Fix race condition in __mlxsw_emad_transmit
Date: Thu, 15 Oct 2015 08:21:55 +0200
Message-ID: <1444890115-1726-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:35244 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbbJOGV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 02:21:57 -0400
Received: by wicll6 with SMTP id ll6so25395556wic.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 23:21:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Under certain conditions EMAD responses can be returned from the device
even before setting trans_active. This will cause the EMAD Rx listener
to drop the EMAD response - as there are no active transactions - and
timeouts will be generated.

Fix this by setting trans_active before transmitting the EMAD skb.

Fixes: 4ec14b7634b2 ("mlxsw: Add interface to access registers and process events")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index dbcaf5d..28c19cc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -374,26 +374,31 @@ static int __mlxsw_emad_transmit(struct mlxsw_core *mlxsw_core,
 	int err;
 	int ret;
 
+	mlxsw_core->emad.trans_active = true;
+
 	err = mlxsw_core_skb_transmit(mlxsw_core->driver_priv, skb, tx_info);
 	if (err) {
 		dev_err(mlxsw_core->bus_info->dev, "Failed to transmit EMAD (tid=%llx)\n",
 			mlxsw_core->emad.tid);
 		dev_kfree_skb(skb);
-		return err;
+		goto trans_inactive_out;
 	}
 
-	mlxsw_core->emad.trans_active = true;
 	ret = wait_event_timeout(mlxsw_core->emad.wait,
 				 !(mlxsw_core->emad.trans_active),
 				 msecs_to_jiffies(MLXSW_EMAD_TIMEOUT_MS));
 	if (!ret) {
 		dev_warn(mlxsw_core->bus_info->dev, "EMAD timed-out (tid=%llx)\n",
 			 mlxsw_core->emad.tid);
-		mlxsw_core->emad.trans_active = false;
-		return -EIO;
+		err = -EIO;
+		goto trans_inactive_out;
 	}
 
 	return 0;
+
+trans_inactive_out:
+	mlxsw_core->emad.trans_active = false;
+	return err;
 }
 
 static int mlxsw_emad_process_status(struct mlxsw_core *mlxsw_core,
-- 
1.9.3
