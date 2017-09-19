From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/13] mlxsw: spectrum: Add multicast router traps and trap groups
Date: Tue, 19 Sep 2017 10:00:20 +0200
Message-ID: <20170919080020.5870-14-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36617 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751628AbdISIAf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:35 -0400
Received: by mail-wr0-f195.google.com with SMTP id g50so1706232wra.3
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:34 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add three new traps needed for multicast routing:
 - PIM: Trap for PIM protocol control packets.
 - RPF: Trap for packets that fail the RPF check on a specific hardware
   route entry.
 - MULTICAST: Generic trap for multicast. It is used for routes that trap
   the packets to the CPU.

The RPF and MULTICAST traps have rate limiters as these traps may have
line-rate of packets trapped. The PIM trap has a rate limiter similarly to
other L3 control protocols. The rate limiters are implemented by adding
three new trap groups for the newly introduced traps.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |  4 ++++
 3 files changed, 17 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index c203e0d..17eba19 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3681,12 +3681,15 @@ enum mlxsw_reg_htgt_trap_group {
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IGMP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_OSPF,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_PIM,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_MULTICAST,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_HOST_MISS,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IP2ME,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_RPF,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_EVENT,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_MLD,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_ND,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6ba6ff2..e9b9443 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3421,6 +3421,10 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 		  false, SP_IP2ME, DISCARD),
 	/* ACL trap */
 	MLXSW_SP_RXL_NO_MARK(ACL0, TRAP_TO_CPU, IP2ME, false),
+	/* Multicast Router Traps */
+	MLXSW_SP_RXL_MARK(IPV4_PIM, TRAP_TO_CPU, PIM, false),
+	MLXSW_SP_RXL_MARK(RPF, TRAP_TO_CPU, RPF, false),
+	MLXSW_SP_RXL_MARK(ACL1, TRAP_TO_CPU, MULTICAST, false),
 };
 
 static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
@@ -3446,6 +3450,8 @@ static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LACP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LLDP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_OSPF:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_PIM:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_RPF:
 			rate = 128;
 			burst_size = 7;
 			break;
@@ -3461,6 +3467,7 @@ static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_ND:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_MULTICAST:
 			rate = 1024;
 			burst_size = 7;
 			break;
@@ -3506,6 +3513,7 @@ static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LACP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_LLDP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_OSPF:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_PIM:
 			priority = 5;
 			tc = 5;
 			break;
@@ -3522,12 +3530,14 @@ static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 			break;
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_ND:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_RPF:
 			priority = 2;
 			tc = 2;
 			break;
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_HOST_MISS:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_MULTICAST:
 			priority = 1;
 			tc = 1;
 			break;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index f396a1f..a981035 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -62,6 +62,8 @@ enum {
 	MLXSW_TRAP_ID_TTLERROR = 0x53,
 	MLXSW_TRAP_ID_LBERROR = 0x54,
 	MLXSW_TRAP_ID_IPV4_OSPF = 0x55,
+	MLXSW_TRAP_ID_IPV4_PIM = 0x58,
+	MLXSW_TRAP_ID_RPF = 0x5C,
 	MLXSW_TRAP_ID_IP2ME = 0x5F,
 	MLXSW_TRAP_ID_IPV6_UNSPECIFIED_ADDRESS = 0x60,
 	MLXSW_TRAP_ID_IPV6_LINK_LOCAL_DEST = 0x61,
@@ -89,6 +91,8 @@ enum {
 	MLXSW_TRAP_ID_ROUTER_ALERT_IPV4 = 0xD6,
 	MLXSW_TRAP_ID_ROUTER_ALERT_IPV6 = 0xD7,
 	MLXSW_TRAP_ID_ACL0 = 0x1C0,
+	/* Multicast trap used for routes with trap action */
+	MLXSW_TRAP_ID_ACL1 = 0x1C1,
 
 	MLXSW_TRAP_ID_MAX = 0x1FF
 };
-- 
2.9.5
