From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH v3 net-next 5/8] ipv4: process socket-level control messages in IPv4
Date: Sat,  2 Apr 2016 23:08:10 -0400
Message-ID: <1459652893-14207-6-git-send-email-soheil.kdev@gmail.com>
References: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Cc: willemb@google.com, edumazet@google.com, ycheng@google.com,
	ncardwell@google.com, kafai@fb.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f65.google.com ([209.85.192.65]:36391 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbcDCDI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 23:08:26 -0400
Received: by mail-qg0-f65.google.com with SMTP id n34so14845850qge.3
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 20:08:25 -0700 (PDT)
In-Reply-To: <1459652893-14207-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

Process socket-level control messages by invoking
__sock_cmsg_send in ip_cmsg_send for control messages on
the SOL_SOCKET layer.

This makes sure whenever ip_cmsg_send is called in udp, icmp,
and raw, we also process socket-level control messages.

Note that this commit interprets new control messages that
were ignored before. As such, this commit does not change
the behavior of IPv4 control messages.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>
---
 include/net/ip.h       | 3 ++-
 net/ipv4/ip_sockglue.c | 9 ++++++++-
 net/ipv4/ping.c        | 2 +-
 net/ipv4/raw.c         | 2 +-
 net/ipv4/udp.c         | 3 +--
 5 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index fad74d3..93725e5 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -56,6 +56,7 @@ static inline unsigned int ip_hdrlen(const struct sk_buff *skb)
 }
 
 struct ipcm_cookie {
+	struct sockcm_cookie	sockc;
 	__be32			addr;
 	int			oif;
 	struct ip_options_rcu	*opt;
@@ -550,7 +551,7 @@ int ip_options_rcv_srr(struct sk_buff *skb);
 
 void ipv4_pktinfo_prepare(const struct sock *sk, struct sk_buff *skb);
 void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb, int offset);
-int ip_cmsg_send(struct net *net, struct msghdr *msg,
+int ip_cmsg_send(struct sock *sk, struct msghdr *msg,
 		 struct ipcm_cookie *ipc, bool allow_ipv6);
 int ip_setsockopt(struct sock *sk, int level, int optname, char __user *optval,
 		  unsigned int optlen);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 035ad64..1b7c077 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -219,11 +219,12 @@ void ip_cmsg_recv_offset(struct msghdr *msg, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(ip_cmsg_recv_offset);
 
-int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
+int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
 		 bool allow_ipv6)
 {
 	int err, val;
 	struct cmsghdr *cmsg;
+	struct net *net = sock_net(sk);
 
 	for_each_cmsghdr(cmsg, msg) {
 		if (!CMSG_OK(msg, cmsg))
@@ -244,6 +245,12 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc,
 			continue;
 		}
 #endif
+		if (cmsg->cmsg_level == SOL_SOCKET) {
+			if (__sock_cmsg_send(sk, msg, cmsg, &ipc->sockc))
+				return -EINVAL;
+			continue;
+		}
+
 		if (cmsg->cmsg_level != SOL_IP)
 			continue;
 		switch (cmsg->cmsg_type) {
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index cf9700b..670639b 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -747,7 +747,7 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	sock_tx_timestamp(sk, &ipc.tx_flags);
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc, false);
+		err = ip_cmsg_send(sk, msg, &ipc, false);
 		if (unlikely(err)) {
 			kfree(ipc.opt);
 			return err;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 8d22de7..088ce66 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -548,7 +548,7 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(net, msg, &ipc, false);
+		err = ip_cmsg_send(sk, msg, &ipc, false);
 		if (unlikely(err)) {
 			kfree(ipc.opt);
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 08eed5e..bccb4e1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1034,8 +1034,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	sock_tx_timestamp(sk, &ipc.tx_flags);
 
 	if (msg->msg_controllen) {
-		err = ip_cmsg_send(sock_net(sk), msg, &ipc,
-				   sk->sk_family == AF_INET6);
+		err = ip_cmsg_send(sk, msg, &ipc, sk->sk_family == AF_INET6);
 		if (unlikely(err)) {
 			kfree(ipc.opt);
 			return err;
-- 
2.8.0.rc3.226.g39d4020
