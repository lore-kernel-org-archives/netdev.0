From: Arun Chandran <achandran@mvista.com>
Subject: Re: [PATCH] net: macb: Add big endian CPU support
Date: Fri, 20 Feb 2015 17:15:04 +0530
Message-ID: <CAFdej03U7mMVC8H5SJJNCPq3nYRHZYHLshALvxusQvm24QPuSw@mail.gmail.com>
References: <1424258975-28611-1-git-send-email-achandran@mvista.com>
	<54E5D5A0.90005@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: monstr@monstr.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54E5D5A0.90005@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 19, 2015 at 5:52 PM, Michal Simek <monstr@monstr.eu> wrote:
>
> On 02/18/2015 12:29 PM, Arun Chandran wrote:
> > This patch converts all __raw_readl and __raw_writel function calls
> > to their corresponding readl_relaxed and writel_relaxed variants.
> >
> > It also tells the driver to set ahb_endian_swp_mgmt_en bit in dma_cfg
> > when the CPU is configured in big endian mode.
> >
> > Signed-off-by: Arun Chandran <achandran@mvista.com>
> > ---
> >       This patch is tested on xilinx ZC702 evaluation board with
> >       CONFIG_CPU_BIG_ENDIAN=y and booting NFS rootfs
> > ---
> > ---
> >  drivers/net/ethernet/cadence/macb.c | 18 ++++++++++++------
> >  drivers/net/ethernet/cadence/macb.h | 15 ++++++++-------
> >  2 files changed, 20 insertions(+), 13 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> > index ad76b8e..05fb36d 100644
> > --- a/drivers/net/ethernet/cadence/macb.c
> > +++ b/drivers/net/ethernet/cadence/macb.c
> > @@ -449,7 +449,7 @@ static void macb_update_stats(struct macb *bp)
> >       WARN_ON((unsigned long)(end - p - 1) != (MACB_TPF - MACB_PFR) / 4);
> >
> >       for(; p < end; p++, reg++)
> > -             *p += __raw_readl(reg);
> > +             *p += readl_relaxed(reg);
> >  }
> >
> >  static int macb_halt_tx(struct macb *bp)
> > @@ -1585,7 +1585,11 @@ static void macb_configure_dma(struct macb *bp)
> >               if (bp->dma_burst_length)
> >                       dmacfg = GEM_BFINS(FBLDO, bp->dma_burst_length, dmacfg);
> >               dmacfg |= GEM_BIT(TXPBMS) | GEM_BF(RXBMS, -1L);
> > -             dmacfg &= ~GEM_BIT(ENDIA);
> > +             dmacfg &= ~GEM_BIT(ENDIA_PKT);
> > +             /* Tell the chip to byteswap descriptors on big-endian hosts */
> > +#ifdef __BIG_ENDIAN
> > +             dmacfg |= GEM_BIT(ENDIA_DESC);
> > +#endif
>
> I don't think this is the best way what you should do.
> Instead of having this ifdef here you should find out any reg and detect if the IP
> is in big endian or little endian mode. I have done it for some xilinx IPs which
> can run on big or little endian system.
> In general find reg which some field which has some meaning - write there 1
> and read expected value and based on that decide if you are on big or little endian system.

Hi Michal,

I was not able to find any such registers for GEM in the TRM
http://www.xilinx.com/support/documentation/user_guides/ug585-Zynq-7000-TRM.pdf

I tried writing to dma_cfg (0x00000010) and reading from design_cfg5
(0x00000290)
Its not reflecting anything(design_cfg5 always reads same value); It
is not helping.

The only way (I don't think its not right way either) I can think of
eliminating that
 #ifdef __BIG_ENDIAN is reading some register in ARM cpu to identify its
current endianness and write dma_cfg accordingly.

--Arun
