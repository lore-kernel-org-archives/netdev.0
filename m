From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] mlxsw: spectrum: Mirror certain packets to CPU
Date: Thu, 25 Aug 2016 18:42:40 +0200
Message-ID: <1472143360-15796-6-git-send-email-jiri@resnulli.us>
References: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        gospo@cumulusnetworks.com, ast@plumgrid.com, edumazet@google.com,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35492 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759533AbcHYQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:43:53 -0400
Received: by mail-wm0-f67.google.com with SMTP id i5so8154154wmg.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:42:49 -0700 (PDT)
In-Reply-To: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Instead of trapping certain packets to the CPU and then relying on it to
flood them we can instead make the device mirror them.

The following packet types are mirrored:

* DHCP: Broadcast packets that should be flooded by the device, but also
trapped in case CPU is running the DHCP server.

* IGMP query: Multicast packets that need to be forwarded to other
bridge ports, but also trapped so that receiving netdev will be marked
as a router port by the bridge driver.

* ARP request: Broadcast packets that should be forwarded to other
bridge ports, but also trapped in case requested IP is of the local
machine.

* ARP response: Unicast packets that should be forwarded by the bridge
but also trapped in case response is directed at us.

Set the trap action of such packets to mirror and mark them using
'offload_fwd_mark' to prevent the bridge driver from forwarding them
itself.

Note that OSPF packets are also marked despite their action being trap.
The reason for this is that the device traps such packets in the
pipeline after they were already flooded.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index ea4086a..8c9c124 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2570,6 +2570,13 @@ static void mlxsw_sp_rx_listener_func(struct sk_buff *skb, u8 local_port,
 	netif_receive_skb(skb);
 }
 
+static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
+					   void *priv)
+{
+	skb->offload_fwd_mark = 1;
+	return mlxsw_sp_rx_listener_func(skb, local_port, priv);
+}
+
 #define MLXSW_SP_RXL(_func, _trap_id, _action)			\
 	{							\
 		.func = _func,					\
@@ -2588,19 +2595,19 @@ static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MMRP, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MVRP, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RPVST, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, DHCP, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_QUERY, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, DHCP, MIRROR_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, IGMP_QUERY, MIRROR_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V1_REPORT, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_REPORT, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V2_LEAVE, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IGMP_V3_REPORT, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPBC, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, ARPUC, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, ARPBC, MIRROR_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, ARPUC, MIRROR_TO_CPU),
 	/* L3 traps */
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, MTUERROR, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, TTLERROR, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LBERROR, TRAP_TO_CPU),
-	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, OSPF, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_mark_func, OSPF, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, IP2ME, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, RTR_INGRESS0, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, HOST_MISS_IPV4, TRAP_TO_CPU),
-- 
2.5.5
