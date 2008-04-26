From: Sam Ravnborg <sam@ravnborg.org>
Subject: [PATCH][CAN]: Fix copy_from_user() results interpretation
Date: Sat, 26 Apr 2008 11:59:23 +0200
Message-ID: <20080426095923.GA22836@uranus.ravnborg.org>
References: <4812C973.5000504@grandegger.com> <20080426064007.GA20558@uranus.ravnborg.org> <4812E73A.6060104@hartkopp.net> <20080426.021001.18044508.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@hartkopp.net, wg@grandegger.com,
	urs.thuermann@volkswagen.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de, oliver.hartkopp@volkswagen.de,
	xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:47667 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751505AbYDZJ6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Apr 2008 05:58:50 -0400
Content-Disposition: inline
In-Reply-To: <20080426.021001.18044508.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both copy_to_ and _from_user return the number of bytes, that failed to
reach their destination, not the 0/-EXXX values.

Based on patch from Pavel Emelyanov <xemul@openvz.org>

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
Acked-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Cc: Pavel Emelyanov <xemul@openvz.org>
Cc: Wolfgang Grandegger <wg@grandegger.com>
---

Hi David.

> Right, I also have no problem with Sam's patch at all and plan to
> apply it.
OK - here is a proper patch.
Actual patch is the same - I just added a proper changelog.

	Sam

diff --git a/net/can/raw.c b/net/can/raw.c
index 201cbfc..69877b8 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -435,15 +435,13 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 			if (!filter)
 				return -ENOMEM;
 
-			err = copy_from_user(filter, optval, optlen);
-			if (err) {
+			if (copy_from_user(filter, optval, optlen)) {
 				kfree(filter);
-				return err;
+				return -EFAULT;
 			}
 		} else if (count == 1) {
-			err = copy_from_user(&sfilter, optval, optlen);
-			if (err)
-				return err;
+			if (copy_from_user(&sfilter, optval, optlen))
+				return -EFAULT;
 		}
 
 		lock_sock(sk);
@@ -493,9 +491,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(err_mask))
 			return -EINVAL;
 
-		err = copy_from_user(&err_mask, optval, optlen);
-		if (err)
-			return err;
+		if (copy_from_user(&err_mask, optval, optlen))
+			return -EFAULT;
 
 		err_mask &= CAN_ERR_MASK;
 
@@ -531,7 +528,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(ro->loopback))
 			return -EINVAL;
 
-		err = copy_from_user(&ro->loopback, optval, optlen);
+		if (copy_from_user(&ro->loopback, optval, optlen))
+			return -EFAULT;
 
 		break;
 
@@ -539,7 +537,8 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 		if (optlen != sizeof(ro->recv_own_msgs))
 			return -EINVAL;
 
-		err = copy_from_user(&ro->recv_own_msgs, optval, optlen);
+		if (copy_from_user(&ro->recv_own_msgs, optval, optlen))
+			return -EFAULT;
 
 		break;
 
diff --git a/scripts/Makefile.build b/scripts/Makefile.build
index 277cfe0..4a7327b 100644
--- a/scripts/Makefile.build
+++ b/scripts/Makefile.build
@@ -105,7 +105,7 @@ endif
 
 # Do section mismatch analysis for each module/built-in.o
 ifdef CONFIG_DEBUG_SECTION_MISMATCH
-  cmd_secanalysis = ; scripts/mod/modpost $@
+  #cmd_secanalysis = ; scripts/mod/modpost $@
 endif
 
 # Compile C sources (.c)
