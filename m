From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: fix IP_CHECKSUM handling
Date: Sun, 23 Oct 2016 18:03:06 -0700
Message-ID: <1477270986.7065.102.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Sam Kumar <samanthakumar@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33272 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756728AbcJXBDI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2016 21:03:08 -0400
Received: by mail-pf0-f195.google.com with SMTP id i85so14851644pfa.0
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 18:03:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

First bug was added in commit ad6f939ab193 ("ip: Add offset parameter to
ip_cmsg_recv") : Tom missed that ipv4 udp messages could be received on
AF_INET6 socket. ip_cmsg_recv(msg, skb) should have been replaced by
ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr));

Then commit e6afc8ace6dd ("udp: remove headers from UDP packets before
queueing") forgot to adjust the offsets now UDP headers are pulled
before skb are put in receive queue.

Fixes: ad6f939ab193 ("ip: Add offset parameter to ip_cmsg_recv")
Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Sam Kumar <samanthakumar@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
Tom, I would appreciate your feedback on this patch, I presume
you have tests to verify IP_CHECKSUM feature ? Thanks !

 include/net/ip.h       |    4 ++--
 net/ipv4/ip_sockglue.c |   11 ++++++-----
 net/ipv4/udp.c         |    2 +-
 net/ipv6/udp.c         |    3 ++-
 4 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index c9d07988911e..5413883ac47f 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -578,7 +578,7 @@ int ip_options_rcv_srr(struct sk_buff *skb);
  */
 
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
-void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb, int offset);
+void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb, int tlen, int offset);
 int ip_cmsg_send(struct sock *sk, struct msghdr *msg,
 		 struct ipcm_cookie *ipc, bool allow_ipv6);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
@@ -600,7 +600,7 @@ void ip_local_error(struct sock *sk, int err, __be32 daddr, __be16 dport,
 
 static inline void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 {
-	ip_cmsg_recv_offset(msg, skb, 0);
+	ip_cmsg_recv_offset(msg, skb, 0, 0);
 }
 
 bool icmp_global_allow(void);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index af4919792b6a..b8a2d63d1fb8 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -98,7 +98,7 @@ static void ip_cmsg_recv_retopts(struct msghdr *msg, struct sk_buff *skb)
 }
 
 static void ip_cmsg_recv_checksum(struct msghdr *msg, struct sk_buff *skb,
-				  int offset)
+				  int tlen, int offset)
 {
 	__wsum csum = skb->csum;
 
@@ -106,8 +106,9 @@ static void ip_cmsg_recv_checksum(struct msghdr *msg, struct sk_buff *skb,
 		return;
 
 	if (offset != 0)
-		csum = csum_sub(csum, csum_partial(skb_transport_header(skb),
-						   offset, 0));
+		csum = csum_sub(csum,
+				csum_partial(skb_transport_header(skb) + tlen,
+					     offset, 0));
 
 	put_cmsg(msg, SOL_IP, IP_CHECKSUM, sizeof(__wsum), &csum);
 }
@@ -153,7 +154,7 @@ static void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
 }
 
 void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
-			 int offset)
+			 int tlen, int offset)
 {
 	struct inet_sock *inet = inet_sk(skb->sk);
 	unsigned int flags = inet->cmsg_flags;
@@ -216,7 +217,7 @@ void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
 	}
 
 	if (flags & IP_CMSG_CHECKSUM)
-		ip_cmsg_recv_checksum(msg, skb, offset);
+		ip_cmsg_recv_checksum(msg, skb, tlen, offset);
 }
 EXPORT_SYMBOL(ip_cmsg_recv_offset);
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 311613e413cb..d123d68f4d1d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1322,7 +1322,7 @@ int udp_recvmsg(struct sock *sk, struct msghdr *msg, size_t len, int noblock,
 		*addr_len = sizeof(*sin);
 	}
 	if (inet->cmsg_flags)
-		ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr) + off);
+		ip_cmsg_recv_offset(msg, skb, sizeof(struct udphdr), off);
 
 	err = copied;
 	if (flags & MSG_TRUNC)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 9aa7c1c7a9ce..b2ef061e6836 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -427,7 +427,8 @@ int udpv6_recvmsg(struct sock *sk, struct msghdr *msg, size_t len,
 
 	if (is_udp4) {
 		if (inet->cmsg_flags)
-			ip_cmsg_recv(msg, skb);
+			ip_cmsg_recv_offset(msg, skb,
+					    sizeof(struct udphdr), off);
 	} else {
 		if (np->rxopt.all)
 			ip6_datagram_recv_specific_ctl(sk, msg, skb);
