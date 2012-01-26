From: "Erich E. Hoover" <ehoover@mines.edu>
Subject: [PATCH] Implement IP_UNICAST_IF socket option.
Date: Thu, 26 Jan 2012 16:57:48 -0700
Message-ID: <1327622268-15602-1-git-send-email-ehoover@mines.edu>
Cc: "Erich E. Hoover" <ehoover@mines.edu>
To: Linux Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from izzard.Mines.EDU ([138.67.132.197]:57175 "EHLO izzard.mines.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011Ab2A0Axd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 19:53:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The IP_UNICAST_IF feature is needed by the Wine project.  This patch implements the feature by setting the outgoing interface in the same fashion as that of IP_PKTINFO.

Signed-off-by: Erich E. Hoover <ehoover@mines.edu>
---
 include/linux/in.h      |    1 +
 include/net/inet_sock.h |    3 ++
 include/net/ip.h        |    2 +-
 net/ipv4/af_inet.c      |    3 ++
 net/ipv4/ip_sockglue.c  |   78 ++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/ping.c         |    2 +-
 net/ipv4/raw.c          |    2 +-
 net/ipv4/udp.c          |    2 +-
 8 files changed, 88 insertions(+), 5 deletions(-)

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
index e3e4051..1a8fe64 100644
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
@@ -167,6 +168,8 @@ struct inet_sock {
 				transparent:1,
 				mc_all:1,
 				nodefrag:1;
+	int			outif_index;
+	__be32			outif_addr;
 	int			mc_index;
 	__be32			mc_addr;
 	struct ip_mc_socklist __rcu	*mc_list;
diff --git a/include/net/ip.h b/include/net/ip.h
index 775009f..16f7151 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -452,7 +452,7 @@ extern int ip_options_rcv_srr(struct sk_buff *skb);
 
 extern void	ipv4_pktinfo_prepare(struct sk_buff *skb);
 extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
-extern int	ip_cmsg_send(struct net *net,
+extern int	ip_cmsg_send(struct sock *sk,
 			     struct msghdr *msg, struct ipcm_cookie *ipc);
 extern int	ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval, unsigned int optlen);
 extern int	ip_getsockopt(struct sock *sk, int level, int optname, char __user *optval, int __user *optlen);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f7b5670..44b1622 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -375,6 +375,9 @@ lookup_protocol:
 	sk->sk_protocol	   = protocol;
 	sk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
 
+	inet->outif_index  = 0;
+	inet->outif_addr   = 0;
+
 	inet->uc_ttl	= -1;
 	inet->mc_loop	= 1;
 	inet->mc_ttl	= 1;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8aa87c1..b99da51 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -186,11 +186,20 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(ip_cmsg_recv);
 
-int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
+int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc)
 {
+	struct net *net = sock_net(sk);
+	struct inet_sock *inet = inet_sk(sk);
 	int err;
 	struct cmsghdr *cmsg;
 
+	/* set the outgoing interface from IP_UNICAST_IF */
+	if (inet->outif_index || inet->outif_addr)
+	{
+		ipc->oif = inet->outif_index;
+		ipc->addr = inet->outif_addr;
+	}
+
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
@@ -628,6 +637,60 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			goto e_inval;
 		inet->mc_loop = !!val;
 		break;
+
+	case IP_UNICAST_IF:
+	{
+		struct ip_mreqn mreq;
+		struct net_device *dev = NULL;
+
+		/*
+		 *	Check the arguments are allowable
+		 */
+
+		if (optlen < sizeof(struct in_addr))
+			goto e_inval;
+
+		err = -EFAULT;
+		if (optlen >= sizeof(struct ip_mreqn)) {
+			if (copy_from_user(&mreq, optval, sizeof(mreq)))
+				break;
+		} else {
+			memset(&mreq, 0, sizeof(mreq));
+			if (optlen >= sizeof(struct in_addr) &&
+			    copy_from_user(&mreq.imr_address, optval,
+					   sizeof(struct in_addr)))
+				break;
+		}
+
+		if (!mreq.imr_ifindex) {
+			if (mreq.imr_address.s_addr == htonl(INADDR_ANY)) {
+				inet->outif_index = 0;
+				inet->outif_addr  = 0;
+				err = 0;
+				break;
+			}
+			dev = ip_dev_find(sock_net(sk), mreq.imr_address.s_addr);
+			if (dev)
+				mreq.imr_ifindex = dev->ifindex;
+		} else
+			dev = dev_get_by_index(sock_net(sk), mreq.imr_ifindex);
+
+
+		err = -EADDRNOTAVAIL;
+		if (!dev)
+			break;
+		dev_put(dev);
+
+		err = -EINVAL;
+		if (sk->sk_bound_dev_if &&
+		    mreq.imr_ifindex != sk->sk_bound_dev_if)
+			break;
+
+		inet->outif_index = mreq.imr_ifindex;
+		inet->outif_addr  = mreq.imr_address.s_addr;
+		err = 0;
+		break;
+	}
 	case IP_MULTICAST_IF:
 	{
 		struct ip_mreqn mreq;
@@ -1178,6 +1241,19 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_MULTICAST_LOOP:
 		val = inet->mc_loop;
 		break;
+	case IP_UNICAST_IF:
+	{
+		struct in_addr addr;
+		len = min_t(unsigned int, len, sizeof(struct in_addr));
+		addr.s_addr = inet->outif_addr;
+		release_sock(sk);
+
+		if (put_user(len, optlen))
+			return -EFAULT;
+		if (copy_to_user(optval, &addr, len))
+			return -EFAULT;
+		return 0;
+	}
 	case IP_MULTICAST_IF:
 	{
 		struct in_addr addr;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index aea5a19..fffdc44 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -517,7 +517,7 @@ static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return err;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		err = ip_cmsg_send(sk, msg, &ipc);
 		if (err)
 			return err;
 		if (ipc.opt)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3ccda5a..0aea6c7 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -518,7 +518,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		err = ip_cmsg_send(sk, msg, &ipc);
 		if (err)
 			goto out;
 		if (ipc.opt)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d075b5..e95c9d4 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -874,7 +874,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (err)
 		return err;
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		err = ip_cmsg_send(sk, msg, &ipc);
 		if (err)
 			return err;
 		if (ipc.opt)
-- 
1.7.5.4
