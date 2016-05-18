From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: suppress warnings on dev_alloc_skb
Date: Wed, 18 May 2016 17:09:43 -0400
Message-ID: <20160518210943.GA771@hmsreliant.think-freely.org>
References: <1463585124-13086-1-git-send-email-nhorman@tuxdriver.com>
 <1463587298.18194.129.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uct2FPuVHER=p-kpb2nbnVMG7ya1Cy67iJDRV7ZUE=jVg@mail.gmail.com>
 <20160518192934.GD29900@hmsreliant.think-freely.org>
 <CAKgT0Ue6iRY0=i0OV3V51+3jWaOa7-pjHe7tQz22oK8qYX+irg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57368 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbcERVJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 17:09:54 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0Ue6iRY0=i0OV3V51+3jWaOa7-pjHe7tQz22oK8qYX+irg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 01:48:15PM -0700, Alexander Duyck wrote:
> On Wed, May 18, 2016 at 12:29 PM, Neil Horman <nhorman@tuxdriver.com> wrote:
> > On Wed, May 18, 2016 at 10:57:21AM -0700, Alexander Duyck wrote:
> >> On Wed, May 18, 2016 at 9:01 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> > On Wed, 2016-05-18 at 11:25 -0400, Neil Horman wrote:
> >> >> Noticed an allocation failure in a network driver the other day on a 32 bit
> >> >> system:
> >> >>
> >> >> DMA-API: debugging out of memory - disabling
> >> >> bnx2fc: adapter_lookup: hba NULL
> >> >> lldpad: page allocation failure. order:0, mode:0x4120
> >> >> Pid: 4556, comm: lldpad Not tainted 2.6.32-639.el6.i686.debug #1
> >> >> Call Trace:
> >> >>  [<c08a4086>] ? printk+0x19/0x23
> >> >>  [<c05166a4>] ? __alloc_pages_nodemask+0x664/0x830
> >> >>  [<c0649d02>] ? free_object+0x82/0xa0
> >> >>  [<fb4e2c9b>] ? ixgbe_alloc_rx_buffers+0x10b/0x1d0 [ixgbe]
> >> >>  [<fb4e2fff>] ? ixgbe_configure_rx_ring+0x29f/0x420 [ixgbe]
> >> >>  [<fb4e228c>] ? ixgbe_configure_tx_ring+0x15c/0x220 [ixgbe]
> >> >>  [<fb4e3709>] ? ixgbe_configure+0x589/0xc00 [ixgbe]
> >> >>  [<fb4e7be7>] ? ixgbe_open+0xa7/0x5c0 [ixgbe]
> >> >>  [<fb503ce6>] ? ixgbe_init_interrupt_scheme+0x5b6/0x970 [ixgbe]
> >> >>  [<fb4e8e54>] ? ixgbe_setup_tc+0x1a4/0x260 [ixgbe]
> >> >>  [<fb505a9f>] ? ixgbe_dcbnl_set_state+0x7f/0x90 [ixgbe]
> >> >>  [<c088d80d>] ? dcb_doit+0x10ed/0x16d0
> >> >> ...
> >> >
> >> >
> >> > Well, maybe this call site (via ixgbe_configure_rx_ring()) should be
> >> > using GFP_KERNEL instead of GFP_ATOMIC.
> >>
> >> The problem is the ixgbe driver is using the same function for
> >> allocating memory in the softirq and in the init.  As such it has to
> >> default to GFP_ATOMIC so that it doesn't screw up the NAPI allocation
> >> case.
> >>
> >
> > I suppose a happy medium would be to extend dev_alloc_pages to accept a gfp
> > argument, and then have the function itself only set __GFP_NOWARN, if ATOMIC is
> > also set?
> 
> Why bother?  I really think Eric's patch is the way to go.
> 
> We can already pass gfp flags to __dev_alloc_pages so if we need to
> pass flags we can use that.  Otherwise for the users of dev_alloc_page
> and dev_alloc_pages we can just pass GFP_ATOMIC | __GFP_NOWARN like
> Eric did in his example patch.
> 
> - Alex
> 
Oh, my bad, I misread what he was saying.  Yeah, thats the way to go.

Neil
