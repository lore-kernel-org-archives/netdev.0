From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH] ptp_clock: future-proofing drivers against PTP subsystem
 becoming optional
Date: Tue, 20 Sep 2016 19:25:58 -0400 (EDT)
Message-ID: <alpine.LFD.2.20.1609201915070.9311@knanqh.ubzr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:32777 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753586AbcITX0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:26:01 -0400
Received: by mail-qk0-f176.google.com with SMTP id w204so30531093qka.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:26:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Drivers must be ready to accept NULL from ptp_clock_register() if the
PTP clock subsystem is configured out.

This patch documents that and ensures that all drivers cope well
with a NULL return.

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Reviewed-by: Eugenia Emantayev <eugenia@mellanox.com>

---

Let's have the basics merged now and work out the actual Kconfig issue 
separately. Richard, if you agree with this patch, I think this could go 
via the netdev tree.

diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 2e1b17ad52..ad03763e00 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -334,7 +334,7 @@ void e1000e_ptp_init(struct e1000_adapter *adapter)
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		e_err("ptp_clock_register failed\n");
-	} else {
+	} else if (adapter->ptp_clock) {
 		e_info("registered PHC clock\n");
 	}
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index ed39cbad24..f1feceab75 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -669,7 +669,7 @@ void i40e_ptp_init(struct i40e_pf *pf)
 		pf->ptp_clock = NULL;
 		dev_err(&pf->pdev->dev, "%s: ptp_clock_register failed\n",
 			__func__);
-	} else {
+	} else if (pf->ptp_clock) {
 		struct timespec64 ts;
 		u32 regval;
 
diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 336c103ae3..7531892b08 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -1159,7 +1159,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 	if (IS_ERR(adapter->ptp_clock)) {
 		adapter->ptp_clock = NULL;
 		dev_err(&adapter->pdev->dev, "ptp_clock_register failed\n");
-	} else {
+	} else if (adapter->ptp_clock) {
 		dev_info(&adapter->pdev->dev, "added PHC on %s\n",
 			 adapter->netdev->name);
 		adapter->ptp_flags |= IGB_PTP_ENABLED;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index e5431bfe33..a92277683a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -1254,7 +1254,7 @@ static long ixgbe_ptp_create_clock(struct ixgbe_adapter *adapter)
 		adapter->ptp_clock = NULL;
 		e_dev_err("ptp_clock_register failed\n");
 		return err;
-	} else
+	} else if (adapter->ptp_clock)
 		e_dev_info("registered PHC device on %s\n", netdev->name);
 
 	/* set default timestamp mode to disabled here. We do this in
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_clock.c b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
index 1494997c4f..08fc5fc56d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_clock.c
@@ -298,7 +298,7 @@ void mlx4_en_init_timestamp(struct mlx4_en_dev *mdev)
 	if (IS_ERR(mdev->ptp_clock)) {
 		mdev->ptp_clock = NULL;
 		mlx4_err(mdev, "ptp_clock_register failed\n");
-	} else {
+	} else if (mdev->ptp_clock) {
 		mlx4_info(mdev, "registered PHC clock\n");
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 847a8f3ac2..13dc388667 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -273,7 +273,7 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 
 	tstamp->ptp = ptp_clock_register(&tstamp->ptp_info,
 					 &priv->mdev->pdev->dev);
-	if (IS_ERR_OR_NULL(tstamp->ptp)) {
+	if (IS_ERR(tstamp->ptp)) {
 		mlx5_core_warn(priv->mdev, "ptp_clock_register failed %ld\n",
 			       PTR_ERR(tstamp->ptp));
 		tstamp->ptp = NULL;
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index c771e0af4e..f105a170b4 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1269,13 +1269,13 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 		if (IS_ERR(ptp->phc_clock)) {
 			rc = PTR_ERR(ptp->phc_clock);
 			goto fail3;
-		}
-
-		INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
-		ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
-		if (!ptp->pps_workwq) {
-			rc = -ENOMEM;
-			goto fail4;
+		} else if (ptp->phc_clock) {
+			INIT_WORK(&ptp->pps_work, efx_ptp_pps_worker);
+			ptp->pps_workwq = create_singlethread_workqueue("sfc_pps");
+			if (!ptp->pps_workwq) {
+				rc = -ENOMEM;
+				goto fail4;
+			}
 		}
 	}
 	ptp->nic_ts_enabled = false;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 170a18b612..6e3b82972c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -187,7 +187,7 @@ int stmmac_ptp_register(struct stmmac_priv *priv)
 	if (IS_ERR(priv->ptp_clock)) {
 		priv->ptp_clock = NULL;
 		pr_err("ptp_clock_register() failed on %s\n", priv->dev->name);
-	} else
+	} else if (priv->ptp_clock)
 		pr_debug("Added PTP HW clock successfully on %s\n",
 			 priv->dev->name);
 
diff --git a/include/linux/ptp_clock_kernel.h b/include/linux/ptp_clock_kernel.h
index 6b15e16814..5ad54fc66c 100644
--- a/include/linux/ptp_clock_kernel.h
+++ b/include/linux/ptp_clock_kernel.h
@@ -127,6 +127,11 @@ struct ptp_clock;
  *
  * @info:   Structure describing the new clock.
  * @parent: Pointer to the parent device of the new clock.
+ *
+ * Returns a valid pointer on success or PTR_ERR on failure.  If PHC
+ * support is missing at the configuration level, this function
+ * returns NULL, and drivers are expected to gracefully handle that
+ * case separately.
  */
 
 extern struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info,
