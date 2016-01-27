From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 04/11] mlxsw: spectrum: Don't forward packets when STP state is DISABLED
Date: Wed, 27 Jan 2016 15:20:19 +0100
Message-ID: <1453904426-4960-5-git-send-email-jiri@resnulli.us>
References: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38247 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932860AbcA0OUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 09:20:35 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so28695750wmp.1
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 06:20:35 -0800 (PST)
In-Reply-To: <1453904426-4960-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When STP state is set to DISABLED the port is assumed to be inactive, but
currently we forward packets ingressing through it.

Instead, set the port's STP state in hardware to DISCARDING, which means
it doesn't forward packets or perform any learning, but it does trap
control packets. However, these packets will be dropped by bridge code,
which results in the expected behavior.

Fixes: 56ade8fe3fe1 ("mlxsw: spectrum: Add initial support for Spectrum ASIC")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index f627165..913488e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -125,7 +125,6 @@ static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	int err;
 
 	switch (state) {
-	case BR_STATE_DISABLED: /* fall-through */
 	case BR_STATE_FORWARDING:
 		spms_state = MLXSW_REG_SPMS_STATE_FORWARDING;
 		break;
@@ -133,6 +132,7 @@ static int mlxsw_sp_port_stp_state_set(struct mlxsw_sp_port *mlxsw_sp_port,
 	case BR_STATE_LEARNING:
 		spms_state = MLXSW_REG_SPMS_STATE_LEARNING;
 		break;
+	case BR_STATE_DISABLED: /* fall-through */
 	case BR_STATE_BLOCKING:
 		spms_state = MLXSW_REG_SPMS_STATE_DISCARDING;
 		break;
-- 
1.9.3
