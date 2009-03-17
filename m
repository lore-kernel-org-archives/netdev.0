From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 06/30] solos: Handle attribute show/store in kernel more
 sanely
Date: Tue, 17 Mar 2009 21:29:15 +0000
Message-ID: <1237325355.27681.335.camel@macbook.infradead.org>
References: <1237310370.27681.314.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37654 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757862AbZCQV3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:29:21 -0400
Received: from macbook.infradead.org ([2001:8b0:10b:1:216:eaff:fe05:bbb8])
	by casper.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Ljgqb-0001uu-Ke
	for netdev@vger.kernel.org; Tue, 17 Mar 2009 21:29:18 +0000
In-Reply-To: <1237310370.27681.314.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are still a _lot_ of attributes, but for at least the basic ones
we want to be able to get/set them from the kernel. Especially the ones
we want to inform the ATM core about (link state, speed).

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c |  187 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 187 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index 5179dbf..d9262a4 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -38,6 +38,8 @@
 #include <linux/device.h>
 #include <linux/kobject.h>
 #include <linux/firmware.h>
+#include <linux/ctype.h>
+#include <linux/swab.h>
 
 #define VERSION "0.07"
 #define PTAG "solos-pci"
@@ -91,11 +93,23 @@ struct solos_card {
 	spinlock_t tx_lock;
 	spinlock_t tx_queue_lock;
 	spinlock_t cli_queue_lock;
+	spinlock_t param_queue_lock;
+	struct list_head param_queue;
 	struct sk_buff_head tx_queue[4];
 	struct sk_buff_head cli_queue[4];
+	wait_queue_head_t param_wq;
 	wait_queue_head_t fw_wq;
 };
 
+
+struct solos_param {
+	struct list_head list;
+	pid_t pid;
+	int port;
+	struct sk_buff *response;
+	wait_queue_head_t wq;
+};
+
 #define SOLOS_CHAN(atmdev) ((int)(unsigned long)(atmdev)->phy_data)
 
 MODULE_AUTHOR("Traverse Technologies <support@traverse.com.au>");
@@ -131,6 +145,168 @@ static inline void solos_pop(struct atm_vcc *vcc, struct sk_buff *skb)
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
+	skb = alloc_skb(buflen, GFP_KERNEL);
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
+	skb = alloc_skb(buflen, GFP_KERNEL);
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
@@ -195,6 +371,8 @@ static ssize_t console_store(struct device *dev, struct device_attribute *attr,
 }
 
 static DEVICE_ATTR(console, 0644, console_show, console_store);
+static DEVICE_ATTR(OperationalMode, 0444, solos_param_show, NULL);
+static DEVICE_ATTR(AutoStart, 0644, solos_param_show, solos_param_store);
 
 static int flash_upgrade(struct solos_card *card, int chip)
 {
@@ -351,6 +529,8 @@ void solos_bh(unsigned long card_arg)
 
 			case PKT_COMMAND:
 			default: /* FIXME: Not really, surely? */
+				if (process_command(card, port, skb))
+					break;
 				spin_lock(&card->cli_queue_lock);
 				if (skb_queue_len(&card->cli_queue[port]) > 10) {
 					if (net_ratelimit())
@@ -671,6 +851,7 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	card->dev = dev;
 	init_waitqueue_head(&card->fw_wq);
+	init_waitqueue_head(&card->param_wq);
 
 	err = pci_enable_device(dev);
 	if (err) {
@@ -722,6 +903,8 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	spin_lock_init(&card->tx_lock);
 	spin_lock_init(&card->tx_queue_lock);
 	spin_lock_init(&card->cli_queue_lock);
+	spin_lock_init(&card->param_queue_lock);
+	INIT_LIST_HEAD(&card->param_queue);
 
 /*
 	// Set Loopback mode
@@ -804,6 +987,10 @@ static int atm_init(struct solos_card *card)
 		}
 		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_console))
 			dev_err(&card->dev->dev, "Could not register console for ATM device %d\n", i);
+		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_OperationalMode))
+			dev_err(&card->dev->dev, "Could not register opmode attr for ATM device %d\n", i);
+		if (device_create_file(&card->atmdev[i]->class_dev, &dev_attr_AutoStart))
+			dev_err(&card->dev->dev, "Could not register autostart attr for ATM device %d\n", i);
 
 		dev_info(&card->dev->dev, "Registered ATM device %d\n", card->atmdev[i]->number);
 
-- 
1.6.0.6


