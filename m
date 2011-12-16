From: igorm@etf.rs
Subject: [PATCH 10/10 net-next] net: Enable ipv4 per interface statistics
Date: Fri, 16 Dec 2011 16:26:03 +0100
Message-ID: <1324049163-11207-11-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53877 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760036Ab1LPP0e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:34 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Added argument of type net_device* to macros IP_*_STATS and ICMP_*_STATS
In most places that was trivial - just added net_device* from
which we've read net*.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 net/bridge/br_netfilter.c       |    6 ++--
 net/dccp/ipv4.c                 |    9 ++++---
 net/ipv4/datagram.c             |    2 +-
 net/ipv4/icmp.c                 |   29 ++++++++++++++-----------
 net/ipv4/inet_connection_sock.c |    8 +++++-
 net/ipv4/ip_forward.c           |    8 ++++--
 net/ipv4/ip_fragment.c          |   43 +++++++++++++++++++++-----------------
 net/ipv4/ip_input.c             |   33 +++++++++++++++--------------
 net/ipv4/ip_output.c            |   43 +++++++++++++++++++++-----------------
 net/ipv4/ipmr.c                 |    6 +++-
 net/ipv4/ping.c                 |    8 +++---
 net/ipv4/raw.c                  |    4 +-
 net/ipv4/route.c                |    2 +-
 net/ipv4/tcp_ipv4.c             |    9 ++++---
 net/ipv4/udp.c                  |    7 +++--
 net/l2tp/l2tp_ip.c              |    6 ++--
 net/sctp/input.c                |    4 +-
 net/sctp/output.c               |    2 +-
 18 files changed, 127 insertions(+), 102 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 834dfab..a821217 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -255,13 +255,13 @@ static int br_parse_ip_options(struct sk_buff *skb)
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
 
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -286,7 +286,7 @@ static int br_parse_ip_options(struct sk_buff *skb)
 	return 0;
 
 inhdr_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INHDRERRORS);
 drop:
 	return -1;
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 1c67fe8..ca8a024 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -219,11 +219,12 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 	struct sock *sk;
 	__u64 seq;
 	int err;
-	struct net *net = dev_net(skb->dev);
+	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
 
 	if (skb->len < offset + sizeof(*dh) ||
 	    skb->len < offset + __dccp_basic_hdr_len(dh)) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INERRORS);
 		return;
 	}
 
@@ -231,7 +232,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 			iph->daddr, dh->dccph_dport,
 			iph->saddr, dh->dccph_sport, inet_iif(skb));
 	if (sk == NULL) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INERRORS);
 		return;
 	}
 
@@ -488,7 +489,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt)) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+		IP_INC_STATS_BH(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
 
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 424fafb..ca1d0ba 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -57,7 +57,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
-			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS_BH(sock_net(sk), NULL, IPSTATS_MIB_OUTNOROUTES);
 		goto out;
 	}
 
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index ab188ae..8a064db 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -264,10 +264,10 @@ out:
 /*
  *	Maintain the counters used in the SNMP statistics for outgoing ICMP
  */
