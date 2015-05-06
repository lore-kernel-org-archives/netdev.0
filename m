From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH v2 net-next] tcp: set SOCK_NOSPACE under memory pressure
Date: Wed,  6 May 2015 15:52:23 +0000 (GMT)
Message-ID: <20150506155223.9743A2027@prod-mail-relay06.akamai.com>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay07.akamai.com ([72.246.2.115]:39767 "EHLO
	prod-mail-xrelay07.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750997AbbEFPwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 11:52:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

Under tcp memory pressure, calling epoll_wait() in edge triggered
mode after -EAGAIN, can result in an indefinite hang in epoll_wait(),
even when there is sufficient memory available to continue making
progress. The problem is that when __sk_mem_schedule() returns 0
under memory pressure, we do not set the SOCK_NOSPACE flag in the
tcp write paths (tcp_sendmsg() or do_tcp_sendpages()). Then, since
SOCK_NOSPACE is used to trigger wakeups when incoming acks create
sufficient new space in the write queue, all outstanding packets
are acked, but we never wake up with the the EPOLLOUT that we are
expecting from epoll_wait().

This issue is currently limited to epoll() when used in edge trigger
mode, since 'tcp_poll()', does in fact currently set SOCK_NOSPACE.
This is sufficient for poll()/select() and epoll() in level trigger
mode. However, in edge trigger mode, epoll() is relying on the write
path to set SOCK_NOSPACE. EPOLL(7) says that in edge-trigger mode we
can only call epoll_wait() after read/write return -EAGAIN. Thus, in
the case of the socket write, we are relying on the fact that
tcp_sendmsg()/network write paths are going to issue a wakeup for
us at some point in the future when we get -EAGAIN.

Normally, epoll() edge trigger works fine when we've exceeded the
sk->sndbuf because in that case we do set SOCK_NOSPACE. However, when
we return -EAGAIN from the write path b/c we are over the tcp memory
limits and not b/c we are over the sndbuf, we are never going to get
another wakeup.

I can reproduce this issue, using SO_SNDBUF, since __sk_mem_schedule()
will return 0, or failure more readily with SO_SNDBUF:

1) create socket and set SO_SNDBUF to N
2) add socket as edge trigger
3) write to socket and block in epoll on -EAGAIN
4) cause tcp mem pressure via: echo "<small val>" > net.ipv4.tcp_mem

The fix here is simply to set SOCK_NOSPACE in sk_stream_wait_memory()
when the socket is non-blocking. Note that SOCK_NOSPACE, in addition
to waking up outstanding waiters is also used to expand the size of
the sk->sndbuf. However, we will not expand it by setting it in this
case because tcp_should_expand_sndbuf(), ensures that no expansion
occurs when we are under tcp memory pressure.

Note that we could still hang if sk->sk_wmem_queue is 0, when we get
the -EAGAIN. In this case the SOCK_NOSPACE bit will not help, since we
are waiting for and event that will never happen. I believe
that this case is harder to hit (and did not hit in my testing),
in that over the tcp 'soft' memory limits, we continue to guarantee a
minimum write buffer size. Perhaps, we could return -ENOSPC in this
case, or maybe we simply issue a wakeup in this case, such that we
keep retrying the write. Note that this case is not specific to
epoll() ET, but rather would affect blocking sockets as well. So I
view this patch as bringing epoll() edge-trigger into sync with the
current poll()/select()/epoll() level trigger and blocking sockets
behavior.

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
