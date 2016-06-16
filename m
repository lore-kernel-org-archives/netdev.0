From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/8] tou: Base infrastructure for Transport over UDP
Date: Thu, 16 Jun 2016 10:51:57 -0700
Message-ID: <1466099522-690741-4-git-send-email-tom@herbertland.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46285 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754220AbcFPRwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 13:52:31 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GHobfc003095
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:25 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23kxw30q5f-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:25 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 152bf91e33eb11e6b7aa0002c9dfb610-84cc2e0 for <netdev@vger.kernel.org>;	Thu,
 16 Jun 2016 10:52:24 -0700
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tou.c that implements common setsockopt functionality. This includes
initialization and argument structure for the setsockopt.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/inet_sock.h        |   2 +
 include/net/ip_tunnels.h       |   1 +
 include/uapi/linux/if_tunnel.h |  10 +++
 net/ipv4/Makefile              |   3 +-
 net/ipv4/af_inet.c             |   4 ++
 net/ipv4/tou.c                 | 140 +++++++++++++++++++++++++++++++++++++++++
 6 files changed, 159 insertions(+), 1 deletion(-)
 create mode 100644 net/ipv4/tou.c

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 012b1f9..d39f383 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -167,6 +167,7 @@ struct rtable;
  * @uc_index - Unicast outgoing device index
  * @mc_index - Multicast device index
  * @mc_list - Group array
