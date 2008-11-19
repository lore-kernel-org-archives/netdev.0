From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 05/11] ip: support for TX timestamps on UDP and RAW sockets
Date: Wed, 19 Nov 2008 13:08:42 +0100
Message-ID: <1227096528-24150-6-git-send-email-patrick.ohly@intel.com>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-2-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-3-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-4-git-send-email-patrick.ohly@intel.com>
 <1227096528-24150-5-git-send-email-patrick.ohly@intel.com>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick Ohly <patrick.ohly@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2282 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752642AbYKSMJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2008 07:09:03 -0500
In-Reply-To: <1227096528-24150-5-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instructions for time stamping outgoing packets are take from the
socket layer and later copied into the new skb.
---
 include/net/ip.h     |    1 +
 net/can/raw.c        |    6 ++++++
 net/ipv4/icmp.c      |    2 ++
 net/ipv4/ip_output.c |    2 ++
 net/ipv4/raw.c       |    1 +
 net/ipv4/udp.c       |    4 ++++
 6 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index bc026ec..9bc2b65 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -55,6 +55,7 @@ struct ipcm_cookie
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
+	union sk_buff_hwtstamp	tstamp_tx;
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
diff --git a/net/can/raw.c b/net/can/raw.c
index 6e0663f..d4a38e3 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -618,6 +618,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct raw_sock *ro = raw_sk(sk);
 	struct sk_buff *skb;
 	struct net_device *dev;
+	union sk_buff_hwtstamp tstamp_tx;
 	int ifindex;
 	int err;
 
@@ -639,6 +640,10 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!dev)
 		return -ENXIO;
 
+	err = sock_tx_timestamp(msg, sk, &tstamp_tx);
+	if (err < 0)
+		return err;
+
 	skb = sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT,
 				  &err);
 	if (!skb) {
@@ -654,6 +659,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	}
 	skb->dev = dev;
 	skb->sk  = sk;
+	skb->hwtstamp = tstamp_tx;
 
 	err = can_send(skb, ro->loopback);
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 21e497e..ba739f4 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -375,6 +375,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.tstamp_tx.hwtstamp.tv64 = 0;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt = &icmp_param->replyopts;
 		if (ipc.opt->srr)
@@ -532,6 +533,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	inet_sk(sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
+	ipc.tstamp_tx.hwtstamp.tv64 = 0;
 
 	{
 		struct flowi fl = {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 46d7be2..1498848 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -940,6 +940,7 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+			skb->hwtstamp = ipc->tstamp_tx;
 
 			/*
 			 *	Find where to start putting bytes.
@@ -1354,6 +1355,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.tstamp_tx.hwtstamp.tv64 = 0;
 
 	if (replyopts.opt.optlen) {
 		ipc.opt = &replyopts.opt;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 998fcff..9115ed5 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -493,6 +493,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.addr = inet->saddr;
 	ipc.opt = NULL;
+	ipc.tstamp_tx.hwtstamp.tv64 = 0;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index fea2d87..32c4e98 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -573,6 +573,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
+	ipc.tstamp_tx.hwtstamp.tv64 = 0;
 
 	if (up->pending) {
 		/*
@@ -620,6 +621,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
+	err = sock_tx_timestamp(msg, sk, &ipc.tstamp_tx);
+	if (err)
+		return err;
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
-- 
1.6.0.4

