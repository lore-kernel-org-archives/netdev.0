From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] xfrm: use memdup_user
Date: Sat,  6 May 2017 23:42:21 +0800
Message-ID: <7d89949ab688323cf05273b7dfaca94348118594.1493780592.git.geliangtang@gmail.com>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34288 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754921AbdEFPnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 11:43:09 -0400
In-Reply-To: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use memdup_user() helper instead of open-coding to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 net/xfrm/xfrm_state.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fc3c5aa..5780cda 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2023,13 +2023,9 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 	if (optlen <= 0 || optlen > PAGE_SIZE)
 		return -EMSGSIZE;
 
-	data = kmalloc(optlen, GFP_KERNEL);
-	if (!data)
-		return -ENOMEM;
-
-	err = -EFAULT;
-	if (copy_from_user(data, optval, optlen))
-		goto out;
+	data = memdup_user(optval, optlen);
+	if (IS_ERR(data))
+		return PTR_ERR(data);
 
 	err = -EINVAL;
 	rcu_read_lock();
@@ -2047,7 +2043,6 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 		err = 0;
 	}
 
-out:
 	kfree(data);
 	return err;
 }
-- 
2.9.3
