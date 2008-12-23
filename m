From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH] Driver for Solos PCI ADSL2+ card.
Date: Tue, 23 Dec 2008 14:09:02 +0000
Message-ID: <1230041343.22786.441.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Nathan Williams <nathan@traverse.com.au>,
	Guy Ellis <guy@traverse.com.au>, Danny@xrio.com
To: linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43840 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbYLWOJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Dec 2008 09:09:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds basic support for the 'Solos' PCI ADSL2+ cards being develope=
d
by Traverse Technologies and Xrio Ltd:
http://www.traverse.com.au/productview.php?product_id=3D116

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---=20

There are some improvements to come -- an FPGA update will add DMA
support, and a few other things. But since the cards are now coming off
the production line and being shipped, it's worth getting the functiona=
l
driver upstream...

Development tree at {http://,git://}
	git.infradead.org/users/dwmw2/solos-2.6.git

diff --git a/drivers/atm/Kconfig b/drivers/atm/Kconfig
index f197a19..191b85e 100644
--- a/drivers/atm/Kconfig
+++ b/drivers/atm/Kconfig
@@ -391,4 +391,10 @@ config ATM_HE_USE_SUNI
 	  Support for the S/UNI-Ultra and S/UNI-622 found in the ForeRunner
 	  HE cards.  This driver provides carrier detection some statistics.
=20
+config ATM_SOLOS
+	tristate "Solos ADSL2+ PCI Multiport card driver"
+	depends on PCI
+	help
+	  Support for the Solos multiport ADSL2+ card.
+
 endif # ATM
diff --git a/drivers/atm/Makefile b/drivers/atm/Makefile
index 0bfb317..62c3cc1 100644
--- a/drivers/atm/Makefile
+++ b/drivers/atm/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_ATM_IA)		+=3D iphase.o suni.o
 obj-$(CONFIG_ATM_FORE200E)	+=3D fore_200e.o
 obj-$(CONFIG_ATM_ENI)		+=3D eni.o suni.o
 obj-$(CONFIG_ATM_IDT77252)	+=3D idt77252.o
+obj-$(CONFIG_ATM_SOLOS)		+=3D solos-pci.o
=20
 ifeq ($(CONFIG_ATM_NICSTAR_USE_SUNI),y)
   obj-$(CONFIG_ATM_NICSTAR)	+=3D suni.o
diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
new file mode 100644
index 0000000..e222ffb
--- /dev/null
+++ b/drivers/atm/solos-pci.c
@@ -0,0 +1,790 @@
+/*
+ * Driver for the Solos PCI ADSL2+ card, designed to support Linux by
+ *  Traverse Technologies -- http://www.traverse.com.au/
+ *  Xrio Limited          -- http://www.xrio.com/
+ *
+ *
+ * Copyright =C2=A9 2008 Traverse Technologies
+ * Copyright =C2=A9 2008 Intel Corporation
+ *
+ * Authors: Nathan Williams <nathan@traverse.com.au>
+ *          David Woodhouse <dwmw2@infradead.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#define DEBUG
+#define VERBOSE_DEBUG
+
+#include <linux/interrupt.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/ioport.h>
+#include <linux/types.h>
+#include <linux/pci.h>
+#include <linux/atm.h>
+#include <linux/atmdev.h>
+#include <linux/skbuff.h>
+#include <linux/sysfs.h>
+#include <linux/device.h>
+#include <linux/kobject.h>
+
+#define VERSION "0.04"
+#define PTAG "solos-pci"
+
+#define CONFIG_RAM_SIZE	128
+#define FLAGS_ADDR	0x7C
+#define IRQ_EN_ADDR	0x78
+#define FPGA_VER	0x74
+#define IRQ_CLEAR	0x70
+#define BUG_FLAG	0x6C
+
+#define DATA_RAM_SIZE	32768
+#define BUF_SIZE	4096
+
+#define RX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2)
+#define TX_BUF(card, nr) ((card->buffers) + (nr)*BUF_SIZE*2 + BUF_SIZE=
)
+
+static int debug =3D 0;
+static int atmdebug =3D 0;
+
+struct pkt_hdr {
+	__le16 size;
+	__le16 vpi;
+	__le16 vci;
+	__le16 type;
+};
+
+#define PKT_DATA	0
+#define PKT_COMMAND	1
+#define PKT_POPEN	3
+#define PKT_PCLOSE	4
+
+struct solos_card {
+	void __iomem *config_regs;
+	void __iomem *buffers;
+	int nr_ports;
+	struct pci_dev *dev;
+	struct atm_dev *atmdev[4];
+	struct tasklet_struct tlet;
+	spinlock_t tx_lock;
+	spinlock_t tx_queue_lock;
+	spinlock_t cli_queue_lock;
+	struct sk_buff_head tx_queue[4];
+	struct sk_buff_head cli_queue[4];
+};
+
+#define SOLOS_CHAN(atmdev) ((int)(unsigned long)(atmdev)->phy_data)
+
+MODULE_AUTHOR("Traverse Technologies <support@traverse.com.au>");
+MODULE_DESCRIPTION("Solos PCI driver");
+MODULE_VERSION(VERSION);
+MODULE_LICENSE("GPL");
+MODULE_PARM_DESC(debug, "Enable Loopback");
+MODULE_PARM_DESC(atmdebug, "Print ATM data");
+module_param(debug, int, 0444);
+module_param(atmdebug, int, 0444);
+
+static int opens;
+
+static void fpga_queue(struct solos_card *card, int port, struct sk_bu=
ff *skb,
+		       struct atm_vcc *vcc);
+static int fpga_tx(struct solos_card *);
+static irqreturn_t solos_irq(int irq, void *dev_id);
+static struct atm_vcc* find_vcc(struct atm_dev *dev, short vpi, int vc=
i);
+static int list_vccs(int vci);
+static int atm_init(struct solos_card *);
+static void atm_remove(struct solos_card *);
+static int send_command(struct solos_card *card, int dev, const char *=
buf, size_t size);
+static void solos_bh(unsigned long);
+static int print_buffer(struct sk_buff *buf);
+
+static inline void solos_pop(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+        if (vcc->pop)
+                vcc->pop(vcc, skb);
+        else
+                dev_kfree_skb_any(skb);
+}
+
+static ssize_t console_show(struct device *dev, struct device_attribut=
e *attr,
+			    char *buf)
+{
+	struct atm_dev *atmdev =3D container_of(dev, struct atm_dev, class_de=
v);
+	struct solos_card *card =3D atmdev->dev_data;
+	struct sk_buff *skb;
+
+	spin_lock(&card->cli_queue_lock);
+	skb =3D skb_dequeue(&card->cli_queue[SOLOS_CHAN(atmdev)]);
+	spin_unlock(&card->cli_queue_lock);
+	if(skb =3D=3D NULL)
+		return sprintf(buf, "No data.\n");
+
+	memcpy(buf, skb->data, skb->len);
+	dev_dbg(&card->dev->dev, "len: %d\n", skb->len);
+
+	kfree_skb(skb);
+	return skb->len;
+}
+
+static int send_command(struct solos_card *card, int dev, const char *=
buf, size_t size)
+{
+	struct sk_buff *skb;
+	struct pkt_hdr *header;
+
+//	dev_dbg(&card->dev->dev, "size: %d\n", size);
+
+	if (size > (BUF_SIZE - sizeof(*header))) {
+		dev_dbg(&card->dev->dev, "Command is too big.  Dropping request\n");
+		return 0;
+	}
+	skb =3D alloc_skb(size + sizeof(*header), GFP_ATOMIC);
+	if (!skb) {
+		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in send_comman=
d()\n");
+		return 0;
+	}
+
+	header =3D (void *)skb_put(skb, sizeof(*header));
+
+	header->size =3D cpu_to_le16(size);
+	header->vpi =3D cpu_to_le16(0);
+	header->vci =3D cpu_to_le16(0);
+	header->type =3D cpu_to_le16(PKT_COMMAND);
+
+	memcpy(skb_put(skb, size), buf, size);
+
+	fpga_queue(card, dev, skb, NULL);
+
+	return 0;
+}
+
+static ssize_t console_store(struct device *dev, struct device_attribu=
te *attr,
+			     const char *buf, size_t count)
+{
+	struct atm_dev *atmdev =3D container_of(dev, struct atm_dev, class_de=
v);
+	struct solos_card *card =3D atmdev->dev_data;
+	int err;
+
+	err =3D send_command(card, SOLOS_CHAN(atmdev), buf, count);
+
+	return err?:count;
+}
+
+static DEVICE_ATTR(console, 0644, console_show, console_store);
+
+static irqreturn_t solos_irq(int irq, void *dev_id)
+{
+	struct solos_card *card =3D dev_id;
+	int handled =3D 1;
+
+	//ACK IRQ
+	iowrite32(0, card->config_regs + IRQ_CLEAR);
+	//Disable IRQs from FPGA
+	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
+
+	/* If we only do it when the device is open, we lose console
+	   messages */
+	if (1 || opens)
+		tasklet_schedule(&card->tlet);
+
+	//Enable IRQs from FPGA
+	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
+	return IRQ_RETVAL(handled);
+}
+
+void solos_bh(unsigned long card_arg)
+{
+	struct solos_card *card =3D (void *)card_arg;
+	int port;
+	uint32_t card_flags;
+	uint32_t tx_mask;
+	uint32_t rx_done =3D 0;
+
+	card_flags =3D ioread32(card->config_regs + FLAGS_ADDR);
+
+	/* The TX bits are set if the channel is busy; clear if not. We want =
to
+	   invoke fpga_tx() unless _all_ the bits for active channels are set=
 */
+	tx_mask =3D (1 << card->nr_ports) - 1;
+	if ((card_flags & tx_mask) !=3D tx_mask)
+		fpga_tx(card);
+
+	for (port =3D 0; port < card->nr_ports; port++) {
+		if (card_flags & (0x10 << port)) {
+			struct pkt_hdr header;
+			struct sk_buff *skb;
+			struct atm_vcc *vcc;
+			int size;
+
+			rx_done |=3D 0x10 << port;
+
+			memcpy_fromio(&header, RX_BUF(card, port), sizeof(header));
+
+			size =3D le16_to_cpu(header.size);
+
+			skb =3D alloc_skb(size, GFP_ATOMIC);
+			if (!skb) {
+				if (net_ratelimit())
+					dev_warn(&card->dev->dev, "Failed to allocate sk_buff for RX\n");
+				continue;
+			}
+
+			memcpy_fromio(skb_put(skb, size),
+				      RX_BUF(card, port) + sizeof(header),
+				      size);
+
+			if (atmdebug) {
+				dev_info(&card->dev->dev, "Received: device %d\n", port);
+				dev_info(&card->dev->dev, "size: %d VPI: %d VCI: %d\n",
+					 size, le16_to_cpu(header.vpi),
+					 le16_to_cpu(header.vci));
+				print_buffer(skb);
+			}
+
+			switch (le16_to_cpu(header.type)) {
+			case PKT_DATA:
+				vcc =3D find_vcc(card->atmdev[port], le16_to_cpu(header.vpi),
+					       le16_to_cpu(header.vci));
+				if (!vcc) {
+					if (net_ratelimit())
+						dev_warn(&card->dev->dev, "Received packet for unknown VCI.VPI %=
d.%d on port %d\n",
+							 le16_to_cpu(header.vci), le16_to_cpu(header.vpi),
+							 port);
+					continue;
+				}
+				atm_charge(vcc, skb->truesize);
+				vcc->push(vcc, skb);
+				atomic_inc(&vcc->stats->rx);
+				break;
+
+			case PKT_COMMAND:
+			default: /* FIXME: Not really, surely? */
+				spin_lock(&card->cli_queue_lock);
+				if (skb_queue_len(&card->cli_queue[port]) > 10) {
+					if (net_ratelimit())
+						dev_warn(&card->dev->dev, "Dropping console response on port %d\=
n",
+							 port);
+				} else
+					skb_queue_tail(&card->cli_queue[port], skb);
+				spin_unlock(&card->cli_queue_lock);
+				break;
+			}
+		}
+	}
+	if (rx_done)
+		iowrite32(rx_done, card->config_regs + FLAGS_ADDR);
+
+	return;
+}
+
+static struct atm_vcc *find_vcc(struct atm_dev *dev, short vpi, int vc=
i)
+{
+	struct hlist_head *head;
+	struct atm_vcc *vcc =3D NULL;
+	struct hlist_node *node;
+	struct sock *s;
+
+	read_lock(&vcc_sklist_lock);
+	head =3D &vcc_hash[vci & (VCC_HTABLE_SIZE -1)];
+	sk_for_each(s, node, head) {
+		vcc =3D atm_sk(s);
+		if (vcc->dev =3D=3D dev && vcc->vci =3D=3D vci &&
+		    vcc->vpi =3D=3D vpi && vcc->qos.rxtp.traffic_class !=3D ATM_NONE=
)
+			goto out;
+	}
+	vcc =3D NULL;
+ out:
+	read_unlock(&vcc_sklist_lock);
+	return vcc;
+}
+
+static int list_vccs(int vci)
+{
+	struct hlist_head *head;
+	struct atm_vcc *vcc;
+	struct hlist_node *node;
+	struct sock *s;
+	int num_found =3D 0;
+	int i;
+
+	read_lock(&vcc_sklist_lock);
+	if (vci !=3D 0){
+		head =3D &vcc_hash[vci & (VCC_HTABLE_SIZE -1)];
+		sk_for_each(s, node, head) {
+			num_found ++;
+			vcc =3D atm_sk(s);
+			printk(KERN_DEBUG "Device: %d Vpi: %d Vci: %d\n",
+			       vcc->dev->number,
+			       vcc->vpi,
+			       vcc->vci);
+		}
+	} else {
+		for(i=3D0; i<32; i++){
+			head =3D &vcc_hash[i];
+			sk_for_each(s, node, head) {
+				num_found ++;
+	 			vcc =3D atm_sk(s);
+				printk(KERN_DEBUG "Device: %d Vpi: %d Vci: %d\n",
+				       vcc->dev->number,
+				       vcc->vpi,
+				       vcc->vci);
+		 	}
+		}
+	}
+	read_unlock(&vcc_sklist_lock);
+	return num_found;
+}
+
+
+static int popen(struct atm_vcc *vcc)
+{
+	struct solos_card *card =3D vcc->dev->dev_data;
+	struct sk_buff *skb;
+	struct pkt_hdr *header;
+
+	skb =3D alloc_skb(sizeof(*header), GFP_ATOMIC);
+	if (!skb && net_ratelimit()) {
+		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in popen()\n")=
;
+		return -ENOMEM;
+	}
+	header =3D (void *)skb_put(skb, sizeof(*header));
+
+	header->size =3D cpu_to_le16(sizeof(*header));
+	header->vpi =3D cpu_to_le16(vcc->vpi);
+	header->vci =3D cpu_to_le16(vcc->vci);
+	header->type =3D cpu_to_le16(PKT_POPEN);
+
+	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
+
+//	dev_dbg(&card->dev->dev, "Open for vpi %d and vci %d on interface %=
d\n", vcc->vpi, vcc->vci, SOLOS_CHAN(vcc->dev));
+	set_bit(ATM_VF_ADDR, &vcc->flags); // accept the vpi / vci
+	set_bit(ATM_VF_READY, &vcc->flags);
+	list_vccs(0);
+
+	if (!opens)
+		iowrite32(1, card->config_regs + IRQ_EN_ADDR);
+
+	opens++; //count open PVCs
+
+	return 0;
+}
+
+static void pclose(struct atm_vcc *vcc)
+{
+	struct solos_card *card =3D vcc->dev->dev_data;
+	struct sk_buff *skb;
+	struct pkt_hdr *header;
+
+	skb =3D alloc_skb(sizeof(*header), GFP_ATOMIC);
+	if (!skb) {
+		dev_warn(&card->dev->dev, "Failed to allocate sk_buff in pclose()\n"=
);
+		return;
+	}
+	header =3D (void *)skb_put(skb, sizeof(*header));
+
+	header->size =3D cpu_to_le16(sizeof(*header));
+	header->vpi =3D cpu_to_le16(vcc->vpi);
+	header->vci =3D cpu_to_le16(vcc->vci);
+	header->type =3D cpu_to_le16(PKT_PCLOSE);
+
+	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, NULL);
+
+//	dev_dbg(&card->dev->dev, "Close for vpi %d and vci %d on interface =
%d\n", vcc->vpi, vcc->vci, SOLOS_CHAN(vcc->dev));
+	if (!--opens)
+		iowrite32(0, card->config_regs + IRQ_EN_ADDR);
+
+	clear_bit(ATM_VF_ADDR, &vcc->flags);
+	clear_bit(ATM_VF_READY, &vcc->flags);
+
+	return;
+}
+
+static int print_buffer(struct sk_buff *buf)
+{
+	int len,i;
+	char msg[500];
+	char item[10];
+
+	len =3D buf->len;
+	for (i =3D 0; i < len; i++){
+		if(i % 8 =3D=3D 0)
+			sprintf(msg, "%02X: ", i);
+
+		sprintf(item,"%02X ",*(buf->data + i));
+		strcat(msg, item);
+		if(i % 8 =3D=3D 7) {
+			sprintf(item, "\n");
+			strcat(msg, item);
+			printk(KERN_DEBUG "%s", msg);
+		}
+	}
+	if (i % 8 !=3D 0) {
+		sprintf(item, "\n");
+		strcat(msg, item);
+		printk(KERN_DEBUG "%s", msg);
+	}
+	printk(KERN_DEBUG "\n");
+
+	return 0;
+}
+
+static void fpga_queue(struct solos_card *card, int port, struct sk_bu=
ff *skb,
+		       struct atm_vcc *vcc)
+{
+	int old_len;
+
+	*(void **)skb->cb =3D vcc;
+
+	spin_lock(&card->tx_queue_lock);
+	old_len =3D skb_queue_len(&card->tx_queue[port]);
+	skb_queue_tail(&card->tx_queue[port], skb);
+	spin_unlock(&card->tx_queue_lock);
+
+	/* If TX might need to be started, do so */
+	if (!old_len)
+		fpga_tx(card);
+}
+
+static int fpga_tx(struct solos_card *card)
+{
+	uint32_t tx_pending;
+	uint32_t tx_started =3D 0;
+	struct sk_buff *skb;
+	struct atm_vcc *vcc;
+	unsigned char port;
+	unsigned long flags;
+
+	spin_lock_irqsave(&card->tx_lock, flags);
+
+	tx_pending =3D ioread32(card->config_regs + FLAGS_ADDR);
+
+	dev_vdbg(&card->dev->dev, "TX Flags are %X\n", tx_pending);
+
+	for (port =3D 0; port < card->nr_ports; port++) {
+		if (!(tx_pending & (1 << port))) {
+
+			spin_lock(&card->tx_queue_lock);
+			skb =3D skb_dequeue(&card->tx_queue[port]);
+			spin_unlock(&card->tx_queue_lock);
+
+			if (!skb)
+				continue;
+		=09
+			if (atmdebug) {
+				dev_info(&card->dev->dev, "Transmitted: port %d\n",
+					 port);
+				print_buffer(skb);
+			}
+			memcpy_toio(TX_BUF(card, port), skb->data, skb->len);
+
+			vcc =3D *(void **)skb->cb;
+
+			if (vcc) {
+				atomic_inc(&vcc->stats->tx);
+				solos_pop(vcc, skb);
+			} else
+				dev_kfree_skb_irq(skb);
+
+			tx_started |=3D 1 << port; //Set TX full flag
+		}
+	}
+	if (tx_started)
+		iowrite32(tx_started, card->config_regs + FLAGS_ADDR);
+
+	spin_unlock_irqrestore(&card->tx_lock, flags);
+	return 0;
+}
+
+static int psend(struct atm_vcc *vcc, struct sk_buff *skb)
+{
+	struct solos_card *card =3D vcc->dev->dev_data;
+	struct sk_buff *skb2 =3D NULL;
+	struct pkt_hdr *header;
+
+	//dev_dbg(&card->dev->dev, "psend called.\n");
+	//dev_dbg(&card->dev->dev, "dev,vpi,vci =3D %d,%d,%d\n",SOLOS_CHAN(vc=
c->dev),vcc->vpi,vcc->vci);
+
+	if (debug) {
+		skb2 =3D atm_alloc_charge(vcc, skb->len, GFP_ATOMIC);
+		if (skb2) {
+			memcpy(skb2->data, skb->data, skb->len);
+			skb_put(skb2, skb->len);
+			vcc->push(vcc, skb2);
+			atomic_inc(&vcc->stats->rx);
+		}
+		atomic_inc(&vcc->stats->tx);
+		solos_pop(vcc, skb);
+		return 0;
+	}
+
+	if (skb->len > (BUF_SIZE - sizeof(*header))) {
+		dev_warn(&card->dev->dev, "Length of PDU is too large. Dropping PDU.=
\n");
+		solos_pop(vcc, skb);
+		return 0;
+	}
+
+	if (!skb_clone_writable(skb, sizeof(*header))) {
+		int expand_by =3D 0;
+		int ret;
+
+		if (skb_headroom(skb) < sizeof(*header))
+			expand_by =3D sizeof(*header) - skb_headroom(skb);
+
+		ret =3D pskb_expand_head(skb, expand_by, 0, GFP_ATOMIC);
+		if (ret) {
+			solos_pop(vcc, skb);
+			return ret;
+		}
+	}
+
+	header =3D (void *)skb_push(skb, sizeof(*header));
+
+	header->size =3D cpu_to_le16(skb->len);
+	header->vpi =3D cpu_to_le16(vcc->vpi);
+	header->vci =3D cpu_to_le16(vcc->vci);
+	header->type =3D cpu_to_le16(PKT_DATA);
+
+	fpga_queue(card, SOLOS_CHAN(vcc->dev), skb, vcc);
+
+	return 0;
+}
+
+static struct atmdev_ops fpga_ops =3D {
+	.open =3D		popen,
+	.close =3D	pclose,
+	.ioctl =3D	NULL,
+	.getsockopt =3D	NULL,
+	.setsockopt =3D	NULL,
+	.send =3D		psend,
+	.send_oam =3D	NULL,
+	.phy_put =3D	NULL,
+	.phy_get =3D	NULL,
+	.change_qos =3D	NULL,
+	.proc_read =3D	NULL,
+	.owner =3D	THIS_MODULE
+};
+
+static int fpga_probe(struct pci_dev *dev, const struct pci_device_id =
*id)
+{
+	int err, i;
+	uint16_t fpga_ver;
+	uint8_t major_ver, minor_ver;
+	uint32_t data32;
+	struct solos_card *card;
+
+	if (debug)
+		return 0;
+
+	card =3D kzalloc(sizeof(*card), GFP_KERNEL);
+	if (!card)
+		return -ENOMEM;
+
+	card->dev =3D dev;
+
+	err =3D pci_enable_device(dev);
+	if (err) {
+		dev_warn(&dev->dev,  "Failed to enable PCI device\n");
+		goto out;
+	}
+
+	err =3D pci_request_regions(dev, "solos");
+	if (err) {
+		dev_warn(&dev->dev, "Failed to request regions\n");
+		goto out;
+	}
+
+	card->config_regs =3D pci_iomap(dev, 0, CONFIG_RAM_SIZE);
+	if (!card->config_regs) {
+		dev_warn(&dev->dev, "Failed to ioremap config registers\n");
+		goto out_release_regions;
+	}
+	card->buffers =3D pci_iomap(dev, 1, DATA_RAM_SIZE);
+	if (!card->buffers) {
+		dev_warn(&dev->dev, "Failed to ioremap data buffers\n");
+		goto out_unmap_config;
+	}
+
+//	for(i=3D0;i<64 ;i+=3D4){
+//		data32=3Dioread32(card->buffers + i);
+//		dev_dbg(&card->dev->dev, "%08lX\n",(unsigned long)data32);
+//	}
+
+	//Fill Config Mem with zeros
+	for(i =3D 0; i < 128; i +=3D 4)
+		iowrite32(0, card->config_regs + i);
+
+	//Set RX empty flags
+	iowrite32(0xF0, card->config_regs + FLAGS_ADDR);
+
+	data32 =3D ioread32(card->config_regs + FPGA_VER);
+	fpga_ver =3D (data32 & 0x0000FFFF);
+	major_ver =3D ((data32 & 0xFF000000) >> 24);
+	minor_ver =3D ((data32 & 0x00FF0000) >> 16);
+	dev_info(&dev->dev, "Solos FPGA Version %d.%02d svn-%d\n",
+		 major_ver, minor_ver, fpga_ver);
+
+	card->nr_ports =3D 2; /* FIXME: Detect daughterboard */
+
+	err =3D atm_init(card);
+	if (err)
+		goto out_unmap_both;
+
+	pci_set_drvdata(dev, card);
+	tasklet_init(&card->tlet, solos_bh, (unsigned long)card);
+	spin_lock_init(&card->tx_lock);
+	spin_lock_init(&card->tx_queue_lock);
+	spin_lock_init(&card->cli_queue_lock);
+/*
+	// Set Loopback mode
+	data32 =3D 0x00010000;
+	iowrite32(data32,card->config_regs + FLAGS_ADDR);
+*/
+/*
+	// Fill Buffers with zeros
+	for (i =3D 0; i < BUF_SIZE * 8; i +=3D 4)
+		iowrite32(0, card->buffers + i);
+*/
+/*
+	for(i =3D 0; i < (BUF_SIZE * 1); i +=3D 4)
+		iowrite32(0x12345678, card->buffers + i + (0*BUF_SIZE));
+	for(i =3D 0; i < (BUF_SIZE * 1); i +=3D 4)
+		iowrite32(0xabcdef98, card->buffers + i + (1*BUF_SIZE));
+
+	// Read Config Memory
+	printk(KERN_DEBUG "Reading Config MEM\n");
+	i =3D 0;
+	for(i =3D 0; i < 16; i++) {
+		data32=3Dioread32(card->buffers + i*(BUF_SIZE/2));
+		printk(KERN_ALERT "Addr: %lX Data: %08lX\n",
+		       (unsigned long)(addr_start + i*(BUF_SIZE/2)),
+		       (unsigned long)data32);
+	}
+*/
+	//dev_dbg(&card->dev->dev, "Requesting IRQ: %d\n",dev->irq);
+	err =3D request_irq(dev->irq, solos_irq, IRQF_DISABLED|IRQF_SHARED,
+			  "solos-pci", card);
+	if (err)
+		dev_dbg(&card->dev->dev, "Failed to request interrupt IRQ: %d\n", de=
v->irq);
+
+	// Enable IRQs
+	iowrite32(1, card->config_regs + IRQ_EN_ADDR);
+
+	return 0;
+
+ out_unmap_both:
+	pci_iounmap(dev, card->config_regs);
+ out_unmap_config:
+	pci_iounmap(dev, card->buffers);
+ out_release_regions:
+	pci_release_regions(dev);
+ out:
+	return err;
+}
+
+static int atm_init(struct solos_card *card)
+{
+	int i;
+
+	opens =3D 0;
+
+	for (i =3D 0; i < card->nr_ports; i++) {
+		skb_queue_head_init(&card->tx_queue[i]);
+		skb_queue_head_init(&card->cli_queue[i]);
+
+		card->atmdev[i] =3D atm_dev_register("solos-pci", &fpga_ops, -1, NUL=
L);
+		if (!card->atmdev[i]) {
+			dev_err(&card->dev->dev, "Could not register ATM device %d\n", i);
+			atm_remove(card);
+			return -ENODEV;
+		}
+		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_consol=
e))
+			dev_err(&card->dev->dev, "Could not register console for ATM device=
 %d\n", i);
+
+		dev_info(&card->dev->dev, "Registered ATM device %d\n", card->atmdev=
[i]->number);
+
+		card->atmdev[i]->ci_range.vpi_bits =3D 8;
+		card->atmdev[i]->ci_range.vci_bits =3D 16;
+		card->atmdev[i]->dev_data =3D card;
+		card->atmdev[i]->phy_data =3D (void *)(unsigned long)i;
+	}
+	return 0;
+}
+
+static void atm_remove(struct solos_card *card)
+{
+	int i;
+
+	for (i =3D 0; i < card->nr_ports; i++) {
+		if (card->atmdev[i]) {
+			dev_info(&card->dev->dev, "Unregistering ATM device %d\n", card->at=
mdev[i]->number);
+			atm_dev_deregister(card->atmdev[i]);
+		}
+	}
+}
+
+static void fpga_remove(struct pci_dev *dev)
+{
+	struct solos_card *card =3D pci_get_drvdata(dev);
+
+	if (debug)
+		return;
+
+	atm_remove(card);
+
+	dev_vdbg(&dev->dev, "Freeing IRQ\n");
+	// Disable IRQs from FPGA
+	iowrite32(0, card->config_regs + IRQ_EN_ADDR);
+	free_irq(dev->irq, card);
+	tasklet_kill(&card->tlet);
+
+	//	iowrite32(0x01,pciregs);
+	dev_vdbg(&dev->dev, "Unmapping PCI resource\n");
+	pci_iounmap(dev, card->buffers);
+	pci_iounmap(dev, card->config_regs);
+
+	dev_vdbg(&dev->dev, "Releasing PCI Region\n");
+	pci_release_regions(dev);
+	pci_disable_device(dev);
+
+	pci_set_drvdata(dev, NULL);
+	kfree(card);
+//	dev_dbg(&card->dev->dev, "fpga_remove\n");
+	return;
+}
+
+static struct pci_device_id fpga_pci_tbl[] __devinitdata =3D {
+	{ 0x10ee, 0x0300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	{ 0, }
+};
+
+MODULE_DEVICE_TABLE(pci,fpga_pci_tbl);
+
+static struct pci_driver fpga_driver =3D {
+	.name =3D		"solos",
+	.id_table =3D	fpga_pci_tbl,
+	.probe =3D	fpga_probe,
+	.remove =3D	fpga_remove,
+};
+
+
+static int __init solos_pci_init(void)
+{
+	printk(KERN_INFO "Solos PCI Driver Version %s\n", VERSION);
+	return pci_register_driver(&fpga_driver);
+}
+
+static void __exit solos_pci_exit(void)
+{
+	pci_unregister_driver(&fpga_driver);
+	printk(KERN_INFO "Solos PCI Driver %s Unloaded\n", VERSION);
+}
+
+module_init(solos_pci_init);
+module_exit(solos_pci_exit);


--=20
David Woodhouse                            Open Source Technology Centr=
e
David.Woodhouse@intel.com                              Intel Corporatio=
n

