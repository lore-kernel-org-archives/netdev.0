From: Martin Lucina <martin@lucina.net>
Subject: [PATCH] Implement IP_EVIL socket option (RFC 3514)
Date: Sun,  1 Apr 2012 14:53:11 +0200
Message-ID: <1333284791-5363-1-git-send-email-martin@lucina.net>
Cc: Martin Lucina <martin@lucina.net>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements the IP_EVIL socket option, allowing user-space
applications to set the Security Flag in the IPv4 Header, aka "evil" bit,
as defined in RFC 3514.

Signed-off-by: Martin Lucina <martin@lucina.net>
---
 include/linux/in.h      |    1 +
 include/net/inet_sock.h |    1 +
 net/ipv4/af_inet.c      |    1 +
 net/ipv4/ip_output.c    |    2 ++
 net/ipv4/ip_sockglue.c  |    9 ++++++++-
 5 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index e0337f1..6814c0f 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -86,6 +86,7 @@ struct in_addr {
 
 #define IP_MINTTL       21
 #define IP_NODEFRAG     22
+#define IP_EVIL         23
 
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index ae17e13..37aaf9b 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -168,6 +168,7 @@ struct inet_sock {
 				transparent:1,
 				mc_all:1,
 				nodefrag:1;
+	__u8			evil;
 	__u8			rcv_tos;
 	int			uc_index;
 	int			mc_index;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 10e3751..b165dfb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -356,6 +356,7 @@ lookup_protocol:
 	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;
 
 	inet->nodefrag = 0;
+	inet->evil = 0; /* Don't be evil */
 
 	if (SOCK_RAW == sock->type) {
 		inet->inet_num = protocol;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4910176..c1b4b15 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -157,6 +157,8 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 		iph->frag_off = htons(IP_DF);
 	else
 		iph->frag_off = 0;
+	if (inet->evil)
+		iph->frag_off |= 1<<15;
 	iph->ttl      = ip_select_ttl(inet, &rt->dst);
 	iph->daddr    = (opt && opt->opt.srr ? opt->opt.faddr : daddr);
 	iph->saddr    = saddr;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 2fd0fba..f26d45c 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -463,7 +463,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			     (1<<IP_MTU_DISCOVER) | (1<<IP_RECVERR) |
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
 			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
-			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG))) ||
+			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG) |
+			     (1<<IP_EVIL))) ||
 	    optname == IP_UNICAST_IF ||
 	    optname == IP_MULTICAST_TTL ||
 	    optname == IP_MULTICAST_ALL ||
@@ -598,6 +599,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 		inet->nodefrag = val ? 1 : 0;
 		break;
+	case IP_EVIL:
+		inet->evil = val ? 1 : 0;
+		break;
 	case IP_MTU_DISCOVER:
 		if (val < IP_PMTUDISC_DONT || val > IP_PMTUDISC_PROBE)
 			goto e_inval;
@@ -1176,6 +1180,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_NODEFRAG:
 		val = inet->nodefrag;
 		break;
+	case IP_EVIL:
+		val = inet->evil;
+		break;
 	case IP_MTU_DISCOVER:
 		val = inet->pmtudisc;
 		break;
-- 
1.7.9.1
