From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v5 2/4] ipv4: Remove the 'publish' logic in tcp_fastopen_init_key_once
Date: Wed, 27 Sep 2017 11:35:41 +0800
Message-ID: <1506483343-11544-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <edumazet@google.com>,
        Wei Wang <weiwan@google.com>, Luca BRUNO <lucab@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506483343-11544-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The 'publish' logic is not necessary after commit dfea2aa65424 ("tcp:
Do not call tcp_fastopen_reset_cipher from interrupt context"), because
in tcp_fastopen_cookie_gen，it wouldn't call tcp_fastopen_init_key_once.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 include/net/tcp.h          | 2 +-
 net/ipv4/af_inet.c         | 2 +-
 net/ipv4/sysctl_net_ipv4.c | 5 -----
 net/ipv4/tcp.c             | 2 +-
 net/ipv4/tcp_fastopen.c    | 4 ++--
 5 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f628967..061c128 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1562,7 +1562,7 @@ struct tcp_fastopen_request {
 struct sock *tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 			      struct request_sock *req,
 			      struct tcp_fastopen_cookie *foc);
-void tcp_fastopen_init_key_once(bool publish);
+void tcp_fastopen_init_key_once(void);
 bool tcp_fastopen_cookie_check(struct sock *sk, u16 *mss,
 			     struct tcp_fastopen_cookie *cookie);
 bool tcp_fastopen_defer_connect(struct sock *sk, int *err);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index ddd126d..e73ce79 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -222,7 +222,7 @@ int inet_listen(struct socket *sock, int backlog)
 		    (tcp_fastopen & TFO_SERVER_ENABLE) &&
 		    !inet_csk(sk)->icsk_accept_queue.fastopenq.max_qlen) {
 			fastopen_queue_tune(sk, backlog);
-			tcp_fastopen_init_key_once(true);
+			tcp_fastopen_init_key_once();
 		}
 
 		err = inet_csk_listen_start(sk, backlog);
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index e31e853c..f6324ea 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -282,11 +282,6 @@ static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 			ret = -EINVAL;
 			goto bad_key;
 		}
-		/* Generate a dummy secret but don't publish it. This
-		 * is needed so we don't regenerate a new key on the
-		 * first invocation of tcp_fastopen_cookie_gen
-		 */
-		tcp_fastopen_init_key_once(false);
 		tcp_fastopen_reset_cipher(user_key, TCP_FASTOPEN_KEY_LENGTH);
 	}
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index dac56c4..4e39545 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2749,7 +2749,7 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_FASTOPEN:
 		if (val >= 0 && ((1 << sk->sk_state) & (TCPF_CLOSE |
 		    TCPF_LISTEN))) {
-			tcp_fastopen_init_key_once(true);
+			tcp_fastopen_init_key_once();
 
 			fastopen_queue_tune(sk, val);
 		} else {
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 31b08ec..8c8f0f0 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -13,7 +13,7 @@
 
 static DEFINE_SPINLOCK(tcp_fastopen_ctx_lock);
 
-void tcp_fastopen_init_key_once(bool publish)
+void tcp_fastopen_init_key_once(void)
 {
 	static u8 key[TCP_FASTOPEN_KEY_LENGTH];
 
@@ -23,7 +23,7 @@ void tcp_fastopen_init_key_once(bool publish)
 	 * All call sites of tcp_fastopen_cookie_gen also check
 	 * for a valid cookie, so this is an acceptable risk.
 	 */
-	if (net_get_random_once(key, sizeof(key)) && publish)
+	if (net_get_random_once(key, sizeof(key)))
 		tcp_fastopen_reset_cipher(key, sizeof(key));
 }
 
-- 
1.8.3.1
