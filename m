From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [PATCH net-next v3 1/2]L2TP:Adjust intf MTU, add underlay L3, L2
 hdrs
Date: Thu, 16 Mar 2017 21:33:54 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1703162125310.7174@vera100.eng.brocade.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kleptog@svana.org, jchapman@katalix.com, mostrows@speakeasy.net,
        acme@xconectiva.com.br, davem@redhat.com, nprachan@brocade.com,
        rshearma@brocade.com, stephen@networkplumber.org,
        sdietric@brocade.com, ciwillia@brocade.com, lboccass@brocade.com,
        dfawcus@brocade.com, bhong@brocade.com, jblunck@brocade.com,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



In existing kernel code, when setting up the L2TP interface, all of the
tunnel encapsulation headers are not taken into account when setting
up the MTU on the  L2TP logical interface device. Due to this, the
packets created by the applications on top of the L2TP layer are larger
than they ought to be, relative to the underlay MTU, which leads to
needless fragmentation once the L2TP packet is encapsulated in an outer IP
packet.

Specifically, the MTU calculation  does not take into account the (outer)
IP header imposed on the encapsulated L2TP packet, and the Layer 2 header
imposed on the inner L2TP packet prior to encapsulation. The patch posted
here takes care of these.

Existing code also seems to assume an Ethernet (non-jumbo) underlay. The
patch uses the PMTU mechanism and the dst entry in the L2TP tunnel socket
to directly pull up the underlay MTU (as the baseline number on top of
which the encapsulation headers are factored in).  Ethernet MTU is
assumed as a fallback only if this fails.

Picked up review comments from James Chapman, added a function
to compute ip header + ip option overhead on a socket, and factored it
into L2TP change-set.

Signed-off-by: R. Parameswaran <rparames@brocade.com>
---
 include/linux/net.h |  3 +++
 net/socket.c        | 41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

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
index e034fe4..af54b12 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3345,3 +3345,44 @@ int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
 	return sock->ops->shutdown(sock, how);
 }
 EXPORT_SYMBOL(kernel_sock_shutdown);
+
+/*	This routine returns the IP overhead imposed by a socket i.e.
+ *	the length of the underlying IP header, depending on whether
+ *	this is an IPv4 or IPv6 socket and the length from IP options turned
+ *	on at the socket.
+ */
+u32 kernel_sock_ip_overhead(struct sock *sk)
+{
+	struct inet_sock *inet;
+	struct ipv6_pinfo *np;
+	struct ip_options_rcu *opt = NULL;
+	struct ipv6_txoptions *optv6 = NULL;
+	u32 overhead = 0;
+	bool owned_by_user = sock_owned_by_user(sk);
+
+	if (!sk)
+		return overhead;
+	switch (sk->sk_family) {
+	case AF_INET:
+		inet = inet_sk(sk);
+		overhead += sizeof(struct iphdr);
+		if (inet)
+			opt = rcu_dereference_protected(inet->inet_opt,
+							owned_by_user);
+		if (opt)
+			overhead += opt->opt.optlen;
+		return overhead;
+	case AF_INET6:
+		np = inet6_sk(sk);
+		overhead += sizeof(struct ipv6hdr);
+		if (np)
+			optv6 = rcu_dereference_protected(np->opt,
+							  owned_by_user);
+		if (optv6)
+			overhead += (optv6->opt_flen + optv6->opt_nflen);
+		return overhead;
+	default: /* Returns 0 overhead if the socket is not ipv4 or ipv6 */
+		return overhead;
+	}
+}
+EXPORT_SYMBOL(kernel_sock_ip_overhead);
-- 
2.1.4
