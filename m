From: Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH NET-NEXT 05/12] ip: support for TX timestamps on UDP and RAW sockets
Date: Wed, 21 Jan 2009 11:10:05 +0100
Message-ID: <1232532612-10382-5-git-send-email-patrick.ohly@intel.com>
References: <1232532457.7829.19.camel@ecld0pohly>
 <1232532612-10382-1-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-2-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-3-git-send-email-patrick.ohly@intel.com>
 <1232532612-10382-4-git-send-email-patrick.ohly@intel.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Patrick Ohly <patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1232532612-10382-4-git-send-email-patrick.ohly-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Instructions for time stamping outgoing packets are take from the
socket layer and later copied into the new skb.
---
 Documentation/networking/timestamping.txt |    2 ++
 include/net/ip.h                          |    1 +
 net/can/raw.c                             |   14 +++++++++++---
 net/ipv4/icmp.c                           |    2 ++
 net/ipv4/ip_output.c                      |   12 ++++++++++--
 net/ipv4/raw.c                            |    1 +
 net/ipv4/udp.c                            |    4 ++++
 7 files changed, 31 insertions(+), 5 deletions(-)

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
index 27aab63..1f2111d 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -618,6 +618,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct raw_sock *ro = raw_sk(sk);
 	struct sk_buff *skb;
 	struct net_device *dev;
+	union skb_shared_tx shtx;
 	int ifindex;
 	int err;
 
@@ -639,8 +640,14 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (!dev)
 		return -ENXIO;
 
-	skb = sock_alloc_send_skb(sk, size, msg->msg_flags & MSG_DONTWAIT,
-				  &err);
+	err = sock_tx_timestamp(msg, sk, &shtx);
+	if (err < 0)
+		return err;
+
+	skb = sock_alloc_send_skb_flags(sk, size,
+				((msg->msg_flags & MSG_DONTWAIT) ? SKB_FLAGS_NOBLOCK : 0) |
+					(shtx.flags ? SKB_FLAGS_OPTIONAL_TX : 0),
+				&err);
 	if (!skb)
 		goto put_dev;
 
@@ -649,7 +656,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct socket *sock,
 		goto free_skb;
 	skb->dev = dev;
 	skb->sk  = sk;
-
+	if (shtx.flags)
+		*skb_tx(skb) = shtx;
 	err = can_send(skb, ro->loopback);
 
 	dev_put(dev);
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
index 8ebe86d..ed92f0b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -923,9 +923,11 @@ alloc_new_skb:
 				alloclen += rt->u.dst.trailer_len;
 
 			if (transhdrlen) {
-				skb = sock_alloc_send_skb(sk,
+				skb = sock_alloc_send_skb_flags(sk,
 						alloclen + hh_len + 15,
-						(flags & MSG_DONTWAIT), &err);
+				       		((flags & MSG_DONTWAIT) ? SKB_FLAGS_NOBLOCK : 0) |
+							(ipc->shtx.flags ? SKB_FLAGS_OPTIONAL_TX : 0),
+						&err);
 			} else {
 				skb = NULL;
 				if (atomic_read(&sk->sk_wmem_alloc) <=
@@ -935,6 +937,9 @@ alloc_new_skb:
 							   sk->sk_allocation);
 				if (unlikely(skb == NULL))
 					err = -ENOBUFS;
+				else
+					/* only the initial fragment is time stamped */
+					ipc->shtx.flags = 0;
 			}
 			if (skb == NULL)
 				goto error;
@@ -945,6 +950,8 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+			if (ipc->shtx.flags)
+				*skb_tx(skb) = ipc->shtx;
 
 			/*
 			 *	Find where to start putting bytes.
@@ -1364,6 +1371,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 
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
index cf5ab05..bbf1a6d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -573,6 +573,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		return -EOPNOTSUPP;
 
 	ipc.opt = NULL;
+	ipc.shtx.flags = 0;
 
 	if (up->pending) {
 		/*
@@ -620,6 +621,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->saddr;
 
 	ipc.oif = sk->sk_bound_dev_if;
+	err = sock_tx_timestamp(msg, sk, &ipc.shtx);
+	if (err)
+		return err;
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
 		if (err)
-- 
1.5.5.3

--
To unsubscribe from this list: send the line "unsubscribe linux-api" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
