From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 2/7] tou: Base infrastructure for Transport over UDP
Date: Mon, 23 May 2016 15:48:21 -0700
Message-ID: <1464043706-2843932-3-git-send-email-tom@herbertland.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:3469 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750973AbcEWWsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 18:48:41 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4NMl214024411
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:40 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 234ann83ch-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 23 May 2016 15:48:40 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 7de3c1e6213811e697a70002c9931860-31cbd6d0 for <netdev@vger.kernel.org>;	Mon,
 23 May 2016 15:48:39 -0700
In-Reply-To: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add tou.c that implements common setsockopt functionality. This includes
initialization and argument structure for the setsockopt.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/if_tunnel.h |  10 ++++
 net/ipv4/Makefile              |   3 +-
 net/ipv4/af_inet.c             |   4 ++
 net/ipv4/tou.c                 | 132 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 148 insertions(+), 1 deletion(-)
 create mode 100644 net/ipv4/tou.c

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index af4de90..c6b4afa 100644
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
index bfa1336..3b46dd6 100644
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
index 377424e..7a856f8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -120,6 +120,7 @@
 #include <linux/mroute.h>
 #endif
 #include <net/l3mdev.h>
+#include <net/tou.h>
 
 
 /* The inetsw table contains everything that inet_create needs to
@@ -1822,6 +1823,9 @@ static int __init inet_init(void)
 	/* Add UDP-Lite (RFC 3828) */
 	udplite4_register();
 
+	/* Set TOU slab cache (Transport layer encapsulation over UDP) */
+	tou_init();
+
 	ping_init();
 
 	/*
diff --git a/net/ipv4/tou.c b/net/ipv4/tou.c
new file mode 100644
index 0000000..601466a
--- /dev/null
+++ b/net/ipv4/tou.c
@@ -0,0 +1,132 @@
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
+			inet->tou_encap = NULL;
+			kmem_cache_free(tou_cachep, e);
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
+		inet->tou_encap = e;
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
