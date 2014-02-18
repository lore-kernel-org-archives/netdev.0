From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: honor IPV6_PKTINFO with v4 mapped addresses on sendmsg
Date: Tue, 18 Feb 2014 21:38:08 +0100
Message-ID: <20140218203808.GA19788@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: gert@space.net, tore@fud.no
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36279 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbaBRUiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 15:38:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we decide in udp6_sendmsg to send the packet down the ipv4
udp_sendmsg path because the destination is either of family AF_INET or
the destination is an ipv4 mapped ipv6 address, we don't honor the
maybe specified ipv4 mapped ipv6 address in IPV6_PKTINFO.

We simply can check for this option in ip_cmsg_send because no calls to
ipv6 module functions are needed to do so.

Reported-by: Gert Doering <gert@space.net>
Cc: Tore Anderson <tore@fud.no>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/ip.h       |  3 ++-
 net/ipv4/ip_sockglue.c | 19 ++++++++++++++++++-
 net/ipv4/ping.c        |  2 +-
 net/ipv4/raw.c         |  2 +-
 net/ipv4/udp.c         |  3 ++-
 5 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 23be0fd..4aa781b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -489,7 +489,8 @@ int ip_options_rcv_srr(struct sk_buff *skb);
 
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
 void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
-int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc);
+int ip_cmsg_send(struct net *net, struct msghdr *msg,
+		 struct ipcm_cookie *ipc, bool allow_ipv6);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		  unsigned int optlen);
 int ip_getsockopt(struct sock *sk, int level, int optname, char __user *optval,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 580dd96..0968b28 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -186,7 +186,8 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(ip_cmsg_recv);
 
-int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
+int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
+		 bool allow_ipv6)
 {
 	int err, val;
 	struct cmsghdr *cmsg;
@@ -194,6 +195,22 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
+#if defined(CONFIG_IPV6)
+		if (allow_ipv6 &&
+		    cmsg->cmsg_level == SOL_IPV6 &&
+		    cmsg->cmsg_type == IPV6_PKTINFO) {
+			struct in6_pktinfo *src_info;
+
+			if (cmsg->cmsg_len < CMSG_LEN(sizeof(*src_info)))
+				return -EINVAL;
+			src_info = (struct in6_pktinfo *)CMSG_DATA(cmsg);
+			if (!ipv6_addr_v4mapped(&src_info->ipi6_addr))
+				return -EINVAL;
+			ipc->oif = src_info->ipi6_ifindex;
+			ipc->addr = src_info->ipi6_addr.s6_addr32[3];
+			continue;
+		}
+#endif
 		if (cmsg->cmsg_level != SOL_IP)
 			continue;
 		switch (cmsg->cmsg_type) {
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 2d11c09..f4b19e5 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -727,7 +727,7 @@ static int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *m
 	sock_tx_timestamp(sk, &ipc.tx_flags);
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
 		if (err)
 			return err;
 		if (ipc.opt)
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index c04518f..a9dbe58 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -524,7 +524,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
 		if (err)
 			goto out;
 		if (ipc.opt)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 77bd16f..4468e1a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -931,7 +931,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	sock_tx_timestamp(sk, &ipc.tx_flags);
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		err = ip_cmsg_send(sock_net(sk), msg, &ipc,
+				   sk->sk_family == AF_INET6);
 		if (err)
 			return err;
 		if (ipc.opt)
-- 
1.8.5.3
