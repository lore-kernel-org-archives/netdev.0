From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH] add return value check of request_irq()
Date: Tue, 5 Jun 2007 22:55:06 +0900
Message-ID: <20070605225506.72e5f8fe.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo30.po.2iij.net ([210.128.50.53]:15596 "EHLO mo30.po.2iij.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760153AbXFENzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 09:55:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch has added return value check of request_irq() to pcmcia net drivers.

Yoichi

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X generic/Documentation/dontdiff generic-orig/drivers/net/pcmcia/axnet_cs.c generic/drivers/net/pcmcia/axnet_cs.c
--- generic-orig/drivers/net/pcmcia/axnet_cs.c	2007-06-05 11:12:22.039270000 +0900
+++ generic/drivers/net/pcmcia/axnet_cs.c	2007-06-05 22:41:57.017445250 +0900
@@ -521,6 +521,7 @@ static void mdio_write(kio_addr_t addr, 
 
 static int axnet_open(struct net_device *dev)
 {
+    int ret;
     axnet_dev_t *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
     
@@ -529,9 +530,11 @@ static int axnet_open(struct net_device 
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
-    link->open++;
+    ret = request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, "axnet_cs", dev);
+    if (ret)
+	    return ret;
 
-    request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, "axnet_cs", dev);
+    link->open++;
 
     info->link_status = 0x00;
     init_timer(&info->watchdog);
diff -pruN -X generic/Documentation/dontdiff generic-orig/drivers/net/pcmcia/pcnet_cs.c generic/drivers/net/pcmcia/pcnet_cs.c
--- generic-orig/drivers/net/pcmcia/pcnet_cs.c	2007-06-05 11:12:22.043270250 +0900
+++ generic/drivers/net/pcmcia/pcnet_cs.c	2007-06-05 22:41:45.656735250 +0900
@@ -960,6 +960,7 @@ static void mii_phy_probe(struct net_dev
 
 static int pcnet_open(struct net_device *dev)
 {
+    int ret;
     pcnet_dev_t *info = PRIV(dev);
     struct pcmcia_device *link = info->p_dev;
 
@@ -968,10 +969,12 @@ static int pcnet_open(struct net_device 
     if (!pcmcia_dev_present(link))
 	return -ENODEV;
 
-    link->open++;
-
     set_misc_reg(dev);
-    request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, dev_info, dev);
+    ret = request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, dev_info, dev);
+    if (ret)
+	    return ret;
+
+    link->open++;
 
     info->phy_id = info->eth_phy;
     info->link_status = 0x00;
