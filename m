From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] net: add driver for the NIC on Cell Blades
Date: Wed, 29 Jun 2005 09:32:25 +0200
Message-ID: <1120030346.3196.21.camel@laptopd505.fenrus.org>
References: <200506281528.08834.arnd@arndb.de>
	<1119966799.3175.32.camel@laptopd505.fenrus.org>
	<200506290238.59231.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Utz Bacher <utz.bacher@de.ibm.com>, linuxppc64-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200506290238.59231.arnd@arndb.de>
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

On Wed, 2005-06-29 at 02:38 +0200, Arnd Bergmann wrote:
> On Dinsdag 28 Juni 2005 15:53, Arjan van de Ven wrote:
> > 
> > > +static void
> > > +spider_net_rx_irq_off(struct spider_net_card *card)
> > > +{
> > > +       u32 regvalue;
> > > +       unsigned long flags;
> > > +
> > > +       spin_lock_irqsave(&card->intmask_lock, flags);
> > > +       regvalue = spider_net_read_reg(card, SPIDER_NET_GHIINT0MSK);
> > > +       regvalue &= ~SPIDER_NET_RXINT;
> > > +       spider_net_write_reg(card, SPIDER_NET_GHIINT0MSK, regvalue);
> > > +       spin_unlock_irqrestore(&card->intmask_lock, flags);
> > > +}
> > 
> > I think you have a PCI posting bug here....
> 
> Could you be more specific? My guess would be that the 'sync' in writel
> takes care of this. Should there be an extra mmiowb() in here or are
> you referring to some other problem?

different problem. the sync will get the byte out of the cpu. It won't
get it out of the pci bridges...

In short, pci bridges are allowed to buffer (post) writes until data
traffic in the other direction happens (eg readl() or dma). 

In cases where you want your writel to hit the device instantly (and
disabling irqs is generally one of those) you need to flush this posting
cache with a dummy readl().

http://ftp.linux.org.uk/pub/linux/willy/patches/debug-write.diff

is a patch to simulate this behavior more agressive
