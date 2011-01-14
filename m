From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v5 09/10] ARM: mxs/mx28evk: read fec mac address from ocotp
Date: Fri, 14 Jan 2011 15:25:52 +0800
Message-ID: <1294989952-20813-1-git-send-email-shawn.guo@freescale.com>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<lw@karo-electronics.de>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:39393 "EHLO
	TX2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753188Ab1ANHXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 02:23:01 -0500
In-Reply-To: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read fec mac address from ocotp and save it into fec_platform_data
mac field for fec driver to use.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
 arch/arm/mach-mxs/mach-mx28evk.c |   35 ++++++++++++++++++++++++++++++++++-
 1 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/arch/arm/mach-mxs/mach-mx28evk.c b/arch/arm/mach-mxs/mach-mx28evk.c
index 8e2c597..e8db99f 100644
--- a/arch/arm/mach-mxs/mach-mx28evk.c
+++ b/arch/arm/mach-mxs/mach-mx28evk.c
@@ -119,7 +119,7 @@ static void __init mx28evk_fec_reset(void)
 	gpio_set_value(MX28EVK_FEC_PHY_RESET, 1);
 }
 
-static struct fec_platform_data mx28_fec_pdata[] = {
+static struct fec_platform_data mx28_fec_pdata[] __initdata = {
 	{
 		/* fec0 */
 		.phy = PHY_INTERFACE_MODE_RMII,
@@ -129,12 +129,45 @@ static struct fec_platform_data mx28_fec_pdata[] = {
 	},
 };
 
+static int __init mx28evk_fec_get_mac(void)
+{
+	int i;
+	u32 val;
+	const u32 *ocotp = mxs_get_ocotp();
+
+	if (!ocotp)
+		goto error;
+
+	/*
+	 * OCOTP only stores the last 4 octets for each mac address,
+	 * so hard-code Freescale OUI (00:04:9f) here.
+	 */
+	for (i = 0; i < 2; i++) {
+		val = ocotp[i * 4];
+		mx28_fec_pdata[i].mac[0] = 0x00;
+		mx28_fec_pdata[i].mac[1] = 0x04;
+		mx28_fec_pdata[i].mac[2] = 0x9f;
+		mx28_fec_pdata[i].mac[3] = (val >> 16) & 0xff;
+		mx28_fec_pdata[i].mac[4] = (val >> 8) & 0xff;
+		mx28_fec_pdata[i].mac[5] = (val >> 0) & 0xff;
+	}
+
+	return 0;
+
+error:
+	pr_err("%s: timeout when reading fec mac from OCOTP\n", __func__);
+	return -ETIMEDOUT;
+}
+
 static void __init mx28evk_init(void)
 {
 	mxs_iomux_setup_multiple_pads(mx28evk_pads, ARRAY_SIZE(mx28evk_pads));
 
 	mx28_add_duart();
 
+	if (mx28evk_fec_get_mac())
+		pr_warn("%s: failed on fec mac setup\n", __func__);
+
 	mx28evk_fec_reset();
 	mx28_add_fec(0, &mx28_fec_pdata[0]);
 	mx28_add_fec(1, &mx28_fec_pdata[1]);
-- 
1.7.1


