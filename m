From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] [NET] uli526x: add support for netpoll
Date: Thu, 15 May 2008 19:12:55 +0400
Message-ID: <20080515151255.GA12408@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:43629 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1750947AbYEOPNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 11:13:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds netpoll support for the uli526x ethernet driver --
simply call the interrupt handler for polling.

To do this without disable_irq()/enable_irq() pair we should fully
protect the handler. Luckily, it's already using irqsave spinlock,
the only unprotected place is interrupts re-enabling write. It was
safe to re-enable interrupts without holding the spinlock, but with
netpoll possibility now it doesn't seem so.

Patch was tested using netconsole and KGDBoE.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/tulip/uli526x.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index 2511ca7..6a04a95 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -225,6 +225,7 @@ static void uli526x_set_filter_mode(struct net_device *);
 static const struct ethtool_ops netdev_ethtool_ops;
 static u16 read_srom_word(long, int);
 static irqreturn_t uli526x_interrupt(int, void *);
+static void uli526x_poll(struct net_device *dev);
 static void uli526x_descriptor_init(struct uli526x_board_info *, unsigned long);
 static void allocate_rx_buffer(struct uli526x_board_info *);
 static void update_cr6(u32, unsigned long);
@@ -339,6 +340,9 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	dev->get_stats = &uli526x_get_stats;
 	dev->set_multicast_list = &uli526x_set_filter_mode;
 	dev->ethtool_ops = &netdev_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = &uli526x_poll;
+#endif
 	spin_lock_init(&db->lock);
 
 
@@ -681,8 +685,9 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 	db->cr5_data = inl(ioaddr + DCR5);
 	outl(db->cr5_data, ioaddr + DCR5);
 	if ( !(db->cr5_data & 0x180c1) ) {
-		spin_unlock_irqrestore(&db->lock, flags);
+		/* Restore CR7 to enable interrupt mask */
 		outl(db->cr7_data, ioaddr + DCR7);
+		spin_unlock_irqrestore(&db->lock, flags);
 		return IRQ_HANDLED;
 	}
 
@@ -715,6 +720,13 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void uli526x_poll(struct net_device *dev)
+{
+	/* ISR grabs the irqsave lock, so this should be safe */
+	uli526x_interrupt(dev->irq, dev);
+}
+#endif
 
 /*
  *	Free TX resource after TX complete
-- 
1.5.5.1