-void icmp_out_count(struct net *net, unsigned char type)
+void icmp_out_count(struct net_device *dev, unsigned char type)
 {
-	ICMPMSGOUT_INC_STATS(net, type);
-	ICMP_INC_STATS(net, ICMP_MIB_OUTMSGS);
+	ICMPMSGOUT_INC_STATS(dev_net(dev), dev, type);
+	ICMP_INC_STATS(dev_net(dev), dev, ICMP_MIB_OUTMSGS);
 }
 
 /*
@@ -296,13 +296,14 @@ static void icmp_push_reply(struct icmp_bxm *icmp_param,
 {
 	struct sock *sk;
 	struct sk_buff *skb;
+	struct net_device *dev = (*rt)->dst.dev;
 
-	sk = icmp_sk(dev_net((*rt)->dst.dev));
+	sk = icmp_sk(dev_net(dev));
 	if (ip_append_data(sk, fl4, icmp_glue_bits, icmp_param,
 			   icmp_param->data_len+icmp_param->head_len,
 			   icmp_param->head_len,
 			   ipc, rt, MSG_DONTWAIT) < 0) {
-		ICMP_INC_STATS_BH(sock_net(sk), ICMP_MIB_OUTERRORS);
+		ICMP_INC_STATS_BH(sock_net(sk), dev, ICMP_MIB_OUTERRORS);
 		ip_flush_pending_frames(sk);
 	} else if ((skb = skb_peek(&sk->sk_write_queue)) != NULL) {
 		struct icmphdr *icmph = icmp_hdr(skb);
@@ -643,8 +644,9 @@ static void icmp_unreach(struct sk_buff *skb)
 	const struct net_protocol *ipprot;
 	u32 info = 0;
 	struct net *net;
+	struct net_device *dev = skb_dst(skb)->dev;
 
-	net = dev_net(skb_dst(skb)->dev);
+	net = dev_net(dev);
 
 	/*
 	 *	Incomplete header ?
@@ -747,7 +749,7 @@ static void icmp_unreach(struct sk_buff *skb)
 out:
 	return;
 out_err:
-	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INERRORS);
 	goto out;
 }
 
@@ -796,7 +798,7 @@ static void icmp_redirect(struct sk_buff *skb)
 out:
 	return;
 out_err:
-	ICMP_INC_STATS_BH(dev_net(skb->dev), ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(dev_net(skb->dev), skb->dev, ICMP_MIB_INERRORS);
 	goto out;
 }
 
@@ -867,7 +869,7 @@ static void icmp_timestamp(struct sk_buff *skb)
 out:
 	return;
 out_err:
-	ICMP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), skb_dst(skb)->dev, ICMP_MIB_INERRORS);
 	goto out;
 }
 
@@ -963,7 +965,8 @@ int icmp_rcv(struct sk_buff *skb)
 {
 	struct icmphdr *icmph;
 	struct rtable *rt = skb_rtable(skb);
-	struct net *net = dev_net(rt->dst.dev);
+	struct net_device *dev = rt->dst.dev;
+	struct net *net = dev_net(dev);
 
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
 		struct sec_path *sp = skb_sec_path(skb);
@@ -985,7 +988,7 @@ int icmp_rcv(struct sk_buff *skb)
 		skb_set_network_header(skb, nh);
 	}
 
-	ICMP_INC_STATS_BH(net, ICMP_MIB_INMSGS);
+	ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INMSGS);
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -1003,7 +1006,7 @@ int icmp_rcv(struct sk_buff *skb)
 
 	icmph = icmp_hdr(skb);
 
-	ICMPMSGIN_INC_STATS_BH(net, icmph->type);
+	ICMPMSGIN_INC_STATS_BH(net, dev, icmph->type);
 	/*
 	 *	18 is the highest 'known' ICMP type. Anything else is a mystery
 	 *
@@ -1044,7 +1047,7 @@ drop:
 	kfree_skb(skb);
 	return 0;
 error:
-	ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+	ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INERRORS);
 	goto drop;
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 2e4e244..f527d70 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -372,9 +372,11 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	return &rt->dst;
 
 route_err:
+	IP_INC_STATS_BH(net, rt->dst.dev, IPSTATS_MIB_OUTNOROUTES);
 	ip_rt_put(rt);
+	return NULL;
 no_route:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+	IP_INC_STATS_BH(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(inet_csk_route_req);
@@ -405,9 +407,11 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 	return &rt->dst;
 
 route_err:
+	IP_INC_STATS_BH(net, rt->dst.dev, IPSTATS_MIB_OUTNOROUTES);
 	ip_rt_put(rt);
+	return NULL;
 no_route:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+	IP_INC_STATS_BH(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(inet_csk_route_child_sock);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 29a07b6..f8ab57e 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -43,7 +43,8 @@ static int ip_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), skb_dst(skb)->dev,
+		IPSTATS_MIB_OUTFORWDATAGRAMS);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
@@ -89,7 +90,7 @@ int ip_forward(struct sk_buff *skb)
 
 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
-		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(rt->dst.dev), rt->dst.dev, IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(dst_mtu(&rt->dst)));
 		goto drop;
@@ -124,7 +125,8 @@ sr_failed:
 
 too_many_hops:
 	/* Tell the sender its packet died... */
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), skb_dst(skb)->dev,
+		IPSTATS_MIB_INHDRERRORS);
 	icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index fdaabf2..9aa00e1 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -209,13 +209,14 @@ static void ipq_kill(struct ipq *ipq)
 /* Memory limiting on fragments.  Evictor trashes the oldest
  * fragment queue until we are back under the threshold.
  */
