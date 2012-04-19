From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 4/4] stmmac: do not fail when probe and there is no csr clk defined
Date: Thu, 19 Apr 2012 07:48:22 +0200
Message-ID: <1334814502-29707-4-git-send-email-peppe.cavallaro@st.com>
References: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:52545 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752614Ab2DSFsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 01:48:45 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 94A87210
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:43 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 3DC8E18B5
	for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 05:48:43 +0000 (GMT)
In-Reply-To: <1334814502-29707-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some platforms, for example where we are doing the bring-up,
the csr clock is not passed from the framework and the Ethernet
device driver is failing when it can work w/o any issues and
using the default values. So this patch just warnings the case
of the csr clock cannot be acquired but w/o failing the probe
step. I have just tested it on ST STiH415 SoC (ARM).

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   13 +++++++------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    5 ++++-
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 9f2435c..db2de9a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -107,7 +107,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 #ifdef CONFIG_HAVE_CLK
 static inline int stmmac_clk_enable(struct stmmac_priv *priv)
 {
-	if (priv->stmmac_clk)
+	if (!IS_ERR(priv->stmmac_clk))
 		return clk_enable(priv->stmmac_clk);
 
 	return 0;
@@ -115,17 +115,18 @@ static inline int stmmac_clk_enable(struct stmmac_priv *priv)
 
 static inline void stmmac_clk_disable(struct stmmac_priv *priv)
 {
-	if (priv->stmmac_clk)
-		clk_disable(priv->stmmac_clk);
+	if (IS_ERR(priv->stmmac_clk))
+		return;
+
+	clk_disable(priv->stmmac_clk);
 }
 static inline int stmmac_clk_get(struct stmmac_priv *priv)
 {
 	priv->stmmac_clk = clk_get(priv->device, NULL);
 
-	if (IS_ERR(priv->stmmac_clk)) {
-		pr_err("%s: ERROR clk_get failed\n", __func__);
+	if (IS_ERR(priv->stmmac_clk))
 		return PTR_ERR(priv->stmmac_clk);
-	}
+
 	return 0;
 }
 #else
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index efc42e1..1a4cf81 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -168,6 +168,9 @@ static void stmmac_clk_csr_set(struct stmmac_priv *priv)
 #ifdef CONFIG_HAVE_CLK
 	u32 clk_rate;
 
+	if (IS_ERR(priv->stmmac_clk))
+		return;
+
 	clk_rate = clk_get_rate(priv->stmmac_clk);
 
 	/* Platform provided default clk_csr would be assumed valid
@@ -1923,7 +1926,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 	}
 
 	if (stmmac_clk_get(priv))
-		goto error;
+		pr_warning("%s: warning: cannot get CSR clock\n", __func__);
 
 	/* If a specific clk_csr value is passed from the platform
 	 * this means that the CSR Clock Range selection cannot be
-- 
1.7.4.4
