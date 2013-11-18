From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] inet: prevent leakage of uninitialized memory to
 user in recv syscalls
Date: Mon, 18 Nov 2013 08:13:50 -0800
Message-ID: <1384791230.8604.67.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAApbN=Jm=zuDaVYALmGg5z_QfJJ3q13e9tshb7OpAtPQ8Ema1w@mail.gmail.com>
	 <CAApbN=K8j+XQG+pQF2fxBSrDEPcjD242e9uP72azD9XWBzHcGQ@mail.gmail.com>
	 <20131116054344.GG26901@order.stressinduktion.org>
	 <20131116054814.GH26901@order.stressinduktion.org>
	 <20131116191916.GC16541@order.stressinduktion.org>
	 <1384634802.8604.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131116224330.GF16541@order.stressinduktion.org>
	 <1384648584.8604.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131117192240.GI16541@order.stressinduktion.org>
	 <20131118032045.GJ16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mpb <mpb.mail@gmail.com>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:34922 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab3KRQNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 11:13:53 -0500
Received: by mail-pd0-f178.google.com with SMTP id p10so6649504pdj.23
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 08:13:52 -0800 (PST)
In-Reply-To: <20131118032045.GJ16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-11-18 at 04:20 +0100, Hannes Frederic Sowa wrote:
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

This definitely looks much better, as this will remove lot of crap,
thanks !

unix_dgram_recvmsg() and unix_stream_recvmsg() for example clear
msg_namelen

 
