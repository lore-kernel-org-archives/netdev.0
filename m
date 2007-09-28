From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Make TCP prequeue configurable
Date: Fri, 28 Sep 2007 15:40:31 -0700 (PDT)
Message-ID: <20070928.154031.99471318.davem@davemloft.net>
References: <46FC29E1.9010809@cosmosbay.com>
	<20070927154432.6ca3b525@freepuppy.rosehill>
	<46FC663A.6030601@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57658
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753478AbXI1Wkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 18:40:31 -0400
In-Reply-To: <46FC663A.6030601@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Thu, 27 Sep 2007 22:26:02 -0400

> I think it really does help in case (4) with old NICs that don't do rx 
> checksumming.  I'm not sure how many people really care about this 
> anymore, but probably some...?
> 
> OTOH, it would be nice to get rid of sysctl_tcp_low_latency.

I know most high end apps use poll() so won't sleep in recvmsg()
directly, but occasisionally they will, and even those that have a
poll() triggered recvmsg() will run the backlog and do prequeue if
packets arrive while they are processing the existing receive packets
which is quite common.

So for any app that ends up doing a prequeue it's a win because there
is the issue of scheduling and cpu usage charging.

If the ACK's are coming out of the stack at the rate that the
application can pull data out of the receive queue, and no faster,
this will pace the sender to send precisely how fast the receiver can
get onto the cpu depending upon load.

Furthermore, prequeue puts the stack input processing work into user
context, which means that the users will be charged more fairly for
the work that is done for them.

When packets get fully processed in softirq context, that's bad
because this is cpu usage which doesn't get charged to the user, and
for TCP input processing this cpu usage is non-trivial and is
multiplied by packet count.
