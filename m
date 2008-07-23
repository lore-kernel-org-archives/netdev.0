From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC][PATCH 2/3] ip: support for SOL_SKB control messages for UDP/RAW sockets
Date: Thu, 24 Jul 2008 01:01:03 +0300
Message-ID: <1216850464-30000-3-git-send-email-opurdila@ixiacom.com>
References: <1216850464-30000-1-git-send-email-opurdila@ixiacom.com>
Cc: Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:1937 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753605AbYGWWDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:03:32 -0400
In-Reply-To: <1216850464-30000-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/linux/skbuff.h |    2 +-
 include/net/ip.h       |    1 +
 net/ipv4/icmp.c        |    2 ++
 net/ipv4/ip_output.c   |    2 ++
 net/ipv4/ip_sockglue.c |    6 ++++++
 net/ipv4/raw.c         |    1 +
 net/ipv4/udp.c         |    1 +
 7 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f2988d1..2d394ed 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1762,7 +1762,7 @@ struct skb_cmsg *skb_cmsg_alloc(int type, int len, int gfp);
  */
 static inline void skb_cmsg_add(struct skb_cmsg **head, struct skb_cmsg *sc)
 {
-	sc->next = (*head)->next;
+	sc->next = *head;
 	*head = sc;
 }
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 3b40bc2..ccb8be7 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -54,6 +54,7 @@ struct ipcm_cookie
 	__be32			addr;
 	int			oif;
 	struct ip_options	*opt;
+	struct skb_cmsg		*skb_cmsg;
 };
 
 #define IPCB(skb) ((struct inet_skb_parm*)((skb)->cb))
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 8739735..68da287 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -377,6 +377,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.skb_cmsg = NULL;
 	if (icmp_param->replyopts.optlen) {
 		ipc.opt = &icmp_param->replyopts;
 		if (ipc.opt->srr)
@@ -534,6 +535,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	inet_sk(sk)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
+	ipc.skb_cmsg = NULL;
 
 	{
 		struct flowi fl = {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index e527628..da85d42 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -941,6 +941,7 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+			skb_shinfo(skb)->cmsg = ipc->skb_cmsg;
 
 			/*
 			 *	Find where to start putting bytes.
@@ -1354,6 +1355,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
 	daddr = ipc.addr = rt->rt_src;
 	ipc.opt = NULL;
+	ipc.skb_cmsg = NULL;
 
 	if (replyopts.opt.optlen) {
 		ipc.opt = &replyopts.opt;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index e0514e8..599cfe6 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -169,6 +169,10 @@ int ip_cmsg_send(struct net *net, struct msghdr *msg, struct ipcm_cookie *ipc)
 	int err;
 	struct cmsghdr *cmsg;
 
+	err = __skb_cmsg_send(&ipc->skb_cmsg, msg);
+	if (err)
+		return err;
+
 	for (cmsg = CMSG_FIRSTHDR(msg); cmsg; cmsg = CMSG_NXTHDR(msg, cmsg)) {
 		if (!CMSG_OK(msg, cmsg))
 			return -EINVAL;
@@ -353,6 +357,8 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len)
 	if (err)
 		goto out_free_skb;
 
+	skb_cmsg_recv(msg, skb);
+
 	sock_recv_timestamp(msg, sk, skb);
 
 	serr = SKB_EXT_ERR(skb);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 37a1ecd..75f0122 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -494,6 +494,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.addr = inet->saddr;
 	ipc.opt = NULL;
+	ipc.skb_cmsg = NULL;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 56fcda3..e9b0f51 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -560,6 +560,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
+	ipc.skb_cmsg = NULL;
 
 	if (up->pending) {
 		/*
-- 
1.5.6.2

