From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP event tracking via netlink...
Date: Fri, 7 Dec 2007 18:43:47 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712071307290.18529@kivilampi-30.cs.helsinki.fi>
References: <20071205.053031.87154402.davem@davemloft.net>
 <Pine.LNX.4.64.0712051533050.3119@kivilampi-30.cs.helsinki.fi>
 <20071206.023346.256200942.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1595765661-1197030059=:18529"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43052 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbXLGQnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 11:43:50 -0500
In-Reply-To: <20071206.023346.256200942.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0712071825060.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1595765661-1197030059=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712071434381.18529@kivilampi-30.cs.helsinki.fi>

On Thu, 6 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Thu, 6 Dec 2007 01:18:28 +0200 (EET)
> 
> > On Wed, 5 Dec 2007, David Miller wrote:
> > 
> > > I assume you're using something like carefully crafted printk's,
> > > kprobes, or even ad-hoc statistic counters.  That's what I used to do
> > > :-)
> > 
> > No, that's not at all what I do :-). I usually look time-seq graphs 
> > expect for the cases when I just find things out by reading code (or
> > by just thinking of it).
> 
> Can you briefly detail what graph tools and command lines
> you are using?

I have a tool called Sealion but it's behind NDA (making it open source 
has been talked for long but I don't have idea why it hasn't realized 
yet). It's mostly tcl/tk code is, by no means nice or clean desing nor 
quality (I'll leave details why I think it's that way out of this 
discussion :-)). Produces svgs. Usually I'm have the things I need in 
the standard sent+ACK+SACKs(+win) graph it produces. The result is quite 
similar to what tcptrace+xplot produces but xplot UI is really horrible, 
IMHO.

If I have to deal with tcpdump output only, it takes considerable amount 
of time to do computations with bc to come up with the same understanding 
by just reading tcpdumps.

> The last time I did graphing to analyze things, the tools
> were hit-or-miss.

Yeah, this is definately true. Open source graphing tools I know are 
really not that astonishing :-(. I've tried to look for better tools
as well but with little success.

> > Much of the info is available in tcpdump already, it's just hard to read 
> > without graphing it first because there are some many overlapping things 
> > to track in two-dimensional space.
> > 
> > ...But yes, I have to admit that couple of problems come to my mind
> > where having some variable from tcp_sock would have made the problem
> > more obvious.
> 
> The most important are the cwnd and ssthresh, which you could guess
> using graphs but it is important to know on a packet to packet
> basis why we might have sent a packet or not because this has
> rippling effects down the rest of the RTT.

Couple of points:

In order to evaluate validity of some action, one might need more than
one packet from the history.

Answer to the why we have sent a packet is rather simple (excluding RTOs): 
cwnd > packets_in_flight and data was available. No, it's not at all 
complicated. Though I might be too biased toward non-application limited 
cases which make the formula even simpler because everything is basically 
ACK clocked.

To really tell what caused changes between cwnd and/or packets_in_flight 
one usually needs some history or more fine-grained approach, once per 
packet is way too wide gap. It tells just what happened, not why, unless 
you're really familiar with the state machine and can make the right 
guess.

> > Not sure what is the benefit of having distributions with it because 
> > those people hardly report problems anyway to here, they're just too 
> > happy with TCP performance unless we print something to their logs,
> > which implies that we must setup a *_ON() condition :-(.
> 
> That may be true, but if we could integrate the information with
> tcpdumps, we could gather internal state using tools the user
> already has available.

It would definately help if we could, but that of course depends on 
getting the reports in the first place.

> Imagine if tcpdump printed out:
> 
> 02:26:14.865805 IP $SRC > $DEST: . 11226:12686(1460) ack 0 win 108
> 	ss_thresh: 129 cwnd: 133 packets_out: 132
> 
> or something like that.

How about this:

02:26:14.865805 IP $SRC > $DEST: . ack 11226 win 108 <...sack 1 {15606:18526}
17066:18526 0->S sacktag_one l0 s1 r0 f4 pc1 ...
11226:12686 ---- clean_rtx_queue ...
11226:12686 0->L mark_head_lost l1 s1 r0 f4 pc1 ...
12686:14146 0->L mark_head_lost l2 s1 r0 f4 pc1 ...
11226:12686 L->LRe retransmit_skb l2 s1 r1 f4 pc1 ...

...would make the bug in sack processing relatively obvious (yes, it 
has an intentional flaw in it, points from find it :-))... That would
be something I'd like to have right now.

> But sometimes the algorithms are working as designed, it's just that
> they provide poor pipe utilization and CWND analysis embedded inside
> of a tcpdump would be one way to see that as well as determine the
> flaw in the algorithm.

Fair enough.


> It is untested since I didn't write the userland app yet to see that
> proper things get logged.  Basically you could run a daemon that
> writes per-connection traces into files based upon the incoming
> netlink events.  Later, using the binary pcap file and these traces,
> you can piece together traces like the above using the timestamps
> etc. to match up pcap packets to ones from the TCP logger.
>
> The userland tools could do analysis and print pre-cooked state diff
> logs, like "this ACK raised CWND by one" or whatever else you wanted
> to know.

Obviously a collection of useful userland tools seems here at least as 
important as the existance of the interface.

> It's nice that an expert like you can look at graphs and understand,
> but we'd like to create more experts and besides reading code one
> way to become an expert is to be able to extrace live real data
> from the kernel's working state and try to understand how things
> got that way.  This information is permanently lost currently.

IMHO this problem is in such caliber that no human can track efficiently 
more than a couple of packets of a TCP flow from text only view, without 
headaches I mean, or are you able to do that at ease? And we're talking 
here about the people who have just begun to deal with TCP. ...For me 
especially those nearly identical seqnos all around are too overwhelming 
to track in any sane way and I'd expect that most feel the same way.

I'd state my point different way around (with the terms you chose): it is 
very difficult to become an expert without looking some graphs, we may 
disagree and that's fine :-). I think it's because one would then have no 
idea about larger picture (and about the very _relevant_ past/future) when 
looking just a single line at a time from the tcpdump (or equivalent). Sad 
thing is that a good tool to do the visulization might not exist.


-- 
 i.
---696243703-1595765661-1197030059=:18529--
