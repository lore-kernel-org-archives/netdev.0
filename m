From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH] ethtool: Add vmxnet3 register dump support
Date: Wed, 23 Sep 2015 15:19:12 -0700
Message-ID: <1443046752-28892-1-git-send-email-skhare@vmware.com>
Cc: Shrikrishna Khare <skhare@vmware.com>,
	Bhavesh Davda <bhavesh@vmware.com>
To: bwh@kernel.org, netdev@vger.kernel.org, pv-drivers@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:47777 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754112AbbIWWTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 18:19:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for dumping vmxnet3 registers in a readable format.

Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
Acked-by: Srividya Murali <smurali@vmware.com>
---
 Makefile.am |   2 +-
 ethtool.c   |   2 +
 internal.h  |   3 +
 vmxnet3.c   | 198 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 204 insertions(+), 1 deletion(-)
 create mode 100644 vmxnet3.c

diff --git a/Makefile.am b/Makefile.am
index 4698d16..6814bc9 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -13,7 +13,7 @@ ethtool_SOURCES += \
 		  fec_8xx.c ibm_emac.c ixgb.c ixgbe.c natsemi.c	\
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
-		  sfpid.c sfpdiag.c ixgbevf.c tse.c
+		  sfpid.c sfpdiag.c ixgbevf.c tse.c vmxnet3.c
 endif
 
 TESTS = test-cmdline test-features
diff --git a/ethtool.c b/ethtool.c
index 01b13a6..92c40b8 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -20,6 +20,7 @@
  *	Copyright 2009, 2010 Solarflare Communications
  * MDI-X set support by Jesse Brandeburg <jesse.brandeburg@intel.com>
  *	Copyright 2012 Intel Corporation
+ * vmxnet3 support by Shrikrishna Khare <skhare@vmware.com>
  *
  * TODO:
  *   * show settings for all devices
@@ -974,6 +975,7 @@ static const struct {
 	{ "st_gmac", st_gmac_dump_regs },
 	{ "et131x", et131x_dump_regs },
 	{ "altera_tse", altera_tse_dump_regs },
+	{ "vmxnet3", vmxnet3_dump_regs },
 #endif
 };
 
diff --git a/internal.h b/internal.h
index 262a39f..444810d 100644
--- a/internal.h
+++ b/internal.h
@@ -248,6 +248,9 @@ int et131x_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 int altera_tse_dump_regs(struct ethtool_drvinfo *info,
 			 struct ethtool_regs *regs);
 
+/* VMware vmxnet3 ethernet controller */
+int vmxnet3_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 /* Rx flow classification */
 int rxclass_parse_ruleopts(struct cmd_context *ctx,
 			   struct ethtool_rx_flow_spec *fsp);
