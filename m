From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH v5] net: ip, diag -- Add diag interface for raw sockets
Date: Wed, 28 Sep 2016 12:03:57 +0300
Message-ID: <20160928090357.GT1876@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
        avagin@openvz.org, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33244 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751892AbcI1JEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 05:04:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In criu we are actively using diag interface to collect sockets
present in the system when dumping applications. And while for
unix, tcp, udp[lite], packet, netlink it works as expected,
the raw sockets do not have. Thus add it.

v2:
 - add missing sock_put calls in raw_diag_dump_one (by eric.dumazet@)
 - implement @destroy for diag requests (by dsa@)

v3:
 - add export of raw_abort for IPv6 (by dsa@)
 - pass net-admin flag into inet_sk_diag_fill due to
   changes in net-next branch (by dsa@)

v4:
 - use @pad in struct inet_diag_req_v2 for raw socket
   protocol specification: raw module carries sockets
   which may have custom protocol passed from socket()
   syscall and sole @sdiag_protocol is not enough to
   match underlied ones
 - start reporting protocol specifed in socket() call
   when sockets are raw ones for the same reason: user
   space tools like ss may parse this attribute and use
   it for socket matching

v5 (by eric.dumazet@):
 - use sock_hold in raw_sock_get instead of atomic_inc,
   we're holding (raw_v4_hashinfo|raw_v6_hashinfo)->lock
   when looking up so counter won't be zero here.

CC: David S. Miller <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David Ahern <dsa@cumulusnetworks.com>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Andrey Vagin <avagin@openvz.org>
CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---

Thanks all for feedback! Take a look please once time permit.

 include/net/raw.h              |    6 +
 include/net/rawv6.h            |    7 +
 include/uapi/linux/inet_diag.h |    5 
 net/ipv4/Kconfig               |    8 +
 net/ipv4/Makefile              |    1 
 net/ipv4/inet_diag.c           |    9 +
 net/ipv4/raw.c                 |   21 +++
 net/ipv4/raw_diag.c            |  233 +++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c                 |    7 -
 9 files changed, 292 insertions(+), 5 deletions(-)

Index: linux-ml.git/include/net/raw.h
===================================================================
--- linux-ml.git.orig/include/net/raw.h
+++ linux-ml.git/include/net/raw.h
@@ -23,6 +23,12 @@
 
 extern struct proto raw_prot;
 
+extern struct raw_hashinfo raw_v4_hashinfo;
+struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
+			     unsigned short num, __be32 raddr,
+			     __be32 laddr, int dif);
+
+int raw_abort(struct sock *sk, int err);
 void raw_icmp_error(struct sk_buff *, int, u32);
 int raw_local_deliver(struct sk_buff *, int);
 
Index: linux-ml.git/include/net/rawv6.h
===================================================================
--- linux-ml.git.orig/include/net/rawv6.h
+++ linux-ml.git/include/net/rawv6.h
@@ -3,6 +3,13 @@
 
 #include <net/protocol.h>
 
+extern struct raw_hashinfo raw_v6_hashinfo;
+struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
+			     unsigned short num, const struct in6_addr *loc_addr,
+			     const struct in6_addr *rmt_addr, int dif);
+
+int raw_abort(struct sock *sk, int err);
+
 void raw6_icmp_error(struct sk_buff *, int nexthdr,
 		u8 type, u8 code, int inner_offset, __be32);
 bool raw6_local_deliver(struct sk_buff *, int);
Index: linux-ml.git/include/uapi/linux/inet_diag.h
===================================================================
--- linux-ml.git.orig/include/uapi/linux/inet_diag.h
+++ linux-ml.git/include/uapi/linux/inet_diag.h
@@ -38,7 +38,10 @@ struct inet_diag_req_v2 {
 	__u8	sdiag_family;
 	__u8	sdiag_protocol;
 	__u8	idiag_ext;
-	__u8	pad;
+	union {
+		__u8	pad;
+		__u8	sdiag_raw_protocol;	/* SOCK_RAW only, @pad for others */
+	};
 	__u32	idiag_states;
 	struct inet_diag_sockid id;
 };
Index: linux-ml.git/net/ipv4/Kconfig
===================================================================
--- linux-ml.git.orig/net/ipv4/Kconfig
+++ linux-ml.git/net/ipv4/Kconfig
@@ -430,6 +430,14 @@ config INET_UDP_DIAG
 	  Support for UDP socket monitoring interface used by the ss tool.
 	  If unsure, say Y.
 
