From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: fix sock_wake_async() rcu protection
Date: Tue, 01 Dec 2015 15:45:29 -0500 (EST)
Message-ID: <20151201.154529.788782225778447815.davem@davemloft.net>
References: <1448856191-31435-1-git-send-email-edumazet@google.com>
	<1448856191-31435-2-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com,
	hannes@stressinduktion.org, edumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56941 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756803AbbLAUpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 15:45:31 -0500
In-Reply-To: <1448856191-31435-2-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun, 29 Nov 2015 20:03:11 -0800

> Dmitry provided a syzkaller (http://github.com/google/syzkaller)
> triggering a fault in sock_wake_async() when async IO is requested.
> 
> Said program stressed af_unix sockets, but the issue is generic
> and should be addressed in core networking stack.
> 
> The problem is that by the time sock_wake_async() is called,
> we should not access the @flags field of 'struct socket',
> as the inode containing this socket might be freed without
> further notice, and without RCU grace period.
> 
> We already maintain an RCU protected structure, "struct socket_wq"
> so moving SOCKWQ_ASYNC_NOSPACE & SOCKWQ_ASYNC_WAITDATA into it
> is the safe route.
> 
> It also reduces number of cache lines needing dirtying, so might
> provide a performance improvement anyway.
> 
> In followup patches, we might move remaining flags (SOCK_NOSPACE,
> SOCK_PASSCRED, SOCK_PASSSEC) to save 8 bytes and let 'struct socket'
> being mostly read and let it being shared between cpus.
> 
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
