From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/7] tlan: proper shared IRQ support
Date: Fri, 30 May 2008 09:49:57 -0700
Message-ID: <20080530165033.873149777@vyatta.com>
References: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34067 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbYE3QxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:53:07 -0400
Content-Disposition: inline; filename=tlan-shared-irq.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle shared IRQ correctly. If IRQ is shared, it typically will show up
as an IRQ with an empty status field. So check in driver and handle it
without crapping out with invalid interrupt message.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tlan.c	2008-05-30 09:26:56.000000000 -0700
+++ b/drivers/net/tlan.c	2008-05-30 09:32:33.000000000 -0700
@@ -218,7 +218,7 @@ static	int		bbuf;
 module_param(bbuf, int, 0);
 MODULE_PARM_DESC(bbuf, "ThunderLAN use big buffer (0-1)");
 
-static	char		TLanSignature[] = "TLAN";
+static	const char TLanSignature[] = "TLAN";
 static  const char tlan_banner[] = "ThunderLAN driver v1.15\n";
 static  int tlan_have_pci;
 static  int tlan_have_eisa;
@@ -297,7 +297,6 @@ static void	TLan_tx_timeout( struct net_
 static void	TLan_tx_timeout_work(struct work_struct *work);
 static int 	tlan_init_one( struct pci_dev *pdev, const struct pci_device_id *ent);
 
-static u32	TLan_HandleInvalid( struct net_device *, u16 );
 static u32	TLan_HandleTxEOF( struct net_device *, u16 );
 static u32	TLan_HandleStatOverflow( struct net_device *, u16 );
 static u32	TLan_HandleRxEOF( struct net_device *, u16 );
@@ -366,7 +365,7 @@ TLan_GetSKB( const struct tlan_list_tag 
 
 
 static TLanIntVectorFunc *TLanIntVector[TLAN_INT_NUMBER_OF_INTS] = {
-	TLan_HandleInvalid,
+	NULL,
 	TLan_HandleTxEOF,
 	TLan_HandleStatOverflow,
 	TLan_HandleRxEOF,
@@ -935,7 +934,8 @@ static int TLan_Open( struct net_device 
 	int		err;
 
 	priv->tlanRev = TLan_DioRead8( dev->base_addr, TLAN_DEF_REVISION );
-	err = request_irq( dev->irq, TLan_HandleInterrupt, IRQF_SHARED, TLanSignature, dev );
+	err = request_irq( dev->irq, TLan_HandleInterrupt, IRQF_SHARED,
+			   dev->name, dev );
 
 	if ( err ) {
 		printk(KERN_ERR "TLAN:  Cannot open %s because IRQ %d is already in use.\n", dev->name, dev->irq );
@@ -1167,33 +1167,31 @@ static int TLan_StartTx( struct sk_buff 
 
 static irqreturn_t TLan_HandleInterrupt(int irq, void *dev_id)
 {
-	u32		ack;
-	struct net_device	*dev;
-	u32		host_cmd;
+	struct net_device	*dev = dev_id;
+	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16		host_int;
-	int		type;
-	TLanPrivateInfo *priv;
-
-	dev = dev_id;
-	priv = netdev_priv(dev);
+	u16		type;
 
 	spin_lock(&priv->lock);
 
 	host_int = inw( dev->base_addr + TLAN_HOST_INT );
-	outw( host_int, dev->base_addr + TLAN_HOST_INT );
-
 	type = ( host_int & TLAN_HI_IT_MASK ) >> 2;
-
-	ack = TLanIntVector[type]( dev, host_int );
-
-	if ( ack ) {
-		host_cmd = TLAN_HC_ACK | ack | ( type << 18 );
-		outl( host_cmd, dev->base_addr + TLAN_HOST_CMD );
+	if ( type ) {
+		u32	ack;
+		u32	host_cmd;
+
+		outw( host_int, dev->base_addr + TLAN_HOST_INT );
+		ack = TLanIntVector[type]( dev, host_int );
+
+		if ( ack ) {
+			host_cmd = TLAN_HC_ACK | ack | ( type << 18 );
+			outl( host_cmd, dev->base_addr + TLAN_HOST_CMD );
+		}
 	}
 
 	spin_unlock(&priv->lock);
 
-	return IRQ_HANDLED;
+	return IRQ_RETVAL(type);
 } /* TLan_HandleInterrupts */
 
 
@@ -1359,31 +1357,6 @@ static void TLan_SetMulticastList( struc
 *****************************************************************************/
 
 
-	/***************************************************************
-	 *	TLan_HandleInvalid
-	 *
-	 *	Returns:
-	 *		0
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This function handles invalid interrupts.  This should
-	 *	never happen unless some other adapter is trying to use
-	 *	the IRQ line assigned to the device.
-	 *
-	 **************************************************************/
-
-static u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
-{
-	/* printk( "TLAN:  Invalid interrupt on %s.\n", dev->name ); */
-	return 0;
-
-} /* TLan_HandleInvalid */
-
-
 
 
 	/***************************************************************

-- 

