From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Mon, 19 May 2008 00:03:28 -0700 (PDT)
Message-ID: <20080519.000328.16713955.davem@davemloft.net>
References: <200805162032.48469.rusty@rustcorp.com.au>
	<20080516.124039.253626477.davem@davemloft.net>
	<200805191308.14548.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, mb@bu3sch.de,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, ron.rindjunsky@intel.com, tomasw@gmail.com,
	ivdoorn@gmail.com, peter.p.waskiewicz.jr@intel.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752457AbYESHDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 03:03:33 -0400
In-Reply-To: <200805191308.14548.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 19 May 2008 13:08:13 +1000

> The bit I can't see is what to do about qdisc if the driver manages its own 
> queue(s).  Leave the qdisc as currently in place and have the driver call 
> dev_dequeue_skb() (or some wrapper) directly?  Modulo locking issues, that 
> should be a fairly simple change.

I'd like to approach a state where the device is just a black hole
that the qdisc injects packets into.  At least theoretically, that's
what the network is once the packet leaves the device anyways.  Nobody
really notices as long as flows don't get reordered.

I realize it isn't feasible to retain many of the qualities that some
qdiscs want (rates, qfull handling, etc.), so we'll have to provide
some handling for that, ideally in some cheap slowpath test.

But for things like tx queue backlog overflow the behavior would
be essentially the same.  The only change is that the txqueuelen
parameter is handled inside of the driver (again, perhaps via
helpers).

Our TX path is way too complicated and, frankly, restrictive.

This is why we don't have real parallel TX multiqueue support as a
simple patch to some drivers.  We have fundamental restrictions that
keep that from happening.
