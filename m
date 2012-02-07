From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: [PATCH v6 1/2] Implement IP_UNICAST_IF socket option.
Date: Tue,  7 Feb 2012 14:44:32 -0700
Message-ID: <1328651073-976-1-git-send-email-ehoover@mines.edu>
Cc: "Erich E. Hoover" <ehoover@mines.edu>
To: Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:46376 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754593Ab2BGVoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Feb 2012 16:44:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The IP_UNICAST_IF feature is needed by the Wine project.  This patch implements the feature by setting the outgoing interface in a similar fashion to that of IP_MULTICAST_IF.  A separate option is needed to handle this feature since the existing options do not provide all of the characteristics required by IP_UNICAST_IF, a summary is provided below.

SO_BINDTODEVICE:
* SO_BINDTODEVICE requires administrative privileges, IP_UNICAST_IF does not.  From reading some old mailing list articles my understanding is that SO_BINDTODEVICE requires administrative privileges because it can override the administrator's routing settings.
* The SO_BINDTODEVICE option restricts both outbound and inbound traffic, IP_UNICAST_IF only impacts outbound traffic.

IP_PKTINFO:
* Since IP_PKTINFO and IP_UNICAST_IF are independent options, implementing IP_UNICAST_IF with IP_PKTINFO will likely break some applications.
* Implementing IP_UNICAST_IF on top of IP_PKTINFO significantly complicates the Wine codebase and reduces the socket performance (doing this requires a lot of extra communication between the "server" and "user" layers).

bind():
* bind() does not work on broadcast packets, IP_UNICAST_IF is specifically intended to work with broadcast packets.
* Like SO_BINDTODEVICE, bind() restricts both outbound and inbound traffic.

Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
---
 include/linux/in.h      |    1 +
 include/net/inet_sock.h |    2 ++
 net/ipv4/ip_sockglue.c  |   33 +++++++++++++++++++++++++++++++++
 net/ipv4/ping.c         |    3 ++-
 net/ipv4/raw.c          |    3 ++-
 net/ipv4/udp.c          |    3 ++-
 6 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 01129c0..e0337f1 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -111,6 +111,7 @@ struct in_addr {
 #define MCAST_LEAVE_SOURCE_GROUP	47
 #define MCAST_MSFILTER			48
 #define IP_MULTICAST_ALL		49
+#define IP_UNICAST_IF			50
 
 #define MCAST_EXCLUDE	0
 #define MCAST_INCLUDE	1
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e3e4051..022f772 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -132,6 +132,7 @@ struct rtable;
  * @tos - TOS
  * @mc_ttl - Multicasting TTL
  * @is_icsk - is this an inet_connection_sock?
+ * @uc_index - Unicast outgoing device index
  * @mc_index - Multicast device index
  * @mc_list - Group array
  * @cork - info to build ip hdr on each ip frag while socket is corked
@@ -167,6 +168,7 @@ struct inet_sock {
 				transparent:1,
 				mc_all:1,
 				nodefrag:1;
+	int			uc_index;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist __rcu	*mc_list;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8aa87c1..9125529 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -469,6 +469,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
 			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
 			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG))) ||
+	    optname == IP_UNICAST_IF ||
 	    optname == IP_MULTICAST_TTL ||
 	    optname == IP_MULTICAST_ALL ||
 	    optname == IP_MULTICAST_LOOP ||
@@ -628,6 +629,35 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto e_inval;
 		inet->mc_loop = !!val;
 		break;
+	case IP_UNICAST_IF:
+	{
+		struct net_device *dev = NULL;
+		int ifindex;
+
+		if (optlen != sizeof(int))
+			goto e_inval;
+
+		ifindex = (__force int)ntohl((__force __be32)val);
+		if (ifindex == 0) {
+			inet->uc_index = 0;
+			err = 0;
+			break;
+		}
+
+		dev = dev_get_by_index(sock_net(sk), ifindex);
+		err = -EADDRNOTAVAIL;
+		if (!dev)
+			break;
+		dev_put(dev);
+
+		err = -EINVAL;
+		if (sk->sk_bound_dev_if)
+			break;
+
+		inet->uc_index = ifindex;
+		err = 0;
+		break;
+	}
 	case IP_MULTICAST_IF:
 	{
 		struct ip_mreqn mreq;
@@ -1178,6 +1208,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_MULTICAST_LOOP:
 		val = inet->mc_loop;
 		break;
+	case IP_UNICAST_IF:
+		val = (__force int)htonl((__u32) inet->uc_index);
+		break;
 	case IP_MULTICAST_IF:
 	{
 		struct in_addr addr;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index aea5a19..cfc82cf 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -556,7 +556,8 @@ static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			ipc.oif = inet->mc_index;
 		if (!saddr)
 			saddr = inet->mc_addr;
-	}
+	} else if (!ipc.oif)
+		ipc.oif = inet->uc_index;
 
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3ccda5a..ab46630 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -563,7 +563,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			ipc.oif = inet->mc_index;
 		if (!saddr)
 			saddr = inet->mc_addr;
-	}
+	} else if (!ipc.oif)
+		ipc.oif = inet->uc_index;
 
 	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
 			   RT_SCOPE_UNIVERSE,
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d075b5..cd99f1a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -917,7 +917,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if (!saddr)
 			saddr = inet->mc_addr;
 		connected = 0;
-	}
+	} else if (!ipc.oif)
+		ipc.oif = inet->uc_index;
 
 	if (connected)
 		rt = (struct rtable *)sk_dst_check(sk, 0);
-- 
1.7.5.4
