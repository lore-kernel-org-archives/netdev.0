From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 5/6] mlx4: Implement hardware messages notification using devlink
Date: Wed,  3 Feb 2016 11:48:01 +0100
Message-ID: <1454496482-13961-6-git-send-email-jiri@resnulli.us>
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
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38352 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcBCKsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:48:11 -0500
Received: by mail-wm0-f51.google.com with SMTP id p63so63828505wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:48:11 -0800 (PST)
In-Reply-To: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use devlink HW message notification facilities to pass massages going
to and from HW to userspace via Netlink multicast.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 9 +++++++++
 include/uapi/linux/devlink.h            | 1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index d66c690..2735211 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -36,6 +36,7 @@
 #include <linux/mlx4/cmd.h>
 #include <linux/module.h>
 #include <linux/cache.h>
+#include <net/devlink.h>
 
 #include "fw.h"
 #include "icm.h"
@@ -2734,6 +2735,8 @@ static int mlx4_ACCESS_REG(struct mlx4_dev *dev, u16 reg_id,
 {
 	struct mlx4_cmd_mailbox *inbox, *outbox;
 	struct mlx4_access_reg *inbuf, *outbuf;
+	struct mlx4_priv *priv = mlx4_priv(dev);
+	struct devlink *devlink = priv_to_devlink(priv);
 	int err;
 
 	inbox = mlx4_alloc_cmd_mailbox(dev);
@@ -2760,6 +2763,9 @@ static int mlx4_ACCESS_REG(struct mlx4_dev *dev, u16 reg_id,
 			    ((0x3) << 12));
 
 	memcpy(inbuf->reg_data, reg_data, reg_len);
+	devlink_hwmsg_notify(devlink, reg_data, reg_len,
+			     DEVLINK_HWMSG_TYPE_MLX_CMD_REG,
+			     DEVLINK_HWMSG_DIR_TO_HW, GFP_KERNEL);
 	err = mlx4_cmd_box(dev, inbox->dma, outbox->dma, 0, 0,
 			   MLX4_CMD_ACCESS_REG, MLX4_CMD_TIME_CLASS_C,
 			   MLX4_CMD_WRAPPED);
@@ -2775,6 +2781,9 @@ static int mlx4_ACCESS_REG(struct mlx4_dev *dev, u16 reg_id,
 	}
 
 	memcpy(reg_data, outbuf->reg_data, reg_len);
+	devlink_hwmsg_notify(devlink, reg_data, reg_len,
+			     DEVLINK_HWMSG_TYPE_MLX_CMD_REG,
+			     DEVLINK_HWMSG_DIR_FROM_HW, GFP_KERNEL);
 out:
 	mlx4_free_cmd_mailbox(dev, inbox);
 	mlx4_free_cmd_mailbox(dev, outbox);
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 761612b..f06f4f7 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -41,6 +41,7 @@ enum devlink_command {
 
 enum devlink_hwmsg_type {
 	DEVLINK_HWMSG_TYPE_MLX_EMAD, /* Mellanox EMAD packet */
+	DEVLINK_HWMSG_TYPE_MLX_CMD_REG, /* Mellanox CMD iface register access */
 };
 
 enum devlink_hwmsg_dir {
-- 
1.9.3
