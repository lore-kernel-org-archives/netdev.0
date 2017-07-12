From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 4/4] mlxsw: spectrum_switchdev: Check status of memory allocation
Date: Wed, 12 Jul 2017 09:12:55 +0200
Message-ID: <20170712071255.1232-5-jiri@resnulli.us>
References: <20170712071255.1232-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33213 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756753AbdGLHNJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 03:13:09 -0400
Received: by mail-wr0-f193.google.com with SMTP id x23so3653782wrb.0
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 00:13:09 -0700 (PDT)
In-Reply-To: <20170712071255.1232-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We can't rely on kzalloc() always succeeding, so check its return value.

Suppresses the following smatch error:

mlxsw_sp_switchdev_event() error: potential null dereference
'switchdev_work->fdb_info.addr'.  (kzalloc returns
 null)

Fixes: af061378924f ("mlxsw: spectrum_switchdev: Add support for learning FDB through notification")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 4733fe9..656b2d3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -1916,6 +1916,8 @@ static int mlxsw_sp_switchdev_event(struct notifier_block *unused,
 		memcpy(&switchdev_work->fdb_info, ptr,
 		       sizeof(switchdev_work->fdb_info));
 		switchdev_work->fdb_info.addr = kzalloc(ETH_ALEN, GFP_ATOMIC);
+		if (!switchdev_work->fdb_info.addr)
+			goto err_addr_alloc;
 		ether_addr_copy((u8 *)switchdev_work->fdb_info.addr,
 				fdb_info->addr);
 		/* Take a reference on the device. This can be either
@@ -1932,6 +1934,10 @@ static int mlxsw_sp_switchdev_event(struct notifier_block *unused,
 	mlxsw_core_schedule_work(&switchdev_work->work);
 
 	return NOTIFY_DONE;
+
+err_addr_alloc:
+	kfree(switchdev_work);
+	return NOTIFY_BAD;
 }
 
 static struct notifier_block mlxsw_sp_switchdev_notifier = {
-- 
2.9.3
