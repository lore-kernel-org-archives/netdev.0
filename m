From: Patrick Ohly <patrick.ohly@intel.com>
Subject: [PATCH NET-NEXT 06/10] ip: support for TX timestamps on UDP and RAW sockets
Date: Thu, 12 Feb 2009 16:00:08 +0100
Message-ID: <1234450812-6246-6-git-send-email-patrick.ohly@intel.com>
References: <1234450670.5914.9.camel@ecld0pohly>
 <1234450812-6246-1-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-2-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-3-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-4-git-send-email-patrick.ohly@intel.com>
 <1234450812-6246-5-git-send-email-patrick.ohly@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	John Stultz <johnstul@us.ibm.com>,
	John Ronciak <john.ronciak@intel.com>,
	Patrick Ohly <patrick.ohly@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27444 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758681AbZBLPAb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 10:00:31 -0500
In-Reply-To: <1234450812-6246-5-git-send-email-patrick.ohly@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instructions for time stamping outgoing packets are take from the
socket layer and later copied into the new skb.
---
 Documentation/networking/timestamping.txt |    2 ++
 include/net/ip.h                          |    1 +
 net/can/raw.c                             |    3 +++
 net/ipv4/icmp.c                           |    2 ++
 net/ipv4/ip_output.c                      |    6 ++++++
 net/ipv4/raw.c                            |    1 +
 net/ipv4/udp.c                            |    4 ++++
 7 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index a681a65..0e58b45 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -56,6 +56,8 @@ and including the link layer, the scm_timestamping control message and
 a sock_extended_err control message with ee_errno==ENOMSG and
 ee_origin==SO_EE_ORIGIN_TIMESTAMPING. A socket with such a pending
 bounced packet is ready for reading as far as select() is concerned.
+If the outgoing packet has to be fragmented, then only the first
+fragment is time stamped and returned to the sending socket.
 
 All three values correspond to the same event in time, but were
 generated in different ways. Each of these values may be empty (= all
diff --git a/include/net/ip.h b/include/net/ip.h
index 1086813..4ac7577 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -55,6 +55,7 @@ struct ipcm_cookie
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
+	union skb_shared_tx	shtx;
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
diff --git a/net/can/raw.c b/net/can/raw.c
index 0703cba..6aa154e 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -648,6 +648,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
 	if (err < 0)
 		goto free_skb;
+	err = sock_tx_timestamp(msg, sk, skb_tx(skb));
+	if (err < 0)
+		goto free_skb;
 	skb->dev = dev;
 	skb->sk  = sk;
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 705b33b..382800a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -375,6 +375,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.shtx.flags = 0;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt = &icmp_param->replyopts;
 		if (ipc.opt->srr)
@@ -532,6 +533,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	inet_sk(sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
+	ipc.shtx.flags = 0;
 
 	{
 		struct flowi fl = {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8ebe86d..3e7e910 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -935,6 +935,10 @@ alloc_new_skb:
 							   sk->sk_allocation);
 				if (unlikely(skb == NULL))
 					err = -ENOBUFS;
+				else
+					/* only the initial fragment is
+					   time stamped */
+					ipc->shtx.flags = 0;
 			}
 			if (skb == NULL)
 				goto error;
@@ -945,6 +949,7 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+			*skb_tx(skb) = ipc->shtx;
 
 			/*
 			 *	Find where to start putting bytes.
@@ -1364,6 +1369,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.shtx.flags = 0;
 
 	if (replyopts.opt.optlen) {
 		ipc.opt = &replyopts.opt;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index dff8bc4..f774651 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -493,6 +493,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.addr = inet->saddr;
 	ipc.opt = NULL;
+	ipc.shtx.flags = 0;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c47c989..4bd178a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -596,6 +596,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
+	ipc.shtx.flags = 0;
 
 	if (up->pending) {
 		/*
@@ -643,6 +644,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
+	err = sock_tx_timestamp(msg, sk, &ipc.shtx);
+	if (err)
+		return err;
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
-- 
1.6.1.2

