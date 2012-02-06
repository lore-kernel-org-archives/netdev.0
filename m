From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: [PATCH v3 1/2] Implement IP_UNICAST_IF socket option.
Date: Mon,  6 Feb 2012 10:57:43 -0700
Message-ID: <1328551064-28573-1-git-send-email-ehoover@mines.edu>
Cc: "Erich E. Hoover" <ehoover@mines.edu>
To: Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:52923 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130Ab2BFR6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 12:58:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The IP_UNICAST_IF feature is needed by the Wine project.  This patch implements the feature by setting the outgoing interface in a similar fashion to that of IP_PKTINFO.  A separate option is needed to handle this feature since the existing options do not provide all of the characteristics required by IP_UNICAST_IF, a summary is provided below.

SO_BINDTODEVICE:
* SO_BINDTODEVICE requires administrative privileges, IP_UNICAST_IF does not.  From reading some old mailing list articles my understanding is that SO_BINDTODEVICE requires administrative privileges because it can override the administrator's routing settings.
* The SO_BINDTODEVICE option restricts both outbound and inbound traffic, IP_UNICAST_IF only impacts outbound traffic.

IP_PKTINFO:
* Since IP_PKTINFO and IP_UNICAST_IF are independent options, implementing IP_UNICAST_IF with IP_PKTINFO will likely break some applications.
* Implementing IP_UNICAST_IF on top of IP_PKTINFO significantly complicates the Wine codebase and reduces the socket performance (doing this requires a lot of extra communication between the "server" and "user" layers).

bind():
* bind() does not work on broadcast packets, IP_UNICAST_IF is specifically intended to work with broadcast packets.

Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
---
 include/linux/in.h      |    1 +
 include/net/inet_sock.h |    2 +
 include/net/ip.h        |    1 +
 net/ipv4/af_inet.c      |    2 +
 net/ipv4/ip_sockglue.c  |   48 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ping.c         |    2 +-
 net/ipv4/raw.c          |    2 +-
 net/ipv4/udp.c          |    2 +-
 net/ipv6/af_inet6.c     |    2 +
 9 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/include/linux/in.h b/include/linux/in.h
index 01129c0..89f6682 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
@@ -86,6 +86,7 @@ struct in_addr {
 
 #define IP_MINTTL       21
 #define IP_NODEFRAG     22
+#define IP_UNICAST_IF   23
 
 /* IP_MTU_DISCOVER values */
 #define IP_PMTUDISC_DONT		0	/* Never send DF frames */
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index e3e4051..ad517f5 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -132,6 +132,7 @@ struct rtable;
  * @tos - TOS
  * @mc_ttl - Multicasting TTL
  * @is_icsk - is this an inet_connection_sock?
+ * @outif_index - Outgoing device index
  * @mc_index - Multicast device index
  * @mc_list - Group array
  * @cork - info to build ip hdr on each ip frag while socket is corked
@@ -167,6 +168,7 @@ struct inet_sock {
 				transparent:1,
 				mc_all:1,
 				nodefrag:1;
+	int			outif_index;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist __rcu	*mc_list;
diff --git a/include/net/ip.h b/include/net/ip.h
index 775009f..05aa269 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -452,6 +452,7 @@ extern int ip_options_rcv_srr(struct sk_buff *skb);
 
 extern void	ipv4_pktinfo_prepare(struct sk_buff *skb);
 extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
+extern int	ip_default_ifindex(const struct sock *sk);
 extern int	ip_cmsg_send(struct net *net,
 			     struct msghdr *msg, struct ipcm_cookie *ipc);
 extern int	ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval, unsigned int optlen);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f7b5670..a5855cd 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -375,6 +375,8 @@ lookup_protocol:
 	sk->sk_protocol	   = protocol;
 	sk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
 
+	inet->outif_index  = 0;
+
 	inet->uc_ttl	= -1;
 	inet->mc_loop	= 1;
 	inet->mc_ttl	= 1;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8aa87c1..87646e4 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -186,6 +186,21 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(ip_cmsg_recv);
 
+int ip_default_ifindex(const struct sock *sk)
+{
+	struct inet_sock *inet = inet_sk(sk);
+	int ifindex = sk->sk_bound_dev_if;
+
+	/*
+         * If not bound to a specific interface then set the outgoing interface
+	 * to the value from the IP_UNICAST_IF socket option.
+         */
+	if (!ifindex)
+		ifindex = inet->outif_index;
+
+	return ifindex;
+}
+
 int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 {
 	int err;
@@ -469,6 +484,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			     (1<<IP_ROUTER_ALERT) | (1<<IP_FREEBIND) |
 			     (1<<IP_PASSSEC) | (1<<IP_TRANSPARENT) |
 			     (1<<IP_MINTTL) | (1<<IP_NODEFRAG))) ||
+	    optname == IP_UNICAST_IF ||
 	    optname == IP_MULTICAST_TTL ||
 	    optname == IP_MULTICAST_ALL ||
 	    optname == IP_MULTICAST_LOOP ||
@@ -628,6 +644,35 @@ static int do_ip_setsockopt(struct sock *sk, int level,
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
+			inet->outif_index = 0;
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
+		if (sk->sk_bound_dev_if && ifindex != sk->sk_bound_dev_if)
+			break;
+
+		inet->outif_index = ifindex;
+		err = 0;
+		break;
+	}
 	case IP_MULTICAST_IF:
 	{
 		struct ip_mreqn mreq;
@@ -1178,6 +1223,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_MULTICAST_LOOP:
 		val = inet->mc_loop;
 		break;
+	case IP_UNICAST_IF:
+		val = (__force int)htonl((__u32) inet->outif_index);
+		break;
 	case IP_MULTICAST_IF:
 	{
 		struct in_addr addr;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index aea5a19..abeb454 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -510,7 +510,7 @@ static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.addr = inet->inet_saddr;
 	ipc.opt = NULL;
-	ipc.oif = sk->sk_bound_dev_if;
+	ipc.oif = ip_default_ifindex(sk);
 	ipc.tx_flags = 0;
 	err = sock_tx_timestamp(sk, &ipc.tx_flags);
 	if (err)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3ccda5a..000d9fb 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -515,7 +515,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->inet_saddr;
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
-	ipc.oif = sk->sk_bound_dev_if;
+	ipc.oif = ip_default_ifindex(sk);
 
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d075b5..651eb62 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -869,7 +869,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 	ipc.addr = inet->inet_saddr;
 
-	ipc.oif = sk->sk_bound_dev_if;
+	ipc.oif = ip_default_ifindex(sk);
 	err = sock_tx_timestamp(sk, &ipc.tx_flags);
 	if (err)
 		return err;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 273f48d..13b84bc 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -210,6 +210,8 @@ lookup_protocol:
 	 */
 	inet->uc_ttl	= -1;
 
+	inet->outif_index = 0;
+
 	inet->mc_loop	= 1;
 	inet->mc_ttl	= 1;
 	inet->mc_index	= 0;
-- 
1.7.5.4
