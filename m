From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH]race between open and disconnect in irda-usb
Date: Fri, 12 Oct 2007 10:53:55 +0200
Message-ID: <200710121053.55829.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: Jean Tourrilhes <jt@hpl.hp.com>,
	Nick Fedchik <nick@fedchik.org.ua>, netdev@vger.kernel.org,
	USB development list <linux-usb-devel@lists.sourceforge.net>,
	Samuel Ortiz <samuel@sortiz.
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:40595 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753199AbXJLIx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:53:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

it seems to me that irda_usb_net_open() must set self->netopen
under spinlock or disconnect() may fail to kill all URBs, if it is called
while an interface is opened.

Signed-off-by: Oliver Neukum <oneukum@suse.de>

	Regards
		Oliver

----

--- a/drivers/net/irda/irda-usb.c	2007-10-11 17:24:35.000000000 +0200
+++ b/drivers/net/irda/irda-usb.c	2007-10-11 17:30:30.000000000 +0200
@@ -1168,6 +1168,7 @@ static int stir421x_patch_device(struct 
 static int irda_usb_net_open(struct net_device *netdev)
 {
 	struct irda_usb_cb *self;
+	unsigned long flags;
 	char	hwname[16];
 	int i;
 	
@@ -1177,13 +1178,16 @@ static int irda_usb_net_open(struct net_
 	self = (struct irda_usb_cb *) netdev->priv;
 	IRDA_ASSERT(self != NULL, return -1;);
 
+	spin_lock_irqsave(&self->lock, flags);
 	/* Can only open the device if it's there */
 	if(!self->present) {
+		spin_unlock_irqrestore(&self->lock, flags);
 		IRDA_WARNING("%s(), device not present!\n", __FUNCTION__);
 		return -1;
 	}
 
 	if(self->needspatch) {
+		spin_unlock_irqrestore(&self->lock, flags);
 		IRDA_WARNING("%s(), device needs patch\n", __FUNCTION__) ;
 		return -EIO ;
 	}
@@ -1198,6 +1202,7 @@ static int irda_usb_net_open(struct net_
 	/* To do *before* submitting Rx urbs and starting net Tx queue
 	 * Jean II */
 	self->netopen = 1;
+	spin_unlock_irqrestore(&self->lock, flags);
 
 	/* 
 	 * Now that everything should be initialized properly,

