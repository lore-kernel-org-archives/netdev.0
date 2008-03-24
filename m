From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 5/11 net-2.6.26] [NETNS]: Add namespace parameter to ip_cmsg_send.
Date: Mon, 24 Mar 2008 17:36:06 +0300
Message-ID: <1206369372-27711-5-git-send-email-den@openvz.org>
References: <1206369185.23705.7.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, xemul@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:61459 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758734AbYCXOfv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2008 10:35:51 -0400
In-Reply-To: <1206369185.23705.7.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pass the init_net there for now.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ip.h       |    3 ++-
 net/ipv4/ip_sockglue.c |    4 ++--
 net/ipv4/raw.c         |    2 +-
 net/ipv4/udp.c         |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 531270d..6d7bcd5 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -362,7 +362,8 @@ extern int ip_options_rcv_srr(struct sk_buff *skb);
  */
 
 extern void	ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb);
-extern int	ip_cmsg_send(struct msghdr *msg, struct ipcm_cookie *ipc);
+extern int	ip_cmsg_send(struct net *net,
+			     struct msghdr *msg, struct ipcm_cookie *ipc);
 extern int	ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval, int optlen);
 extern int	ip_getsockopt(struct sock *sk, int level, int optname, char __user *optval, int __user *optlen);
 extern int	compat_ip_setsockopt(struct sock *sk, int level,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 1b86a50..0857f2d 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -163,7 +163,7 @@ void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
 		ip_cmsg_recv_security(msg, skb);
 }
 
-int ip_cmsg_send(struct msghdr *msg, struct ipcm_cookie *ipc)
+int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 {
 	int err;
 	struct cmsghdr *cmsg;
@@ -176,7 +176,7 @@ int ip_cmsg_send(struct msghdr *msg, struct ipcm_cookie *ipc)
 		switch (cmsg->cmsg_type) {
 		case IP_RETOPTS:
 			err = cmsg->cmsg_len - CMSG_ALIGN(sizeof(struct cmsghdr));
-			err = ip_options_get(&init_net, &ipc->opt, CMSG_DATA(cmsg), err < 40 ? err : 40);
+			err = ip_options_get(net, &ipc->opt, CMSG_DATA(cmsg), err < 40 ? err : 40);
 			if (err)
 				return err;
 			break;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index b433b48..7d29a05 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -499,7 +499,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(msg, &ipc);
+		err = ip_cmsg_send(&init_net, msg, &ipc);
 		if (err)
 			goto out;
 		if (ipc.opt)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8c1f5ea..9d69e9d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -607,7 +607,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.oif = sk->sk_bound_dev_if;
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(msg, &ipc);
+		err = ip_cmsg_send(&init_net, msg, &ipc);
 		if (err)
 			return err;
 		if (ipc.opt)
-- 
1.5.3.rc5

