From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 1/2] qe: add function qe_clock_source
Date: Wed, 10 Oct 2007 17:37:07 -0500
Message-ID: <11920558291655-git-send-email-timur@freescale.com>
References: <11920558283326-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:46900 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbXJJWhW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 18:37:22 -0400
In-Reply-To: <11920558283326-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add function qe_clock_source() which takes a string containing the name of a
QE clock source (as is typically found in device trees) and returns the
matching enum qe_clock value.

Update booting-without-of.txt to indicate that the UCC properties rx-clock
and tx-clock are deprecated and replaced with rx-clock-name and tx-clock-name,
which use strings instead of numbers to indicate QE clock sources.

Update qe_setbrg() to take an enum qe_clock instead of an integer as its
first paramter.

Signed-off-by: Timur Tabi <timur@freescale.com>
---

This patch applies to Kumar's for-2.6.24 branch.

 Documentation/powerpc/booting-without-of.txt |   13 ++++
 arch/powerpc/sysdev/qe_lib/qe.c              |   41 ++++++++++-
 include/asm-powerpc/qe.h                     |   95 +++++++++++++-------------
 3 files changed, 99 insertions(+), 50 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index 7a6c5f2..d8306ee 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1615,6 +1615,19 @@ platforms are moved over to use the flattened-device-tree model.
    - interrupt-parent : the phandle for the interrupt controller that
      services interrupts for this device.
    - pio-handle : The phandle for the Parallel I/O port configuration.
+   - rx-clock-name: the UCC receive clock source
+     "none": clock source is disabled
+     "brg1" through "brg16": clock source is BRG1-BRG16, respectively
+     "clk1" through "clk24": clock source is CLK1-CLK24, respectively
+   - tx-clock-name: the UCC transmit clock source
+     "none": clock source is disabled
+     "brg1" through "brg16": clock source is BRG1-BRG16, respectively
+     "clk1" through "clk24": clock source is CLK1-CLK24, respectively
+   The following two properties are deprecated.  rx-clock has been replaced
+   with rx-clock-name, and tx-clock has been replaced with tx-clock-name.
+   Drivers that currently use the deprecated properties should continue to
+   do so, in order to support older device trees, but they should be updated
+   to check for the new properties first.
    - rx-clock : represents the UCC receive clock source.
      0x00 : clock source is disabled;
      0x1~0x10 : clock source is BRG1~BRG16 respectively;
diff --git a/arch/powerpc/sysdev/qe_lib/qe.c b/arch/powerpc/sysdev/qe_lib/qe.c
index 3d57d38..8551e74 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -167,7 +167,7 @@ unsigned int get_brg_clk(void)
 
 /* Program the BRG to the given sampling rate and multiplier
  *
- * @brg: the BRG, 1-16
+ * @brg: the BRG, QE_BRG1 - QE_BRG16
  * @rate: the desired sampling rate
  * @multiplier: corresponds to the value programmed in GUMR_L[RDCR] or
  * GUMR_L[TDCR].  E.g., if this BRG is the RX clock, and GUMR_L[RDCR]=01,
@@ -175,11 +175,14 @@ unsigned int get_brg_clk(void)
  *
  * Also note that the value programmed into the BRGC register must be even.
  */
