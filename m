From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 06/10] mlxsw: spectrum: Trap loop-backed packets
Date: Wed, 17 Aug 2016 16:39:33 +0200
Message-ID: <1471444777-3412-7-git-send-email-jiri@resnulli.us>
References: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	ilant@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33478 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbcHQOjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:39:48 -0400
Received: by mail-wm0-f67.google.com with SMTP id o80so24865705wme.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:39:47 -0700 (PDT)
In-Reply-To: <1471444777-3412-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

One of the conditions to generate an ICMP Redirect Message is that "the
packet is being forwarded out the same physical interface that it was
received from" (RFC 1812).

Therefore, we need to be able to trap such packets and let the kernel
decide what to do with them.

For each RIF, enable the loop-back filter, which will raise the LBERROR
trap whenever the ingress RIF equals the egress RIF.

Fixes: 99724c18fc66 ("mlxsw: spectrum: Introduce support for router interfaces")
Reported-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h      | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c |  5 +++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |  1 +
 3 files changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 7ca9201..a1bd36c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3383,6 +3383,15 @@ MLXSW_ITEM32(reg, ritr, ipv4_fe, 0x04, 29, 1);
  */
 MLXSW_ITEM32(reg, ritr, ipv6_fe, 0x04, 28, 1);
 
+/* reg_ritr_lb_en
+ * Loop-back filter enable for unicast packets.
+ * If the flag is set then loop-back filter for unicast packets is
+ * implemented on the RIF. Multicast packets are always subject to
+ * loop-back filtering.
+ * Access: RW
+ */
+MLXSW_ITEM32(reg, ritr, lb_en, 0x04, 24, 1);
+
 /* reg_ritr_virtual_router
  * Virtual router ID associated with the router interface.
  * Access: RW
@@ -3484,6 +3493,7 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	mlxsw_reg_ritr_op_set(payload, op);
 	mlxsw_reg_ritr_rif_set(payload, rif);
 	mlxsw_reg_ritr_ipv4_fe_set(payload, 1);
+	mlxsw_reg_ritr_lb_en_set(payload, 1);
 	mlxsw_reg_ritr_mtu_set(payload, mtu);
 	mlxsw_reg_ritr_if_mac_memcpy_to(payload, mac);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 6b69c8a..8137daa 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2661,6 +2661,11 @@ static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
 	{
 		.func = mlxsw_sp_rx_listener_func,
 		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_LBERROR,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
 		.trap_id = MLXSW_TRAP_ID_OSPF,
 	},
 	{
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 9508e0a..ed8e301 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -58,6 +58,7 @@ enum {
 	MLXSW_TRAP_ID_ARPUC = 0x51,
 	MLXSW_TRAP_ID_MTUERROR = 0x52,
 	MLXSW_TRAP_ID_TTLERROR = 0x53,
+	MLXSW_TRAP_ID_LBERROR = 0x54,
 	MLXSW_TRAP_ID_OSPF = 0x55,
 	MLXSW_TRAP_ID_IP2ME = 0x5F,
 	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
-- 
2.5.5
