From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/7] mlxsw: spectrum: mr_tcam: Add trap-and-forward multicast route
Date: Tue,  3 Oct 2017 09:58:11 +0200
Message-ID: <20171003075812.1540-7-jiri@resnulli.us>
References: <20171003075812.1540-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36765 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdJCH6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 03:58:19 -0400
Received: by mail-wr0-f193.google.com with SMTP id k10so5392354wrk.3
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 00:58:19 -0700 (PDT)
In-Reply-To: <20171003075812.1540-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

In addition to the current multicast route actions, which include trap
route action and a forward route action, add the trap-and-forward multicast
route action, and implement it in the multicast routing hardware logic.

To implement that, add a trap-and-forward ACL action as the last action in
the route flexible action set. The used trap is the ACL2 trap, which marks
the packets with offload_mr_forward_mark, to prevent the packet from being
forwarded again by the kernel.

Note: At that stage the offloading logic does not support trap-and-forward
multicast routes. This patch adds the support only in the hardware logic.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h      | 1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c | 8 ++++++++
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h
index c851b23..5d26a12 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.h
@@ -42,6 +42,7 @@
 enum mlxsw_sp_mr_route_action {
 	MLXSW_SP_MR_ROUTE_ACTION_FORWARD,
 	MLXSW_SP_MR_ROUTE_ACTION_TRAP,
+	MLXSW_SP_MR_ROUTE_ACTION_TRAP_AND_FORWARD,
 };
 
 enum mlxsw_sp_mr_route_prio {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
index cda9e9a..3ffb28d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
@@ -253,6 +253,7 @@ mlxsw_sp_mr_tcam_afa_block_create(struct mlxsw_sp *mlxsw_sp,
 		if (err)
 			goto err;
 		break;
+	case MLXSW_SP_MR_ROUTE_ACTION_TRAP_AND_FORWARD:
 	case MLXSW_SP_MR_ROUTE_ACTION_FORWARD:
 		/* If we are about to append a multicast router action, commit
 		 * the erif_list.
@@ -266,6 +267,13 @@ mlxsw_sp_mr_tcam_afa_block_create(struct mlxsw_sp *mlxsw_sp,
 						      erif_list->kvdl_index);
 		if (err)
 			goto err;
+
+		if (route_action == MLXSW_SP_MR_ROUTE_ACTION_TRAP_AND_FORWARD) {
+			err = mlxsw_afa_block_append_trap_and_forward(afa_block,
+								      MLXSW_TRAP_ID_ACL2);
+			if (err)
+				goto err;
+		}
 		break;
 	default:
 		err = -EINVAL;
-- 
2.9.5
