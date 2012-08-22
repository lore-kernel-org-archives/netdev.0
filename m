From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/3] x86_64, sfc: 128-bit memory-mapped I/O
Date: Wed, 22 Aug 2012 03:10:23 +0100
Message-ID: <1345601423.2659.100.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345598275.2659.71.camel@bwh-desktop.uk.solarflarecom.com>
	  <50343810.2000809@zytor.com>
	 <1345599783.2659.82.camel@bwh-desktop.uk.solarflarecom.com>
	 <50343D16.4040901@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>, <x86@kernel.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57082 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754587Ab2HVCK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 22:10:27 -0400
In-Reply-To: <50343D16.4040901@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-21 at 18:59 -0700, H. Peter Anvin wrote:
> On 08/21/2012 06:43 PM, Ben Hutchings wrote:
> > On Tue, 2012-08-21 at 18:38 -0700, H. Peter Anvin wrote:
> >> On 08/21/2012 06:17 PM, Ben Hutchings wrote:
> >>> Current Solarflare network controllers have 128-bit memory-mapped
> >>> registers which are normally accessed through a series of I/O
> >>> operations.  However, it is also possible to access them with a single
> >>> MOVAPS instruction on x86_64, and this is measurably faster as it
> >>> requires only one PCIe transaction.
> >>
> >> Also, have you considered doing this with write combining instead?
> > 
> > We tried it, and it goes horribly wrong.  On some systems, the writes
> > are not combined, but they are reordered in a way the hardware doesn't
> > support.  See the comment at the top of drivers/net/ethernet/sfc/io.h.
> > 
> 
> Yes, you have to make sure you properly enforce the necessary ordering
> requirements manually (I think you can do that with sfence).

We did put an sfence after the writes to each register.  But some
systems only want to combine writes that cover an entire cache line, and
the writes covering a 128-bit register get broken back up into multiple
writes at the PCIe level.  And on some systems these are sent in
decreasing address order, which breaks the rules for writing to
TX_DESC_UPD.

To avoid this we'd have to put an sfence in between the writes to a
register, leaving us back where we started.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
