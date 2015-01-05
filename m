From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/4] ip: Add support for IP_CHECKSUM cmsg
Date: Mon,  5 Jan 2015 12:00:35 -0800
Message-ID: <1420488035-24866-5-git-send-email-therbert@google.com>
References: <1420488035-24866-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:50351 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684AbbAEUBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 15:01:13 -0500
Received: by mail-ie0-f178.google.com with SMTP id vy18so18516122iec.37
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 12:01:12 -0800 (PST)
In-Reply-To: <1420488035-24866-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New cmsg type is IP_CHECKSUM under SOL_IP. Enabled by standard
setsockopt.

The value returned is the unfolded 32 bit checksum of the packet
being received starting from the first byte returned in recvmsg
through the end of the packet (truncation is disregarded).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/inet_sock.h |  1 +
 include/uapi/linux/in.h |  1 +
 net/ipv4/ip_sockglue.c  | 41 ++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/udp.c          |  2 +-
 4 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 4091fab..2823fc0 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -203,6 +203,7 @@ struct inet_sock {
 #define IP_CMSG_RETOPTS		(1 << 4)
 #define IP_CMSG_PASSSEC		(1 << 5)
 #define IP_CMSG_ORIGDSTADDR	(1 << 6)
+#define IP_CMSG_CHECKSUM	(1 << 7)
 
 static inline struct inet_sock *inet_sk(const struct sock *sk)
 {
diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index c33a65e..589ced0 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -109,6 +109,7 @@ struct in_addr {
 
 #define IP_MINTTL       21
 #define IP_NODEFRAG     22
+#define IP_CHECKSUM	23
 
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 513d506..a317797 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -37,6 +37,7 @@
 #include <net/route.h>
 #include <net/xfrm.h>
 #include <net/compat.h>
+#include <net/checksum.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/transp_v6.h>
 #endif
@@ -96,6 +97,20 @@ static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
 	put_cmsg(msg, SOL_IP, IP_RETOPTS, opt->optlen, opt->__data);
 }
 
+static void ip_cmsg_recv_checksum(struct msghdr *msg, struct sk_buff *skb,
+				  int offset)
+{
+	__wsum csum = skb->csum;
+
+	if (skb->ip_summed != CHECKSUM_COMPLETE)
+		return;
+
+	if (offset != 0)
+		csum = csum_sub(csum, csum_partial(skb->data, offset, 0));
+
+	put_cmsg(msg, SOL_IP, IP_CHECKSUM, sizeof(__wsum), &csum);
+}
+
 static void ip_cmsg_recv_security(struct msghdr *msg, struct sk_buff *skb)
 {
 	char *secdata;
@@ -191,9 +206,16 @@ void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
 			return;
 	}
 
-	if (flags & IP_CMSG_ORIGDSTADDR)
+	if (flags & IP_CMSG_ORIGDSTADDR) {
 		ip_cmsg_recv_dstaddr(msg, skb);
 
+		flags &= ~IP_CMSG_ORIGDSTADDR;
+		if (!flags)
+			return;
+	}
+
+	if (flags & IP_CMSG_CHECKSUM)
+		ip_cmsg_recv_checksum(msg, skb, offset);
 }
 EXPORT_SYMBOL(ip_cmsg_recv_offset);
 
@@ -533,6 +555,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_MULTICAST_ALL:
 	case IP_MULTICAST_LOOP:
 	case IP_RECVORIGDSTADDR:
+	case IP_CHECKSUM:
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
 				return -EFAULT;
@@ -630,6 +653,19 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		else
 			inet->cmsg_flags &= ~IP_CMSG_ORIGDSTADDR;
 		break;
+	case IP_CHECKSUM:
+		if (val) {
+			if (!(inet->cmsg_flags & IP_CMSG_CHECKSUM)) {
+				inet_inc_convert_csum(sk);
+				inet->cmsg_flags |= IP_CMSG_CHECKSUM;
+			}
+		} else {
+			if (inet->cmsg_flags & IP_CMSG_CHECKSUM) {
+				inet_dec_convert_csum(sk);
+				inet->cmsg_flags &= ~IP_CMSG_CHECKSUM;
+			}
+		}
+		break;
 	case IP_TOS:	/* This sets both TOS and Precedence */
 		if (sk->sk_type == SOCK_STREAM) {
 			val &= ~INET_ECN_MASK;
@@ -1233,6 +1269,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_RECVORIGDSTADDR:
 		val = (inet->cmsg_flags & IP_CMSG_ORIGDSTADDR) != 0;
 		break;
+	case IP_CHECKSUM:
+		val = (inet->cmsg_flags & IP_CMSG_CHECKSUM) != 0;
+		break;
 	case IP_TOS:
 		val = inet->tos;
 		break;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 53358d8..97ef1f8b 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1329,7 +1329,7 @@ try_again:
 		*addr_len = sizeof(*sin);
 	}
 	if (inet->cmsg_flags)
-		ip_cmsg_recv(msg, skb);
+		ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr));
 
 	err = copied;
 	if (flags & MSG_TRUNC)
-- 
2.2.0.rc0.207.ga3a616c