-static void ip_evictor(struct net *net)
+static void ip_evictor(struct net_device *dev)
 {
 	int evicted;
+	struct net *net = dev_net(dev);
 
 	evicted = inet_frag_evictor(&net->ipv4.frags, &ip4_frags);
 	if (evicted)
-		IP_ADD_STATS_BH(net, IPSTATS_MIB_REASMFAILS, evicted);
+		IP_ADD_STATS_BH(net, dev, IPSTATS_MIB_REASMFAILS, evicted);
 }
 
 /*
@@ -225,6 +226,7 @@ static void ip_expire(unsigned long arg)
 {
 	struct ipq *qp;
 	struct net *net;
+	struct net_device *dev;
 
 	qp = container_of((struct inet_frag_queue *) arg, struct ipq, q);
 	net = container_of(qp->q.net, struct net, ipv4.frags);
@@ -235,19 +237,18 @@ static void ip_expire(unsigned long arg)
 		goto out;
 
 	ipq_kill(qp);
+	
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, qp->iif);
+	IP_INC_STATS_BH(net, dev, IPSTATS_MIB_REASMTIMEOUT);
+	IP_INC_STATS_BH(net, dev, IPSTATS_MIB_REASMFAILS);
 
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
-
-	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
+	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments && dev) {
 		struct sk_buff *head = qp->q.fragments;
 		const struct iphdr *iph;
 		int err;
 
-		rcu_read_lock();
-		head->dev = dev_get_by_index_rcu(net, qp->iif);
-		if (!head->dev)
-			goto out_rcu_unlock;
+		head->dev = dev;
 
 		/* skb dst is stale, drop it, and perform route lookup again */
 		skb_dst_drop(head);
@@ -269,9 +270,9 @@ static void ip_expire(unsigned long arg)
 
 		/* Send an ICMP "Fragment Reassembly Timeout" message. */
 		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
-out_rcu_unlock:
-		rcu_read_unlock();
 	}
+out_rcu_unlock:
+	rcu_read_unlock();
 out:
 	spin_unlock(&qp->q.lock);
 	ipq_put(qp);
@@ -325,7 +326,10 @@ static inline int ip_frag_too_far(struct ipq *qp)
 		struct net *net;
 
 		net = container_of(qp->q.net, struct net, ipv4.frags);
-		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
+		rcu_read_lock();
+		IP_INC_STATS_BH(net, dev_get_by_index_rcu(net, qp->iif),
+			IPSTATS_MIB_REASMFAILS);
+		rcu_read_unlock();
 	}
 
 	return rc;
@@ -631,7 +635,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	iph->frag_off = 0;
 	iph->tot_len = htons(len);
 	iph->tos |= ecn;
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
+	IP_INC_STATS_BH(net, dev, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	qp->q.fragments_tail = NULL;
 	return 0;
@@ -646,7 +650,7 @@ out_oversize:
 		printk(KERN_INFO "Oversized IP packet from %pI4.\n",
 			&qp->saddr);
 out_fail:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(net, dev, IPSTATS_MIB_REASMFAILS);
 	return err;
 }
 
