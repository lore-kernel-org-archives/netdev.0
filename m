From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_core: Add missing report on VST and spoof-checking dev caps
Date: Wed,  8 May 2013 15:30:27 +0300
Message-ID: <1368016228-19783-2-git-send-email-ogerlitz@mellanox.com>
References: <1368016228-19783-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, ronye@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:55306 "EHLO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754935Ab3EHMaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 08:30:19 -0400
In-Reply-To: <1368016228-19783-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commits e6b6a23 "net/mlx4: Add VF MAC spoof checking support" and
3f7fb021 "net/mlx4: Add set VF default vlan ID and priority support"
missed reporting in the device capabilities dump when these features
are actually supported. Also two too noisy debug messages which produce
message on every QP opened by a VF, were left in the code, fix that.

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    4 +++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    9 ---------
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index b147bdd..5444a1a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -131,7 +131,9 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[2] = "RSS XOR Hash Function support",
 		[3] = "Device manage flow steering support",
 		[4] = "Automatic MAC reassignment support",
-		[5] = "Time stamping support"
+		[5] = "Time stamping support",
+		[6] = "VST (control vlan insertion/stripping) support",
+		[7] = "FSM (MAC unti-spoofing) support"
 	};
 	int i;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index e12e0d2..d4a9de6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -377,19 +377,10 @@ static int update_vport_qp_param(struct mlx4_dev *dev,
 		qpc->pri_path.feup |= 1 << 3; /* set fvl bit */
 		qpc->pri_path.sched_queue &= 0xC7;
 		qpc->pri_path.sched_queue |= (vp_oper->state.default_qos) << 3;
-		mlx4_dbg(dev, "qp %d  port %d Q 0x%x set vlan to %d vidx %d feup %x fl %x\n",
-			 be32_to_cpu(qpc->local_qpn) & 0xffffff, port,
-			 (int)(qpc->pri_path.sched_queue), vp_oper->state.default_vlan,
-			 vp_oper->vlan_idx, (int)(qpc->pri_path.feup),
-			 (int)(qpc->pri_path.fl));
 	}
 	if (vp_oper->state.spoofchk) {
 		qpc->pri_path.feup |= 1 << 5; /* set fsm bit */;
 		qpc->pri_path.grh_mylmc = (0x80 & qpc->pri_path.grh_mylmc) + vp_oper->mac_idx;
-		mlx4_dbg(dev, "spoof qp %d  port %d feup  0x%x, myLmc 0x%x mindx %d\n",
-			 be32_to_cpu(qpc->local_qpn) & 0xffffff, port,
-			 (int)qpc->pri_path.feup, (int)qpc->pri_path.grh_mylmc,
-			 vp_oper->mac_idx);
 	}
 	return 0;
 }
-- 
1.7.1
