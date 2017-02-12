From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net V2] net/mlx5e: Disable preemption when doing TC statistics upcall
Date: Sun, 12 Feb 2017 11:21:31 +0200
Message-ID: <1486891291-14453-1-git-send-email-ogerlitz@mellanox.com>
Cc: Saeed Mahameed <saeedm@mellanox.com>, Amir Vadai <amir@vadai.me>,
        Roi Dayan <roid@mellanox.com>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39106 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750905AbdBLJVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 04:21:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When called by HW offloading drivers, the TC action (e.g
net/sched/act_mirred.c) code uses this_cpu logic, e.g

 _bstats_cpu_update(this_cpu_ptr(a->cpu_bstats), bytes, packets)

per the kernel documention, preemption should be disabled, add that.

Before the fix, when running with CONFIG_PREEMPT set, we get a

BUG: using smp_processor_id() in preemptible [00000000] code: tc/3793

asserion from the TC action (mirred) stats_update callback.

Fixes: aad7e08d39bd ('net/mlx5e: Hardware offloaded flower filter statistics support')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
RFC --> V2
  - dropped the RFC mark
  - refined the change log according to some info from Jakub Kicinski (thanks!)

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 237bd5b..9dddc65 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1093,10 +1093,14 @@ int mlx5e_stats_flower(struct mlx5e_priv *priv,
 
 	mlx5_fc_query_cached(counter, &bytes, &packets, &lastuse);
 
+	preempt_disable();
+
 	tcf_exts_to_list(f->exts, &actions);
 	list_for_each_entry(a, &actions, list)
 		tcf_action_stats_update(a, bytes, packets, lastuse);
 
+	preempt_enable();
+
 	return 0;
 }
 
-- 
2.3.7
