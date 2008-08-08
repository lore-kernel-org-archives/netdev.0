From: "Matti Linnanvuori" <mattilinn@gmail.com>
Subject: Re: [patch 1.2.32] WAN: merge driver retina
Date: Fri, 8 Aug 2008 09:34:37 +0300
Message-ID: <ca0148c30808072334w5d2d8216s37152621b4aa8ebf@mail.gmail.com>
References: <ca0148c30807032339o4182fbadq370f709a28861053@mail.gmail.com>
	 <489A96B2.4030903@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jeff Garzik" <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:23274 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbYHHGei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 02:34:38 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1379555wfd.4
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 23:34:37 -0700 (PDT)
In-Reply-To: <489A96B2.4030903@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matti Linnanvuori <matti.linnanvuori@ascom.com>

Retina G.703 and G.SHDSL driver.

Signed-off-by: Matti Linnanvuori <matti.linnanvuori@ascom.com>

---

This version does not use virt_to_bus(), which should not be used in
modern drivers.  The DMA API is used instead.

I am sending a patch against 'retina' branch of jgarzik/netdev-2.6.git.

--- linux/drivers/net/wan/retina.c	2008-08-08 08:36:33.998260400 +0300
+++ linux-next/drivers/net/wan/retina.c	2008-08-08 09:11:57.291397100 +0300
@@ -40,12 +40,11 @@
 #define TX_FIFO_THRESHOLD_STREAM_MODE 0x7
 #define TX_DESC_THRESHOLD_STREAM_MODE 0x1

-#define RETINA_MRU 2000
-#define RETINA_DMA_SIZE (RETINA_MRU + 4)
+#define RETINA_MRU 2000u
+#define RETINA_DMA_SIZE (RETINA_MRU + 4u)

-static const char fepci_name[] = "retina";
+static char fepci_name[] = "retina";
 static const char fepci_alarm_manager_name[] = "retina alarm manager";
-static const char fepci_NAME[] = "RETINA";
 static const char fepci_netdev_name[] = "dcpxx";

 static unsigned int find_cnt;
@@ -79,7 +78,7 @@ static unsigned int find_cnt;

 #include <asm/pgtable.h>

-MODULE_VERSION("1.2.31");
+MODULE_VERSION("1.2.34");

 /* PCI I/O space extent */
 enum { FEPCI_SIZE = 0x20000 };
@@ -160,7 +159,7 @@ struct fepci_card_private {
 	wait_queue_head_t stream_both_q;
 };

