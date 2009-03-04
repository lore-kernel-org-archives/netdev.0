From: David Miller <davem@davemloft.net>
Subject: Re: Multicast packet loss
Date: Wed, 04 Mar 2009 00:16:46 -0800 (PST)
Message-ID: <20090304.001646.100690134.davem@davemloft.net>
References: <20090204012144.GC3650@localhost.localdomain>
	<49A6CE39.5050200@athenacr.com>
	<49A8FAFF.7060104@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kchang@athenacr.com, netdev@vger.kernel.org,
	cl@linux-foundation.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751829AbZCDIRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 03:17:02 -0500
In-Reply-To: <49A8FAFF.7060104@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 28 Feb 2009 09:51:11 +0100

> David, this is a preliminary work, not meant for inclusion as is,
> comments are welcome.
> 
> [PATCH] net: sk_forward_alloc becomes an atomic_t
> 
> Commit 95766fff6b9a78d11fc2d3812dd035381690b55d
> (UDP: Add memory accounting) introduced a regression for high rate UDP flows,
> because of extra lock_sock() in udp_recvmsg()
> 
> In order to reduce need for lock_sock() in UDP receive path, we might need
> to declare sk_forward_alloc as an atomic_t.
> 
> udp_recvmsg() can avoid a lock_sock()/release_sock() pair.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

This adds new overhead for TCP which has to hold the socket
lock for other reasons in these paths.

I don't get how an atomic_t operation is cheaper than a
lock_sock/release_sock.  Is it the case that in many
executions of these paths only atomic_read()'s are necessary?

I actually think this scheme is racy.  There is a reason we
have to hold the socket lock when doing memory scheduling.
Two threads can get in there and say "hey I have enough space
already" even though only enough space is allocated for one
of their requests.

What did I miss? :)

