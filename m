From: Mark Salyzyn <salyzyn@android.com>
Subject: net/unix: sk_socket can disappear when state is unlocked
Date: Thu, 21 May 2015 09:25:32 -0700
Message-ID: <1432225541-28498-1-git-send-email-salyzyn@android.com>
Cc: Mark Salyzyn <salyzyn@android.com>,
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
---
 net/unix/af_unix.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 5266ea7..37a8925 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1880,6 +1880,11 @@ static long unix_stream_data_wait(struct sock *sk, long timeo,
 		unix_state_unlock(sk);
 		timeo = freezable_schedule_timeout(timeo);
 		unix_state_lock(sk);
+
+		/* sk_socket may have been killed while unlocked */
+		if (!sk->sk_socket)
+			break;
+
 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	}
 
-- 
2.2.0.rc0.207.ga3a616c
