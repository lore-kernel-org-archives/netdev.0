From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH] tcp: set SOCK_NOSPACE under memory presure
Date: Mon, 20 Apr 2015 20:05:13 +0000 (GMT)
Message-ID: <20150420200513.11D8E202D@prod-mail-relay06.akamai.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:30176 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750960AbbDUO5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 10:57:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under tcp memory pressure, calling epoll_wait() in edge triggered
mode after -EAGAIN, can result in an indefinite hang in epoll_wait(),
even when there is suffcient memory available to continue making
progress. The problem is that __sk_mem_schedule() can return 0,
under memory pressure without having set the SOCK_NOSPACE flag. Thus,
even though all the outstanding packets have been acked, we never
get the EPOLLOUT that we are expecting from epoll_wait().

This issue is currently limited to epoll when used in edge trigger
mode, since 'tcp_poll()', does in fact currently set SOCK_NOSPACE.
This is sufficient for poll()/select() and epoll() in level trigger
mode. However, in edge trigger mode, epoll() is relying on the write
path to set SOCK_NOSPACE. So I view this patch as bringing us into
sync with poll()/select() and epoll() level trigger behavior.

I can reproduce this issue, using SO_SNDBUF, since
__sk_mem_schedule() will return 0, or failure more readily with
SO_SNDBUF:

1) create socket and set SO_SNDBUF to N
2) add socket as edge trigger
3) write to socket and block in epoll on -EAGAIN
4) cause tcp mem pressure via: echo "<small val>" > net.ipv4.tcp_mem

The fix here is simply to set SOCK_NOSPACE in sk_stream_wait_memory()
when the socket is non-blocking.

Note that we could still hang if sk->sk_wmem_queue is 0, when we get
the -EAGAIN. In this case the SOCK_NOSPACE bit will not help, since we
are waiting for and event that will never happen. I believe
that this case is hard to hit (and did not hit in my testing),
in that over the 'soft' limit, we continue to guarantee a minimum
write buffer size. Perhaps, we could return -ENOSPC in this
case...note that this case is not specific to epoll ET, but
rather would affect all blocking and non-blocking sockets as well,
and thus I think its ok to treat it as a separate case.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/core/stream.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/stream.c b/net/core/stream.c
index 301c05f..d70f77a 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -119,6 +119,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 	int err = 0;
 	long vm_wait = 0;
 	long current_timeo = *timeo_p;
+	bool noblock = (*timeo_p ? false : true);
 	DEFINE_WAIT(wait);
 
 	if (sk_stream_memory_free(sk))
@@ -131,8 +132,11 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 
 		if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 			goto do_error;
-		if (!*timeo_p)
+		if (!*timeo_p) {
+			if (noblock)
+				set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 			goto do_nonblock;
+		}
 		if (signal_pending(current))
 			goto do_interrupted;
 		clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
-- 
1.8.2.rc2
