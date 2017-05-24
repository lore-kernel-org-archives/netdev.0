From: Dave Watson <davejwatson@fb.com>
Subject: [PATCH net-next 2/4] tcp: export do_tcp_sendpages and
 tcp_rate_check_app_limited functions
Date: Wed, 24 May 2017 09:26:57 -0700
Message-ID: <20170524162657.GA24165@davejwatson-mba.local>
References: <cover.1495642647.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnults.org>, <fridolin.pokorny@gmail.com>
To: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36699 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S967737AbdEXQ1N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 12:27:13 -0400
Content-Disposition: inline
In-Reply-To: <cover.1495642647.git.davejwatson@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export do_tcp_sendpages and tcp_rate_check_app_limited, since tls will need to
sendpages while the socket is already locked.

tcp_sendpage is exported, but requires the socket lock to not be held already.

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Boris Pismenny <borisp@mellanox.com>
Signed-off-by: Dave Watson <davejwatson@fb.com>
---
 include/net/tcp.h   | 2 ++
 net/ipv4/tcp.c      | 5 +++--
 net/ipv4/tcp_rate.c | 1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index fcc39f8..2b35100 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -353,6 +353,8 @@ int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
 int tcp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
+ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+		 size_t size, int flags);
 void tcp_release_cb(struct sock *sk);
 void tcp_wfree(struct sk_buff *skb);
 void tcp_write_timer_handler(struct sock *sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 9f06faa..08a8ef4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -882,8 +882,8 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
-				size_t size, int flags)
+ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+			 size_t size, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now, size_goal;
@@ -1013,6 +1013,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	}
 	return sk_stream_error(sk, flags, err);
 }
+EXPORT_SYMBOL(do_tcp_sendpages);
 
 int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags)
diff --git a/net/ipv4/tcp_rate.c b/net/ipv4/tcp_rate.c
index ad99569..62876e4 100644
--- a/net/ipv4/tcp_rate.c
+++ b/net/ipv4/tcp_rate.c
@@ -185,3 +185,4 @@ void tcp_rate_check_app_limited(struct sock *sk)
 		tp->app_limited =
 			(tp->delivered + tcp_packets_in_flight(tp)) ? : 1;
 }
+EXPORT_SYMBOL(tcp_rate_check_app_limited);
-- 
2.9.3
