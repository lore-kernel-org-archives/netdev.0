From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] tcp: avoid sending zero TSval
Date: Tue, 01 Sep 2009 18:16:06 -0700 (PDT)
Message-ID: <20090901.181606.110928566.davem@davemloft.net>
References: <200908312044.56235.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53255
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755306AbZIBBPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 21:15:52 -0400
In-Reply-To: <200908312044.56235.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Mon, 31 Aug 2009 20:44:56 +0300

> Per RFC1323, zero TSecr is considered invalid. Thus we must avoid when
> possible sending a zero TSval.
> 
> Currently, we use the least significant 32 bits of jiffies to fill in
> TSval. But that can wrap around to zero (in 5 minutes after reboot,
> and every 49 days after that in the worst case).
> 
> This patch approximate a wrap-around zero TSval to 1. This is better
> then emitting a value which will be ignored.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Ok, I've changed my mind again.  I think we need to go with
a solution like this.

Even if we could somehow justify allowing zero timestamps,
I just checked some other stacks and all of them ignore zero
tsecr values.  So we can't make that kind of change no matter
what.

This patch needs some changes.

We have to adjust the tests we make against tsecr.

If we bump up a zero jiffies to one in an advertised timestamp,
then we get back a tsecr value of one, and jiffies is still
zero, we should use a comparison value of one not zero.

This is not trivial.  You might think it's OK to handle all of
this by just adjusting the definition of tcp_time_stamp but that
gets used by a lot of other things in the stack so those side
effects need to be analyzed.

Grepping around also shows that we also have some code that doesn't
handle jiffies wraparound at all, f.e. check out the rcv_tsecr tests
in net/ipv4/tcp_lp.c :-/
