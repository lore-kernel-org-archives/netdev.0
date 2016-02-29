From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net] ppp: lock ppp->flags in ppp_read() and ppp_poll()
Date: Mon, 29 Feb 2016 14:59:59 +0100
Message-ID: <20160229135959.GM1186@alphalink.fr>
References: <c7c10511f505342837d57e9bb628fb145504f3e6.1456507305.git.g.nault@alphalink.fr>
 <063D6719AE5E284EB5DD2968C1650D6D41110082@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:38554 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbcB2OAD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 09:00:03 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D41110082@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 29, 2016 at 10:18:38AM +0000, David Laight wrote:
> From: Guillaume Nault
> > Sent: 26 February 2016 17:46
> > 
> > ppp_read() and ppp_poll() can be called concurrently with ppp_ioctl().
> > In this case, ppp_ioctl() might call ppp_ccp_closed(), which may update
> > ppp->flags while ppp_read() or ppp_poll() is reading it.
> > The update done by ppp_ccp_closed() isn't atomic due to the bit mask
> > operation ('ppp->flags &= ~(SC_CCP_OPEN | SC_CCP_UP)'), so concurrent
> > readers might get transient values.
> > Reading incorrect ppp->flags may disturb the 'ppp->flags & SC_LOOP_TRAFFIC'
> > test in ppp_read() and ppp_poll(), which in turn can lead to improper
> > decision on whether the PPP unit file is ready for reading or not.
> > 
> > Since ppp_ccp_closed() is protected by the Rx and Tx locks (with
> > ppp_lock()), taking the Rx lock is enough for ppp_read() and ppp_poll()
> > to guarantee that ppp_ccp_closed() won't update ppp->flags
> > concurrently.
> 
> This is all splurious.
> The 'concurrent' calls cannot be distinguished from calls just prior to,
> or just after the ppp_ccp_closed() call.
> 
If the ppp->flags update is guaranteed to be atomic from a reader's
point of view, then yes, concurrent runs of ppp_{read,poll}() and
ppp_ccp_closed() aren't an issue.

Here I assume that 'ppp->flags &= ~(SC_CCP_OPEN | SC_CCP_UP)' isn't
atomic, and that a concurrent reader may get a value different from
the original or final value of ppp->flags. If ppp_read() or ppp_poll()
reads such a transient value that affects the SC_LOOP_TRAFFIC bit, the
code may take the wrong decision as to whether or not the file
descriptor is available for reading.

ppp_ioctl()
   |
   \_ ppp_ccp_closed()
            |
	    \_ (1) Start Read-Modify-Write operation on ppp->flags
	       |
	       |
	       | <-- (2) ppp_read() or ppp_poll() reads transient value
	       |         of ppp->flags here
	       |
	       (3) End Read-Modify-Write operation on ppp->flags

If we assume that the RMW operation can't generate transient values, or
that transient values can't affect the SC_LOOP_TRAFFIC bit, then this
patch is not needed. However I'm not aware of such guarantees (unless
the atomic stores of ints described by DaveM in my original series
also applies here). At least I haven't seen other parts of the stack
implicitely relying in atomic properties of RMW operations performed on
plain integers.

If my analysis is too far fetched, I'll happily drop the patch.
I'm just trying to fix the possible issues I saw while working on the
PPP code, before resubmitting the PPP rtnetlink handler support.
