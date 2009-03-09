From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Mon, 9 Mar 2009 21:05:05 +0100
Message-ID: <20090309200505.GA58375@bts.sk>
References: <20090309112521.GB37984@bts.sk> <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:56886 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751719AbZCIUFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 16:05:06 -0400
Received: from md by saus.bts.sk with local (Exim 4.69 (FreeBSD))
	(envelope-from <md@bts.sk>)
	id 1Lglij-000FD8-Om
	for netdev@vger.kernel.org; Mon, 09 Mar 2009 21:05:05 +0100
Content-Disposition: inline
In-Reply-To: <1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 9 Mar 2009 11:01:52 -0700, John Heffner wrote
> On Mon, Mar 9, 2009 at 4:25 AM, Marian =C4=8Eurkovi=C4=8D <md@bts.sk>=
 wrote:
> >   As rx window autotuning is enabled in all recent kernels and with=
 1 GB
> > of RAM the maximum tcp_rmem becomes 4 MB, this problem is spreading
> >   rapidly
> > and we believe it needs urgent attention. As demontrated above, suc=
h
> >   huge
> > rx window (which is at least 100*BDP of the example above) does not
> >   deliver
> > any performance gain but instead it seriously harms other hosts and=
/or
> > applications. It should also be noted, that host with autotuning en=
abled
> > steals an unfair share of the total available bandwidth, which migh=
t
> > look
> > like a "better" performing TCP stack at first sight - however such
> > behaviour
> > is not appropriate (RFC2914, section 3.2).
>
> It's well known that "standard" TCP fills all available drop-tail
> buffers, and that this behavior is not desirable.

Well, in practice that was always limited by receive window size, which
was by default 64 kB on most operating systems. So this undesirable beh=
avior
was limited to hosts where receive window was manually increased to hug=
e
values.

Today, the real effect of autotuning is the same as changing the receiv=
e window
size to 4 MB on *all* hosts, since there's no mechanism to prevent it f=
rom
growing the window to maximum even for low RTT paths.

> The situation you describe is exactly what congestion control (the
> topic of RFC2914) should fix.  It is not the role of receive window
> (flow control).  It is really the sender's job to detect and react to
> this, not the receiver's.  (We have had this discussion before on
> netdev.)

It's not of high importance whose job it is according to pure theory.
What matters is, that autotuning introduced serious problem at LAN cont=
ext
by disabling any possibility to properly react to increasing RTT. Again=
,
it's not important whether this functionality was there by design or by
coincidence, but it was holding the system well-balanced for many years=
=2E

Now, as autotuning is enabled by default in stock kernel, this problem =
is
spreading into LANs without users even knowing what's going on. Therefo=
re
I'd like to suggest to look for a decent fix which could be implemented
in relatively short time frame. My proposal is this:

- measure RTT during the initial phase of TCP connection (first X segme=
nts)
- compute maximal receive window size depending on measured RTT using
  configurable constant representing the bandwidth part of BDP
- let autotuning do its work upto that limit.

  With kind regards,

        M.=20
