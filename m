From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][CAN]: Fix copy_from_user() results interpretation.
Date: Fri, 25 Apr 2008 16:42:14 +0400
Message-ID: <4811D1A6.909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56834 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753728AbYDYMpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 08:45:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the noise, I had to check this right after facing this problem
with the copy_to_user()...

Both copy_to_ and _from_user return the number of bytes, that failed to
reach their destination, not the 0/-EXXX values.

Other net/ code handles this correctly.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/can/raw.c b/net/can/raw.c
index ead50c7..2be8c6e 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -438,12 +438,12 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 			err = copy_from_user(filter, optval, optlen);
 			if (err) {
 				kfree(filter);
-				return err;
+				return -EFAULT;
 			}
 		} else if (count == 1) {
 			err = copy_from_user(&sfilter, optval, optlen);
 			if (err)
-				return err;
+				return -EFAULT;
 		}
 
 		lock_sock(sk);
@@ -495,7 +495,7 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 
 		err = copy_from_user(&err_mask, optval, optlen);
 		if (err)
-			return err;
+			return -EFAULT;
 
 		err_mask &= CAN_ERR_MASK;
 
@@ -531,7 +531,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(ro->loopback))
 			return -EINVAL;
 
-		err = copy_from_user(&ro->loopback, optval, optlen);
+		err = copy_from_user(&ro->loopback, optval, optlen) ?
+			-EFAULT : 0;
 
 		break;
 
@@ -539,7 +540,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(ro->recv_own_msgs))
 			return -EINVAL;
 
-		err = copy_from_user(&ro->recv_own_msgs, optval, optlen);
+		err = copy_from_user(&ro->recv_own_msgs, optval, optlen) ?
+			-EFAULT : 0;
 
 		break;
 
