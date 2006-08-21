From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 driver - large files upload problem
Date: Mon, 21 Aug 2006 16:36:45 -0700
Message-ID: <20060821163645.0e1acfb6@localhost.localdomain>
References: <44E9A9E0.20106@cheetah.uio.no>
	<44E9B28C.9050207@gentoo.org>
	<44E9C153.1010300@cheetah.uio.no>
	<20060821095116.1b7f725d@localhost.localdomain>
	<44EA2DD7.9060605@cheetah.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:9407 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750718AbWHUXg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 19:36:56 -0400
To: Jon Wikne <wikne@cheetah.uio.no>
In-Reply-To: <44EA2DD7.9060605@cheetah.uio.no>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Aug 2006 00:04:07 +0200
Jon Wikne <wikne@cheetah.uio.no> wrote:

> Stephen Hemminger wrote:
> 
> > On Mon, 21 Aug 2006 16:21:07 +0200
> > Jon Wikne <wikne@cheetah.uio.no> wrote:
> > 
> >>Daniel Drake wrote:
> >>
> >>>Jon Wikne wrote:
> >>>
> >>>>What happens is typically this: After transeferring some
> >>>>data, ranging from less than 100kB to 10MB, the upload freezes,
> >>>>i.e. gets no further. Use of ping shows the connection is
> >>>>effectively dead. If I do a sequence /sbin/ifdown eth0
> >>>>/sbin/ifup eth0 the upload might resume, but stops again
> >>>>shortly. The phenomenon seems to occur sooner if the path
> >>>>to the remote system is _fast_ (low ping times).
> >>>
> >>>You can try applying this patch:
> >>>http://developer.osdl.org/shemminger/prototypes/sky2-proc-debug.patch
> >>>
> >>>It will add a /proc/net/sky2/ethX file, which lists the status of the TX 
> >>>and status rings. You should compare the contents of this file during 
> >>>normal operation to when the interface has hung.
> >>
> >>Thanks, Daniel. I applied the patch.
> >>
> >>The output of 'cat /proc/net/sky2/eth0' under normal circumstances
> >>is here:
> >>
> >>http://puma.uio.no/sky2/sky2-status-normal.txt
> >>
> >>After the interface hangs, 'cat /proc/net/sky2/eth0' causes the
> >>whole computer to hang completely. No kernel oops or other
> >>messages in the console window. Power down is the only
> >>solution.... :-[ No log entries after reboot.
> >>
> > It could be the code in the debug patch is walking off into space.
> > The smaller version of the same patch, doesn't walk but just reports
> > the index values.
> [ patch ]
> 
> OK, I applied that. Part of it (5 hunks) had to be done manually, since
> it appeared not to be relative to the version in 2.6.18-rc4 which I was
> using.
> 
> The result is:
> 
> Normal operation:
> Status ring (empty)
> Tx ring (empty)
> Rx pending hw get=60 put=256 last=511

The chip has prefetched some of the 254 frames we gave it.

> Error condition:
> Status ring (empty)
> Tx ring 338..378

40 packets waiting to send

> Rx pending hw get=316 put=0 last=511

So there are some frames waiting to be received as well.
Looks like a missed interrupt.  Is there anything surprising in the
ethtool stats?  (ethtool -S eth0)

In the past, when there were flow control hardware bugs
there would be suspicious statistics like "1 mac pause frame received".


> 
> 
> -- Jon
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Stephen Hemminger <shemminger@osdl.org>

All non-trivial abstractions, to some degree, are leaky.