@@ -655,13 +659,14 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 {
 	struct ipq *qp;
 	struct net *net;
+	struct net_device *dev = skb->dev ? skb->dev : skb_dst(skb)->dev;
 
-	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
+	net = dev_net(dev);
+	IP_INC_STATS_BH(net, dev, IPSTATS_MIB_REASMREQDS);
 
 	/* Start by cleaning up the memory. */
 	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
-		ip_evictor(net);
+		ip_evictor(dev);
 
 	/* Lookup (or create) queue header */
 	if ((qp = ip_find(net, ip_hdr(skb), user)) != NULL) {
@@ -676,7 +681,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 		return ret;
 	}
 
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(net, dev, IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -ENOMEM;
 }
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 073a9b0..53f5ba0 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -187,8 +187,9 @@ int ip_call_ra_chain(struct sk_buff *skb)
 
 static int ip_local_deliver_finish(struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb->dev);
-
+	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
+	
 	__skb_pull(skb, ip_hdrlen(skb));
 
 	/* Point into the IP datagram, just past the header. */
@@ -228,16 +229,16 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 				protocol = -ret;
 				goto resubmit;
 			}
-			IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
+			IP_INC_STATS_BH(net, dev, IPSTATS_MIB_INDELIVERS);
 		} else {
 			if (!raw) {
 				if (xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-					IP_INC_STATS_BH(net, IPSTATS_MIB_INUNKNOWNPROTOS);
+					IP_INC_STATS_BH(net, dev, IPSTATS_MIB_INUNKNOWNPROTOS);
 					icmp_send(skb, ICMP_DEST_UNREACH,
 						  ICMP_PROT_UNREACH, 0);
 				}
 			} else
-				IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
+				IP_INC_STATS_BH(net, dev, IPSTATS_MIB_INDELIVERS);
 			kfree_skb(skb);
 		}
 	}
@@ -279,7 +280,7 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 					      --ANK (980813)
 	*/
 	if (skb_cow(skb, skb_headroom(skb))) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -288,7 +289,7 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
 
 	if (ip_options_compile(dev_net(dev), opt, skb)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+		IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
@@ -328,10 +329,10 @@ static int ip_rcv_finish(struct sk_buff *skb)
 					       iph->tos, skb->dev);
 		if (unlikely(err)) {
 			if (err == -EHOSTUNREACH)
-				IP_INC_STATS_BH(dev_net(skb->dev),
+				IP_INC_STATS_BH(dev_net(skb->dev), skb->dev,
 						IPSTATS_MIB_INADDRERRORS);
 			else if (err == -ENETUNREACH)
-				IP_INC_STATS_BH(dev_net(skb->dev),
+				IP_INC_STATS_BH(dev_net(skb->dev), skb->dev,
 						IPSTATS_MIB_INNOROUTES);
 			else if (err == -EXDEV)
 				NET_INC_STATS_BH(dev_net(skb->dev),
@@ -356,10 +357,10 @@ static int ip_rcv_finish(struct sk_buff *skb)
 
 	rt = skb_rtable(skb);
 	if (rt->rt_type == RTN_MULTICAST) {
-		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INMCAST,
+		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), rt->dst.dev, IPSTATS_MIB_INMCAST,
 				skb->len);
 	} else if (rt->rt_type == RTN_BROADCAST)
-		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), IPSTATS_MIB_INBCAST,
+		IP_UPD_PO_STATS_BH(dev_net(rt->dst.dev), rt->dst.dev, IPSTATS_MIB_INBCAST,
 				skb->len);
 
 	return dst_input(skb);
@@ -384,10 +385,10 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		goto drop;
 
 
-	IP_UPD_PO_STATS_BH(dev_net(dev), IPSTATS_MIB_IN, skb->len);
+	IP_UPD_PO_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_IN, skb->len);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
 
