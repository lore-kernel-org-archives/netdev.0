From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 23:22:42 +0100
Message-ID: <20151124222242.GD23215@breakpoint.cc>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
 <CALx6S35uHQS1n7GYATZ-3UwLFhdiShdVzTBzEgdkKsQrmdpXZw@mail.gmail.com>
 <20151124171650.GA23215@breakpoint.cc>
 <CALx6S36qHkUhz5VN+xvsMhszTQnCUUhQ+Doja86wLGWJEe_u_A@mail.gmail.com>
 <20151124205537.GC23215@breakpoint.cc>
 <CALx6S36oFH9=Px=pptZurWgS1MtFbhOE=FeK0jZmNBk3fU7tSg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>, davejwatson@fb.com,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:60183 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754376AbbKXWWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 17:22:48 -0500
Content-Disposition: inline
In-Reply-To: <CALx6S36oFH9=Px=pptZurWgS1MtFbhOE=FeK0jZmNBk3fU7tSg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> On Tue, Nov 24, 2015 at 12:55 PM, Florian Westphal <fw@strlen.de> wrote:
> > Why anyone would invest such a huge amount of work in making this
> > kernel-based framing for single-stream tcp record (de)mux rather than
> > improving the userspace protocol to use UDP or SCTP or at least
> > one tcp connection per worker is beyond me.
> >
> From the /0 patch:
> 
> Q: Why not use an existing message-oriented protocol such as RUDP,
>    DCCP, SCTP, RDS, and others?
> 
> A: Because that would entail using a completely new transport protocol.

Thats why I wrote 'or at least one tcp connection per worker'.

> > For TX side, why is writev not good enough?
> 
> writev on a TCP stream does not guarantee atomicity of the operation.

Are you talking about short writes?

> It writes atomic without user space needing to implement locking when
> a socket is shared amongst threads.

Yes, I get that point, but I maintain that KCM is a strange workaround
for bad userspace design.

1 tcp connection per thread -> no userspace sockfd lock needed

Sender side can use writev, sendmsg, sendmmsg, etc to avoid sending
sub-record sized frames.

Is user space really so bad that instead of fixing it its simpler to
work around it with even more kernel bloat?

Since for KCM userspace has to be adjusted anyway I find that hard
to believe.

I don't know if the 'dynamic RCVLOWAT' that you want is needed
(you say 'yes', Eric reply seems to indicate its not (at least assuming
 a sane/friendly peer that doesn't intentionally xmit byte-by-byte).

But assuming there would really be a benefit, maybe a RCVLOWAT2 could
be added?  Of course we could only make it a hint and would have to
make a blocking read return with less data than desired when tcp rmem limit
gets hit.  But at least we'd avoid the 'unbounded allocation of large
amount of kernel memory' thing that we have with current proposal.

Thanks,
Florian
