From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: add driver for the NIC on Cell Blades
Date: Wed, 29 Jun 2005 14:55:11 +0200
Message-ID: <200506291455.12506.arnd@arndb.de>
References: <200506281528.08834.arnd@arndb.de>
	<200506290238.59231.arnd@arndb.de>
	<1120030346.3196.21.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Utz Bacher <utz.bacher@de.ibm.com>, linuxppc64-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1120030346.3196.21.camel@laptopd505.fenrus.org>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Middeweken 29 Juni 2005 09:32, Arjan van de Ven wrote:

> different problem. the sync will get the byte out of the cpu. It won't
> get it out of the pci bridges...
> 
> In short, pci bridges are allowed to buffer (post) writes until data
> traffic in the other direction happens (eg readl() or dma). 

Ok, understood. This patch changes all io writes within a spinlock
to use a checking version of spider_net_write_reg(). Jens, could
you verify if these are the only places where you rely on the
write making it to the chip and then (n)ack this patch?

Note that in our setup, we know that there are no PCI bridges involved
because the device is not really PCI based but directly attached to
the FlexIO port and just fakes a PCI-like config space.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

--- linux-cg.orig/drivers/net/spider_net.c	2005-06-29 14:22:31.516896448 -0400
+++ linux-cg/drivers/net/spider_net.c	2005-06-29 14:22:22.567931328 -0400
@@ -109,6 +109,23 @@ spider_net_write_reg(struct spider_net_c
 }
 
 /**
+ * spider_net_write_reg_sync - writes to an SMMIO register of a card
+ * @card: device structure
+ * @reg: register to write to
+ * @value: value to write into the specified SMMIO register
+ *
+ * Unlike spider_net_write_reg, this will also make sure the
+ * data arrives on the card by reading the reg again.
+ */
+static void
+spider_net_write_reg_sync(struct spider_net_card *card, u32 reg, u32 value)
+{
+	value = cpu_to_le32(value);
+	writel(value, card->regs + reg);
+	(void)readl(card->regs + reg);
+}
+
+/**
  * spider_net_rx_irq_off - switch off rx irq on this spider card
  * @card: device structure
  *
@@ -123,7 +140,7 @@ spider_net_rx_irq_off(struct spider_net_
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue &= ~SPIDER_NET_RXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
 
@@ -196,7 +213,7 @@ spider_net_rx_irq_on(struct spider_net_c
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue |= SPIDER_NET_RXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
 
@@ -215,7 +232,7 @@ spider_net_tx_irq_off(struct spider_net_
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue &= ~SPIDER_NET_TXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
 
@@ -234,7 +251,7 @@ spider_net_tx_irq_on(struct spider_net_c
 	spin_lock_irqsave(&card->intmask_lock, flags);
 	regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
 	regvalue |= SPIDER_NET_TXINT;
-	spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
+	spider_net_write_reg_sync(card, SPIDER_NET_GHIINT0MSK, regvalue);
 	spin_unlock_irqrestore(&card->intmask_lock, flags);
 }
