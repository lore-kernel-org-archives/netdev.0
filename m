From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH] tcp: tcp_prequeue() can use keyed wakeups
Date: Tue, 12 May 2009 20:34:50 -0500
Message-ID: <1242178490.11389.20.camel@merlyn>
References: <4A031596.4020904@cosmosbay.com>
	 <4A031867.9060806@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:36249 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbZEMBfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 21:35:04 -0400
Received: by rv-out-0506.google.com with SMTP id f9so244994rvb.1
        for <netdev@vger.kernel.org>; Tue, 12 May 2009 18:35:04 -0700 (PDT)
In-Reply-To: <4A031867.9060806@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-05-07 at 19:20 +0200, Eric Dumazet wrote:
> We can avoid waking up tasks not interested in receive notifications,
> using wake_up_interruptible_poll() instead of wake_up_interruptible()

Is there any reason why we shouldn't do the same thing on the write
side?

Compile-tested only.

  --  John

---
[PATCH net-next-2.6] tcp: Don't wake up reading threads on write space 

When TCP frees up write buffer space, avoid waking up tasks that have
done a poll() or select() on the same socket specifying read-side
events.

This is an extension of a read-side patch by Eric Dumazet.

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/core/stream.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/stream.c b/net/core/stream.c
index 8727cea..a37debf 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -33,7 +33,8 @@ void sk_stream_write_space(struct sock *sk)
 		clear_bit(SOCK_NOSPACE, &sock->flags);
 
 		if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-			wake_up_interruptible(sk->sk_sleep);
+			wake_up_interruptible_poll(sk->sk_sleep, POLLOUT |
+						POLLWRNORM | POLLWRBAND);
 		if (sock->fasync_list && !(sk->sk_shutdown & SEND_SHUTDOWN))
 			sock_wake_async(sock, SOCK_WAKE_SPACE, POLL_OUT);
 	}
-- 
1.5.4.3