@@ -420,7 +421,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
@@ -430,7 +431,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	 * Note this now means skb->len holds ntohs(iph->tot_len).
 	 */
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -444,7 +445,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		       ip_rcv_finish);
 
 inhdr_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(dev_net(dev), dev, IPSTATS_MIB_INHDRERRORS);
 drop:
 	kfree_skb(skb);
 out:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index ff302bd..994bbb5 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -186,9 +186,9 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	struct neighbour *neigh;
 
 	if (rt->rt_type == RTN_MULTICAST) {
-		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUTMCAST, skb->len);
+		IP_UPD_PO_STATS(dev_net(dev), dev, IPSTATS_MIB_OUTMCAST, skb->len);
 	} else if (rt->rt_type == RTN_BROADCAST)
-		IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUTBCAST, skb->len);
+		IP_UPD_PO_STATS(dev_net(dev), dev, IPSTATS_MIB_OUTBCAST, skb->len);
 
 	/* Be paranoid, rather than too clever. */
 	if (unlikely(skb_headroom(skb) < hh_len && dev->header_ops)) {
@@ -253,7 +253,7 @@ int ip_mc_output(struct sk_buff *skb)
 	/*
 	 *	If the indicated interface is up and running, send the packet.
 	 */
-	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+	IP_UPD_PO_STATS(dev_net(dev), dev, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -309,7 +309,7 @@ int ip_output(struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 
-	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+	IP_UPD_PO_STATS(dev_net(dev), dev, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -375,7 +375,7 @@ int ip_queue_xmit(struct sk_buff *skb, struct flowi *fl)
 					   RT_CONN_FLAGS(sk),
 					   sk->sk_bound_dev_if);
 		if (IS_ERR(rt))
-			goto no_route;
+			goto no_route_no_dev;
 		sk_setup_caps(sk, &rt->dst);
 	}
 	skb_dst_set_noref(skb, &rt->dst);
@@ -414,11 +414,16 @@ packet_routed:
 	rcu_read_unlock();
 	return res;
 
-no_route:
+out_err:
 	rcu_read_unlock();
-	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EHOSTUNREACH;
+no_route_no_dev:
+	IP_INC_STATS(sock_net(sk), NULL, IPSTATS_MIB_OUTNOROUTES);
+	goto out_err;
+no_route:
+	IP_INC_STATS(sock_net(sk), rt->dst.dev, IPSTATS_MIB_OUTNOROUTES);
+	goto out_err;
 }
 EXPORT_SYMBOL(ip_queue_xmit);
 
@@ -478,7 +483,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	iph = ip_hdr(skb);
 
 	if (unlikely((iph->frag_off & htons(IP_DF)) && !skb->local_df)) {
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(dev), dev, IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(ip_skb_dst_mtu(skb)));
 		kfree_skb(skb);
@@ -570,7 +575,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			err = output(skb);
 
 			if (!err)
-				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
+				IP_INC_STATS(dev_net(dev), dev, IPSTATS_MIB_FRAGCREATES);
 			if (err || !frag)
 				break;
 
@@ -580,7 +585,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		}
 
 		if (err == 0) {
-			IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
+			IP_INC_STATS(dev_net(dev), dev, IPSTATS_MIB_FRAGOKS);
 			return 0;
 		}
 
@@ -589,7 +594,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			kfree_skb(frag);
 			frag = skb;
 		}
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(dev_net(dev), dev, IPSTATS_MIB_FRAGFAILS);
 		return err;
 
 slow_path_clean:
@@ -708,15 +713,15 @@ slow_path:
 		if (err)
 			goto fail;
 
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
+		IP_INC_STATS(dev_net(dev), dev, IPSTATS_MIB_FRAGCREATES);
 	}
 	kfree_skb(skb);
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGOKS);
+	IP_INC_STATS(dev_net(dev), dev, IPSTATS_MIB_FRAGOKS);
 	return err;
 
 fail:
 	kfree_skb(skb);
