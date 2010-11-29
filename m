From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2/5] firewire: ohci: restart ISO DMA contexts on resume from low power mode
Date: Mon, 29 Nov 2010 04:09:50 +0200
Message-ID: <1290996593-32416-3-git-send-email-maximlevitsky@gmail.com>
References: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:48670 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab0K2CK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:10:28 -0500
Received: by mail-bw0-f46.google.com with SMTP id 15so3474612bwz.19
        for <netdev@vger.kernel.org>; Sun, 28 Nov 2010 18:10:27 -0800 (PST)
In-Reply-To: <1290996593-32416-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restore ISO channels DMA so that ISO channels could continue
to work after resume from ram/disk.

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/firewire/ohci.c |   54 ++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/drivers/firewire/ohci.c b/drivers/firewire/ohci.c
index 0fbadb7..f5889d5 100644
--- a/drivers/firewire/ohci.c
+++ b/drivers/firewire/ohci.c
@@ -40,6 +40,7 @@
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/time.h>
+#include <linux/bitops.h>
 
 #include <asm/byteorder.h>
 #include <asm/page.h>
@@ -152,6 +153,7 @@ struct context {
 	descriptor_callback_t callback;
 
 	struct tasklet_struct tasklet;
+	bool active;
 };
 
 #define IT_HEADER_SY(v)          ((v) <<  0)
@@ -167,6 +169,9 @@ struct iso_context {
 	int excess_bytes;
 	void *header;
 	size_t header_length;
+
+	u8 sync;
+	u8 tags;
 };
 
 #define CONFIG_ROM_SIZE 1024
@@ -183,7 +188,8 @@ struct fw_ohci {
 	u32 bus_time;
 	bool is_root;
 	bool csr_state_setclear_abdicate;
-
+	int n_ir;
+	int n_it;
 	/*
 	 * Spinlock for accessing fw_ohci data.  Never call out of
 	 * this driver with this lock held.
@@ -1156,6 +1162,7 @@ static struct descriptor *context_get_descriptors(struct context *ctx,
 static void context_run(struct context *ctx, u32 extra)
 {
 	struct fw_ohci *ohci = ctx->ohci;
+	ctx->active = true;
 
 	reg_write(ohci, COMMAND_PTR(ctx->regs),
 		  le32_to_cpu(ctx->last->branch_address));
@@ -1187,6 +1194,7 @@ static void context_stop(struct context *ctx)
 	u32 reg;
 	int i;
 
+	ctx->active = false;
 	reg_write(ctx->ohci, CONTROL_CLEAR(ctx->regs), CONTEXT_RUN);
 	flush_writes(ctx->ohci);
 
@@ -2614,6 +2622,10 @@ static int ohci_start_iso(struct fw_iso_context *base,
 		reg_write(ohci, OHCI1394_IsoRecvIntMaskSet, 1 << index);
 		reg_write(ohci, CONTEXT_MATCH(ctx->context.regs), match);
 		context_run(&ctx->context, control);
+
+		ctx->sync = sync;
+		ctx->tags = tags;
+
 		break;
 	}
 
@@ -2711,6 +2723,26 @@ static int ohci_set_iso_channels(struct fw_iso_context *base, u64 *channels)
 	return ret;
 }
 
+#ifdef CONFIG_PM
+static void ohci_resume_iso_dma(struct fw_ohci *ohci)
+{
+	int i;
+	struct iso_context *ctx;
+
+	for (i = 0 ; i < ohci->n_ir ; i++) {
+		ctx = &ohci->ir_context_list[i];
+		if (ctx->context.active)
+			ohci_start_iso(&ctx->base, 0, ctx->sync, ctx->tags);
+	}
+
+	for (i = 0 ; i < ohci->n_it ; i++) {
+		ctx = &ohci->it_context_list[i];
+		if (ctx->context.active)
+			ohci_start_iso(&ctx->base, 0, ctx->sync, ctx->tags);
+	}
+}
+#endif
+
 static int queue_iso_transmit(struct iso_context *ctx,
 			      struct fw_iso_packet *packet,
 			      struct fw_iso_buffer *buffer,
@@ -3020,7 +3052,7 @@ static int __devinit pci_probe(struct pci_dev *dev,
 	struct fw_ohci *ohci;
 	u32 bus_options, max_receive, link_speed, version;
 	u64 guid;
-	int i, err, n_ir, n_it;
+	int i, err;
 	size_t size;
 
 	ohci = kzalloc(sizeof(*ohci), GFP_KERNEL);
@@ -3092,15 +3124,15 @@ static int __devinit pci_probe(struct pci_dev *dev,
 	ohci->ir_context_channels = ~0ULL;
 	ohci->ir_context_mask = reg_read(ohci, OHCI1394_IsoRecvIntMaskSet);
 	reg_write(ohci, OHCI1394_IsoRecvIntMaskClear, ~0);
-	n_ir = hweight32(ohci->ir_context_mask);
-	size = sizeof(struct iso_context) * n_ir;
+	ohci->n_ir = hweight32(ohci->ir_context_mask);
+	size = sizeof(struct iso_context) * ohci->n_ir;
 	ohci->ir_context_list = kzalloc(size, GFP_KERNEL);
 
 	reg_write(ohci, OHCI1394_IsoXmitIntMaskSet, ~0);
 	ohci->it_context_mask = reg_read(ohci, OHCI1394_IsoXmitIntMaskSet);
 	reg_write(ohci, OHCI1394_IsoXmitIntMaskClear, ~0);
-	n_it = hweight32(ohci->it_context_mask);
-	size = sizeof(struct iso_context) * n_it;
+	ohci->n_it = hweight32(ohci->it_context_mask);
+	size = sizeof(struct iso_context) * ohci->n_it;
 	ohci->it_context_list = kzalloc(size, GFP_KERNEL);
 
 	if (ohci->it_context_list == NULL || ohci->ir_context_list == NULL) {
@@ -3132,7 +3164,7 @@ static int __devinit pci_probe(struct pci_dev *dev,
 	fw_notify("Added fw-ohci device %s, OHCI v%x.%x, "
 		  "%d IR + %d IT contexts, quirks 0x%x\n",
 		  dev_name(&dev->dev), version >> 16, version & 0xff,
-		  n_ir, n_it, ohci->quirks);
+		  ohci->n_ir, ohci->n_it, ohci->quirks);
 
 	return 0;
 
@@ -3247,7 +3279,13 @@ static int pci_resume(struct pci_dev *dev)
 		reg_write(ohci, OHCI1394_GUIDHi, (u32)(ohci->card.guid >> 32));
 	}
 
-	return ohci_enable(&ohci->card, NULL, 0);
+	err = ohci_enable(&ohci->card, NULL, 0);
+
+	if (err)
+		return err;
+
+	ohci_resume_iso_dma(ohci);
+	return 0;
 }
 #endif
 
-- 
1.7.1

