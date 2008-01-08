From: John Heffner <jheffner@psc.edu>
Subject: Re: SACK scoreboard
Date: Tue, 08 Jan 2008 11:51:53 -0500
Message-ID: <4783AA29.3080406@psc.edu>
References: <Pine.LNX.4.64.0712081523470.17809@kivilampi-30.cs.helsinki.fi>	<20071211.043239.224938181.davem@davemloft.net>	<Pine.LNX.4.64.0712111547300.18529@kivilampi-30.cs.helsinki.fi> <20080107.233617.203640686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, lachlan.andrew@gmail.com,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:63046 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751965AbYAHQwN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 11:52:13 -0500
In-Reply-To: <20080107.233617.203640686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> Ilpo, just trying to keep an old conversation from dying off.
> 
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
> 
> If we could free packets as SACK blocks cover them, all the problems
> go away.
> 
> For one thing, this will allow the retransmit queue liberation during
> loss recovery to be spread out over the event, instead of batched up
> like crazy to the point where the cumulative ACK finally moves and
> releases an entire window's worth of data.
> 
> Next, it would simplify all of this scanning code trying to figure out
> which holes to fill during recovery.
> 
> And for SACK scoreboard marking, the RB trie would become very nearly
> unecessary as far as I can tell.
> 
> I would not even entertain this kind of crazy idea unless I thought
> the fundamental complexity simplification payback was enormous.  And
> in this case I think it is.
> 
> What we could do is put some experimental hack in there for developers
> to start playing with, which would enforce that SACKs always increase
> in coverage.  If violated the connection reset and a verbose log
> message is logged so we can analyze any cases that occur.
> 
> Sounds crazy, but maybe has potential.  What do you think?


Linux has a code path where this can happen under memory over-commit, in 
tcp_prune_queue().  Also, I think one of the motivations for making SACK 
strictly advisory is there was some concern about buggy SACK 
implementations.  Keeping data in your retransmit queue allows you to 
fall back to timeout and go-back-n if things completely fall apart.  For 
better or worse, we have to deal with the spec the way it is.

Even if you made this assumption of "hard" SACKs, you still have to 
worry about large ACKs if SACK is disabled, though I guess you could say 
people running with large windows without SACK deserve what they get. :)


I haven't thought about this too hard, but can we approximate this by 
moving scaked data into a sacked queue, then if something bad happens 
merge this back into the retransmit queue?  The code will have to deal 
with non-contiguous data in the retransmit queue; I'm not sure offhand 
if that violates any assumptions.  You still have a single expensive ACK 
at the end of recovery, though I wonder how much this really hurts.  If 
you want to ameliorate this, you could save this sacked queue to be 
batch processed later, in application context for instance.

   -John


