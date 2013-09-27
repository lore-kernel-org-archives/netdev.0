From: Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>
Subject: [PATCH v3] powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file
Date: Fri, 27 Sep 2013 17:40:27 +0400
Message-ID: <1380289227-12029-1-git-send-email-aida.mynzhasova@skitlab.ru>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, galak-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org
To: linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>
---
 Documentation/devicetree/bindings/net/fsl-tsec-phy.txt | 18 +++++++++++++++++-
 drivers/net/ethernet/freescale/gianfar_ptp.c           |  4 +++-
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
index 2c6be03..d2ea460 100644
--- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
+++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
@@ -86,6 +86,7 @@ General Properties:
 
 Clock Properties:
 
+  - fsl,cksel        Timer reference clock source.
   - fsl,tclk-period  Timer reference clock period in nanoseconds.
   - fsl,tmr-prsc     Prescaler, divides the output clock.
   - fsl,tmr-add      Frequency compensation value.
@@ -97,7 +98,7 @@ Clock Properties:
   clock. You must choose these carefully for the clock to work right.
   Here is how to figure good values:
 
-  TimerOsc     = system clock               MHz
+  TimerOsc     = selected reference clock   MHz
   tclk_period  = desired clock period       nanoseconds
   NominalFreq  = 1000 / tclk_period         MHz
   FreqDivRatio = TimerOsc / NominalFreq     (must be greater that 1.0)
@@ -114,6 +115,20 @@ Clock Properties:
   Pulse Per Second (PPS) signal, since this will be offered to the PPS
   subsystem to synchronize the Linux clock.
 
+  Reference clock source is determined by the value, which is holded
+  in CKSEL bits in TMR_CTRL register. "fsl,cksel" property keeps the
+  value, which will be directly written in those bits, that is why,
+  according to reference manual, the next clock sources can be used:
+
+  <0> - external high precision timer reference clock (TSEC_TMR_CLK
+        input is used for this purpose);
+  <1> - eTSEC system clock;
+  <2> - eTSEC1 transmit clock;
+  <3> - RTC clock input.
+
+  When this attribute is not used, eTSEC system clock will serve as
+  IEEE 1588 timer reference clock.
+
 Example:
 
 	ptp_clock@24E00 {
@@ -121,6 +136,7 @@ Example:
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

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
