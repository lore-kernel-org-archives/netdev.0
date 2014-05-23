From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/5 v3] net: Eliminate no_check from protosw
Date: Fri, 23 May 2014 08:47:09 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405230840080.11945@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:59285 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205AbaEWPrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 11:47:11 -0400
Received: by mail-ie0-f201.google.com with SMTP id tp5so1044054ieb.2
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 08:47:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't seem like an protocols are setting anything other
than the default, and allowing to arbitrarily disable checksums
for a whole protocol seems dangerous. This can be done on a per
socket basis.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/protocol.h | 1 -
 net/dccp/ipv4.c        | 1 -
 net/ipv4/af_inet.c     | 7 -------
 net/ipv4/udplite.c     | 1 -
 net/ipv6/af_inet6.c    | 3 ---
 net/ipv6/ping.c        | 1 -
 net/ipv6/raw.c         | 1 -
 net/ipv6/tcp_ipv6.c    | 1 -
 net/ipv6/udp.c         | 1 -
 net/ipv6/udplite.c     | 1 -
 net/l2tp/l2tp_ip.c     | 1 -
 net/l2tp/l2tp_ip6.c    | 1 -
 net/sctp/ipv6.c        | 2 --
 net/sctp/protocol.c    | 2 --
 14 files changed, 24 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index a7e986b..d6fcc1f 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -86,7 +86,6 @@ struct inet_protosw {
 	struct proto	 *prot;
 	const struct proto_ops *ops;
   
-	char             no_check;   /* checksum on rcv/xmit/none? */
 	unsigned char	 flags;      /* See INET_PROTOSW_* below.  */
 };
 #define INET_PROTOSW_REUSE 0x01	     /* Are ports automatically reusable? */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 22b5d81..6ca645c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1024,7 +1024,6 @@ static struct inet_protosw dccp_v4_protosw = {
 	.protocol	= IPPROTO_DCCP,
 	.prot		= &dccp_v4_prot,
 	.ops		= &inet_dccp_ops,
-	.no_check	= 0,
 	.flags		= INET_PROTOSW_ICSK,
 };
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 279132b..0e9bb08 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -254,7 +254,6 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
 	struct inet_sock *inet;
 	struct proto *answer_prot;
 	unsigned char answer_flags;
-	char answer_no_check;
 	int try_loading_module = 0;
 	int err;
 
@@ -312,7 +311,6 @@ lookup_protocol:
 
 	sock->ops = answer->ops;
 	answer_prot = answer->prot;
-	answer_no_check = answer->no_check;
 	answer_flags = answer->flags;
 	rcu_read_unlock();
 
@@ -324,7 +322,6 @@ lookup_protocol:
 		goto out;
 
 	err = 0;
-	sk->sk_no_check = answer_no_check;
 	if (INET_PROTOSW_REUSE & answer_flags)
 		sk->sk_reuse = SK_CAN_REUSE;
 
@@ -1002,7 +999,6 @@ static struct inet_protosw inetsw_array[] =
 		.protocol =   IPPROTO_TCP,
 		.prot =       &tcp_prot,
 		.ops =        &inet_stream_ops,
-		.no_check =   0,
 		.flags =      INET_PROTOSW_PERMANENT |
 			      INET_PROTOSW_ICSK,
 	},
@@ -1012,7 +1008,6 @@ static struct inet_protosw inetsw_array[] =
 		.protocol =   IPPROTO_UDP,
 		.prot =       &udp_prot,
 		.ops =        &inet_dgram_ops,
-		.no_check =   UDP_CSUM_DEFAULT,
 		.flags =      INET_PROTOSW_PERMANENT,
        },
 
@@ -1021,7 +1016,6 @@ static struct inet_protosw inetsw_array[] =
 		.protocol =   IPPROTO_ICMP,
 		.prot =       &ping_prot,
 		.ops =        &inet_dgram_ops,
-		.no_check =   UDP_CSUM_DEFAULT,
 		.flags =      INET_PROTOSW_REUSE,
        },
 
@@ -1030,7 +1024,6 @@ static struct inet_protosw inetsw_array[] =
 	       .protocol =   IPPROTO_IP,	/* wild card */
 	       .prot =       &raw_prot,
 	       .ops =        &inet_sockraw_ops,
-	       .no_check =   UDP_CSUM_DEFAULT,
 	       .flags =      INET_PROTOSW_REUSE,
        }
 };
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 2c46acd..3b3efbd 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -70,7 +70,6 @@ static struct inet_protosw udplite4_protosw = {
 	.protocol	=  IPPROTO_UDPLITE,
 	.prot		=  &udplite_prot,
 	.ops		=  &inet_dgram_ops,
-	.no_check	=  0,		/* must checksum (RFC 3828) */
 	.flags		=  INET_PROTOSW_PERMANENT,
 };
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index dc47cc7..7cb4392 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -106,7 +106,6 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 	struct inet_protosw *answer;
 	struct proto *answer_prot;
 	unsigned char answer_flags;
-	char answer_no_check;
 	int try_loading_module = 0;
 	int err;
 
