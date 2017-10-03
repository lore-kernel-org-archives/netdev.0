From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/7] mlxsw: acl: Introduce ACL trap and forward action
Date: Tue,  3 Oct 2017 09:58:09 +0200
Message-ID: <20171003075812.1540-5-jiri@resnulli.us>
References: <20171003075812.1540-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36940 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751200AbdJCH6S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 03:58:18 -0400
Received: by mail-wr0-f196.google.com with SMTP id v38so2377007wrc.4
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 00:58:17 -0700 (PDT)
In-Reply-To: <20171003075812.1540-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Use trap/discard flex action to implement trap and forward. The action will
later be used for multicast routing, as the multicast routing mechanism is
done using ACL flexible actions in Spectrum hardware. Using that action, it
will be possible to implement a trap-and-forward route.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c | 17 +++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h |  2 ++
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
index bc55d0e..6a979a0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.c
@@ -676,6 +676,7 @@ enum mlxsw_afa_trapdisc_trap_action {
 MLXSW_ITEM32(afa, trapdisc, trap_action, 0x00, 24, 4);
 
 enum mlxsw_afa_trapdisc_forward_action {
+	MLXSW_AFA_TRAPDISC_FORWARD_ACTION_FORWARD = 1,
 	MLXSW_AFA_TRAPDISC_FORWARD_ACTION_DISCARD = 3,
 };
 
@@ -729,6 +730,22 @@ int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block, u16 trap_id)
 }
 EXPORT_SYMBOL(mlxsw_afa_block_append_trap);
 
+int mlxsw_afa_block_append_trap_and_forward(struct mlxsw_afa_block *block,
+					    u16 trap_id)
+{
+	char *act = mlxsw_afa_block_append_action(block,
+						  MLXSW_AFA_TRAPDISC_CODE,
+						  MLXSW_AFA_TRAPDISC_SIZE);
+
+	if (!act)
+		return -ENOBUFS;
+	mlxsw_afa_trapdisc_pack(act, MLXSW_AFA_TRAPDISC_TRAP_ACTION_TRAP,
+				MLXSW_AFA_TRAPDISC_FORWARD_ACTION_FORWARD,
+				trap_id);
+	return 0;
+}
+EXPORT_SYMBOL(mlxsw_afa_block_append_trap_and_forward);
+
 /* Forwarding Action
  * -----------------
  * Forwarding Action can be used to implement Policy Based Switching (PBS)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
index 06b0be4..a8d3314 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_actions.h
@@ -61,6 +61,8 @@ int mlxsw_afa_block_continue(struct mlxsw_afa_block *block);
 int mlxsw_afa_block_jump(struct mlxsw_afa_block *block, u16 group_id);
 int mlxsw_afa_block_append_drop(struct mlxsw_afa_block *block);
 int mlxsw_afa_block_append_trap(struct mlxsw_afa_block *block, u16 trap_id);
+int mlxsw_afa_block_append_trap_and_forward(struct mlxsw_afa_block *block,
+					    u16 trap_id);
 int mlxsw_afa_block_append_fwd(struct mlxsw_afa_block *block,
 			       u8 local_port, bool in_port);
 int mlxsw_afa_block_append_vlan_modify(struct mlxsw_afa_block *block,
-- 
2.9.5
