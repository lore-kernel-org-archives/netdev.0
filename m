From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/5] [IrDA] Race between open and disconnect in
	irda-usb
Date: Mon, 17 Dec 2007 00:46:49 +0100
Message-ID: <20071216234932.929834588@sortiz.org>
References: <20071216234648.774780960@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline; filename=irda-usb.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

It seems to me that irda_usb_net_open() must set self->netopen
under spinlock or disconnect() may fail to kill all URBs, if it is called
while an interface is opened.

From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>

---
 drivers/net/irda/irda-usb.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: net-2.6/drivers/net/irda/irda-usb.c
===================================================================
--- net-2.6.orig/drivers/net/irda/irda-usb.c	2007-11-25 05:53:43.000000000 +0100
+++ net-2.6/drivers/net/irda/irda-usb.c	2007-11-25 07:12:09.000000000 +0100
@@ -1168,6 +1168,7 @@
 static int irda_usb_net_open(struct net_device *netdev)
 {
 	struct irda_usb_cb *self;
+	unsigned long flags;
 	char	hwname[16];
 	int i;
 	
@@ -1177,13 +1178,16 @@
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
@@ -1198,6 +1202,7 @@
 	/* To do *before* submitting Rx urbs and starting net Tx queue
 	 * Jean II */
 	self->netopen = 1;
+	spin_unlock_irqrestore(&self->lock, flags);
 
 	/* 
 	 * Now that everything should be initialized properly,

-- 


-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
