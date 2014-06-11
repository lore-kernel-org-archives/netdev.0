From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: recvmmsg/sendmmsg result types inconsistent, integer overflows?
Date: Tue, 10 Jun 2014 22:50:08 -0700
Message-ID: <1402465808.3645.454.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140611041243.GA1475@brightrain.aerifal.cx>
	 <1402464261.5195.21.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rich Felker <dalias@libc.org>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402464261.5195.21.camel@marge.simpson.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-06-11 at 07:24 +0200, Mike Galbraith wrote:
> (CCs network wizard hangout)
> 
> On Wed, 2014-06-11 at 00:12 -0400, Rich Felker wrote: 
> > While looking to add support for the recvmmsg and sendmmsg syscalls in
> > musl libc, I ran into some disturbing findings on the kernel side. In
> > the struct mmsghdr, the field where the result for each message is
> > stored has type int, which is inconsistent with the return type
> > ssize_t of recvmsg/sendmsg. So I tried to track down what happens when
> > the result is or would be larger than 2GB, and quickly found an
> > explanation for why the type in the structure was defined wrong:
> > internally, the kernel uses int as the return type for revcmsg and
> > sendmsg. Oops.
> > 
> > A bit more RTFS'ing brought me to tcp_sendmsg in net/ipv4/tcp.c (I
> > figured let's look at a stream-based protocol, since datagrams can
> > likely never be that big for any existing protocol), and as far as I
> > can tell, it's haphazardly mixing int and size_t with no checks for
> > overflows. I looked for anywhere the kernel might try to verify before
> > starting that the sum of the lengths of all the iovec components
> > doesn't overflow INT_MAX or even SIZE_MAX, but didn't find any such
> > checks.
> > 
> > Is there some magic that makes this all safe, or is this a big mess of
> > possibly-security-relevant bugs?
> > 
> > Rich
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 


See commit 8acfe468b0384e834a303f08ebc4953d72fb690a
("net: Limit socket I/O iovec total length to INT_MAX.")

(or grep for verify_iovec() )
