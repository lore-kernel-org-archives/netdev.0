From: Grant Grundler <grundler@parisc-linux.org>
Subject: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Wed, 31 May 2006 13:52:34 -0600
Message-ID: <20060531195234.GA4967@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:17794 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S1751790AbWEaTwi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 15:52:38 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,
SLES10 testing exposed an MCA that was confirmed to be a DMA IO TLB miss.
This means tulip device was attempting to DMA to memory that was already
unmapped. The test was crashing in the "ifconfig down" step when a 4-port
tulip card was under this work load:

while :
do
	ifconfig eth24 up
	ifconfig eth25 up
	ifconfig eth26 up
	ifconfig eth27 up
        # Pound both interfaces with ethtool
        for i in `seq 1000`
        do
                ethtool eth24 &>/dev/null
                ethtool eth25 &>/dev/null
                ethtool eth26 &>/dev/null
                ethtool eth27 &>/dev/null
        done

	# Bring interfaces down
        echo ifconfig $nic1 down
        ifconfig eth24 down
        ifconfig eth25 down
        ifconfig eth26 down
        ifconfig eth27 down

        sleep 5
done


[ And yes, I know tulip doesn't support ethtool. Don't ask.
  It's still a sore point at the moment. Just consider it 
  a delay loop or use "sleep 5" instead. ]

The real "network load" comes from another box(en) running 4 instances
of "ping -f -s 1450 192.168.x.y" where "x.y" is the subnet/IP of eth24-27.
The parisc and ia64 machines will crash in minutes.

I believe the problem is a race condition between an interrupt coming
in and the tulip_down() code path. Moving the "free_irq()" to before
tulip_down() call fixes the problem. I've been able to run the above
test for several hours now.
Please apply.

thanks,
grant


Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -18,11 +18,11 @@
 
 #define DRV_NAME	"tulip"
 #ifdef CONFIG_TULIP_NAPI
-#define DRV_VERSION    "1.1.13-NAPI" /* Keep at least for test */
+#define DRV_VERSION    "1.1.14-NAPI" /* Keep at least for test */
 #else
-#define DRV_VERSION	"1.1.13"
+#define DRV_VERSION	"1.1.14"
 #endif
-#define DRV_RELDATE	"December 15, 2004"
+#define DRV_RELDATE	"May 31, 2006"
 
 
 #include <linux/module.h>
@@ -772,14 +774,13 @@ static int tulip_close (struct net_devic
 	int i;
 
 	netif_stop_queue (dev);
-
+	free_irq (dev->irq, dev);    /* don't let IRQs race w/tulip_down() */
 	tulip_down (dev);
 
 	if (tulip_debug > 1)
 		printk (KERN_DEBUG "%s: Shutting down ethercard, status was %2.2x.\n",
 			dev->name, ioread32 (ioaddr + CSR5));
 
-	free_irq (dev->irq, dev);
 
 	/* Free all the skbuffs in the Rx queue. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
