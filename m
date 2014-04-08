From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 08 Apr 2014 11:42:07 +0200
Message-ID: <10691019.6JnDSRh6QZ@wuerfel>
References: <1396672506-9296-1-git-send-email-zhangfei.gao@linaro.org> <5343AE45.4020308@linaro.org> <063D6719AE5E284EB5DD2968C1650D6D0F6F1434@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: 'zhangfei' <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org" <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	"f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org"
	<sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	"mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6F1434-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 April 2014 08:30:37 David Laight wrote:
> From: zhangfei [mailto:zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org]
> > On 04/08/2014 02:53 AM, David Miller wrote:
> > > From: Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > > Date: Sat,  5 Apr 2014 12:35:06 +0800
> > >
> > >> +struct tx_desc {
> > >> +  u32 send_addr;
> > >> +  u16 reserved_16;
> > >> +  u16 send_size;
> 
> The above doesn't look right for endianness independence.
> I'd guess the hardware spec shows a 32bit word with the 'send size'
> in one half - that is what you need to define.

It's probably good to use __be32 as the type (or possibly __be16,
depending what the reserved field actually is), to annotate the
fact that the device reads these as big-endian values from memory,
regardless of the CPU endianess.

> > >> +  u32 reserved_32;
> > >> +  u32 cfg;
> > >> +  u32 wb_addr;
> > >> +} ____cacheline_aligned;
> > >
> > > I do not think that ____cacheline_aligned is appropriate at all here.
> > >
> > > First of all, this is a hardware descriptor, so it has a fixed layout
> > > and therefore size.
> 
> The structure also isn't even a multiple of a power of two.
> So there will be implicit padding at the end.
> 
> Since there isn't a 'pointer to next' I presume the hardware accesses
> the descriptors from adjacent physical addresses.

My understanding is that in this device, the "ppe" gets a pointer
to the bus address of the descriptor through an MMIO write, and
has a hardware FIFO to keep track of the ones it still needs to
manage. The PPE is shared across multiple ethernet devices.

On a related note, it would be good if Zhangfei could add a comment
in the code to explain how the ppe avoids a FIFO overrun, because
it's not clear from the driver source.

> So you need to explicitly pad to that size.
> If the cache line size were 128 byte the above wouldn't work at all.

I originally recommended doing this, as a simplification from the
prior code that was using dma_pool_create with the cache line size
as the required alignment. While the device is used only in ARM SoCs
and ARM has a fixed cache line size of 32 bytes, you are obviously
correct that this is not something we want to rely on in a driver,
and it should use either explicit padding, or
__attribute__((__aligned__(32))) to enforce the implicit padding.

> > I am sorry, but unfortunately this series really does NOT have TX done
> > interrupt after checked with hardware guy many times.
> > And next series will add TX done interrupt according to the feedback.
> > 
> > There are two reasons of removing the TX done interrupt when the chip is
> > designed.
> > 1. The specific product does not care the latency, only care the throughput.
> > 2. When doing many experiment, the tx done interrupt will impact the
> > throughput, as a result reclaim is moved to xmit as one of
> > optimizations, then finally tx done interrupt is removed at all.

Both of these statements are clearly wrong, you have to stop bringing
these up now and work on explaining to the hardware designers what
mistake they made. This cannot be a design decision, it can only be
a bug that has to be fixed before a new version of the chip is rolled
out!

Zhangfei, do not post another version of this driver until you are
sure you have understood the problem and explained it to the hardware
designers!
Please reread what I wrote to you in the past on IRC, and find me
there again if you still have questions.

> > Is it acceptable of removing timer as well as latency handling, or any
> > other work around of this kind of hardware?
> 
> If you don't have a global 'TX done' interrupt, you need a per
> descriptor one.
> Otherwise you cannot send at maximum rate in the absence of
> receive traffic.

Zhangfei has already talked to the hardware designers a few times,
and from what I understood, they have just not considered how
software is going to use this device, and they are too shy to
admit their mistake, while Zhangfei is trying to take the blame for
them by claiming that it works as designed. This is a very nice
gesture of him, but I'm afraid it is counterproductive to getting
the driver merged.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
