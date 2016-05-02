From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] net: SOCKWQ_ASYNC_NOSPACE optimizations
Date: Mon, 02 May 2016 13:23:27 -0700
Message-ID: <1462220607.5535.273.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
	 <1461605974-4242-2-git-send-email-edumazet@google.com>
	 <20160502161602.GA1984@nanopsycho.orion>
	 <1462206138.5535.255.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160502191229.GA1946@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, eladr@mellanox.com,
	idosch@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33000 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbcEBUXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 16:23:30 -0400
Received: by mail-pa0-f49.google.com with SMTP id xk12so7416191pac.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 13:23:30 -0700 (PDT)
In-Reply-To: <20160502191229.GA1946@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-02 at 21:12 +0200, Jiri Pirko wrote:
> Mon, May 02, 2016 at 06:22:18PM CEST, eric.dumazet@gmail.com wrote:
> >On Mon, 2016-05-02 at 18:16 +0200, Jiri Pirko wrote:
> >> Mon, Apr 25, 2016 at 07:39:32PM CEST, edumazet@google.com wrote:
> >> >SOCKWQ_ASYNC_NOSPACE is tested in sock_wake_async()
> >> >so that a SIGIO signal is sent when needed.
> >> >
> >> >tcp_sendmsg() clears the bit.
> >> >tcp_poll() sets the bit when stream is not writeable.
> >> >
> >> >We can avoid two atomic operations by first checking if socket
> >> >is actually interested in the FASYNC business (most sockets in
> >> >real applications do not use AIO, but select()/poll()/epoll())
> >> >
> >> >This also removes one cache line miss to access sk->sk_wq->flags
> >> >in tcp_sendmsg()
> >> >
> >> >Signed-off-by: Eric Dumazet <edumazet@google.com>
> >> 
> >> I just bisected down to this. This is causing a regression for me when
> >> my nfs mount becomes stuck. I can easily reproduce this if you need to
> >> test the fix.
> >
> >What do you mean by 'when nfs mount becomes stuck' ?
> >
> >Is this patch making nfs not functional , or does it make recovery from
> >some nfs error bad ?
> 
> I can mount nfs on the host. But when I do something (compile a kernel
> module in my case), it gets stuck. Then I cannot even ssh to the machine.
> No messages in dmesg. I didn't debug it any further. I just bisected and
> verified that this patch caused this behaviour.

Interesting.

It looks like net/sunrpc/xprtsock.c should set SOCK_FASYNC
even if it is not actually using fasync_list

Could you try this quick hack to check if this is the right way ?

Thanks !

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index a6c68dc086af83233ee315642638f4a1990ee622..b90c5397b5e137c6cc8accad6eebe2b876363d4e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1950,6 +1950,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
 		sk->sk_user_data = xprt;
 		sk->sk_data_ready = xs_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
+		sock_set_flag(sk, SOCK_FASYNC);
 		sk->sk_error_report = xs_error_report;
 		sk->sk_allocation = GFP_NOIO;
 
@@ -2136,6 +2137,7 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_user_data = xprt;
 		sk->sk_data_ready = xs_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
+		sock_set_flag(sk, SOCK_FASYNC);
 		sk->sk_allocation = GFP_NOIO;
 
 		xprt_set_connected(xprt);
@@ -2237,6 +2239,7 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 		sk->sk_data_ready = xs_tcp_data_ready;
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;
+		sock_set_flag(sk, SOCK_FASYNC);
 		sk->sk_error_report = xs_error_report;
 		sk->sk_allocation = GFP_NOIO;
 
