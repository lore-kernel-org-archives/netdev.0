From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [PATCH ethtool-3] add ixgb dump register support
Date: Fri, 11 Mar 2005 16:48:31 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0503111634500.24631-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I didn't to a push to gkernel bitkeeper because I've never done that
before, Jeff if you want that, I can try it.

This is off a bitkeeper clone from yesterday.

Apologies if I screwed up something with bitkeeper, as I'm just figuring
it all out but want to learn!

Thank you for your support,
  Jesse

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/11 09:26:41-08:00 jbrandeb@isotope.jf.intel.com 
#   Addition of ixgb dump register (-d command) support for the Intel PRO/10Gb Server Adapter family.
#   
#   Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
#   
diff -Nru a/Makefile.am b/Makefile.am
--- a/Makefile.am	2005-03-11 09:27:23 -08:00
+++ b/Makefile.am	2005-03-11 09:27:23 -08:00
@@ -6,7 +6,7 @@
 sbin_PROGRAMS = ethtool
 ethtool_SOURCES = de2104x.c ethtool.c ethtool-copy.h ethtool-util.h natsemi.c \
                   e1000.c realtek.c e100.c tg3.c amd8111e.c pcnet32.c \
-		  fec_8xx.c
+                  fec_8xx.c ixgb.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff -Nru a/ethtool-util.h b/ethtool-util.h
--- a/ethtool-util.h	2005-03-11 09:27:23 -08:00
+++ b/ethtool-util.h	2005-03-11 09:27:23 -08:00
@@ -39,4 +39,7 @@
 /* Motorola 8xx FEC Ethernet controller */
 int fec_8xx_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+/* Intel PRO/10GbE Server Adapters */
+int ixgb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 #endif
diff -Nru a/ethtool.c b/ethtool.c
--- a/ethtool.c	2005-03-11 09:27:23 -08:00
+++ b/ethtool.c	2005-03-11 09:27:23 -08:00
@@ -11,6 +11,7 @@
  * e1000 support by Scott Feldman <scott.feldman@intel.com>
  * e100 support by Wen Tao <wen-hwa.tao@intel.com>
  * amd8111e support by Reeja John <reeja.john@amd.com>
+ * ixgb support by Jesse Brandeburg <jesse.brandeburg@intel.com>
  *
  * TODO:
  *   * no-args => summary of each device (mii-tool style)
@@ -1012,6 +1013,7 @@
 	{ "amd8111e", amd8111e_dump_regs },
 	{ "pcnet32", pcnet32_dump_regs },
 	{ "fec_8xx", fec_8xx_dump_regs },
+	{ "ixgb", ixgb_dump_regs },
 };
 
 static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
diff -Nru a/ixgb.c b/ixgb.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/ixgb.c	2005-03-11 09:27:23 -08:00
@@ -0,0 +1,70 @@
+/* Copyright (c) 2004 Intel Corporation */
+/* support added by Jesse Brandeburg <jesse.brandeburg@intel.com> */
+#include <stdio.h>
+#include "ethtool-util.h"
+
+#define PCI_VENDOR_INTEL            0x8086
+#define PCI_DEVICE_82597EX          0x1048
+#define PCI_DEVICE_82597EX_SR       0x1A48
+#define PCI_DEVICE_82597EX_LR       0x1B48
+
+char *reg_name[] = {
+"CTRL0", "CTRL1", "STAT", "EECD", "MFS", "ICR",
+"ICS", "IMS", "IMC", "RCTL", "FRCTL", "FRCTH",
+"RDBAL", "RDBAH", "RDLEN", "RDH", "RDT", "RDTR",
+"RXDCTL", "RAIDC", "RXCSUM", "RAL_0", "RAH_0",
+"RAL_1", "RAH_1", "RAL_2", "RAH_2", "RAL_3", "RAH_3", 
+"RAL_4", "RAH_4", "RAL_5", "RAH_5", "RAL_6", "RAH_6", 
+"RAL_7", "RAH_7", "RAL_8", "RAH_8", "RAL_9", "RAH_9", 
+"RAL_A", "RAH_A", "RAL_B", "RAH_B", "RAL_C", "RAH_C", 
+"RAL_D", "RAH_D", "RAL_E", "RAH_E", "RAL_F", "RAH_F", 
+"TCTL", "TDBAL", "TDBAH", "TDLEN", "TDH", "TDT",
+"TIDV", "TXDCTL", "TSPMT", "PAP", "PCSC", "PCSC2",
+"PCSS", "PCSS2", "XPCSS", "UCCR", "XPCSTC", "MACA", "APAE",
+"ARD", "AIS", "MSCA", "MSRWD", "TPRL", "TPRH",
+"GPRCL", "GPRCH", "BPRCL", "BPRCH", "MPRCL", "MPRCH",
+"UPRCL", "UPRCH", "VPRCL", "VPRCH", "JPRCL", "JPRCH",
+"GORCL", "GORCH", "TORL", "TORH", "RNBC", "RUC", "ROC",
+"RLEC", "CRCERRS", "ICBC", "ECBC", "MPC", "TPTL", "TPTH",
+"GPTCL", "GPTCH", "BPTCL", "BPTCH", "MPTCL", "MPTCH",
+"UPTCL", "UPTCH", "VPTCL", "VPTCH", "JPTCL", "JPTCH",
+"GOTCL", "GOTCH", "TOTL", "TOTH", "DC", "PLT64C", "TSCTC",
+"TSCTFC", "IBIC", "RFC", "LFC", "PFRC", "PFTC", "MCFRC",
+"MCFTC", "XONRXC", "XONTXC", "XOFFRXC", "XOFFTXC", "RJC"
+};
+
+int
+ixgb_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u32 *data = (u32 *)regs->data;
+	u16 hw_device_id;
+	u32 i;
+	u32 num_of_regs = regs->len/sizeof(u32);
+
+	/* two different driver setups */
+	if(!(regs->version & 0xF0000000)) {
+		hw_device_id = (u16)regs->version;
+		switch (hw_device_id) {
+			case PCI_DEVICE_82597EX:
+			case PCI_DEVICE_82597EX_SR:
+			case PCI_DEVICE_82597EX_LR:
+				break;
+			default: 
+				fprintf(stdout, "Unknown device ID %04x\n",
+					hw_device_id);	
+				break;
+		}
+	} else {
+		/* avoid the device check for older drivers */
+	}
+
+	fprintf(stdout, "82597EX Registers %d\n", num_of_regs);
+	fprintf(stdout, "-----------------\n\n");
+
+	for (i = 0; i < num_of_regs; i++) {
+		fprintf(stdout, "%-15s  %08x\n", 
+			reg_name[i], data[i]);
+	}
+	return 0;
+}
+