@@ -162,7 +161,6 @@ lookup_protocol:
 
 	sock->ops = answer->ops;
 	answer_prot = answer->prot;
-	answer_no_check = answer->no_check;
 	answer_flags = answer->flags;
 	rcu_read_unlock();
 
@@ -176,7 +174,6 @@ lookup_protocol:
 	sock_init_data(sock, sk);
 
 	err = 0;
-	sk->sk_no_check = answer_no_check;
 	if (INET_PROTOSW_REUSE & answer_flags)
 		sk->sk_reuse = SK_CAN_REUSE;
 
diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index a2a1d80..5b7a1ed 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -51,7 +51,6 @@ static struct inet_protosw pingv6_protosw = {
 	.protocol =  IPPROTO_ICMPV6,
 	.prot =      &pingv6_prot,
 	.ops =       &inet6_dgram_ops,
-	.no_check =  UDP_CSUM_DEFAULT,
 	.flags =     INET_PROTOSW_REUSE,
 };
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dddfb5f..b2dc60b 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1322,7 +1322,6 @@ static struct inet_protosw rawv6_protosw = {
 	.protocol	= IPPROTO_IP,	/* wild card */
 	.prot		= &rawv6_prot,
 	.ops		= &inet6_sockraw_ops,
-	.no_check	= UDP_CSUM_DEFAULT,
 	.flags		= INET_PROTOSW_REUSE,
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index f07b2ab..229239a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1992,7 +1992,6 @@ static struct inet_protosw tcpv6_protosw = {
 	.protocol	=	IPPROTO_TCP,
 	.prot		=	&tcpv6_prot,
 	.ops		=	&inet6_stream_ops,
-	.no_check	=	0,
 	.flags		=	INET_PROTOSW_PERMANENT |
 				INET_PROTOSW_ICSK,
 };
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 7edf096..c7ed47b 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1507,7 +1507,6 @@ static struct inet_protosw udpv6_protosw = {
 	.protocol =  IPPROTO_UDP,
 	.prot =      &udpv6_prot,
 	.ops =       &inet6_dgram_ops,
-	.no_check =  UDP_CSUM_DEFAULT,
 	.flags =     INET_PROTOSW_PERMANENT,
 };
 
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index dfcc4be..9cf097e 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -64,7 +64,6 @@ static struct inet_protosw udplite6_protosw = {
 	.protocol	= IPPROTO_UDPLITE,
 	.prot		= &udplitev6_prot,
 	.ops		= &inet6_dgram_ops,
-	.no_check	= 0,
 	.flags		= INET_PROTOSW_PERMANENT,
 };
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 3397fe6..369a982 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -606,7 +606,6 @@ static struct inet_protosw l2tp_ip_protosw = {
 	.protocol	= IPPROTO_L2TP,
 	.prot		= &l2tp_ip_prot,
 	.ops		= &l2tp_ip_ops,
-	.no_check	= 0,
 };
 
 static struct net_protocol l2tp_ip_protocol __read_mostly = {
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index e472d44..f3f98a1 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -755,7 +755,6 @@ static struct inet_protosw l2tp_ip6_protosw = {
 	.protocol	= IPPROTO_L2TP,
 	.prot		= &l2tp_ip6_prot,
 	.ops		= &l2tp_ip6_ops,
-	.no_check	= 0,
 };
 
 static struct inet6_protocol l2tp_ip6_protocol __read_mostly = {
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 4dc5d9e..1999592 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -943,7 +943,6 @@ static struct inet_protosw sctpv6_seqpacket_protosw = {
 	.protocol      = IPPROTO_SCTP,
 	.prot 	       = &sctpv6_prot,
 	.ops           = &inet6_seqpacket_ops,
-	.no_check      = 0,
 	.flags         = SCTP_PROTOSW_FLAG
 };
 static struct inet_protosw sctpv6_stream_protosw = {
@@ -951,7 +950,6 @@ static struct inet_protosw sctpv6_stream_protosw = {
 	.protocol      = IPPROTO_SCTP,
 	.prot 	       = &sctpv6_prot,
 	.ops           = &inet6_seqpacket_ops,
-	.no_check      = 0,
 	.flags         = SCTP_PROTOSW_FLAG,
 };
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index af5afca..6789d785 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1017,7 +1017,6 @@ static struct inet_protosw sctp_seqpacket_protosw = {
 	.protocol   = IPPROTO_SCTP,
 	.prot       = &sctp_prot,
 	.ops        = &inet_seqpacket_ops,
-	.no_check   = 0,
 	.flags      = SCTP_PROTOSW_FLAG
 };
 static struct inet_protosw sctp_stream_protosw = {
@@ -1025,7 +1024,6 @@ static struct inet_protosw sctp_stream_protosw = {
 	.protocol   = IPPROTO_SCTP,
 	.prot       = &sctp_prot,
 	.ops        = &inet_seqpacket_ops,
-	.no_check   = 0,
 	.flags      = SCTP_PROTOSW_FLAG
 };
 
-- 
1.9.1.423.g4596e3a