+ * @tou_encap - Transports over UDP encapsulation
  * @cork - info to build ip hdr on each ip frag while socket is corked
  */
 struct inet_sock {
@@ -209,6 +210,7 @@ struct inet_sock {
 	__be32			mc_addr;
 	struct ip_mc_socklist __rcu	*mc_list;
 	struct inet_cork_full	cork;
+	struct ip_tunnel_encap	*tou_encap;
 };
 
 #define IPCORK_OPT	1	/* ip-options has been held in ipcork.opt */
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 7594132..e7ec9eb 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -88,6 +88,7 @@ struct ip_tunnel_encap {
 	u16			flags;
 	__be16			sport;
 	__be16			dport;
+	struct rcu_head		rcu_head;
 };
 
 struct ip_tunnel_prl_entry {
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 1046f55..d0415ae 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -71,6 +71,16 @@ enum tunnel_encap_types {
 #define TUNNEL_ENCAP_FLAG_CSUM6		(1<<1)
 #define TUNNEL_ENCAP_FLAG_REMCSUM	(1<<2)
 
+/* Structure for Transport Over UDP (TOU) encapsulation. This is used in
+ * setsockopt of inet sockets.
+ */
+struct tou_encap {
+	u16			type; /* enum tunnel_encap_types */
+	u16			flags;
+	__be16			sport;
+	__be16			dport;
+};
+
 /* SIT-mode i_flags */
 #define	SIT_ISATAP	0x0001
 
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 24629b6..c4349e2 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -12,7 +12,8 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
+	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o \
+	     tou.o
 
 obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d39e9e4..9a49376 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -120,6 +120,7 @@
 #include <linux/mroute.h>
 #endif
 #include <net/l3mdev.h>
+#include <net/tou.h>
 
 
 /* The inetsw table contains everything that inet_create needs to
@@ -1830,6 +1831,9 @@ static int __init inet_init(void)
 	/* Add UDP-Lite (RFC 3828) */
 	udplite4_register();
 
+	/* Set TOU slab cache (Transport layer encapsulation over UDP) */
+	tou_init();
+
 	ping_init();
 
 	/*
diff --git a/net/ipv4/tou.c b/net/ipv4/tou.c
new file mode 100644
index 0000000..ef9999f
--- /dev/null
+++ b/net/ipv4/tou.c
@@ -0,0 +1,140 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <net/genetlink.h>
+#include <net/gue.h>
+#include <net/ip.h>
+#include <net/protocol.h>
+#include <net/udp.h>
+#include <net/udp_tunnel.h>
+#include <net/xfrm.h>
+#include <net/tou.h>
+#include <net/ip6_tunnel.h>
+#include <uapi/linux/fou.h>
+#include <uapi/linux/genetlink.h>
+
+static struct kmem_cache *tou_cachep __read_mostly;
+
+static void tou_encap_rcu_free(struct rcu_head *head)
+{
+	struct ip_tunnel_encap *e = container_of(head, struct ip_tunnel_encap,
+						 rcu_head);
+
+	kmem_cache_free(tou_cachep, e);
+}
+
+int tou_encap_setsockopt(struct sock *sk, char __user *optval, int optlen,
+			 bool is_ipv6)
+{
+	struct tou_encap te;
+	struct ip_tunnel_encap encap;
+	struct inet_sock *inet = inet_sk(sk);
+	struct ip_tunnel_encap *e = inet->tou_encap;
+	int hlen = 0, old_hlen = 0;
+
+	if (optlen < sizeof(te))
+		return -EINVAL;
+
+	if (copy_from_user(&te, optval, sizeof(te)))
+		return -EFAULT;
+
+	if (e) {
+		old_hlen = is_ipv6 ? ip6_encap_hlen(e) : ip_encap_hlen(e);
+		if (unlikely(old_hlen < 0))
+			return -EINVAL;
+	}
+
+	if (te.type == TUNNEL_ENCAP_NONE) {
+		if (e) {
+			if (unlikely(old_hlen < 0))
+				return -EINVAL;
+
+			rcu_assign_pointer(inet->tou_encap, NULL);
+			call_rcu(&e->rcu_head, tou_encap_rcu_free);
+
+			goto adjust_ext_hdr;
+		} else {
+			return 0;
+		}
+	}
+
+	memset(&encap, 0, sizeof(encap));
+	encap.type = te.type;
+	encap.sport = te.sport;
+	encap.dport = te.dport;
+	encap.flags = te.flags;
+
+	hlen = is_ipv6 ? ip6_encap_hlen(e) : ip_encap_hlen(e);
+	if (hlen < 0)
+		return hlen;
+
+	if (!e) {
+		e = kmem_cache_alloc(tou_cachep, GFP_KERNEL);
+		if (!e)
+			return -ENOMEM;
+		rcu_assign_pointer(inet->tou_encap, e);
+	}
+
+	*e = encap;
+
+adjust_ext_hdr:
+	if (inet->is_icsk) {
+		struct inet_connection_sock *icsk = inet_csk(sk);
+
+		/* For a connected socket add the overhead of encapsulation
+		 * (specifically the difference between the new encapsulation
+		 * and the old one it present) into the extrenal header length
+		 * and adjust the mss.
+		 */
+		icsk->icsk_ext_hdr_len += (hlen - old_hlen);
+		icsk->icsk_sync_mss(sk, icsk->icsk_pmtu_cookie);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(tou_encap_setsockopt);
+
+int tou_encap_getsockopt(struct sock *sk, char __user *optval,
+			 int len, int __user *optlen, bool is_ipv6)
+{
+	struct tou_encap te;
+	struct inet_sock *inet = inet_sk(sk);
+	struct ip_tunnel_encap *e = inet->tou_encap;
+
+	if (len < sizeof(te))
+		return -EINVAL;
+
+	len = sizeof(te);
+
+	memset(&te, 0, sizeof(te));
+
+	if (!e) {
+		te.type = TUNNEL_ENCAP_NONE;
+	} else {
+		te.type = e->type;
+		te.sport = e->sport;
+		te.dport = e->dport;
+		te.flags = e->flags;
+	}
+
+	if (put_user(len, optlen))
+		return -EFAULT;
+
+	if (copy_to_user(optval, &te, len))
+		return -EFAULT;
+
+	return 0;
+}
+EXPORT_SYMBOL(tou_encap_getsockopt);
+
+void __init tou_init(void)
+{
+	tou_cachep = kmem_cache_create("tou_cache",
+				       sizeof(struct ip_tunnel_encap), 0,
+				       SLAB_HWCACHE_ALIGN | SLAB_PANIC, NULL);
+}
-- 
2.8.0.rc2
