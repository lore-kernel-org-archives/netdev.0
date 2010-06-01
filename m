From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH 1/2] mac8390: propagate error code from request_irq
Date: Tue, 1 Jun 2010 22:18:32 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1006011738330.299@localhost>
References: <alpine.LNX.2.00.1005312011210.469@nippy.intranet> <20100531.043056.258120791.davem@davemloft.net> <alpine.OSX.2.00.1005312244520.1490@localhost> <20100531.060225.68146363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: geert@linux-m68k.org, joe@perches.com, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <20100531.060225.68146363.davem@davemloft.net>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use the request_irq() error code as the return value for mac8390_open(). 
EAGAIN doesn't make sense for Nubus slot IRQs. Only this driver can claim 
this IRQ (until the NIC is removed, which means everything is powered 
down).

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Index: linux-2.6.34/drivers/net/mac8390.c
===================================================================
--- linux-2.6.34.orig/drivers/net/mac8390.c	2010-06-01 20:20:29.000000000 +1000
+++ linux-2.6.34/drivers/net/mac8390.c	2010-06-01 20:22:23.000000000 +1000
@@ -643,12 +643,13 @@ static int __init mac8390_initdev(struct
 
 static int mac8390_open(struct net_device *dev)
 {
+	int err;
+
 	__ei_open(dev);
-	if (request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev)) {
-		pr_info("%s: unable to get IRQ %d.\n", dev->name, dev->irq);
-		return -EAGAIN;
-	}
-	return 0;
+	err = request_irq(dev->irq, __ei_interrupt, 0, "8390 Ethernet", dev);
+	if (err)
+		pr_info("%s: unable to get IRQ %d\n", dev->name, dev->irq);
+	return err;
 }
 
 static int mac8390_close(struct net_device *dev)
