From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) (v2)] stmmac: ptp: fix the reference clock
Date: Wed, 27 Aug 2014 10:37:49 +0200
Message-ID: <1409128669-14276-1-git-send-email-peppe.cavallaro@st.com>
References: <1409033072-10508-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:34486 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752644AbaH0Ih5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 04:37:57 -0400
Received: from pps.filterd (m0046670.ppops.net [127.0.0.1])
	by mx07-00178001.pphosted.com (8.14.5/8.14.5) with SMTP id s7R8ZYDD032742
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 10:37:55 +0200
Received: from beta.dmz-eu.st.com (beta.dmz-eu.st.com [164.129.1.35])
	by mx07-00178001.pphosted.com with ESMTP id 1p0w2mkw52-1
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 10:37:55 +0200
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5261238
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:37:42 +0000 (GMT)
Received: from Webmail-eu.st.com (Safex1hubcas21.st.com [10.75.90.44])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 41FE12CE86
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 08:37:53 +0000 (GMT)
In-Reply-To: <1409033072-10508-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PTP reference clock, used for setting the addend in the Timestamp Addend
Register, was erroneously hard-coded (as reported in the databook just as
example).

The patch removes the macro named: STMMAC_SYSCLOCK and allows to use a
reference clock (clk_ptp_ref_i) that can be passed from the platform.

If not passed, the main driver clock will be used as default; note that
this can be fine on some platforms.

Note that, prior this patch, using the old STMMAC_SYSCLOCK on some platforms,
as side effect, the ptp clock can move faster/slower than the system clock.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
v2: fixed the release function in case of the new clock is not provided by the
    platform.

 Documentation/devicetree/bindings/net/stmmac.txt  |    4 ++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |    2 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   20 ++++++++++++++++----
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h  |    2 --
 4 files changed, 22 insertions(+), 6 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 9b03c57..e45ac3f 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -39,6 +39,10 @@ Optional properties:
   further clocks may be specified in derived bindings.
 - clock-names: One name for each entry in the clocks property, the
   first one should be "stmmaceth".
+- clk_ptp_ref: this is the PTP reference clock; in case of the PTP is
+  available this clock is used for programming the Timestamp Addend Register.
+  If not passed then the system clock will be used and this is fine on some
+  platforms.
 
 Examples:
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index ca01035..128a0b7 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -105,6 +105,8 @@ struct stmmac_priv {
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_clock_ops;
 	unsigned int default_addend;
+	struct clk *clk_ptp_ref;
+	unsigned int clk_ptp_rate;
 	u32 adv_ts;
 	int use_riwt;
 	int irq_wake;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 51a89d4..0365289 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -603,16 +603,16 @@ static int stmmac_hwtstamp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		/* calculate default added value:
 		 * formula is :
 		 * addend = (2^32)/freq_div_ratio;
-		 * where, freq_div_ratio = STMMAC_SYSCLOCK/50MHz
-		 * hence, addend = ((2^32) * 50MHz)/STMMAC_SYSCLOCK;
-		 * NOTE: STMMAC_SYSCLOCK should be >= 50MHz to
+		 * where, freq_div_ratio = clk_ptp_ref_i/50MHz
+		 * hence, addend = ((2^32) * 50MHz)/clk_ptp_ref_i;
+		 * NOTE: clk_ptp_ref_i should be >= 50MHz to
 		 *       achive 20ns accuracy.
 		 *
 		 * 2^x * y == (y << x), hence
 		 * 2^32 * 50000000 ==> (50000000 << 32)
 		 */
 		temp = (u64) (50000000ULL << 32);
-		priv->default_addend = div_u64(temp, STMMAC_SYSCLOCK);
+		priv->default_addend = div_u64(temp, priv->clk_ptp_rate);
 		priv->hw->ptp->config_addend(priv->ioaddr,
 					     priv->default_addend);
 
@@ -638,6 +638,16 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 	if (!(priv->dma_cap.time_stamp || priv->dma_cap.atime_stamp))
 		return -EOPNOTSUPP;
 
+	/* Fall-back to main clock in case of no PTP ref is passed */
+	priv->clk_ptp_ref = devm_clk_get(priv->device, "clk_ptp_ref");
+	if (IS_ERR(priv->clk_ptp_ref)) {
+		priv->clk_ptp_rate = clk_get_rate(priv->stmmac_clk);
+		priv->clk_ptp_ref = NULL;
+	} else {
+		clk_prepare_enable(priv->clk_ptp_ref);
+		priv->clk_ptp_rate = clk_get_rate(priv->clk_ptp_ref);
+	}
+
 	priv->adv_ts = 0;
 	if (priv->dma_cap.atime_stamp && priv->extend_desc)
 		priv->adv_ts = 1;
@@ -657,6 +667,8 @@ static int stmmac_init_ptp(struct stmmac_priv *priv)
 
 static void stmmac_release_ptp(struct stmmac_priv *priv)
 {
+	if (priv->clk_ptp_ref)
+		clk_disable_unprepare(priv->clk_ptp_ref);
 	stmmac_ptp_unregister(priv);
 }
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index 3dbc047..4535df3 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -25,8 +25,6 @@
 #ifndef __STMMAC_PTP_H__
 #define __STMMAC_PTP_H__
 
-#define STMMAC_SYSCLOCK 62500000
-
 /* IEEE 1588 PTP register offsets */
 #define PTP_TCR		0x0700	/* Timestamp Control Reg */
 #define PTP_SSIR	0x0704	/* Sub-Second Increment Reg */
-- 
1.7.4.4
