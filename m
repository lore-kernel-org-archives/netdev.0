From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V1 10/10] net/mlx5e: Support offload cls_flower with skbedit mark action
Date: Thu,  3 Mar 2016 11:23:26 +0200
Message-ID: <1456997006-18538-11-git-send-email-amir@vadai.me>
References: <1456997006-18538-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>, Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36257 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274AbcCCJUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 04:20:02 -0500
Received: by mail-wm0-f68.google.com with SMTP id l68so3024136wml.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 01:20:01 -0800 (PST)
In-Reply-To: <1456997006-18538-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce offloading of skbedit mark action.

For example, to mark with 0x1234, all TCP (ip_proto 6) packets arriving
to interface ens9:

 # tc qdisc add dev ens9 ingress
 # tc filter add dev ens9 protocol ip parent ffff: \
     flower ip_proto 6 \
     indev ens9 \
     action skbedit mark 0x1234

Signed-off-by: Amir Vadai <amir@vadai.me>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h | 2 ++
 3 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 519a07f..f293afe 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -35,6 +35,7 @@
 #include <linux/tcp.h>
 #include <net/busy_poll.h>
 #include "en.h"
+#include "en_tc.h"
 
 static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 {
@@ -224,6 +225,8 @@ static inline void mlx5e_build_rx_skb(struct mlx5_cqe64 *cqe,
 	if (cqe_has_vlan(cqe))
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 				       be16_to_cpu(cqe->vlan_info));
+
+	skb->mark = be32_to_cpu(cqe->sop_drop_qpn) & MLX5E_TC_FLOW_ID_MASK;
 }
 
 int mlx5e_poll_rx_cq(struct mlx5e_cq *cq, int budget)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3aea5da..544c739 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -33,6 +33,7 @@
 #include <net/flow_dissector.h>
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_gact.h>
+#include <net/tc_act/tc_skbedit.h>
 #include <linux/mlx5/fs.h>
 #include <linux/mlx5/device.h>
 #include <linux/rhashtable.h>
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
index 70642f4..d677428 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.h
@@ -33,6 +33,8 @@
 #ifndef __MLX5_EN_TC_H__
 #define __MLX5_EN_TC_H__
 
+#define MLX5E_TC_FLOW_ID_MASK 0x0000ffff
+
 int mlx5e_tc_init(struct mlx5e_priv *priv);
 void mlx5e_tc_cleanup(struct mlx5e_priv *priv);
 
-- 
2.7.0
