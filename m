From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/4] ethtool: sky2 support
Date: Tue, 26 Sep 2006 13:09:14 -0700
Message-ID: <20060926130914.7fff348b@freekitty>
References: <20060926115437.11ed1f85@freekitty>
	<451AF4B1.2000208@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:61873 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031178AbWI0WuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 18:50:23 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451AF4B1.2000208@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add full support for sky2 chip

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
---
 ethtool-util.h |    3 +
 ethtool.c      |    1 
 marvell.c      |  204 +++++++++++++++++++++++++++++++++++++++++++++++++-------
 3 files changed, 183 insertions(+), 25 deletions(-)

diff --git a/ethtool-util.h b/ethtool-util.h
index 0e6fce2..0909a5a 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -51,4 +51,7 @@ int tg3_dump_regs(struct ethtool_drvinfo
 /* SysKonnect Gigabit (Genesis and Yukon) */
 int skge_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
 
+/* SysKonnect Gigabit (Yukon2) */
+int sky2_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs);
+
 #endif
diff --git a/ethtool.c b/ethtool.c
index 2363b3b..b783248 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -957,6 +957,7 @@ static struct {
 	{ "ibm_emac", ibm_emac_dump_regs },
 	{ "tg3", tg3_dump_regs },
 	{ "skge", skge_dump_regs },
+	{ "sky2", sky2_dump_regs },
 };
 
 static int dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
diff --git a/marvell.c b/marvell.c
index 23282f5..08fdbd9 100644
--- a/marvell.c
+++ b/marvell.c
@@ -1,5 +1,7 @@
 /*
- * Copyright (C) 2004
+ * Code to dump Marvell SysKonnect registers for skge and sky2 drivers.
+ *
+ * Copyright (C) 2004, 2006
  *  Stephen Hemminger <shemminger@osdl.org>
  */
 
@@ -111,6 +113,48 @@ static void dump_fifo(const char *name, 
 	dump_timer("LED", p + 0x20);
 }
 
+static void dump_mac(const u8 *r)
+{
+	printf("\nMAC Addresses\n");
+	printf("---------------\n");
+	dump_addr(1, r + 0x100);
+	dump_addr(2, r + 0x108);
+	dump_addr(3, r + 0x110);
+	printf("\n");
+
+	printf("Connector type               0x%02X\n", r[0x118]);
+	printf("PMD type                     0x%02X\n", r[0x119]);
+	printf("Configuration                0x%02X\n", r[0x11a]);
+	printf("Chip Revision                0x%02X\n", r[0x11b]);
+}
+	
+static void dump_gma(const char *name, const u8 *r)
+{
+	int i;
+
+	printf("%12s address: ", name);
+	for (i = 0; i < 3; i++) {
+		u16 a = *(u16 *)(r + i * 4);
+		printf(" %02X %02X", a & 0xff, (a >> 8) & 0xff);
+	}
+	printf("\n");
+}
+
+static void dump_gmac(const char *name, const u8 *data)
+{
+	printf("\n%s\n", name);
+	printf("Status                       0x%04X\n", *(u16 *) data);
+	printf("Control                      0x%04X\n", *(u16 *) (data + 4));
+	printf("Transmit                     0x%04X\n", *(u16 *) (data + 8));
+	printf("Receive                      0x%04X\n", *(u16 *) (data + 0xc));
+	printf("Transmit flow control        0x%04X\n", *(u16 *) (data + 0x10));
+	printf("Transmit parameter           0x%04X\n", *(u16 *) (data + 0x14));
+	printf("Serial mode                  0x%04X\n", *(u16 *) (data + 0x18));
+
+	dump_gma("Source", data + 0x1c);
+	dump_gma("Physical", data + 0x28);
+}
+
 int skge_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	const u32 *r = (const u32 *) regs->data;
@@ -138,21 +182,8 @@ int skge_dump_regs(struct ethtool_drvinf
 		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
 	}
 
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
+	dump_mac(regs->data);
+	dump_gmac("GMAC 1", regs->data + 0x2800);
 
 	dump_timer("Timer", regs->data + 0x130);
 	dump_timer("IRQ Moderation", regs->data +0x140);
