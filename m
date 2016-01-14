From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: [PATCH] af_unix: Use kfree for addresses in unix_bind
Date: Thu, 14 Jan 2016 16:22:10 +0000
Message-ID: <87y4bsw2q5.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kfree instead of unix_release_addr when freeing newly-allocated
unix_address structures after binding the socket failed. The second
function does an atomic_dec_and_test in order to free the address once
its reference count falls to zero which isn't necessary for the
unix_bind error path as the new structure wasn't published yet. 'Using
kfree' is also how unix_autobind handles this case.

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---
gdiff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index c5bf5ef..b894a3c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1044,7 +1044,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		if (err) {
 			if (err == -EEXIST)
 				err = -EADDRINUSE;
-			unix_release_addr(addr);
+			kfree(addr);
 			goto out_up;
 		}
 		addr->hash = UNIX_HASH_SIZE;
@@ -1057,7 +1057,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		err = -EADDRINUSE;
 		if (__unix_find_socket_byname(net, sunaddr, addr_len,
 					      sk->sk_type, hash)) {
-			unix_release_addr(addr);
+			kfree(addr);
 			goto out_unlock;
 		}
 
