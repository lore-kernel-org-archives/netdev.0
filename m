From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] sockopt: Introduce the SO_BINDTOIFINDEX
Date: Tue, 23 Oct 2012 18:21:49 +0400
Message-ID: <5086A7FD.3020503@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Brian Haley <brian.haley@hp.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23029 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525Ab2JWOWa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2012 10:22:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gentlemen,

here's how the symmetrical sk_bound_dev set/get would look like. If it's OK
for you, I would ask David for inclusion.



It was noted that it was not good to have the non-symmetrical SO_BINDTODEVICE
sockoption (set works with name, get reports index) and we'd rather implement
another option to set and get socket bound device that work on ifindex.

The SO_BINDTONETDEV get-er is removed, as getting a device name is tricky and
having one doesn't worth that pain.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/uapi/asm-generic/socket.h |    2 +
 net/core/sock.c                   |   41 ++++++++++++++++++++++++++++++++++--
 2 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
index b1bea03..c99c843 100644
--- a/include/uapi/asm-generic/socket.h
+++ b/include/uapi/asm-generic/socket.h
@@ -72,4 +72,6 @@
 /* Instruct lower device to use last 4-bytes of skb data as FCS */
 #define SO_NOFCS		43
 
+#define SO_BINDTOIFINDEX	44
+
 #endif /* __ASM_GENERIC_SOCKET_H */
diff --git a/net/core/sock.c b/net/core/sock.c
index c49412c..c4f56e9 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -505,6 +505,39 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
 }
 EXPORT_SYMBOL(sk_dst_check);
 
+static void sock_set_bound_dev(struct sock *sk, int idx)
+{
+	sk->sk_bound_dev_if = idx;
+	sk_dst_reset(sk);
+}
+
+static int sock_bindtoindex(struct sock *sk, int idx)
+{
+	int ret = -ENOPROTOOPT;
+#ifdef CONFIG_NETDEVICES
+	struct net *net = sock_net(sk);
+
+	if (!capable(CAP_NET_RAW))
+		return -EPERM;
+
+	if (idx != 0) {
+		struct net_device *dev;
+
+		rcu_read_lock();
+		dev = dev_get_by_index_rcu(net, idx);
+		rcu_read_unlock();
+		ret = -ENODEV;
+		if (!dev)
+			goto out;
+	}
+
+	sock_set_bound_dev(sk, idx);
+	ret = 0;
+out:
+#endif
+	return ret;
+}
+
 static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 {
 	int ret = -ENOPROTOOPT;
@@ -550,8 +583,7 @@ static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
 	}
 
 	lock_sock(sk);
-	sk->sk_bound_dev_if = index;
-	sk_dst_reset(sk);
+	sock_set_bound_dev(sk, index);
 	release_sock(sk);
 
 	ret = 0;
@@ -839,6 +871,9 @@ set_rcvbuf:
 	case SO_NOFCS:
 		sock_valbool_flag(sk, SOCK_NOFCS, valbool);
 		break;
+	case SO_BINDTOIFINDEX:
+		ret = sock_bindtoindex(sk, val);
+		break;
 
 	default:
 		ret = -ENOPROTOOPT;
@@ -1074,7 +1109,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
 	case SO_NOFCS:
 		v.val = sock_flag(sk, SOCK_NOFCS);
 		break;
-	case SO_BINDTODEVICE:
+	case SO_BINDTOIFINDEX:
 		v.val = sk->sk_bound_dev_if;
 		break;
 	default:
-- 
1.7.6.5
