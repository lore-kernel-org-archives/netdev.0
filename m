From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 03/14] netns: add net parameter to IP6_INC_STATS
Date: Wed,  8 Oct 2008 15:51:51 +0400
Message-ID: <1223466722-8169-3-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17810 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbYJHLxr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:53:47 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h    |    3 +-
 net/ipv6/icmp.c       |    2 +-
 net/ipv6/ip6_output.c |   56 +++++++++++++++++++++++++++++-------------------
 net/ipv6/mcast.c      |   10 ++++----
 net/ipv6/ndisc.c      |    4 +-
 net/ipv6/netfilter.c  |    3 +-
 net/ipv6/raw.c        |    4 +-
 net/ipv6/reassembly.c |    8 +++---
 net/ipv6/route.c      |    7 ++++-
 9 files changed, 57 insertions(+), 40 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index dfa7ae3..26c1798 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -129,7 +129,8 @@ extern struct ctl_path net_ipv6_ctl_path[];
 /* MIBs */
 DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 
-#define IP6_INC_STATS(idev,field)	_DEVINC(ipv6, , idev, field)
+#define IP6_INC_STATS(net, idev,field)	({ (void)(net); \
+		_DEVINC(ipv6, , idev, field); })
 #define IP6_INC_STATS_BH(idev,field)	_DEVINC(ipv6, _BH, idev, field)
 #define IP6_ADD_STATS_BH(idev,field,val) _DEVADD(ipv6, _BH, idev, field, val)
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index b3157a0..758cdd7 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -183,7 +183,7 @@ static inline int icmpv6_xrlim_allow(struct sock *sk, int type,
 	 */
 	dst = ip6_route_output(net, sk, fl);
 	if (dst->error) {
-		IP6_INC_STATS(ip6_dst_idev(dst),
+		IP6_INC_STATS(net, ip6_dst_idev(dst),
 			      IPSTATS_MIB_OUTNOROUTES);
 	} else if (dst->dev && (dst->dev->flags&IFF_LOOPBACK)) {
 		res = 1;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index f22393e..db28c20 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -150,13 +150,14 @@ static int ip6_output2(struct sk_buff *skb)
 					ip6_dev_loopback_xmit);
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
-				IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
+				IP6_INC_STATS(dev_net(dev), idev,
+					      IPSTATS_MIB_OUTDISCARDS);
 				kfree_skb(skb);
 				return 0;
 			}
 		}
 
