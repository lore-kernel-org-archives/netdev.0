From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] ethtool: marvell register update
Date: Mon, 17 Sep 2007 14:08:09 -0700
Message-ID: <20070917140809.2c73cfc2@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35449 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932515AbXIQVOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 17:14:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the decode of sky2 registers.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/marvell.c	2007-09-17 14:03:08.000000000 -0700
+++ b/marvell.c	2007-09-17 14:05:44.000000000 -0700
@@ -183,6 +183,7 @@ static void dump_mac(const u8 *r)
 	case 0xb4:	printf("Yukon-2 EC Ultra");	break;
 	case 0xb6:	printf("Yukon-2 EC");	break;
  	case 0xb7:	printf("Yukon-2 FE");	break;
+	case 0xb8:	printf("Yukon-2 FE Plus"); break;
 	default:	printf("(Unknown)");	break;
 	}
 
@@ -247,6 +248,12 @@ static void dump_control(u8 *r)
 	printf("Interrupt Mask                   0x%08X\n", *(u32 *) (r + 0xc));
 	printf("Interrupt Hardware Error Source  0x%08X\n", *(u32 *) (r + 0x10));
 	printf("Interrupt Hardware Error Mask    0x%08X\n", *(u32 *) (r + 0x14));
+	printf("Interrupt Control                0x%08X\n", *(u32 *) (r + 0x2c));
+	printf("Interrupt Moderation Mask        0x%08X\n", *(u32 *) (r + 0x14c));
+	printf("Hardware Moderation Mask         0x%08X\n", *(u32 *) (r + 0x150));
+	dump_timer("Moderation Timer", r + 0x140);
+
+	printf("General Purpose  I/O             0x%08X\n", *(u32 *) (r + 0x15c));
 }
 
 int skge_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
@@ -273,7 +280,6 @@ int skge_dump_regs(struct ethtool_drvinf
 	dump_gmac("GMAC 1", regs->data + 0x2800);
 
 	dump_timer("Timer", regs->data + 0x130);
-	dump_timer("IRQ Moderation", regs->data +0x140);
 	dump_timer("Blink Source", regs->data +0x170);
 
 	dump_queue("Receive Queue 1", regs->data +0x400, 1);
@@ -342,7 +348,7 @@ static void dump_queue2(const char *name
 	printf("Request                          0x%08X%08X\n",
 	       d->req_hi, d->req_lo);
 	if (rx) {
-		printf("Csum1      Offset %4d Position   %d\n",
+		printf("Csum1      Offset %4d Position  %d\n",
 		       d->csum1, d->csum1_start);
 		printf("Csum2      Offset %4d Position  %d\n",
 		       d->csum2, d->csum2_start);
@@ -351,6 +357,25 @@ static void dump_queue2(const char *name
 		       d->csum1, d->csum2_start, d->csum1_start);
 }
 
+static void dump_prefetch(const char *name, const void *r)
+{
+	const u32 *reg = r;
+
+	printf("\n%s Prefetch\n", name);
+	printf("Control               0x%08X\n", reg[0]);
+	printf("Last Index            %u\n", reg[1]);
+	printf("Start Address         0x%08x%08x\n", reg[3], reg[2]);
+	if (*name == 'S') { /* Status unit */
+		printf("TX1 report            %u\n", reg[4]);
+		printf("TX2 report            %u\n", reg[5]);
+		printf("TX threshold          %u\n", reg[6]);
+		printf("Put Index             %u\n", reg[7]);
+	} else {
+		printf("Get Index             %u\n", reg[4]);
+		printf("Put Index             %u\n", reg[5]);
+	}
+}
+
 int sky2_dump_regs(struct ethtool_drvinfo *info, struct ethtool_regs *regs)
 {
 	const u32 *r = (const u32 *) regs->data;
@@ -375,23 +400,14 @@ int sky2_dump_regs(struct ethtool_drvinf
 
 	dump_mac(regs->data);
 
-	printf("\nStatus BMU:\n-----------\n");
-	printf("Control                                0x%08X\n",
-	       *(u32 *) (regs->data + 0x0e80));
-	printf("Last Index                             0x%04X\n",
-	       *(u16 *) (regs->data + 0x0e84));
-	printf("Put Index                              0x%04X\n",
-	       *(u16 *) (regs->data + 0x0e9c));
-	printf("List Address                           0x%08X%08X\n",
-	       *(u32 *) (regs->data + 0x0e8c),
-	       *(u32 *) (regs->data + 0x0e88));
-	printf("Transmit 1 done index                  0x%04X\n",
-	       *(u16 *) (regs->data + 0x0e90));
-	if (dual)
-		printf("Transmit 2 done index                  0x%04X\n",
-		       *(u16 *) (regs->data + 0x0e94));
-	printf("Transmit index threshold               0x%04X\n",
-	       *(u16 *) (regs->data + 0x0e98));
+	dump_prefetch("Status", regs->data + 0xe80);
+	dump_prefetch("Receive 1", regs->data + 0x450);
+	dump_prefetch("Transmit 1", regs->data + 0x450 + 0x280);
+
+	if (dual) {
+		dump_prefetch("Receive 2", regs->data + 0x450 + 0x80);
+		dump_prefetch("Transmit 2", regs->data + 0x450 + 0x380);
+	}
 
 	printf("\nStatus FIFO\n");
   	printf("\tWrite Pointer            0x%02X\n", regs->data[0xea0]);
@@ -399,6 +415,7 @@ int sky2_dump_regs(struct ethtool_drvinf
   	printf("\tLevel                    0x%02X\n", regs->data[0xea8]);
   	printf("\tWatermark                0x%02X\n", regs->data[0xeac]);
   	printf("\tISR Watermark            0x%02X\n", regs->data[0xead]);
+
 	dump_timer("Status level", regs->data + 0xeb0);
 	dump_timer("TX status", regs->data + 0xec0);
 	dump_timer("ISR", regs->data + 0xed0);
@@ -415,7 +432,6 @@ int sky2_dump_regs(struct ethtool_drvinf
 	dump_queue("Sync Transmit Queue 1", regs->data +0x600, 0);
 	dump_queue2("Async Transmit Queue 1", regs->data +0x680, 0);
 
-
 	dump_ram("Receive RAMbuffer 1", regs->data+0x800);
 	dump_ram("Sync Transmit RAMbuffer 1", regs->data+0xa00);
 	dump_ram("Async Transmit RAMbuffer 1", regs->data+0xa80);


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
