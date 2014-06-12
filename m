From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: recvmmsg/sendmmsg result types inconsistent, integer overflows?
Date: Thu, 12 Jun 2014 20:53:13 +0200
Message-ID: <CAKgNAkhYvR1cSFVyghPYLm8ggS0-USD2chq4xNuOTqG+v19SzQ@mail.gmail.com>
References: <20140611041243.GA1475@brightrain.aerifal.cx> <1402464261.5195.21.camel@marge.simpson.net>
 <1402465808.3645.454.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140611151511.GU179@brightrain.aerifal.cx> <CAKgNAkh7ihJyZ4gOXAeb3x-Su7ayshLdi9m6ML4n840n3bx=0Q@mail.gmail.com>
 <20140612141327.GY179@brightrain.aerifal.cx>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Mike Galbraith <umgwanakikbuti@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Rich Felker <dalias@libc.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140612141327.GY179@brightrain.aerifal.cx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rich,

On Thu, Jun 12, 2014 at 4:13 PM, Rich Felker <dalias@libc.org> wrote:
> On Thu, Jun 12, 2014 at 08:04:54AM +0200, Michael Kerrisk (man-pages) wrote:
>> Rich,
>>
>> On Wed, Jun 11, 2014 at 5:15 PM, Rich Felker <dalias@libc.org> wrote:
>> > On Tue, Jun 10, 2014 at 10:50:08PM -0700, Eric Dumazet wrote:
>> >> On Wed, 2014-06-11 at 07:24 +0200, Mike Galbraith wrote:
>> >> > (CCs network wizard hangout)
>> >> >
>> >> > On Wed, 2014-06-11 at 00:12 -0400, Rich Felker wrote:
>> >> > > While looking to add support for the recvmmsg and sendmmsg syscalls in
>> >> > > musl libc, I ran into some disturbing findings on the kernel side. In
>> >> > > the struct mmsghdr, the field where the result for each message is
>> >> > > stored has type int, which is inconsistent with the return type
>> >> > > ssize_t of recvmsg/sendmsg. So I tried to track down what happens when
>> >> > > the result is or would be larger than 2GB, and quickly found an
>> >> > > explanation for why the type in the structure was defined wrong:
>> >> > > internally, the kernel uses int as the return type for revcmsg and
>> >> > > sendmsg. Oops.
>> >> > >
>> >> > > A bit more RTFS'ing brought me to tcp_sendmsg in net/ipv4/tcp.c (I
>> >> > > figured let's look at a stream-based protocol, since datagrams can
>> >> > > likely never be that big for any existing protocol), and as far as I
>> >> > > can tell, it's haphazardly mixing int and size_t with no checks for
>> >> > > overflows. I looked for anywhere the kernel might try to verify before
>> >> > > starting that the sum of the lengths of all the iovec components
>> >> > > doesn't overflow INT_MAX or even SIZE_MAX, but didn't find any such
>> >> > > checks.
>> >> > >
>> >> > > Is there some magic that makes this all safe, or is this a big mess of
>> >> > > possibly-security-relevant bugs?
>> >> > >
>> >> > > Rich
>> >> > > --
>> >> > > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> >> > > the body of a message to majordomo@vger.kernel.org
>> >> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> >> > > Please read the FAQ at  http://www.tux.org/lkml/
>> >> >
>> >>
>> >>
>> >> See commit 8acfe468b0384e834a303f08ebc4953d72fb690a
>> >> ("net: Limit socket I/O iovec total length to INT_MAX.")
>> >>
>> >> (or grep for verify_iovec() )
>> >
>> > Thanks; that addresses my concern about safety. There's still the ugly
>> > API inconsistency which it seems too late to fix. Michael, perhaps
>> > this should at least be documented in the man pages for sendmmsg and
>> > recvmmsg since it's certain to be confusing to anyone familiar with
>> > the sendmsg and recvmsg API, but not with kernel internals, who's
>> > trying to use these functions...
>>
>> Care to send me a patch?
>
> I'm not at all familiar with man format, but I could write some
> suggested text if that would be ok.

I would take raw text. Or, better a patch where you just make crummy
mistakes with groff. I'll fix them. ;-)

> Unrelated (at least not directly) to man pages, one concern I have is
> that, if these interfaces move towards standardization, the
> inconsistent return type is going to be a point of contention that
> could result in an incompatible version of the interfaces being
> adopted in the standard. From that standpoint, it might make sense to
> do something like documenting them returning socklen_t rather than
> int (IIRC these are always the same on Linux). It's not quite logical,
> but at least a bit more logical from a non-Linux-centric perspective
> than using int.

I'm not sure what I think about that yet. I'd probably have a better
idea when I get the above text.

Cheers,

Michael

PS No reply from you on the "Very bad advice in man 2 dup2" thread
despite a ping or two. What's up?

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
