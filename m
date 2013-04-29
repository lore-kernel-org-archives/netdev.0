From: Colin Cross <ccross@android.com>
Subject: [PATCH 10/10] af_unix: use freezable blocking calls in read
Date: Mon, 29 Apr 2013 14:45:46 -0700
Message-ID: <1367271946-7239-11-git-send-email-ccross@android.com>
References: <1367271946-7239-1-git-send-email-ccross@android.com>
Cc: linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	arve@android.com, Colin Cross <ccross@android.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>, netdev@vger.kernel.org
To: linux-pm@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:32881 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932547Ab3D2Vp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 17:45:59 -0400
Received: by mail-qc0-f202.google.com with SMTP id k26so712307qcs.5
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 14:45:58 -0700 (PDT)
In-Reply-To: <1367271946-7239-1-git-send-email-ccross@android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid waking up every thread sleeping in read call on an AF_UNIX
socket during suspend and resume by calling a freezable blocking
call.

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
