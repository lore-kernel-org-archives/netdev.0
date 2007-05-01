From: Richard Knutsson <ricknu-0@student.ltu.se>
Subject: [PATCH] drivers/net/3c505: Convert to generic boolean
Date: Tue, 1 May 2007 18:16:28 +0200 (MEST)
Message-ID: <20070501161359.32400.51795.sendpatchset@thinktank.campus.ltu.se>
Cc: netdev@vger.kernel.org, kernel-janitors@lists.osdl.org,
	Richard Knutsson <ricknu-0@student.ltu.se>
To: philb@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gepetto.dc.ltu.se ([130.240.42.40]:33162 "EHLO
	gepetto.dc.ltu.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbXEAQQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 12:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert to generic boolean

Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>
---
Compile-tested with all(yes|mod|no)config on x86(|_64) & sparc(|64)
Diffed against Linus' git-tree.


diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index e985a85..acede30 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -169,21 +169,6 @@ static int elp_debug;
 
 /*****************************************************************
  *
- * useful macros
- *
- *****************************************************************/
-
-#ifndef	TRUE
-#define	TRUE	1
-#endif
-
-#ifndef	FALSE
-#define	FALSE	0
-#endif
-
-
-/*****************************************************************
- *
  * List of I/O-addresses we try to auto-sense
  * Last element MUST BE 0!
  *****************************************************************/
@@ -270,7 +255,7 @@ static inline void set_hsf(struct net_device *dev, int hsf)
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
-static int start_receive(struct net_device *, pcb_struct *);
+static bool start_receive(struct net_device *, pcb_struct *);
 
 static inline void adapter_reset(struct net_device *dev)
 {
@@ -328,28 +313,28 @@ static inline void check_3c505_dma(struct net_device *dev)
 }
 
 /* Primitive functions used by send_pcb() */
-static inline unsigned int send_pcb_slow(unsigned int base_addr, unsigned char byte)
+static inline bool send_pcb_slow(unsigned int base_addr, unsigned char byte)
 {
 	unsigned long timeout;
 	outb_command(byte, base_addr);
 	for (timeout = jiffies + 5*HZ/100; time_before(jiffies, timeout);) {
 		if (inb_status(base_addr) & HCRE)
-			return FALSE;
+			return false;
 	}
 	printk(KERN_WARNING "3c505: send_pcb_slow timed out\n");
-	return TRUE;
+	return true;
 }
 
-static inline unsigned int send_pcb_fast(unsigned int base_addr, unsigned char byte)
+static inline bool send_pcb_fast(unsigned int base_addr, unsigned char byte)
 {
 	unsigned int timeout;
 	outb_command(byte, base_addr);
 	for (timeout = 0; timeout < 40000; timeout++) {
 		if (inb_status(base_addr) & HCRE)
-			return FALSE;
+			return false;
 	}
 	printk(KERN_WARNING "3c505: send_pcb_fast timed out\n");
-	return TRUE;
+	return true;
 }
 
 /* Check to see if the receiver needs restarting, and kick it if so */
@@ -386,7 +371,7 @@ static inline void prime_rx(struct net_device *dev)
  * timeout is reduced to 500us).
  */
 