-void qe_setbrg(unsigned int brg, unsigned int rate, unsigned int multiplier)
+void qe_setbrg(enum qe_clock brg, unsigned int rate, unsigned int multiplier)
 {
 	u32 divisor, tempval;
 	u32 div16 = 0;
 
+	if ((brg < QE_BRG1) || (brg > QE_BRG16))
+		return;
+
 	divisor = get_brg_clk() / (rate * multiplier);
 
 	if (divisor > QE_BRGC_DIVISOR_MAX + 1) {
@@ -196,8 +199,40 @@ void qe_setbrg(unsigned int brg, unsigned int rate, unsigned int multiplier)
 	tempval = ((divisor - 1) << QE_BRGC_DIVISOR_SHIFT) |
 		QE_BRGC_ENABLE | div16;
 
-	out_be32(&qe_immr->brg.brgc[brg - 1], tempval);
+	out_be32(&qe_immr->brg.brgc[brg - QE_BRG1], tempval);
+}
+
+/* Convert a string to a QE clock source enum
+ *
+ * This function takes a string, typically from a property in the device
+ * tree, and returns the corresponding "enum qe_clock" value.
+*/
+enum qe_clock qe_clock_source(const char *source)
+{
+	unsigned int i;
+
+	if (strcasecmp(source, "none") == 0)
+		return QE_CLK_NONE;
+
+	if (strncasecmp(source, "brg", 3) == 0) {
+		i = simple_strtoul(source + 3, NULL, 10);
+		if ((i >= 1) && (i <= 16))
+			return (QE_BRG1 - 1) + i;
+		else
+			return QE_CLK_DUMMY;
+	}
+
+	if (strncasecmp(source, "clk", 3) == 0) {
+		i = simple_strtoul(source + 3, NULL, 10);
+		if ((i >= 1) && (i <= 24))
+			return (QE_CLK1 - 1) + i;
+		else
+			return QE_CLK_DUMMY;
+	}
+
+	return QE_CLK_DUMMY;
 }
+EXPORT_SYMBOL(qe_clock_source);
 
 /* Initialize SNUMs (thread serial numbers) according to
  * QE Module Control chapter, SNUM table
diff --git a/include/asm-powerpc/qe.h b/include/asm-powerpc/qe.h
index 0dabe46..81403ee 100644
--- a/include/asm-powerpc/qe.h
+++ b/include/asm-powerpc/qe.h
@@ -28,6 +28,52 @@
 #define MEM_PART_SECONDARY	1
 #define MEM_PART_MURAM		2
 
+/* Clocks and BRGs */
+enum qe_clock {
+	QE_CLK_NONE = 0,
+	QE_BRG1,		/* Baud Rate Generator 1 */
+	QE_BRG2,		/* Baud Rate Generator 2 */
+	QE_BRG3,		/* Baud Rate Generator 3 */
+	QE_BRG4,		/* Baud Rate Generator 4 */
+	QE_BRG5,		/* Baud Rate Generator 5 */
+	QE_BRG6,		/* Baud Rate Generator 6 */
+	QE_BRG7,		/* Baud Rate Generator 7 */
+	QE_BRG8,		/* Baud Rate Generator 8 */
+	QE_BRG9,		/* Baud Rate Generator 9 */
+	QE_BRG10,		/* Baud Rate Generator 10 */
+	QE_BRG11,		/* Baud Rate Generator 11 */
+	QE_BRG12,		/* Baud Rate Generator 12 */
+	QE_BRG13,		/* Baud Rate Generator 13 */
+	QE_BRG14,		/* Baud Rate Generator 14 */
+	QE_BRG15,		/* Baud Rate Generator 15 */
+	QE_BRG16,		/* Baud Rate Generator 16 */
+	QE_CLK1,		/* Clock 1 */
+	QE_CLK2,		/* Clock 2 */
+	QE_CLK3,		/* Clock 3 */
+	QE_CLK4,		/* Clock 4 */
+	QE_CLK5,		/* Clock 5 */
+	QE_CLK6,		/* Clock 6 */
+	QE_CLK7,		/* Clock 7 */
+	QE_CLK8,		/* Clock 8 */
+	QE_CLK9,		/* Clock 9 */
+	QE_CLK10,		/* Clock 10 */
+	QE_CLK11,		/* Clock 11 */
+	QE_CLK12,		/* Clock 12 */
+	QE_CLK13,		/* Clock 13 */
+	QE_CLK14,		/* Clock 14 */
+	QE_CLK15,		/* Clock 15 */
+	QE_CLK16,		/* Clock 16 */
+	QE_CLK17,		/* Clock 17 */
+	QE_CLK18,		/* Clock 18 */
+	QE_CLK19,		/* Clock 19 */
+	QE_CLK20,		/* Clock 20 */
+	QE_CLK21,		/* Clock 21 */
+	QE_CLK22,		/* Clock 22 */
+	QE_CLK23,		/* Clock 23 */
+	QE_CLK24,		/* Clock 24 */
+	QE_CLK_DUMMY
+};
+
 /* Export QE common operations */
 extern void qe_reset(void);
 extern int par_io_init(struct device_node *np);
@@ -38,7 +84,8 @@ extern int par_io_data_set(u8 port, u8 pin, u8 val);
 
 /* QE internal API */
 int qe_issue_cmd(u32 cmd, u32 device, u8 mcn_protocol, u32 cmd_input);
-void qe_setbrg(unsigned int brg, unsigned int rate, unsigned int multiplier);
+enum qe_clock qe_clock_source(const char *source);
+void qe_setbrg(enum qe_clock brg, unsigned int rate, unsigned int multiplier);
 int qe_get_snum(void);
 void qe_put_snum(u8 snum);
 unsigned long qe_muram_alloc(int size, int align);
@@ -129,52 +176,6 @@ enum comm_dir {
 	COMM_DIR_RX_AND_TX = 3
 };
 
-/* Clocks and BRGs */
-enum qe_clock {
-	QE_CLK_NONE = 0,
-	QE_BRG1,		/* Baud Rate Generator 1 */
-	QE_BRG2,		/* Baud Rate Generator 2 */
-	QE_BRG3,		/* Baud Rate Generator 3 */
-	QE_BRG4,		/* Baud Rate Generator 4 */
-	QE_BRG5,		/* Baud Rate Generator 5 */
-	QE_BRG6,		/* Baud Rate Generator 6 */
-	QE_BRG7,		/* Baud Rate Generator 7 */
-	QE_BRG8,		/* Baud Rate Generator 8 */
-	QE_BRG9,		/* Baud Rate Generator 9 */
-	QE_BRG10,		/* Baud Rate Generator 10 */
-	QE_BRG11,		/* Baud Rate Generator 11 */
-	QE_BRG12,		/* Baud Rate Generator 12 */
-	QE_BRG13,		/* Baud Rate Generator 13 */
-	QE_BRG14,		/* Baud Rate Generator 14 */
-	QE_BRG15,		/* Baud Rate Generator 15 */
-	QE_BRG16,		/* Baud Rate Generator 16 */
-	QE_CLK1,		/* Clock 1 */
-	QE_CLK2,		/* Clock 2 */
-	QE_CLK3,		/* Clock 3 */
-	QE_CLK4,		/* Clock 4 */
-	QE_CLK5,		/* Clock 5 */
-	QE_CLK6,		/* Clock 6 */
-	QE_CLK7,		/* Clock 7 */
-	QE_CLK8,		/* Clock 8 */
-	QE_CLK9,		/* Clock 9 */
-	QE_CLK10,		/* Clock 10 */
-	QE_CLK11,		/* Clock 11 */
-	QE_CLK12,		/* Clock 12 */
-	QE_CLK13,		/* Clock 13 */
-	QE_CLK14,		/* Clock 14 */
-	QE_CLK15,		/* Clock 15 */
-	QE_CLK16,		/* Clock 16 */
-	QE_CLK17,		/* Clock 17 */
-	QE_CLK18,		/* Clock 18 */
-	QE_CLK19,		/* Clock 19 */
-	QE_CLK20,		/* Clock 20 */
-	QE_CLK21,		/* Clock 21 */
-	QE_CLK22,		/* Clock 22 */
-	QE_CLK23,		/* Clock 23 */
-	QE_CLK24,		/* Clock 24 */
-	QE_CLK_DUMMY,
-};
-
 /* QE CMXUCR Registers.
  * There are two UCCs represented in each of the four CMXUCR registers.
  * These values are for the UCC in the LSBs
-- 
1.5.2.4

