From: Ivan Delalande <colona@arista.com>
Subject: [PATCH net-next v2 2/2] tcp_diag: report TCP MD5 signing keys and addresses
Date: Fri, 25 Aug 2017 18:53:46 -0700
Message-ID: <20170826015346.24247-2-colona@arista.com>
References: <20170826015346.24247-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:18361 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751589AbdHZCBn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 22:01:43 -0400
In-Reply-To: <20170826015346.24247-1-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report TCP MD5 (RFC2385) signing keys, addresses and address prefixes to
processes with CAP_NET_ADMIN requesting INET_DIAG_INFO. Currently it is
not possible to retrieve these from the kernel once they have been
configured on sockets.

Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/uapi/linux/inet_diag.h |   1 +
 net/ipv4/tcp_diag.c            | 112 ++++++++++++++++++++++++++++++++++++++---
 2 files changed, 107 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/inet_diag.h b/include/uapi/linux/inet_diag.h
index 678496897a68..f52ff62bfabe 100644
--- a/include/uapi/linux/inet_diag.h
+++ b/include/uapi/linux/inet_diag.h
@@ -143,6 +143,7 @@ enum {
 	INET_DIAG_MARK,
 	INET_DIAG_BBRINFO,
 	INET_DIAG_CLASS_ID,
+	INET_DIAG_MD5SIG,
 	__INET_DIAG_MAX,
 };
 
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index a748c74aa8b7..99c54b765921 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -16,6 +16,7 @@
 
 #include <linux/tcp.h>
 
+#include <net/netlink.h>
 #include <net/tcp.h>
 
 static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
@@ -36,6 +37,103 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		tcp_get_info(sk, info);
 }
 
+#ifdef CONFIG_TCP_MD5SIG
+static void inet_diag_md5sig_fill(struct tcp_md5sig *info,
+				  const struct tcp_md5sig_key *key)
+{
+	#if IS_ENABLED(CONFIG_IPV6)
+	if (key->family == AF_INET6) {
+		struct sockaddr_in6 *sin6 =
+			(struct sockaddr_in6 *)&info->tcpm_addr;
+
+		memcpy(&sin6->sin6_addr, &key->addr.a6,
+		       sizeof(struct in6_addr));
+	} else
+	#endif
+	{
+		struct sockaddr_in *sin =
+			(struct sockaddr_in *)&info->tcpm_addr;
+
+		memcpy(&sin->sin_addr, &key->addr.a4, sizeof(struct in_addr));
+	}
+
+	info->tcpm_addr.ss_family = key->family;
+	info->tcpm_prefixlen = key->prefixlen;
+	info->tcpm_keylen = key->keylen;
+	memcpy(info->tcpm_key, key->key, key->keylen);
+}
+
+static int inet_diag_put_md5sig(struct sk_buff *skb,
+				const struct tcp_md5sig_info *md5sig)
+{
+	const struct tcp_md5sig_key *key;
+	struct nlattr *attr;
+	struct tcp_md5sig *info;
+	int md5sig_count = 0;
+
+	hlist_for_each_entry_rcu(key, &md5sig->head, node)
+		md5sig_count++;
+
+	attr = nla_reserve(skb, INET_DIAG_MD5SIG,
+			   md5sig_count * sizeof(struct tcp_md5sig));
+	if (!attr)
+		return -EMSGSIZE;
+
+	info = nla_data(attr);
+	hlist_for_each_entry_rcu(key, &md5sig->head, node) {
+		inet_diag_md5sig_fill(info, key);
+		info++;
+	}
+
+	return 0;
+}
+#endif
+
+static int tcp_diag_get_aux(struct sock *sk, bool net_admin,
+			    struct sk_buff *skb)
+{
+#ifdef CONFIG_TCP_MD5SIG
+	if (net_admin) {
+		struct tcp_md5sig_info *md5sig;
+		int err = 0;
+
+		lock_sock(sk);
+		rcu_read_lock();
+		md5sig = rcu_dereference(tcp_sk(sk)->md5sig_info);
+		if (md5sig)
+			err = inet_diag_put_md5sig(skb, md5sig);
+		rcu_read_unlock();
+		release_sock(sk);
+		if (err < 0)
+			return err;
+	}
+#endif
+
+	return 0;
+}
+
+static size_t tcp_diag_get_aux_size(struct sock *sk, bool net_admin)
+{
+	size_t size = 0;
+
+#ifdef CONFIG_TCP_MD5SIG
+	if (sk_fullsock(sk)) {
+		const struct tcp_md5sig_info *md5sig;
+		const struct tcp_md5sig_key *key;
+
+		rcu_read_lock();
+		md5sig = rcu_dereference(tcp_sk(sk)->md5sig_info);
+		if (md5sig) {
+			hlist_for_each_entry_rcu(key, &md5sig->head, node)
+				size += sizeof(struct tcp_md5sig);
+		}
+		rcu_read_unlock();
+	}
+#endif
+
+	return size;
+}
+
 static void tcp_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 			  const struct inet_diag_req_v2 *r, struct nlattr *bc)
 {
@@ -68,13 +166,15 @@ static int tcp_diag_destroy(struct sk_buff *in_skb,
 #endif
 
 static const struct inet_diag_handler tcp_diag_handler = {
-	.dump		 = tcp_diag_dump,
-	.dump_one	 = tcp_diag_dump_one,
-	.idiag_get_info	 = tcp_diag_get_info,
-	.idiag_type	 = IPPROTO_TCP,
-	.idiag_info_size = sizeof(struct tcp_info),
+	.dump			= tcp_diag_dump,
+	.dump_one		= tcp_diag_dump_one,
+	.idiag_get_info		= tcp_diag_get_info,
+	.idiag_get_aux		= tcp_diag_get_aux,
+	.idiag_get_aux_size	= tcp_diag_get_aux_size,
+	.idiag_type		= IPPROTO_TCP,
+	.idiag_info_size	= sizeof(struct tcp_info),
 #ifdef CONFIG_INET_DIAG_DESTROY
-	.destroy	 = tcp_diag_destroy,
+	.destroy		= tcp_diag_destroy,
 #endif
 };
 
-- 
2.14.1
