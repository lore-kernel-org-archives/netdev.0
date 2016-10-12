From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 2/2] stmmac: fix error check when init ptp
Date: Wed, 12 Oct 2016 15:42:04 +0200
Message-ID: <1476279724-11817-2-git-send-email-peppe.cavallaro@st.com>
References: <1476279724-11817-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:21786 "EHLO
        mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754882AbcJLNsP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 09:48:15 -0400
In-Reply-To: <1476279724-11817-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a problem when propagated the
failure of ptp_clock_register to open function.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Cc: Alexandre TORGUE <alexandre.torgue@st.com>
Cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |  4 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c  | 10 ++++++----
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e838850..6c85b61 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1709,8 +1709,8 @@ static int stmmac_hw_setup(struct net_device *dev, bool init_ptp)
 
 	if (init_ptp) {
 		ret = stmmac_init_ptp(priv);
-		if (ret && ret != -EOPNOTSUPP)
-			pr_warn("%s: failed PTP initialisation\n", __func__);
+		if (ret)
+			netdev_warn(priv->dev, "PTP support cannot init.\n");
 	}
 
 #ifdef CONFIG_DEBUG_FS
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
index 6e3b829..289d527 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.c
@@ -186,10 +186,12 @@ int stmmac_ptp_register(struct stmmac_priv *priv)
 					     priv->device);
 	if (IS_ERR(priv->ptp_clock)) {
 		priv->ptp_clock = NULL;
-		pr_err("ptp_clock_register() failed on %s\n", priv->dev->name);
-	} else if (priv->ptp_clock)
-		pr_debug("Added PTP HW clock successfully on %s\n",
-			 priv->dev->name);
+		return PTR_ERR(priv->ptp_clock);
+	}
+
+	spin_lock_init(&priv->ptp_lock);
+
+	netdev_dbg(priv->dev, "Added PTP HW clock successfully\n");
 
 	return 0;
 }
-- 
2.7.4
