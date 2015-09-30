From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: add pfmemalloc check in sk_add_backlog()
Date: Tue, 29 Sep 2015 18:52:25 -0700
Message-ID: <1443577945.32531.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Greg Thelen <gthelen@google.com>,
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36338 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbbI3Bw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 21:52:27 -0400
Received: by pablk4 with SMTP id lk4so22548345pab.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 18:52:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Greg reported crashes hitting the following check in __sk_backlog_rcv()

	BUG_ON(!sock_flag(sk, SOCK_MEMALLOC)); 

The pfmemalloc bit is currently checked in sk_filter().

This works correctly for TCP, because sk_filter() is ran in
tcp_v[46]_rcv() before hitting the prequeue or backlog checks.

For UDP or other protocols, this does not work, because the sk_filter()
is ran from sock_queue_rcv_skb(), which might be called _after_ backlog
queuing if socket is owned by user by the time packet is processed by
softirq handler.

Fixes: b4b9e35585089 ("netvm: set PF_MEMALLOC as appropriate during SKB processing")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Greg Thelen <gthelen@google.com>
---
 include/net/sock.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 7aa78440559a..e23717013a4e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -828,6 +828,14 @@ static inline __must_check int sk_add_backlog(struct sock *sk, struct sk_buff *s
 	if (sk_rcvqueues_full(sk, limit))
 		return -ENOBUFS;
 
+	/*
+	 * If the skb was allocated from pfmemalloc reserves, only
+	 * allow SOCK_MEMALLOC sockets to use it as this socket is
+	 * helping free memory
+	 */
+	if (skb_pfmemalloc(skb) && !sock_flag(sk, SOCK_MEMALLOC))
+		return -ENOMEM;
+
 	__sk_add_backlog(sk, skb);
 	sk->sk_backlog.len += skb->truesize;
 	return 0;
