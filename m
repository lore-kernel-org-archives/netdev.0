From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH] [TPROXY] implemented IP_RECVORIGDSTADDR socket option
Date: Thu, 13 Nov 2008 11:37:04 +0100
Message-ID: <1226572624.7164.11.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>, tproxy@lists.balabit.hu,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	KOVACS Krisztian <hidden@sch.bme.hu>,
	Andrey Luzgin <andrey@icomsw.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:45236 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751797AbYKMKj1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2008 05:39:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In case UDP traffic is redirected to a local UDP socket,
the originally addressed destination address/port
cannot be recovered with the in-kernel tproxy.

This patch adds an IP_RECVORIGDSTADDR sockopt that enables
a IP_ORIGDSTADDR ancillary message in recvmsg(). This
ancillary message contains the original destination address/port
of the packet being received.

Please apply.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/linux/in.h     |    4 ++++
 net/ipv4/ip_sockglue.c |   40 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 43 insertions(+), 1 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index db458be..d60122a 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -80,6 +80,10 @@ struct in_addr {
 /* BSD compatibility */
 #define IP_RECVRETOPTS	IP_RETOPTS
 
+/* TProxy original addresses */
+#define IP_ORIGDSTADDR       20
+#define IP_RECVORIGDSTADDR   IP_ORIGDSTADDR
+
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
 #define IP_PMTUDISC_WANT		1	/* Use per route hints	*/
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 465abf0..1e70488 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -48,6 +48,7 @@
 #define IP_CMSG_RECVOPTS	8
 #define IP_CMSG_RETOPTS		16
 #define IP_CMSG_PASSSEC		32
+#define IP_CMSG_ORIGDSTADDR     64
 
 /*
  *	SOL_IP control messages.
@@ -126,6 +127,27 @@ static void ip_cmsg_recv_security(struct msghdr *msg, struct sk_buff *skb)
 	security_release_secctx(secdata, seclen);
 }
 
+void ip_cmsg_recv_dstaddr(struct msghdr *msg, struct sk_buff *skb)
+{
+	struct sockaddr_in sin;
+	struct iphdr *iph = ip_hdr(skb);
+	u16 *ports = (u16 *) skb_transport_header(skb);
+
+	if (skb_transport_offset(skb) + 4 > skb->len)
+		return;
+
+	/* All current transport protocols have the port numbers in the
+	 * first four bytes of the transport header and this function is
+	 * written with this assumption in mind.
+	 */
+
+	sin.sin_family = AF_INET;
+	sin.sin_addr.s_addr = iph->daddr;
+	sin.sin_port = ports[1];
+	memset(sin.sin_zero, 0, sizeof(sin.sin_zero));
+
+	put_cmsg(msg, SOL_IP, IP_ORIGDSTADDR, sizeof(sin), &sin);
+}
 
 void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 {
@@ -160,6 +182,12 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 
 	if (flags & 1)
 		ip_cmsg_recv_security(msg, skb);
+
+	if ((flags>>=1) == 0)
+		return;
+	if (flags & 1)
+		ip_cmsg_recv_dstaddr(msg, skb);
+
 }
 
 int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
@@ -421,7 +449,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
 			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT))) ||
 	    optname == IP_MULTICAST_TTL ||
-	    optname == IP_MULTICAST_LOOP) {
+	    optname == IP_MULTICAST_LOOP ||
+	    optname == IP_RECVORIGDSTADDR) {
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
 				return -EFAULT;
@@ -509,6 +538,12 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		else
 			inet->cmsg_flags &= ~IP_CMSG_PASSSEC;
 		break;
+	case IP_RECVORIGDSTADDR:
+		if (val)
+			inet->cmsg_flags |= IP_CMSG_ORIGDSTADDR;
+		else
+			inet->cmsg_flags &= ~IP_CMSG_ORIGDSTADDR;
+		break;
 	case IP_TOS:	/* This sets both TOS and Precedence */
 		if (sk->sk_type == SOCK_STREAM) {
 			val &= ~3;
@@ -1022,6 +1057,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_PASSSEC:
 		val = (inet->cmsg_flags & IP_CMSG_PASSSEC) != 0;
 		break;
+	case IP_RECVORIGDSTADDR:
+		val = (inet->cmsg_flags & IP_CMSG_ORIGDSTADDR) != 0;
+		break;
 	case IP_TOS:
 		val = inet->tos;
 		break;
-- 
1.5.4.3


-- 
Bazsi


