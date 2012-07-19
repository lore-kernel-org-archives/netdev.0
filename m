From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: tcp: remove per net tcp_sock
Date: Thu, 19 Jul 2012 10:58:52 +0200
Message-ID: <1342688332.2626.4001.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:59618 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753322Ab2GSI66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 04:58:58 -0400
Received: by qaas11 with SMTP id s11so1537863qaa.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 01:58:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcp_v4_send_reset() and tcp_v4_send_ack() use a single socket
per network namespace.

This leads to bad behavior on multiqueue NICS, because many cpus
contend for the socket lock and once socket lock is acquired, extra
false sharing on various socket fields slow down the operations.

To better resist to attacks, we use a percpu socket. Each cpu can
run without contention, using appropriate memory (local node)

Additional features :

1) We also mirror the queue_mapping of the incoming skb, so that
answers use the same queue if possible.

2) Setting SOCK_USE_WRITE_QUEUE socket flag speedup sock_wfree()

3) We now limit the number of in-flight RST/ACK [1] packets
per cpu, instead of per namespace, and we honor the sysctl_wmem_default
limit dynamically. (Prior to this patch, sysctl_wmem_default value was
copied at boot time, so any further change would not affect tcp_sock
limit)


[1] These packets are only generated when no socket was matched for
the incoming packet.

Reported-by: Bill Sommerfeld <wsommerfeld@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
---
 include/net/ip.h         |    2 -
 include/net/netns/ipv4.h |    1 
 net/ipv4/ip_output.c     |   46 ++++++++++++++++++++++---------------
 net/ipv4/tcp_ipv4.c      |    8 ++----
 4 files changed, 32 insertions(+), 25 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index ec5cfde..bd5e444 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -158,7 +158,7 @@ static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
 	return (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ? FLOWI_FLAG_ANYSRC : 0;
 }
 
-void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
+void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 			   __be32 saddr, const struct ip_reply_arg *arg,
 			   unsigned int len);
 
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 2e089a9..d909c7f 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -38,7 +38,6 @@ struct netns_ipv4 {
 	struct sock		*fibnl;
 
 	struct sock		**icmp_sk;
-	struct sock		*tcp_sock;
 	struct inet_peer_base	*peers;
 	struct tcpm_hash_bucket	*tcp_metrics_hash;
 	unsigned int		tcp_metrics_hash_mask;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index cc52679..3633136 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1463,20 +1463,29 @@ static int ip_reply_glue_bits(void *dptr, char *to, int offset,
 
 /*
  *	Generic function to send a packet as reply to another packet.
- *	Used to send TCP resets so far.
+ *	Used to send some TCP resets/acks so far.
  *
- *	Should run single threaded per socket because it uses the sock
- *     	structure to pass arguments.
+ *	Use a fake percpu inet socket to avoid false sharing and contention.
  */
-void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
+void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 			   __be32 saddr, const struct ip_reply_arg *arg,
 			   unsigned int len)
 {
-	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_data replyopts;
 	struct ipcm_cookie ipc;
 	struct flowi4 fl4;
 	struct rtable *rt = skb_rtable(skb);
+	struct sk_buff *nskb;
+	struct sock *sk;
+	struct inet_sock *inet;
+	static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
+		.sk = {
+			.sk_wmem_alloc	= ATOMIC_INIT(1),
+			.sk_allocation	= GFP_ATOMIC,
+			.sk_flags	= (1UL << SOCK_USE_WRITE_QUEUE),
+		},
+		.pmtudisc = IP_PMTUDISC_WANT,
+	};
 
 	if (ip_options_echo(&replyopts.opt.opt, skb))
 		return;
@@ -1494,38 +1503,39 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
 
 	flowi4_init_output(&fl4, arg->bound_dev_if, 0,
 			   RT_TOS(arg->tos),
-			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
+			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
 			   ip_reply_arg_flowi_flags(arg),
 			   daddr, saddr,
 			   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
-	rt = ip_route_output_key(sock_net(sk), &fl4);
+	rt = ip_route_output_key(net, &fl4);
 	if (IS_ERR(rt))
 		return;
 
-	/* And let IP do all the hard work.
+	inet = &get_cpu_var(unicast_sock);
 
-	   This chunk is not reenterable, hence spinlock.
-	   Note that it uses the fact, that this function is called
-	   with locally disabled BH and that sk cannot be already spinlocked.
-	 */
-	bh_lock_sock(sk);
 	inet->tos = arg->tos;
+	sk = &inet->sk;
 	sk->sk_priority = skb->priority;
 	sk->sk_protocol = ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if = arg->bound_dev_if;
+	sock_net_set(sk, net);
+	__skb_queue_head_init(&sk->sk_write_queue);
+	sk->sk_sndbuf = sysctl_wmem_default;
 	ip_append_data(sk, &fl4, ip_reply_glue_bits, arg->iov->iov_base, len, 0,
 		       &ipc, &rt, MSG_DONTWAIT);
-	if ((skb = skb_peek(&sk->sk_write_queue)) != NULL) {
+	nskb = skb_peek(&sk->sk_write_queue);
+	if (nskb) {
 		if (arg->csumoffset >= 0)
-			*((__sum16 *)skb_transport_header(skb) +
-			  arg->csumoffset) = csum_fold(csum_add(skb->csum,
+			*((__sum16 *)skb_transport_header(nskb) +
+			  arg->csumoffset) = csum_fold(csum_add(nskb->csum,
 								arg->csum));
-		skb->ip_summed = CHECKSUM_NONE;
+		nskb->ip_summed = CHECKSUM_NONE;
+		skb_set_queue_mapping(nskb, skb_get_queue_mapping(skb));
 		ip_push_pending_frames(sk, &fl4);
 	}
 
-	bh_unlock_sock(sk);
+	put_cpu_var(unicast_sock);
 
 	ip_rt_put(rt);
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index d9caf5c..d7d2fa5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -688,7 +688,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 	net = dev_net(skb_dst(skb)->dev);
 	arg.tos = ip_hdr(skb)->tos;
-	ip_send_unicast_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
+	ip_send_unicast_reply(net, skb, ip_hdr(skb)->saddr,
 			      ip_hdr(skb)->daddr, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
@@ -771,7 +771,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	if (oif)
 		arg.bound_dev_if = oif;
 	arg.tos = tos;
-	ip_send_unicast_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
+	ip_send_unicast_reply(net, skb, ip_hdr(skb)->saddr,
 			      ip_hdr(skb)->daddr, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
@@ -2624,13 +2624,11 @@ EXPORT_SYMBOL(tcp_prot);
 
 static int __net_init tcp_sk_init(struct net *net)
 {
-	return inet_ctl_sock_create(&net->ipv4.tcp_sock,
-				    PF_INET, SOCK_RAW, IPPROTO_TCP, net);
+	return 0;
 }
 
 static void __net_exit tcp_sk_exit(struct net *net)
 {
-	inet_ctl_sock_destroy(net->ipv4.tcp_sock);
 }
 
 static void __net_exit tcp_sk_exit_batch(struct list_head *net_exit_list)
