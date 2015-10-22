From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/2] can: xilinx: use readl/writel instead of ioread/iowrite
Date: Thu, 22 Oct 2015 10:58:33 +0200
Message-ID: <8460953.p47oezaZnR@wuerfel>
References: <1445489163-11045-1-git-send-email-appanad@xilinx.com> <4061693.oBld7AKBIp@wuerfel> <56289CA6.1060809@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-arm-kernel@lists.infradead.org,
	Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	anirudh@xilinx.com, wg@grandegger.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, appanad@xilinx.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-can@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <56289CA6.1060809@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 22 October 2015 10:21:58 Marc Kleine-Budde wrote:
> On 10/22/2015 10:14 AM, Arnd Bergmann wrote:
> > On Thursday 22 October 2015 10:16:02 Kedareswara rao Appana wrote:
> >> The driver only supports memory-mapped I/O [by ioremap()],
> >> so readl/writel is actually the right thing to do, IMO.
> >> During the validation of this driver or IP on ARM 64-bit processor
> >> while sending lot of packets observed that the tx packet drop with iowrite
> >> Putting the barriers for each tx fifo register write fixes this issue
> >> Instead of barriers using writel also fixed this issue.
> >>
> >> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>
> > 
> > The two should really do the same thing: iowrite32() is just a static inline
> > calling writel() on both ARM32 and ARM64. On which kernel version did you
> > observe the difference? It's possible that an older version used
> > CONFIG_GENERIC_IOMAP, which made this slightly more expensive.
> > 
> > If there are barriers that you want to get rid of for performance reasons,
> > you should use writel_relaxed(), but be careful to synchronize them correctly
> > with regard to DMA. It should be fine in this driver, as it does not
> > perform any DMA, but be aware that there is no big-endian version of
> > writel_relaxed() at the moment.
> 
> We don't have DMA in CAN drivers, but usually a certain write triggers
> sending. Do we need a barrier before triggering the sending?

No, the relaxed writes are not well-defined across architectures. On
ARM, the CPU guarantees that stores to an MMIO area are still in order
with respect to one another, the barrier is only needed for actual DMA,
so you are fine. I would expect the same to be true everywhere,
otherwise a lot of other drivers would be broken too.

To be on the safe side, that last write() could remain a writel() instead
of writel_relaxed(), and that would be guaranteed to work on all
architectures even if they end relax the ordering between MMIO writes.
If there is a measurable performance difference, just use writel_relaxed()
and add a comment.

	Arnd
