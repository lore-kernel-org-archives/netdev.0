From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: add driver for the NIC on Cell Blades
Date: Thu, 30 Jun 2005 09:48:20 +1000
Message-ID: <1120088901.31924.31.camel@gaston>
References: <200506281528.08834.arnd@arndb.de>
	<1119966799.3175.32.camel@laptopd505.fenrus.org>
	<200506290238.59231.arnd@arndb.de>
	<1120030346.3196.21.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Utz Bacher <utz.bacher@de.ibm.com>,
	Jens Osterkamp <Jens.Osterkamp@de.ibm.com>,
	linuxppc64-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1120030346.3196.21.camel@laptopd505.fenrus.org>
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


> > 
> > Could you be more specific? My guess would be that the 'sync' in writel
> > takes care of this. Should there be an extra mmiowb() in here or are
> > you referring to some other problem?
> 
> different problem. the sync will get the byte out of the cpu. It won't
> get it out of the pci bridges...
> 
> In short, pci bridges are allowed to buffer (post) writes until data
> traffic in the other direction happens (eg readl() or dma). 
> 
> In cases where you want your writel to hit the device instantly (and
> disabling irqs is generally one of those) you need to flush this posting
> cache with a dummy readl().

As I keep repeating over and over again, nothing will guarantee that
your interrupt is actually disabled here, not even a readl(). You _must_
make sure you are ready for a spurrious interrupt coming in, though in
that case, the interrupt will probably be very short.

The thing is, interrupts (not MSIs tho, but the problem is still
potentially there at the APIC level) are totally asynchronous to PCI
transactions. By the time you readl() back (and thus flush your PCI
posting buffers), or are approx. sure that the chip will have
de-asserted it's IRQ line (oh well, that isn't even sure, it may take a
few cycles depending on the HW you have there). But the IRQ may already
have been "captured" by the PIC, or even by several layers of PICs. By
the time the IRQ de-assertion propagates all the way to the CPU, you may
already have taken it.

Since those PCI IRQs are level, hopefully, it will go down real soon
(unless you have a misconfigured PIC along the chain), so it most cases,
it's just a matter of ignoring it. If it's safe, just read your device
IRQ status reg and your IRQ routine will "notice" that there is nothing
to do. (Note that returning IRQ_NONE there may confuse the core, heh !).
If it's not, then you need a local variable indicating that you did
indeed mask interrupts, and that cause your handler to just bail out. It
may get re-entered a couple of time, but ultimately, the IRQ will go
down.

Ben
