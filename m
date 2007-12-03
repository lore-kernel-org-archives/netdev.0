From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 1/2] qe: add function qe_clock_source()
Date: Mon,  3 Dec 2007 15:17:58 -0600
Message-ID: <1196716680381-git-send-email-timur@freescale.com>
References: <11967166791607-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:37027 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbXLCVzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2007 16:55:09 -0500
In-Reply-To: <11967166791607-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add function qe_clock_source() which takes a string containing the name of a
QE clock source (as is typically found in device trees) and returns the
matching enum qe_clock value.

Update booting-without-of.txt to indicate that the UCC properties rx-clock
and tx-clock are deprecated and replaced with rx-clock-name and tx-clock-name,
which use strings instead of numbers to indicate QE clock sources.

Signed-off-by: Timur Tabi <timur@freescale.com>
---

This patch applies to Kumar's for-2.6.25 branch.  You may need to apply
my other pending patch, "qe: add ability to upload QE firmware", first.

 Documentation/powerpc/booting-without-of.txt |   13 ++++++++++
 arch/powerpc/sysdev/qe_lib/qe.c              |   32 ++++++++++++++++++++++++++
 include/asm-powerpc/qe.h                     |    1 +
 3 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/Documentation/powerpc/booting-without-of.txt b/Documentation/powerpc/booting-without-of.txt
index e9a3cb1..c4342d3 100644
--- a/Documentation/powerpc/booting-without-of.txt
+++ b/Documentation/powerpc/booting-without-of.txt
@@ -1626,6 +1626,19 @@ platforms are moved over to use the flattened-device-tree model.
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
index 865277b..5df8530 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -204,6 +204,38 @@ int qe_setbrg(enum qe_clock brg, unsigned int rate, unsigned int multiplier)
 }
 EXPORT_SYMBOL(qe_setbrg);
 
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
+}
+EXPORT_SYMBOL(qe_clock_source);
+
 /* Initialize SNUMs (thread serial numbers) according to
  * QE Module Control chapter, SNUM table
  */
diff --git a/include/asm-powerpc/qe.h b/include/asm-powerpc/qe.h
index 35c7b8d..430dc77 100644
--- a/include/asm-powerpc/qe.h
+++ b/include/asm-powerpc/qe.h
@@ -84,6 +84,7 @@ extern int par_io_data_set(u8 port, u8 pin, u8 val);
 
 /* QE internal API */
 int qe_issue_cmd(u32 cmd, u32 device, u8 mcn_protocol, u32 cmd_input);
+enum qe_clock qe_clock_source(const char *source);
 int qe_setbrg(enum qe_clock brg, unsigned int rate, unsigned int multiplier);
 int qe_get_snum(void);
 void qe_put_snum(u8 snum);
-- 
1.5.2.4

