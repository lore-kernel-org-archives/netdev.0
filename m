From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/12] mlxsw: spectrum: Add traps needed for router implementation
Date: Sat,  2 Jul 2016 11:00:20 +0200
Message-ID: <1467450020-23415-13-git-send-email-jiri@resnulli.us>
References: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33564 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315AbcGBJAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:41 -0400
Received: by mail-wm0-f66.google.com with SMTP id r201so10297735wme.0
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:40 -0700 (PDT)
In-Reply-To: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

ip2me:
To instruct HW to send trapped ip2me traffic to kernel, we have to add
this trap. Selection ip2me traffic is introduced later on in this set.

ARPs:
We are going to stop flooding to CPU port when netdev isn't bridged and
only get packets destined to the netdev's IP address and certain control
packets.

Add traps for ARP request (broadcast) and response (unicast) in order to
get these to the CPU and resolve neighbours.

host miss:
If a packet is routed through a directly connected route and its
destination IP is not in the device's neighbour table, then we need to
trap it to CPU. This will cause the host to resolve the MAC of the
neighbour, which will be eventually programmed to the device's table.

router ingress:
In order to trap packets in router part.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 25 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |  5 +++++
 2 files changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index de30763..f0799898 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2255,6 +2255,31 @@ static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
 		.local_port = MLXSW_PORT_DONT_CARE,
 		.trap_id = MLXSW_TRAP_ID_IGMP_V3_REPORT,
 	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_ARPBC,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_ARPUC,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_IP2ME,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_RTR_INGRESS0,
+	},
+	{
+		.func = mlxsw_sp_rx_listener_func,
+		.local_port = MLXSW_PORT_DONT_CARE,
+		.trap_id = MLXSW_TRAP_ID_HOST_MISS_IPV4,
+	},
 };
 
 static int mlxsw_sp_traps_init(struct mlxsw_sp *mlxsw_sp)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 53a9550..470d769 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -54,6 +54,11 @@ enum {
 	MLXSW_TRAP_ID_IGMP_V2_REPORT = 0x32,
 	MLXSW_TRAP_ID_IGMP_V2_LEAVE = 0x33,
 	MLXSW_TRAP_ID_IGMP_V3_REPORT = 0x34,
+	MLXSW_TRAP_ID_ARPBC = 0x50,
+	MLXSW_TRAP_ID_ARPUC = 0x51,
+	MLXSW_TRAP_ID_IP2ME = 0x5F,
+	MLXSW_TRAP_ID_RTR_INGRESS0 = 0x70,
+	MLXSW_TRAP_ID_HOST_MISS_IPV4 = 0x90,
 
 	MLXSW_TRAP_ID_MAX = 0x1FF
 };
-- 
2.5.5