-	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+	IP_INC_STATS(dev_net(dev), dev, IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
 EXPORT_SYMBOL(ip_fragment);
@@ -1049,7 +1054,7 @@ alloc_new_skb:
 
 error:
 	cork->length -= length;
-	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
+	IP_INC_STATS(sock_net(sk), rt->dst.dev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
@@ -1270,7 +1275,7 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 
 error:
 	cork->length -= size;
-	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTDISCARDS);
+	IP_INC_STATS(sock_net(sk), rt->dst.dev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
@@ -1295,7 +1300,6 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	struct sk_buff *skb, *tmp_skb;
 	struct sk_buff **tail_skb;
 	struct inet_sock *inet = inet_sk(sk);
-	struct net *net = sock_net(sk);
 	struct ip_options *opt = NULL;
 	struct rtable *rt = (struct rtable *)cork->dst;
 	struct iphdr *iph;
@@ -1368,7 +1372,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	skb_dst_set(skb, &rt->dst);
 
 	if (iph->protocol == IPPROTO_ICMP)
-		icmp_out_count(net, ((struct icmphdr *)
+		icmp_out_count(rt->dst.dev, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
 	ip_cork_release(cork);
@@ -1379,6 +1383,7 @@ out:
 int ip_send_skb(struct sk_buff *skb)
 {
 	struct net *net = sock_net(skb->sk);
+	struct net_device *dev = skb_dst(skb)->dev;
 	int err;
 
 	err = ip_local_out(skb);
@@ -1386,7 +1391,7 @@ int ip_send_skb(struct sk_buff *skb)
 		if (err > 0)
 			err = net_xmit_errno(err);
 		if (err)
-			IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
+			IP_INC_STATS(net, dev, IPSTATS_MIB_OUTDISCARDS);
 	}
 
 	return err;
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 8e54490..0aaa704 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1575,7 +1575,8 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options *opt = &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev),
+		skb_dst(skb)->dev, IPSTATS_MIB_OUTFORWDATAGRAMS);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
@@ -1637,7 +1638,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		 * to blackhole.
 		 */
 
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS_BH(dev_net(dev), dev,
+			IPSTATS_MIB_FRAGFAILS);
 		ip_rt_put(rt);
 		goto out_free;
 	}
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 43d4c3b..10504e8 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -567,7 +567,7 @@ static int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		err = PTR_ERR(rt);
 		rt = NULL;
 		if (err == -ENETUNREACH)
-			IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS_BH(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 		goto out;
 	}
 
@@ -602,13 +602,13 @@ back_from_confirm:
 	release_sock(sk);
 
 out:
-	ip_rt_put(rt);
 	if (free)
 		kfree(ipc.opt);
 	if (!err) {
-		icmp_out_count(sock_net(sk), user_icmph.type);
-		return len;
+		icmp_out_count(rt->dst.dev, user_icmph.type);
+		err = len;
 	}
+	ip_rt_put(rt);
 	return err;
 
 do_confirm:
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 3ccda5a..7c579c3 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -387,7 +387,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
 	}
 	if (iph->protocol == IPPROTO_ICMP)
-		icmp_out_count(net, ((struct icmphdr *)
+		icmp_out_count(rt->dst.dev, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, skb, NULL,
@@ -402,7 +402,7 @@ out:
 error_free:
 	kfree_skb(skb);
 error:
-	IP_INC_STATS(net, IPSTATS_MIB_OUTDISCARDS);
+	IP_INC_STATS(net, rt->dst.dev, IPSTATS_MIB_OUTDISCARDS);
 	if (err == -ENOBUFS && !inet->recverr)
 		err = 0;
 	return err;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f30112f..e9b1124 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1545,7 +1545,7 @@ static int ip_error(struct sk_buff *skb)
 	case ENETUNREACH:
 		code = ICMP_NET_UNREACH;
 		IP_INC_STATS_BH(dev_net(rt->dst.dev),
-				IPSTATS_MIB_INNOROUTES);
+				rt->dst.dev, IPSTATS_MIB_INNOROUTES);
 		break;
 	case EACCES:
 		code = ICMP_PKT_FILTERED;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1eb4ad5..8b99f21 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -183,7 +183,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 	if (IS_ERR(rt)) {
 		err = PTR_ERR(rt);
 		if (err == -ENETUNREACH)
-			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS_BH(sock_net(sk), NULL, IPSTATS_MIB_OUTNOROUTES);
 		return err;
 	}
 
@@ -359,17 +359,18 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 info)
 	__u32 seq;
 	__u32 remaining;
 	int err;
-	struct net *net = dev_net(icmp_skb->dev);
+	struct net_device *dev = icmp_skb->dev;
+	struct net *net = dev_net(dev);
 
 	if (icmp_skb->len < (iph->ihl << 2) + 8) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INERRORS);
 		return;
 	}
 
 	sk = inet_lookup(net, &tcp_hashinfo, iph->daddr, th->dest,
 			iph->saddr, th->source, inet_iif(icmp_skb));
 	if (!sk) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INERRORS);
 		return;
 	}
 	if (sk->sk_state == TCP_TIME_WAIT) {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d075b5..b4af9c0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -587,12 +587,13 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, struct udp_table *udptable)
 	struct sock *sk;
 	int harderr;
 	int err;
