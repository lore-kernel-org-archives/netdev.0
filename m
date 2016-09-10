From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH v2] net: ip, diag -- Add diag interface for raw sockets
Date: Sun, 11 Sep 2016 01:05:28 +0300
Message-ID: <20160910220528.GB2001@uranus.lan>
References: <20160909182636.GC2366@uranus.lan>
 <de68cd54-849e-93d6-b291-83e8be010f9a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <de68cd54-849e-93d6-b291-83e8be010f9a@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 10, 2016 at 10:31:35AM -0600, David Ahern wrote:
> 
> Would you mind adding the destroy capability as well? The udp version
> should be close to what is needed for raw sockets. See udp_diag_destroy
> and udp_abort.

Should be something like below. Didn't tested it yet so for review only.
Will do testing at Monday.
---
From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [PATCH v2] net: ip, diag -- Add diag interface for raw sockets

In criu we are actively using diag interface to collect sockets
present in the system when dumping applications. And while for
unix, tcp, udp[lite], packet, netlink it works as expected,
the raw sockets do not have. Thus add it.

v2:
 - add missing sock_put calls in raw_diag_dump_one (by eric.dumazet@)
 - implement @destroy for diag requests (by dsa@)

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

Take a look please, once time permit. Hopefully I didn't
miss something obvious, tested as "ss -n -A raw" for modified
iproute2 instance and c/r for trivial application which has
raw sockets opened. A patch for ss tool is at https://goo.gl/VFQ93L
for the reference, will send it out then.

 include/net/raw.h   |    5 +
 include/net/rawv6.h |    5 +
 net/ipv4/Kconfig    |    8 +
 net/ipv4/Makefile   |    1 
 net/ipv4/raw.c      |   22 ++++-
 net/ipv4/raw_diag.c |  219 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/raw.c      |    7 +
 7 files changed, 263 insertions(+), 4 deletions(-)

Index: linux-ml.git/include/net/raw.h
===================================================================
--- linux-ml.git.orig/include/net/raw.h
+++ linux-ml.git/include/net/raw.h
@@ -23,6 +23,11 @@
 
 extern struct proto raw_prot;
 
+extern struct raw_hashinfo raw_v4_hashinfo;
+struct sock *__raw_v4_lookup(struct net *net, struct sock *sk,
+			     unsigned short num, __be32 raddr,
+			     __be32 laddr, int dif);
+
 void raw_icmp_error(struct sk_buff *, int, u32);
 int raw_local_deliver(struct sk_buff *, int);
 
Index: linux-ml.git/include/net/rawv6.h
===================================================================
--- linux-ml.git.orig/include/net/rawv6.h
+++ linux-ml.git/include/net/rawv6.h
@@ -3,6 +3,11 @@
 
 #include <net/protocol.h>
 
+extern struct raw_hashinfo raw_v6_hashinfo;
+struct sock *__raw_v6_lookup(struct net *net, struct sock *sk,
+			     unsigned short num, const struct in6_addr *loc_addr,
+			     const struct in6_addr *rmt_addr, int dif);
+
 void raw6_icmp_error(struct sk_buff *, int nexthdr,
 		u8 type, u8 code, int inner_offset, __be32);
 bool raw6_local_deliver(struct sk_buff *, int);
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
@@ -918,6 +920,21 @@ static int compat_raw_ioctl(struct sock
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
+	sock_put(sk);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(raw_abort);
+
 struct proto raw_prot = {
 	.name		   = "RAW",
 	.owner		   = THIS_MODULE,
@@ -943,6 +960,7 @@ struct proto raw_prot = {
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
@@ -0,0 +1,219 @@
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
+		sk = __raw_v4_lookup(net, from, r->sdiag_protocol,
+				     r->id.idiag_dst[0],
+				     r->id.idiag_src[0],
+				     r->id.idiag_if);
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		sk = __raw_v6_lookup(net, from, r->sdiag_protocol,
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
+			if (sk)
+				break;
+		}
+	}
+	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
+		sk = NULL;
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
+				nlh->nlmsg_seq, 0, nlh);
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
+			struct nlattr *bc)
+{
+	if (!inet_diag_bc_sk(bc, sk))
+		return 0;
+
+	return inet_sk_diag_fill(sk, NULL, skb, r,
+			sk_user_ns(NETLINK_CB(cb->skb).sk),
+			NETLINK_CB(cb->skb).portid,
+			cb->nlh->nlmsg_seq, NLM_F_MULTI, cb->nlh);
+}
+
+static void raw_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
+			  const struct inet_diag_req_v2 *r, struct nlattr *bc)
+{
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
+			if (sk_diag_dump(sk, skb, cb, r, bc) < 0)
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
+
+static const struct inet_diag_handler raw_diag_handler = {
+	.dump			= raw_diag_dump,
+	.dump_one		= raw_diag_dump_one,
+	.idiag_get_info		= raw_diag_get_info,
+	.idiag_type		= IPPROTO_RAW,
+	.idiag_info_size	= 0,
+	.destroy		= raw_diag_destroy,
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
