From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Wed, 31 Oct 2012 16:06:49 -0400
Message-ID: <509184D9.8030103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:10971 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759725Ab2JaUGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 16:06:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
will then require another call like if_indextoname() to get the actual interface
name, have it return the name directly.

This also matches the existing man page description on socket(7) which mentions
the argument being an interface name.

If the value has not been set, zero is returned and optlen will be set to zero
to indicate there is no interface name present.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--

diff --git a/net/core/sock.c b/net/core/sock.c
index 0a023b8..9172ff4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -505,7 +505,8 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
 }
 EXPORT_SYMBOL(sk_dst_check);

-static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
+static int sock_setbindtodevice(struct sock *sk, char __user *optval,
+				int optlen)
 {
 	int ret = -ENOPROTOOPT;
 #ifdef CONFIG_NETDEVICES
@@ -562,6 +563,52 @@ out:
 	return ret;
 }

+static int sock_getbindtodevice(struct sock *sk, char __user *optval,
+				int __user *optlen, int len)
+{
+	int ret = -ENOPROTOOPT;
+#ifdef CONFIG_NETDEVICES
+	struct net *net = sock_net(sk);
+	struct net_device *dev;
+	char devname[IFNAMSIZ];
+
+	if (sk->sk_bound_dev_if == 0) {
+		len = 0;
+		goto zero;
+	}
+
+	ret = -EINVAL;
+	if (len < IFNAMSIZ)
+		goto out;
+
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
+	if (dev)
+		strcpy(devname, dev->name);
+	rcu_read_unlock();
+	ret = -ENODEV;
+	if (!dev)
+		goto out;
+
+	len = strlen(devname) + 1;
+
+	ret = -EFAULT;
+	if (copy_to_user(optval, devname, len))
+		goto out;
+
+zero:
+	ret = -EFAULT;
+	if (put_user(len, optlen))
+		goto out;
+
+	ret = 0;
+
+out:
+#endif
+
+	return ret;
+}
+
 static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
 {
 	if (valbool)
@@ -589,7 +636,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	 */

 	if (optname == SO_BINDTODEVICE)
-		return sock_bindtodevice(sk, optval, optlen);
+		return sock_setbindtodevice(sk, optval, optlen);

 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -1074,9 +1121,10 @@ int sock_getsockopt(struct socket *sock, int level, int
optname,
 	case SO_NOFCS:
 		v.val = sock_flag(sk, SOCK_NOFCS);
 		break;
+
 	case SO_BINDTODEVICE:
-		v.val = sk->sk_bound_dev_if;
-		break;
+		return sock_getbindtodevice(sk, optval, optlen, len);
+
 	default:
 		return -ENOPROTOOPT;
 	}
