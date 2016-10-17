From: "R. Parameswaran" <parameswaran.r7@gmail.com>
Subject: [RFC PATCH v3 1/2] L2TP:Adjust intf MTU,factor underlay L3,overlay
 L2
Date: Sun, 16 Oct 2016 21:05:51 -0700 (PDT)
Message-ID: <alpine.DEB.2.11.1610162104480.12804@duvvury48.eng.vyatta.net>
References: <alpine.DEB.2.11.1609221341500.6975@duvvury30.eng.vyatta.net> <57ED30D7.6000009@katalix.com> <alpine.DEB.2.11.1609291913070.8509@duvvury48.eng.vyatta.net> <1cec5be4-0719-0dca-d3c6-8c794c867672@katalix.com> <alpine.DEB.2.11.1610031954330.2198@duvvury48.eng.vyatta.net>
 <149288c4-a352-ae30-ad3a-91d1edfa4bce@katalix.com> <CAGeBGG7AS1JZYHC6T5_H6vY4wfptUtPzO=+kdCcUzJGXA0m6_A@mail.gmail.com> <52890af4-38d6-6aa7-a9e0-69be60fe89fa@katalix.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: R Parameswaran <parameswaran.r7@gmail.com>, kleptog@svana.org,
        netdev@vger.kernel.org, davem@redhat.com,
        linux-kernel@vger.kernel.org, nprachan@brocade.com,
        Robert Shearman <rshearma@brocade.com>, dfawcus@brocade.com,
        stephen@networkplumber.org, acme@redhat.com, lboccass@brocade.com,
        bhong@brocade.com
To: James Chapman <jchapman@katalix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52890af4-38d6-6aa7-a9e0-69be60fe89fa@katalix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[v3: Picked up review comments from James Chapman, added a
 function  to compute ip header + ip option overhead on a socket, and factored
 it  into L2TP change-set, RFC, would like early feedback on name and
 placement, and logic  of new function while I test this]

>From 30c4b3900d09deb912fc6ce4af3c19e870f84e14 Mon Sep 17 00:00:00 2001
From: "R. Parameswaran" <rparames@brocade.com>
Date: Sun, 16 Oct 2016 20:19:38 -0700

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

Signed-off-by: nprachan@brocade.com,
Signed-off-by: bhong@brocade.com,
Signed-off-by: rshearma@brocade.com,
Signed-off-by: dfawcus@brocade.com
---
 include/linux/net.h |  3 +++
 net/socket.c        | 37 +++++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)

diff --git a/include/linux/net.h b/include/linux/net.h
index cd0c8bd..2c8b092 100644
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
index 5a9bf5e..d5e79c2 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -3293,3 +3293,40 @@ int kernel_sock_shutdown(struct socket *sock, enum sock_shutdown_cmd how)
 	return sock->ops->shutdown(sock, how);
 }
 EXPORT_SYMBOL(kernel_sock_shutdown);
+
+/*
+ *	This routine returns the IP overhead imposed by a socket i.e.
+ *	the length of the underlying IP header, depending on whether
+ *      this is an IPv4 or IPv6 socket and the length from IP options turned
+ *      on at the socket.
+ */
+u32 kernel_sock_ip_overhead(struct sock *sk)
+{
+	u32 overhead = 0;
+	if (!sk)
+		goto done;
+	if (sk->sk_family == AF_INET) {
+		struct ip_options_rcu *opt = NULL;
+		struct inet_sock *inet = inet_sk(sk);
+		overhead += sizeof(struct iphdr);
+		if (inet)
+			opt = rcu_dereference_protected(inet->inet_opt,
+							sock_owned_by_user(sk));
+		if (opt)
+			overhead += opt->opt.optlen;
+	}
+	else if (sk->sk_family == AF_INET6) {
+		struct ipv6_pinfo *np = inet6_sk(sk);
+		struct ipv6_txoptions *opt = NULL;
+		overhead += sizeof(struct ipv6hdr);
+		if (np)
+			opt = rcu_dereference_protected(np->opt,
+							sock_owned_by_user(sk));
+		if (opt)
+			overhead += (opt->opt_flen + opt->opt_nflen);
+	}
+
+done:
+	return overhead;
+}
+EXPORT_SYMBOL_GPL(kernel_sock_ip_overhead);
-- 
2.1.4

----
On Tue, 11 Oct 2016, James Chapman wrote:

> 
> I think keep it simple. A function to return the size of the IP header
> associated with any IP socket, not necessarily a tunnel socket. Don't
> mix in any MTU derivation logic or UDP header size etc.
> 
> Post code early as an RFC. You're more likely to get review feedback
> from others.
> 
> 
> 
> 
