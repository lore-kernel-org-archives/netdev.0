From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/22] mlxsw: spectrum: Add support for IPv6 traps
Date: Tue, 18 Jul 2017 10:10:11 +0200
Message-ID: <20170718081030.2781-4-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:34171 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbdGRIKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:38 -0400
Received: by mail-wr0-f194.google.com with SMTP id w4so2852181wrb.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:37 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Before we can start using IPv6, we need to trap certain control packets
to the CPU. Among others, these include Neighbour Discovery, DHCP and
neighbour misses.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      |  5 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 39 +++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlxsw/trap.h     | 20 +++++++++++--
 3 files changed, 53 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 8282acb..fe196fd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3679,16 +3679,17 @@ enum mlxsw_reg_htgt_trap_group {
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_LACP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_LLDP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IGMP,
-	MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP_IPV4,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_OSPF,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP,
-	MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP_MISS,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_HOST_MISS,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IP2ME,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_EVENT,
 	MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_MLD,
+	MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_ND,
 };
 
 /* reg_htgt_trap_group
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1aa6298..d6dc3dc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3345,12 +3345,35 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_MARK(MTUERROR, TRAP_TO_CPU, ROUTER_EXP, false),
 	MLXSW_SP_RXL_MARK(TTLERROR, TRAP_TO_CPU, ROUTER_EXP, false),
 	MLXSW_SP_RXL_MARK(LBERROR, TRAP_TO_CPU, ROUTER_EXP, false),
-	MLXSW_SP_RXL_MARK(OSPF, TRAP_TO_CPU, OSPF, false),
 	MLXSW_SP_RXL_MARK(IP2ME, TRAP_TO_CPU, IP2ME, false),
+	MLXSW_SP_RXL_MARK(IPV6_UNSPECIFIED_ADDRESS, TRAP_TO_CPU, ROUTER_EXP,
+			  false),
+	MLXSW_SP_RXL_MARK(IPV6_LINK_LOCAL_DEST, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(IPV6_LINK_LOCAL_SRC, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(IPV6_ALL_NODES_LINK, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(IPV6_ALL_ROUTERS_LINK, TRAP_TO_CPU, ROUTER_EXP,
+			  false),
+	MLXSW_SP_RXL_MARK(IPV4_OSPF, TRAP_TO_CPU, OSPF, false),
+	MLXSW_SP_RXL_MARK(IPV6_OSPF, TRAP_TO_CPU, OSPF, false),
+	MLXSW_SP_RXL_MARK(IPV6_DHCP, TRAP_TO_CPU, DHCP, false),
 	MLXSW_SP_RXL_MARK(RTR_INGRESS0, TRAP_TO_CPU, REMOTE_ROUTE, false),
-	MLXSW_SP_RXL_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, ARP_MISS, false),
-	MLXSW_SP_RXL_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
+	MLXSW_SP_RXL_MARK(IPV4_BGP, TRAP_TO_CPU, BGP, false),
+	MLXSW_SP_RXL_MARK(IPV6_BGP, TRAP_TO_CPU, BGP, false),
+	MLXSW_SP_RXL_MARK(L3_IPV6_ROUTER_SOLICITATION, TRAP_TO_CPU, IPV6_ND,
+			  false),
+	MLXSW_SP_RXL_MARK(L3_IPV6_ROUTER_ADVERTISMENT, TRAP_TO_CPU, IPV6_ND,
+			  false),
+	MLXSW_SP_RXL_MARK(L3_IPV6_NEIGHBOR_SOLICITATION, TRAP_TO_CPU, IPV6_ND,
+			  false),
+	MLXSW_SP_RXL_MARK(L3_IPV6_NEIGHBOR_ADVERTISMENT, TRAP_TO_CPU, IPV6_ND,
+			  false),
+	MLXSW_SP_RXL_MARK(L3_IPV6_REDIRECTION, TRAP_TO_CPU, IPV6_ND, false),
+	MLXSW_SP_RXL_MARK(IPV6_MC_LINK_LOCAL_DEST, TRAP_TO_CPU, ROUTER_EXP,
+			  false),
+	MLXSW_SP_RXL_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, HOST_MISS, false),
+	MLXSW_SP_RXL_MARK(HOST_MISS_IPV6, TRAP_TO_CPU, HOST_MISS, false),
 	MLXSW_SP_RXL_MARK(ROUTER_ALERT_IPV4, TRAP_TO_CPU, ROUTER_EXP, false),
+	MLXSW_SP_RXL_MARK(ROUTER_ALERT_IPV6, TRAP_TO_CPU, ROUTER_EXP, false),
 	/* PKT Sample trap */
 	MLXSW_RXL(mlxsw_sp_rx_listener_sample_func, PKT_SAMPLE, MIRROR_TO_CPU,
 		  false, SP_IP2ME, DISCARD),
