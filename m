From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 1/3] mlxsw: spectrum: Check requested ageing time is valid
Date: Tue,  8 Mar 2016 12:59:33 -0800
Message-ID: <1457470775-32224-2-git-send-email-stephen@networkplumber.org>
References: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org, Ido Schimmel <idosch@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34903 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbcCHU7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:59:24 -0500
Received: by mail-pf0-f169.google.com with SMTP id x188so21187829pfb.2
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 12:59:24 -0800 (PST)
In-Reply-To: <1457470775-32224-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Commit c62987bbd8a1 ("bridge: push bridge setting ageing_time down to
switchdev") added a check for minimum and maximum ageing time, but this
breaks existing behaviour where one can set ageing time to 0 for a
non-learning bridge.

Push this check down to the driver and allow the check in the bridge
layer to be removed. Currently ageing time 0 is refused by the driver,
but we can later add support for this functionality.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           | 2 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 9 +++++++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 3b89ed2..65a115f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -118,6 +118,8 @@ struct mlxsw_sp {
 #define MLXSW_SP_DEFAULT_LEARNING_INTERVAL 100
 		unsigned int interval; /* ms */
 	} fdb_notify;
+#define MLXSW_SP_MIN_AGEING_TIME 10
+#define MLXSW_SP_MAX_AGEING_TIME 1000000
 #define MLXSW_SP_DEFAULT_AGEING_TIME 300
 	u32 ageing_time;
 	struct mlxsw_sp_upper master_bridge;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index 7b56098..e1c74ef 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -311,8 +311,13 @@ static int mlxsw_sp_port_attr_br_ageing_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	unsigned long ageing_jiffies = clock_t_to_jiffies(ageing_clock_t);
 	u32 ageing_time = jiffies_to_msecs(ageing_jiffies) / 1000;
 
-	if (switchdev_trans_ph_prepare(trans))
-		return 0;
+	if (switchdev_trans_ph_prepare(trans)) {
+		if (ageing_time < MLXSW_SP_MIN_AGEING_TIME ||
+		    ageing_time > MLXSW_SP_MAX_AGEING_TIME)
+			return -ERANGE;
+		else
+			return 0;
+	}
 
 	return mlxsw_sp_ageing_set(mlxsw_sp, ageing_time);
 }
-- 
2.1.4
