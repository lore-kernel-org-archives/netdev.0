From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6-rc net driver fixes
Date: Sat, 24 Jan 2004 16:21:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124212159.GA25401@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, torvalds@osdl.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.5

This will update the following files:

 drivers/net/8139cp.c          |   12 ++++++++++--
 drivers/net/tulip/xircom_cb.c |    5 +++++
 2 files changed, 15 insertions(+), 2 deletions(-)

through these ChangeSets:

<shemminger@osdl.org> (04/01/24 1.1512)
   [PATCH] Make xircom cardbus handle shared irq
   
   Current driver doesn't do shared irq properly.  When testing on
   a laptop here irq 3 get shared between pcmcia slot and tty/IRDA

<hirofumi@mail.parknet.co.jp> (04/01/24 1.1511)
   [netdrvr 8139cp] fix NAPI race
   
   Andreas Happe <andreashappe@gmx.net> writes:
   > my notebook (hp/compaq nx7000) still crashes when using 8139cp (runs
   > rock solid with 8139too driver). The computer just locks up, there is no
   > dmesg output. This has happened since I've got this laptop (around
   > november '03).
   
   It seems 8139cp.c has the race condition of rx_poll and interrupt.
   
   NOTE, since I don't have this device, patch is untested. Sorry.

[further note - it has been tested]

diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	Sat Jan 24 16:20:26 2004
+++ b/drivers/net/8139cp.c	Sat Jan 24 16:20:26 2004
@@ -615,8 +615,10 @@
 		if (cpr16(IntrStatus) & cp_rx_intr_mask)
 			goto rx_status_loop;
 
-		netif_rx_complete(dev);
+		local_irq_disable();
 		cpw16_f(IntrMask, cp_intr_mask);
+		__netif_rx_complete(dev);
+		local_irq_enable();
 
 		return 0;	/* done */
 	}
@@ -643,6 +645,12 @@
 
 	spin_lock(&cp->lock);
 
+	/* close possible race's with dev_close */
+	if (unlikely(!netif_running(dev))) {
+		cpw16(IntrMask, 0);
+		goto out;
+	}
+
 	if (status & (RxOK | RxErr | RxEmpty | RxFIFOOvr)) {
 		if (netif_rx_schedule_prep(dev)) {
 			cpw16_f(IntrMask, cp_norx_intr_mask);
@@ -664,7 +672,7 @@
 
 		/* TODO: reset hardware */
 	}
-
+out:
 	spin_unlock(&cp->lock);
 	return IRQ_HANDLED;
 }
diff -Nru a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
--- a/drivers/net/tulip/xircom_cb.c	Sat Jan 24 16:20:26 2004
+++ b/drivers/net/tulip/xircom_cb.c	Sat Jan 24 16:20:26 2004
@@ -342,6 +342,11 @@
 	printk("tx status 0x%08x 0x%08x \n",card->tx_buffer[0],card->tx_buffer[4]);
 	printk("rx status 0x%08x 0x%08x \n",card->rx_buffer[0],card->rx_buffer[4]);
 #endif	
+	/* Handle shared irq and hotplug */
+	if (status == 0 || status == 0xffffffff) {
+		spin_unlock(&card->lock);
+		return IRQ_NONE;
+	}
 
 	if (link_status_changed(card)) {
 		int newlink;