+config INET_RAW_DIAG
+	tristate "RAW: socket monitoring interface"
+	depends on INET_DIAG && (IPV6 || IPV6=n)
+	default n
+	---help---
+	  Support for RAW socket monitoring interface used by the ss tool.
+	  If unsure, say Y.
+
 config INET_DIAG_DESTROY
 	bool "INET: allow privileged process to administratively close sockets"
 	depends on INET_DIAG
Index: linux-ml.git/net/ipv4/Makefile
===================================================================
--- linux-ml.git.orig/net/ipv4/Makefile
+++ linux-ml.git/net/ipv4/Makefile
@@ -40,6 +40,7 @@ obj-$(CONFIG_NETFILTER)	+= netfilter.o n
 obj-$(CONFIG_INET_DIAG) += inet_diag.o 
 obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
 obj-$(CONFIG_INET_UDP_DIAG) += udp_diag.o
+obj-$(CONFIG_INET_RAW_DIAG) += raw_diag.o
 obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_CDG) += tcp_cdg.o
Index: linux-ml.git/net/ipv4/inet_diag.c
===================================================================
--- linux-ml.git.orig/net/ipv4/inet_diag.c
+++ linux-ml.git/net/ipv4/inet_diag.c
@@ -200,6 +200,15 @@ int inet_sk_diag_fill(struct sock *sk, s
 		if (sock_diag_put_meminfo(sk, skb, INET_DIAG_SKMEMINFO))
 			goto errout;
 
+	/*
+	 * RAW sockets might have user-defined protocols assigned,
+	 * so report the one supplied on socket creation.
+	 */
+	if (sk->sk_type == SOCK_RAW) {
+		if (nla_put_u8(skb, INET_DIAG_PROTOCOL, sk->sk_protocol))
+			goto errout;
+	}
+
 	if (!icsk) {
 		handler->idiag_get_info(sk, r, NULL);
 		goto out;
Index: linux-ml.git/net/ipv4/raw.c
===================================================================
--- linux-ml.git.orig/net/ipv4/raw.c
+++ linux-ml.git/net/ipv4/raw.c
@@ -89,9 +89,10 @@ struct raw_frag_vec {
 	int hlen;
 };
 
-static struct raw_hashinfo raw_v4_hashinfo = {
+struct raw_hashinfo raw_v4_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v4_hashinfo.lock),
 };
+EXPORT_SYMBOL_GPL(raw_v4_hashinfo);
 
 int raw_hash_sk(struct sock *sk)
 {
@@ -120,7 +121,7 @@ void raw_unhash_sk(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(raw_unhash_sk);
 
-static struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
+struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
 		unsigned short num, __be32 raddr, __be32 laddr, int dif)
 {
 	sk_for_each_from(sk) {
@@ -136,6 +137,7 @@ static struct sock *__raw_v4_lookup(stru
 found:
 	return sk;
 }
+EXPORT_SYMBOL_GPL(__raw_v4_lookup);
 
 /*
  *	0 - deliver
@@ -918,6 +920,20 @@ static int compat_raw_ioctl(struct sock
 }
 #endif
 
+int raw_abort(struct sock *sk, int err)
+{
+	lock_sock(sk);
+
+	sk->sk_err = err;
+	sk->sk_error_report(sk);
+	udp_disconnect(sk, 0);
+
+	release_sock(sk);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(raw_abort);
+
 struct proto raw_prot = {
 	.name		   = "RAW",
 	.owner		   = THIS_MODULE,
@@ -943,6 +959,7 @@ struct proto raw_prot = {
 	.compat_getsockopt = compat_raw_getsockopt,
 	.compat_ioctl	   = compat_raw_ioctl,
 #endif
+	.diag_destroy	   = raw_abort,
 };
 
 #ifdef CONFIG_PROC_FS
Index: linux-ml.git/net/ipv4/raw_diag.c
===================================================================
--- /dev/null
+++ linux-ml.git/net/ipv4/raw_diag.c
@@ -0,0 +1,233 @@
+#include <linux/module.h>
+
+#include <linux/inet_diag.h>
+#include <linux/sock_diag.h>
+
+#include <net/raw.h>
+#include <net/rawv6.h>
+
+#ifdef pr_fmt
+# undef pr_fmt
+#endif
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+static struct raw_hashinfo *
+raw_get_hashinfo(const struct inet_diag_req_v2 *r)
+{
+	if (r->sdiag_family == AF_INET) {
+		return &raw_v4_hashinfo;
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if (r->sdiag_family == AF_INET6) {
+		return &raw_v6_hashinfo;
+#endif
+	} else {
+		pr_warn_once("Unexpected inet family %d\n",
+			     r->sdiag_family);
+		WARN_ON_ONCE(1);
+		return ERR_PTR(-EINVAL);
+	}
+}
+
+static struct sock *raw_lookup(struct net *net, struct sock *from,
+			       const struct inet_diag_req_v2 *r)
+{
+	struct sock *sk = NULL;
+
+	if (r->sdiag_family == AF_INET)
+		sk = __raw_v4_lookup(net, from, r->sdiag_raw_protocol,
+				     r->id.idiag_dst[0],
+				     r->id.idiag_src[0],
+				     r->id.idiag_if);
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		sk = __raw_v6_lookup(net, from, r->sdiag_raw_protocol,
+				     (const struct in6_addr *)r->id.idiag_src,
+				     (const struct in6_addr *)r->id.idiag_dst,
+				     r->id.idiag_if);
+#endif
+	return sk;
+}
+
+static struct sock *raw_sock_get(struct net *net, const struct inet_diag_req_v2 *r)
+{
+	struct raw_hashinfo *hashinfo = raw_get_hashinfo(r);
+	struct sock *sk = NULL, *s;
+	int slot;
+
+	if (IS_ERR(hashinfo))
+		return ERR_CAST(hashinfo);
+
+	read_lock(&hashinfo->lock);
+	for (slot = 0; slot < RAW_HTABLE_SIZE; slot++) {
+		sk_for_each(s, &hashinfo->ht[slot]) {
+			sk = raw_lookup(net, s, r);
+			if (sk) {
+				/*
+				 * Grab it and keep until we fill
+				 * diag message to be reported, so
+				 * caller should call sock_put then.
+				 * We can do that because we're keeping
+				 * hashinfo->lock here.
+				 */
+				sock_hold(sk);
+				break;
+			}
+		}
+	}
+	read_unlock(&hashinfo->lock);
+
+	return sk ? sk : ERR_PTR(-ENOENT);
+}
+
+static int raw_diag_dump_one(struct sk_buff *in_skb,
+			     const struct nlmsghdr *nlh,
+			     const struct inet_diag_req_v2 *r)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct sk_buff *rep;
+	struct sock *sk;
+	int err;
+
+	sk = raw_sock_get(net, r);
+	if (IS_ERR(sk))
+		return PTR_ERR(sk);
+
+	rep = nlmsg_new(sizeof(struct inet_diag_msg) +
+			sizeof(struct inet_diag_meminfo) + 64,
+			GFP_KERNEL);
+	if (!rep) {
+		sock_put(sk);
+		return -ENOMEM;
+	}
+
+	err = inet_sk_diag_fill(sk, NULL, rep, r,
+				sk_user_ns(NETLINK_CB(in_skb).sk),
+				NETLINK_CB(in_skb).portid,
+				nlh->nlmsg_seq, 0, nlh,
+				netlink_net_capable(in_skb, CAP_NET_ADMIN));
+	sock_put(sk);
+
+	if (err < 0) {
+		kfree_skb(rep);
+		return err;
+	}
+
+	err = netlink_unicast(net->diag_nlsk, rep,
+			      NETLINK_CB(in_skb).portid,
+			      MSG_DONTWAIT);
+	if (err > 0)
+		err = 0;
+	return err;
+}
+
+static int sk_diag_dump(struct sock *sk, struct sk_buff *skb,
+			struct netlink_callback *cb,
+			const struct inet_diag_req_v2 *r,
+			struct nlattr *bc, bool net_admin)
+{
+	if (!inet_diag_bc_sk(bc, sk))
+		return 0;
+
+	return inet_sk_diag_fill(sk, NULL, skb, r,
+			sk_user_ns(NETLINK_CB(cb->skb).sk),
+			NETLINK_CB(cb->skb).portid,
+			cb->nlh->nlmsg_seq, NLM_F_MULTI,
+			cb->nlh, net_admin);
+}
+
+static void raw_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			  const struct inet_diag_req_v2 *r, struct nlattr *bc)
+{
+	bool net_admin = netlink_net_capable(cb->skb, CAP_NET_ADMIN);
+	struct raw_hashinfo *hashinfo = raw_get_hashinfo(r);
+	struct net *net = sock_net(skb->sk);
+	int num, s_num, slot, s_slot;
+	struct sock *sk = NULL;
+
+	if (IS_ERR(hashinfo))
+		return;
+
+	s_slot = cb->args[0];
+	num = s_num = cb->args[1];
+
+	read_lock(&hashinfo->lock);
+	for (slot = s_slot; slot < RAW_HTABLE_SIZE; s_num = 0, slot++) {
+		num = 0;
+
+		sk_for_each(sk, &hashinfo->ht[slot]) {
+			struct inet_sock *inet = inet_sk(sk);
+
+			if (!net_eq(sock_net(sk), net))
+				continue;
+			if (num < s_num)
+				goto next;
+			if (sk->sk_family != r->sdiag_family)
+				goto next;
+			if (r->id.idiag_sport != inet->inet_sport &&
+			    r->id.idiag_sport)
+				goto next;
+			if (r->id.idiag_dport != inet->inet_dport &&
+			    r->id.idiag_dport)
+				goto next;
+			if (sk_diag_dump(sk, skb, cb, r, bc, net_admin) < 0)
+				goto out_unlock;
+next:
+			num++;
+		}
+	}
+
+out_unlock:
+	read_unlock(&hashinfo->lock);
+
+	cb->args[0] = slot;
+	cb->args[1] = num;
+}
+
+static void raw_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
+			      void *info)
+{
+	r->idiag_rqueue = sk_rmem_alloc_get(sk);
+	r->idiag_wqueue = sk_wmem_alloc_get(sk);
+}
+
+#ifdef CONFIG_INET_DIAG_DESTROY
+static int raw_diag_destroy(struct sk_buff *in_skb,
+			    const struct inet_diag_req_v2 *r)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct sock *sk;
+
+	sk = raw_sock_get(net, r);
+	if (IS_ERR(sk))
+		return PTR_ERR(sk);
+	return sock_diag_destroy(sk, ECONNABORTED);
+}
+#endif
+
+static const struct inet_diag_handler raw_diag_handler = {
+	.dump			= raw_diag_dump,
+	.dump_one		= raw_diag_dump_one,
+	.idiag_get_info		= raw_diag_get_info,
+	.idiag_type		= IPPROTO_RAW,
+	.idiag_info_size	= 0,
+#ifdef CONFIG_INET_DIAG_DESTROY
+	.destroy		= raw_diag_destroy,
+#endif
+};
+
+static int __init raw_diag_init(void)
+{
+	return inet_diag_register(&raw_diag_handler);
+}
+
+static void __exit raw_diag_exit(void)
+{
+	inet_diag_unregister(&raw_diag_handler);
+}
+
+module_init(raw_diag_init);
+module_exit(raw_diag_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 2-255 /* AF_INET - IPPROTO_RAW */);
+MODULE_ALIAS_NET_PF_PROTO_TYPE(PF_NETLINK, NETLINK_SOCK_DIAG, 10-255 /* AF_INET6 - IPPROTO_RAW */);
Index: linux-ml.git/net/ipv6/raw.c
===================================================================
--- linux-ml.git.orig/net/ipv6/raw.c
+++ linux-ml.git/net/ipv6/raw.c
@@ -65,11 +65,12 @@
 
 #define	ICMPV6_HDRLEN	4	/* ICMPv6 header, RFC 4443 Section 2.1 */
 
-static struct raw_hashinfo raw_v6_hashinfo = {
+struct raw_hashinfo raw_v6_hashinfo = {
 	.lock = __RW_LOCK_UNLOCKED(raw_v6_hashinfo.lock),
 };
+EXPORT_SYMBOL_GPL(raw_v6_hashinfo);
 
-static struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
+struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
 		unsigned short num, const struct in6_addr *loc_addr,
 		const struct in6_addr *rmt_addr, int dif)
 {
@@ -102,6 +103,7 @@ static struct sock *__raw_v6_lookup(stru
 found:
 	return sk;
 }
+EXPORT_SYMBOL_GPL(__raw_v6_lookup);
 
 /*
  *	0 - deliver
@@ -1252,6 +1254,7 @@ struct proto rawv6_prot = {
 	.compat_getsockopt = compat_rawv6_getsockopt,
 	.compat_ioctl	   = compat_rawv6_ioctl,
 #endif
+	.diag_destroy	   = raw_abort,
 };
 
 #ifdef CONFIG_PROC_FS
