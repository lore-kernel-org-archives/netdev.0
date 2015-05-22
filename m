From: Mark Salyzyn <salyzyn@android.com>
Subject: [PATCH v2] net/unix: sk_socket can disappear when state is unlocked
Date: Fri, 22 May 2015 08:00:42 -0700
Message-ID: <1432306867-27009-1-git-send-email-salyzyn@android.com>
Cc: Hannes Frederic Sowa <hannes@redhat.com>,
	Mark Salyzyn <salyzyn@android.com>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	David Howells <dhowells@redhat.com>,
	Ying Xue <ying.xue@windriver.com>,
	Christoph Hellwig <hch@lst.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

got a rare NULL pointer dereference in clear_bit

Signed-off-by: Mark Salyzyn <salyzyn@android.com>
----
v2: switch to sock_flag(sk, SOCK_DEAD) and added net/caif/caif_socket.c

 net/caif/caif_socket.c | 4 ++++
 net/unix/af_unix.c     | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 4ec0c80..8f44c38 100644
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
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5266ea7..7b68dc8 100644
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
 
-- 
2.2.0.rc0.207.ga3a616c
