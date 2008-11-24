From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: avoid a pair of dst_hold()/dst_release() in
 ip_append_data()
Date: Mon, 24 Nov 2008 15:55:31 -0800 (PST)
Message-ID: <20081124.155531.135918197.davem@davemloft.net>
References: <87y6z9h33h.fsf@basil.nowhere.org>
	<492A7E85.3060502@cosmosbay.com>
	<492A8F05.3080509@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, minyard@acm.org,
	christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50240
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754133AbYKXXzc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 18:55:32 -0500
In-Reply-To: <492A8F05.3080509@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 24 Nov 2008 12:24:53 +0100

> [PATCH] net: avoid a pair of dst_hold()/dst_release() in ip_append_data()
> 
> We can reduce pressure on dst entry refcount that slowdown UDP transmit
> path on SMP machines. This pressure is visible on RTP servers when
> delivering content to mediagateways, especially big ones, handling
> thousand of streams. Several cpus send UDP frames to the same
> destination, hence use the same dst entry.
> 
> This patch makes ip_append_data() eventually steal the refcount its
> callers had to take on the dst entry.
> 
> This doesnt avoid all refcounting, but still gives speedups on SMP,
> on UDP/RAW transmit path
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Ok, this looks fine to me, thanks Eric.  Although as you know
I'm not a big fan of pass by reference arguments :-)

Thinking more I believe we can do similar tricks for all TCP
transmit traffic.

Packets bound to sockets never outlive those sockets (and thus
their cached routes) unless we skb_orphan().

The only not covered case is where the socket cached route
is reset or changed.  We could defer the dst put until the
transmit queue reaches a certain point, kind of like a retransmit
queue RCU :-)

Just some ideas...
