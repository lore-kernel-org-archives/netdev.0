From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net PATCH] atl1c: Fix misuse of netdev_alloc_skb in refilling
 rx ring
Date: Sun, 28 Jul 2013 21:22:52 +0100
Message-ID: <1375042972.2546.17.camel@deadeye.wl.decadent.org.uk>
References: <87k3kbdcmy.fsf@canonical.com>
	 <1374960610.3607.13.camel@deadeye.wl.decadent.org.uk>
	 <1374969583.3669.23.camel@edumazet-glaptop>
	 <20130727.200205.67471633133830510.davem@davemloft.net>
	 <20130728104446.GB9876@neilslaptop.think-freely.org>
	 <1375028154.3669.30.camel@edumazet-glaptop>
	 <20130728185318.GA10795@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	<luis.henriques@canonical.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <stable@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130728185318.GA10795@neilslaptop.think-freely.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-07-28 at 14:53 -0400, Neil Horman wrote:
> On Sun, Jul 28, 2013 at 09:15:54AM -0700, Eric Dumazet wrote:
> > On Sun, 2013-07-28 at 06:44 -0400, Neil Horman wrote:
> > > On Sat, Jul 27, 2013 at 08:02:05PM -0700, David Miller wrote:
> > > > From: Eric Dumazet <eric.dumazet@gmail.com>
> > > > Date: Sat, 27 Jul 2013 16:59:43 -0700
> > > > 
> > > > > If a hardware needs frame being in a single 4K page, its driver must do
> > > > > its own allocation, or add appropriate aligning logic.
> > > > 
> > > > Whatever the cause the original patch in this thread is not the
> > > > correct fix and I've thus reverted it.
> > > > 
> > > 
> > > So what exactly is the consensus here?  We can certainly modify the patch to
> > > ensure allocation on a 4k boundary, and within a unique 4k page, but thats just
> > > a guess at the problem, and the Qualcomm people have been silent on the issue
> > > for weeks now.
> > > 
> > 
> > Thats the guess yes, but since MTU can be more than 4096 bytes, it could
> > be something else, some kind of DMA problem.

Oh well, there goes that theory.

> Right, thats exactly my concern, its a guess, one which infers problems of its
> own.  I'll certainly code up a patch to test, sure, given what we've discussed
> here, but I'm not sure it leaves us in any better position than we were in with
> my origional patch.
> 
> > I wonder why rx_buffer_len includes VLAN_HLEN as this nic provides
> > accelerated vlan.
> > 
> I expect its an overestimation of sizing requirements in the rx ring.  The
> set_features method for the driver doesn't re-allocate the rx ring buffers if
> the vlan tag accleration feature is disabled, so I suspect that they keep that
> extra space in place in the event that its ever turned off.
> 
> > drivers/net/ethernet/atheros/atl1c/atl1c_main.c uses :
> >  hw->dmar_block = atl1c_dma_req_1024;
> > 
> > while drivers/net/ethernet/atheros/atlx/atl1.c uses :
> >  hw->dmar_block = atl1_dma_req_256;
> > 
> Another question for the Atheros people I suppose.  Although, atl1c takes this
> value through several other contortions in atl1c_configure_tx, in which it seems
> to allow the value to be either 2, or 3 (capped by the min_t call, and floored
> by the check against DEVICE_CTRL_MAXRRS_MIN).  By all rights the setting in the
> atlx driver would be considered invalid in the atl1c driver (if such
> comparisons can be drawn).
[...]

The value programmed as the Max Read Request Size should be irrelevant
to memory writes (i.e. RX DMA).  Memory write transactions must be
limited by the Max Payload Size and must not cross 4K boundaries.  I
would expect PCIe devices to split linear DMA transfers into suitably
sized transactions automatically, modulo bugs of course.

Since we know lengths > 4K work, perhaps it would be worth testing with
the fragment cache size reduced to 16K?  The driver would never
previously have used RX buffers crossing 16K boundaries, except if SLOB
was used (and that's an unlikely combination).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
