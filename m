From: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Subject: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file
Date: Tue, 24 Sep 2013 11:39:57 +0400
Message-ID: <1380008397-22980-1-git-send-email-aida.mynzhasova@skitlab.ru>
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skitlab.ru ([217.65.220.135]:52171 "EHLO mail.skitlab.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652Ab3IXHkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 03:40:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently IEEE 1588 timer reference clock source is determined through
hard-coded value in gianfar_ptp driver. This patch allows to select ptp
clock source by means of device tree file node.

For instance:

	fsl,cksel = <0>;

for using external (TSEC_TMR_CLK input) high precision timer
reference clock.

Other acceptable values:

	<1> : eTSEC system clock
	<2> : eTSEC1 transmit clock
	<3> : RTC clock input

When this attribute isn't used, eTSEC system clock will serve as
IEEE 1588 timer reference clock.

Signed-off-by: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
---
 Documentation/devicetree/bindings/net/fsl-tsec-phy.txt | 2 ++
 drivers/net/ethernet/freescale/gianfar_ptp.c           | 4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
index 2c6be03..2f889f1 100644
--- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
@@ -86,6 +86,7 @@ General Properties:
 
 Clock Properties:
 
+  - fsl,cksel        Timer reference clock source.
   - fsl,tclk-period  Timer reference clock period in nanoseconds.
   - fsl,tmr-prsc     Prescaler, divides the output clock.
   - fsl,tmr-add      Frequency compensation value.
@@ -121,6 +122,7 @@ Example:
 		reg = <0x24E00 0xB0>;
 		interrupts = <12 0x8 13 0x8>;
 		interrupt-parent = < &ipic >;
+		fsl,cksel       = <1>;
 		fsl,tclk-period = <10>;
 		fsl,tmr-prsc    = <100>;
 		fsl,tmr-add     = <0x999999A4>;
diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 098f133..e006a09 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -452,7 +452,9 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 	err = -ENODEV;
 
 	etsects->caps = ptp_gianfar_caps;
-	etsects->cksel = DEFAULT_CKSEL;
+
+	if (get_of_u32(node, "fsl,cksel", &etsects->cksel))
+		etsects->cksel = DEFAULT_CKSEL;
 
 	if (get_of_u32(node, "fsl,tclk-period", &etsects->tclk_period) ||
 	    get_of_u32(node, "fsl,tmr-prsc", &etsects->tmr_prsc) ||
-- 
1.8.1.2
