From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH resend] ethtool: add register dump support for fjes driver
Date: Wed, 16 Nov 2016 09:55:32 +0900
Message-ID: <1479257733-19277-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:29799 "EHLO
        mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbcKPBHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 20:07:44 -0500
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
        by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id ED2DAAC0152
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 10:07:34 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the register dump format for FUJITSU Extended
Network device like the following:

   # ethtool -d es0

0x0000: OWNER_EPID    (Owner EPID)                       0x00000001
0x0004: MAX_EP        (Maximum EP)                       0x00000008
0x0010: DCTL          (Device Control)                   0x00000000
0x0020: CR            (Command request)                  0x80000002
0x0024: CS            (Command status)                   0x80000002
0x0028: SHSTSAL       (Share status address Low)         0xE8215304
0x002C: SHSTSAH       (Share status address High)        0x00000007
0x0034: REQBL         (Request Buffer length)            0x00008028
0x0038: REQBAL        (Request Buffer Address Low)       0xEB0A0000
0x003C: REQBAH        (Request Buffer Address High)      0x00000007
0x0044: RESPBL        (Response Buffer Length)           0x00000018
0x0048: RESPBAL       (Response Buffer Address Low)      0xE41E1220
0x004C: RESPBAH       (Response Buffer Address High)     0x00000007
0x0080: IS            (Interrupt status)                 0x00000000
0x0084: IMS           (Interrupt mask set)               0x7FE00000
0x0088: IMC           (Interrupt mask clear)             0x001F0000
0x008C: IG            (Interrupt generator)              0x00010000
0x0090: ICTL          (Interrupt control)                0x00000000

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 Makefile.am |  2 +-
 ethtool.c   |  1 +
 fjes.c      | 89 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 internal.h  |  2 ++
 4 files changed, 93 insertions(+), 1 deletion(-)
 create mode 100644 fjes.c

diff --git a/Makefile.am b/Makefile.am
index de2db2e..edbda57 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -14,7 +14,7 @@ ethtool_SOURCES += \
 		  pcnet32.c realtek.c tg3.c marvell.c vioc.c	\
 		  smsc911x.c at76c50x-usb.c sfc.c stmmac.c	\
 		  sff-common.c sff-common.h sfpid.c sfpdiag.c	\
-		  ixgbevf.c tse.c vmxnet3.c qsfp.c qsfp.h
+		  ixgbevf.c tse.c vmxnet3.c qsfp.c qsfp.h fjes.c
 endif
 
 TESTS = test-cmdline test-features
diff --git a/ethtool.c b/ethtool.c
index 49ac94e..75299c6 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1136,6 +1136,7 @@ static const struct {
 	{ "et131x", et131x_dump_regs },
 	{ "altera_tse", altera_tse_dump_regs },
 	{ "vmxnet3", vmxnet3_dump_regs },
+	{ "fjes", fjes_dump_regs },
 #endif
 };
 
diff --git a/fjes.c b/fjes.c
new file mode 100644
index 0000000..52f7c28
--- /dev/null
+++ b/fjes.c
@@ -0,0 +1,89 @@
+/* Copyright (c) 2016 FUJITSU LIMITED */
+#include <stdio.h>
+#include "internal.h"
+
+int fjes_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	u32 *regs_buff = (u32 *)regs->data;
+
+	if (regs->version != 1)
+		return -1;
+
+	/* Information registers */
+	fprintf(stdout,
+		"0x0000: OWNER_EPID    (Owner EPID)                       0x%08X\n",
+		regs_buff[0]);
+
+	fprintf(stdout,
+		"0x0004: MAX_EP        (Maximum EP)                       0x%08X\n",
+		regs_buff[1]);
+
+	/* Device Control registers */
+	fprintf(stdout,
+		"0x0010: DCTL          (Device Control)                   0x%08X\n",
+		regs_buff[4]);
+
+	/* Command Control registers */
+	fprintf(stdout,
+		"0x0020: CR            (Command request)                  0x%08X\n",
+		regs_buff[8]);
+
+	fprintf(stdout,
+		"0x0024: CS            (Command status)                   0x%08X\n",
+		regs_buff[9]);
+
+	fprintf(stdout,
+		"0x0028: SHSTSAL       (Share status address Low)         0x%08X\n",
+		regs_buff[10]);
+
+	fprintf(stdout,
+		"0x002C: SHSTSAH       (Share status address High)        0x%08X\n",
+		regs_buff[11]);
+
+	fprintf(stdout,
+		"0x0034: REQBL         (Request Buffer length)            0x%08X\n",
+		regs_buff[13]);
+
+	fprintf(stdout,
+		"0x0038: REQBAL        (Request Buffer Address Low)       0x%08X\n",
+		regs_buff[14]);
+
+	fprintf(stdout,
+		"0x003C: REQBAH        (Request Buffer Address High)      0x%08X\n",
+		regs_buff[15]);
+
+	fprintf(stdout,
+		"0x0044: RESPBL        (Response Buffer Length)           0x%08X\n",
+		regs_buff[17]);
+
+	fprintf(stdout,
+		"0x0048: RESPBAL       (Response Buffer Address Low)      0x%08X\n",
+		regs_buff[18]);
+
+	fprintf(stdout,
+		"0x004C: RESPBAH       (Response Buffer Address High)     0x%08X\n",
+		regs_buff[19]);
+
+	/* Interrupt Control registers */
+	fprintf(stdout,
+		"0x0080: IS            (Interrupt status)                 0x%08X\n",
+		regs_buff[32]);
+
+	fprintf(stdout,
+		"0x0084: IMS           (Interrupt mask set)               0x%08X\n",
+		regs_buff[33]);
+
+	fprintf(stdout,
+		"0x0088: IMC           (Interrupt mask clear)             0x%08X\n",
+		regs_buff[34]);
+
+	fprintf(stdout,
+		"0x008C: IG            (Interrupt generator)              0x%08X\n",
+		regs_buff[35]);
+
+	fprintf(stdout,
+		"0x0090: ICTL          (Interrupt control)                0x%08X\n",
+		regs_buff[36]);
+
+	return 0;
+}
diff --git a/internal.h b/internal.h
index 3c08b74..4e658ea 100644
--- a/internal.h
+++ b/internal.h
@@ -348,4 +348,6 @@ void sff8472_show_all(const __u8 *id);
 /* QSFP Optics diagnostics */
 void sff8636_show_all(const __u8 *id, __u32 eeprom_len);
 
+/* FUJITSU Extended Socket network device */
+int fjes_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 #endif /* ETHTOOL_INTERNAL_H__ */
-- 
1.9.1
