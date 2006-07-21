From: Brice Goglin <brice@myri.com>
Subject: [patch 2/2] myri10ge - Write the firmware in 256-bytes chunks
Date: Fri, 21 Jul 2006 15:49:45 -0400
Message-ID: <44C12FD9.3050001@myri.com>
References: <44C12D14.7050509@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:60104 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751129AbWGUTtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 15:49:49 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44C12D14.7050509@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When writing the firmware to the NIC, the FIFO is 256-bytes long,
so we use 256-bytes chunks and a read to wait until the previous
write is done.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-18 15:17:55.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-18 15:19:44.000000000 -0400
@@ -448,6 +448,7 @@
 	struct mcp_gen_header *hdr;
 	size_t hdr_offset;
 	int status;
+	unsigned i;
 
 	if ((status = request_firmware(&fw, mgp->fw_name, dev)) < 0) {
 		dev_err(dev, "Unable to load %s firmware image via hotplug\n",
@@ -479,18 +480,13 @@
 		goto abort_with_fw;
 
 	crc = crc32(~0, fw->data, fw->size);
-	if (mgp->tx.boundary == 2048) {
-		/* Avoid PCI burst on chipset with unaligned completions. */
-		int i;
-		__iomem u32 *ptr = (__iomem u32 *) (mgp->sram +
-						    MYRI10GE_FW_OFFSET);
-		for (i = 0; i < fw->size / 4; i++) {
-			__raw_writel(((u32 *) fw->data)[i], ptr + i);
-			wmb();
-		}
-	} else {
-		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET, fw->data,
-				  fw->size);
+	for (i = 0; i < fw->size; i += 256) {
+		myri10ge_pio_copy(mgp->sram + MYRI10GE_FW_OFFSET + i,
+				  fw->data + i,
+				  min(256U, (unsigned)(fw->size - i)));
+		mb();
+		readb(mgp->sram);
+		mb();
 	}
 	/* corruption checking is good for parity recovery and buggy chipset */
 	memcpy_fromio(fw->data, mgp->sram + MYRI10GE_FW_OFFSET, fw->size);