-		IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_INC_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCASTPKTS);
 	}
 
 	return NF_HOOK(PF_INET6, NF_INET_POST_ROUTING, skb, NULL, skb->dev,
@@ -175,7 +176,8 @@ int ip6_output(struct sk_buff *skb)
 {
 	struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 	if (unlikely(idev->cnf.disable_ipv6)) {
-		IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(dev_net(skb->dst->dev), idev,
+			      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 		return 0;
 	}
@@ -194,6 +196,7 @@ int ip6_output(struct sk_buff *skb)
 int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 	     struct ipv6_txoptions *opt, int ipfragok)
 {
+	struct net *net = sock_net(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *first_hop = &fl->fl6_dst;
 	struct dst_entry *dst = skb->dst;
@@ -216,7 +219,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 		if (skb_headroom(skb) < head_room) {
 			struct sk_buff *skb2 = skb_realloc_headroom(skb, head_room);
 			if (skb2 == NULL) {
-				IP6_INC_STATS(ip6_dst_idev(skb->dst),
+				IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 					      IPSTATS_MIB_OUTDISCARDS);
 				kfree_skb(skb);
 				return -ENOBUFS;
@@ -270,7 +273,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 
 	mtu = dst_mtu(dst);
 	if ((skb->len <= mtu) || skb->local_df || skb_is_gso(skb)) {
-		IP6_INC_STATS(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 			      IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
@@ -280,7 +283,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi *fl,
 		printk(KERN_DEBUG "IPv6: sending pkt_too_big to self\n");
 	skb->dev = dst->dev;
 	icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
-	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
+	IP6_INC_STATS(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return -EMSGSIZE;
 }
@@ -422,7 +425,7 @@ int ip6_forward(struct sk_buff *skb)
 		goto drop;
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
-		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -468,13 +471,14 @@ int ip6_forward(struct sk_buff *skb)
 		if (proxied > 0)
 			return ip6_input(skb);
 		else if (proxied < 0) {
-			IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
+			IP6_INC_STATS(net, ip6_dst_idev(dst),
+				      IPSTATS_MIB_INDISCARDS);
 			goto drop;
 		}
 	}
 
 	if (!xfrm6_route_forward(skb)) {
-		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 	dst = skb->dst;
@@ -530,7 +534,7 @@ int ip6_forward(struct sk_buff *skb)
 	}
 
 	if (skb_cow(skb, dst->dev->hard_header_len)) {
-		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTDISCARDS);
 		goto drop;
 	}
 
@@ -622,6 +626,7 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	__be32 frag_id = 0;
 	int ptr, offset = 0, err=0;
 	u8 *prevhdr, nexthdr = 0;
+	struct net *net = dev_net(skb->dst->dev);
 
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
@@ -635,7 +640,8 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 	if (!skb->local_df) {
 		skb->dev = skb->dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, skb->dev);
-		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
+		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
@@ -684,7 +690,8 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		*prevhdr = NEXTHDR_FRAGMENT;
 		tmp_hdr = kmemdup(skb_network_header(skb), hlen, GFP_ATOMIC);
 		if (!tmp_hdr) {
-			IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGFAILS);
+			IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+				      IPSTATS_MIB_FRAGFAILS);
 			return -ENOMEM;
 		}
 
@@ -735,7 +742,8 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 
 			err = output(skb);
 			if(!err)
-				IP6_INC_STATS(ip6_dst_idev(&rt->u.dst), IPSTATS_MIB_FRAGCREATES);
+				IP6_INC_STATS(net, ip6_dst_idev(&rt->u.dst),
+					      IPSTATS_MIB_FRAGCREATES);
 
 			if (err || !frag)
 				break;
@@ -748,7 +756,8 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 		kfree(tmp_hdr);
 
 		if (err == 0) {
-			IP6_INC_STATS(ip6_dst_idev(&rt->u.dst), IPSTATS_MIB_FRAGOKS);
+			IP6_INC_STATS(net, ip6_dst_idev(&rt->u.dst),
+				      IPSTATS_MIB_FRAGOKS);
 			dst_release(&rt->u.dst);
 			return 0;
 		}
@@ -759,7 +768,8 @@ static int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 			frag = skb;
 		}
 
-		IP6_INC_STATS(ip6_dst_idev(&rt->u.dst), IPSTATS_MIB_FRAGFAILS);
+		IP6_INC_STATS(net, ip6_dst_idev(&rt->u.dst),
+			      IPSTATS_MIB_FRAGFAILS);
 		dst_release(&rt->u.dst);
 		return err;
 	}
@@ -793,7 +803,7 @@ slow_path:
 
 		if ((frag = alloc_skb(len+hlen+sizeof(struct frag_hdr)+LL_ALLOCATED_SPACE(rt->u.dst.dev), GFP_ATOMIC)) == NULL) {
 			NETDEBUG(KERN_INFO "IPv6: frag: no memory for new fragment!\n");
-			IP6_INC_STATS(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 				      IPSTATS_MIB_FRAGFAILS);
 			err = -ENOMEM;
 			goto fail;
@@ -857,15 +867,16 @@ slow_path:
 		if (err)
 			goto fail;
 
-		IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_FRAGCREATES);
+		IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
+			      IPSTATS_MIB_FRAGCREATES);
 	}
-	IP6_INC_STATS(ip6_dst_idev(skb->dst),
+	IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 		      IPSTATS_MIB_FRAGOKS);
 	kfree_skb(skb);
 	return err;
 
 fail:
