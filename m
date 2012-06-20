From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Wed, 20 Jun 2012 03:15:43 -0700 (PDT)
Message-ID: <20120620.031543.1511134879638711616.davem@davemloft.net>
References: <20120619.214657.1345825814176201681.davem@davemloft.net>
	<1340171940.4604.799.camel@edumazet-glaptop>
	<20120619.231412.1236237191660427779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970Ab2FTKPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 06:15:44 -0400
In-Reply-To: <20120619.231412.1236237191660427779.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 19 Jun 2012 23:14:12 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 20 Jun 2012 07:59:00 +0200
> 
>> On Tue, 2012-06-19 at 21:46 -0700, David Miller wrote:
>> 
>>> These numbers can be decreased further, because since we're already
>>> looking at the TCP header we can pre-cook the TCP control block in the
>>> SKB and skip much of the stuff that tcp_v4_rcv() does since we've done
>>> it already in the early demux code.
>> 
>> It could be done at GRO level and remove one another demux.
>> 
>> As routers probably have no use of GRO, no need of additional knob.
> 
> That's a great idea.

Here's what I have so far, the ipv6 implementation we get nearly for
free :-)

Initially I tried to use ->gro_complete() for this as it was more
natural, but we abort before we get there for a lot of cases where we
want to use the early demux and cached route (ACKs, FINs, sub-mss
sized packets, etc.)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 967b926..a1b1b53 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -37,7 +37,6 @@
 
 /* This is used to register protocols. */
 struct net_protocol {
-	int			(*early_demux)(struct sk_buff *skb);
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
 	int			(*gso_send_check)(struct sk_buff *skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5b21522..c1b5626 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2956,6 +2956,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		return -ENOMEM;
 
 	__copy_skb_header(nskb, p);
+	if (p->sk) {
+		nskb->sk = p->sk;
+		nskb->destructor = p->destructor;
+		p->sk = NULL;
+		p->destructor = NULL;
+	}
 	nskb->mac_len = p->mac_len;
 
 	skb_reserve(nskb, headroom);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 07a02f6..0aabad7 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1519,7 +1519,6 @@ static const struct net_protocol igmp_protocol = {
 #endif
 
 static const struct net_protocol tcp_protocol = {
-	.early_demux	=	tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
 	.err_handler	=	tcp_v4_err,
 	.gso_send_check	=	tcp_v4_gso_send_check,
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 93b092c..c4fe1d2 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -323,32 +323,19 @@ static int ip_rcv_finish(struct sk_buff *skb)
 	 *	how the packet travels inside Linux networking.
 	 */
 	if (skb_dst(skb) == NULL) {
-		const struct net_protocol *ipprot;
-		int protocol = iph->protocol;
-		int err;
-
-		rcu_read_lock();
-		ipprot = rcu_dereference(inet_protos[protocol]);
-		err = -ENOENT;
-		if (ipprot && ipprot->early_demux)
-			err = ipprot->early_demux(skb);
-		rcu_read_unlock();
-
-		if (err) {
-			err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-						   iph->tos, skb->dev);
-			if (unlikely(err)) {
-				if (err == -EHOSTUNREACH)
-					IP_INC_STATS_BH(dev_net(skb->dev),
-							IPSTATS_MIB_INADDRERRORS);
-				else if (err == -ENETUNREACH)
-					IP_INC_STATS_BH(dev_net(skb->dev),
-							IPSTATS_MIB_INNOROUTES);
-				else if (err == -EXDEV)
-					NET_INC_STATS_BH(dev_net(skb->dev),
-							 LINUX_MIB_IPRPFILTER);
-				goto drop;
-			}
+		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
+					       iph->tos, skb->dev);
+		if (unlikely(err)) {
+			if (err == -EHOSTUNREACH)
+				IP_INC_STATS_BH(dev_net(skb->dev),
+						IPSTATS_MIB_INADDRERRORS);
+			else if (err == -ENETUNREACH)
+				IP_INC_STATS_BH(dev_net(skb->dev),
+						IPSTATS_MIB_INNOROUTES);
+			else if (err == -EXDEV)
+				NET_INC_STATS_BH(dev_net(skb->dev),
+						 LINUX_MIB_IPRPFILTER);
+			goto drop;
 		}
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 13857df..2a483ad 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1671,52 +1671,6 @@ csum_err:
 }
 EXPORT_SYMBOL(tcp_v4_do_rcv);
 
-int tcp_v4_early_demux(struct sk_buff *skb)
-{
-	struct net *net = dev_net(skb->dev);
-	const struct iphdr *iph;
-	const struct tcphdr *th;
-	struct sock *sk;
-	int err;
-
-	err = -ENOENT;
-	if (skb->pkt_type != PACKET_HOST)
-		goto out_err;
-
-	if (!pskb_may_pull(skb, ip_hdrlen(skb) + sizeof(struct tcphdr)))
-		goto out_err;
-
-	iph = ip_hdr(skb);
-	th = (struct tcphdr *) ((char *)iph + ip_hdrlen(skb));
-
-	if (th->doff < sizeof(struct tcphdr) / 4)
-		goto out_err;
-
-	if (!pskb_may_pull(skb, ip_hdrlen(skb) + th->doff * 4))
-		goto out_err;
-
-	sk = __inet_lookup_established(net, &tcp_hashinfo,
-				       iph->saddr, th->source,
-				       iph->daddr, th->dest,
-				       skb->dev->ifindex);
-	if (sk) {
-		skb->sk = sk;
-		skb->destructor = sock_edemux;
-		if (sk->sk_state != TCP_TIME_WAIT) {
-			struct dst_entry *dst = sk->sk_rx_dst;
-			if (dst)
-				dst = dst_check(dst, 0);
-			if (dst) {
-				skb_dst_set_noref(skb, dst);
-				err = 0;
-			}
-		}
-	}
-
-out_err:
-	return err;
-}
-
 /*
  *	From tcp_input.c
  */
@@ -2576,6 +2530,7 @@ void tcp4_proc_exit(void)
 struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	const struct iphdr *iph = skb_gro_network_header(skb);
+	struct sk_buff **pp;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -2591,7 +2546,36 @@ struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 		return NULL;
 	}
 
-	return tcp_gro_receive(head, skb);
+	pp = tcp_gro_receive(head, skb);
+
+	if (!NAPI_GRO_CB(skb)->same_flow) {
+		const struct tcphdr *th = tcp_hdr(skb);
+		struct net_device *dev = skb->dev;
+		struct sock *sk;
+
+		sk = __inet_lookup_established(dev_net(dev), &tcp_hashinfo,
+					       iph->saddr, th->source,
+					       iph->daddr, th->dest,
+					       dev->ifindex);
+		if (sk) {
+			skb_orphan(skb);
+			skb->sk = sk;
+			skb->destructor = sock_edemux;
+			if (!skb_dst(skb) &&
+			    sk->sk_state != TCP_TIME_WAIT) {
+				struct dst_entry *dst = sk->sk_rx_dst;
+				if (dst)
+					dst = dst_check(dst, 0);
+				if (dst) {
+					struct rtable *rt = (struct rtable *) dst;
+
+					if (rt->rt_iif == dev->ifindex)
+						skb_dst_set_noref(skb, dst);
+				}
+			}
+		}
+	}
+	return pp;
 }
 
 int tcp4_gro_complete(struct sk_buff *skb)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 26a8862..b8ea463 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -797,6 +797,7 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
 	const struct ipv6hdr *iph = skb_gro_network_header(skb);
+	struct sk_buff **pp;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -812,7 +813,32 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 		return NULL;
 	}
 
-	return tcp_gro_receive(head, skb);
+	pp = tcp_gro_receive(head, skb);
+
+	if (!NAPI_GRO_CB(skb)->same_flow) {
+		const struct tcphdr *th = tcp_hdr(skb);
+		struct net_device *dev = skb->dev;
+		struct sock *sk;
+
+		sk = __inet6_lookup_established(dev_net(dev), &tcp_hashinfo,
+						&iph->saddr, th->source,
+						&iph->daddr, th->dest,
+						dev->ifindex);
+		if (sk) {
+			skb_orphan(skb);
+			skb->sk = sk;
+			skb->destructor = sock_edemux;
+			if (!skb_dst(skb) &&
+			    sk->sk_state != TCP_TIME_WAIT) {
+				struct dst_entry *dst = sk->sk_rx_dst;
+				if (dst)
+					dst = dst_check(dst, 0);
+				if (dst)
+					skb_dst_set(skb, dst);
+			}
+		}
+	}
+	return pp;
 }
 
 static int tcp6_gro_complete(struct sk_buff *skb)
