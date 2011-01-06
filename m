From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: add POLLPRI to sock_def_readable()
Date: Thu, 06 Jan 2011 18:44:57 +0100
Message-ID: <1294335897.3074.83.camel@edumazet-laptop>
References: <20110106155040.GA27769@libre.l.ngdn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Leonardo Chiquitto <leonardo.lists@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40212 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab1AFRqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 12:46:14 -0500
Received: by wwa36 with SMTP id 36so17639604wwa.1
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 09:46:07 -0800 (PST)
In-Reply-To: <20110106155040.GA27769@libre.l.ngdn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Leonardo Chiquitto found poll() could block forever on tcp sockets and
Urgent data was received, if the event flag only contains POLLPRI.

He did a bisection and found commit 4938d7e0233 (poll: avoid extra
wakeups in select/poll) was the source of the problem.

Problem is TCP sockets use standard sock_def_readable() function for
their sk_data_ready() handler, and sock_def_readable() doesnt signal
POLLPRI.

Only TCP is affected by the problem. Adding POLLPRI to the list of flags
might trigger unnecessary schedules, but URGENT handling is such a
seldom used feature this seems a good compromise.

Thanks a lot to Leonardo for providing the bisection result and a test
program as well.

Reference : http://www.spinics.net/lists/netdev/msg151793.html

Reported-and-bisected-by: Leonardo Chiquitto <leonardo.lists@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Tested-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/sock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index e5af8d5..7fd3541 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1907,7 +1907,7 @@ static void sock_def_readable(struct sock *sk, int len)
 	rcu_read_lock();
 	wq = rcu_dereference(sk->sk_wq);
 	if (wq_has_sleeper(wq))
-		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
+		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
 	rcu_read_unlock();


