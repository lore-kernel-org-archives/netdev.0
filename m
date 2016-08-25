From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] mlxsw: spectrum: Allow different traps to have different actions
Date: Thu, 25 Aug 2016 18:42:39 +0200
Message-ID: <1472143360-15796-5-git-send-email-jiri@resnulli.us>
References: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        gospo@cumulusnetworks.com, ast@plumgrid.com, edumazet@google.com,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35878 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759516AbcHYQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:43:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id i138so8134173wmf.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:42:48 -0700 (PDT)
In-Reply-To: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Up until now we only trapped packets to CPU, but we are going to allow
some packets to be mirrored (trap & forward) to CPU.

Extend the Rx listener with 'action' member.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.h     |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 59 +++++++++++++-------------
 2 files changed, 31 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index d3476ea..d2e3297 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -87,6 +87,7 @@ struct mlxsw_rx_listener {
 	void (*func)(struct sk_buff *skb, u8 local_port, void *priv);
 	u8 local_port;
 	u16 trap_id;
+	enum mlxsw_reg_hpkt_action action;
 };
 
 struct mlxsw_event_listener {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index cc83cd2..ea4086a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2570,39 +2570,40 @@ static void mlxsw_sp_rx_listener_func(struct sk_buff *skb, u8 local_port,
 	netif_receive_skb(skb);
 }
 
-#define MLXSW_SP_RXL(_func, _trap_id)			\
-	{						\
-		.func = _func,				\
-		.local_port = MLXSW_PORT_DONT_CARE,	\
-		.trap_id = MLXSW_TRAP_ID_##_trap_id,	\
+#define MLXSW_SP_RXL(_func, _trap_id, _action)			\
+	{							\
+		.func = _func,					\
+		.local_port = MLXSW_PORT_DONT_CARE,		\
+		.trap_id = MLXSW_TRAP_ID_##_trap_id,		\
+		.action = MLXSW_REG_HPKT_ACTION_##_action,	\
 	}
 
 static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, FDB_MC),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, FDB_MC, TRAP_TO_CPU),
 	/* Traps for specific L2 packet types, not trapped as FDB MC */
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, STP),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LACP),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, EAPOL),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LLDP),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MMRP),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MVRP),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RPVST),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, DHCP),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_QUERY),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V1_REPORT),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_REPORT),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_LEAVE),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V3_REPORT),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPBC),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPUC),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, STP, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LACP, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, EAPOL, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LLDP, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MMRP, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MVRP, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RPVST, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, DHCP, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_QUERY, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V1_REPORT, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_REPORT, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_LEAVE, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V3_REPORT, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPBC, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPUC, TRAP_TO_CPU),
 	/* L3 traps */
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MTUERROR),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, TTLERROR),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LBERROR),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, OSPF),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IP2ME),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RTR_INGRESS0),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, HOST_MISS_IPV4),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MTUERROR, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, TTLERROR, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LBERROR, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, OSPF, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IP2ME, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RTR_INGRESS0, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, HOST_MISS_IPV4, TRAP_TO_CPU),
 };
 
 static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
@@ -2629,7 +2630,7 @@ static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
 		if (err)
 			goto err_rx_listener_register;
 
-		mlxsw_reg_hpkt_pack(hpkt_pl, MLXSW_REG_HPKT_ACTION_TRAP_TO_CPU,
+		mlxsw_reg_hpkt_pack(hpkt_pl, mlxsw_sp_rx_listener[i].action,
 				    mlxsw_sp_rx_listener[i].trap_id);
 		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(hpkt), hpkt_pl);
 		if (err)
-- 
2.5.5
