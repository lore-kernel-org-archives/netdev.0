From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH][RESEND] Avoid possible NULL pointer deref in 3c359 driver
Date: Sat, 4 Aug 2007 20:31:05 +0200
Message-ID: <200708042031.05784.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Mike Phillips <mikep@linuxtr.net>, netdev@vger.kernel.org,
	linux-tr@linuxtr.net, Jesper Juhl <jesper.juhl@gmail.com>,
	davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:45415 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765458AbXHDSdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2007 14:33:01 -0400
Received: by fk-out-0910.google.com with SMTP id z23so995997fkz
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2007 11:33:01 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Resending old patch originally submitted at 1/7-2007 02:19)


In xl_freemem(), if dev_if is NULL, the line 
   struct xl_private *xl_priv =(struct xl_private *)dev->priv;
will cause a NULL pointer dereference. However, if we move 
that assignment below the 'if' statement that tests for a NULL 
'dev', then that NULL deref can never happen.
It never hurts to be safe :-)


Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
--- 

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index e22a3f5..671f4da 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -1044,15 +1044,17 @@ static void xl_freemem(struct net_device *dev)
 static irqreturn_t xl_interrupt(int irq, void *dev_id) 
 {
 	struct net_device *dev = (struct net_device *)dev_id;
- 	struct xl_private *xl_priv =(struct xl_private *)dev->priv;
-	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
-	u16 intstatus, macstatus  ;
+ 	struct xl_private *xl_priv;
+	u8 __iomem * xl_mmio; 
+	u16 intstatus, macstatus;
 
 	if (!dev) { 
-		printk(KERN_WARNING "Device structure dead, aaahhhh !\n") ;
+		printk(KERN_WARNING "3c359: Device structure dead, aaahhhh!\n");
 		return IRQ_NONE; 
 	}
 
+	xl_priv = (struct xl_private *)dev->priv;
+	xl_mmio = xl_priv->xl_mmio;
 	intstatus = readw(xl_mmio + MMIO_INTSTATUS) ;  
 
 	if (!(intstatus & 1)) /* We didn't generate the interrupt */



