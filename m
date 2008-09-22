From: akpm@linux-foundation.org
Subject: [patch 2/4] mISDN: endian annotations for struct zt
Date: Mon, 22 Sep 2008 14:51:02 -0700
Message-ID: <200809222151.m8MLp2iv031898@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51938 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753478AbYIVVvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:51:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

Found two possible bugs where the z1 value was used directly without
byteswapping.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hardware/mISDN/hfc_pci.h |    4 ++--
 drivers/isdn/hardware/mISDN/hfcpci.c  |    9 ++++-----
 2 files changed, 6 insertions(+), 7 deletions(-)

diff -puN drivers/isdn/hardware/mISDN/hfc_pci.h~misdn-endian-annotations-for-struct-zt drivers/isdn/hardware/mISDN/hfc_pci.h
--- a/drivers/isdn/hardware/mISDN/hfc_pci.h~misdn-endian-annotations-for-struct-zt
+++ a/drivers/isdn/hardware/mISDN/hfc_pci.h
@@ -183,8 +183,8 @@
 #define D_FREG_MASK  0xF
 
 struct zt {
-	unsigned short z1;  /* Z1 pointer 16 Bit */
-	unsigned short z2;  /* Z2 pointer 16 Bit */
+	__le16 z1;  /* Z1 pointer 16 Bit */
+	__le16 z2;  /* Z2 pointer 16 Bit */
 };
 
 struct dfifo {
diff -puN drivers/isdn/hardware/mISDN/hfcpci.c~misdn-endian-annotations-for-struct-zt drivers/isdn/hardware/mISDN/hfcpci.c
--- a/drivers/isdn/hardware/mISDN/hfcpci.c~misdn-endian-annotations-for-struct-zt
+++ a/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -366,8 +366,7 @@ static void hfcpci_clear_fifo_tx(struct 
 	bzt->f2 = MAX_B_FRAMES;
 	bzt->f1 = bzt->f2;	/* init F pointers to remain constant */
 	bzt->za[MAX_B_FRAMES].z1 = cpu_to_le16(B_FIFO_SIZE + B_SUB_VAL - 1);
-	bzt->za[MAX_B_FRAMES].z2 = cpu_to_le16(
-	    le16_to_cpu(bzt->za[MAX_B_FRAMES].z1 - 1));
+	bzt->za[MAX_B_FRAMES].z2 = cpu_to_le16(B_FIFO_SIZE + B_SUB_VAL - 2);
 	if (fifo_state)
 		hc->hw.fifo_en |= fifo_state;
 	Write_hfc(hc, HFCPCI_FIFO_EN, hc->hw.fifo_en);
@@ -482,7 +481,7 @@ receive_dmsg(struct hfc_pci *hc)
 			df->f2 = ((df->f2 + 1) & MAX_D_FRAMES) |
 			    (MAX_D_FRAMES + 1);	/* next buffer */
 			df->za[df->f2 & D_FREG_MASK].z2 =
-			    cpu_to_le16((zp->z2 + rcnt) & (D_FIFO_SIZE - 1));
+			    cpu_to_le16((le16_to_cpu(zp->z2) + rcnt) & (D_FIFO_SIZE - 1));
 		} else {
 			dch->rx_skb = mI_alloc_skb(rcnt - 3, GFP_ATOMIC);
 			if (!dch->rx_skb) {
@@ -526,7 +525,7 @@ receive_dmsg(struct hfc_pci *hc)
 int
 hfcpci_empty_fifo_trans(struct bchannel *bch, struct bzfifo *bz, u_char *bdata)
 {
-	unsigned short	*z1r, *z2r;
+	 __le16 *z1r, *z2r;
 	int		new_z2, fcnt, maxlen;
 	u_char		*ptr, *ptr1;
 
@@ -724,7 +723,7 @@ hfcpci_fill_fifo(struct bchannel *bch)
 	struct bzfifo	*bz;
 	u_char		*bdata;
 	u_char		new_f1, *src, *dst;
-	unsigned short	*z1t, *z2t;
+	__le16 *z1t, *z2t;
 
 	if ((bch->debug & DEBUG_HW_BCHANNEL) && !(bch->debug & DEBUG_HW_BFIFO))
 		printk(KERN_DEBUG "%s\n", __func__);
_