-	struct net *net = dev_net(skb->dev);
+	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
 
 	sk = __udp4_lib_lookup(net, iph->daddr, uh->dest,
 			iph->saddr, uh->source, skb->dev->ifindex, udptable);
 	if (sk == NULL) {
-		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(net, dev, ICMP_MIB_INERRORS);
 		return;	/* No socket for error */
 	}
 
@@ -937,7 +938,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			err = PTR_ERR(rt);
 			rt = NULL;
 			if (err == -ENETUNREACH)
-				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+				IP_INC_STATS_BH(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 			goto out;
 		}
 
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index d21e7eb..1620860 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -330,7 +330,7 @@ static int l2tp_ip_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len
 	if (IS_ERR(rt)) {
 		rc = PTR_ERR(rt);
 		if (rc == -ENETUNREACH)
-			IP_INC_STATS_BH(&init_net, IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS_BH(&init_net, NULL, IPSTATS_MIB_OUTNOROUTES);
 		goto out;
 	}
 
@@ -406,7 +406,7 @@ static int l2tp_ip_backlog_recv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 
 drop:
-	IP_INC_STATS(&init_net, IPSTATS_MIB_INDISCARDS);
+	IP_INC_STATS(&init_net, skb->dev, IPSTATS_MIB_INDISCARDS);
 	kfree_skb(skb);
 	return -1;
 }
@@ -532,7 +532,7 @@ out:
 
 no_route:
 	rcu_read_unlock();
-	IP_INC_STATS(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
+	IP_INC_STATS(sock_net(sk), NULL, IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	rc = -EHOSTUNREACH;
 	goto out;
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 80f71af..f86f811 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -576,7 +576,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	int err;
 
 	if (skb->len < ihlen + 8) {
-		ICMP_INC_STATS_BH(&init_net, ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(&init_net, skb->dev, ICMP_MIB_INERRORS);
 		return;
 	}
 
@@ -590,7 +590,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 	skb->network_header = saveip;
 	skb->transport_header = savesctp;
 	if (!sk) {
-		ICMP_INC_STATS_BH(&init_net, ICMP_MIB_INERRORS);
+		ICMP_INC_STATS_BH(&init_net, skb->dev, ICMP_MIB_INERRORS);
 		return;
 	}
 	/* Warning:  The sock lock is held.  Remember to call
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 08b3cea..7fb40d0 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -569,7 +569,7 @@ out:
 	return err;
 no_route:
 	kfree_skb(nskb);
-	IP_INC_STATS_BH(&init_net, IPSTATS_MIB_OUTNOROUTES);
+	IP_INC_STATS_BH(&init_net, NULL, IPSTATS_MIB_OUTNOROUTES);
 
 	/* FIXME: Returning the 'err' will effect all the associations
 	 * associated with a socket, although only one of the paths of the
-- 
1.7.5.4
