From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Early TCP socket demux.
Date: Mon, 18 Jun 2012 19:40:16 -0700 (PDT)
Message-ID: <20120618.194016.2282814982594761206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136Ab2FSCkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 22:40:19 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 0EA4558624B
	for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 19:40:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You know you want it.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 875f489..6c47bf8 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -34,6 +34,7 @@
 
 /* This is used to register protocols. */
 struct net_protocol {
+	int			(*early_demux)(struct sk_buff *skb);
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			(*gso_send_check)(struct sk_buff *skb);
diff --git a/include/net/sock.h b/include/net/sock.h
index 4a45216..87b424a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -319,6 +319,7 @@ struct sock {
 	unsigned long 		sk_flags;
 	struct dst_entry	*sk_dst_cache;
 	spinlock_t		sk_dst_lock;
+	struct dst_entry	*sk_rx_dst;
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
 	int			sk_sndbuf;
@@ -1426,6 +1427,7 @@ extern struct sk_buff		*sock_rmalloc(struct sock *sk,
 					      gfp_t priority);
 extern void			sock_wfree(struct sk_buff *skb);
 extern void			sock_rfree(struct sk_buff *skb);
+extern void			sock_edemux(struct sk_buff *skb);
 
 extern int			sock_setsockopt(struct socket *sock, int level,
 						int op, char __user *optval,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 9332f34..6660ffc 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -325,6 +325,7 @@ extern void tcp_v4_err(struct sk_buff *skb, u32);
 
 extern void tcp_shutdown (struct sock *sk, int how);
 
+extern int tcp_v4_early_demux(struct sk_buff *skb);
 extern int tcp_v4_rcv(struct sk_buff *skb);
 
 extern struct inet_peer *tcp_v4_get_peer(struct sock *sk);
diff --git a/net/core/sock.c b/net/core/sock.c
index 9e5b71f..929bdcc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1465,6 +1465,11 @@ void sock_rfree(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_rfree);
 
+void sock_edemux(struct sk_buff *skb)
+{
+	sock_put(skb->sk);
+}
+EXPORT_SYMBOL(sock_edemux);
 
 int sock_i_uid(struct sock *sk)
 {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e4e8e00..a2bd2d2 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -157,6 +157,7 @@ void inet_sock_destruct(struct sock *sk)
 
 	kfree(rcu_dereference_protected(inet->inet_opt, 1));
 	dst_release(rcu_dereference_check(sk->sk_dst_cache, 1));
+	dst_release(sk->sk_rx_dst);
 	sk_refcnt_debug_dec(sk);
 }
 EXPORT_SYMBOL(inet_sock_destruct);
@@ -1520,14 +1521,15 @@ static const struct net_protocol igmp_protocol = {
 #endif
 
 static const struct net_protocol tcp_protocol = {
-	.handler =	tcp_v4_rcv,
-	.err_handler =	tcp_v4_err,
-	.gso_send_check = tcp_v4_gso_send_check,
-	.gso_segment =	tcp_tso_segment,
-	.gro_receive =	tcp4_gro_receive,
-	.gro_complete =	tcp4_gro_complete,
-	.no_policy =	1,
-	.netns_ok =	1,
+	.early_demux	=	tcp_v4_early_demux,
+	.handler	=	tcp_v4_rcv,
+	.err_handler	=	tcp_v4_err,
+	.gso_send_check	=	tcp_v4_gso_send_check,
+	.gso_segment	=	tcp_tso_segment,
+	.gro_receive	=	tcp4_gro_receive,
+	.gro_complete	=	tcp4_gro_complete,
+	.no_policy	=	1,
+	.netns_ok	=	1,
 };
 
 static const struct net_protocol udp_protocol = {
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 8590144..cb883e1 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -324,19 +324,34 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 *	how the packet travels inside Linux networking.
 	 */
 	if (skb_dst(skb) == NULL) {
-		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					       iph->tos, skb->dev);
-		if (unlikely(err)) {
-			if (err == -EHOSTUNREACH)
-				IP_INC_STATS_BH(dev_net(skb->dev),
-						IPSTATS_MIB_INADDRERRORS);
-			else if (err == -ENETUNREACH)
-				IP_INC_STATS_BH(dev_net(skb->dev),
-						IPSTATS_MIB_INNOROUTES);
-			else if (err == -EXDEV)
-				NET_INC_STATS_BH(dev_net(skb->dev),
-						 LINUX_MIB_IPRPFILTER);
-			goto drop;
+		const struct net_protocol *ipprot;
+		int protocol = iph->protocol;
+		int hash, err;
+
+		hash = protocol & (MAX_INET_PROTOS - 1);
+
+		rcu_read_lock();
+		ipprot = rcu_dereference(inet_protos[hash]);
+		err = -ENOENT;
+		if (ipprot && ipprot->early_demux)
+			err = ipprot->early_demux(skb);
+		rcu_read_unlock();
+
+		if (err) {
+			err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
+						   iph->tos, skb->dev);
+			if (unlikely(err)) {
+				if (err == -EHOSTUNREACH)
+					IP_INC_STATS_BH(dev_net(skb->dev),
+							IPSTATS_MIB_INADDRERRORS);
+				else if (err == -ENETUNREACH)
+					IP_INC_STATS_BH(dev_net(skb->dev),
+							IPSTATS_MIB_INNOROUTES);
+				else if (err == -EXDEV)
+					NET_INC_STATS_BH(dev_net(skb->dev),
+							 LINUX_MIB_IPRPFILTER);
+				goto drop;
+			}
 		}
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index fda2ca1..bd90181 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1671,6 +1671,50 @@ csum_err:
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
 
+int tcp_v4_early_demux(struct sk_buff *skb)
+{
+	struct net *net = dev_net(skb->dev);
+	const struct iphdr *iph;
+	const struct tcphdr *th;
+	struct sock *sk;
+	int err;
+
+	err = -ENOENT;
+	if (skb->pkt_type != PACKET_HOST)
+		goto out_err;
+
+	if (!pskb_may_pull(skb, ip_hdrlen(skb) + sizeof(struct tcphdr)))
+		goto out_err;
+
+	iph = ip_hdr(skb);
+	th = (struct tcphdr *) ((char *)iph + ip_hdrlen(skb));
+
+	if (th->doff < sizeof(struct tcphdr) / 4)
+		goto out_err;
+
+	if (!pskb_may_pull(skb, ip_hdrlen(skb) + th->doff * 4))
+		goto out_err;
+
+	sk = __inet_lookup_established(net, &tcp_hashinfo,
+				       iph->saddr, th->source,
+				       iph->daddr, th->dest,
+				       skb->dev->ifindex);
+	if (sk) {
+		skb->sk = sk;
+		skb->destructor = sock_edemux;
+		if (sk->sk_state != TCP_TIME_WAIT) {
+			struct dst_entry *dst = sk->sk_rx_dst;
+			if (dst) {
+				skb_dst_set_noref(skb, dst);
+				err = 0;
+			}
+		}
+	}
+
+out_err:
+	return err;
+}
+
 /*
  *	From tcp_input.c
  */
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index cb01531..72b7c63 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -445,6 +445,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		struct tcp_sock *oldtp = tcp_sk(sk);
 		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
 
+		newsk->sk_rx_dst = dst_clone(skb_dst(skb));
+
 		/* TCP Cookie Transactions require space for the cookie pair,
 		 * as it differs for each connection.  There is no need to
 		 * copy any s_data_payload stored at the original socket.
