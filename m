From: David Miller <davem@davemloft.net>
Subject: [PATCH]: New SO_BINDTODEVICE fix.
Date: Fri, 14 Sep 2007 16:42:43 -0700 (PDT)
Message-ID: <20070914.164243.41634621.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758670AbXINXmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 19:42:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ok, I changed my mind and decided to retain the optlen==0
intended behavior.  It fell out of fixing the small
string length case.

This is likely what I'll push to Linus and later -stable
as a fix for this stuff.

Thanks.

commit 4878809f711981a602cc562eb47994fc81ea0155
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Fri Sep 14 16:41:03 2007 -0700

    [NET]: Fix two issues wrt. SO_BINDTODEVICE.
    
    1) Comments suggest that setting optlen to zero will unbind
       the socket from whatever device it might be attached to.  This
       hasn't been the case since at least 2.2.x because the first thing
       this function does is return -EINVAL if 'optlen' is less than
       sizeof(int).
    
       This check also means that passing in a two byte string doesn't
       work so well.  It's almost as if this code was testing with "eth?"
       patterned strings and nothing else :-)
    
       Fix this by breaking the logic of this facility out into a
       seperate function which validates optlen more appropriately.
    
       The optlen==0 and small string cases now work properly.
    
    2) We should reset the cached route of the socket after we have made
       the device binding changes, not before.
    
    Reported by Ben Greear.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/sock.c b/net/core/sock.c
index cfed7d4..190de61 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -362,6 +362,61 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
 }
 EXPORT_SYMBOL(sk_dst_check);
 
+static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
+{
+	int ret = -ENOPROTOOPT;
+#ifdef CONFIG_NETDEVICES
+	char devname[IFNAMSIZ];
+	int index;
+
+	/* Sorry... */
+	ret = -EPERM;
+	if (!capable(CAP_NET_RAW))
+		goto out;
+
+	ret = -EINVAL;
+	if (optlen < 0)
+		goto out;
+
+	/* Bind this socket to a particular device like "eth0",
+	 * as specified in the passed interface name. If the
+	 * name is "" or the option length is zero the socket
+	 * is not bound.
+	 */
+	if (optlen > IFNAMSIZ - 1)
+		optlen = IFNAMSIZ - 1;
+	memset(devname, 0, sizeof(devname));
+
+	ret = -EFAULT;
+	if (copy_from_user(devname, optval, optlen))
+		goto out;
+
+	if (devname[0] == '\0') {
+		index = 0;
+	} else {
+		struct net_device *dev = dev_get_by_name(devname);
+
+		ret = -ENODEV;
+		if (!dev)
+			goto out;
+
+		index = dev->ifindex;
+		dev_put(dev);
+	}
+
+	lock_sock(sk);
+	sk->sk_bound_dev_if = index;
+	sk_dst_reset(sk);
+	release_sock(sk);
+
+	ret = 0;
+
+out:
+#endif
+
+	return ret;
+}
+
 /*
  *	This is meant for all protocols to use and covers goings on
  *	at the socket level. Everything here is generic.
@@ -390,6 +445,9 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	}
 #endif
 
+	if (optname == SO_BINDTODEVICE)
+		return sock_bindtodevice(sk, optval, optlen);
+
 	if (optlen < sizeof(int))
 		return -EINVAL;
 
@@ -578,54 +636,6 @@ set_rcvbuf:
 		ret = sock_set_timeout(&sk->sk_sndtimeo, optval, optlen);
 		break;
 
-#ifdef CONFIG_NETDEVICES
-	case SO_BINDTODEVICE:
-	{
-		char devname[IFNAMSIZ];
-
-		/* Sorry... */
-		if (!capable(CAP_NET_RAW)) {
-			ret = -EPERM;
-			break;
-		}
-
-		/* Bind this socket to a particular device like "eth0",
-		 * as specified in the passed interface name. If the
-		 * name is "" or the option length is zero the socket
-		 * is not bound.
-		 */
-
-		if (!valbool) {
-			sk->sk_bound_dev_if = 0;
-		} else {
-			if (optlen > IFNAMSIZ - 1)
-				optlen = IFNAMSIZ - 1;
-			memset(devname, 0, sizeof(devname));
-			if (copy_from_user(devname, optval, optlen)) {
-				ret = -EFAULT;
-				break;
-			}
-
-			/* Remove any cached route for this socket. */
-			sk_dst_reset(sk);
-
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
-		break;
-	}
-#endif
-
-
 	case SO_ATTACH_FILTER:
 		ret = -EINVAL;
 		if (optlen == sizeof(struct sock_fprog)) {
