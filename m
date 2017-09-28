From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/7] mlxsw: spectrum: Add trap for multicast trap-and-forward routes
Date: Thu, 28 Sep 2017 19:34:13 +0200
Message-ID: <20170928173415.15551-6-jiri@resnulli.us>
References: <20170928173415.15551-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:55629 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdI1ReW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:34:22 -0400
Received: by mail-wm0-f68.google.com with SMTP id u138so3701427wmu.4
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 10:34:21 -0700 (PDT)
In-Reply-To: <20170928173415.15551-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

When a multicast route is configured with trap-and-forward action, the
packets should be marked with skb->offload_mr_fwd_mark, in order to prevent
the packets from being forwarded again by the kernel ipmr module.

Due to this, it is not possible to use the already existing multicast trap
(MLXSW_TRAP_ID_ACL1) as the packet should be marked differently. Add the
MLXSW_TRAP_ID_ACL2 which is for trap-and-forward multicast routes, and set
the offload_mr_fwd_mark skb field in its handler.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 13 +++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |  2 ++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index e9b9443..3adf237 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3312,6 +3312,14 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 	return mlxsw_sp_rx_listener_no_mark_func(skb, local_port, priv);
 }
 
+static void mlxsw_sp_rx_listener_mr_mark_func(struct sk_buff *skb,
+					      u8 local_port, void *priv)
+{
+	skb->offload_mr_fwd_mark = 1;
+	skb->offload_fwd_mark = 1;
+	return mlxsw_sp_rx_listener_no_mark_func(skb, local_port, priv);
+}
+
 static void mlxsw_sp_rx_listener_sample_func(struct sk_buff *skb, u8 local_port,
 					     void *priv)
 {
@@ -3355,6 +3363,10 @@ static void mlxsw_sp_rx_listener_sample_func(struct sk_buff *skb, u8 local_port,
 	MLXSW_RXL(mlxsw_sp_rx_listener_mark_func, _trap_id, _action,	\
 		_is_ctrl, SP_##_trap_group, DISCARD)
 
+#define MLXSW_SP_RXL_MR_MARK(_trap_id, _action, _trap_group, _is_ctrl)	\
+	MLXSW_RXL(mlxsw_sp_rx_listener_mr_mark_func, _trap_id, _action,	\
+		_is_ctrl, SP_##_trap_group, DISCARD)
+
 #define MLXSW_SP_EVENTL(_func, _trap_id)		\
 	MLXSW_EVENTL(_func, _trap_id, SP_EVENT)
 
@@ -3425,6 +3437,7 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_MARK(IPV4_PIM, TRAP_TO_CPU, PIM, false),
 	MLXSW_SP_RXL_MARK(RPF, TRAP_TO_CPU, RPF, false),
 	MLXSW_SP_RXL_MARK(ACL1, TRAP_TO_CPU, MULTICAST, false),
+	MLXSW_SP_RXL_MR_MARK(ACL2, TRAP_TO_CPU, MULTICAST, false),
 };
 
 static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index a981035..ec6cef8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -93,6 +93,8 @@ enum {
 	MLXSW_TRAP_ID_ACL0 = 0x1C0,
 	/* Multicast trap used for routes with trap action */
 	MLXSW_TRAP_ID_ACL1 = 0x1C1,
+	/* Multicast trap used for routes with trap-and-forward action */
+	MLXSW_TRAP_ID_ACL2 = 0x1C2,
 
 	MLXSW_TRAP_ID_MAX = 0x1FF
 };
-- 
2.9.5
