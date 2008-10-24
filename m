From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [RFC PATCH 05/13] ip: support for TX timestamps on UDP and RAW
	sockets
Date: Fri, 24 Oct 2008 15:49:10 +0200
Message-ID: <1226415422.31699.4.camel@ecld0pohly>
References: <1226414697.17450.852.camel@ecld0pohly>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30488 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756026AbYKKO5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 09:57:03 -0500
In-Reply-To: <1226414697.17450.852.camel@ecld0pohly>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Patrick Ohly <patrick.ohly@intel.com>
---
 include/net/ip.h     |    1 +
 net/can/raw.c        |    8 ++++++++
 net/ipv4/icmp.c      |    2 ++
 net/ipv4/ip_output.c |    2 ++
 net/ipv4/raw.c       |    1 +
 net/ipv4/udp.c       |    4 ++++
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 250e6ef..76cee15 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -54,6 +54,7 @@ struct ipcm_cookie
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
+	union ktime		tstamp;
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
diff --git a/net/can/raw.c b/net/can/raw.c
index 6e0663f..b3a978b 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -618,6 +618,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct raw_sock *ro = raw_sk(sk);
 	struct sk_buff *skb;
 	struct net_device *dev;
+	union ktime tstamp = {
+		.tv64 = 0.
+	};
 	int ifindex;
 	int err;
 
@@ -639,6 +642,10 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!dev)
 		return -ENXIO;
 
+	err = sock_tx_timestamp(msg, sk, &tstamp);
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
index 55c355e..27cd661 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -375,6 +375,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt = &icmp_param->replyopts;
 		if (ipc.opt->srr)
@@ -532,6 +533,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	inet_sk(sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
+	ipc.tstamp.tv64 = 0;
 
 	{
 		struct flowi fl = {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d533a89..437906d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -939,6 +939,7 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+			skb->tstamp = ipc->tstamp;
 
 			/*
 			 *	Find where to start putting bytes.
@@ -1353,6 +1354,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 
 	if (replyopts.opt.optlen) {
 		ipc.opt = &replyopts.opt;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index cd97574..2120ac5 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -493,6 +493,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.addr = inet->saddr;
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 57e26fa..6b9c544 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -557,6 +557,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
+	ipc.tstamp.tv64 = 0;
 
 	if (up->pending) {
 		/*
@@ -604,6 +605,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
+	err = sock_tx_timestamp(msg, sk, &ipc.tstamp);
+	if (err)
+		return err;
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
-- 
1.6.0.4


