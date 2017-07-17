From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] mlxsw: spectrum: Add support for IPv6 MLDv1/2 traps
Date: Mon, 17 Jul 2017 14:15:31 +0200
Message-ID: <20170717121532.4036-4-jiri@resnulli.us>
References: <20170717121532.4036-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34692 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdGQMPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:15:40 -0400
Received: by mail-wr0-f195.google.com with SMTP id w4so969643wrb.1
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:15:39 -0700 (PDT)
In-Reply-To: <20170717121532.4036-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for IPv6 MLDv1/2 packet trapping.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |  4 ++++
 3 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 1bd34d9..0ca1968 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3688,6 +3688,7 @@ enum mlxsw_reg_htgt_trap_group {
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IP2ME,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_EVENT,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_MLD,
 };
 
 /* reg_htgt_trap_group
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index bc35b40..1aa6298 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3333,6 +3333,14 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_MARK(ARPBC, MIRROR_TO_CPU, ARP, false),
 	MLXSW_SP_RXL_MARK(ARPUC, MIRROR_TO_CPU, ARP, false),
 	MLXSW_SP_RXL_NO_MARK(FID_MISS, TRAP_TO_CPU, IP2ME, false),
+	MLXSW_SP_RXL_MARK(IPV6_MLDV12_LISTENER_QUERY, MIRROR_TO_CPU, IPV6_MLD,
+			  false),
+	MLXSW_SP_RXL_NO_MARK(IPV6_MLDV1_LISTENER_REPORT, TRAP_TO_CPU, IPV6_MLD,
+			     false),
+	MLXSW_SP_RXL_NO_MARK(IPV6_MLDV1_LISTENER_DONE, TRAP_TO_CPU, IPV6_MLD,
+			     false),
+	MLXSW_SP_RXL_NO_MARK(IPV6_MLDV2_LISTENER_REPORT, TRAP_TO_CPU, IPV6_MLD,
+			     false),
 	/* L3 traps */
 	MLXSW_SP_RXL_MARK(MTUERROR, TRAP_TO_CPU, ROUTER_EXP, false),
 	MLXSW_SP_RXL_MARK(TTLERROR, TRAP_TO_CPU, ROUTER_EXP, false),
@@ -3377,6 +3385,7 @@ static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
 			burst_size = 7;
 			break;
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IGMP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_MLD:
 			rate = 16 * 1024;
 			burst_size = 10;
 			break;
@@ -3441,6 +3450,7 @@ static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 			break;
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IGMP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IP2ME:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_MLD:
 			priority = 3;
 			tc = 3;
 			break;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 4946d4e..891b4ee 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -63,6 +63,10 @@ enum {
 	MLXSW_TRAP_ID_LBERROR = 0x54,
 	MLXSW_TRAP_ID_OSPF = 0x55,
 	MLXSW_TRAP_ID_IP2ME = 0x5F,
+	MLXSW_TRAP_ID_IPV6_MLDV12_LISTENER_QUERY = 0x65,
+	MLXSW_TRAP_ID_IPV6_MLDV1_LISTENER_REPORT = 0x66,
+	MLXSW_TRAP_ID_IPV6_MLDV1_LISTENER_DONE = 0x67,
+	MLXSW_TRAP_ID_IPV6_MLDV2_LISTENER_REPORT = 0x68,
 	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
 	MLXSW_TRAP_ID_BGP_IPV4 = 0x88,
 	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
-- 
2.9.3
