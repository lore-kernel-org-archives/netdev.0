From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH/CFT] de2104x fixes
Date: Fri, 21 Nov 2003 13:50:24 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBE5E70.9060102@pobox.com>
References: <200311212051.32352.russell@coker.com.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060507000103040403010101"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, rask@sygehus.dk,
        akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: russell@coker.com.au
In-Reply-To: <200311212051.32352.russell@coker.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060507000103040403010101
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

So, can people give this a test?  It includes a change that, I hope, 
addresses Russell's problem, as well as a patch from Rask.

	Jeff


P.S.  It would be great if people cc'd me on such bug reports ;-) 
Quicker to find and respond, these days.


--------------060507000103040403010101
Content-Type: text/plain;
 name="patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch"

===== drivers/net/tulip/de2104x.c 1.25 vs edited =====
--- 1.25/drivers/net/tulip/de2104x.c	Thu Sep 11 18:46:11 2003
+++ edited/drivers/net/tulip/de2104x.c	Fri Nov 21 13:48:17 2003
@@ -28,8 +28,8 @@
  */
 
 #define DRV_NAME		"de2104x"
-#define DRV_VERSION		"0.6"
-#define DRV_RELDATE		"Sep 1, 2003"
+#define DRV_VERSION		"0.9"
+#define DRV_RELDATE		"Nov 21, 2003"
 
 #include <linux/config.h>
 #include <linux/module.h>
@@ -1380,18 +1380,18 @@
 		return rc;
 	}
 
-	rc = de_init_hw(de);
+	rc = request_irq(dev->irq, de_interrupt, SA_SHIRQ, dev->name, dev);
 	if (rc) {
-		printk(KERN_ERR "%s: h/w init failure, err=%d\n",
-		       dev->name, rc);
+		printk(KERN_ERR "%s: IRQ %d request failure, err=%d\n",
+		       dev->name, dev->irq, rc);
 		goto err_out_free;
 	}
 
-	rc = request_irq(dev->irq, de_interrupt, SA_SHIRQ, dev->name, dev);
+	rc = de_init_hw(de);
 	if (rc) {
-		printk(KERN_ERR "%s: IRQ %d request failure, err=%d\n",
-		       dev->name, dev->irq, rc);
-		goto err_out_hw;
+		printk(KERN_ERR "%s: h/w init failure, err=%d\n",
+		       dev->name, rc);
+		goto err_out_free_irq;
 	}
 
 	netif_start_queue(dev);
@@ -1399,10 +1399,8 @@
 
 	return 0;
 
-err_out_hw:
-	spin_lock_irqsave(&de->lock, flags);
-	de_stop_hw(de);
-	spin_unlock_irqrestore(&de->lock, flags);
+err_out_free_irq:
+	free_irq (dev->irq, dev);
 
 err_out_free:
 	de_free_rings(de);
@@ -1571,13 +1569,17 @@
 	    (ecmd->advertising == de->media_advertise))
 		return 0; /* nothing to change */
 	    
-	de_link_down(de);
-	de_stop_rxtx(de);
+	if (netif_running(dev)) {
+		de_link_down(de);
+		de_stop_rxtx(de);
+	}
 	
 	de->media_type = new_media;
 	de->media_lock = media_lock;
 	de->media_advertise = ecmd->advertising;
-	de_set_media(de);
+
+	if (netif_running(dev))
+		de_set_media(de);
 	
 	return 0;
 }

--------------060507000103040403010101--