@@ -3389,12 +3412,13 @@ static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
 			rate = 16 * 1024;
 			burst_size = 10;
 			break;
-		case MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP_IPV4:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP:
-		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP_MISS:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_HOST_MISS:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_ND:
 			rate = 1024;
 			burst_size = 7;
 			break;
@@ -3443,7 +3467,7 @@ static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 			priority = 5;
 			tc = 5;
 			break;
-		case MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP_IPV4:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_BGP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_DHCP:
 			priority = 4;
 			tc = 4;
@@ -3455,10 +3479,11 @@ static int mlxsw_sp_trap_groups_set(struct mlxsw_core *mlxsw_core)
 			tc = 3;
 			break;
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_IPV6_ND:
 			priority = 2;
 			tc = 2;
 			break;
-		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ARP_MISS:
+		case MLXSW_REG_HTGT_TRAP_GROUP_SP_HOST_MISS:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_ROUTER_EXP:
 		case MLXSW_REG_HTGT_TRAP_GROUP_SP_REMOTE_ROUTE:
 			priority = 1;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 891b4ee..6165239 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -61,16 +61,32 @@ enum {
 	MLXSW_TRAP_ID_MTUERROR = 0x52,
 	MLXSW_TRAP_ID_TTLERROR = 0x53,
 	MLXSW_TRAP_ID_LBERROR = 0x54,
-	MLXSW_TRAP_ID_OSPF = 0x55,
+	MLXSW_TRAP_ID_IPV4_OSPF = 0x55,
 	MLXSW_TRAP_ID_IP2ME = 0x5F,
+	MLXSW_TRAP_ID_IPV6_UNSPECIFIED_ADDRESS = 0x60,
+	MLXSW_TRAP_ID_IPV6_LINK_LOCAL_DEST = 0x61,
+	MLXSW_TRAP_ID_IPV6_LINK_LOCAL_SRC = 0x62,
+	MLXSW_TRAP_ID_IPV6_ALL_NODES_LINK = 0x63,
+	MLXSW_TRAP_ID_IPV6_OSPF = 0x64,
 	MLXSW_TRAP_ID_IPV6_MLDV12_LISTENER_QUERY = 0x65,
 	MLXSW_TRAP_ID_IPV6_MLDV1_LISTENER_REPORT = 0x66,
 	MLXSW_TRAP_ID_IPV6_MLDV1_LISTENER_DONE = 0x67,
 	MLXSW_TRAP_ID_IPV6_MLDV2_LISTENER_REPORT = 0x68,
+	MLXSW_TRAP_ID_IPV6_DHCP = 0x69,
+	MLXSW_TRAP_ID_IPV6_ALL_ROUTERS_LINK = 0x6F,
 	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
-	MLXSW_TRAP_ID_BGP_IPV4 = 0x88,
+	MLXSW_TRAP_ID_IPV4_BGP = 0x88,
+	MLXSW_TRAP_ID_IPV6_BGP = 0x89,
+	MLXSW_TRAP_ID_L3_IPV6_ROUTER_SOLICITATION = 0x8A,
+	MLXSW_TRAP_ID_L3_IPV6_ROUTER_ADVERTISMENT = 0x8B,
+	MLXSW_TRAP_ID_L3_IPV6_NEIGHBOR_SOLICITATION = 0x8C,
+	MLXSW_TRAP_ID_L3_IPV6_NEIGHBOR_ADVERTISMENT = 0x8D,
+	MLXSW_TRAP_ID_L3_IPV6_REDIRECTION = 0x8E,
 	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
+	MLXSW_TRAP_ID_IPV6_MC_LINK_LOCAL_DEST = 0x91,
+	MLXSW_TRAP_ID_HOST_MISS_IPV6 = 0x92,
 	MLXSW_TRAP_ID_ROUTER_ALERT_IPV4 = 0xD6,
+	MLXSW_TRAP_ID_ROUTER_ALERT_IPV6 = 0xD7,
 	MLXSW_TRAP_ID_ACL0 = 0x1C0,
 
 	MLXSW_TRAP_ID_MAX = 0x1FF
-- 
2.9.3
