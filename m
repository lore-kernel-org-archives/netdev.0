From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/6] mlxsw: Implement hardware messages notification using devlink
Date: Wed,  3 Feb 2016 11:47:59 +0100
Message-ID: <1454496482-13961-4-git-send-email-jiri@resnulli.us>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37213 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbcBCKsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:48:09 -0500
Received: by mail-wm0-f51.google.com with SMTP id l66so63862445wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:48:08 -0800 (PST)
In-Reply-To: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use devlink HW message notification facilities to pass massages going
to and from HW to userspace via Netlink multicast.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 15 +++++++++++----
 include/uapi/linux/devlink.h               |  2 +-
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index 57d9655..da4e6c9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -65,6 +65,7 @@
 #include "trap.h"
 #include "emad.h"
 #include "reg.h"
+#include "txheader.h"
 
 static LIST_HEAD(mlxsw_core_driver_list);
 static DEFINE_SPINLOCK(mlxsw_core_driver_list_lock);
@@ -1099,7 +1100,11 @@ static int mlxsw_core_reg_access_emad(struct mlxsw_core *mlxsw_core,
 
 	dev_dbg(mlxsw_core->bus_info->dev, "EMAD send (tid=%llx)\n",
 		mlxsw_core->emad.tid);
-	mlxsw_core_buf_dump_dbg(mlxsw_core, skb->data, skb->len);
+	devlink_hwmsg_notify(priv_to_devlink(mlxsw_core),
+			     skb->data + MLXSW_TXHDR_LEN,
+			     skb->len - MLXSW_TXHDR_LEN,
+			     DEVLINK_HWMSG_TYPE_MLX_EMAD,
+			     DEVLINK_HWMSG_DIR_TO_HW, GFP_KERNEL);
 
 	err = mlxsw_emad_transmit(mlxsw_core, skb, &tx_info);
 	if (!err) {
@@ -1109,9 +1114,11 @@ static int mlxsw_core_reg_access_emad(struct mlxsw_core *mlxsw_core,
 
 		dev_dbg(mlxsw_core->bus_info->dev, "EMAD recv (tid=%llx)\n",
 			mlxsw_core->emad.tid - 1);
-		mlxsw_core_buf_dump_dbg(mlxsw_core,
-					mlxsw_core->emad.resp_skb->data,
-					mlxsw_core->emad.resp_skb->len);
+		devlink_hwmsg_notify(priv_to_devlink(mlxsw_core),
+				     mlxsw_core->emad.resp_skb->data,
+				     mlxsw_core->emad.resp_skb->len,
+				     DEVLINK_HWMSG_TYPE_MLX_EMAD,
+				     DEVLINK_HWMSG_DIR_FROM_HW, GFP_KERNEL);
 
 		dev_kfree_skb(mlxsw_core->emad.resp_skb);
 	}
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 1d9f999..761612b 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -40,7 +40,7 @@ enum devlink_command {
 };
 
 enum devlink_hwmsg_type {
-	DEVLINK_HWMSG_TYPE_TMP, /* temporary, until first message type is introduced */
+	DEVLINK_HWMSG_TYPE_MLX_EMAD, /* Mellanox EMAD packet */
 };
 
 enum devlink_hwmsg_dir {
-- 
1.9.3
