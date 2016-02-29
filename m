From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH] net: relax setup_tc ndo op handle restriction
Date: Mon, 29 Feb 2016 11:26:13 -0800
Message-ID: <20160229192613.24163.31830.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35593 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbcB2T01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 14:26:27 -0500
Received: by mail-pf0-f180.google.com with SMTP id w128so52346462pfb.2
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 11:26:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I added this check in setup_tc to multiple drivers,

 if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)

Unfortunately restricting to TC_H_ROOT like this breaks the old
instantiation of mqprio to setup a hardware qdisc. This patch
relaxes the test to only check the type to make it equivalent
to the check before I broke it. With this the old instantiation
continues to work.

A good smoke test is to setup mqprio with,

# tc qdisc add dev eth4 root mqprio num_tc 8 \
  map 0 1 2 3 4 5 6 7 \
  queues 0@0 1@1 2@2 3@3 4@4 5@5 6@6 7@7

Fixes: e4c6734eaab9 ("net: rework ndo tc op to consume additional qdisc handle paramete")
Reported-by: Singh Krishneil <krishneil.k.singh@intel.com>
Reported-by: Jake Keller <jacob.e.keller@intel.com>
CC: Murali Karicheri <m-karicheri2@ti.com>
CC: Shradha Shah <sshah@solarflare.com>
CC: Or Gerlitz <ogerlitz@mellanox.com>
CC: Ariel Elior <ariel.elior@qlogic.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c        |    2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       |    2 +-
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    2 +-
 drivers/net/ethernet/sfc/tx.c                   |    2 +-
 drivers/net/ethernet/ti/netcp_core.c            |    2 +-
 8 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 3360684..ebf9224 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -1632,7 +1632,7 @@ static int xgbe_setup_tc(struct net_device *netdev, u32 handle, __be16 proto,
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 	u8 tc;
 
-	if (handle != TC_H_ROOT || tc_to_netdev->type != TC_SETUP_MQPRIO)
+	if (tc_to_netdev->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc = tc_to_netdev->tc;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 45843d1..a949783 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -4275,7 +4275,7 @@ int bnx2x_setup_tc(struct net_device *dev, u8 num_tc)
 int __bnx2x_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 		     struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 	return bnx2x_setup_tc(dev, tc->tc);
 }
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ff1507f..f1a0a73 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -5383,7 +5383,7 @@ static int bnxt_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	struct bnxt *bp = netdev_priv(dev);
 	u8 tc;
 
-	if (handle != TC_H_ROOT || ntc->type != TC_SETUP_MQPRIO)
+	if (ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	tc = ntc->tc;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index dc1a821..d09a8dd 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -1207,7 +1207,7 @@ err_queueing_scheme:
 static int __fm10k_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 			    struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	return fm10k_setup_tc(dev, tc->tc);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cf4b729..02139f3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8422,7 +8422,7 @@ int __ixgbe_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 		}
 	}
 
-	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	return ixgbe_setup_tc(dev, tc->tc);
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 96d95cb..a2d560a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -72,7 +72,7 @@ int mlx4_en_setup_tc(struct net_device *dev, u8 up)
 static int __mlx4_en_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 			      struct tc_to_netdev *tc)
 {
-	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	return mlx4_en_setup_tc(dev, tc->tc);
diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 2cdb571..2337789 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -571,7 +571,7 @@ int efx_setup_tc(struct net_device *net_dev, u32 handle, __be16 proto,
 	unsigned tc, num_tc;
 	int rc;
 
-	if (handle != TC_H_ROOT || ntc->type != TC_SETUP_MQPRIO)
+	if (ntc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	num_tc = ntc->tc;
diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index ed0c30f..1d0942c 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -1860,7 +1860,7 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
 	/* setup tc must be called under rtnl lock */
 	ASSERT_RTNL();
 
-	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
+	if (tc->type != TC_SETUP_MQPRIO)
 		return -EINVAL;
 
 	/* Sanity-check the number of traffic classes requested */
