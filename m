From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: recvmmsg/sendmmsg result types inconsistent, integer overflows?
Date: Wed, 11 Jun 2014 07:24:21 +0200
Message-ID: <1402464261.5195.21.camel@marge.simpson.net>
References: <20140611041243.GA1475@brightrain.aerifal.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Rich Felker <dalias@libc.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140611041243.GA1475@brightrain.aerifal.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(CCs network wizard hangout)

On Wed, 2014-06-11 at 00:12 -0400, Rich Felker wrote: 
> While looking to add support for the recvmmsg and sendmmsg syscalls in
> musl libc, I ran into some disturbing findings on the kernel side. In
> the struct mmsghdr, the field where the result for each message is
> stored has type int, which is inconsistent with the return type
> ssize_t of recvmsg/sendmsg. So I tried to track down what happens when
> the result is or would be larger than 2GB, and quickly found an
> explanation for why the type in the structure was defined wrong:
> internally, the kernel uses int as the return type for revcmsg and
> sendmsg. Oops.
> 
> A bit more RTFS'ing brought me to tcp_sendmsg in net/ipv4/tcp.c (I
> figured let's look at a stream-based protocol, since datagrams can
> likely never be that big for any existing protocol), and as far as I
> can tell, it's haphazardly mixing int and size_t with no checks for
> overflows. I looked for anywhere the kernel might try to verify before
> starting that the sum of the lengths of all the iovec components
> doesn't overflow INT_MAX or even SIZE_MAX, but didn't find any such
> checks.
> 
> Is there some magic that makes this all safe, or is this a big mess of
> possibly-security-relevant bugs?
> 
> Rich
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
