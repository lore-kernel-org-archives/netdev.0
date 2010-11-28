From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: [PATCH 2/5] firewire: ohci: restart ISO channels on resume
Date: Sun, 28 Nov 2010 03:15:33 +0200
Message-ID: <1290906936-14472-3-git-send-email-maximlevitsky@gmail.com>
References: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>, netdev@vger.kernel.org,
	Maxim Levitsky <maximlevitsky@gmail.com>
To: linux1394-devel <linux1394-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55574 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753403Ab0K1BPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Nov 2010 20:15:49 -0500
Received: by mail-bw0-f46.google.com with SMTP id 15so2883308bwz.19
        for <netdev@vger.kernel.org>; Sat, 27 Nov 2010 17:15:48 -0800 (PST)
In-Reply-To: <1290906936-14472-1-git-send-email-maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ISO streams are supposed to be not interrupted
on bus resets, and suspend resume can be though
as one big bus reset.

Of course users must as soon as they notice the
bus reset, revalidate the ISO channel with IRM.

Signed-off-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 drivers/firewire/ohci.c |   49 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/drivers/firewire/ohci.c b/drivers/firewire/ohci.c
index cadd6af..9704b34 100644
--- a/drivers/firewire/ohci.c
+++ b/drivers/firewire/ohci.c
@@ -40,6 +40,7 @@
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/time.h>
+#include <linux/bitops.h>
 
 #include <asm/byteorder.h>
 #include <asm/page.h>
@@ -167,6 +168,9 @@ struct iso_context {
 	int excess_bytes;
 	void *header;
 	size_t header_length;
+
+	u8 sync;
+	u8 tags;
 };
 
 #define CONFIG_ROM_SIZE 1024
@@ -199,8 +203,11 @@ struct fw_ohci {
 
 	u32 it_context_mask;     /* unoccupied IT contexts */
 	struct iso_context *it_context_list;
+	u32 it_active_mask;
+
 	u64 ir_context_channels; /* unoccupied channels */
 	u32 ir_context_mask;     /* unoccupied IR contexts */
+	u32 ir_active_mask;	/*running IR contexts */
 	struct iso_context *ir_context_list;
 	u64 mc_channels; /* channels in use by the multichannel IR context */
 	bool mc_allocated;
@@ -2596,6 +2603,7 @@ static int ohci_start_iso(struct fw_iso_context *base,
 
 		reg_write(ohci, OHCI1394_IsoXmitIntEventClear, 1 << index);
 		reg_write(ohci, OHCI1394_IsoXmitIntMaskSet, 1 << index);
+		ohci->it_active_mask |= (1 << index);
 		context_run(&ctx->context, match);
 		break;
 
@@ -2613,7 +2621,12 @@ static int ohci_start_iso(struct fw_iso_context *base,
 		reg_write(ohci, OHCI1394_IsoRecvIntEventClear, 1 << index);
 		reg_write(ohci, OHCI1394_IsoRecvIntMaskSet, 1 << index);
 		reg_write(ohci, CONTEXT_MATCH(ctx->context.regs), match);
+		ohci->ir_active_mask |= (1 << index);
 		context_run(&ctx->context, control);
+
+		ctx->sync = sync;
+		ctx->tags = tags;
+
 		break;
 	}
 
@@ -2630,12 +2643,14 @@ static int ohci_stop_iso(struct fw_iso_context *base)
 	case FW_ISO_CONTEXT_TRANSMIT:
 		index = ctx - ohci->it_context_list;
 		reg_write(ohci, OHCI1394_IsoXmitIntMaskClear, 1 << index);
+		ohci->it_active_mask &= ~(1 << index);
 		break;
 
 	case FW_ISO_CONTEXT_RECEIVE:
 	case FW_ISO_CONTEXT_RECEIVE_MULTICHANNEL:
 		index = ctx - ohci->ir_context_list;
 		reg_write(ohci, OHCI1394_IsoRecvIntMaskClear, 1 << index);
+		ohci->ir_active_mask &= ~(1 << index);
 		break;
 	}
 	flush_writes(ohci);
@@ -2711,6 +2726,33 @@ static int ohci_set_iso_channels(struct fw_iso_context *base, u64 *channels)
 	return ret;
 }
 
+static int ohci_resume_iso(struct fw_ohci *ohci)
+{
+	int i, err;
+	struct iso_context *ctx;
+
+	for_each_set_bit(i, (unsigned long *)&ohci->ir_active_mask,
+					sizeof(ohci->ir_active_mask)) {
+		ctx = &ohci->ir_context_list[i];
+		err = ohci_start_iso(&ctx->base, 0, ctx->sync, ctx->tags);
+
+		if (err)
+			return err;
+	}
+
+	for_each_set_bit(i, (unsigned long *)&ohci->it_active_mask,
+					sizeof(ohci->it_active_mask)) {
+		ctx = &ohci->it_context_list[i];
+		err = ohci_start_iso(&ctx->base, 0, 0, 0);
+
+		if (err)
+			return err;
+	}
+
+
+	return 0;
+}
+
 static int queue_iso_transmit(struct iso_context *ctx,
 			      struct fw_iso_packet *packet,
 			      struct fw_iso_buffer *buffer,
@@ -3244,7 +3286,12 @@ static int pci_resume(struct pci_dev *dev)
 	reg_write(ohci, OHCI1394_GUIDLo, ohci->card.guid & 0xFFFFFFFF);
 	reg_write(ohci, OHCI1394_GUIDHi, (ohci->card.guid >> 32) & 0xFFFFFFFF);
 
-	return ohci_enable(&ohci->card, NULL, 0);
+	err = ohci_enable(&ohci->card, NULL, 0);
+
+	if (err)
+		return err;
+
+	return ohci_resume_iso(ohci);
 }
 #endif
 
-- 
1.7.1