-	IP6_INC_STATS(ip6_dst_idev(skb->dst),
+	IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 		      IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return err;
@@ -1385,7 +1396,7 @@ alloc_new_skb:
 	return 0;
 error:
 	inet->cork.length -= length;
-	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
+	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
@@ -1409,6 +1420,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	struct in6_addr final_dst_buf, *final_dst = &final_dst_buf;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ipv6hdr *hdr;
 	struct ipv6_txoptions *opt = np->cork.opt;
 	struct rt6_info *rt = (struct rt6_info *)inet->cork.dst;
@@ -1462,7 +1474,7 @@ int ip6_push_pending_frames(struct sock *sk)
 	skb->mark = sk->sk_mark;
 
 	skb->dst = dst_clone(&rt->u.dst);
-	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
 	if (proto == IPPROTO_ICMPV6) {
 		struct inet6_dev *idev = ip6_dst_idev(skb->dst);
 
@@ -1491,7 +1503,7 @@ void ip6_flush_pending_frames(struct sock *sk)
 
 	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
 		if (skb->dst)
-			IP6_INC_STATS(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS(sock_net(sk), ip6_dst_idev(skb->dst),
 				      IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 	}
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index e7c03bc..a1d588d 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1446,7 +1446,7 @@ static void mld_sendpack(struct sk_buff *skb)
 	int err;
 	struct flowi fl;
 
-	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
 	payload_len = (skb->tail - skb->network_header) - sizeof(*pip6);
 	mldlen = skb->tail - skb->transport_header;
 	pip6->payload_len = htons(payload_len);
@@ -1771,7 +1771,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	struct flowi fl;
 
 	rcu_read_lock();
-	IP6_INC_STATS(__in6_dev_get(dev),
+	IP6_INC_STATS(net, __in6_dev_get(dev),
 		      IPSTATS_MIB_OUTREQUESTS);
 	rcu_read_unlock();
 	if (type == ICMPV6_MGM_REDUCTION)
@@ -1787,7 +1787,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	if (skb == NULL) {
 		rcu_read_lock();
-		IP6_INC_STATS(__in6_dev_get(dev),
+		IP6_INC_STATS(net, __in6_dev_get(dev),
 			      IPSTATS_MIB_OUTDISCARDS);
 		rcu_read_unlock();
 		return;
@@ -1841,9 +1841,9 @@ out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(idev, type);
 		ICMP6_INC_STATS(idev, ICMP6_MIB_OUTMSGS);
-		IP6_INC_STATS(idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
-		IP6_INC_STATS(idev, IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index f1c62ba..ce5b617 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -516,7 +516,7 @@ static void __ndisc_send(struct net_device *dev,
 	skb->dst = dst;
 
 	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
 
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
 		      dst_output);
@@ -1581,7 +1581,7 @@ void ndisc_send_redirect(struct sk_buff *skb, struct neighbour *neigh,
 
 	buff->dst = dst;
 	idev = in6_dev_get(dst->dev);
-	IP6_INC_STATS(idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 8c6c5e7..5391ac0 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -33,7 +33,8 @@ int ip6_route_me_harder(struct sk_buff *skb)
 #endif
 
 	if (dst->error) {
-		IP6_INC_STATS(ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+		IP6_INC_STATS(&init_net, ip6_dst_idev(dst),
+			      IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
 		dst_release(dst);
 		return -EINVAL;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e53e493..2ba04d4 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -638,7 +638,7 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 	if (err)
 		goto error_fault;
 
-	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
+	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTREQUESTS);
 	err = NF_HOOK(PF_INET6, NF_INET_LOCAL_OUT, skb, NULL, rt->u.dst.dev,
 		      dst_output);
 	if (err > 0)
@@ -652,7 +652,7 @@ error_fault:
 	err = -EFAULT;
 	kfree_skb(skb);
 error:
-	IP6_INC_STATS(rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
+	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index f4f62f0..6364407 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -433,7 +433,8 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	return -1;
 
 err:
-	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS(dev_net(skb->dst->dev), ip6_dst_idev(skb->dst),
+		      IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 }
@@ -573,7 +574,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
-	struct net *net;
+	struct net *net = dev_net(skb->dst->dev);
 
 	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMREQDS);
 
@@ -597,7 +598,6 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	net = dev_net(skb->dev);
 	if (atomic_read(&net->ipv6.frags.mem) > net->ipv6.frags.high_thresh)
 		ip6_evictor(net, ip6_dst_idev(skb->dst));
 
@@ -619,7 +619,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	return -1;
 
 fail_hdr:
-	IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
 	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb_network_header_len(skb));
 	return -1;
 }
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e10a170..89dc699 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1833,16 +1833,19 @@ int ipv6_route_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 static int ip6_pkt_drop(struct sk_buff *skb, int code, int ipstats_mib_noroutes)
 {
 	int type;
+	struct dst_entry *dst = skb->dst;
 	switch (ipstats_mib_noroutes) {
 	case IPSTATS_MIB_INNOROUTES:
 		type = ipv6_addr_type(&ipv6_hdr(skb)->daddr);
 		if (type == IPV6_ADDR_ANY || type == IPV6_ADDR_RESERVED) {
-			IP6_INC_STATS(ip6_dst_idev(skb->dst), IPSTATS_MIB_INADDRERRORS);
+			IP6_INC_STATS(dev_net(dst->dev), ip6_dst_idev(dst),
+				      IPSTATS_MIB_INADDRERRORS);
 			break;
 		}
 		/* FALLTHROUGH */
 	case IPSTATS_MIB_OUTNOROUTES:
-		IP6_INC_STATS(ip6_dst_idev(skb->dst), ipstats_mib_noroutes);
+		IP6_INC_STATS(dev_net(dst->dev), ip6_dst_idev(dst),
+			      ipstats_mib_noroutes);
 		break;
 	}
 	icmpv6_send(skb, ICMPV6_DEST_UNREACH, code, 0, skb->dev);
-- 
1.5.3.rc5