@@ -161,24 +192,24 @@ int skge_dump_regs(struct ethtool_drvinf
 	dump_queue("Receive Queue 1", regs->data +0x400, 1);
 	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
 	dump_queue("Async Transmit Queue 1", regs->data +0x680, 0);
-	if (dual) {
-		dump_queue("Receive Queue 2", regs->data +0x480, 1);
-		dump_queue("Async Transmit Queue 2", regs->data +0x780, 0);
-		dump_queue("Sync Transmit Queue 2", regs->data +0x700, 0);
-	}
 
 	dump_ram("Receive RAMbuffer 1", regs->data+0x800);
 	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
 	dump_ram("Async Transmit RAMbuffer 1", regs->data+0xa80);
+
+	dump_fifo("Receive MAC FIFO 1", regs->data+0xc00);
+	dump_fifo("Transmit MAC FIFO 1", regs->data+0xd00);
 	if (dual) {
+		dump_gmac("GMAC 1", regs->data + 0x2800);
+
+		dump_queue("Receive Queue 2", regs->data +0x480, 1);
+		dump_queue("Async Transmit Queue 2", regs->data +0x780, 0);
+		dump_queue("Sync Transmit Queue 2", regs->data +0x700, 0);
+
 		dump_ram("Receive RAMbuffer 2", regs->data+0x880);
 		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
 		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
-	}
 
-	dump_fifo("Receive MAC FIFO 1", regs->data+0xc00);
-	dump_fifo("Transmit MAC FIFO 1", regs->data+0xd00);
-	if (dual) {
 		dump_fifo("Receive MAC FIFO 2", regs->data+0xc80);
 		dump_fifo("Transmit MAC FIFO 2", regs->data+0xd80);
 	}
@@ -187,3 +218,126 @@ int skge_dump_regs(struct ethtool_drvinf
 	return 0;
 
 }
+
+static void dump_queue2(const char *name, void *a, int rx)
+{
+	struct sky2_queue {
+		u16	buf_control;
+		u16	byte_count;
+		u32	rss;
+		u32	addr_lo, addr_hi;
+		u32	status;
+		u32	timestamp;
+		u16	csum1, csum2;
+		u16	csum1_start, csum2_start;
+		u16	length;
+		u16	vlan;
+		u16	rsvd1;
+		u16	done;
+		u32	req_lo, req_hi;
+		u16	rsvd2;
+		u16	req_count;
+		u32	csr;
+	} *d = a;
+
+	printf("\n%s\n", name);
+	printf("---------------\n");
+
+	printf("Buffer control                   0x%04X\n", d->buf_control);
+
+	printf("Byte Counter                     %d\n", d->byte_count);
+	printf("Descriptor Address               0x%08X%08X\n",
+	       d->addr_hi, d->addr_lo);
+	printf("Status                           0x%08X\n", d->status);
+	printf("Timestamp                        0x%08X\n", d->timestamp);
+	printf("BMU Control/Status               0x%08X\n", d->csr);
+	printf("Done                             0x%04X\n", d->done);
+	printf("Request                          0x%08X%08X\n",
+	       d->req_hi, d->req_lo);
+	if (rx) {
+		printf("Csum1      Offset %4d Piston   %d\n",
+		       d->csum1, d->csum1_start);
+		printf("Csum2      Offset %4d Positing   %d\n",
+		       d->csum2, d->csum2_start);
+	} else
+		printf("Csum Start 0x%04X Pos %4d Write %d\n",
+		       d->csum1, d->csum2_start, d->csum1_start);
+}
+
+int sky2_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
+{
+	const u32 *r = (const u32 *) regs->data;
+	int dual;
+
+	printf("Control Registers\n");
+	printf("-----------------\n");
+
+	printf("Control/Status                   0x%08X\n", r[1]);
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
+
+	dual = (regs->data[0x11e] & 2) != 0;
+	if (dual) {
+		printf("CSR Receive Queue 2              0x%08X\n", r[25]);
+		printf("CSR Async Queue 2                0x%08X\n", r[29]);
+		printf("CSR Sync Queue 2                 0x%08X\n", r[28]);
+	}
+
+	dump_mac(regs->data);
+	dump_gmac("GMAC 1", regs->data + 0x2800);
+
+	printf("\nStatus BMU:\n-----------\n");
+	printf("Control                                0x%08X\n",
+	       *(u32 *) (regs->data + 0x0e80));
+	printf("Last Index                             0x%04X\n",
+	       *(u16 *) (regs->data + 0x0e84));
+	printf("Put Index                              0x%04X\n",
+	       *(u16 *) (regs->data + 0x0e9c));
+	printf("List Address                           0x%08X%08X\n",
+	       *(u32 *) (regs->data + 0x0e8c),
+	       *(u32 *) (regs->data + 0x0e88));
+	printf("Transmit 1 done index                  0x%04X\n",
+	       *(u16 *) (regs->data + 0x0e90));
+	if (dual)
+		printf("Transmit 2 done index                  0x%04X\n",
+		       *(u16 *) (regs->data + 0x0e94));
+	printf("Transmit index threshold               0x%04X\n",
+	       *(u16 *) (regs->data + 0x0e98));
+
+	printf("\nStatus FIFO\n");
+  	printf("\tWrite Pointer            0x%02X\n", regs->data[0xea0]);
+  	printf("\tRead Pointer             0x%02X\n", regs->data[0xea4]);
+  	printf("\tLevel                    0x%02X\n", regs->data[0xea8]);
+  	printf("\tWatermark                0x%02X\n", regs->data[0xeac]);
+  	printf("\tISR Watermark            0x%02X\n", regs->data[0xead]);
+	dump_timer("Status level", regs->data + 0xeb0);
+	dump_timer("TX status", regs->data + 0xec0);
+	dump_timer("ISR", regs->data + 0xed0);
+
+	dump_queue2("Receive Queue 1", regs->data +0x400, 1);
+	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
+	dump_queue2("Async Transmit Queue 1", regs->data +0x680, 0);
+
+
+	dump_ram("Receive RAMbuffer 1", regs->data+0x800);
+	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
+	dump_ram("Async Transmit RAMbuffer 1", regs->data+0xa80);
+
+	if (dual) {
+		dump_ram("Receive RAMbuffer 2", regs->data+0x880);
+		dump_ram("Sync Transmit RAMbuffer 2", regs->data+0xb00);
+		dump_ram("Async Transmit RAMbuffer 21", regs->data+0xb80);
+		dump_gmac("GMAC 2", regs->data + 0x3800);
+	}
+
+	return 0;
+}
-- 
1.4.1

