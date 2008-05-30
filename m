From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/7] tlan: get rid of padding buffer
Date: Fri, 30 May 2008 09:49:52 -0700
Message-ID: <20080530165033.445403629@vyatta.com>
References: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34070 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905AbYE3QxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:53:13 -0400
Content-Disposition: inline; filename=tlan-pad.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_padto to pad frames, this avoid allocation of separate buffer just
for dma of the extra bytes.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tlan.c	2008-05-30 08:44:39.000000000 -0700
+++ b/drivers/net/tlan.c	2008-05-30 08:46:19.000000000 -0700
@@ -218,8 +218,6 @@ static	int		bbuf;
 module_param(bbuf, int, 0);
 MODULE_PARM_DESC(bbuf, "ThunderLAN use big buffer (0-1)");
 
-static	u8		*TLanPadBuffer;
-static  dma_addr_t	TLanPadBufferDMA;
 static	char		TLanSignature[] = "TLAN";
 static  const char tlan_banner[] = "ThunderLAN driver v1.15\n";
 static  int tlan_have_pci;
@@ -469,16 +467,6 @@ static int __init tlan_probe(void)
 
 	printk(KERN_INFO "%s", tlan_banner);
 
-	TLanPadBuffer = (u8 *) pci_alloc_consistent(NULL, TLAN_MIN_FRAME_SIZE, &TLanPadBufferDMA);
-
-	if (TLanPadBuffer == NULL) {
-		printk(KERN_ERR "TLAN: Could not allocate memory for pad buffer.\n");
-		rc = -ENOMEM;
-		goto err_out;
-	}
-
-	memset(TLanPadBuffer, 0, TLAN_MIN_FRAME_SIZE);
-
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting PCI Probe....\n");
 
 	/* Use new style PCI probing. Now the kernel will
@@ -506,8 +494,6 @@ static int __init tlan_probe(void)
 err_out_pci_unreg:
 	pci_unregister_driver(&tlan_driver);
 err_out_pci_free:
-	pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
-err_out:
 	return rc;
 }
 
@@ -724,8 +710,6 @@ static void __exit tlan_exit(void)
 	if (tlan_have_eisa)
 		TLan_Eisa_Cleanup();
 
-	pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
-
 }
 
 
@@ -1096,7 +1080,6 @@ static int TLan_StartTx( struct sk_buff 
 	TLanList	*tail_list;
 	dma_addr_t	tail_list_phys;
 	u8		*tail_buffer;
-	int		pad;
 	unsigned long	flags;
 
 	if ( ! priv->phyOnline ) {
@@ -1105,6 +1088,9 @@ static int TLan_StartTx( struct sk_buff 
 		return 0;
 	}
 
+	if (skb_padto(skb, TLAN_MIN_FRAME_SIZE))
+		return 0;
+
 	tail_list = priv->txList + priv->txTail;
 	tail_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txTail;
 
@@ -1125,19 +1111,10 @@ static int TLan_StartTx( struct sk_buff 
 		TLan_StoreSKB(tail_list, skb);
 	}
 
-	pad = TLAN_MIN_FRAME_SIZE - skb->len;
-
-	if ( pad > 0 ) {
-		tail_list->frameSize = (u16) skb->len + pad;
-		tail_list->buffer[0].count = (u32) skb->len;
-		tail_list->buffer[1].count = TLAN_LAST_BUFFER | (u32) pad;
-		tail_list->buffer[1].address = TLanPadBufferDMA;
-	} else {
-		tail_list->frameSize = (u16) skb->len;
-		tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) skb->len;
-		tail_list->buffer[1].count = 0;
-		tail_list->buffer[1].address = 0;
-	}
+	tail_list->frameSize = (u16) skb->len;
+	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) skb->len;
+	tail_list->buffer[1].count = 0;
+	tail_list->buffer[1].address = 0;
 
 	spin_lock_irqsave(&priv->lock, flags);
 	tail_list->cStat = TLAN_CSTAT_READY;

-- 

