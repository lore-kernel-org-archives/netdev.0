From: Pablo Neira <pablo@eurodev.net>
Subject: [PATCH 2.6] fix zombie netlink socket in user space
Date: Sun, 19 Sep 2004 07:28:15 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414D18EF.3080207@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000100000407020505030203"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Herbert Xu <herbert@gondor.apana.org.au>, jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000100000407020505030203
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Davem,

If you try to bind/connect to a non existant netlink socket, client 
socket gets succesfully inserted as head in the socket list. The problem 
is that the head can't be delete, so that socket stays in the list 
forever (see sk_del_node_init).

If I'm missing something, please let me know. I'll submit a 2.4 version

regards,
Pablo

--------------000100000407020505030203
Content-Type: text/x-patch;
 name="netlink-fix-zombie.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink-fix-zombie.patch"

diff -u -r1.2 af_netlink.c
--- a/net/netlink/af_netlink.c	19 Sep 2004 04:41:12 -0000	1.2
+++ b/net/netlink/af_netlink.c	19 Sep 2004 05:20:51 -0000
@@ -306,6 +306,19 @@
 	return 0;
 }
 
+static inline int netlink_socket_exist(int protocol)
+{
+	/* Wanna bind to an non-existant netlink socket? */
+	netlink_table_grab();
+	if (!sk_head(&nl_table[protocol])) {
+		netlink_table_ungrab();
+		return 0;
+	}
+	netlink_table_ungrab();
+
+	return 1;
+}
+
 static int netlink_autobind(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -351,6 +364,9 @@
 	if (nladdr->nl_family != AF_NETLINK)
 		return -EINVAL;
 
+        if (!netlink_socket_exist(sk->sk_protocol))
+		return -ENOENT;
+
 	/* Only superuser is allowed to listen multicasts */
 	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_RECV))
 		return -EPERM;
@@ -392,6 +408,9 @@
 	if (addr->sa_family != AF_NETLINK)
 		return -EINVAL;
 
+        if (!netlink_socket_exist(sk->sk_protocol))
+		return -ENOENT;
+
 	/* Only superuser is allowed to send multicasts */
 	if (nladdr->nl_groups && !netlink_capable(sock, NL_NONROOT_SEND))
 		return -EPERM;

--------------000100000407020505030203--
