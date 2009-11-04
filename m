From: Eric Paris <eparis@redhat.com>
Subject: [PATCH 1/3] net: drop capability from protocol definitions
Date: Wed, 04 Nov 2009 11:32:11 -0500
Message-ID: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@redhat.com, acme@redhat.com, dwalsh@redhat.com,
	davem@davemloft.net, linux-security-module@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct can_proto had a capability field which wasn't ever used.  It is dropped
entirely.

struct inet_protosw had a capability field which can be more clearly expressed
in the code by just checking if sock->type = SOCK_RAW.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 include/linux/can/core.h |    2 --
 include/net/protocol.h   |    4 ----
 net/can/af_can.c         |    5 -----
 net/can/bcm.c            |    1 -
 net/can/raw.c            |    1 -
 net/dccp/ipv4.c          |    1 -
 net/dccp/ipv6.c          |    1 -
 net/ipv4/af_inet.c       |    5 +----
 net/ipv4/udplite.c       |    1 -
 net/ipv6/af_inet6.c      |    2 +-
 net/ipv6/raw.c           |    1 -
 net/ipv6/tcp_ipv6.c      |    1 -
 net/ipv6/udp.c           |    1 -
 net/ipv6/udplite.c       |    1 -
 net/sctp/ipv6.c          |    2 --
 net/sctp/protocol.c      |    2 --
 16 files changed, 2 insertions(+), 29 deletions(-)

diff --git a/include/linux/can/core.h b/include/linux/can/core.h
index 25085cb..6c507be 100644
--- a/include/linux/can/core.h
+++ b/include/linux/can/core.h
@@ -32,14 +32,12 @@
  * struct can_proto - CAN protocol structure
  * @type:       type argument in socket() syscall, e.g. SOCK_DGRAM.
  * @protocol:   protocol number in socket() syscall.
- * @capability: capability needed to open the socket, or -1 for no restriction.
  * @ops:        pointer to struct proto_ops for sock->ops.
  * @prot:       pointer to struct proto structure.
  */
 struct can_proto {
 	int              type;
 	int              protocol;
-	int              capability;
 	struct proto_ops *ops;
 	struct proto     *prot;
 };
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 60249e5..8321b2c 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -83,10 +83,6 @@ struct inet_protosw {
 	struct proto	 *prot;
 	const struct proto_ops *ops;
   
-	int              capability; /* Which (if any) capability do
-				      * we need to use this socket
-				      * interface?
-                                      */
 	char             no_check;   /* checksum on rcv/xmit/none? */
 	unsigned char	 flags;      /* See INET_PROTOSW_* below.  */
 };
diff --git a/net/can/af_can.c b/net/can/af_can.c
index 3f2eb27..9c0426d 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -160,11 +160,6 @@ static int can_create(struct net *net, struct socket *sock, int protocol)
 		goto errout;
 	}
 
-	if (cp->capability >= 0 && !capable(cp->capability)) {
-		err = -EPERM;
-		goto errout;
-	}
-
 	sock->ops = cp->ops;
 
 	sk = sk_alloc(net, PF_CAN, GFP_KERNEL, cp->prot);
diff --git a/net/can/bcm.c b/net/can/bcm.c
index 2f47039..67b5433 100644
--- a/net/can/bcm.c
+++ b/net/can/bcm.c
@@ -1576,7 +1576,6 @@ static struct proto bcm_proto __read_mostly = {
 static struct can_proto bcm_can_proto __read_mostly = {
 	.type       = SOCK_DGRAM,
 	.protocol   = CAN_BCM,
-	.capability = -1,
 	.ops        = &bcm_ops,
 	.prot       = &bcm_proto,
 };
diff --git a/net/can/raw.c b/net/can/raw.c
index 6e77db5..abca920 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -742,7 +742,6 @@ static struct proto raw_proto __read_mostly = {
 static struct can_proto raw_can_proto __read_mostly = {
 	.type       = SOCK_RAW,
 	.protocol   = CAN_RAW,
-	.capability = -1,
 	.ops        = &raw_ops,
 	.prot       = &raw_proto,
 };
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 00028d4..2423a08 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -991,7 +991,6 @@ static struct inet_protosw dccp_v4_protosw = {
 	.protocol	= IPPROTO_DCCP,
 	.prot		= &dccp_v4_prot,
 	.ops		= &inet_dccp_ops,
-	.capability	= -1,
 	.no_check	= 0,
 	.flags		= INET_PROTOSW_ICSK,
 };
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6d89f9f..50ea91a 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1185,7 +1185,6 @@ static struct inet_protosw dccp_v6_protosw = {
 	.protocol	= IPPROTO_DCCP,
 	.prot		= &dccp_v6_prot,
 	.ops		= &inet6_dccp_ops,
-	.capability	= -1,
 	.flags		= INET_PROTOSW_ICSK,
 };
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 538e84d..180ec4c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -325,7 +325,7 @@ lookup_protocol:
 	}
 
 	err = -EPERM;
-	if (answer->capability > 0 && !capable(answer->capability))
+	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
 		goto out_rcu_unlock;
 
 	err = -EAFNOSUPPORT;
@@ -947,7 +947,6 @@ static struct inet_protosw inetsw_array[] =
 		.protocol =   IPPROTO_TCP,
 		.prot =       &tcp_prot,
 		.ops =        &inet_stream_ops,
-		.capability = -1,
 		.no_check =   0,
 		.flags =      INET_PROTOSW_PERMANENT |
 			      INET_PROTOSW_ICSK,
@@ -958,7 +957,6 @@ static struct inet_protosw inetsw_array[] =
 		.protocol =   IPPROTO_UDP,
 		.prot =       &udp_prot,
 		.ops =        &inet_dgram_ops,
-		.capability = -1,
 		.no_check =   UDP_CSUM_DEFAULT,
 		.flags =      INET_PROTOSW_PERMANENT,
        },
