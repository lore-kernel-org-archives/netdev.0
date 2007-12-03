From: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/5] [IrDA] Race between open and disconnect in
	irda-usb
Date: Mon, 03 Dec 2007 10:28:32 +0100
Message-ID: <20071203093053.168766504@sortiz.org>
References: <20071203092831.724254969@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
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
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
