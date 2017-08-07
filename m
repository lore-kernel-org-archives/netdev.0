From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 03/16] net: sched: make egress_dev flag part of flower offload struct
Date: Mon,  7 Aug 2017 10:15:19 +0200
Message-ID: <20170807081532.32760-4-jiri@resnulli.us>
References: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:32778 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752495AbdHGIPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:40 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so7111558wrd.0
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:39 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since this is specific to flower now, make it part of the flower offload
struct.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 2 +-
 include/linux/netdevice.h                        | 1 -
 include/net/pkt_cls.h                            | 1 +
 net/sched/cls_flower.c                           | 2 +-
 4 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index d44049e..0e6bab1 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -661,7 +661,7 @@ static int mlx5e_rep_ndo_setup_tc(struct net_device *dev,
 	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS))
 		return -EOPNOTSUPP;
 
-	if (tc->egress_dev) {
+	if (type == TC_SETUP_CLSFLOWER && tc->cls_flower->egress_dev) {
 		struct mlx5_eswitch *esw = priv->mdev->priv.eswitch;
 		struct net_device *uplink_dev = mlx5_eswitch_get_uplink_netdev(esw);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8051a3..bd49dba 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -792,7 +792,6 @@ struct tc_to_netdev {
 		struct tc_cls_bpf_offload *cls_bpf;
 		struct tc_mqprio_qopt *mqprio;
 	};
-	bool egress_dev;
 };
 
 /* These structures hold the attributes of xdp state that are being passed
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e0c54f1..8213acd 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -504,6 +504,7 @@ struct tc_cls_flower_offload {
 	struct fl_flow_key *mask;
 	struct fl_flow_key *key;
 	struct tcf_exts *exts;
+	bool egress_dev;
 };
 
 enum tc_matchall_command {
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index ddeed17..52deeed 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -259,7 +259,7 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 			return tc_skip_sw(f->flags) ? -EINVAL : 0;
 		}
 		dev = f->hw_dev;
-		tc->egress_dev = true;
+		offload.egress_dev = true;
 	} else {
 		f->hw_dev = dev;
 	}
-- 
2.9.3
