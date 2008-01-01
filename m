From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [ICMP]: change "struct socket *" percpu var to a "struct sock *"
Date: Tue, 01 Jan 2008 19:46:21 +0100
Message-ID: <477A8A7D.3000301@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020505090003050605010202"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33649 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754190AbYAASqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 13:46:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020505090003050605010202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Instead of storing a pointer to a 'struct socket' and dereferencing ->sk
to get "struct sock *" from it, just store a "struct sock *" pointer.

This saves 75 bytes of text on x86

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--------------020505090003050605010202
Content-Type: text/plain;
 name="icmp.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="icmp.patch"

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ccdef9a..fc66c8a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -229,14 +229,14 @@ static const struct icmp_control icmp_pointers[NR_ICMP_TYPES+1];
  *
  *	On SMP we have one ICMP socket per-cpu.
  */
-static DEFINE_PER_CPU(struct socket *, __icmp_socket) = NULL;
-#define icmp_socket	__get_cpu_var(__icmp_socket)
+static DEFINE_PER_CPU(struct sock *, __icmp_sock) = NULL;
+#define icmp_sock	__get_cpu_var(__icmp_sock)
 
 static __inline__ int icmp_xmit_lock(void)
 {
 	local_bh_disable();
 
-	if (unlikely(!spin_trylock(&icmp_socket->sk->sk_lock.slock))) {
+	if (unlikely(!spin_trylock(&icmp_sock->sk_lock.slock))) {
 		/* This can happen if the output path signals a
 		 * dst_link_failure() for an outgoing ICMP packet.
 		 */
@@ -248,7 +248,7 @@ static __inline__ int icmp_xmit_lock(void)
 
 static void icmp_xmit_unlock(void)
 {
-	spin_unlock_bh(&icmp_socket->sk->sk_lock.slock);
+	spin_unlock_bh(&icmp_sock->sk_lock.slock);
 }
 
 /*
@@ -347,17 +347,17 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 {
 	struct sk_buff *skb;
 
-	if (ip_append_data(icmp_socket->sk, icmp_glue_bits, icmp_param,
+	if (ip_append_data(icmp_sock, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
 			   ipc, rt, MSG_DONTWAIT) < 0)
-		ip_flush_pending_frames(icmp_socket->sk);
-	else if ((skb = skb_peek(&icmp_socket->sk->sk_write_queue)) != NULL) {
+		ip_flush_pending_frames(icmp_sock);
+	else if ((skb = skb_peek(&icmp_sock->sk_write_queue)) != NULL) {
 		struct icmphdr *icmph = icmp_hdr(skb);
 		__wsum csum = 0;
 		struct sk_buff *skb1;
 
-		skb_queue_walk(&icmp_socket->sk->sk_write_queue, skb1) {
+		skb_queue_walk(&icmp_sock->sk_write_queue, skb1) {
 			csum = csum_add(csum, skb1->csum);
 		}
 		csum = csum_partial_copy_nocheck((void *)&icmp_param->data,
@@ -365,7 +365,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 						 icmp_param->head_len, csum);
 		icmph->checksum = csum_fold(csum);
 		skb->ip_summed = CHECKSUM_NONE;
-		ip_push_pending_frames(icmp_socket->sk);
+		ip_push_pending_frames(icmp_sock);
 	}
 }
 
@@ -375,7 +375,7 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 
 static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 {
-	struct sock *sk = icmp_socket->sk;
+	struct sock *sk = icmp_sock;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipcm_cookie ipc;
 	struct rtable *rt = (struct rtable *)skb->dst;
@@ -542,7 +542,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	icmp_param.skb	  = skb_in;
 	icmp_param.offset = skb_network_offset(skb_in);
 	icmp_out_count(icmp_param.data.icmph.type);
-	inet_sk(icmp_socket->sk)->tos = tos;
+	inet_sk(icmp_sock)->tos = tos;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param.replyopts;
 
@@ -1140,22 +1140,25 @@ void __init icmp_init(struct net_proto_family *ops)
 
 	for_each_possible_cpu(i) {
 		int err;
+		struct socket *socket;
+		struct sock *sock;
 
 		err = sock_create_kern(PF_INET, SOCK_RAW, IPPROTO_ICMP,
-				       &per_cpu(__icmp_socket, i));
+				&socket);
 
 		if (err < 0)
 			panic("Failed to create the ICMP control socket.\n");
-
-		per_cpu(__icmp_socket, i)->sk->sk_allocation = GFP_ATOMIC;
+		sock = socket->sk;
+		per_cpu(__icmp_sock, i) = sock;
+		sock->sk_allocation = GFP_ATOMIC;
 
 		/* Enough space for 2 64K ICMP packets, including
 		 * sk_buff struct overhead.
 		 */
-		per_cpu(__icmp_socket, i)->sk->sk_sndbuf =
+		sock->sk_sndbuf =
 			(2 * ((64 * 1024) + sizeof(struct sk_buff)));
 
-		inet = inet_sk(per_cpu(__icmp_socket, i)->sk);
+		inet = inet_sk(sock);
 		inet->uc_ttl = -1;
 		inet->pmtudisc = IP_PMTUDISC_DONT;
 
@@ -1163,7 +1166,7 @@ void __init icmp_init(struct net_proto_family *ops)
 		 * see it, we do not wish this socket to see incoming
 		 * packets.
 		 */
-		per_cpu(__icmp_socket, i)->sk->sk_prot->unhash(per_cpu(__icmp_socket, i)->sk);
+		sock->sk_prot->unhash(sock);
 	}
 }
 

--------------020505090003050605010202--
