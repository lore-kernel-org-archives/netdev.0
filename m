From: Rich Felker <dalias@libc.org>
Subject: Re: recvmmsg/sendmmsg result types inconsistent, integer overflows?
Date: Wed, 11 Jun 2014 11:15:11 -0400
Message-ID: <20140611151511.GU179@brightrain.aerifal.cx>
References: <20140611041243.GA1475@brightrain.aerifal.cx>
 <1402464261.5195.21.camel@marge.simpson.net>
 <1402465808.3645.454.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Galbraith <umgwanakikbuti@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1402465808.3645.454.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 10, 2014 at 10:50:08PM -0700, Eric Dumazet wrote:
> On Wed, 2014-06-11 at 07:24 +0200, Mike Galbraith wrote:
> > (CCs network wizard hangout)
> > 
> > On Wed, 2014-06-11 at 00:12 -0400, Rich Felker wrote: 
> > > While looking to add support for the recvmmsg and sendmmsg syscalls in
> > > musl libc, I ran into some disturbing findings on the kernel side. In
> > > the struct mmsghdr, the field where the result for each message is
> > > stored has type int, which is inconsistent with the return type
> > > ssize_t of recvmsg/sendmsg. So I tried to track down what happens when
> > > the result is or would be larger than 2GB, and quickly found an
> > > explanation for why the type in the structure was defined wrong:
> > > internally, the kernel uses int as the return type for revcmsg and
> > > sendmsg. Oops.
> > > 
> > > A bit more RTFS'ing brought me to tcp_sendmsg in net/ipv4/tcp.c (I
> > > figured let's look at a stream-based protocol, since datagrams can
> > > likely never be that big for any existing protocol), and as far as I
> > > can tell, it's haphazardly mixing int and size_t with no checks for
> > > overflows. I looked for anywhere the kernel might try to verify before
> > > starting that the sum of the lengths of all the iovec components
> > > doesn't overflow INT_MAX or even SIZE_MAX, but didn't find any such
> > > checks.
> > > 
> > > Is there some magic that makes this all safe, or is this a big mess of
> > > possibly-security-relevant bugs?
> > > 
> > > Rich
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > Please read the FAQ at  http://www.tux.org/lkml/
> > 
> 
> 
> See commit 8acfe468b0384e834a303f08ebc4953d72fb690a
> ("net: Limit socket I/O iovec total length to INT_MAX.")
> 
> (or grep for verify_iovec() )

Thanks; that addresses my concern about safety. There's still the ugly
API inconsistency which it seems too late to fix. Michael, perhaps
this should at least be documented in the man pages for sendmmsg and
recvmmsg since it's certain to be confusing to anyone familiar with
the sendmsg and recvmsg API, but not with kernel internals, who's
trying to use these functions...

Rich
