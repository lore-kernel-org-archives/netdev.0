From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH] tcp: splice as many packets as possible at once
Date: Thu, 8 Jan 2009 21:16:46 +0100
Message-ID: <20090108201646.GA23687@1wt.eu>
References: <20090108173028.GA22531@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1270 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003AbZAHUUF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 15:20:05 -0500
Content-Disposition: inline
In-Reply-To: <20090108173028.GA22531@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

would you please accept this patch (acked by Jens) ?

Also, would you mind adding this one as well as
4f7d54f59bc470f0aaa932f747a95232d7ebf8b1 to your stable queue, because
without them, splicing between sockets is unusable or worthless, and
having both in the long-term 2.6.27 will certainly promote splice()
usage among applications.

Thanks!
Willy


>From fafe76713523c8e9767805cfdc7b73323d7bf180 Mon Sep 17 00:00:00 2001
From: Willy Tarreau <w@1wt.eu>
Date: Thu, 8 Jan 2009 17:10:13 +0100
Subject: [PATCH] tcp: splice as many packets as possible at once

Currently, in non-blocking mode, tcp_splice_read() returns after
splicing one segment regardless of the len argument. This results
in low performance and very high overhead due to syscall rate when
splicing from interfaces which do not support LRO.

The fix simply consists in not breaking out of the loop after the
first read. That way, we can read up to the size requested by the
caller and still return when there is no data left.

Performance has significantly improved with this fix, with the
number of calls to splice() divided by about 20, and CPU usage
dropped from 100% to 75%.

Signed-off-by: Willy Tarreau <w@1wt.eu>
Acked-by: Jens Axboe <jens.axboe@oracle.com>
---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 35bcddf..80261b4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -615,7 +615,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t *ppos,
 		lock_sock(sk);
 
 		if (sk->sk_err || sk->sk_state == TCP_CLOSE ||
-		    (sk->sk_shutdown & RCV_SHUTDOWN) || !timeo ||
+		    (sk->sk_shutdown & RCV_SHUTDOWN) ||
 		    signal_pending(current))
 			break;
 	}
-- 
1.6.0.3

