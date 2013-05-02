From: Colin Cross <ccross@android.com>
Subject: [PATCH v2 10/10] af_unix: use freezable blocking calls in read
Date: Wed,  1 May 2013 18:35:08 -0700
Message-ID: <1367458508-9133-11-git-send-email-ccross@android.com>
References: <1367458508-9133-1-git-send-email-ccross@android.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	arve@android.com, Tejun Heo <tj@kernel.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Colin Cross <ccross@android.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: linux-pm@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367458508-9133-1-git-send-email-ccross@android.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid waking up every thread sleeping in read call on an AF_UNIX
socket during suspend and resume by calling a freezable blocking
call.  Previous patches modified the freezer to avoid sending
wakeups to threads that are blocked in freezable blocking calls.

This call was selected to be converted to a freezable call because
it doesn't hold any locks or release any resources when interrupted
that might be needed by another freezing task or a kernel driver
during suspend, and is a common site where idle userspace tasks are
blocked.

Signed-off-by: Colin Cross <ccross@android.com>
---
 net/unix/af_unix.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 2db702d..2bcac57 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -114,6 +114,7 @@
 #include <linux/mount.h>
 #include <net/checksum.h>
 #include <linux/security.h>
+#include <linux/freezer.h>
 
 struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE];
 EXPORT_SYMBOL_GPL(unix_socket_table);
@@ -1880,7 +1881,7 @@ static long unix_stream_data_wait(struct sock *sk, long timeo)
 
 		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 		unix_state_unlock(sk);
-		timeo = schedule_timeout(timeo);
+		timeo = freezable_schedule_timeout(timeo);
 		unix_state_lock(sk);
 		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
 	}
-- 
1.8.2.1
