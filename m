From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC PATCH net-2.6.25 uncompilable] [TCP]: Avoid breaking GSOed
 skbs when SACKed one-by-one
Date: Wed, 12 Dec 2007 16:00:38 -0800
Message-ID: <20071212160038.6b640a63@freepuppy.rosehill>
References: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
	<20071211.043239.224938181.davem@davemloft.net>
	<aa7d2c6d0712111614k2832f51axa8bc9736ac7ec796@mail.gmail.com>
	<20071212.071136.26499607.davem@davemloft.net>
	<aa7d2c6d0712121535y31bea3a6v14e270293c272e6f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org, quetchen@caltech.edu,
	"Darryl Veitch" <d.veitch@ee.unimelb.edu.au>
To: "Lachlan Andrew" <lachlan.andrew@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54675 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbXLMAC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 19:02:56 -0500
In-Reply-To: <aa7d2c6d0712121535y31bea3a6v14e270293c272e6f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2007 15:35:49 -0800
"Lachlan Andrew" <lachlan.andrew@gmail.com> wrote:

> Greetings Dave,
> 
> On 12/12/2007, David Miller <davem@davemloft.net> wrote:
> > From: "Lachlan Andrew" <lachlan.andrew@gmail.com>
> > Date: Tue, 11 Dec 2007 16:14:36 -0800
> >
> > > This thread started because TCP processing interferes with RTT
> > > estimation.  This problem would be eliminated if time-stamping were
> > > done as soon as the packet comes off the NIC.
> >
> > We don't do that because such timestamping is too expensive.
> > It used to be the case that we did this, but we stopped doing
> > that a long time ago.
> >
> > On x86 for example, timestamping can involve touching a slow
> > I/O device to read the timestamp.  We do not want to do that
> > for every packet.
> 
> OK.  Thanks for the background.
> 
> I thought that a TSC read was fairly cheap.  Any messing around to
> interpret it could be the responsibility of any task which actually
> needs a high-resolution timestamp, couldn't it?  If TSC is disabled,
> then the timestamp field could be set to "invalid".
> 
> > Also, we timestamp differently for TCP, the global high
> > resolution timestamp is overkill for this purpose.
> 
> Overkill for Reno and Cubic, but useful for Vegas, LP, veno, Illinois
> and YeAH which are all in the kernel.  They currently use "high
> resolution" timestamps which are effectively quantized to the
> scheduler resolution because of the way timestamping is done --
> reading a high-resolution time source when a task is scheduled.
> 
> > Really, this is a silly idea
> 
> Oh... :(
> 
> > and would only be a bandaid
> > for the problem at hand, that TCP input processing is
> > too expensive in certain circumstances.
> 
> That problem should certainly be fixed as well -- I wasn't suggesting
> this as an alternative.  Will fixing it fix the problem of those TCP
> modules suffering from CPU load from other sources?
> 
> (I'm Cc'ing this to Darryl Veitch who has often wanted driver-level
> time-stamping for achieving high-resolution synchronization between
> hosts.)
> 
> Cheers,
> Lachlan
> 

In current kernel, the congestion control can choose the desired accuracy.
The units are always the same (microseconds), 
but if the flag value "TCP_CONG_RTT_STAMP" is set, then TCP
tries to the high resolution real time clock.  This is relatively
expensive so only vegas, veno, LP, and YeAH use it. It would be
worth an experiment to see whether it is worth it.

All the delay based congestion control algorithms are impractical
in the real world, but everyone keeps trying :-)



-- 
Stephen Hemminger <shemminger@linux-foundation.org>
