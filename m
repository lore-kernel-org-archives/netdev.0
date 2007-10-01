From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.21 -> 2.6.22 & 2.6.23-rc8 performance regression
Date: Mon, 01 Oct 2007 00:12:59 -0700 (PDT)
Message-ID: <20071001.001259.28812610.davem@davemloft.net>
References: <200709301425.37564.nickpiggin@yahoo.com.au>
	<20070930223503.M8966@nuclearcat.com>
	<47008CB0.7010808@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nuclearcat@nuclearcat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37947
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbXJAHM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 03:12:59 -0400
In-Reply-To: <47008CB0.7010808@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 01 Oct 2007 07:59:12 +0200

> No problem here on bigger servers, so I CC David Miller and netdev
> on this one.  AFAIK do_gettimeofday() and ktime_get_real() should
> use the same underlying hardware functions on PC and no performance
> problem should happen here.

One thing that jumps out at me is that on 32-bit (and to a certain
extent on 64-bit) there is a lot of stack accesses and missed
optimizations because all of the work occurs, and gets expanded,
inside of ktime_get_real().

The timespec_to_ktime() inside of there constructs the ktime_t return
value on the stack, then returns that as an aggregate to the caller.

That cannot be without some cost.

ktime_get_real() is definitely a candidate for inlining especially in
these kinds of cases where we'll happily get computations in local
registers instead of all of this on-stack nonsense.  And in several
cases (if the caller only needs the tv_sec value, for example)
computations can be elided entirely.

It would be constructive to experiment and see if this is in fact part
of the problem.

