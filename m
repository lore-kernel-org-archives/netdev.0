From: Paul Gortmaker <penguin@muskoka.com>
Subject: [PATCH] 2.6.9 Use skb_padto() in drivers/net/8390.c
Date: Thu, 16 Dec 2004 18:12:36 -0500
Message-ID: <41C21664.2070404@muskoka.com>
Mime-Version: 1.0
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The 8390 driver had been fixed for leaking information in short packets
prior to skb_padto() existing.  This change gets rid of the scratch area on
the stack and makes it use skb_padto().  Thanks to Mark Smith for bringing
this to my attention.

Signed-off-by: Paul Gortmaker <p_gortmaker@yahoo.com>

--- linux-386/drivers/net/8390.c~	Mon Oct 18 17:55:55 2004
+++ linux-386/drivers/net/8390.c	Thu Dec 16 18:06:23 2004
@@ -43,6 +43,7 @@
   Paul Gortmaker	: Separate out Tx timeout code from Tx path.
   Paul Gortmaker	: Remove old unused single Tx buffer code.
   Hayato Fujiwara	: Add m32r support.
+  Paul Gortmaker	: use skb_padto() instead of stack scratch area
 
   Sources:
   The National Semiconductor LAN Databook, and the 3Com 3c503 databook.
@@ -272,11 +273,15 @@ static int ei_start_xmit(struct sk_buff 
 {
 	long e8390_base = dev->base_addr;
 	struct ei_device *ei_local = (struct ei_device *) netdev_priv(dev);
-	int length, send_length, output_page;
+	int send_length = skb->len, output_page;
 	unsigned long flags;
-	char scratch[ETH_ZLEN];
 
-	length = skb->len;
+	if (skb->len < ETH_ZLEN) {
+		skb = skb_padto(skb, ETH_ZLEN);
+		if (skb == NULL)
+			return 0;
+		send_length = ETH_ZLEN;
+	}
 
 	/* Mask interrupts from the ethercard. 
 	   SMP: We have to grab the lock here otherwise the IRQ handler
@@ -298,8 +303,6 @@ static int ei_start_xmit(struct sk_buff 
 	
 	ei_local->irqlock = 1;
 
-	send_length = ETH_ZLEN < length ? length : ETH_ZLEN;
-    
 	/*
 	 * We have two Tx slots available for use. Find the first free
 	 * slot, and then perform some sanity checks. With two Tx bufs,
@@ -344,13 +347,7 @@ static int ei_start_xmit(struct sk_buff 
 	 * trigger the send later, upon receiving a Tx done interrupt.
 	 */
 	 
-	if (length == send_length)
-		ei_block_output(dev, length, skb->data, output_page);
-	else {
-		memset(scratch, 0, ETH_ZLEN);
-		memcpy(scratch, skb->data, skb->len);
-		ei_block_output(dev, ETH_ZLEN, scratch, output_page);
-	}
+	ei_block_output(dev, send_length, skb->data, output_page);
 		
 	if (! ei_local->txing) 
 	{
