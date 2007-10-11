From: Oliver Neukum <oliver@neukum.org>
Subject: [PATCH]race between open and disconnect in
	irda-usb
Date: Thu, 11 Oct 2007 17:45:28 +0200
Message-ID: <200710111745.28594.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean Tourrilhes <jt@hpl.hp.com>,
	Nick Fedchik <nick@fedchik.org.ua>, netdev@vger.kernel.org,
	USB development list <linux-usb-devel@lists.sourceforge.net>
Return-path: <linux-usb-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-usb-devel>
List-Post: <mailto:linux-usb-devel@lists.sourceforge.net>
List-Help: <mailto:linux-usb-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-usb-devel>,
	<mailto:linux-usb-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux-usb-devel-bounces@lists.sourceforge.net
Errors-To: linux-usb-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi,

it seems to me that irda_usb_net_open() must set self->netopen
under spinlock or disconnect() may fail to kill all URBs.

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


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
linux-usb-devel@lists.sourceforge.net
To unsubscribe, use the last form field at:
https://lists.sourceforge.net/lists/listinfo/linux-usb-devel
