From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [PATCH net-next v5 1/2] New kernel function to get IP overhead on
 a socket.
Date: Wed, 5 Apr 2017 16:50:35 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1704051644350.19131@vera98.eng.brocade.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jchapman@katalix.com, kleptog@svana.org, nprachan@brocade.com,
        rshearma@brocade.com, stephen@networkplumber.org,
        sdietric@brocade.com, ciwillia@brocade.com, lboccass@brocade.com,
        dfawcus@brocade.com, bhong@brocade.com, jblunck@brocade.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34241 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752652AbdDEXui (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 19:50:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A new function, kernel_sock_ip_overhead(), is provided
to calculate the cumulative overhead imposed by the IP
Header and IP options, if any, on a socket's payload.
The new function returns an overhead of zero for sockets
that do not belong to the IPv4 or IPv6 address families.
This is used in the L2TP code path to compute the
total outer IP overhead on the L2TP tunnel socket when
calculating the default MTU for Ethernet pseudowires.

Signed-off-by: R. Parameswaran <rparames@brocade.com>
---
 include/linux/net.h |  3 +++
 net/socket.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index 0620f5e..a42fab2 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -298,6 +298,9 @@ int kernel_sendpage(struct socket *sock, struct page *page, int offset,
 int kernel_sock_ioctl(struct socket *sock, int cmd, unsigned long arg);
 int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how);
 
+/* Following routine returns the IP overhead imposed by a socket.  */
+u32 kernel_sock_ip_overhead(struct sock *sk);
+
 #define MODULE_ALIAS_NETPROTO(proto) \
 	MODULE_ALIAS("net-pf-" __stringify(proto))
 
diff --git a/net/socket.c b/net/socket.c
index 985ef06..eea9970 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3356,3 +3356,49 @@ int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
 	return sock->ops->shutdown(sock, how);
 }
 EXPORT_SYMBOL(kernel_sock_shutdown);
+
+/* This routine returns the IP overhead imposed by a socket i.e.
+ * the length of the underlying IP header, depending on whether
+ * this is an IPv4 or IPv6 socket and the length from IP options turned
+ * on at the socket.
+ */
+u32 kernel_sock_ip_overhead(struct sock *sk)
+{
+	struct inet_sock *inet;
+	struct ip_options_rcu *opt;
+	u32 overhead = 0;
+	bool owned_by_user;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct ipv6_pinfo *np;
+	struct ipv6_txoptions *optv6 = NULL;
+#endif /* IS_ENABLED(CONFIG_IPV6) */
+
+	if (!sk)
+		return overhead;
+
+	owned_by_user = sock_owned_by_user(sk);
+	switch (sk->sk_family) {
+	case AF_INET:
+		inet = inet_sk(sk);
+		overhead += sizeof(struct iphdr);
+		opt = rcu_dereference_protected(inet->inet_opt,
+						owned_by_user);
+		if (opt)
+			overhead += opt->opt.optlen;
+		return overhead;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		np = inet6_sk(sk);
+		overhead += sizeof(struct ipv6hdr);
+		if (np)
+			optv6 = rcu_dereference_protected(np->opt,
+							  owned_by_user);
+		if (optv6)
+			overhead += (optv6->opt_flen + optv6->opt_nflen);
+		return overhead;
+#endif /* IS_ENABLED(CONFIG_IPV6) */
+	default: /* Returns 0 overhead if the socket is not ipv4 or ipv6 */
+		return overhead;
+	}
+}
+EXPORT_SYMBOL(kernel_sock_ip_overhead);
-- 
2.1.4
