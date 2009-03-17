From: David Woodhouse <dwmw2@infradead.org>
Subject: [GIT *] Solos PCI ADSL card update
Date: Tue, 17 Mar 2009 17:19:30 +0000
Message-ID: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	Chas Williams <chas@cmf.nrl.navy.mil>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:36114 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbZCQRTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 13:19:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from git://git.infradead.org/~dwmw2/solos-2.6.git

This contains a bunch of updates to the Solos PCI driver (full patch
below for review):

David Woodhouse (27):
      solos: Fix length header in FPGA transfers
      solos: Clean up firmware loading code
      solos: Kill global 'opens' count.
      solos: Handle attribute show/store in kernel more sanely
      solos: Add initial list of parameters
      solos: Handle new line status change packets, hook up to ATM layer info
      solos: Kill existing connections on link down event
      solos: Reject non-AAL5 connections.... for now
      solos: Add SNR and Attn to status packet, fix oops on load
      solos: Fix under-allocation of skb size for get/set parameters
      solos: Remove parameter group from sysfs on ATM dev deregister
      solos: First attempt at DMA support
      solos: Tidy up DMA handling a little. Still untested
      solos: Tidy up tx_mask handling for ports which need TX
      solos: Remove unused loopback debug stuff
      solos: Remove IRQF_DISABLED, don't frob IRQ enable on the FPGA in solos_irq()
      solos: Remove superfluous wait_queue_head_t from struct solos_param
      solos: Fix various bugs in status packet handling
      solos: Clean up handling of card->tx_mask a little
      solos: Remove debugging, commented-out test code
      solos: Add 'reset' module parameter to reset the DSL chips on load
      solos: Tidy up status interrupt handling, cope with 'ERROR' status
      solos: Don't clear config registers at startup
      solos: Set RX empty flag at startup only for !dma mode
      solos: Swap upstream/downstream rates in status packet, clean up some more
      solos: Reset device on unload, free pending skbs
      solos: Disable DMA until we have an FPGA update with it actually implemented.

Nathan Williams (1):
      solos: Automatically determine number of ports

Simon Farnsworth (2):
      solos: Slight debugging improvements
      solos: FPGA and firmware update support.

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 72fc0f7..bc3079d 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -9,6 +9,7 @@
  *
  * Authors: Nathan Williams <nathan@traverse.com.au>
  *          David Woodhouse <dwmw2@infradead.org>
+ *          Treker Chen <treker@xrio.com>
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -36,8 +37,11 @@
 #include <linux/sysfs.h>
 #include <linux/device.h>
 #include <linux/kobject.h>
+#include <linux/firmware.h>
+#include <linux/ctype.h>
+#include <linux/swab.h>
 
-#define VERSION "0.04"
+#define VERSION "0.07"
 #define PTAG "solos-pci"
 
 #define CONFIG_RAM_SIZE	128
@@ -45,16 +49,31 @@
 #define IRQ_EN_ADDR	0x78
 #define FPGA_VER	0x74
 #define IRQ_CLEAR	0x70
-#define BUG_FLAG	0x6C
+#define WRITE_FLASH	0x6C
+#define PORTS		0x68
+#define FLASH_BLOCK	0x64
+#define FLASH_BUSY	0x60
+#define FPGA_MODE	0x5C
+#define FLASH_MODE	0x58
+#define TX_DMA_ADDR(port)	(0x40 + (4 * (port)))
+#define RX_DMA_ADDR(port)	(0x30 + (4 * (port)))
 
 #define DATA_RAM_SIZE	32768
 #define BUF_SIZE	4096
+#define FPGA_PAGE	528 /* FPGA flash page size*/
+#define SOLOS_PAGE	512 /* Solos flash page size*/
+#define FPGA_BLOCK	(FPGA_PAGE * 8) /* FPGA flash block size*/
+#define SOLOS_BLOCK	(SOLOS_PAGE * 8) /* Solos flash block size*/
 
 #define RX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2)
 #define TX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2 + BUF_SIZE)
 
-static int debug = 0;
+#define RX_DMA_SIZE	2048
+
+static int reset = 0;
 static int atmdebug = 0;
+static int firmware_upgrade = 0;
+static int fpga_upgrade = 0;
 
 struct pkt_hdr {
 	__le16 size;
@@ -63,23 +82,48 @@ struct pkt_hdr {
 	__le16 type;
 };
 
+struct solos_skb_cb {
+	struct atm_vcc *vcc;
+	uint32_t dma_addr;
+};
+
+
+#define SKB_CB(skb)		((struct solos_skb_cb *)skb->cb)
+
 #define PKT_DATA	0
 #define PKT_COMMAND	1
 #define PKT_POPEN	3
 #define PKT_PCLOSE	4
+#define PKT_STATUS	5
 
 struct solos_card {
 	void __iomem *config_regs;
 	void __iomem *buffers;
 	int nr_ports;
+	int tx_mask;
 	struct pci_dev *dev;
 	struct atm_dev *atmdev[4];
 	struct tasklet_struct tlet;
 	spinlock_t tx_lock;
 	spinlock_t tx_queue_lock;
 	spinlock_t cli_queue_lock;
+	spinlock_t param_queue_lock;
+	struct list_head param_queue;
 	struct sk_buff_head tx_queue[4];
 	struct sk_buff_head cli_queue[4];
+	struct sk_buff *tx_skb[4];
+	struct sk_buff *rx_skb[4];
+	wait_queue_head_t param_wq;
+	wait_queue_head_t fw_wq;
+	int using_dma;
+};
+
+
+struct solos_param {
+	struct list_head list;
+	pid_t pid;
+	int port;
+	struct sk_buff *response;
 };
 
 #define SOLOS_CHAN(atmdev) ((int)(unsigned long)(atmdev)->phy_data)
@@ -88,19 +132,22 @@ MODULE_AUTHOR("Traverse Technologies <support@traverse.com.au>");
 MODULE_DESCRIPTION("Solos PCI driver");
 MODULE_VERSION(VERSION);
 MODULE_LICENSE("GPL");
-MODULE_PARM_DESC(debug, "Enable Loopback");
+MODULE_PARM_DESC(reset, "Reset Solos chips on startup");
 MODULE_PARM_DESC(atmdebug, "Print ATM data");
-module_param(debug, int, 0444);
-module_param(atmdebug, int, 0444);
-
-static int opens;
+MODULE_PARM_DESC(firmware_upgrade, "Initiate Solos firmware upgrade");
+MODULE_PARM_DESC(fpga_upgrade, "Initiate FPGA upgrade");
+module_param(reset, int, 0444);
+module_param(atmdebug, int, 0644);
+module_param(firmware_upgrade, int, 0444);
+module_param(fpga_upgrade, int, 0444);
 
 static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc);