-static int send_pcb(struct net_device *dev, pcb_struct * pcb)
+static bool send_pcb(struct net_device *dev, pcb_struct * pcb)
 {
 	int i;
 	unsigned long timeout;
@@ -396,14 +381,14 @@ static int send_pcb(struct net_device *dev, pcb_struct * pcb)
 	check_3c505_dma(dev);
 
 	if (adapter->dmaing && adapter->current_dma.direction == 0)
-		return FALSE;
+		return false;
 
 	/* Avoid contention */
 	if (test_and_set_bit(1, &adapter->send_pcb_semaphore)) {
 		if (elp_debug >= 3) {
 			printk(KERN_DEBUG "%s: send_pcb entered while threaded\n", dev->name);
 		}
-		return FALSE;
+		return false;
 	}
 	/*
 	 * load each byte into the command register and
@@ -435,7 +420,7 @@ static int send_pcb(struct net_device *dev, pcb_struct * pcb)
 		switch (GET_ASF(dev->base_addr)) {
 		case ASF_PCB_ACK:
 			adapter->send_pcb_semaphore = 0;
-			return TRUE;
+			return true;
 
 		case ASF_PCB_NAK:
 #ifdef ELP_DEBUG
@@ -453,7 +438,7 @@ static int send_pcb(struct net_device *dev, pcb_struct * pcb)
 	spin_unlock_irqrestore(&adapter->lock, flags);
       abort:
 	adapter->send_pcb_semaphore = 0;
-	return FALSE;
+	return false;
 }
 
 
@@ -470,7 +455,7 @@ static int send_pcb(struct net_device *dev, pcb_struct * pcb)
  *
  *****************************************************************/
 
-static int receive_pcb(struct net_device *dev, pcb_struct * pcb)
+static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 {
 	int i, j;
 	int total_length;
@@ -487,7 +472,7 @@ static int receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	while (((stat = get_status(dev->base_addr)) & ACRF) == 0 && time_before(jiffies, timeout));
 	if (time_after_eq(jiffies, timeout)) {
 		TIMEOUT_MSG(__LINE__);
-		return FALSE;
+		return false;
 	}
 	pcb->command = inb_command(dev->base_addr);
 
@@ -497,14 +482,14 @@ static int receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	if (time_after_eq(jiffies, timeout)) {
 		TIMEOUT_MSG(__LINE__);
 		printk(KERN_INFO "%s: status %02x\n", dev->name, stat);
-		return FALSE;
+		return false;
 	}
 	pcb->length = inb_command(dev->base_addr);
 
 	if (pcb->length > MAX_PCB_DATA) {
 		INVALID_PCB_MSG(pcb->length);
 		adapter_reset(dev);
-		return FALSE;
+		return false;
 	}
 	/* read the data */
 	spin_lock_irqsave(&adapter->lock, flags);
@@ -519,7 +504,7 @@ static int receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	spin_unlock_irqrestore(&adapter->lock, flags);
 	if (j >= 20000) {
 		TIMEOUT_MSG(__LINE__);
-		return FALSE;
+		return false;
 	}
 	/* woops, the last "data" byte was really the length! */
 	total_length = pcb->data.raw[--i];
@@ -529,7 +514,7 @@ static int receive_pcb(struct net_device *dev, pcb_struct * pcb)
 		if (elp_debug >= 2)
 			printk(KERN_WARNING "%s: mangled PCB received\n", dev->name);
 		set_hsf(dev, HSF_PCB_NAK);
-		return FALSE;
+		return false;
 	}
 
 	if (pcb->command == CMD_RECEIVE_PACKET_COMPLETE) {
@@ -538,14 +523,14 @@ static int receive_pcb(struct net_device *dev, pcb_struct * pcb)
 				set_hsf(dev, HSF_PCB_NAK);
 				printk(KERN_WARNING "%s: PCB rejected, transfer in progress and backlog full\n", dev->name);
 				pcb->command = 0;
-				return TRUE;
+				return true;
 			} else {
 				pcb->command = 0xff;
 			}
 		}
 	}
 	set_hsf(dev, HSF_PCB_ACK);
-	return TRUE;
+	return true;
 }
 
 /******************************************************
@@ -555,9 +540,9 @@ static int receive_pcb(struct net_device *dev, pcb_struct * pcb)
  *
  ******************************************************/
 
-static int start_receive(struct net_device *dev, pcb_struct * tx_pcb)
+static bool start_receive(struct net_device *dev, pcb_struct * tx_pcb)
 {
-	int status;
+	bool status;
 	elp_device *adapter = dev->priv;
 
 	if (elp_debug >= 3)
@@ -984,7 +969,7 @@ static int elp_open(struct net_device *dev)
  *
  ******************************************************/
 
-static int send_packet(struct net_device *dev, struct sk_buff *skb)
+static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 {
 	elp_device *adapter = dev->priv;
 	unsigned long target;
@@ -998,7 +983,7 @@ static int send_packet(struct net_device *dev, struct sk_buff *skb)
 	if (test_and_set_bit(0, (void *) &adapter->busy)) {
 		if (elp_debug >= 2)
 			printk(KERN_DEBUG "%s: transmit blocked\n", dev->name);
-		return FALSE;
+		return false;
 	}
 
 	adapter->stats.tx_bytes += nlen;
@@ -1015,7 +1000,7 @@ static int send_packet(struct net_device *dev, struct sk_buff *skb)
 
 	if (!send_pcb(dev, &adapter->tx_pcb)) {
 		adapter->busy = 0;
-		return FALSE;
+		return false;
 	}
 	/* if this happens, we die */
 	if (test_and_set_bit(0, (void *) &adapter->dmaing))
@@ -1047,7 +1032,7 @@ static int send_packet(struct net_device *dev, struct sk_buff *skb)
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: DMA transfer started\n", dev->name);
 
-	return TRUE;
+	return true;
 }
 
 /*
