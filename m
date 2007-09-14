From: David Miller <davem@davemloft.net>
Subject: Re: SO_BINDTODEVICE mismatch with man page & comments.
Date: Fri, 14 Sep 2007 13:12:25 -0700 (PDT)
Message-ID: <20070914.131225.78720330.davem@davemloft.net>
References: <46DDDFFA.6090705@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:36496
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758803AbXINUMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 16:12:33 -0400
In-Reply-To: <46DDDFFA.6090705@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 04 Sep 2007 15:45:14 -0700

> According to the comment in the net/core/sock.c code (in 2.6.20), I should be able to pass a zero
> optlen to the setsockopt method for SO_BINDTODEVICE:
 ...
> However, earlier in that method it returns -EINVAL if optlen is < sizeof(int).
> 
> The man page has comments similar to that in the code above.
> 
> Also, even when I get the un-bind call working with code similar to:
> 
> int z = 0;
> setsockopt(s, SOL_SOCKET, SO_BINDTODEVICE, &z, sizeof(z));
> 
> The app I'm working on (Xorp) does not appear to work.  Perhaps because
> the kernel does not clean up the cached route when you un-bind
> as it does in the (re)bind logic?
> 
>                                  /* Remove any cached route for this socket. */
>                                  sk_dst_reset(sk);
> 

Ok, the patch below is how I'm dealing with this.

Let me know if things work better now, and also I would appreciate
it if you could contact the man page maintainers to remove the
optlen==0 language.

Thanks.

>From 136f55cf4ad0a3b0185bfc97c68f9e4d74ddcfe7 Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 14 Sep 2007 13:10:17 -0700
Subject: [PATCH] [NET]: Fix two issues wrt. SO_BINDTODEVICE.

1) Comments suggest that setting optlen to zero will unbind
   the socket from whatever device it might be attached to.  This
   hasn't been the case since at least 2.2.x because the first thing
   this function does is return -EINVAL if 'optlen' is less than
   sizeof(int).

   Furthermore, there are not "optlen == 0" tests in the
   SO_BINDTODEVICE code either.

   This also means we can toss the "!valbool" code block because if
   that is true we'll also see the first byte of the passed in name
   buffer as '\0' and this will also unbind the socket.

2) We should reset the cached route of the socket after we have made
   the device binding changes, not before.

Reported by Ben Greear.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/sock.c |   39 +++++++++++++++++----------------------
 1 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index cfed7d4..96be0ed 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -591,36 +591,31 @@ set_rcvbuf:
 
 		/* Bind this socket to a particular device like "eth0",
 		 * as specified in the passed interface name. If the
-		 * name is "" or the option length is zero the socket
-		 * is not bound.
+		 * name is "", the socket is not bound.
 		 */
+		if (optlen > IFNAMSIZ - 1)
+			optlen = IFNAMSIZ - 1;
+		memset(devname, 0, sizeof(devname));
+		if (copy_from_user(devname, optval, optlen)) {
+			ret = -EFAULT;
+			break;
+		}
 
-		if (!valbool) {
+		if (devname[0] == '\0') {
 			sk->sk_bound_dev_if = 0;
 		} else {
-			if (optlen > IFNAMSIZ - 1)
-				optlen = IFNAMSIZ - 1;
-			memset(devname, 0, sizeof(devname));
-			if (copy_from_user(devname, optval, optlen)) {
-				ret = -EFAULT;
+			struct net_device *dev = dev_get_by_name(devname);
+			if (!dev) {
+				ret = -ENODEV;
 				break;
 			}
+			sk->sk_bound_dev_if = dev->ifindex;
+			dev_put(dev);
+		}
 
-			/* Remove any cached route for this socket. */
-			sk_dst_reset(sk);
+		/* Remove any cached route for this socket. */
+		sk_dst_reset(sk);
 
-			if (devname[0] == '\0') {
-				sk->sk_bound_dev_if = 0;
-			} else {
-				struct net_device *dev = dev_get_by_name(devname);
-				if (!dev) {
-					ret = -ENODEV;
-					break;
-				}
-				sk->sk_bound_dev_if = dev->ifindex;
-				dev_put(dev);
-			}
-		}
 		break;
 	}
 #endif
-- 
1.5.2.4

