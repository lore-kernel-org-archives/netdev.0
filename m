From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/4] ethtool: move skge.c to marvell.c
Date: Tue, 26 Sep 2006 13:08:25 -0700
Message-ID: <20060926130825.7a65979d@freekitty>
References: <20060926115437.11ed1f85@freekitty>
	<451AF4B1.2000208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:48817 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031178AbWI0Wtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 18:49:52 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451AF4B1.2000208@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The code will be common for skge and sky2

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 Makefile.am |    2 -
 marvell.c   |  189 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 skge.c      |  189 -----------------------------------------------------------
 3 files changed, 190 insertions(+), 190 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index c78eecf..97ad512 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -7,7 +7,7 @@ sbin_PROGRAMS = ethtool
 ethtool_SOURCES = ethtool.c ethtool-copy.h ethtool-util.h	\
 		  amd8111e.c de2104x.c e100.c e1000.c		\
 		  fec_8xx.c ibm_emac.c ixgb.c natsemi.c		\
-		  pcnet32.c realtek.c tg3.c skge.c
+		  pcnet32.c realtek.c tg3.c marvell.c
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/marvell.c b/marvell.c
new file mode 100644
index 0000000..23282f5
--- /dev/null
+++ b/marvell.c
@@ -0,0 +1,189 @@
+/*
+ * Copyright (C) 2004
+ *  Stephen Hemminger <shemminger@osdl.org>
+ */
+
+#include <stdio.h>
+
+#include "ethtool-util.h"
+
+static void dump_addr(int n, const u8 *a)
+{
+	int i;
+
+	printf("Addr %d            ", n);
+	for (i = 0; i < 6; i++)
+		printf("%02X%c", a[i], i == 5 ? '\n' : ' ');
+}
+
+static void dump_timer(const char *name, const void *p)
+{
+	const u8 *a = p;
+	const u32 *r = p;
+
+	printf("%s\n", name);
+	printf("\tInit 0x%08X Value 0x%08X\n", r[0], r[1]);
+	printf("\tTest 0x%02X       Control 0x%02X\n", a[8], a[9]);
+}
+
+static void dump_queue(const char *name, const void *a, int rx)
+{
+	struct desc {
+		u_int32_t		ctl;
+		u_int32_t		next;
+		u_int32_t		data_lo;
+		u_int32_t		data_hi;
+		u_int32_t		status;
+		u_int32_t		timestamp;
+		u_int16_t		csum2;
+		u_int16_t		csum1;
+		u_int16_t		csum2_start;
+		u_int16_t		csum1_start;
+		u_int32_t		addr_lo;
+		u_int32_t		addr_hi;
+		u_int32_t		count_lo;
+		u_int32_t		count_hi;
+		u_int32_t               byte_count;
+		u_int32_t               csr;
+		u_int32_t               flag;
+	};
+	const struct desc *d = a;
+
+	printf("\n%s\n", name);
+	printf("---------------\n");
+	printf("Descriptor Address       0x%08X%08X\n",
+	       d->addr_hi, d->addr_lo);
+	printf("Address Counter          0x%08X%08X\n",
+	       d->count_hi, d->count_lo);
+	printf("Current Byte Counter             %d\n", d->byte_count);
+	printf("BMU Control/Status               0x%08X\n", d->csr);
+	printf("Flag & FIFO Address              0x%08X\n", d->flag);
+	printf("\n");
+	printf("Control                          0x%08X\n", d->ctl);
+	printf("Next                             0x%08X\n", d->next);
+	printf("Data                     0x%08X%08X\n",
+	       d->data_hi, d->data_lo);
+	printf("Status                           0x%08X\n", d->status);
+	printf("Timestamp                        0x%08X\n", d->timestamp);
+	if (rx) {
+		printf("Csum1      Offset %4d Positon   %d\n",
+		       d->csum1, d->csum1_start);
+		printf("Csum2      Offset %4d Positon   %d\n",
+		       d->csum2, d->csum2_start);
+	} else
+		printf("Csum Start 0x%04X Pos %4d Write %d\n",
+		       d->csum1, d->csum2_start, d->csum1_start);
+
+}
+
+static void dump_ram(const char *name, const void *p)
+{
+	const u32 *r = p;
+
+	printf("\n%s\n", name);
+	printf("---------------\n");
+	printf("Start Address                    0x%08X\n", r[0]);
+	printf("End Address                      0x%08X\n", r[1]);
+	printf("Write Pointer                    0x%08X\n", r[2]);
+	printf("Read Pointer                     0x%08X\n", r[3]);
+	printf("Upper Threshold/Pause Packets    0x%08X\n", r[4]);
+	printf("Lower Threshold/Pause Packets    0x%08X\n", r[5]);
+	printf("Upper Threshold/High Priority    0x%08X\n", r[6]);
+	printf("Lower Threshold/High Priority    0x%08X\n", r[7]);
+	printf("Packet Counter                   0x%08X\n", r[8]);
+	printf("Level                            0x%08X\n", r[9]);
+	printf("Test                             0x%08X\n", r[10]);
+}
+
+static void dump_fifo(const char *name, const void *p)
+{
+	const u32 *r = p;
+
+	printf("\n%s\n", name);
+	printf("---------------\n");
+	printf("End Address                      0x%08X\n", r[0]);
+  	printf("Write Pointer                    0x%08X\n", r[1]);
+  	printf("Read Pointer                     0x%08X\n", r[2]);
+  	printf("Packet Counter                   0x%08X\n", r[3]);
+  	printf("Level                            0x%08X\n", r[4]);
+  	printf("Control                          0x%08X\n", r[5]);
+  	printf("Control/Test                     0x%08X\n", r[6]);
+	dump_timer("LED", p + 0x20);
+}
+
+int skge_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	const u32 *r = (const u32 *) regs->data;
+	int dual = !(regs->data[0x11a] & 1);
+
+	printf("Control Registers\n");
+	printf("-----------------\n");
+
+	printf("Register Access Port             0x%08X\n", r[0]);
+	printf("LED Control/Status               0x%08X\n", r[1]);
+	printf("Interrupt Source                 0x%08X\n", r[2]);
+	printf("Interrupt Mask                   0x%08X\n", r[3]);
+	printf("Interrupt Hardware Error Source  0x%08X\n", r[4]);
+	printf("Interrupt Hardware Error Mask    0x%08X\n", r[5]);
+	printf("Special Interrupt Source         0x%08X\n", r[6]);
+
+	printf("\nBus Management Unit\n");
+	printf("-------------------\n");
+	printf("CSR Receive Queue 1              0x%08X\n", r[24]);
+	printf("CSR Sync Queue 1                 0x%08X\n", r[26]);
+	printf("CSR Async Queue 1                0x%08X\n", r[27]);
+	if (dual) {
+		printf("CSR Receive Queue 2              0x%08X\n", r[25]);
+		printf("CSR Async Queue 2                0x%08X\n", r[29]);
+		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
+	}
+
+	printf("\nMAC Address\n");
+	printf("-------------\n");
+	dump_addr(1, regs->data + 0x100);
+	dump_addr(2, regs->data + 0x108);
+	dump_addr(3, regs->data + 0x110);
+	printf("\n");
+
+	printf("Connector type                         0x%02X\n",
+	       regs->data[0x118]);
+	printf("PMD type                               0x%02X\n",
+	       regs->data[0x119]);
+	printf("Configuration                          0x%02X\n",
+	       regs->data[0x11a]);
+	printf("Chip Revision                          0x%02X\n",
+	       regs->data[0x11b]);
+
+	dump_timer("Timer", regs->data + 0x130);
+	dump_timer("IRQ Moderation", regs->data +0x140);
+	dump_timer("Blink Source", regs->data +0x170);
+
+	dump_queue("Receive Queue 1", regs->data +0x400, 1);
+	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
+	dump_queue("Async Transmit Queue 1", regs->data +0x680, 0);
+	if (dual) {
+		dump_queue("Receive Queue 2", regs->data +0x480, 1);
+		dump_queue("Async Transmit Queue 2", regs->data +0x780, 0);
+		dump_queue("Sync Transmit Queue 2", regs->data +0x700, 0);
+	}
+
+	dump_ram("Receive RAMbuffer 1", regs->data+0x800);
+	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
+	dump_ram("Async Transmit RAMbuffer 1", regs->data+0xa80);
+	if (dual) {
+		dump_ram("Receive RAMbuffer 2", regs->data+0x880);
+		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
+		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
+	}
+
+	dump_fifo("Receive MAC FIFO 1", regs->data+0xc00);
+	dump_fifo("Transmit MAC FIFO 1", regs->data+0xd00);
+	if (dual) {
+		dump_fifo("Receive MAC FIFO 2", regs->data+0xc80);
+		dump_fifo("Transmit MAC FIFO 2", regs->data+0xd80);
+	}
+
+	dump_timer("Descriptor Poll", regs->data+0xe00);
+	return 0;
+
+}
diff --git a/skge.c b/skge.c
deleted file mode 100644
index 23282f5..0000000
--- a/skge.c
+++ /dev/null
@@ -1,189 +0,0 @@
-/*
- * Copyright (C) 2004
- *  Stephen Hemminger <shemminger@osdl.org>
- */
-
-#include <stdio.h>
-
-#include "ethtool-util.h"
-
-static void dump_addr(int n, const u8 *a)
-{
-	int i;
-
-	printf("Addr %d            ", n);
-	for (i = 0; i < 6; i++)
-		printf("%02X%c", a[i], i == 5 ? '\n' : ' ');
-}
-
-static void dump_timer(const char *name, const void *p)
-{
-	const u8 *a = p;
-	const u32 *r = p;
-
-	printf("%s\n", name);
-	printf("\tInit 0x%08X Value 0x%08X\n", r[0], r[1]);
-	printf("\tTest 0x%02X       Control 0x%02X\n", a[8], a[9]);
-}
-
-static void dump_queue(const char *name, const void *a, int rx)
-{
-	struct desc {
-		u_int32_t		ctl;
-		u_int32_t		next;
-		u_int32_t		data_lo;
-		u_int32_t		data_hi;
-		u_int32_t		status;
-		u_int32_t		timestamp;
-		u_int16_t		csum2;
-		u_int16_t		csum1;
-		u_int16_t		csum2_start;
-		u_int16_t		csum1_start;
-		u_int32_t		addr_lo;
-		u_int32_t		addr_hi;
-		u_int32_t		count_lo;
-		u_int32_t		count_hi;
-		u_int32_t               byte_count;
-		u_int32_t               csr;
-		u_int32_t               flag;
-	};
-	const struct desc *d = a;
-
-	printf("\n%s\n", name);
-	printf("---------------\n");
-	printf("Descriptor Address       0x%08X%08X\n",
-	       d->addr_hi, d->addr_lo);
-	printf("Address Counter          0x%08X%08X\n",
-	       d->count_hi, d->count_lo);
-	printf("Current Byte Counter             %d\n", d->byte_count);
-	printf("BMU Control/Status               0x%08X\n", d->csr);
-	printf("Flag & FIFO Address              0x%08X\n", d->flag);
-	printf("\n");
-	printf("Control                          0x%08X\n", d->ctl);
-	printf("Next                             0x%08X\n", d->next);
-	printf("Data                     0x%08X%08X\n",
-	       d->data_hi, d->data_lo);
-	printf("Status                           0x%08X\n", d->status);
-	printf("Timestamp                        0x%08X\n", d->timestamp);
-	if (rx) {
-		printf("Csum1      Offset %4d Positon   %d\n",
-		       d->csum1, d->csum1_start);
-		printf("Csum2      Offset %4d Positon   %d\n",
-		       d->csum2, d->csum2_start);
-	} else
-		printf("Csum Start 0x%04X Pos %4d Write %d\n",
-		       d->csum1, d->csum2_start, d->csum1_start);
-
-}
-
-static void dump_ram(const char *name, const void *p)
-{
-	const u32 *r = p;
-
-	printf("\n%s\n", name);
-	printf("---------------\n");
-	printf("Start Address                    0x%08X\n", r[0]);
-	printf("End Address                      0x%08X\n", r[1]);
-	printf("Write Pointer                    0x%08X\n", r[2]);
-	printf("Read Pointer                     0x%08X\n", r[3]);
-	printf("Upper Threshold/Pause Packets    0x%08X\n", r[4]);
-	printf("Lower Threshold/Pause Packets    0x%08X\n", r[5]);
-	printf("Upper Threshold/High Priority    0x%08X\n", r[6]);
-	printf("Lower Threshold/High Priority    0x%08X\n", r[7]);
-	printf("Packet Counter                   0x%08X\n", r[8]);
-	printf("Level                            0x%08X\n", r[9]);
-	printf("Test                             0x%08X\n", r[10]);
-}
-
-static void dump_fifo(const char *name, const void *p)
-{
-	const u32 *r = p;
-
-	printf("\n%s\n", name);
-	printf("---------------\n");
-	printf("End Address                      0x%08X\n", r[0]);
-  	printf("Write Pointer                    0x%08X\n", r[1]);
-  	printf("Read Pointer                     0x%08X\n", r[2]);
-  	printf("Packet Counter                   0x%08X\n", r[3]);
-  	printf("Level                            0x%08X\n", r[4]);
-  	printf("Control                          0x%08X\n", r[5]);
-  	printf("Control/Test                     0x%08X\n", r[6]);
-	dump_timer("LED", p + 0x20);
-}
-
-int skge_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
-{
-	const u32 *r = (const u32 *) regs->data;
-	int dual = !(regs->data[0x11a] & 1);
-
-	printf("Control Registers\n");
-	printf("-----------------\n");
-
-	printf("Register Access Port             0x%08X\n", r[0]);
-	printf("LED Control/Status               0x%08X\n", r[1]);
-	printf("Interrupt Source                 0x%08X\n", r[2]);
-	printf("Interrupt Mask                   0x%08X\n", r[3]);
-	printf("Interrupt Hardware Error Source  0x%08X\n", r[4]);
-	printf("Interrupt Hardware Error Mask    0x%08X\n", r[5]);
-	printf("Special Interrupt Source         0x%08X\n", r[6]);
-
-	printf("\nBus Management Unit\n");
-	printf("-------------------\n");
-	printf("CSR Receive Queue 1              0x%08X\n", r[24]);
-	printf("CSR Sync Queue 1                 0x%08X\n", r[26]);
-	printf("CSR Async Queue 1                0x%08X\n", r[27]);
-	if (dual) {
-		printf("CSR Receive Queue 2              0x%08X\n", r[25]);
-		printf("CSR Async Queue 2                0x%08X\n", r[29]);
-		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
-	}
-
-	printf("\nMAC Address\n");
-	printf("-------------\n");
-	dump_addr(1, regs->data + 0x100);
-	dump_addr(2, regs->data + 0x108);
-	dump_addr(3, regs->data + 0x110);
-	printf("\n");
-
-	printf("Connector type                         0x%02X\n",
-	       regs->data[0x118]);
-	printf("PMD type                               0x%02X\n",
-	       regs->data[0x119]);
-	printf("Configuration                          0x%02X\n",
-	       regs->data[0x11a]);
-	printf("Chip Revision                          0x%02X\n",
-	       regs->data[0x11b]);
-
-	dump_timer("Timer", regs->data + 0x130);
-	dump_timer("IRQ Moderation", regs->data +0x140);
-	dump_timer("Blink Source", regs->data +0x170);
-
-	dump_queue("Receive Queue 1", regs->data +0x400, 1);
-	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
-	dump_queue("Async Transmit Queue 1", regs->data +0x680, 0);
-	if (dual) {
-		dump_queue("Receive Queue 2", regs->data +0x480, 1);
-		dump_queue("Async Transmit Queue 2", regs->data +0x780, 0);
-		dump_queue("Sync Transmit Queue 2", regs->data +0x700, 0);
-	}
-
-	dump_ram("Receive RAMbuffer 1", regs->data+0x800);
-	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
-	dump_ram("Async Transmit RAMbuffer 1", regs->data+0xa80);
-	if (dual) {
-		dump_ram("Receive RAMbuffer 2", regs->data+0x880);
-		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
-		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
-	}
-
-	dump_fifo("Receive MAC FIFO 1", regs->data+0xc00);
-	dump_fifo("Transmit MAC FIFO 1", regs->data+0xd00);
-	if (dual) {
-		dump_fifo("Receive MAC FIFO 2", regs->data+0xc80);
-		dump_fifo("Transmit MAC FIFO 2", regs->data+0xd80);
-	}
-
-	dump_timer("Descriptor Poll", regs->data+0xe00);
-	return 0;
-
-}
-- 
1.4.1

