From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: SACK scoreboard
Date: Tue, 8 Jan 2008 14:12:47 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801081258050.12911@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>
 <20071211.043239.224938181.davem@davemloft.net>
 <Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi>
 <20080107.233617.203640686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lachlan.andrew@gmail.com, Netdev <netdev@vger.kernel.org>,
	quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55882 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbYAHMMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 07:12:50 -0500
In-Reply-To: <20080107.233617.203640686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jan 2008, David Miller wrote:

> Did you happen to read a recent blog posting of mine?
> 
> 	http://vger.kernel.org/~davem/cgi-bin/blog.cgi/2007/12/31#tcp_overhead
> 
> I've been thinking more and more and I think we might be able
> to get away with enforcing that SACKs are always increasing in
> coverage.
> 
> I doubt there are any real systems out there that drop out of order
> packets that are properly formed and are in window, even though the
> SACK specification (foolishly, in my opinion) allows this.

Luckily we can see that already from MIBs, so quering people who have 
large servers, which are continously "testing" the internet :-), under 
their supervision or can access, and asking if they see any might help.
I checked my dept's interactive servers and all had zero renegings, but
I don't think I have access to www server which would have much wider 
exposure.

> If we could free packets as SACK blocks cover them, all the problems
> go away.

I thought it a bit yesterday after reading your blog and came to 
conclusion that they won't, we can still get those nasty ACKs regardless 
of received SACK info (in here, missing). Even in some valid cases which 
include ACK losses besides actual data loss, not that this is the most 
common case but just wanted to point out that cleanup work is at least 
partially independent of SACK problem. So not "all" problems would go
away really.

> For one thing, this will allow the retransmit queue liberation during
> loss recovery to be spread out over the event, instead of batched up
> like crazy to the point where the cumulative ACK finally moves and
> releases an entire window's worth of data.

Two key cases for real pattern are:

1. Losses once per n, where n is something small, like 2-20 or so, usually
   happens at slow start overshoot or when compething traffic slow starts. 
   Cumulative ACKs will cover only small part of the window once rexmits 
   make through, thus this is not a problem.
2. Single loss (or few at the beginning of the window), rest SACKed. 
   Cumulative ACK will cover original window when the last necessary 
   rexmit gets through.

Case 1 becomes nasty ACKy only if rexmit is lost as well, but in that case 
the arriving SACK blocks make the rest of the window equal to 2 :-).

So I'm now trying to solve just case 2. What if we could somehow "combine" 
adjacent skbs (or whatever they're called in that model) if SACK covers 
them both so that we still hold them but can drop them in a very 
efficient way. That would make the combining effort split per ACK. 
And if reneging would occur, we can think a way to put the necessary fuzz 
into a form which cannot hurt the rest of the system (relatively easy & 
fast if we add CA_Reneging and allow retransmitting a portion of an skb 
similar to what you suggested earlier).

And it might even be possible then to offer admin a control so that the 
admin can choose between recover/plain reset if admin thinks that it's 
always an indication of an attack. This is somewhat similar case to what 
UTO (under IETF evaluation) does, as purpose of both is in violation of 
RFC TCP to avoid malicious traps but the control about it is left to the 
user.

> Next, it would simplify all of this scanning code trying to figure out
> which holes to fill during recovery.
> 
> And for SACK scoreboard marking, the RB trie would become very nearly
> unecessary as far as I can tell.

I've been contacted by a person who was interested in reaching 500k 
windows, so your 4000 sounded like a joke :-/. Having, let say, every
20th dropped means 25k skbs remaining, can we scan though it in any
sensible time without RBs and friends :-)? However, allowing queue walk
to begin from either direction would solve most of the common cases well 
enough for it to be nearly manageable.

> I would not even entertain this kind of crazy idea unless I thought
> the fundamental complexity simplification payback was enormous.  And
> in this case I think it is.
> 
> What we could do is put some experimental hack in there for developers
> to start playing with, which would enforce that SACKs always increase
> in coverage.  If violated the connection reset and a verbose log
> message is logged so we can analyze any cases that occur.

We have an initial number already, in MIBs.

> Sounds crazy, but maybe has potential.  What do you think?

If I'd hint my boss that I'm involved in something like this I'd
bet that he also would get quite crazy... ;-) I'm partially paid
for making TCP more RFCish :-), or at least that the places where
thing diverge are known and controllable for research purposes.


-- 
 i.

ps. If other Cced would like to get dropped if there are some followups, 
just let me know :-). Else, no need to do anything.
