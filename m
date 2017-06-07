From: Ivan Delalande <colona@arista.com>
Subject: [PATCH 2/2] tcp: md5: add fields to the tcp_md5sig struct to set a key address prefix
Date: Tue,  6 Jun 2017 17:54:14 -0700
Message-ID: <20170607005414.25361-2-colona@arista.com>
References: <20170607005414.25361-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:44055 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751436AbdFGBB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 21:01:57 -0400
In-Reply-To: <20170607005414.25361-1-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace padding in the socket option structure tcp_md5sig with a new
flag field and address prefix length so it can be specified when
configuring a new key with the TCP_MD5SIG socket option.

Signed-off-by: Bob Gilligan <gilligan@arista.com>
Signed-off-by: Eric Mowat <mowat@arista.com>
Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/uapi/linux/tcp.h |  6 +++++-
 net/ipv4/tcp_ipv4.c      | 13 +++++++++++--
 net/ipv6/tcp_ipv6.c      | 20 +++++++++++++++-----
 3 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 38a2b07afdff..52ac30aa0652 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -234,9 +234,13 @@ enum {
 /* for TCP_MD5SIG socket option */
 #define TCP_MD5SIG_MAXKEYLEN	80
 
+/* tcp_md5sig flags */
+#define TCP_MD5SIG_FLAG_PREFIX		1	/* address prefix length */
+
 struct tcp_md5sig {
 	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
-	__u16	__tcpm_pad1;				/* zero */
+	__u8	tcpm_flags;				/* flags */
+	__u8	tcpm_prefixlen;				/* address prefix */
 	__u16	tcpm_keylen;				/* key length */
 	__u32	__tcpm_pad2;				/* zero */
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 51ca3bd5a8a3..2b1bb67b3388 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1069,6 +1069,7 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
+	u8 prefixlen;
 
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -1079,15 +1080,23 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (sin->sin_family != AF_INET)
 		return -EINVAL;
 
+	if (cmd.tcpm_flags & TCP_MD5SIG_FLAG_PREFIX) {
+		prefixlen = cmd.tcpm_prefixlen;
+		if (prefixlen > 32)
+			return -EINVAL;
+	} else {
+		prefixlen = 32;
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
index 5cf19dab60aa..f293fc69e88b 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -519,6 +519,7 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
+	u8 prefixlen;
 
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -529,12 +530,21 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (sin6->sin6_family != AF_INET6)
 		return -EINVAL;
 
+	if (cmd.tcpm_flags & TCP_MD5SIG_FLAG_PREFIX) {
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
2.13.0
