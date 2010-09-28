From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 16603] New: send of data > 4 GB fails on 64
 bit systems
Date: Mon, 27 Sep 2010 21:07:11 -0700 (PDT)
Message-ID: <20100927.210711.189689133.davem@davemloft.net>
References: <20100927161540.776f748e.akpm@linux-foundation.org>
	<20100927.202425.71120040.davem@davemloft.net>
	<20100927205624.1564649e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, bono@onlinehome.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49624
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750767Ab0I1EGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 00:06:51 -0400
In-Reply-To: <20100927205624.1564649e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 27 Sep 2010 20:56:24 -0700

> A blanket suckyfix might be, at the syscall level:
> 
> 	if (size > 4g) {
> 		do_it_in_4g_hunks();
> 		do_the_last_bit();
> 	}
> 
> unless that would break some networking syscall->framesize guarantees
> or something?

There is not a single length passed in, but a vector of them, that's
what the iovec conveys.

Even if you could, socket send calls have atomicity guarentees.  For a
datagram socket, for example, a single send call corresponds to one
packet on the network.

BTW, this aspect of datagram sockets is a part of the reason we don't
see many reports about this stuff. :-)  Only stream protocols can
really take such enormous lengths, and the most popular (TCP) does
much of the iovec handling by hand.

We just need to fix our junk, and the {min,max}_t(size_t, ...) change
I suggested is likely the easiest path.
