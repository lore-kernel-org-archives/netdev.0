From: Shawn Guo <shawn.guo@freescale.com>
Subject: [PATCH v3 09/10] ARM: mx28: read fec mac address from ocotp
Date: Wed, 5 Jan 2011 22:07:36 +0800
Message-ID: <1294236457-17476-10-git-send-email-shawn.guo@freescale.com>
References: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shawn Guo <shawn.guo@freescale.com>
To: <davem@davemloft.net>, <gerg@snapgear.com>, <baruch@tkos.co.il>,
	<eric@eukrea.com>, <bryan.wu@canonical.com>,
	<r64343@freescale.com>, <B32542@freescale.com>,
	<u.kleine-koenig@pengutro
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:8492 "EHLO
	TX2EHSOBE006.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324Ab1AEOHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 09:07:02 -0500
In-Reply-To: <1294236457-17476-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read fec mac address from ocotp and save it into fec_platform_data
mac field for fec driver to use.

Signed-off-by: Shawn Guo <shawn.guo@freescale.com>
---
Changes for v2:
 - It's not necessary to remove "const" for fec_platform_data from
   platform-fec.c and devices-common.h, so add it back.
 - Hard-coding Freescale OUI (00:04:9f) instead of just the first
   two two octets.
 - Correct the return of mx28evk_fec_get_mac() and check it
   with caller

 arch/arm/mach-mxs/mach-mx28evk.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-mxs/mach-mx28evk.c b/arch/arm/mach-mxs/mach-mx28evk.c
index def6519..54fa512 100644
--- a/arch/arm/mach-mxs/mach-mx28evk.c
+++ b/arch/arm/mach-mxs/mach-mx28evk.c
@@ -129,12 +129,44 @@ static struct fec_platform_data mx28_fec_pdata[] = {
 	},
 };
 
+static int __init mx28evk_fec_get_mac(void)
+{
+	int i, ret;
+	u32 val;
+
+	/*
+	 * OCOTP only stores the last 4 octets for each mac address,
+	 * so hard-code Freescale OUI (00:04:9f) here.
+	 */
+	for (i = 0; i < 2; i++) {
+		ret = mxs_read_ocotp(0x20 + i * 0x10, 1, &val);
+		if (ret)
+			goto error;
+
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
+	return ret;
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
 #ifdef CONFIG_FEC2
-- 
1.7.1