-static int fpga_tx(struct solos_card *);
+static uint32_t fpga_tx(struct solos_card *);
 static irqreturn_t solos_irq(int irq, void *dev_id);
 static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vci);
 static int list_vccs(int vci);
+static void release_vccs(struct atm_dev *dev);
 static int atm_init(struct solos_card *);
 static void atm_remove(struct solos_card *);
 static int send_command(struct solos_card *card, int dev, const char *buf, size_t size);
@@ -115,6 +162,264 @@ static inline void solos_pop(struct atm_vcc *vcc, struct sk_buff *skb)
                 dev_kfree_skb_any(skb);
 }
 
+static ssize_t solos_param_show(struct device *dev, struct device_attribute *attr,
+				char *buf)
+{
+	struct atm_dev *atmdev = container_of(dev, struct atm_dev, class_dev);
+	struct solos_card *card = atmdev->dev_data;
+	struct solos_param prm;
+	struct sk_buff *skb;
+	struct pkt_hdr *header;
+	int buflen;
+
+	buflen = strlen(attr->attr.name) + 10;
+
+	skb = alloc_skb(sizeof(*header) + buflen, GFP_KERNEL);
+	if (!skb) {
+		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in solos_param_show()\n");
+		return -ENOMEM;
+	}
+
+	header = (void *)skb_put(skb, sizeof(*header));
+
+	buflen = snprintf((void *)&header[1], buflen - 1,
+			  "L%05d\n%s\n", current->pid, attr->attr.name);
+	skb_put(skb, buflen);
+
+	header->size = cpu_to_le16(buflen);
+	header->vpi = cpu_to_le16(0);
+	header->vci = cpu_to_le16(0);
+	header->type = cpu_to_le16(PKT_COMMAND);
+
+	prm.pid = current->pid;
+	prm.response = NULL;
+	prm.port = SOLOS_CHAN(atmdev);
+
+	spin_lock_irq(&card->param_queue_lock);
+	list_add(&prm.list, &card->param_queue);
+	spin_unlock_irq(&card->param_queue_lock);
+
+	fpga_queue(card, prm.port, skb, NULL);
+
+	wait_event_timeout(card->param_wq, prm.response, 5 * HZ);
+
+	spin_lock_irq(&card->param_queue_lock);
+	list_del(&prm.list);
+	spin_unlock_irq(&card->param_queue_lock);
+
+	if (!prm.response)
+		return -EIO;
+
+	buflen = prm.response->len;
+	memcpy(buf, prm.response->data, buflen);
+	kfree_skb(prm.response);
+
+	return buflen;
+}
+
+static ssize_t solos_param_store(struct device *dev, struct device_attribute *attr,
+				 const char *buf, size_t count)
+{
+	struct atm_dev *atmdev = container_of(dev, struct atm_dev, class_dev);
+	struct solos_card *card = atmdev->dev_data;
+	struct solos_param prm;
+	struct sk_buff *skb;
+	struct pkt_hdr *header;
+	int buflen;
+	ssize_t ret;
+
+	buflen = strlen(attr->attr.name) + 11 + count;
+
+	skb = alloc_skb(sizeof(*header) + buflen, GFP_KERNEL);
+	if (!skb) {
+		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in solos_param_store()\n");
+		return -ENOMEM;
+	}
+
+	header = (void *)skb_put(skb, sizeof(*header));
+
+	buflen = snprintf((void *)&header[1], buflen - 1,
+			  "L%05d\n%s\n%s\n", current->pid, attr->attr.name, buf);
+
+	skb_put(skb, buflen);
+	header->size = cpu_to_le16(buflen);
+	header->vpi = cpu_to_le16(0);
+	header->vci = cpu_to_le16(0);
+	header->type = cpu_to_le16(PKT_COMMAND);
+
+	prm.pid = current->pid;
+	prm.response = NULL;
+	prm.port = SOLOS_CHAN(atmdev);
+
+	spin_lock_irq(&card->param_queue_lock);
+	list_add(&prm.list, &card->param_queue);
+	spin_unlock_irq(&card->param_queue_lock);
+
+	fpga_queue(card, prm.port, skb, NULL);
+
+	wait_event_timeout(card->param_wq, prm.response, 5 * HZ);
+
+	spin_lock_irq(&card->param_queue_lock);
+	list_del(&prm.list);
+	spin_unlock_irq(&card->param_queue_lock);
+
+	skb = prm.response;
+
+	if (!skb)
+		return -EIO;
+
+	buflen = skb->len;
+
+	/* Sometimes it has a newline, sometimes it doesn't. */
+	if (skb->data[buflen - 1] == '\n')
+		buflen--;
+
+	if (buflen == 2 && !strncmp(skb->data, "OK", 2))
+		ret = count;
+	else if (buflen == 5 && !strncmp(skb->data, "ERROR", 5))
+		ret = -EIO;
+	else {
+		/* We know we have enough space allocated for this; we allocated 
+		   it ourselves */
+		skb->data[buflen] = 0;
+	
+		dev_warn(&card->dev->dev, "Unexpected parameter response: '%s'\n",
+			 skb->data);
+		ret = -EIO;
+	}
+	kfree_skb(skb);
+
+	return ret;
+}
+
+static char *next_string(struct sk_buff *skb)
+{
+	int i = 0;
+	char *this = skb->data;
+	
+	for (i = 0; i < skb->len; i++) {
+		if (this[i] == '\n') {
+			this[i] = 0;
+			skb_pull(skb, i + 1);
+			return this;
+		}
+		if (!isprint(this[i]))
+			return NULL;
+	}
+	return NULL;
+}
+
+/*
+ * Status packet has fields separated by \n, starting with a version number
+ * for the information therein. Fields are....
+ *
+ *     packet version
+ *     RxBitRate	(version >= 1)
+ *     TxBitRate	(version >= 1)
+ *     State		(version >= 1)
+ *     LocalSNRMargin	(version >= 1)
+ *     LocalLineAttn	(version >= 1)
+ */       
+static int process_status(struct solos_card *card, int port, struct sk_buff *skb)
+{
+	char *str, *end, *state_str, *snr, *attn;
+	int ver, rate_up, rate_down;
+
+	if (!card->atmdev[port])
+		return -ENODEV;
+
+	str = next_string(skb);
+	if (!str)
+		return -EIO;
+
+	ver = simple_strtol(str, NULL, 10);
+	if (ver < 1) {
+		dev_warn(&card->dev->dev, "Unexpected status interrupt version %d\n",
+			 ver);
+		return -EIO;
+	}
+
+	str = next_string(skb);
+	if (!str)
+		return -EIO;
+	if (!strcmp(str, "ERROR")) {
+		dev_dbg(&card->dev->dev, "Status packet indicated Solos error on port %d (starting up?)\n",
+			 port);
+		return 0;
+	}
+
+	rate_down = simple_strtol(str, &end, 10);
+	if (*end)
+		return -EIO;
+
+	str = next_string(skb);
+	if (!str)
+		return -EIO;
+	rate_up = simple_strtol(str, &end, 10);
+	if (*end)
+		return -EIO;
+
+	state_str = next_string(skb);
+	if (!state_str)
+		return -EIO;
+
+	/* Anything but 'Showtime' is down */
+	if (strcmp(state_str, "Showtime")) {
+		card->atmdev[port]->signal = ATM_PHY_SIG_LOST;
+		release_vccs(card->atmdev[port]);
+		dev_info(&card->dev->dev, "Port %d: %s\n", port, state_str);
+		return 0;
+	}
+
+	snr = next_string(skb);
+	if (!str)
+		return -EIO;
+	attn = next_string(skb);
+	if (!attn)
+		return -EIO;
+
+	dev_info(&card->dev->dev, "Port %d: %s @%d/%d kb/s%s%s%s%s\n",
+		 port, state_str, rate_down/1000, rate_up/1000,
+		 snr[0]?", SNR ":"", snr, attn[0]?", Attn ":"", attn);
+	
+	card->atmdev[port]->link_rate = rate_down / 424;
+	card->atmdev[port]->signal = ATM_PHY_SIG_FOUND;
+
+	return 0;
+}
+
+static int process_command(struct solos_card *card, int port, struct sk_buff *skb)
+{
+	struct solos_param *prm;
+	unsigned long flags;
+	int cmdpid;
+	int found = 0;
+
+	if (skb->len < 7)
+		return 0;
+
+	if (skb->data[0] != 'L'    || !isdigit(skb->data[1]) ||
+	    !isdigit(skb->data[2]) || !isdigit(skb->data[3]) ||
+	    !isdigit(skb->data[4]) || !isdigit(skb->data[5]) ||
+	    skb->data[6] != '\n')
+		return 0;
+
+	cmdpid = simple_strtol(&skb->data[1], NULL, 10);
+
+	spin_lock_irqsave(&card->param_queue_lock, flags);
+	list_for_each_entry(prm, &card->param_queue, list) {
+		if (prm->port == port && prm->pid == cmdpid) {
+			prm->response = skb;
+			skb_pull(skb, 7);
+			wake_up(&card->param_wq);
+			found = 1;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&card->param_queue_lock, flags);
+	return found;
+}
+
 static ssize_t console_show(struct device *dev, struct device_attribute *attr,
 			    char *buf)
 {
@@ -140,8 +445,6 @@ static int send_command(struct solos_card *card, int dev, const char *buf, size_
 	struct sk_buff *skb;
 	struct pkt_hdr *header;
 
-//	dev_dbg(&card->dev->dev, "size: %d\n", size);
-
 	if (size > (BUF_SIZE - sizeof(*header))) {
 		dev_dbg(&card->dev->dev, "Command is too big.  Dropping request\n");
 		return 0;
@@ -180,82 +483,181 @@ static ssize_t console_store(struct device *dev, struct device_attribute *attr,
 
 static DEVICE_ATTR(console, 0644, console_show, console_store);
 
+
+#define SOLOS_ATTR_RO(x) static DEVICE_ATTR(x, 0444, solos_param_show, NULL);
+#define SOLOS_ATTR_RW(x) static DEVICE_ATTR(x, 0644, solos_param_show, solos_param_store);
+
+#include "solos-attrlist.c"
+
+#undef SOLOS_ATTR_RO
+#undef SOLOS_ATTR_RW
+
+#define SOLOS_ATTR_RO(x) &dev_attr_##x.attr,
+#define SOLOS_ATTR_RW(x) &dev_attr_##x.attr,
+
+static struct attribute *solos_attrs[] = {
+#include "solos-attrlist.c"
+	NULL
+};
+
+static struct attribute_group solos_attr_group = {
+	.attrs = solos_attrs,
+	.name = "parameters",
+};
+
+static int flash_upgrade(struct solos_card *card, int chip)
+{
+	const struct firmware *fw;
+	const char *fw_name;
+	uint32_t data32 = 0;
+	int blocksize = 0;
+	int numblocks = 0;
+	int offset;
+
+	if (chip == 0) {
+		fw_name = "solos-FPGA.bin";
+		blocksize = FPGA_BLOCK;
+	} else {
+		fw_name = "solos-Firmware.bin";
+		blocksize = SOLOS_BLOCK;
+	}
+
+	if (request_firmware(&fw, fw_name, &card->dev->dev))
+		return -ENOENT;
+
+	dev_info(&card->dev->dev, "Flash upgrade starting\n");
+
+	numblocks = fw->size / blocksize;
+	dev_info(&card->dev->dev, "Firmware size: %zd\n", fw->size);
+	dev_info(&card->dev->dev, "Number of blocks: %d\n", numblocks);
+	
+	dev_info(&card->dev->dev, "Changing FPGA to Update mode\n");
+	iowrite32(1, card->config_regs + FPGA_MODE);
+	data32 = ioread32(card->config_regs + FPGA_MODE); 
+
+	/* Set mode to Chip Erase */
+	dev_info(&card->dev->dev, "Set FPGA Flash mode to %s Chip Erase\n",
+		 chip?"Solos":"FPGA");
+	iowrite32((chip * 2), card->config_regs + FLASH_MODE);
+
+
+	iowrite32(1, card->config_regs + WRITE_FLASH);
+	wait_event(card->fw_wq, !ioread32(card->config_regs + FLASH_BUSY));
+
+	for (offset = 0; offset < fw->size; offset += blocksize) {
+		int i;
+
+		/* Clear write flag */
+		iowrite32(0, card->config_regs + WRITE_FLASH);
+
+		/* Set mode to Block Write */
+		/* dev_info(&card->dev->dev, "Set FPGA Flash mode to Block Write\n"); */
+		iowrite32(((chip * 2) + 1), card->config_regs + FLASH_MODE);
+
+		/* Copy block to buffer, swapping each 16 bits */
+		for(i = 0; i < blocksize; i += 4) {
+			uint32_t word = swahb32p((uint32_t *)(fw->data + offset + i));
+			iowrite32(word, RX_BUF(card, 3) + i);
+		}
+
+		/* Specify block number and then trigger flash write */
+		iowrite32(offset / blocksize, card->config_regs + FLASH_BLOCK);
+		iowrite32(1, card->config_regs + WRITE_FLASH);
+		wait_event(card->fw_wq, !ioread32(card->config_regs + FLASH_BUSY));
+	}
+
+	release_firmware(fw);
+	iowrite32(0, card->config_regs + WRITE_FLASH);
+	iowrite32(0, card->config_regs + FPGA_MODE);
+	iowrite32(0, card->config_regs + FLASH_MODE);
+	dev_info(&card->dev->dev, "Returning FPGA to Data mode\n");
+	return 0;
+}
+
 static irqreturn_t solos_irq(int irq, void *dev_id)
 {
 	struct solos_card *card = dev_id;
 	int handled = 1;
 
-	//ACK IRQ
 	iowrite32(0, card->config_regs + IRQ_CLEAR);
-	//Disable IRQs from FPGA
-	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 
-	/* If we only do it when the device is open, we lose console
-	   messages */
-	if (1 || opens)
+	/* If we're up and running, just kick the tasklet to process TX/RX */
+	if (card->atmdev[0])
 		tasklet_schedule(&card->tlet);
+	else
+		wake_up(&card->fw_wq);
 
-	//Enable IRQs from FPGA
-	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
 	return IRQ_RETVAL(handled);
 }
 
 void solos_bh(unsigned long card_arg)
 {
 	struct solos_card *card = (void *)card_arg;
-	int port;
 	uint32_t card_flags;
-	uint32_t tx_mask;
 	uint32_t rx_done = 0;
+	int port;
 
-	card_flags = ioread32(card->config_regs + FLAGS_ADDR);
-
-	/* The TX bits are set if the channel is busy; clear if not. We want to
-	   invoke fpga_tx() unless _all_ the bits for active channels are set */
-	tx_mask = (1 << card->nr_ports) - 1;
-	if ((card_flags & tx_mask) != tx_mask)
-		fpga_tx(card);
+	/*
+	 * Since fpga_tx() is going to need to read the flags under its lock,
+	 * it can return them to us so that we don't have to hit PCI MMIO
+	 * again for the same information
+	 */
+	card_flags = fpga_tx(card);
 
 	for (port = 0; port < card->nr_ports; port++) {
 		if (card_flags & (0x10 << port)) {
-			struct pkt_hdr header;
+			struct pkt_hdr _hdr, *header;
 			struct sk_buff *skb;
 			struct atm_vcc *vcc;
 			int size;
 
-			rx_done |= 0x10 << port;
+			if (card->using_dma) {
+				skb = card->rx_skb[port];
+				card->rx_skb[port] = NULL;
 
-			memcpy_fromio(&header, RX_BUF(card, port), sizeof(header));
+				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
+						 RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
 
-			size = le16_to_cpu(header.size);
+				header = (void *)skb->data;
+				size = le16_to_cpu(header->size);
+				skb_put(skb, size + sizeof(*header));
+				skb_pull(skb, sizeof(*header));
+			} else {
+				header = &_hdr;
 
-			skb = alloc_skb(size, GFP_ATOMIC);
-			if (!skb) {
-				if (net_ratelimit())
-					dev_warn(&card->dev->dev, "Failed to allocate sk_buff for RX\n");
-				continue;
-			}
+				rx_done |= 0x10 << port;
+
+				memcpy_fromio(header, RX_BUF(card, port), sizeof(*header));
 
-			memcpy_fromio(skb_put(skb, size),
-				      RX_BUF(card, port) + sizeof(header),
-				      size);
+				size = le16_to_cpu(header->size);
 
+				skb = alloc_skb(size + 1, GFP_ATOMIC);
+				if (!skb) {
+					if (net_ratelimit())
+						dev_warn(&card->dev->dev, "Failed to allocate sk_buff for RX\n");
+					continue;
+				}
+
+				memcpy_fromio(skb_put(skb, size),
+					      RX_BUF(card, port) + sizeof(*header),
+					      size);
+			}
 			if (atmdebug) {
 				dev_info(&card->dev->dev, "Received: device %d\n", port);
 				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
-					 size, le16_to_cpu(header.vpi),
-					 le16_to_cpu(header.vci));
+					 size, le16_to_cpu(header->vpi),
+					 le16_to_cpu(header->vci));
 				print_buffer(skb);
 			}
 
-			switch (le16_to_cpu(header.type)) {
+			switch (le16_to_cpu(header->type)) {
 			case PKT_DATA:
-				vcc = find_vcc(card->atmdev[port], le16_to_cpu(header.vpi),
-					       le16_to_cpu(header.vci));
+				vcc = find_vcc(card->atmdev[port], le16_to_cpu(header->vpi),
+					       le16_to_cpu(header->vci));
 				if (!vcc) {
 					if (net_ratelimit())
 						dev_warn(&card->dev->dev, "Received packet for unknown VCI.VPI %d.%d on port %d\n",
-							 le16_to_cpu(header.vci), le16_to_cpu(header.vpi),
+							 le16_to_cpu(header->vci), le16_to_cpu(header->vpi),
 							 port);
 					continue;
 				}
@@ -264,19 +666,50 @@ void solos_bh(unsigned long card_arg)
 				atomic_inc(&vcc->stats->rx);
 				break;
 
+			case PKT_STATUS:
+				if (process_status(card, port, skb) &&
+				    net_ratelimit()) {
+					dev_warn(&card->dev->dev, "Bad status packet of %d bytes on port %d:\n", skb->len, port);
+					print_buffer(skb);
+				}
+				dev_kfree_skb_any(skb);
+				break;
+
 			case PKT_COMMAND:
 			default: /* FIXME: Not really, surely? */
+				if (process_command(card, port, skb))
+					break;
 				spin_lock(&card->cli_queue_lock);
 				if (skb_queue_len(&card->cli_queue[port]) > 10) {
 					if (net_ratelimit())
 						dev_warn(&card->dev->dev, "Dropping console response on port %d\n",
 							 port);
+					dev_kfree_skb_any(skb);
 				} else
 					skb_queue_tail(&card->cli_queue[port], skb);
 				spin_unlock(&card->cli_queue_lock);
 				break;
 			}
 		}
+		/* Allocate RX skbs for any ports which need them */
+		if (card->using_dma && card->atmdev[port] &&
+		    !card->rx_skb[port]) {
+			struct sk_buff *skb = alloc_skb(RX_DMA_SIZE, GFP_ATOMIC);
+			if (skb) {
+				SKB_CB(skb)->dma_addr =
+					pci_map_single(card->dev, skb->data,
+						       RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+				iowrite32(SKB_CB(skb)->dma_addr,
+					  card->config_regs + RX_DMA_ADDR(port));
+				card->rx_skb[port] = skb;
+			} else {
+				if (net_ratelimit())
+					dev_warn(&card->dev->dev, "Failed to allocate RX skb");
+
+				/* We'll have to try again later */
+				tasklet_schedule(&card->tlet);
+			}
+		}
 	}
 	if (rx_done)
 		iowrite32(rx_done, card->config_regs + FLAGS_ADDR);
@@ -326,7 +759,7 @@ static int list_vccs(int vci)
 			       vcc->vci);
 		}
 	} else {
-		for(i=0; i<32; i++){
+		for(i = 0; i < VCC_HTABLE_SIZE; i++){
 			head = &vcc_hash[i];
 			sk_for_each(s, node, head) {
 				num_found ++;
@@ -342,6 +775,28 @@ static int list_vccs(int vci)
 	return num_found;
 }
 
+static void release_vccs(struct atm_dev *dev)
+{
+        int i;
+
+        write_lock_irq(&vcc_sklist_lock);
+        for (i = 0; i < VCC_HTABLE_SIZE; i++) {
+                struct hlist_head *head = &vcc_hash[i];
+                struct hlist_node *node, *tmp;
+                struct sock *s;
+                struct atm_vcc *vcc;
+
+                sk_for_each_safe(s, node, tmp, head) {
+                        vcc = atm_sk(s);
+                        if (vcc->dev == dev) {
+                                vcc_release_async(vcc, -EPIPE);
+                                sk_del_node_init(s);
+                        }
+                }
+        }
+        write_unlock_irq(&vcc_sklist_lock);
+}
+
 
 static int popen(struct atm_vcc *vcc)
 {
@@ -349,6 +804,12 @@ static int popen(struct atm_vcc *vcc)
 	struct sk_buff *skb;
 	struct pkt_hdr *header;
 
+	if (vcc->qos.aal != ATM_AAL5) {
+		dev_warn(&card->dev->dev, "Unsupported ATM type %d\n",
+			 vcc->qos.aal);
+		return -EINVAL;
+	}
+
 	skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
 	if (!skb && net_ratelimit()) {
 		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n");
@@ -356,22 +817,17 @@ static int popen(struct atm_vcc *vcc)
 	}
 	header = (void *)skb_put(skb, sizeof(*header));
 
-	header->size = cpu_to_le16(sizeof(*header));
+	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
 	header->vci = cpu_to_le16(vcc->vci);
 	header->type = cpu_to_le16(PKT_POPEN);
 
 	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
 
-//	dev_dbg(&card->dev->dev, "Open for vpi %d and vci %d on interface %d\n", vcc->vpi, vcc->vci, SOLOS_CHAN(vcc->dev));
-	set_bit(ATM_VF_ADDR, &vcc->flags); // accept the vpi / vci
+	set_bit(ATM_VF_ADDR, &vcc->flags);
 	set_bit(ATM_VF_READY, &vcc->flags);
 	list_vccs(0);
 
-	if (!opens)
-		iowrite32(1, card->config_regs + IRQ_EN_ADDR);
-
-	opens++; //count open PVCs
 
 	return 0;
 }
@@ -389,17 +845,13 @@ static void pclose(struct atm_vcc *vcc)
 	}
 	header = (void *)skb_put(skb, sizeof(*header));
 
-	header->size = cpu_to_le16(sizeof(*header));
+	header->size = cpu_to_le16(0);
 	header->vpi = cpu_to_le16(vcc->vpi);
 	header->vci = cpu_to_le16(vcc->vci);
 	header->type = cpu_to_le16(PKT_PCLOSE);
 
 	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
 
-//	dev_dbg(&card->dev->dev, "Close for vpi %d and vci %d on interface %d\n", vcc->vpi, vcc->vci, SOLOS_CHAN(vcc->dev));
-	if (!--opens)
-		iowrite32(0, card->config_regs + IRQ_EN_ADDR);
-
 	clear_bit(ATM_VF_ADDR, &vcc->flags);
 	clear_bit(ATM_VF_READY, &vcc->flags);
 
@@ -439,22 +891,26 @@ static void fpga_queue(struct solos_card *card, int port, struct sk_buff *skb,
 		       struct atm_vcc *vcc)
 {
 	int old_len;
+	unsigned long flags;
 
-	*(void **)skb->cb = vcc;
+	SKB_CB(skb)->vcc = vcc;
 
-	spin_lock(&card->tx_queue_lock);
+	spin_lock_irqsave(&card->tx_queue_lock, flags);
 	old_len = skb_queue_len(&card->tx_queue[port]);
 	skb_queue_tail(&card->tx_queue[port], skb);
-	spin_unlock(&card->tx_queue_lock);
+	if (!old_len)
+		card->tx_mask |= (1 << port);
+	spin_unlock_irqrestore(&card->tx_queue_lock, flags);
 
-	/* If TX might need to be started, do so */
+	/* Theoretically we could just schedule the tasklet here, but
+	   that introduces latency we don't want -- it's noticeable */
 	if (!old_len)
 		fpga_tx(card);
 }
 
-static int fpga_tx(struct solos_card *card)
+static uint32_t fpga_tx(struct solos_card *card)
 {
-	uint32_t tx_pending;
+	uint32_t tx_pending, card_flags;
 	uint32_t tx_started = 0;
 	struct sk_buff *skb;
 	struct atm_vcc *vcc;
@@ -462,69 +918,77 @@ static int fpga_tx(struct solos_card *card)
 	unsigned long flags;
 
 	spin_lock_irqsave(&card->tx_lock, flags);
-
-	tx_pending = ioread32(card->config_regs + FLAGS_ADDR);
-
-	dev_vdbg(&card->dev->dev, "TX Flags are %X\n", tx_pending);
-
-	for (port = 0; port < card->nr_ports; port++) {
-		if (!(tx_pending & (1 << port))) {
+	
+	card_flags = ioread32(card->config_regs + FLAGS_ADDR);
+	/*
+	 * The queue lock is required for _writing_ to tx_mask, but we're
+	 * OK to read it here without locking. The only potential update
+	 * that we could race with is in fpga_queue() where it sets a bit
+	 * for a new port... but it's going to call this function again if
+	 * it's doing that, anyway.
+	 */
+	tx_pending = card->tx_mask & ~card_flags;
+
+	for (port = 0; tx_pending; tx_pending >>= 1, port++) {
+		if (tx_pending & 1) {
+			struct sk_buff *oldskb = card->tx_skb[port];
+			if (oldskb)
+				pci_unmap_single(card->dev, SKB_CB(oldskb)->dma_addr,
+						 oldskb->len, PCI_DMA_TODEVICE);
 
 			spin_lock(&card->tx_queue_lock);
 			skb = skb_dequeue(&card->tx_queue[port]);
+			if (!skb)
+				card->tx_mask &= ~(1 << port);
 			spin_unlock(&card->tx_queue_lock);
 
-			if (!skb)
+			if (skb && !card->using_dma) {
+				memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
+				tx_started |= 1 << port;
+				oldskb = skb; /* We're done with this skb already */
+			} else if (skb && card->using_dma) {
+				SKB_CB(skb)->dma_addr = pci_map_single(card->dev, skb->data,
+								       skb->len, PCI_DMA_TODEVICE);
+				iowrite32(SKB_CB(skb)->dma_addr,
+					  card->config_regs + TX_DMA_ADDR(port));
+			}
+
+			if (!oldskb)
 				continue;
 
+			/* Clean up and free oldskb now it's gone */
 			if (atmdebug) {
 				dev_info(&card->dev->dev, "Transmitted: port %d\n",
 					 port);
-				print_buffer(skb);
+				print_buffer(oldskb);
 			}
-			memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
 
-			vcc = *(void **)skb->cb;
+			vcc = SKB_CB(oldskb)->vcc;
 
 			if (vcc) {
 				atomic_inc(&vcc->stats->tx);
-				solos_pop(vcc, skb);
+				solos_pop(vcc, oldskb);
 			} else
-				dev_kfree_skb_irq(skb);
+				dev_kfree_skb_irq(oldskb);
 
-			tx_started |= 1 << port; //Set TX full flag
 		}
 	}
+	/* For non-DMA TX, write the 'TX start' bit for all four ports simultaneously */
 	if (tx_started)
 		iowrite32(tx_started, card->config_regs + FLAGS_ADDR);
 
 	spin_unlock_irqrestore(&card->tx_lock, flags);
-	return 0;
+	return card_flags;
 }
 
 static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct solos_card *card = vcc->dev->dev_data;
-	struct sk_buff *skb2 = NULL;
 	struct pkt_hdr *header;
+	int pktlen;
 
-	//dev_dbg(&card->dev->dev, "psend called.\n");
-	//dev_dbg(&card->dev->dev, "dev,vpi,vci = %d,%d,%d\n",SOLOS_CHAN(vcc->dev),vcc->vpi,vcc->vci);
-
-	if (debug) {
-		skb2 = atm_alloc_charge(vcc, skb->len, GFP_ATOMIC);
-		if (skb2) {
-			memcpy(skb2->data, skb->data, skb->len);
-			skb_put(skb2, skb->len);
-			vcc->push(vcc, skb2);
-			atomic_inc(&vcc->stats->rx);
-		}
-		atomic_inc(&vcc->stats->tx);
-		solos_pop(vcc, skb);
-		return 0;
-	}
-
-	if (skb->len > (BUF_SIZE - sizeof(*header))) {
+	pktlen = skb->len;
+	if (pktlen > (BUF_SIZE - sizeof(*header))) {
 		dev_warn(&card->dev->dev, "Length of PDU is too large. Dropping PDU.\n");
 		solos_pop(vcc, skb);
 		return 0;
@@ -539,6 +1003,7 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 
 		ret = pskb_expand_head(skb, expand_by, 0, GFP_ATOMIC);
 		if (ret) {
+			dev_warn(&card->dev->dev, "pskb_expand_head failed.\n");
 			solos_pop(vcc, skb);
 			return ret;
 		}
@@ -546,7 +1011,8 @@ static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
 
 	header = (void *)skb_push(skb, sizeof(*header));
 
-	header->size = cpu_to_le16(skb->len);
+	/* This does _not_ include the size of the header */
+	header->size = cpu_to_le16(pktlen);
 	header->vpi = cpu_to_le16(vcc->vpi);
 	header->vci = cpu_to_le16(vcc->vci);
 	header->type = cpu_to_le16(PKT_DATA);
@@ -573,20 +1039,19 @@ static struct atmdev_ops fpga_ops = {
 
 static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 {
-	int err, i;
+	int err;
 	uint16_t fpga_ver;
 	uint8_t major_ver, minor_ver;
 	uint32_t data32;
 	struct solos_card *card;
 
-	if (debug)
-		return 0;
-
 	card = kzalloc(sizeof(*card), GFP_KERNEL);
 	if (!card)
 		return -ENOMEM;
 
 	card->dev = dev;
+	init_waitqueue_head(&card->fw_wq);
+	init_waitqueue_head(&card->param_wq);
 
 	err = pci_enable_device(dev);
 	if (err) {
@@ -594,6 +1059,12 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out;
 	}
 
+	err = pci_set_dma_mask(dev, DMA_32BIT_MASK);
+	if (err) {
+		dev_warn(&dev->dev, "Failed to set 32-bit DMA mask\n");
+		goto out;
+	}
+
 	err = pci_request_regions(dev, "solos");
 	if (err) {
 		dev_warn(&dev->dev, "Failed to request regions\n");
@@ -611,17 +1082,13 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 		goto out_unmap_config;
 	}
 
-//	for(i=0;i<64 ;i+=4){
-//		data32=ioread32(card->buffers + i);
-//		dev_dbg(&card->dev->dev, "%08lX\n",(unsigned long)data32);
-//	}
-
-	//Fill Config Mem with zeros
-	for(i = 0; i < 128; i += 4)
-		iowrite32(0, card->config_regs + i);
+	if (reset) {
+		iowrite32(1, card->config_regs + FPGA_MODE);
+		data32 = ioread32(card->config_regs + FPGA_MODE); 
 
-	//Set RX empty flags
-	iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
+		iowrite32(0, card->config_regs + FPGA_MODE);
+		data32 = ioread32(card->config_regs + FPGA_MODE); 
+	}
 
 	data32 = ioread32(card->config_regs + FPGA_VER);
 	fpga_ver = (data32 & 0x0000FFFF);
@@ -630,55 +1097,53 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	dev_info(&dev->dev, "Solos FPGA Version %d.%02d svn-%d\n",
 		 major_ver, minor_ver, fpga_ver);
 
-	card->nr_ports = 2; /* FIXME: Detect daughterboard */
+	if (0 && fpga_ver > 27)
+		card->using_dma = 1;
+	else {
+		/* Set RX empty flag for all ports */
+		iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
+	}
 
-	err = atm_init(card);
-	if (err)
-		goto out_unmap_both;
+	data32 = ioread32(card->config_regs + PORTS);
+	card->nr_ports = (data32 & 0x000000FF);
 
 	pci_set_drvdata(dev, card);
+
 	tasklet_init(&card->tlet, solos_bh, (unsigned long)card);
 	spin_lock_init(&card->tx_lock);
 	spin_lock_init(&card->tx_queue_lock);
 	spin_lock_init(&card->cli_queue_lock);
-/*
-	// Set Loopback mode
-	data32 = 0x00010000;
-	iowrite32(data32,card->config_regs + FLAGS_ADDR);
-*/
-/*
-	// Fill Buffers with zeros
-	for (i = 0; i < BUF_SIZE * 8; i += 4)
-		iowrite32(0, card->buffers + i);
-*/
-/*
-	for(i = 0; i < (BUF_SIZE * 1); i += 4)
-		iowrite32(0x12345678, card->buffers + i + (0*BUF_SIZE));
-	for(i = 0; i < (BUF_SIZE * 1); i += 4)
-		iowrite32(0xabcdef98, card->buffers + i + (1*BUF_SIZE));
-
-	// Read Config Memory
-	printk(KERN_DEBUG "Reading Config MEM\n");
-	i = 0;
-	for(i = 0; i < 16; i++) {
-		data32=ioread32(card->buffers + i*(BUF_SIZE/2));
-		printk(KERN_ALERT "Addr: %lX Data: %08lX\n",
-		       (unsigned long)(addr_start + i*(BUF_SIZE/2)),
-		       (unsigned long)data32);
-	}
-*/
-	//dev_dbg(&card->dev->dev, "Requesting IRQ: %d\n",dev->irq);
-	err = request_irq(dev->irq, solos_irq, IRQF_DISABLED|IRQF_SHARED,
+	spin_lock_init(&card->param_queue_lock);
+	INIT_LIST_HEAD(&card->param_queue);
+
+	err = request_irq(dev->irq, solos_irq, IRQF_SHARED,
 			  "solos-pci", card);
-	if (err)
+	if (err) {
 		dev_dbg(&card->dev->dev, "Failed to request interrupt IRQ: %d\n", dev->irq);
+		goto out_unmap_both;
+	}
 
-	// Enable IRQs
 	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
 
+	if (fpga_upgrade)
+		flash_upgrade(card, 0);
+
+	if (firmware_upgrade)
+		flash_upgrade(card, 1);
+
+	err = atm_init(card);
+	if (err)
+		goto out_free_irq;
+
 	return 0;
 
+ out_free_irq:
+	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
+	free_irq(dev->irq, card);
+	tasklet_kill(&card->tlet);
+	
  out_unmap_both:
+	pci_set_drvdata(dev, NULL);
 	pci_iounmap(dev, card->config_regs);
  out_unmap_config:
 	pci_iounmap(dev, card->buffers);
@@ -692,9 +1157,10 @@ static int atm_init(struct solos_card *card)
 {
 	int i;
 
-	opens = 0;
-
 	for (i = 0; i < card->nr_ports; i++) {
+		struct sk_buff *skb;
+		struct pkt_hdr *header;
+
 		skb_queue_head_init(&card->tx_queue[i]);
 		skb_queue_head_init(&card->cli_queue[i]);
 
@@ -706,6 +1172,8 @@ static int atm_init(struct solos_card *card)
 		}
 		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_console))
 			dev_err(&card->dev->dev, "Could not register console for ATM device %d\n", i);
+		if (sysfs_create_group(&card->atmdev[i]->class_dev.kobj, &solos_attr_group))
+			dev_err(&card->dev->dev, "Could not register parameter group for ATM device %d\n", i);
 
 		dev_info(&card->dev->dev, "Registered ATM device %d\n", card->atmdev[i]->number);
 
@@ -713,6 +1181,22 @@ static int atm_init(struct solos_card *card)
 		card->atmdev[i]->ci_range.vci_bits = 16;
 		card->atmdev[i]->dev_data = card;
 		card->atmdev[i]->phy_data = (void *)(unsigned long)i;
+		card->atmdev[i]->signal = ATM_PHY_SIG_UNKNOWN;
+
+		skb = alloc_skb(sizeof(*header), GFP_ATOMIC);
+		if (!skb) {
+			dev_warn(&card->dev->dev, "Failed to allocate sk_buff in atm_init()\n");
+			continue;
+		}
+
+		header = (void *)skb_put(skb, sizeof(*header));
+
+		header->size = cpu_to_le16(0);
+		header->vpi = cpu_to_le16(0);
+		header->vci = cpu_to_le16(0);
+		header->type = cpu_to_le16(PKT_STATUS);
+
+		fpga_queue(card, i, skb, NULL);
 	}
 	return 0;
 }
@@ -723,8 +1207,28 @@ static void atm_remove(struct solos_card *card)
 
 	for (i = 0; i < card->nr_ports; i++) {
 		if (card->atmdev[i]) {
+			struct sk_buff *skb;
+
 			dev_info(&card->dev->dev, "Unregistering ATM device %d\n", card->atmdev[i]->number);
+
+			sysfs_remove_group(&card->atmdev[i]->class_dev.kobj, &solos_attr_group);
 			atm_dev_deregister(card->atmdev[i]);
+
+			skb = card->rx_skb[i];
+			if (skb) {
+				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
+						 RX_DMA_SIZE, PCI_DMA_FROMDEVICE);
+				dev_kfree_skb(skb);
+			}
+			skb = card->tx_skb[i];
+			if (skb) {
+				pci_unmap_single(card->dev, SKB_CB(skb)->dma_addr,
+						 skb->len, PCI_DMA_TODEVICE);
+				dev_kfree_skb(skb);
+			}
+			while ((skb = skb_dequeue(&card->tx_queue[i])))
+				dev_kfree_skb(skb);
+ 
 		}
 	}
 }
@@ -732,31 +1236,31 @@ static void atm_remove(struct solos_card *card)
 static void fpga_remove(struct pci_dev *dev)
 {
 	struct solos_card *card = pci_get_drvdata(dev);
+	
+	/* Disable IRQs */
+	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 
-	if (debug)
-		return;
+	/* Reset FPGA */
+	iowrite32(1, card->config_regs + FPGA_MODE);
+	(void)ioread32(card->config_regs + FPGA_MODE); 
 
 	atm_remove(card);
 
-	dev_vdbg(&dev->dev, "Freeing IRQ\n");
-	// Disable IRQs from FPGA
-	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
 	free_irq(dev->irq, card);
 	tasklet_kill(&card->tlet);
 
-	//	iowrite32(0x01,pciregs);
-	dev_vdbg(&dev->dev, "Unmapping PCI resource\n");
+	/* Release device from reset */
+	iowrite32(0, card->config_regs + FPGA_MODE);
+	(void)ioread32(card->config_regs + FPGA_MODE); 
+
 	pci_iounmap(dev, card->buffers);
 	pci_iounmap(dev, card->config_regs);
 
-	dev_vdbg(&dev->dev, "Releasing PCI Region\n");
 	pci_release_regions(dev);
 	pci_disable_device(dev);
 
 	pci_set_drvdata(dev, NULL);
 	kfree(card);
-//	dev_dbg(&card->dev->dev, "fpga_remove\n");
-	return;
 }
 
 static struct pci_device_id fpga_pci_tbl[] __devinitdata = {
diff --git a/drivers/atm/solos-attrlist.c b/drivers/atm/solos-attrlist.c
new file mode 100644
index 0000000..efa2808
--- /dev/null
+++ b/drivers/atm/solos-attrlist.c
@@ -0,0 +1,70 @@
+SOLOS_ATTR_RO(DriverVersion)
+SOLOS_ATTR_RO(APIVersion)
+SOLOS_ATTR_RO(FirmwareVersion)
+// SOLOS_ATTR_RO(DspVersion)
+// SOLOS_ATTR_RO(CommonHandshake)
+SOLOS_ATTR_RO(Connected)
+SOLOS_ATTR_RO(OperationalMode)
+SOLOS_ATTR_RO(State)
+SOLOS_ATTR_RO(Watchdog)
+SOLOS_ATTR_RO(OperationProgress)
+SOLOS_ATTR_RO(LastFailed)
+SOLOS_ATTR_RO(TxBitRate)
+SOLOS_ATTR_RO(RxBitRate)
+// SOLOS_ATTR_RO(DeltACTATPds)
+// SOLOS_ATTR_RO(DeltACTATPus)
+SOLOS_ATTR_RO(TxATTNDR)
+SOLOS_ATTR_RO(RxATTNDR)
+SOLOS_ATTR_RO(AnnexType)
+SOLOS_ATTR_RO(GeneralFailure)
+SOLOS_ATTR_RO(InterleaveDpDn)
+SOLOS_ATTR_RO(InterleaveDpUp)
+SOLOS_ATTR_RO(RSCorrectedErrorsDn)
+SOLOS_ATTR_RO(RSUnCorrectedErrorsDn)
+SOLOS_ATTR_RO(RSCorrectedErrorsUp)
+SOLOS_ATTR_RO(RSUnCorrectedErrorsUp)
+SOLOS_ATTR_RO(InterleaveRDn)
+SOLOS_ATTR_RO(InterleaveRUp)
+SOLOS_ATTR_RO(ShowtimeStart)
+SOLOS_ATTR_RO(ATURVendor)
+SOLOS_ATTR_RO(ATUCCountry)
+SOLOS_ATTR_RO(ATURANSIRev)
+SOLOS_ATTR_RO(ATURANSISTD)
+SOLOS_ATTR_RO(ATUCANSIRev)
+SOLOS_ATTR_RO(ATUCANSIId)
+SOLOS_ATTR_RO(ATUCANSISTD)
+SOLOS_ATTR_RO(DataBoost)
+SOLOS_ATTR_RO(LocalITUCountryCode)
+SOLOS_ATTR_RO(LocalSEF)
+SOLOS_ATTR_RO(LocalEndLOS)
+SOLOS_ATTR_RO(LocalSNRMargin)
+SOLOS_ATTR_RO(LocalLineAttn)
+SOLOS_ATTR_RO(RawAttn)
+SOLOS_ATTR_RO(LocalTxPower)
+SOLOS_ATTR_RO(RemoteTxPower)
+SOLOS_ATTR_RO(RemoteSEF)
+SOLOS_ATTR_RO(RemoteLOS)
+SOLOS_ATTR_RO(RemoteLineAttn)
+SOLOS_ATTR_RO(RemoteSNRMargin)
+SOLOS_ATTR_RO(LineUpCount)
+SOLOS_ATTR_RO(SRACnt)
+SOLOS_ATTR_RO(SRACntUp)
+SOLOS_ATTR_RO(ProfileStatus)
+SOLOS_ATTR_RW(Action)
+SOLOS_ATTR_RW(ActivateLine)
+SOLOS_ATTR_RO(LineStatus)
+SOLOS_ATTR_RW(HostControl)
+SOLOS_ATTR_RW(AutoStart)
+SOLOS_ATTR_RW(Failsafe)
+SOLOS_ATTR_RW(ShowtimeLed)
+SOLOS_ATTR_RW(Retrain)
+SOLOS_ATTR_RW(Defaults)
+SOLOS_ATTR_RW(LineMode)
+SOLOS_ATTR_RW(Profile)
+SOLOS_ATTR_RW(DetectNoise)
+SOLOS_ATTR_RO(SupportedAnnexes)
+SOLOS_ATTR_RO(Status)
+SOLOS_ATTR_RO(TotalStart)
+SOLOS_ATTR_RO(RecentShowtimeStart)
+SOLOS_ATTR_RO(TotalRxBlocks)
+SOLOS_ATTR_RO(TotalTxBlocks)

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation

