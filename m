From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] inet: prevent leakage of uninitialized memory to
 user in recv syscalls
Date: Mon, 18 Nov 2013 15:14:30 -0500 (EST)
Message-ID: <20131118.151430.75221704090778394.davem@davemloft.net>
References: <1384648584.8604.39.camel@edumazet-glaptop2.roam.corp.google.com>
	<20131117192240.GI16541@order.stressinduktion.org>
	<20131118032045.GJ16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mpb.mail@gmail.com, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab3KRUOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 15:14:33 -0500
In-Reply-To: <20131118032045.GJ16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 18 Nov 2013 04:20:45 +0100

> Only update *addr_len when we actually fill in sockaddr, otherwise we
> can return uninitialized memory from the stack to the caller in the
> recvfrom, recvmmsg and recvmsg syscalls. Drop the the (addr_len == NULL)
> checks because we only get called with a valid addr_len pointer either
> from sock_common_recvmsg or inet_recvmsg.
> 
> If a blocking read waits on a socket which is concurrently shut down we
> now return zero and set msg_msgnamelen to 0.
> 
> Reported-by: mpb <mpb.mail@gmail.com>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
> This is the first round, fixing the callees of sock_common_recvmsg and
> inet_recvmsg. I guess there are some more problems of this kind with
> recvmsg called directly via proto_ops->recvmsg. I will have a look at
> them in the next days.
> 
> We could actually leave out filling in msg_name if the user didn't request
> (src_addr == NULL in recvfrom). I'll put this on my TODO for net-next.
> Also it is possible to just update msg->msg_namelen directly here and simplify
> sock_common_recvmsg and inet_recvmsg, also for net-next.

This looks a lot better than your previous attempts, nice work.

Applied and queued up for -stable.

The handling of msg_name/msg_namelen in the ->recvmsg proto op is decidedly
non-trivial.  Can I suggest that we at least add some documentation about
this semantic above "(*recvmsg)" in the definition of proto_ops in
include/linux/net.h?

Thanks.
