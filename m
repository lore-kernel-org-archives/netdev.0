From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 2/2] ip: support for TX timestamps on UDP and RAW sockets
Date: Tue, 29 Jul 2008 03:35:53 +0300
Message-ID: <1217291753-5322-3-git-send-email-opurdila@ixiacom.com>
References: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:25529 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751577AbYG2AiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 20:38:25 -0400
In-Reply-To: <1217291753-5322-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/ip.h     |    1 +
 net/can/raw.c        |    8 ++++++++
 net/ipv4/icmp.c      |    2 ++
 net/ipv4/ip_output.c |    2 ++
 net/ipv4/raw.c       |    1 +
 net/ipv4/udp.c       |    4 ++++
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 3b40bc2..b557a7a 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -54,6 +54,7 @@ struct ipcm_cookie
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
+	ktime_t			tstamp;
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
diff --git a/net/can/raw.c b/net/can/raw.c
index 3e46ee3..e1dff8a 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -618,6 +618,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct raw_sock *ro = raw_sk(sk);
 	struct sk_buff *skb;
 	struct net_device *dev;
+	ktime_t tstamp = {
+		.tv64 = 0.
+	};
 	int ifindex;
 	int err;
 
@@ -639,6 +642,10 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!dev)
 		return -ENXIO;
 
+	err = sock_send_timestamp(&tstamp, msg, sk);
+	if (err < 0)
+		return err;
+
 	skb = sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT,
 				  &err);
 	if (!skb) {
@@ -654,6 +661,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 	skb->dev = dev;
 	skb->sk  = sk;
+	skb->tstamp = tstamp;
 
 	err = can_send(skb, ro->loopback);
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 8739735..4d65f57 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -377,6 +377,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt = &icmp_param->replyopts;
 		if (ipc.opt->srr)
@@ -534,6 +535,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	inet_sk(sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
+	ipc.tstamp.tv64 = 0;
 
 	{
 		struct flowi fl = {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e527628..08be117 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -941,6 +941,7 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+			skb->tstamp = ipc->tstamp;
 
 			/*
 			 *	Find where to start putting bytes.
@@ -1354,6 +1355,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 
 	if (replyopts.opt.optlen) {
 		ipc.opt = &replyopts.opt;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 37a1ecd..0719f88 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -494,6 +494,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.addr = inet->saddr;
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 56fcda3..aea821f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -560,6 +560,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 
 	if (up->pending) {
 		/*
@@ -608,6 +609,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.oif = sk->sk_bound_dev_if;
 	if (msg->msg_controllen) {
+		err = sock_send_timestamp(&ipc.tstamp, msg, sk);
+		if (err)
+			return err;
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
 			return err;
-- 
1.5.6.2