diff --git a/vmxnet3.c b/vmxnet3.c
new file mode 100644
index 0000000..621d02f
--- /dev/null
+++ b/vmxnet3.c
@@ -0,0 +1,198 @@
+/* Copyright (c) 2015 VMware Inc.*/
+#include <stdio.h>
+#include "internal.h"
+
+int
+vmxnet3_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u32 *regs_buff = (u32 *)regs->data;
+	u32 version = regs->version;
+	int i = 0, j = 0, cnt;
+
+	if (version != 2)
+		return -1;
+
+	fprintf(stdout, "Control Registers\n");
+	fprintf(stdout, "=================\n");
+
+	fprintf(stdout,
+		"    VRRS (Vmxnet3 Revision Report and Selection)    0x%x\n",
+		regs_buff[j++]);
+	fprintf(stdout,
+		"    UVRS (UPT Version Report and Selection)         0x%x\n",
+		regs_buff[j++]);
+	fprintf(stdout,
+		"    DSA  (Driver Shared Address)                    0x%08x%08x\n",
+		regs_buff[j+1], regs_buff[j]);
+	j += 2;
+	fprintf(stdout,
+		"    CMD  (Command Register)                         0x%x\n",
+		regs_buff[j++]);
+	fprintf(stdout,
+		"    MAC  (Media Access Control address)             %02x:%02x:%02x:%02x:%02x:%02x\n",
+		regs_buff[j] & 0xff,
+		(regs_buff[j] >> 8)  & 0xff,
+		(regs_buff[j] >> 16) & 0xff,
+		(regs_buff[j] >> 24) & 0xff,
+		regs_buff[j + 1] & 0xff,
+		(regs_buff[j + 1] >> 8)  & 0xff);
+	j += 2;
+	fprintf(stdout,
+		"    ICR  (Interrupt Cause Register)                 0x%x\n",
+		regs_buff[j++]);
+	fprintf(stdout,
+		"    ECR  (Event Cause Register)                     0x%x\n",
+		regs_buff[j++]);
+
+	fprintf(stdout, "Datapath Registers\n");
+	fprintf(stdout, "==================\n");
+
+	/* Interrupt Mask Registers */
+	cnt = regs_buff[j++];
+	for (i = 0; i < cnt; i++) {
+		fprintf(stdout,
+			"    IMR (Interrupt Mask Register) %d                 0x%x\n",
+			i, regs_buff[j++]);
+	}
+
+	/* Transmit Queue Registers */
+	cnt = regs_buff[j++];
+	for (i = 0; i < cnt; i++) {
+		fprintf(stdout, "    Transmit Queue %d\n", i);
+		fprintf(stdout, "    ----------------\n");
+		fprintf(stdout,
+			"        TXPROD (Transmit Ring Producer Register)    0x%x\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"        Transmit Ring\n");
+		fprintf(stdout,
+			"            Base Address                            0x%08x%08x\n",
+			regs_buff[j+1], regs_buff[j]);
+		j += 2;
+		fprintf(stdout,
+			"            Size                                    %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2fill                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2comp                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            gen                                     %u\n",
+			regs_buff[j++]);
+
+		fprintf(stdout,
+			"        Transmit Data Ring\n");
+		fprintf(stdout,
+			"            Base Address                            0x%08x%08x\n",
+			regs_buff[j+1], regs_buff[j]);
+		j += 2;
+		fprintf(stdout,
+			"            Size                                    %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            Buffer Size                             %u\n",
+			regs_buff[j++]);
+
+		fprintf(stdout,
+			"        Transmit Completion Ring\n");
+		fprintf(stdout,
+			"            Base Address                            0x%08x%08x\n",
+			regs_buff[j+1], regs_buff[j]);
+		j += 2;
+		fprintf(stdout,
+			"            size                                    %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2proc                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            gen                                     %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"        stopped                                     %u\n",
+			regs_buff[j++]);
+	}
+
+	/* Receive Queue Registers */
+	cnt = regs_buff[j++];
+	for (i = 0; i < cnt; i++) {
+		fprintf(stdout, "    Receive Queue %d\n", i);
+		fprintf(stdout, "    ----------------\n");
+		fprintf(stdout,
+			"        RXPROD1 (Receive Ring Producer Register) 1  0x%x\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"        RXPROD2 (Receive Ring Producer Register) 2  0x%x\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"        Receive Ring 0\n");
+		fprintf(stdout,
+			"            Base Address                            0x%08x%08x\n",
+			regs_buff[j+1], regs_buff[j]);
+		j += 2;
+		fprintf(stdout,
+			"            Size                                    %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2fill                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2comp                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            gen                                     %u\n",
+			regs_buff[j++]);
+
+		fprintf(stdout,
+			"        Receive Ring 1\n");
+		fprintf(stdout,
+			"            Base Address                            0x%08x%08x\n",
+			regs_buff[j+1], regs_buff[j]);
+		j += 2;
+		fprintf(stdout,
+			"            Size                                    %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2fill                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2comp                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            gen                                     %u\n",
+			regs_buff[j++]);
+
+		fprintf(stdout,
+			"        Receive Data Ring\n");
+		fprintf(stdout,
+			"            Base Address                            0x%08x%08x\n",
+			regs_buff[j+1], regs_buff[j]);
+		j += 2;
+		fprintf(stdout,
+			"            Size                                    %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            Buffer Size                             %u\n",
+			regs_buff[j++]);
+
+		fprintf(stdout,
+			"        Receive Completion Ring\n");
+		fprintf(stdout,
+			"            Base Address                            0x%08x%08x\n",
+			regs_buff[j+1], regs_buff[j]);
+		j += 2;
+		fprintf(stdout,
+			"            size                                    %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            next2proc                               %u\n",
+			regs_buff[j++]);
+		fprintf(stdout,
+			"            gen                                     %u\n",
+			regs_buff[j++]);
+	}
+
+	return 0;
+}
-- 
1.8.5.6
