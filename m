From: Mark Salyzyn <salyzyn@android.com>
Subject: [PATCH v3] net/unix: sk_socket can disappear when state is unlocked
Date: Tue, 26 May 2015 08:22:19 -0700
Message-ID: <1432653777-13799-1-git-send-email-salyzyn@android.com>
Cc: Mark Salyzyn <salyzyn@android.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: hannes@redhat.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

got a rare NULL pointer dereference in clear_bit

Signed-off-by: Mark Salyzyn <salyzyn@android.com>
----
v2: switch to sock_flag(sk, SOCK_DEAD) and added net/caif/caif_socket.c
v3: return -ECONNRESET in upstream caller of wait function for SOCK_DEAD
---
 net/caif/caif_socket.c | 8 ++++++++
 net/unix/af_unix.c     | 8 ++++++++
 2 files changed, 16 insertions(+)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 4ec0c80..112ad78 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -330,6 +330,10 @@ static long caif_stream_data_wait(struct sock *sk, long timeo)
 		release_sock(sk);
 		timeo = schedule_timeout(timeo);
 		lock_sock(sk);
+
+		if (sock_flag(sk, SOCK_DEAD))
+			break;
+
 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	}
 
@@ -373,6 +377,10 @@ static int caif_stream_recvmsg(struct socket *sock, struct msghdr *msg,
 		struct sk_buff *skb;
 
 		lock_sock(sk);
+		if (sock_flag(sk, SOCK_DEAD)) {
+			err = -ECONNRESET;
+			goto unlock;
+		}
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		caif_check_flow_release(sk);
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5266ea7..0643059 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1880,6 +1880,10 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 		unix_state_unlock(sk);
 		timeo = freezable_schedule_timeout(timeo);
 		unix_state_lock(sk);
+
+		if (sock_flag(sk, SOCK_DEAD))
+			break;
+
 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	}
 
@@ -1939,6 +1943,10 @@ static int unix_stream_recvmsg(struct socket *sock, struct msghdr *msg,
 		struct sk_buff *skb, *last;
 
 		unix_state_lock(sk);
+		if (sock_flag(sk, SOCK_DEAD)) {
+			err = -ECONNRESET;
+			goto unlock;
+		}
 		last = skb = skb_peek(&sk->sk_receive_queue);
 again:
 		if (skb == NULL) {
-- 
2.2.0.rc0.207.ga3a616c