@@ -969,7 +967,6 @@ static struct inet_protosw inetsw_array[] =
 	       .protocol =   IPPROTO_IP,	/* wild card */
 	       .prot =       &raw_prot,
 	       .ops =        &inet_sockraw_ops,
-	       .capability = CAP_NET_RAW,
 	       .no_check =   UDP_CSUM_DEFAULT,
 	       .flags =      INET_PROTOSW_REUSE,
        }
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 470c504..66f7951 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -64,7 +64,6 @@ static struct inet_protosw udplite4_protosw = {
 	.protocol	=  IPPROTO_UDPLITE,
 	.prot		=  &udplite_prot,
 	.ops		=  &inet_dgram_ops,
-	.capability	= -1,
 	.no_check	=  0,		/* must checksum (RFC 3828) */
 	.flags		=  INET_PROTOSW_PERMANENT,
 };
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 9105b25..1b38893 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -158,7 +158,7 @@ lookup_protocol:
 	}
 
 	err = -EPERM;
-	if (answer->capability > 0 && !capable(answer->capability))
+	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
 		goto out_rcu_unlock;
 
 	sock->ops = answer->ops;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index cb834ab..818ef21 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1336,7 +1336,6 @@ static struct inet_protosw rawv6_protosw = {
 	.protocol	= IPPROTO_IP,	/* wild card */
 	.prot		= &rawv6_prot,
 	.ops		= &inet6_sockraw_ops,
-	.capability	= CAP_NET_RAW,
 	.no_check	= UDP_CSUM_DEFAULT,
 	.flags		= INET_PROTOSW_REUSE,
 };
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 34925f0..696a22f 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2112,7 +2112,6 @@ static struct inet_protosw tcpv6_protosw = {
 	.protocol	=	IPPROTO_TCP,
 	.prot		=	&tcpv6_prot,
 	.ops		=	&inet6_stream_ops,
-	.capability	=	-1,
 	.no_check	=	0,
 	.flags		=	INET_PROTOSW_PERMANENT |
 				INET_PROTOSW_ICSK,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 5ae1d7c..5bc7cdb 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1284,7 +1284,6 @@ static struct inet_protosw udpv6_protosw = {
 	.protocol =  IPPROTO_UDP,
 	.prot =      &udpv6_prot,
 	.ops =       &inet6_dgram_ops,
-	.capability =-1,
 	.no_check =  UDP_CSUM_DEFAULT,
 	.flags =     INET_PROTOSW_PERMANENT,
 };
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index d737a27..6ea6938 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -62,7 +62,6 @@ static struct inet_protosw udplite6_protosw = {
 	.protocol	= IPPROTO_UDPLITE,
 	.prot		= &udplitev6_prot,
 	.ops		= &inet6_dgram_ops,
-	.capability	= -1,
 	.no_check	= 0,
 	.flags		= INET_PROTOSW_PERMANENT,
 };
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index bb280e6..bacd6a7 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -930,7 +930,6 @@ static struct inet_protosw sctpv6_seqpacket_protosw = {
 	.protocol      = IPPROTO_SCTP,
 	.prot 	       = &sctpv6_prot,
 	.ops           = &inet6_seqpacket_ops,
-	.capability    = -1,
 	.no_check      = 0,
 	.flags         = SCTP_PROTOSW_FLAG
 };
@@ -939,7 +938,6 @@ static struct inet_protosw sctpv6_stream_protosw = {
 	.protocol      = IPPROTO_SCTP,
 	.prot 	       = &sctpv6_prot,
 	.ops           = &inet6_seqpacket_ops,
-	.capability    = -1,
 	.no_check      = 0,
 	.flags         = SCTP_PROTOSW_FLAG,
 };
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d9f4cc2..3613d80 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -909,7 +909,6 @@ static struct inet_protosw sctp_seqpacket_protosw = {
 	.protocol   = IPPROTO_SCTP,
 	.prot       = &sctp_prot,
 	.ops        = &inet_seqpacket_ops,
-	.capability = -1,
 	.no_check   = 0,
 	.flags      = SCTP_PROTOSW_FLAG
 };
@@ -918,7 +917,6 @@ static struct inet_protosw sctp_stream_protosw = {
 	.protocol   = IPPROTO_SCTP,
 	.prot       = &sctp_prot,
 	.ops        = &inet_seqpacket_ops,
-	.capability = -1,
 	.no_check   = 0,
 	.flags      = SCTP_PROTOSW_FLAG
 };

