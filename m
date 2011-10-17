From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reduce memory needs of out of order queue
Date: Sun, 16 Oct 2011 20:53:29 -0400 (EDT)
Message-ID: <20111016.205329.560591300167306483.davem@davemloft.net>
References: <4E98B3B4.20406@hp.com>
	<20111014.191845.232827637484150228.davem@davemloft.net>
	<1318661682.2525.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab1JQAxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Oct 2011 20:53:46 -0400
In-Reply-To: <1318661682.2525.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 15 Oct 2011 08:54:42 +0200

> I think the problem is in TCP layer (and maybe in other protocols) :
> 
> 1) Either tune rcvbuf to allow more memory to be used, for a particular
> tcp window,
> 
>    Or lower TCP window to allow less packets in flight for a given
> rcvbuf.
> 
> 2) TCP COLLAPSE already is trying to reduce memory costs of a tcp socket
> with many packets in OFO queue. But fixing 1) would make these collapses
> never happen in the first place. People wanting high TCP bandwidth
> [ with say more than 500 in-flight packets per session ] can certainly
> afford having enough memory.

So perhaps the best solution is to divorce truesize from such driver
and device details?  If there is one calculation, then TCP need only
be concerned with one case.

Look at how confusing and useless tcp_adv_win_scale ends up being for
this problem.

Therefore I'll make the mostly-serious propsal that truesize be
something like "initial_real_total_data + sizeof(metadata)"

So if a device receives a 512 byte packet, it's:

	512 + sizeof(metadata)

It still provides the necessary protection that truesize is meant to
provide, yet sanitizes all of the receive and send buffer overhead
handling.

TCP should be absoultely, and completely, impervious to details like
how buffering needs to be done for some random wireless card.  Just
the mere fact that using a larger buffer in a driver ruins TCP
performance indicates a serious design failure.
