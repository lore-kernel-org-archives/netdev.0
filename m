From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 23:49:41 -0700
Message-ID: <1458888581.6473.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160324153053.GA7569@1wt.eu>
	 <1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160324165047.GA7585@1wt.eu>
	 <1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	 <56F42A00.7050002@iogearbox.net>
	 <CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
	 <1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKQ1sVPJoaaf1gRfgYPRygfMFVqk08Q0K74wn6kLHV+vy=8w1w@mail.gmail.com>
	 <CALx6S37uZah89sNgH9wuD1J+_WEhd34Z5zmrnG8Qp-AQ7Ew=Jg@mail.gmail.com>
	 <20160325052819.GA8548@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Yann Ylavic <ylavic.dev@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34229 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbcCYGtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 02:49:45 -0400
Received: by mail-pa0-f41.google.com with SMTP id fe3so40539026pab.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 23:49:44 -0700 (PDT)
In-Reply-To: <20160325052819.GA8548@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-25 at 06:28 +0100, Willy Tarreau wrote:
> On Thu, Mar 24, 2016 at 04:54:03PM -0700, Tom Herbert wrote:
> > On Thu, Mar 24, 2016 at 4:40 PM, Yann Ylavic <ylavic.dev@gmail.com> wrote:
> > > I'll learn how to do this to get the best performances from the
> > > server, but having to do so to work around what looks like a defect
> > > (for simple/default SMP configurations at least, no NUMA or clever
> > > CPU-affinity or queuing policy involved) seems odd in the first place.
> > >
> > I disagree with your assessment that there is a defect. SO_REUSEPORT
> > is designed to spread packets amongst _equivalent_ connections. In the
> > server draining case sockets are no longer equivalent, but that is a
> > special case.
> 
> I partially disagree with you here Tom. Initially SO_REUSEPORT was not
> used to spread packets but to allow soft restart in some applications.
> I've been using it since 2001 in haproxy on *BSD and linux 2.2. It was
> removed during 2.3 and I used to keep a patch to reimplement it in 2.4
> (basically 2 or 3 lines, the infrastructure was still present), but the
> patch was not accepted. The same patch worked for 2.6 and 3.x, allowing
> me to continue to perform soft-restarts on Linux just like I used to do
> on *BSD. When SO_REUSEPORT was reimplemented in 3.9 with load balancing,
> I was happy because it at last allowed me to drop my patch and I got
> the extra benefit of better load balancing of incoming connections.
> 
> But the main use we have for it (at least historically) is for soft
> restarts, where one process replaces another one. Very few people use
> more than one process in our case.
> 
> However given the benefits of the load spreading for extreme loads,
> I'm willing to find how to achieve the same with BPF, but it's pretty
> clear that at this point I have no idea where to start from and that
> for a single process replacing a single one, it looks quite complicated.
> 
> For me quite frankly the special case is the load balancing which is
> a side benefit (and a nice one, don't get me wrong).
> 
> That's why I would have found it nice to "fix" the process replacement
> to avoid dropping incoming connections, though I don't want it to become
> a problem for future improvements on BPF. I don't think the two lines I
> proposed could become an issue but I'll live without them (or continue
> to apply this patch).
> 
> BTW, I have no problem with having to write a little bit of assembly for
> fast interfaces if it remains untouched for years, we do already have a
> bit in haproxy. It's just a longterm investment.

Everything is possible, but do not complain because BPF went in the
kernel before your changes.

Just rework your patch.

Supporting multiple SO_REUSEPORT groups on the same port should not be
too hard really. Making sure BPF still work for them is feasible.

But the semantic of the socket option would be really different.

You need to not control an individual listener, but a group of listener.

Your dying haproxy would issue a single system call to tell the kernel :
My SO_REUSEPORT group should not accept new SYN packets, so that the new
haproxy can setup a working new SO_REUSEPORT group.
