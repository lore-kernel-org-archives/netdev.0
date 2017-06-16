From: Ivan Delalande <colona@arista.com>
Subject: [PATCH v3 2/2] tcp: md5: add TCP_MD5SIG_EXT socket option to set a key address prefix
Date: Thu, 15 Jun 2017 18:07:07 -0700
Message-ID: <20170616010707.27666-2-colona@arista.com>
References: <20170610021449.16091-1-colona@arista.com>
 <20170616010707.27666-1-colona@arista.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170616010707.27666-1-colona@arista.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace first padding in the tcp_md5sig structure with a new flag field
and address prefix length so it can be specified when configuring a new
key for TCP MD5 signature. The tcpm_flags field will only be used if the
socket option is TCP_MD5SIG_EXT to avoid breaking existing programs, and
tcpm_prefixlen only when the TCP_MD5SIG_FLAG_PREFIX flag is set.

Signed-off-by: Bob Gilligan <gilligan@arista.com>
Signed-off-by: Eric Mowat <mowat@arista.com>
Signed-off-by: Ivan Delalande <colona@arista.com>
---
 include/net/tcp.h        |  1 +
 include/uapi/linux/tcp.h |  9 +++++++--
 net/ipv4/tcp.c           |  3 ++-
 net/ipv4/tcp_ipv4.c      | 16 ++++++++++++----
 net/ipv6/tcp_ipv6.c      | 25 ++++++++++++++++++-------
 5 files changed, 40 insertions(+), 14 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2b68023ab095..575f95cb8275 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1802,6 +1802,7 @@ struct tcp_sock_af_ops {
 					 const struct sock *sk,
 					 const struct sk_buff *skb);
 	int		(*md5_parse)(struct sock *sk,
+				     int optname,
 				     char __user *optval,
 				     int optlen);
 #endif
diff --git a/include/uapi/linux/tcp.h b/include/uapi/linux/tcp.h
index 38a2b07afdff..9870b7f08f4f 100644
--- a/include/uapi/linux/tcp.h
+++ b/include/uapi/linux/tcp.h
@@ -117,6 +117,7 @@ enum {
 #define TCP_SAVED_SYN		28	/* Get SYN headers recorded for connection */
 #define TCP_REPAIR_WINDOW	29	/* Get/set window parameters */
 #define TCP_FASTOPEN_CONNECT	30	/* Attempt FastOpen with connect */
+#define TCP_MD5SIG_EXT		31	/* TCP MD5 Signature with extensions */
 
 struct tcp_repair_opt {
 	__u32	opt_code;
@@ -234,11 +235,15 @@ enum {
 /* for TCP_MD5SIG socket option */
 #define TCP_MD5SIG_MAXKEYLEN	80
 
+/* tcp_md5sig extension flags for TCP_MD5SIG_EXT */
+#define TCP_MD5SIG_FLAG_PREFIX		1	/* address prefix length */
+
 struct tcp_md5sig {
 	struct __kernel_sockaddr_storage tcpm_addr;	/* address associated */
-	__u16	__tcpm_pad1;				/* zero */
+	__u8	tcpm_flags;				/* extension flags */
+	__u8	tcpm_prefixlen;				/* address prefix */
 	__u16	tcpm_keylen;				/* key length */
-	__u32	__tcpm_pad2;				/* zero */
+	__u32	__tcpm_pad;				/* zero */
 	__u8	tcpm_key[TCP_MD5SIG_MAXKEYLEN];		/* key (binary) */
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1e4c76d2b827..2a68221d2e55 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2666,8 +2666,9 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 
 #ifdef CONFIG_TCP_MD5SIG
 	case TCP_MD5SIG:
+	case TCP_MD5SIG_EXT:
 		/* Read the IP->Key mappings from userspace */
-		err = tp->af_specific->md5_parse(sk, optval, optlen);
+		err = tp->af_specific->md5_parse(sk, optname, optval, optlen);
 		break;
 #endif
 	case TCP_USER_TIMEOUT:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 51ca3bd5a8a3..81d6c16aecdc 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1064,11 +1064,12 @@ static void tcp_clear_md5_list(struct sock *sk)
 	}
 }
 
-static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
-				 int optlen)
+static int tcp_v4_parse_md5_keys(struct sock *sk, int optname,
+				 char __user *optval, int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in *sin = (struct sockaddr_in *)&cmd.tcpm_addr;
+	u8 prefixlen = 32;
 
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -1079,15 +1080,22 @@ static int tcp_v4_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (sin->sin_family != AF_INET)
 		return -EINVAL;
 
+	if (optname == TCP_MD5SIG_EXT &&
+	    cmd.tcpm_flags & TCP_MD5SIG_FLAG_PREFIX) {
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
index 5cf19dab60aa..ae36442786ec 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -514,11 +514,12 @@ static struct tcp_md5sig_key *tcp_v6_md5_lookup(const struct sock *sk,
 	return tcp_v6_md5_do_lookup(sk, &addr_sk->sk_v6_daddr);
 }
 
-static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
-				 int optlen)
+static int tcp_v6_parse_md5_keys(struct sock *sk, int optname,
+				 char __user *optval, int optlen)
 {
 	struct tcp_md5sig cmd;
 	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)&cmd.tcpm_addr;
+	u8 prefixlen;
 
 	if (optlen < sizeof(cmd))
 		return -EINVAL;
@@ -529,12 +530,22 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 	if (sin6->sin6_family != AF_INET6)
 		return -EINVAL;
 
+	if (optname == TCP_MD5SIG_EXT &&
+	    cmd.tcpm_flags & TCP_MD5SIG_FLAG_PREFIX) {
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
@@ -542,12 +553,12 @@ static int tcp_v6_parse_md5_keys(struct sock *sk, char __user *optval,
 
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