-enum {
+enum retina_semaphore {
 	RETINA_IDLE = 0,
 	RETINA_IN_USE = 7,
 	RETINA_RESERVED_UCTRL = 0x80,
@@ -208,18 +207,24 @@ enum reg_transmit_control {
 };

 enum int_bits {
-	MaskFrameReceived = 0x01, MaskRxFifoError =
-	    0x02, MaskRxFrameDroppedError = 0x04,
-	MaskFrameTransmitted = 0x40, MaskTxFifoError = 0x80,
+	MaskFrameReceived = 0x01,
+	MaskRxFifoError = 0x02,
+	MaskRxFrameDroppedError = 0x04,
+	MaskFrameTransmitted = 0x40,
+	MaskTxFifoError = 0x80,
 	MaskAllInts = 0xc7,
-	IntrFrameReceived = 0x01, IntrRxFifoError =
-	    0x02, IntrRxFrameDroppedError = 0x04,
-	IntrFrameTransmitted = 0x40, IntrTxFifoError = 0x80,
+	IntrFrameReceived = 0x01,
+	IntrRxFifoError = 0x02,
+	IntrRxFrameDroppedError = 0x04,
+	IntrFrameTransmitted = 0x40,
+	IntrTxFifoError = 0x80,
 	IntrAllInts = 0xc7,
 };

-/* The FEPCI Rx and Tx buffer descriptors
- * Elements are written as 32 bit for endian portability */
+/**
+ * The reception and transmission buffer descriptors.
+ * Elements are written as 32 bit for endian portability.
+ **/

 struct fepci_desc {
 	u32 desc_a;
@@ -237,8 +242,8 @@ enum desc_b_bits {
 	transfer_not_done	= 0x80000000,
 };

-/* global variables (common to whole driver, all the cards): */
-static int major;			/* char device major number */
+/* Global variables (common to whole driver, all the cards): */
+static int major; /* character device major number */
 static struct fepci_card_private **card_privates;
 static unsigned long stream_pointers;

@@ -246,10 +251,10 @@ static void set_int_mask(unsigned char c
 			 struct fepci_card_private *cp)
 {
 	uint8_t __iomem *address = cp->ioaddr + reg_first_int_mask;
-	const unsigned shift = 8 * channel;
+	const unsigned shift = 8u * channel;
 	uint32_t oldvalue = readl(address);
-	oldvalue &= ~(0xff << shift);	/* clear bits */
-	oldvalue |= value << shift;	/* set bits */
+	oldvalue &= ~(0xff << shift);	/* Clear bits. */
+	oldvalue |= value << shift;	/* Set bits. */
 	writel(oldvalue, address);
 }

@@ -263,7 +268,7 @@ static inline unsigned get_int_status(un
 				      uint8_t __iomem *ioaddr)
 {
 	const uint32_t oldvalue = readl(ioaddr + reg_first_int_status);
-	return (oldvalue >> (8 * channel)) & 0xff; /* clear other bits */
+	return (oldvalue >> (8 * channel)) & 0xff; /* Clear other bits. */
 }

 static void fillregisterswith_00(uint8_t __iomem *ioaddr)
@@ -279,7 +284,6 @@ static void fillregisterswith_00(uint8_t
 static int fepci_open(struct net_device *dev);
 static void fepci_timer(unsigned long data);
 static void fepci_tx_timeout(struct net_device *dev);
-static void fepci_init_ring(struct net_device *dev);
 static int fepci_start_xmit(struct sk_buff *skb, struct net_device *dev);
 static irqreturn_t fepci_interrupt(int irq, void *dev_instance);
 static int fepci_close(struct net_device *dev);
@@ -380,37 +384,37 @@ static int fepci_char_mmap(struct file *
 {
 	unsigned long offset = vma->vm_pgoff << PAGE_SHIFT;
 	unsigned long size = vma->vm_end - vma->vm_start;
-	unsigned long virtual_address = 0;
-	unsigned pfn;
+	unsigned long virtual_address = 0ul;
+	unsigned long pfn;
+	struct fepci_card_private *device = filp->private_data;

 	vma->vm_flags |= VM_IO | VM_RESERVED;
 	vma->vm_file = filp;

 	if (offset == STREAM_BUFFER_POINTER_AREA) {
 		virtual_address = stream_pointers;
-		if (size > (1 << PAGE_SHIFT)) {
-			printk(KERN_WARNING
-			       "%s: mmap: area size over range.\n", fepci_name);
+		if (size > (1ul << PAGE_SHIFT)) {
+			dev_warn(&device->pci_dev->dev,
+				 "mmap: area size over range\n");
 			return -EINVAL;
 		}
 	} else {
-		unsigned int channel = (offset >> CHANNEL_ADDRESS_SHIFT) & 0xf;
-		/* 0 = rx, 1 = tx */
-		unsigned int area = (offset >> AREA_ADDRESS_SHIFT) & 0xf;
-		struct fepci_card_private *device = filp->private_data;
+		unsigned long channel = (offset >> CHANNEL_ADDRESS_SHIFT) & 0xf;
+		/* 0 = reception, 1 = transmission */
+		unsigned long area = (offset >> AREA_ADDRESS_SHIFT) & 0xf;
 		if (unlikely(device->removed))
 			goto INVALID;
-		if (area == 0) {
-			virtual_address = (unsigned long)device->
-						ch_privates[channel]->rx_buffer;
-		} else if (area == 1) {
-			virtual_address = (unsigned long)device->
-						ch_privates[channel]->tx_buffer;
+		if (area == 0ul) {
+			virtual_address = (unsigned long)
+				device->ch_privates[channel]->rx_buffer;
+		} else if (area == 1ul) {
+			virtual_address = (unsigned long)
+				device->ch_privates[channel]->tx_buffer;
 		} else {
 INVALID:
 			return -EINVAL;
 		}
-		if (unlikely(virtual_address == 0))
+		if (unlikely(virtual_address == 0ul))
 			goto INVALID;
 	}

@@ -428,27 +432,27 @@ static int fepci_copy_to_user(unsigned l
 			      unsigned len, bool shrink)
 {
 	if (shrink) {
-		unsigned int i;
-		for (i = 0; i < len; i += 2) {
-			uint32_t longword = readl_relaxed(from + i / 2 *
+		unsigned int w;
+		for (w = 0u; w < len; w += 2) {
+			uint32_t longword = readl_relaxed(from + w / 2u *
 							  sizeof(u32));
 			int error = __put_user(longword,
 					       (unsigned char __user *)
-					       (to + i));
+					       (to + w));
 			if (unlikely(error))
 				return error;
 			error = __put_user(longword >> 8,
 					   (unsigned char __user *)
-					   (to + i + 1));
+					   (to + w + 1));
 			if (unlikely(error))
 				return error;
 		}
 	} else {
-		unsigned int i;
-		for (i = 0; i < len; i += 4) {
-			uint32_t longword = readl_relaxed(from + i);
+		unsigned int w;
+		for (w = 0u; w < len; w += 4u) {
+			uint32_t longword = readl_relaxed(from + w);
 			int error = __put_user(longword,
-					       (uint32_t __user *)(to + i));
+					       (uint32_t __user *)(to + w));
 			if (unlikely(error))
 				return error;
 		}
@@ -460,47 +464,47 @@ static int fepci_copy_from_user(uint8_t
 				unsigned len, bool enlarge)
 {
 	if (enlarge) {
-		unsigned int i;
-		for (i = 0; i < len; i += 2) {
+		unsigned int w;
+		for (w = 0u; w < len; w += 2u) {
 			unsigned char temp1;
 			unsigned char temp2;
 			int error = __get_user(temp1,
 					       (unsigned char __user *)
-					       (from + i));
+					       (from + w));
 			if (unlikely(error))
 				return error;
 			error = __get_user(temp2,
 					   (unsigned char __user *)
-					   (from + i + 1));
+					   (from + w + 1u));
 			if (unlikely(error))
 				return error;
-			writel(temp1 + (temp2 << 8), to + i * 2);
+			writel(temp1 + (temp2 << 8), to + w * 2u);
 		}
 	} else {
-		unsigned int i;
-		for (i = 0; i < len; i += 4) {
+		unsigned int w;
+		for (w = 0u; w < len; w += 4u) {
 			uint32_t longword;
 			int error = __get_user(longword,
-					       (u32 __user *)(from + i));
+					       (u32 __user *)(from + w));
 			if (unlikely(error))
 				return error;
-			writel(longword, to + i);
+			writel(longword, to + w);
 		}
 	}
 	return 0;
 }

-static unsigned get_semafore(struct fepci_real_mailbox __iomem *mailbox)
+static
+enum retina_semaphore get_semafore(struct fepci_real_mailbox __iomem *mailbox)
 {
-	unsigned semafore = readb_relaxed(&mailbox->Semafore_Mail_number);
-	return semafore;
+	return readb_relaxed(&mailbox->Semafore_Mail_number);
 }

 static void set_semafore(struct fepci_real_mailbox __iomem *mailbox,
-			 unsigned semafore)
+			 enum retina_semaphore value)
 {
 	uint32_t number = readl_relaxed(&mailbox->Semafore_Mail_number);
-	number = ((number & ~0xFF) | semafore) + (1 << 8);
+	number = ((number & ~0xFF) | value) + (1u << 8);
 	writel(number, &mailbox->Semafore_Mail_number);
 }

@@ -513,12 +517,8 @@ static int fepci_char_ioctl(struct inode
 	int retval = 0;
 	struct fepci_card_private *card = filp->private_data;

-	if (unlikely(card->removed)) {
-		printk(KERN_WARNING
-		       "%s: trying to access a card that does not exist\n",
-		       fepci_NAME);
+	if (unlikely(card->removed))
 		return -ENXIO;
-	}

 	if (_IOC_DIR(cmd) & _IOC_READ)
 		if (unlikely(!access_ok(VERIFY_WRITE, (void __user *)arg,
@@ -535,13 +535,14 @@ static int fepci_char_ioctl(struct inode

 	switch (cmd) {
 	case FEPCI_IOCTL_STREAM_TRANSMIT_POLL:
-		/* here: arg == channel number */
-		if (unlikely(arg < 0 || arg >= CHANNELS
-		    || !(card->ch_privates[arg]->stream_on)))
+		/* Here: arg == channel number. */
+		if (unlikely(arg >= CHANNELS ||
+			     !(card->ch_privates[arg]->stream_on))) {
 			return 0x2;
-		{
-			u32 pointer = *USER_TX_S_FAKE_POINTER(minor, arg,
-							      stream_pointers);
+		} else {
+			unsigned long pointer =
+				*USER_TX_S_FAKE_POINTER(minor, arg,
+							stream_pointers);
 			wait_event_interruptible(card->stream_transmit_q,
 						 (pointer !=
 						  *USER_TX_S_FAKE_POINTER
@@ -551,13 +552,14 @@ static int fepci_char_ioctl(struct inode
 		}
 		return retval;
 	case FEPCI_IOCTL_STREAM_RECEIVE_POLL:
-		/* here: arg == channel number */
-		if (unlikely(arg < 0 || arg >= CHANNELS
-		    || !(card->ch_privates[arg]->stream_on)))
+		/* Here: arg == channel number. */
+		if (unlikely(arg >= CHANNELS ||
+			     !(card->ch_privates[arg]->stream_on))) {
 			return 0x2;
-		{
-			u32 pointer = *USER_RX_S_FAKE_POINTER(minor, arg,
-							      stream_pointers);
+		} else {
+			unsigned long pointer =
+				*USER_RX_S_FAKE_POINTER(minor, arg,
+							stream_pointers);
 			wait_event_interruptible(card->stream_receive_q,
 						 (pointer !=
 						  *USER_RX_S_FAKE_POINTER
@@ -567,15 +569,15 @@ static int fepci_char_ioctl(struct inode
 		}
 		return retval;
 	case FEPCI_IOCTL_STREAM_BOTH_POLL:
-		/* here: arg == channel number */
-		if (unlikely(arg < 0 || arg >= CHANNELS
-		    || !(card->ch_privates[arg]->stream_on)))
+		/* Here: arg == channel number. */
+		if (unlikely(arg >= CHANNELS ||
+			     !(card->ch_privates[arg]->stream_on))) {
 			return 0x2;
-		{
-			u32 temp_tx_pointer =
+		} else {
+			unsigned long temp_tx_pointer =
 				*USER_TX_S_FAKE_POINTER(minor, arg,
 							stream_pointers);
-			u32 temp_rx_pointer =
+			unsigned long temp_rx_pointer =
 				*USER_RX_S_FAKE_POINTER(minor, arg,
 							stream_pointers);
 			wait_event_interruptible(card->stream_both_q,
@@ -592,31 +594,31 @@ static int fepci_char_ioctl(struct inode
 	case FEPCI_IOCTL_R_SHARED_MEM:
 		retval = fepci_copy_to_user(arg,
 					    ioaddr + FEPCI_SHARED_MEM_OFFSETT,
-					    _IOC_SIZE(cmd), 0);
+					    _IOC_SIZE(cmd), false);
 		break;
 	case FEPCI_IOCTL_W_SHARED_MEM:
 		retval = fepci_copy_from_user(ioaddr + FEPCI_SHARED_MEM_OFFSETT,
-					      arg, _IOC_SIZE(cmd), 0);
+					      arg, _IOC_SIZE(cmd), false);
 		break;
 	case FEPCI_IOCTL_G_IDENTIFICATION:
 		retval = fepci_copy_to_user(arg,
 					    ioaddr +
 					    FEPCI_IDENTIFICATION_OFFSETT,
-					    _IOC_SIZE(cmd), 1);
+					    _IOC_SIZE(cmd), true);
 		break;
 	case FEPCI_IOCTL_G_FEATURES:
 		retval = fepci_copy_to_user(arg, ioaddr +
 						 FEPCI_FEATURES_OFFSETT,
-					    _IOC_SIZE(cmd), 1);
+					    _IOC_SIZE(cmd), true);
 		break;
 	case FEPCI_IOCTL_G_SETTINGS:
 		retval = fepci_copy_to_user(arg, ioaddr +
 						 FEPCI_SETTINGS_OFFSETT,
-					    _IOC_SIZE(cmd), 1);
+					    _IOC_SIZE(cmd), true);
 		break;
 	case FEPCI_IOCTL_G_STATUS:
 		retval = fepci_copy_to_user(arg, ioaddr + FEPCI_STATUS_OFFSETT,
-					    _IOC_SIZE(cmd), 1);
+					    _IOC_SIZE(cmd), true);
 		break;
 	case FEPCI_IOCTL_B_POLL:
 		mutex_lock(&card->mutex);
@@ -628,7 +630,7 @@ static int fepci_char_ioctl(struct inode
 		if (get_semafore(real_mailbox) == RETINA_IDLE) {
 			set_semafore(real_mailbox, RETINA_RESERVED_PC);
 			get_semafore(real_mailbox); /* Wait for write. */
-			msleep(1);	/* delay at least 1 millisecond */
+			msleep(1u);	/* Delay at least 1 millisecond. */
 			switch (get_semafore(real_mailbox)) {
 			case RETINA_RESERVED_PC:
 				retval = 0;
@@ -681,11 +683,14 @@ static int fepci_char_ioctl(struct inode
 		case RETINA_RESERVED_PC:
 		case RETINA_READY_PC_REPLY:
 		case RETINA_READY_PC:
-			/* copy the mailbox */
+			if (unlikely(_IOC_SIZE(cmd) <= 2u))
+				goto DEFAULT;
+			/* Copy the mailbox. */
 			retval = fepci_copy_from_user(ioaddr +
-						FEPCI_MAILBOX_OFFSETT + 4,
-						arg + 2, _IOC_SIZE(cmd) - 2, 1);
-			/* semafore -> 10 */
+						FEPCI_MAILBOX_OFFSETT + 4u,
+						arg + 2ul, _IOC_SIZE(cmd) - 2u,
+						true);
+			/* Semaphore -> 10. */
 			set_semafore(real_mailbox, RETINA_READY_UCTRL);
 			break;
 		case RETINA_READY_UCTRL:
@@ -707,12 +712,15 @@ static int fepci_char_ioctl(struct inode
 		case RETINA_RESERVED_PC:
 		case RETINA_READY_PC_REPLY:
 		case RETINA_READY_PC:
-			/* copy the mailbox; */
+			if (unlikely(_IOC_SIZE(cmd) <= 2u))
+				goto DEFAULT;
+			/* Copy the mailbox; */
 			retval = fepci_copy_from_user(ioaddr +
-						FEPCI_MAILBOX_OFFSETT + 4,
-						arg + 2, _IOC_SIZE(cmd) - 2, 1);
-			/* semafore -> 11 */
-			set_semafore(real_mailbox, 0x11);
+						FEPCI_MAILBOX_OFFSETT + 4u,
+						arg + 2ul, _IOC_SIZE(cmd) - 2u,
+						true);
+			/* Semaphore -> 11 */
+			set_semafore(real_mailbox, RETINA_READY_UCTRL_REPLY);
 			break;
 		case RETINA_READY_UCTRL:
 		case RETINA_READY_UCTRL_REPLY:
@@ -723,7 +731,7 @@ static int fepci_char_ioctl(struct inode
 			retval = 0x3;
 			break;
 		default:
-			retval = 0xff;
+DEFAULT:		retval = 0xff;
 		}
 		mutex_unlock(&card->mutex);
 		break;
@@ -741,7 +749,7 @@ static int fepci_char_ioctl(struct inode
 			retval = fepci_copy_to_user(arg,
 						ioaddr +
 						FEPCI_MAILBOX_OFFSETT,
-						_IOC_SIZE(cmd), 1);
+						_IOC_SIZE(cmd), true);
 			break;
 		case RETINA_IDLE:
 			retval = 0x3;
@@ -756,7 +764,7 @@ static int fepci_char_ioctl(struct inode
 						4, 1);
 			if (likely(retval == 0))
 				/* lowest byte = 0x7 */
-				retval = __put_user(7, (char __user *)arg);
+				retval = __put_user(0x7, (char __user *)arg);
 		}
 		mutex_unlock(&card->mutex);
 		break;
@@ -767,7 +775,7 @@ static int fepci_char_ioctl(struct inode
 		mutex_lock(&card->mutex);
 		{
 			struct fepci_ch_private *fp =
-				card->ch_privates[arg & 3];
+				card->ch_privates[arg & 3ul];
 			if (fp->in_stream_mode)
 				retval = -EBUSY;
 			else
@@ -779,7 +787,7 @@ static int fepci_char_ioctl(struct inode
 		mutex_lock(&card->mutex);
 		{
 			struct fepci_ch_private *fp =
-				card->ch_privates[arg & 3];
+				card->ch_privates[arg & 3ul];
 			if (fp->in_stream_mode)
 				retval = -EBUSY;
 			else
@@ -794,8 +802,6 @@ static int fepci_char_ioctl(struct inode
 	case FEPCI_IOCTL_STREAM_CLOSE:
 		return fepci_stream_close(card, card->ch_privates[arg]);
 	default:
-		dev_warn(&card->pci_dev->dev, "unknown ioctl command 0x%x\n",
-			 cmd);
 		return -ENOTTY;
 	}
 	return retval;
@@ -804,10 +810,10 @@ static int fepci_char_ioctl(struct inode
 static int fepci_register_char_device(void)
 {
 	int error =
-		register_chrdev(0 /* dynamic */ , fepci_name, &fepci_char_fops);
+		register_chrdev(0u /* dynamic */, fepci_name, &fepci_char_fops);
 	if (unlikely(error < 0))
 		printk(KERN_WARNING
-		       "%s: unable to register char device\n", fepci_NAME);
+		       "%s: unable to register char device\n", fepci_name);
 	return error;
 }

@@ -836,12 +842,12 @@ static int fepci_stream_open(struct fepc
 			     struct fepci_ch_private *fp)
 {
 	unsigned tx_pages, rx_pages, tx_order, rx_order;
-	unsigned int i;
+	unsigned int u;
 	mutex_lock(&cp->mutex);

 	if (unlikely(fp->in_eth_mode)) {
 		dev_warn(&fp->this_dev->dev,
-			 "Interface is in Ethernet mode, "
+			 "Interface is in Ethernet mode: "
 			 "cannot open stream interface\n");
 		mutex_unlock(&cp->mutex);
 		return -EBUSY;
@@ -856,9 +862,9 @@ static int fepci_stream_open(struct fepc
 		return -ENXIO;
 	}

-	fp->bufsize = 1 << fp->bufsize_order;
+	fp->bufsize = 1u << fp->bufsize_order;

-	if (unlikely(fp->fake_unit_sz_order < 5)) {
+	if (unlikely(fp->fake_unit_sz_order < 5u)) {
 		dev_warn(&fp->this_dev->dev,
 			 "Unit size has to be at least 32 bytes\n");
 INVALID:
@@ -877,29 +883,29 @@ INVALID:
 	else
 		fp->unit_sz_order = fp->fake_unit_sz_order;

-	fp->fake_unit_sz = 1 << fp->fake_unit_sz_order;
-	fp->unit_sz = 1 << fp->unit_sz_order;
-	fp->units = 1 << (fp->bufsize_order - fp->unit_sz_order);
-	fp->fake_units = 1 << (fp->bufsize_order - fp->fake_unit_sz_order);
+	fp->fake_unit_sz = 1u << fp->fake_unit_sz_order;
+	fp->unit_sz = 1u << fp->unit_sz_order;
+	fp->units = 1u << (fp->bufsize_order - fp->unit_sz_order);
+	fp->fake_units = 1u << (fp->bufsize_order - fp->fake_unit_sz_order);

 	/* Reserve memory. */
 	if (fp->bufsize_order < PAGE_SHIFT) {
-		rx_order = 0;
-		tx_order = 0;
-		rx_pages = 1;
-		tx_pages = 1;
+		rx_order = 0u;
+		tx_order = 0u;
+		rx_pages = 1u;
+		tx_pages = 1u;
 	} else {
 		tx_order = fp->bufsize_order - PAGE_SHIFT;
-		tx_pages = 1 << tx_order;
-		rx_order = tx_order + 1;
-		rx_pages = 1 << rx_order;
-	}
-	fp->in_stream_mode = 1;
-	fp->tx_buffer = (u32 *) __get_free_pages(GFP_KERNEL, tx_order);
-	if (unlikely(!fp->tx_buffer))
+		tx_pages = 1u << tx_order;
+		rx_order = tx_order + 1u;
+		rx_pages = 1u << rx_order;
+	}
+	fp->in_stream_mode = true;
+	fp->tx_buffer = (u32 *)__get_free_pages(GFP_KERNEL, tx_order);
+	if (unlikely(fp->tx_buffer == NULL))
 		goto NO_MEMORY;
-	fp->rx_buffer = (u32 *) __get_free_pages(GFP_KERNEL, rx_order);
-	if (unlikely(!fp->rx_buffer)) {
+	fp->rx_buffer = (u32 *)__get_free_pages(GFP_KERNEL, rx_order);
+	if (unlikely(fp->rx_buffer == NULL)) {
 NO_MEMORY:
 		dev_warn(&fp->this_dev->dev,
 			 "unable to allocate memory for buffers\n");
@@ -908,37 +914,31 @@ NO_MEMORY:
 		return -ENOMEM;
 	}

-	for (i = 0; i < (fp->bufsize) / 4; i++)
-		fp->tx_buffer[i] = 0xffffffff;
+	for (u = 0u; u < fp->bufsize / 4u; u++)
+		fp->tx_buffer[u] = 0xffffffff;

-	/* + fp->channel_number; */
-	*USER_RX_S_POINTER(cp->card_number, fp->channel_number,
-			   stream_pointers) = 0;
-	/* + fp->channel_number; */
-	*USER_TX_S_POINTER(cp->card_number, fp->channel_number,
-			   stream_pointers) = 0;
-	/* + fp->channel_number; */
+	*USER_RX_S_POINTER(cp->card_number, fp->channel_number, stream_pointers)
+		= 0ul;
+	*USER_TX_S_POINTER(cp->card_number, fp->channel_number, stream_pointers)
+		= 0ul;
 	*USER_RX_S_FAKE_POINTER(cp->card_number,
-				fp->channel_number, stream_pointers) = 0;
-	/* + fp->channel_number; */
+				fp->channel_number, stream_pointers) = 0ul;
 	*USER_TX_S_FAKE_POINTER(cp->card_number,
-				fp->channel_number, stream_pointers) = 0;
+				fp->channel_number, stream_pointers) = 0ul;

-	/* Init ring buffers. */
-	for (i = 0; i < MAX_RX_UNITS; i++)
-		fp->rx_unit[i] =
-		    (u32 *) ((u32) (fp->rx_buffer) + (fp->unit_sz * i));
-	for (i = 0; i < MAX_TX_UNITS; i++)
-		fp->tx_unit[i] =
-		    (u32 *) ((u32) (fp->tx_buffer) + (fp->unit_sz * i));
-
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		writel(0, &fp->rx_desc[i].desc_a);
-		writel(0, &fp->rx_desc[i].desc_b);
-	}
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		writel(0, &fp->tx_desc[i].desc_a);
-		writel(0, &fp->tx_desc[i].desc_b);
+	/* Init the ring buffers. */
+	for (u = 0u; u < MAX_RX_UNITS; u++)
+		fp->rx_unit[u] = fp->rx_buffer + fp->unit_sz * u / sizeof(u32);
+	for (u = 0u; u < MAX_TX_UNITS; u++)
+		fp->tx_unit[u] = fp->tx_buffer + fp->unit_sz * u / sizeof(u32);
+
+	for (u = 0u; u < RX_RING_SIZE; u++) {
+		writel(0u, &fp->rx_desc[u].desc_a);
+		writel(0u, &fp->rx_desc[u].desc_b);
+	}
+	for (u = 0u; u < TX_RING_SIZE; u++) {
+		writel(0u, &fp->tx_desc[u].desc_a);
+		writel(0u, &fp->tx_desc[u].desc_b);
 	}
 	mutex_unlock(&cp->mutex);
 	return 0;
@@ -974,13 +974,13 @@ static int fepci_stream_start(struct fep
 		}
 	}

-	fp->stream_on = 1;
+	fp->stream_on = true;

 	/* Sending and receiving on, start from the beginning of the buffer. */
-	fp->cur_tx_unit = 0;
-	fp->cur_rx_unit = 0;
-	fp->cur_tx = 0;
-	fp->cur_rx = 0;
+	fp->cur_tx_unit = 0u;
+	fp->cur_rx_unit = 0u;
+	fp->cur_tx = 0u;
+	fp->cur_rx = 0u;

 	/* All the descriptors ready to go: */
 	for (i = 0; i < min(RX_RING_SIZE, TX_RING_SIZE); i++) {
@@ -990,7 +990,7 @@ static int fepci_stream_start(struct fep
 							     i) % fp->units],
 						    fp->unit_sz,
 						    PCI_DMA_FROMDEVICE);
-		if (unlikely(pci_dma_mapping_error(address))) {
+		if (unlikely(pci_dma_mapping_error(cp->pci_dev, address))) {
 			dev_warn(&dev->dev,
 				 "failed to map reception DMA buffer\n");
 		} else {
@@ -1006,7 +1006,7 @@ static int fepci_stream_start(struct fep
 					 fp->tx_unit[(fp->cur_tx_unit + i) %
 					 fp->units], fp->unit_sz,
 					 PCI_DMA_TODEVICE);
-		if (unlikely(pci_dma_mapping_error(address))) {
+		if (unlikely(pci_dma_mapping_error(cp->pci_dev, address))) {
 			dev_warn(&dev->dev,
 				 "failed to map transmission DMA buffer\n");
 		} else {
@@ -1043,9 +1043,9 @@ static inline void fepci_stream_stop(str
 				     struct fepci_ch_private *fp)
 {
 	uint8_t __iomem *ioaddr = cp->ioaddr;
-	unsigned i = min(RX_RING_SIZE, TX_RING_SIZE) - 1;
+	unsigned d = min(RX_RING_SIZE, TX_RING_SIZE) - 1;
 	struct net_device *dev = fp->this_dev;
-	fp->stream_on = 0;
+	fp->stream_on = false;
 	/* Stop Rx and Tx channels. */
 	writel(0x0, ioaddr + fp->reg_rxctrl);
 	writel(0x0, ioaddr + fp->reg_txctrl);
@@ -1057,18 +1057,18 @@ static inline void fepci_stream_stop(str
 	free_irq(dev->irq, dev);

 	do {
-		if (likely(!pci_dma_mapping_error(
-					pci_unmap_addr(fp->rx + i, address))))
+		if (likely(!pci_dma_mapping_error(cp->pci_dev,
+					pci_unmap_addr(fp->rx + d, address))))
 			pci_unmap_single(cp->pci_dev,
-					 pci_unmap_addr(fp->rx + i, address),
+					 pci_unmap_addr(fp->rx + d, address),
 					 fp->unit_sz,
 					 PCI_DMA_FROMDEVICE);
-		if (likely(!pci_dma_mapping_error(
-					pci_unmap_addr(fp->tx + i, address))))
+		if (likely(!pci_dma_mapping_error(cp->pci_dev,
+					pci_unmap_addr(fp->tx + d, address))))
 			pci_unmap_single(cp->pci_dev,
-					 pci_unmap_addr(fp->tx + i, address),
+					 pci_unmap_addr(fp->tx + d, address),
 					 fp->unit_sz, PCI_DMA_TODEVICE);
-	} while (i--);
+	} while (d--);
 }

 static int fepci_stream_close_down(struct fepci_card_private *cp,
@@ -1080,15 +1080,15 @@ static int fepci_stream_close_down(struc
 	fepci_stream_stop(cp, fp);
 	/* release memory */
 	if (fp->bufsize_order < PAGE_SHIFT) {
-		rx_order = 0;
-		tx_order = 0;
-		rx_pages = 1;
-		tx_pages = 1;
+		rx_order = 0u;
+		tx_order = 0u;
+		rx_pages = 1u;
+		tx_pages = 1u;
 	} else {
-		rx_order = (int)((fp->bufsize_order) - PAGE_SHIFT + 1);
-		rx_pages = 1 << rx_order;
-		tx_order = (int)((fp->bufsize_order) - PAGE_SHIFT);
-		tx_pages = 1 << tx_order;
+		rx_order = fp->bufsize_order - PAGE_SHIFT + 1u;
+		rx_pages = 1u << rx_order;
+		tx_order = fp->bufsize_order - PAGE_SHIFT;
+		tx_pages = 1u << tx_order;
 	}
 	if (fp->rx_buffer) {
 		free_pages((unsigned long)fp->rx_buffer, rx_order);
@@ -1098,7 +1098,7 @@ static int fepci_stream_close_down(struc
 		free_pages((unsigned long)fp->tx_buffer, tx_order);
 		fp->tx_buffer = NULL;
 	}
-	fp->in_stream_mode = 0;
+	fp->in_stream_mode = false;
 	return 0;
 }

@@ -1116,21 +1116,21 @@ static irqreturn_t fepci_stream_interrup
 	if (!intr_status)
 		return IRQ_NONE;
 	clear_int(channel, intr_status, ioaddr);
-	/* First update cur_rx, and do stuff if it has moved
-	   (+ packets have been received). */
 	temp_rx = fp->cur_rx;
-	while ((readl(&fp->rx_desc[fp->cur_rx].desc_b) &
-		transfer_not_done) == 0 /* has been received */
-	       /* Stop if made one round. */
-	       && temp_rx != ((fp->cur_rx + 1) & (RX_RING_SIZE - 1))) {
-		if (likely(!pci_dma_mapping_error(
-			pci_unmap_addr(fp->rx + fp->cur_rx, address))))
+	while (!(readl(&fp->rx_desc[fp->cur_rx].desc_b) & transfer_not_done)
+		/* Has been received. */ &&
+		/* Stop if made one round. */
+	       temp_rx != ((fp->cur_rx + 1u) & (RX_RING_SIZE - 1u))) {
+		if (likely(!pci_dma_mapping_error(fp->this_card_priv->pci_dev,
+						  pci_unmap_addr(fp->rx +
+								 fp->cur_rx,
+								 address))))
 			pci_unmap_single(fp->this_card_priv->pci_dev,
-					 pci_unmap_addr(fp->rx + fp->cur,
+					 pci_unmap_addr(fp->rx + fp->cur_rx,
 							address),
 					 fp->unit_sz, PCI_DMA_FROMDEVICE);
-		fp->cur_rx = (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
-		fp->cur_rx_unit = (fp->cur_rx_unit + 1);
+		fp->cur_rx = (fp->cur_rx + 1u) & (RX_RING_SIZE - 1u);
+		fp->cur_rx_unit = (fp->cur_rx_unit + 1u);
 		fp->cur_rx_unit *= fp->cur_rx_unit < fp->units;
 		*USER_RX_S_POINTER(fp->this_card_priv->card_number,
 				   fp->channel_number,
@@ -1142,13 +1142,13 @@ static irqreturn_t fepci_stream_interrup
 		wake_up_interruptible(&(fp->this_card_priv->stream_receive_q));
 		wake_up_interruptible(&(fp->this_card_priv->stream_both_q));
 	}
-	/* from the first uninitialized descriptor to cur_rx */
-	temp_rx = (fp->cur_rx + 1) & (RX_RING_SIZE - 1);
+	/* From the first uninitialized descriptor to cur_rx. */
+	temp_rx = (fp->cur_rx + 1u) & (RX_RING_SIZE - 1u);
 	temp_rx_unit = (fp->cur_rx_unit + 1);
 	temp_rx_unit *= temp_rx_unit < fp->units;
 	while (temp_rx != fp->cur_rx) {
 		uint32_t desc_b = readl(&fp->rx_desc[temp_rx].desc_b);
-		if ((desc_b & transfer_not_done) == 0) {
+		if (!(desc_b & transfer_not_done)) {
 			dma_addr_t bus_address;
 			/* Update debug counters. */
 			if (unlikely(desc_b & fifo_error)) {
@@ -1166,7 +1166,9 @@ static irqreturn_t fepci_stream_interrup
 				pci_map_single(fp->this_card_priv->pci_dev,
 					       fp->rx_unit[temp_rx_unit],
 					       fp->unit_sz, PCI_DMA_FROMDEVICE);
-			if (likely(!pci_dma_mapping_error(bus_address))) {
+			if (likely(!pci_dma_mapping_error(fp->this_card_priv->
+									pci_dev,
+							  bus_address))) {
 				pci_unmap_addr_set(fp->rx + temp_rx, address,
 						   bus_address);
 				writel(bus_address,
@@ -1178,27 +1180,26 @@ static irqreturn_t fepci_stream_interrup
 					 "failed to map DMA for reception\n");
 			}
 		}
-		temp_rx = (temp_rx + 1) & (RX_RING_SIZE - 1);
-		temp_rx_unit = (temp_rx_unit + 1);
+		temp_rx = (temp_rx + 1u) & (RX_RING_SIZE - 1u);
+		temp_rx_unit = (temp_rx_unit + 1u);
 		temp_rx_unit *= temp_rx_unit < fp->units;
 	}

-	/* first update cur_tx, and do stuff if it has moved
-	   (+ packets have been transmitted) */
 	temp_tx = fp->cur_tx;
-	/* has been transmitted? */
-	while ((readl_relaxed(&fp->tx_desc[fp->cur_tx].desc_b) &
-		transfer_not_done) == 0
-		/* stop if made one round */
-	       && temp_tx != ((fp->cur_tx + 1) & (TX_RING_SIZE - 1))) {
-		if (likely(!pci_dma_mapping_error(
-			pci_unmap_addr(fp->tx + fp->cur_tx, address))))
+	while (!(readl_relaxed(&fp->tx_desc[fp->cur_tx].desc_b) &
+		transfer_not_done) /* Has been transmitted. */ &&
+		/* Stop if made one round. */
+	       temp_tx != ((fp->cur_tx + 1u) & (TX_RING_SIZE - 1u))) {
+		if (likely(!pci_dma_mapping_error(fp->this_card_priv->pci_dev,
+						  pci_unmap_addr(fp->tx +
+								 fp->cur_tx,
+								 address))))
 			pci_unmap_single(fp->this_card_priv->pci_dev,
 					 pci_unmap_addr(fp->tx + fp->cur_tx,
 							address),
 					 fp->unit_sz, PCI_DMA_TODEVICE);
-		fp->cur_tx = (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
-		fp->cur_tx_unit = (fp->cur_tx_unit + 1);
+		fp->cur_tx = (fp->cur_tx + 1u) & (TX_RING_SIZE - 1u);
+		fp->cur_tx_unit = (fp->cur_tx_unit + 1u);
 		fp->cur_tx_unit *= fp->cur_tx_unit < fp->units;
 			*USER_TX_S_POINTER(fp->this_card_priv->card_number,
 					   fp->channel_number,
@@ -1214,24 +1215,26 @@ static irqreturn_t fepci_stream_interrup
 					stream_both_q));
 	}

-	/* from the first uninitialized descriptor to cur_tx */
-	temp_tx = (fp->cur_tx + 1) & (TX_RING_SIZE - 1);
-	temp_tx_unit = (fp->cur_tx_unit + 1);
+	/* From the first uninitialized descriptor to cur_tx. */
+	temp_tx = (fp->cur_tx + 1u) & (TX_RING_SIZE - 1u);
+	temp_tx_unit = (fp->cur_tx_unit + 1u);
 	temp_tx_unit *= temp_tx_unit < fp->units;

 	while (temp_tx != fp->cur_tx) {
 		uint32_t desc_b = readl_relaxed(&fp->tx_desc[temp_tx].desc_b);
-		if ((desc_b & transfer_not_done) == 0) {
+		if (!(desc_b & transfer_not_done)) {
 			dma_addr_t bus_address;
-			/* update debug counters */
+			/* Update debug counters. */
 			if (unlikely(desc_b & fifo_error))
 				dev->stats.tx_fifo_errors++;
-			/* initialize the descriptor for transfer */
+			/* Initialize the descriptor for transfer. */
 			bus_address =
 				pci_map_single(fp->this_card_priv->pci_dev,
 					       fp->tx_unit[temp_tx_unit],
 					       fp->unit_sz, PCI_DMA_TODEVICE);
-			if (likely(!pci_dma_mapping_error(bus_address))) {
+			if (likely(!pci_dma_mapping_error(fp->this_card_priv->
+									pci_dev,
+							  bus_address))) {
 				pci_unmap_addr_set(fp->tx + temp_tx,
 						   address, bus_address);
 				writel(bus_address,
@@ -1244,8 +1247,8 @@ static irqreturn_t fepci_stream_interrup
 					 "failed to map transmission DMA\n");
 			}
 		}
-		temp_tx = (temp_tx + 1) & (TX_RING_SIZE - 1);
-		temp_tx_unit = (temp_tx_unit + 1);
+		temp_tx = (temp_tx + 1u) & (TX_RING_SIZE - 1u);
+		temp_tx_unit = (temp_tx_unit + 1u);
 		temp_tx_unit *= temp_tx_unit < fp->units;
 	}

@@ -1291,9 +1294,9 @@ static int __devinit fepci_init_one(stru
 			goto FOUND;
 		}
 	}
-	if (unlikely(find_cnt == 256))
+	if (unlikely(find_cnt == 256u))
 		return -ENOMEM;
-	cards = kmalloc((find_cnt + 1) * sizeof(struct fepci_card_private *),
+	cards = kmalloc((find_cnt + 1u) * sizeof(struct fepci_card_private *),
 			GFP_KERNEL);
 	if (cards == NULL)
 		return -ENOMEM;
@@ -1318,7 +1321,7 @@ static int __devinit fepci_init_one(stru
 	kfree(old);
 	find_cnt++;
 FOUND:
-	if (PCI_FUNC(pdev->devfn) != 0)
+	if (PCI_FUNC(pdev->devfn) != 0u)
 		return -ENXIO;
 	i = pci_enable_device(pdev);
 	if (unlikely(i)) {
@@ -1326,7 +1329,7 @@ FOUND:
 		return i;
 	}
 	pci_set_master(pdev);
-	i = pci_request_regions(pdev, (char *)fepci_name);
+	i = pci_request_regions(pdev, fepci_name);
 	if (unlikely(i)) {
 		dev_warn(&pdev->dev, "requesting regions error %d\n", i);
 		pci_disable_device(pdev);
@@ -1337,17 +1340,17 @@ FOUND:
 		dev_warn(&pdev->dev, "no suitable DMA available\n");
 		goto ERR_1;
 	}
-	if (unlikely(pci_resource_len(pdev, 0) < FEPCI_SIZE)) {
+	if (unlikely(pci_resource_len(pdev, 0u) < FEPCI_SIZE)) {
 		dev_warn(&pdev->dev, "resource length less than required %u\n",
 			 FEPCI_SIZE);
 		i = -ENXIO;
 		goto ERR_1;
 	}
-	if (unlikely(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM))) {
+	if (unlikely(!(pci_resource_flags(pdev, 0u) & IORESOURCE_MEM))) {
 		i = -ENXIO;
 		goto ERR_1;
 	}
-	ioaddr = pci_iomap(pdev, 0, FEPCI_SIZE);
+	ioaddr = pci_iomap(pdev, 0u, FEPCI_SIZE);
 	if (unlikely(!ioaddr)) {
 		dev_warn(&pdev->dev, "mapping failed\n");
 		i = -ENOMEM;
@@ -1386,12 +1389,12 @@ FOUND:
 		card_private->ch_privates[j] = fp;
 		name = dev->name;
 		/* name := xxx01..xxxnn */
-		memcpy(name, fepci_netdev_name, 6);
+		memcpy(name, fepci_netdev_name, 6u);
 		/* dev->name[3]= j+'0';    channel number -> ascii */
 		/* minor number -> ascii */
-		name[4] = ((position * CHANNELS + j) % 10) + '0';
+		name[4] = ((position * CHANNELS + j) % 10u) + '0';
 		/* minor number -> ascii */
-		name[3] = ((position * CHANNELS + j) / 10) + '0';
+		name[3] = ((position * CHANNELS + j) / 10u) + '0';
 		clear_int(j, IntrAllInts, ioaddr);
 		ether_setup(dev);
 		/* HW_ADDR is got using the mailbox: */
@@ -1402,40 +1405,37 @@ FOUND:
 		waituntil = jiffies + HZ;
 		while (time_before(jiffies, waituntil) &&
 		       get_semafore(real_mailbox) != RETINA_READY_PC)
-			msleep(1);
+			msleep(1u);
 		if (get_semafore(real_mailbox) == RETINA_READY_PC) {
-			u32 __iomem *data = real_mailbox->Data + 3 * j;
+			u32 __iomem *data = real_mailbox->Data + 3u * j;
 			address[5] = readb_relaxed(data);
-			address[4] = readb_relaxed(((u8 __iomem *) data)
-						   + 1);
+			address[4] = readb_relaxed((u8 __iomem *)data + 1u);
 			address[3] = readb_relaxed(++data);
-			address[2] = readb_relaxed(((u8 __iomem *) data)
-						   + 1);
+			address[2] = readb_relaxed((u8 __iomem *)data + 1u);
 			address[1] = readb_relaxed(++data);
-			address[0] = readb_relaxed(((u8 __iomem *) data)
-						   + 1);
+			address[0] = readb_relaxed((u8 __iomem *)data + 1u);
 			if (unlikely(!is_valid_ether_addr(address)))
 				goto RANDOM;
 		} else {
 RANDOM:			random_ether_addr(address);
 		}
 		set_semafore(real_mailbox, RETINA_IDLE);
-		dev->addr_len = 6;
+		dev->addr_len = 6u;
 		dev->base_addr = (unsigned long)ioaddr;
 		dev->irq = pdev->irq;
 		fp->rx_desc = (struct fepci_desc __iomem *)
 			(ioaddr + first_rx_desc + j * to_next_ch_rx_desc);
 		fp->tx_desc = (struct fepci_desc __iomem *)
 			(ioaddr + first_tx_desc + j * to_next_ch_tx_desc);
-		fp->channel_number = j;	/* channel in this device */
+		fp->channel_number = j;	/* The channel in this device. */
 		fp->this_dev = dev;
 		fp->this_card_priv = card_private;
-		fp->cur_tx = 0;
-		fp->in_stream_mode = 0;
-		fp->in_eth_mode = 0;
+		fp->cur_tx = 0u;
+		fp->in_stream_mode = false;
+		fp->in_eth_mode = false;
 		fp->reg_rxctrl = reg_first_rxctrl + j * to_next_rxctrl;
 		fp->reg_txctrl = reg_first_txctrl + j * to_next_txctrl;
-		/* The FEPCI specific entries in the device structure */
+		/* The specific entries in the device structure. */
 		dev->open = &fepci_open;
 		dev->hard_start_xmit = &fepci_start_xmit;
 		dev->stop = &fepci_close;
@@ -1464,6 +1464,52 @@ ERR_1:
 	return i;
 }

+/* Initialize the reception and transmission ring buffers. */
+static inline void fepci_init_ring(struct net_device *dev)
+{
+	struct fepci_ch_private *fp = netdev_priv(dev);
+	unsigned d;
+
+	for (d = 0u; d < RX_RING_SIZE; d++) {
+		struct sk_buff *skb = __netdev_alloc_skb(dev,
+							 RETINA_DMA_SIZE +
+							 NET_IP_ALIGN,
+							 GFP_KERNEL);
+		if (unlikely(skb == NULL)) {
+ZERO:
+			writel(0u, &fp->rx_desc[d].desc_a);
+			writel(0u, &fp->rx_desc[d].desc_b);
+		} else {
+			dma_addr_t bus_address;
+			skb_reserve(skb, NET_IP_ALIGN);
+			bus_address =
+				pci_map_single(fp->this_card_priv->pci_dev,
+						skb->data, RETINA_MRU,
+						PCI_DMA_FROMDEVICE);
+			if (likely(!pci_dma_mapping_error(fp->this_card_priv->
+									pci_dev,
+							  bus_address))) {
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+				fp->rx[d].skbuff = skb;
+				pci_unmap_addr_set(fp->rx + d, address,
+						   bus_address);
+				writel(bus_address, &fp->rx_desc[d].desc_a);
+				writel(enable_transfer, &fp->rx_desc[d].desc_b);
+			} else {
+				dev_kfree_skb(skb);
+				goto ZERO;
+			}
+		}
+	}
+
+	for (d = 0u; d < TX_RING_SIZE; d++) {
+		fp->tx[d].skbuff = NULL;
+		writel(0u, &fp->tx_desc[d].desc_a); /* No address. */
+		/* No transfer enable, no interrupt enable. */
+		writel(0u, &fp->tx_desc[d].desc_b);
+	}
+}
+
 static int fepci_open_down(struct net_device *dev, struct fepci_ch_private *fp)
 {
 	uint8_t __iomem *ioaddr = (uint8_t __iomem *)dev->base_addr;
@@ -1481,12 +1527,12 @@ static int fepci_open_down(struct net_de
 		}
 	}

-	fp->in_eth_mode = 1;
+	fp->in_eth_mode = true;

 	fepci_init_ring(dev);

-	fp->cur_rx = 0;
-	fp->cur_tx = 0;
+	fp->cur_rx = 0u;
+	fp->cur_tx = 0u;

 	netif_carrier_off(dev);

@@ -1507,7 +1553,7 @@ static int fepci_open_down(struct net_de
 		(Tx_fifo_threshold & TX_FIFO_THRESHOLD_PACKET_MODE)),
 	       ioaddr + fp->reg_txctrl);

-	netif_wake_queue(dev);
+	netif_start_queue(dev);

 	init_timer(&fp->timer);
 	fp->timer.expires = jiffies + HZ;
@@ -1537,13 +1583,13 @@ static void fepci_timer(unsigned long da
 	struct fepci_ch_private *fp = netdev_priv(dev);

 	if ((get_common_reg_word(fp->this_card_priv->ioaddr, 0x72) >>
-	     fp->channel_number) & 1)
+	     fp->channel_number) & 1u)
 		netif_carrier_off(dev);
 	else
 		netif_carrier_on(dev);

 	if (fp->in_eth_mode)
-		mod_timer(&fp->timer, jiffies + 5 * HZ);
+		mod_timer(&fp->timer, jiffies + 5ul * HZ);
 }

 static void fepci_tx_timeout(struct net_device *dev)
@@ -1552,50 +1598,6 @@ static void fepci_tx_timeout(struct net_
 	tasklet_schedule(&fp->transmission);
 }

-/* Initialize the reception and transmission ring buffers. */
-static void fepci_init_ring(struct net_device *dev)
-{
-	struct fepci_ch_private *fp = netdev_priv(dev);
-	unsigned i;
-
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = __netdev_alloc_skb(dev,
-							 RETINA_DMA_SIZE +
-							 NET_IP_ALIGN,
-							 GFP_KERNEL);
-		if (unlikely(skb == NULL)) {
-ZERO:
-			writel(0, &fp->rx_desc[i].desc_a);
-			writel(0, &fp->rx_desc[i].desc_b);
-		} else {
-			dma_addr_t bus_address;
-			skb_reserve(skb, NET_IP_ALIGN);
-			bus_address =
-				pci_map_single(fp->this_card_priv->pci_dev,
-						skb->data, RETINA_MRU,
-						PCI_DMA_FROMDEVICE);
-			if (likely(!pci_dma_mapping_error(bus_address))) {
-				skb->ip_summed = CHECKSUM_UNNECESSARY;
-				fp->rx[i].skbuff = skb;
-				pci_unmap_addr_set(fp->rx + i, address,
-						   bus_address);
-				writel(bus_address, &fp->rx_desc[i].desc_a);
-				writel(enable_transfer, &fp->rx_desc[i].desc_b);
-			} else {
-				dev_kfree_skb(skb);
-				goto ZERO;
-			}
-		}
-	}
-
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		fp->tx[i].skbuff = NULL;
-		writel(0, &fp->tx_desc[i].desc_a); /* No address. */
-		/* No transfer enable, no interrupt enable. */
-		writel(0, &fp->tx_desc[i].desc_b);
-	}
-}
-
 static int fepci_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fepci_ch_private *fp;
@@ -1615,7 +1617,8 @@ static int fepci_start_xmit(struct sk_bu
 	bus_address = pci_map_single(fp->this_card_priv->pci_dev, skb->data,
 				     tx_length, PCI_DMA_TODEVICE);
 	cur_tx = fp->cur_tx;
-	if (likely(!pci_dma_mapping_error(bus_address))) {
+	if (likely(!pci_dma_mapping_error(fp->this_card_priv->pci_dev,
+					  bus_address))) {
 		struct fepci_desc __iomem *descriptor;
 		pci_unmap_addr_set(fp->tx + cur_tx, address, bus_address);
 		descriptor = &fp->tx_desc[cur_tx];
@@ -1630,7 +1633,7 @@ static int fepci_start_xmit(struct sk_bu
 	fp->tx[cur_tx].skbuff = skb;

 	/* Calculate the next transmission descriptor entry. */
-	next = (cur_tx + 1) & (TX_RING_SIZE - 1);
+	next = (cur_tx + 1u) & (TX_RING_SIZE - 1u);
 	fp->cur_tx = next;
 	/* If the next descriptor is busy, discontinue taking new ones. */
 	if (fp->tx[next].skbuff != NULL)
@@ -1642,59 +1645,57 @@ static int fepci_start_xmit(struct sk_bu

 static void retina_tx(unsigned long channel)
 {
-	unsigned next;
 	struct fepci_ch_private *fp = (struct fepci_ch_private *)channel;
 	struct net_device *dev = fp->this_dev;
 	struct fepci_desc __iomem *tx_desc = fp->tx_desc;
-	unsigned i = 0;
+	unsigned d = 0u;
 	do {
 		uint32_t desc_b;
-		struct sk_buff *skb = fp->tx[i].skbuff;
+		struct sk_buff *skb = fp->tx[d].skbuff;
 		struct fepci_desc __iomem *desc;
 		if (skb == NULL)
 			continue;
-		desc = tx_desc + i;
+		desc = tx_desc + d;
 		desc_b = readl_relaxed(&desc->desc_b);
-		if ((desc_b & transfer_not_done) == 0) {
-			/* Has been sent. */
+		if (!(desc_b & transfer_not_done)) { /* Has been sent. */
 			pci_unmap_single(fp->this_card_priv->pci_dev,
-					 pci_unmap_addr(fp->tx + i, address),
+					 pci_unmap_addr(fp->tx + d, address),
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
-			fp->tx[i].skbuff = NULL;
+			fp->tx[d].skbuff = NULL;
 			if (unlikely(desc_b & fifo_error))
 				dev->stats.tx_fifo_errors++;
 			else
 				dev->stats.tx_packets++;
 		}
-	} while (i++ < TX_RING_SIZE - 1);
-	netif_tx_lock(dev);
-	next = fp->cur_tx;
-	/* If next transmission descriptor is free, continue taking new ones. */
-	if (netif_queue_stopped(dev) &&
-	    fp->tx[next].skbuff == NULL &&
-	    fp->in_eth_mode)
-		netif_wake_queue(dev);
-	netif_tx_unlock(dev);
+	} while (d++ < TX_RING_SIZE - 1u);
+	if (__netif_tx_trylock(netdev_get_tx_queue(dev, 0u))) {
+		unsigned next = fp->cur_tx;
+		if (netif_queue_stopped(dev) &&
+		    fp->tx[next].skbuff == NULL &&
+		    fp->in_eth_mode)
+			netif_wake_queue(dev);
+		netif_tx_unlock(dev);
+	} else {
+		tasklet_schedule(&fp->transmission);
+	}
 }

 static inline void fepci_rx(struct fepci_ch_private *fp, struct
net_device *dev)
 {
-	unsigned i, old_cur_rx = fp->cur_rx;
-	unsigned last = (old_cur_rx + RX_RING_SIZE - 1) & (RX_RING_SIZE - 1);
-	for (i = old_cur_rx;
-	     i != last;
-	     i = (i + 1) & (RX_RING_SIZE - 1)) {
+	unsigned d, old_cur_rx = fp->cur_rx;
+	unsigned last = (old_cur_rx + RX_RING_SIZE - 1u) & (RX_RING_SIZE - 1u);
+	for (d = old_cur_rx; d != last; d = (d + 1u) & (RX_RING_SIZE - 1u)) {
 		uint32_t desc_b;
-		struct sk_buff **rx_skbuff = &fp->rx[i].skbuff;
+		struct sk_buff **rx_skbuff = &fp->rx[d].skbuff;
 		struct sk_buff *skb = *rx_skbuff;
-		struct fepci_desc __iomem *rx_desc = fp->rx_desc + i;
+		struct fepci_desc __iomem *rx_desc = fp->rx_desc + d;
 		if (unlikely(skb == NULL))
 			goto RESERVE;
 		desc_b = readl(&rx_desc->desc_b);
-		if (!(desc_b & transfer_not_done)) { /* transfer done */
+		if (!(desc_b & transfer_not_done)) { /* Transfer done. */
 			uint32_t length;
-			fp->cur_rx = (i + 1) & (RX_RING_SIZE - 1);
+			fp->cur_rx = (d + 1u) & (RX_RING_SIZE - 1u);
 			if (unlikely(desc_b & (fifo_error | size_error |
 					       crc_error | octet_error |
 					       line_error))) {
@@ -1708,13 +1709,13 @@ ENABLE_TRANSFER:		writel(enable_transfer
 				dev->stats.rx_errors++;
 				continue;
 			}
-			length = (desc_b & frame_length) - 4;
+			length = (desc_b & frame_length) - 4u;
 			if (unlikely(length > RETINA_MRU)) {
 				dev->stats.rx_length_errors++;
 				goto ENABLE_TRANSFER;
 			}
 			pci_unmap_single(fp->this_card_priv->pci_dev,
-				pci_unmap_addr(fp->rx + i, address),
+				pci_unmap_addr(fp->rx + d, address),
 				RETINA_MRU, PCI_DMA_FROMDEVICE);
 			__skb_put(skb, length);
 			skb->protocol = eth_type_trans(skb, dev);
@@ -1755,8 +1756,10 @@ RESERVE:		skb = netdev_alloc_skb(dev, RE
 							 pci_dev, skb->data,
 							 RETINA_MRU,
 							 PCI_DMA_FROMDEVICE);
-				if (likely(!pci_dma_mapping_error(address))) {
-					pci_unmap_addr_set(fp->rx + i,
+				if (likely(!pci_dma_mapping_error(fp->
+							this_card_priv->pci_dev,
+								  address))) {
+					pci_unmap_addr_set(fp->rx + d,
 							   address, address);
 					*rx_skbuff = skb;
 					skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -1798,7 +1801,7 @@ static void fepci_close_down(struct net_
 			     struct fepci_ch_private *fp,
 			     struct fepci_card_private *card)
 {
-	unsigned i;
+	unsigned d;
 	uint8_t __iomem *ioaddr;
 	struct pci_dev *pdev;
 	if (unlikely(!fp->in_eth_mode))
@@ -1810,8 +1813,8 @@ static void fepci_close_down(struct net_
 	ioaddr = (uint8_t __iomem *)dev->base_addr;
 	writel(0x0, ioaddr + fp->reg_rxctrl);
 	writel(0x0, ioaddr + fp->reg_txctrl);
-	fp->in_eth_mode = 0;
-	smp_wmb(); /* Get out of Ethernet mode before deleting the timer. */
+	fp->in_eth_mode = false;
+	smp_wmb(); /* Prevent restarting the timer by setting the mode false. */
 	del_timer_sync(&fp->timer);

 	free_irq(dev->irq, dev);
@@ -1819,26 +1822,26 @@ static void fepci_close_down(struct net_
 	tasklet_kill(&fp->transmission);
 	netif_tx_disable(dev);
 	pdev = card->pci_dev;
-	/* Free all the reception struct sk_buffs... */
-	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = fp->rx[i].skbuff;
+	/* Free all the reception struct sk_buffs. */
+	for (d = 0u; d < RX_RING_SIZE; d++) {
+		struct sk_buff *skb = fp->rx[d].skbuff;
 		if (skb != NULL) {
 			pci_unmap_single(pdev,
-					 pci_unmap_addr(fp->rx + i, address),
+					 pci_unmap_addr(fp->rx + d, address),
 					 RETINA_MRU, PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(skb);
-			fp->rx[i].skbuff = NULL;
+			fp->rx[d].skbuff = NULL;
 		}
 	}
-	/* ...and transmission ones. */
-	for (i = 0; i < TX_RING_SIZE; i++) {
-		struct sk_buff *skb = fp->tx[i].skbuff;
+	/* Free all the transmission sk_buffs. */
+	for (d = 0u; d < TX_RING_SIZE; d++) {
+		struct sk_buff *skb = fp->tx[d].skbuff;
 		if (skb != NULL) {
 			pci_unmap_single(pdev,
-					 pci_unmap_addr(fp->tx + i, address),
+					 pci_unmap_addr(fp->tx + d, address),
 					 skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
-			fp->tx[i].skbuff = NULL;
+			fp->tx[d].skbuff = NULL;
 		}
 	}
 }
@@ -1857,8 +1860,8 @@ static void alarm_off(uint8_t __iomem *i
 {
 	uint8_t __iomem *ioaddr_reg_custom = ioaddr + reg_custom;
 	do {
-		/* Alarm manager interrupt off. */
-		writel(0, ioaddr_reg_custom);
+		/* Turn the alarm manager interrupt off. */
+		writel(0u, ioaddr_reg_custom);
 		synchronize_irq(irq);
 	} while (readl_relaxed(ioaddr_reg_custom) & AM_interrupt_mask);
 }
@@ -1866,21 +1869,21 @@ static void alarm_off(uint8_t __iomem *i
 static void fepci_remove_one(struct pci_dev *pdev)
 {
 	struct fepci_card_private *cardp = pci_get_drvdata(pdev);
-	unsigned int i;
+	unsigned int c;
 	uint8_t __iomem *ioaddr = cardp->ioaddr;
 	unsigned int irq = pdev->irq;
 	cardp->removed = true;
 	alarm_off(ioaddr, irq);

-	for (i = 0; i < CHANNELS; i++) {
-		struct fepci_ch_private *fp = cardp->ch_privates[i];
+	for (c = 0u; c < CHANNELS; c++) {
+		struct fepci_ch_private *fp = cardp->ch_privates[c];
 		struct net_device *dev = fp->this_dev;
 		if (unlikely(dev == NULL))
 			continue;
 		unregister_netdev(dev);
 		fepci_stream_close(cardp, fp);
 		free_netdev(dev);
-		cardp->ch_privates[i] = NULL;
+		cardp->ch_privates[c] = NULL;
 	}
 	free_irq(irq, cardp);

@@ -1898,10 +1901,9 @@ static void fepci_remove_one(struct pci_
 static int fepci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct fepci_card_private *cardp = pci_get_drvdata(pdev);
-	unsigned channel;
+	unsigned channel = 0u;
 	unsigned irq = pdev->irq;
 	cardp->removed = true;
-	channel = 0;
 	do {
 		struct fepci_ch_private *fp = cardp->ch_privates[channel];
 		struct net_device *dev = fp->this_dev;
@@ -1923,7 +1925,7 @@ static int fepci_suspend(struct pci_dev
 		fp->in_eth_mode = in_eth_mode;
 		fp->in_stream_mode = in_stream_mode;
 		fp->stream_on = stream_on;
-	} while (channel++ < CHANNELS - 1);
+	} while (channel++ < CHANNELS - 1u);
 	alarm_off(cardp->ioaddr, irq);
 	/* Disable IRQ */
 	free_irq(irq, cardp);
@@ -1955,9 +1957,9 @@ static int fepci_resume(struct pci_dev *
 			    IRQF_SHARED, fepci_alarm_manager_name, cardp);
 	if (unlikely(error))
 		return error;
-	/* Alarm manager interrupt on. */
+	/* Turn alarm manager interrupt on. */
 	writel(AM_interrupt_mask, cardp->ioaddr + reg_custom);
-	channel = 0;
+	channel = 0u;
 	cardp->removed = false;
 	do {
 		struct fepci_ch_private *fp = cardp->ch_privates[channel];
@@ -1972,12 +1974,12 @@ static int fepci_resume(struct pci_dev *
 				error = open;
 		} else if (fp->in_stream_mode) {
 			int open;
-			fp->in_stream_mode = 0;
+			fp->in_stream_mode = false;
 			open = fepci_stream_open(cardp, fp);
 			if (unlikely(open))
 				error = open;
 			if (fp->stream_on) {
-				fp->stream_on = 0;
+				fp->stream_on = false;
 				open = fepci_stream_start(cardp, fp);
 				if (unlikely(open))
 					error = open;
@@ -1985,13 +1987,13 @@ static int fepci_resume(struct pci_dev *
 		}
 		rtnl_unlock();
 		netif_device_attach(dev);
-	} while (channel++ < CHANNELS - 1);
+	} while (channel++ < CHANNELS - 1u);
 	return error;
 }
 #endif

 static struct pci_driver fepci_driver = {
-	.name		= "retina",
+	.name		= fepci_name,
 	.id_table	= fepci_pci_tbl,
 	.probe		= fepci_init_one,
 	.remove		= fepci_remove_one,
@@ -2004,7 +2006,7 @@ static struct pci_driver fepci_driver =
 static int __init fepci_init(void)
 {
 	stream_pointers = get_zeroed_page(GFP_KERNEL);
-	if (unlikely(stream_pointers == 0))
+	if (unlikely(stream_pointers == 0ul))
 		return -ENOMEM;
 	major = pci_register_driver(&fepci_driver);
 	if (unlikely(major))
@@ -2025,7 +2027,7 @@ static void __exit fepci_cleanup(void)
 	pci_unregister_driver(&fepci_driver);
 	fepci_unregister_char_device();
 	free_page(stream_pointers);
-	for (card = 0; card < find_cnt; card++)
+	for (card = 0u; card < find_cnt; card++)
 		kfree(card_privates[card]);
 	kfree(card_privates);
 }
--- linux/MAINTAINERS	2008-08-08 08:37:41.086996000 +0300
+++ linux-next/MAINTAINERS	2008-08-08 09:14:52.942800400 +0300
@@ -3519,7 +3519,7 @@ S:	Supported

 RETINA DRIVER
 P:	Matti Linnanvuori
-M:	mattilinnanvuori@yahoo.com
+M:	matti.linnanvuori@ascom.com
 L:	netdev@vger.kernel.org
 S:	Supported
