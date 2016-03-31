From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH] net: mvneta: explicitly disable BM on 64bit platform
Date: Thu, 31 Mar 2016 16:13:24 +0800
Message-ID: <20160331161324.64c541b7@xhacker>
References: <1459344310-626-1-git-send-email-jszhang@marvell.com>
	<8737r8uhjm.fsf@free-electrons.com>	<20160331135322.523a7ceb@xhacker>
	<CAPv3WKcR+JgoguUUEW0_uPoJL_CtxgKz-ZG_rZhGAAB5utzqMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPv3WKcR+JgoguUUEW0_uPoJL_CtxgKz-ZG_rZhGAAB5utzqMw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Marcin,

On Thu, 31 Mar 2016 08:49:19 +0200 Marcin Wojtas wrote:

> Hi Jisheng,
> 
> 2016-03-31 7:53 GMT+02:00 Jisheng Zhang <jszhang@marvell.com>:
> > Hi Gregory,
> >
> > On Wed, 30 Mar 2016 17:11:41 +0200 Gregory CLEMENT wrote:
> >  
> >> Hi Jisheng,
> >>
> >>  On mer., mars 30 2016, Jisheng Zhang <jszhang@marvell.com> wrote:
> >>  
> >> > The mvneta BM can't work on 64bit platform, as the BM hardware expects
> >> > buf virtual address to be placed in the first four bytes of mapped
> >> > buffer, but obviously the virtual address on 64bit platform can't be
> >> > stored in 4 bytes. So we have to explicitly disable BM on 64bit
> >> > platform.  
> >>
> >> Actually mvneta is used on Armada 3700 which is a 64bits platform.
> >> Is it true that the driver needs some change to use BM in 64 bits, but
> >> we don't have to disable it.
> >>
> >> Here is the 64 bits part of the patch we have currently on the hardware
> >> prototype. We have more things which are really related to the way the
> >> mvneta is connected to the Armada 3700 SoC. This code was not ready for  
> >
> > Thanks for the sharing.
> >
> > I think we could commit easy parts firstly, for example: the cacheline size
> > hardcoding, either piece of your diff or my version:
> >
> > http://lists.infradead.org/pipermail/linux-arm-kernel/2016-March/418513.html  
> 
> Since the commit:
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/arch/arm64/include/asm/cache.h?id=97303480753e48fb313dc0e15daaf11b0451cdb8
> detached L1_CACHE_BYTES from real cache size, I suggest, the macro should be:
> #define MVNETA_CPU_D_CACHE_LINE_SIZE     cache_line_size()

Thanks for the hint. I'll send out updated version to address the cacheline size
issue.

> 
> Regarding check after dma_alloc_coherent, I agree it's not necessary.
> 
> >  
> >> mainline but I prefer share it now instead of having the HWBM blindly  
> >
> > I have looked through the diff, it is for the driver itself on 64bit platforms,
> > and it doesn't touch BM. The BM itself need to be disabled for 64bit, I'm not
> > sure the BM could work on 64bit even with your diff. Per my understanding, the BM
> > can't work on 64 bit, let's have a look at some piece of the mvneta_bm_construct()
> >
> > *(u32 *)buf = (u32)buf;  
> 
> Indeed this particular part is different and unclear, I tried
> different options - with no success. I'm checking with design team
> now. Anyway, I managed to enable operation for HWBM on A3700 with one
> work-around in mvneta_hwbm_rx():
> data = phys_to_virt(rx_desc->buf_phys_addr);

oh yes! This seems a good idea. And If we replace all

data = (void *)rx_desc->buf_cookie

with

data = phys_to_virt(rx_desc->buf_phys_addr);

we also resolve the buf_cookie issue on 64bit platforms! no need to introduce
data_high or use existing reserved member to store virtual address' higher 32bits

> 
> Of course mvneta_bm, due to some silicone differences needed also a rework.
> 
> Actually I'd wait with updating 64-bit parts of mvneta, until real
> support for such machine's controller is introduced. Basing on my
> experience with enabling neta on A3700, it turns out to be more
> changes.

I agree with you. And I need one more rework: berlin SoCs don't have mbus
concept at all ;)

Thanks for your hints,
Jisheng
