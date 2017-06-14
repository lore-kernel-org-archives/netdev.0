From: Dave Watson <davejwatson@fb.com>
Subject: [PATCH v3 net-next 2/4] tcp: export do_tcp_sendpages and
 tcp_rate_check_app_limited functions
Date: Wed, 14 Jun 2017 11:37:26 -0700
Message-ID: <20170614183726.GA80346@davejwatson-mba.dhcp.thefacebook.com>
References: <cover.1497465295.git.davejwatson@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        <nmav@gnutls.org>, <fridolin.pokorny@gmail.com>
To: Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Liran Liss <liranl@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        <herbert@gondor.apana.org.au>, <linux-crypto@vger.kernel.org>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1497465295.git.davejwatson@fb.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index b439f46..e17ec28 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -350,6 +350,8 @@ int tcp_v4_tw_remember_stamp(struct inet_timewait_sock *tw);
 int tcp_sendmsg(struct sock *sk, struct msghdr *msg, size_t size);
 int tcp_sendpage(struct sock *sk, struct page *page, int offset, size_t size,
 		 int flags);
+ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+		 size_t size, int flags);
 void tcp_release_cb(struct sock *sk);
 void tcp_wfree(struct sk_buff *skb);
 void tcp_write_timer_handler(struct sock *sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b06ee30..11e4ee2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -901,8 +901,8 @@ static int tcp_send_mss(struct sock *sk, int *size_goal, int flags)
 	return mss_now;
 }
 
-static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
-				size_t size, int flags)
+ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
+			 size_t size, int flags)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	int mss_now, size_goal;
@@ -1032,6 +1032,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page *page, int offset,
 	}
 	return sk_stream_error(sk, flags, err);
 }
+EXPORT_SYMBOL_GPL(do_tcp_sendpages);
 
 int tcp_sendpage(struct sock *sk, struct page *page, int offset,
 		 size_t size, int flags)
diff --git a/net/ipv4/tcp_rate.c b/net/ipv4/tcp_rate.c
index ad99569..3330a37 100644
--- a/net/ipv4/tcp_rate.c
+++ b/net/ipv4/tcp_rate.c
@@ -185,3 +185,4 @@ void tcp_rate_check_app_limited(struct sock *sk)
 		tp->app_limited =
 			(tp->delivered + tcp_packets_in_flight(tp)) ? : 1;
 }
+EXPORT_SYMBOL_GPL(tcp_rate_check_app_limited);
-- 
2.9.3
