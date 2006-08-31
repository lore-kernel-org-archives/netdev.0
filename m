From: David Miller <davem@davemloft.net>
Subject: Re: high latency with TCP connections
Date: Thu, 31 Aug 2006 16:57:01 -0700 (PDT)
Message-ID: <20060831.165701.104033558.davem@davemloft.net>
References: <20060831151456.12a4e080@dxpl.pdx.osdl.net>
	<20060831.154428.35684218.davem@davemloft.net>
	<20060831232923.GA10036@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47565
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932493AbWHaX5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 19:57:03 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060831232923.GA10036@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Fri, 1 Sep 2006 03:29:23 +0400

> > 2) a way to take delayed ACKs into account for cwnd growth
> 
> This part is OK now, right?

This part of ABC is not on by default, and was broken until last week
:-)

Test in tcp_slow_start() used to be:

	tp->bytes_acked > 2*tp->mss_cache

but now it is the correct:

	tp->bytes_acked >= 2*tp->mss_cache

It allows to make two congestion window increases from one ACK, when
noticing delayed ACK.

Non-ABC code did not do this, but could figure this kind of thing
out while scanning retransmit queue.

> > 1) protection against ACK division
> 
> But Linux never had this problem... Congestion window was increased
> only when a whole skb is ACKed, flag FLAG_DATA_ACKED. (TSO could
> break this, but should not). Otherwise, this ACK just advanced snd_una
> and nothing more.

Ugh, I missed this. :-/

The TSO code is carefuly to only trim TSO skbs on proper boundaries,
and this ensures proper setting of FLAG_DATA_ACKED too.  So no
problems here.

> The only problem of kind "too-aggressive" with Linux was that we could
> develop large cwnd sending small segments, and then switch to sending
> mss-sized segments. It does not look scary, to be honest. :-)

Agreed.

> Linux had troubles with slow start even before ABC. Actually,
> some of applications can suffer of the same syndrome even if ABC disabled.
> With ABC it becomes TROUBLE, cwnd has no chances to develop at all.

I've discussed that very issue here before, some time ago, with
John Heffner.  It was in response to a user reporting a similar
problem.  The problem is really at the receiver because we only
ACK every other full sized frame.  I had the idea to ACK every 2
frames, regardless of size, but that might have other problems.

There is an assymetry between how we do congestion control on
sending (packet counting) and our ACK policy on receive (packet
sized based).

> Probably, aspect 1 of ABC just should be disabled. And the first my
> suggestion looks working too.

I'm ready to rip out ABC entirely, to be honest.  Or at least
turn it off by default.
