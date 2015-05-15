From: Jason Baron <jbaron@akamai.com>
Subject: [PATCH] tcp: ensure epoll edge trigger wakeup when out of memory
Date: Fri, 15 May 2015 21:17:07 +0000 (GMT)
Message-ID: <20150515211707.D9FC480066@prod-mail-relay07.akamai.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: edumazet@google.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:56744 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422770AbbEOVRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:17:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>

If we really can't get an skb allocated, make sure that we let
userspace know. This at least gives us a chance to re-try or abort.

Signed-off-by: Jason Baron <jbaron@akamai.com>
---
 net/ipv4/tcp.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index ecccfdc..d7d85e8 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -986,6 +986,9 @@ do_error:
 	if (copied)
 		goto out;
 out_err:
+	/* make sure we wake any epoll edge trigger waiter */
+	if (unlikely(sk->sk_write_queue == 0 && err == -EAGAIN))
+		sk->sk_write_space(sk);
 	return sk_stream_error(sk, flags, err);
 }
 
@@ -1274,6 +1277,9 @@ do_error:
 		goto out;
 out_err:
 	err = sk_stream_error(sk, flags, err);
+	/* make sure we wake any epoll edge trigger waiter */
+	if (unlikely(sk->sk_write_queue == 0 && err == -EAGAIN))
+		sk->sk_write_space(sk);
 	release_sock(sk);
 	return err;
 }
-- 
1.8.2.rc2
