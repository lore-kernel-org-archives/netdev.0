From: Ivan Delalande <colona@arista.com>
Subject: [PATCH v2 2/2] tcp: md5: extend the tcp_md5sig struct to specify a key address prefix
Date: Fri,  9 Jun 2017 19:14:49 -0700
Message-ID: <20170610021449.16091-2-colona@arista.com>
References: <20170607005414.25361-1-colona@arista.com>
 <20170610021449.16091-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:41139 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751637AbdFJCOv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 22:14:51 -0400
In-Reply-To: <20170610021449.16091-1-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a flag field and address prefix length at the end of the tcp_md5sig
structure so users can configure an address prefix length along with a
key. Make sure shorter option values are still accepted in
tcp_v4_parse_md5_keys and tcp_v6_parse_md5_keys to maintain backward
compatibility.

Signed-off-by: Bob Gilligan <gilligan@arista.com>
Signed-off-by: Eric Mowat <mowat@arista.com>
Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/uapi/linux/tcp.h |  8 ++++++++
 net/ipv4/tcp_ipv4.c      | 15 +++++++++++----
 net/ipv6/tcp_ipv6.c      | 24 +++++++++++++++++-------
 3 files changed, 36 insertions(+), 11 deletions(-)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 38a2b07afdff..440a8d983e4b 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -233,6 +233,12 @@ enum {
 
 /* for TCP_MD5SIG socket option */
 #define TCP_MD5SIG_MAXKEYLEN	80
+/* original struct stopped at tcpm_key and must still be considered valid */
+#define TCP_MD5SIG_LEGACY_LEN	(offsetof(struct tcp_md5sig, tcpm_key) + \
+				 TCP_MD5SIG_MAXKEYLEN)
+
+/* tcp_md5sig flags */
+#define TCP_MD5SIG_FLAG_PREFIX		1	/* address prefix length */
 
 struct tcp_md5sig {
 	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
@@ -240,6 +246,8 @@ struct tcp_md5sig {
 	__u16	tcpm_keylen;				/* key length */
 	__u32	__tcpm_pad2;				/* zero */
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
+	__u8    tcpm_flags;				/* flags */
+	__u8    tcpm_prefixlen;				/* address prefix */
 };
 
 #endif /* _UAPI_LINUX_TCP_H */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 51ca3bd5a8a3..96a56224b913 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1069,25 +1069,32 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
+	u8 prefixlen = 32;
 
-	if (optlen < sizeof(cmd))
+	if (optlen < TCP_MD5SIG_LEGACY_LEN)
 		return -EINVAL;
 
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+	if (copy_from_user(&cmd, optval, min_t(size_t, sizeof(cmd), optlen)))
 		return -EFAULT;
 
 	if (sin->sin_family != AF_INET)
 		return -EINVAL;
 
+	if (optlen >= sizeof(cmd) && cmd.tcpm_flags & TCP_MD5SIG_FLAG_PREFIX) {
+		prefixlen = cmd.tcpm_prefixlen;
+		if (prefixlen > 32)
+			return -EINVAL;
+	}
+
 	if (!cmd.tcpm_keylen)
 		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
-				      AF_INET, 32);
+				      AF_INET, prefixlen);
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
 		return -EINVAL;
 
 	return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin->sin_addr.s_addr,
-			      AF_INET, 32, cmd.tcpm_key, cmd.tcpm_keylen,
+			      AF_INET, prefixlen, cmd.tcpm_key, cmd.tcpm_keylen,
 			      GFP_KERNEL);
 }
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5cf19dab60aa..aff909e19b3d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -519,22 +519,32 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
+	u8 prefixlen;
 
-	if (optlen < sizeof(cmd))
+	if (optlen < TCP_MD5SIG_LEGACY_LEN)
 		return -EINVAL;
 
-	if (copy_from_user(&cmd, optval, sizeof(cmd)))
+	if (copy_from_user(&cmd, optval, min_t(size_t, sizeof(cmd), optlen)))
 		return -EFAULT;
 
 	if (sin6->sin6_family != AF_INET6)
 		return -EINVAL;
 
+	if (optlen >= sizeof(cmd) && cmd.tcpm_flags & TCP_MD5SIG_FLAG_PREFIX) {
+		prefixlen = cmd.tcpm_prefixlen;
+		if (prefixlen > 128 || (ipv6_addr_v4mapped(&sin6->sin6_addr) &&
+					prefixlen > 32))
+			return -EINVAL;
+	} else {
+		prefixlen = ipv6_addr_v4mapped(&sin6->sin6_addr) ? 32 : 128;
+	}
+
 	if (!cmd.tcpm_keylen) {
 		if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 			return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin6->sin6_addr.s6_addr32[3],
-					      AF_INET, 32);
+					      AF_INET, prefixlen);
 		return tcp_md5_do_del(sk, (union tcp_md5_addr *)&sin6->sin6_addr,
-				      AF_INET6, 128);
+				      AF_INET6, prefixlen);
 	}
 
 	if (cmd.tcpm_keylen > TCP_MD5SIG_MAXKEYLEN)
@@ -542,12 +552,12 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 
 	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
 		return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin6->sin6_addr.s6_addr32[3],
-				      AF_INET, 32, cmd.tcpm_key,
+				      AF_INET, prefixlen, cmd.tcpm_key,
 				      cmd.tcpm_keylen, GFP_KERNEL);
 
 	return tcp_md5_do_add(sk, (union tcp_md5_addr *)&sin6->sin6_addr,
-			      AF_INET6, 128, cmd.tcpm_key, cmd.tcpm_keylen,
-			      GFP_KERNEL);
+			      AF_INET6, prefixlen, cmd.tcpm_key,
+			      cmd.tcpm_keylen, GFP_KERNEL);
 }
 
 static int tcp_v6_md5_hash_headers(struct tcp_md5sig_pool *hp,
-- 
2.13.1
