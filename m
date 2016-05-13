From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sunrpc: set SOCK_FASYNC
Date: Thu, 12 May 2016 21:41:39 -0700
Message-ID: <1463114499.23934.179.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461605974-4242-1-git-send-email-edumazet@google.com>
	 <1461605974-4242-2-git-send-email-edumazet@google.com>
	 <20160502161602.GA1984@nanopsycho.orion>
	 <1462206138.5535.255.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160502191229.GA1946@nanopsycho.orion>
	 <1462220607.5535.273.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Huang Ying <ying.huang@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35624 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750763AbcEMElm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 00:41:42 -0400
Received: by mail-pa0-f67.google.com with SMTP id zy2so9039927pac.2
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 21:41:42 -0700 (PDT)
In-Reply-To: <1462220607.5535.273.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sunrpc is using SOCKWQ_ASYNC_NOSPACE without setting SOCK_FASYNC,
so the recent optimizations done in sk_set_bit() and sk_clear_bit()
broke it.

There is still the risk that a subsequent sock_fasync() call
would clear SOCK_FASYNC, but sunrpc does not use this yet.

Fixes: 9317bb69824e ("net: SOCKWQ_ASYNC_NOSPACE optimizations")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Jiri Pirko <jiri@resnulli.us>
Reported-by: Huang, Ying <ying.huang@intel.com>
Tested-by: Jiri Pirko <jiri@resnulli.us>
Tested-by: Huang, Ying <ying.huang@intel.com>
---
 net/sunrpc/xprtsock.c |    3 +++
 1 file changed, 3 insertions(+)

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
 
