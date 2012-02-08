From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 1/3 net-next] bnx2: Add support for ethtool
 --show-channels|--set-channels
Date: Tue, 7 Feb 2012 17:19:33 -0800
Message-ID: <20120207171933.00001f12@unknown>
References: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
	<1328645954.3549.17.camel@bwh-desktop>
	<1328648307.8014.35.camel@nseg_linux_HP1.broadcom.com>
	<1328652088.3549.30.camel@bwh-desktop>
	<1328654187.3549.40.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6219 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756522Ab2BHBTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 20:19:41 -0500
In-Reply-To: <1328654187.3549.40.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Feb 2012 22:36:27 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:
> > > > If I read this correctly, IRQs may be shared between RX and TX queues
> > > > i.e. there may be 'combined channels'.
> > > 
> > > It is true that an IRQ can have a TX and a RX queue, but they don't both
> > > have to be enabled.  Because of that, it is easier to treat them as
> > > independent queues.  They are independent in all aspects except the IRQ.
> > 
> > Given that these numbers can be set independently, I can see that
> > treating TX and RX queues as having separate sets of channels might make
> > the set_channels operation easier to understand.
> > 
> > The kernel-doc actually committed for struct ethtool_channels is not at
> > all clear on what is meant by a 'channel', but it was certainly my
> > intent that a channel should correspond to one IRQ and the total number
> > of IRQs used by a device would be equal to the sum of
> > {rx,tx,other,combined}_count.  Which is certainly not the case for the
> > implementation in bnx2.
> 
> It doesn't seem to be true for the original implementation in qlcnic
> either.  That has 1 IRQ shared between RX and TX, with additional IRQs
> for RX only, but it reports them as all separate.  (It also seems to
> report the number of TX channels to be what the firmware reports as the
> maximum, despite the fact the driver only uses 1.)
> 
> There really should be some way to report, and potentially change,
> whether IRQs are shared between RX and TX queues.  I wonder if it isn't
> too late to rename and redefine the max_combined and combined_count
> fields...

I'm not very fond of the current ethtool implementation either.  Just
today I was implementing the -l/-L options for ixgbe, and since ixgbe
hardware can support 1-all queues on a single interrupt vector, it is
very difficult to express any kind of useful control over anything but
the most basic cases.  The driver defaults today to queue tx/rx pairs
per interrupt, with one interrupt per CPU.  This default is easy to
express, but if I want to have 1 tx queue per cpu thread, and 1 rx
queue per socket, what do we do then? 

While we're at it, can we at least mention in the -h (and man page) that
this is about queues (and or interrupts)?  The "channels" reference
ends up being obtuse and difficult for no reason that I can discern.

In my initial interpretation of the data structure I was showing:
Channel parameters for p6p1:
Pre-set maximums:
RX:             64
TX:             64
Other:          0
Combined:       64
Current hardware settings:
RX:             8
TX:             8
Other:          0
Combined:       8

p6p1 /proc/interrupts
p6p1-TxRx-0
p6p1-TxRx-1
p6p1-TxRx-2
p6p1-TxRx-3
p6p1-TxRx-4
p6p1-TxRx-5
p6p1-TxRx-6
p6p1-TxRx-7
p6p1

8 rx queues, 8 tx queues and they were all combined.
