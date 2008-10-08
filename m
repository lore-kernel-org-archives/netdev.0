From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 04/14] ipv6: added net argument to IP6_INC_STATS_BH
Date: Wed,  8 Oct 2008 15:51:52 +0400
Message-ID: <1223466722-8169-4-git-send-email-den@openvz.org>
References: <1223466685.7184.13.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, dlezcano@fr.ibm.com,
	benjamin.thery@bull.net, xemul@openvz.org, yoshfuji@linux-ipv6.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9845 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754454AbYJHLyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:54:35 -0400
In-Reply-To: <1223466685.7184.13.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ipv6.h    |    3 ++-
 net/ipv6/exthdrs.c    |   42 ++++++++++++++++++++++++------------------
 net/ipv6/ip6_input.c  |   27 ++++++++++++++++-----------
 net/ipv6/ip6_output.c |   18 +++++++++++-------
 net/ipv6/mcast.c      |    4 ++--
 net/ipv6/reassembly.c |   26 +++++++++++++++-----------
 6 files changed, 70 insertions(+), 50 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 26c1798..e7732d3 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -131,7 +131,8 @@ DECLARE_SNMP_STAT(struct ipstats_mib, ipv6_statistics);
 
 #define IP6_INC_STATS(net, idev,field)	({ (void)(net); \
 		_DEVINC(ipv6, , idev, field); })
-#define IP6_INC_STATS_BH(idev,field)	_DEVINC(ipv6, _BH, idev, field)
+#define IP6_INC_STATS_BH(net, idev,field) ({ (void)(net); \
+		_DEVINC(ipv6, _BH, idev, field); })
 #define IP6_ADD_STATS_BH(idev,field,val) _DEVADD(ipv6, _BH, idev, field, val)
 
 DECLARE_SNMP_STAT(struct icmpv6_mib, icmpv6_statistics);
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 837c830..6bfffec 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -277,7 +277,7 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(dev_net(skb->dst->dev), ip6_dst_idev(skb->dst),
 				 IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -301,7 +301,8 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(dev_net(dst->dev),
+			 ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
 	dst_release(dst);
 	return -1;
 }
@@ -319,7 +320,8 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	int n, i;
 	struct ipv6_rt_hdr *hdr;
 	struct rt0_hdr *rthdr;
-	int accept_source_route = dev_net(skb->dev)->ipv6.devconf_all->accept_source_route;
+	struct net *net = dev_net(skb->dev);
+	int accept_source_route = net->ipv6.devconf_all->accept_source_route;
 
 	idev = in6_dev_get(skb->dev);
 	if (idev) {
@@ -331,7 +333,7 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 				 IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -341,7 +343,7 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 				 IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -356,7 +358,7 @@ looped_back:
 			 * processed by own
 			 */
 			if (!addr) {
-				IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+				IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 						 IPSTATS_MIB_INADDRERRORS);
 				kfree_skb(skb);
 				return -1;
@@ -382,7 +384,7 @@ looped_back:
 			goto unknown_rh;
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
-			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INHDRERRORS);
 			kfree_skb(skb);
 			return -1;
@@ -401,7 +403,7 @@ looped_back:
 	n = hdr->hdrlen >> 1;
 
 	if (hdr->segments_left > n) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((&hdr->segments_left) -
@@ -415,7 +417,7 @@ looped_back:
 	if (skb_cloned(skb)) {
 		/* the copy is a forwarded packet */
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_OUTDISCARDS);
 			kfree_skb(skb);
 			return -1;
@@ -438,13 +440,13 @@ looped_back:
 		if (xfrm6_input_addr(skb, (xfrm_address_t *)addr,
 				     (xfrm_address_t *)&ipv6_hdr(skb)->saddr,
 				     IPPROTO_ROUTING) < 0) {
-			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
 		if (!ipv6_chk_home_addr(dev_net(skb->dst->dev), addr)) {
-			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
@@ -456,7 +458,7 @@ looped_back:
 	}
 
 	if (ipv6_addr_is_multicast(addr)) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 				 IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
@@ -476,7 +478,7 @@ looped_back:
 
 	if (skb->dst->dev->flags&IFF_LOOPBACK) {
 		if (ipv6_hdr(skb)->hop_limit <= 1) {
-			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 				    0, skb->dev);
@@ -492,7 +494,7 @@ looped_back:
 	return -1;
 
 unknown_rh:
-	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_INHDRERRORS);
 	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 			  (&hdr->type) - skb_network_header(skb));
 	return -1;
@@ -579,29 +581,33 @@ static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 {
 	const unsigned char *nh = skb_network_header(skb);
 	u32 pkt_len;
+	struct net *net = dev_net(skb->dst->dev);
 
 	if (nh[optoff + 1] != 4 || (optoff & 3) != 2) {
 		LIMIT_NETDEBUG(KERN_DEBUG "ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
 			       nh[optoff+1]);
-		IP6_INC_STATS_BH(ipv6_skb_idev(skb),
+		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
 				 IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
 	pkt_len = ntohl(*(__be32 *)(nh + optoff + 2));
 	if (pkt_len <= IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(ipv6_skb_idev(skb), IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
+				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
 		return 0;
 	}
 	if (ipv6_hdr(skb)->payload_len) {
-		IP6_INC_STATS_BH(ipv6_skb_idev(skb), IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
+				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff);
 		return 0;
 	}
 
 	if (pkt_len > skb->len - sizeof(struct ipv6hdr)) {
-		IP6_INC_STATS_BH(ipv6_skb_idev(skb), IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
+				 IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	}
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 7e14ccc..936f489 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -59,6 +59,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	struct ipv6hdr *hdr;
 	u32 		pkt_len;
 	struct inet6_dev *idev;
+	struct net *net = dev_net(skb->dev);
 
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		kfree_skb(skb);
@@ -69,11 +70,11 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	idev = __in6_dev_get(skb->dev);
 
-	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INRECEIVES);
+	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INRECEIVES);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL ||
 	    !idev || unlikely(idev->cnf.disable_ipv6)) {
-		IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDISCARDS);
+		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDISCARDS);
 		rcu_read_unlock();
 		goto out;
 	}
@@ -118,11 +119,12 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* pkt_len may be zero if Jumbo payload option is present */
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
 		if (pkt_len + sizeof(struct ipv6hdr) > skb->len) {
-			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INTRUNCATEDPKTS);
+			IP6_INC_STATS_BH(net,
+					 idev, IPSTATS_MIB_INTRUNCATEDPKTS);
 			goto drop;
 		}
 		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr))) {
-			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
 			goto drop;
 		}
 		hdr = ipv6_hdr(skb);
@@ -130,7 +132,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
 		if (ipv6_parse_hopopts(skb) < 0) {
-			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
+			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
 			rcu_read_unlock();
 			return 0;
 		}
@@ -141,7 +143,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	return NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, dev, NULL,
 		       ip6_rcv_finish);
 err:
-	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INHDRERRORS);
+	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
 drop:
 	rcu_read_unlock();
 	kfree_skb(skb);
@@ -161,6 +163,7 @@ static int ip6_input_finish(struct sk_buff *skb)
 	int nexthdr, raw;
 	u8 hash;
 	struct inet6_dev *idev;
+	struct net *net = dev_net(skb->dst->dev);
 
 	/*
 	 *	Parse extension headers
@@ -205,24 +208,25 @@ resubmit:
 		if (ret > 0)
 			goto resubmit;
 		else if (ret == 0)
-			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDELIVERS);
+			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
 	} else {
 		if (!raw) {
 			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-				IP6_INC_STATS_BH(idev, IPSTATS_MIB_INUNKNOWNPROTOS);
+				IP6_INC_STATS_BH(net, idev,
+						 IPSTATS_MIB_INUNKNOWNPROTOS);
 				icmpv6_send(skb, ICMPV6_PARAMPROB,
 					    ICMPV6_UNK_NEXTHDR, nhoff,
 					    skb->dev);
 			}
 		} else
-			IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDELIVERS);
+			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
 		kfree_skb(skb);
 	}
 	rcu_read_unlock();
 	return 0;
 
 discard:
-	IP6_INC_STATS_BH(idev, IPSTATS_MIB_INDISCARDS);
+	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDISCARDS);
 	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
@@ -240,7 +244,8 @@ int ip6_mc_input(struct sk_buff *skb)
 	struct ipv6hdr *hdr;
 	int deliver;
 
-	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
+	IP6_INC_STATS_BH(dev_net(skb->dst->dev),
+			 ip6_dst_idev(skb->dst), IPSTATS_MIB_INMCASTPKTS);
 
 	hdr = ipv6_hdr(skb);
 	deliver = ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index db28c20..f0fded6 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -103,7 +103,8 @@ static int ip6_output_finish(struct sk_buff *skb)
 	else if (dst->neighbour)
 		return dst->neighbour->output(skb);
 
-	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+	IP6_INC_STATS_BH(dev_net(dst->dev),
+			 ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EINVAL;
 
@@ -458,7 +459,8 @@ int ip6_forward(struct sk_buff *skb)
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 			    0, skb->dev);
-		IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
+		IP6_INC_STATS_BH(net,
+				 ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
 
 		kfree_skb(skb);
 		return -ETIMEDOUT;
@@ -527,8 +529,10 @@ int ip6_forward(struct sk_buff *skb)
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, dst_mtu(dst), skb->dev);
-		IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INTOOBIGERRORS);
-		IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_FRAGFAILS);
+		IP6_INC_STATS_BH(net,
+				 ip6_dst_idev(dst), IPSTATS_MIB_INTOOBIGERRORS);
+		IP6_INC_STATS_BH(net,
+				 ip6_dst_idev(dst), IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
@@ -544,12 +548,12 @@ int ip6_forward(struct sk_buff *skb)
 
 	hdr->hop_limit--;
 
-	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
 	return NF_HOOK(PF_INET6, NF_INET_FORWARD, skb, skb->dev, dst->dev,
 		       ip6_forward_finish);
 
 error:
-	IP6_INC_STATS_BH(ip6_dst_idev(dst), IPSTATS_MIB_INADDRERRORS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_INADDRERRORS);
 drop:
 	kfree_skb(skb);
 	return -EINVAL;
@@ -991,7 +995,7 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 
 out_err_release:
 	if (err == -ENETUNREACH)
-		IP6_INC_STATS_BH(NULL, IPSTATS_MIB_OUTNOROUTES);
+		IP6_INC_STATS_BH(net, NULL, IPSTATS_MIB_OUTNOROUTES);
 	dst_release(*dst);
 	*dst = NULL;
 	return err;
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index a1d588d..88811eb 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1476,9 +1476,9 @@ out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS_BH(idev, ICMPV6_MLD2_REPORT);
 		ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
-		IP6_INC_STATS_BH(idev, IPSTATS_MIB_OUTMCASTPKTS);
+		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTMCASTPKTS);
 	} else
-		IP6_INC_STATS_BH(idev, IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_OUTDISCARDS);
 
 	if (likely(idev != NULL))
 		in6_dev_put(idev);
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index 6364407..693d208 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -213,8 +213,8 @@ static void ip6_frag_expire(unsigned long data)
 		goto out;
 
 	rcu_read_lock();
-	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
-	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
+	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 	rcu_read_unlock();
 
 	/* Don't send error if the first segment did not arrive. */
@@ -257,7 +257,7 @@ fq_find(struct net *net, __be32 id, struct in6_addr *src, struct in6_addr *dst,
 	return container_of(q, struct frag_queue, q);
 
 oom:
-	IP6_INC_STATS_BH(idev, IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_REASMFAILS);
 	return NULL;
 }
 
@@ -267,6 +267,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
 	int offset, end;
+	struct net *net = dev_net(skb->dst->dev);
 
 	if (fq->q.last_in & INET_FRAG_COMPLETE)
 		goto err;
@@ -276,7 +277,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			((u8 *)(fhdr + 1) - (u8 *)(ipv6_hdr(skb) + 1)));
 
 	if ((unsigned int)end > IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+		IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 				 IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((u8 *)&fhdr->frag_off -
@@ -309,7 +310,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			/* RFC2460 says always send parameter problem in
 			 * this case. -DaveM
 			 */
-			IP6_INC_STATS_BH(ip6_dst_idev(skb->dst),
+			IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst),
 					 IPSTATS_MIB_INHDRERRORS);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 					  offsetof(struct ipv6hdr, payload_len));
@@ -433,7 +434,7 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 	return -1;
 
 err:
-	IP6_INC_STATS(dev_net(skb->dst->dev), ip6_dst_idev(skb->dst),
+	IP6_INC_STATS(net, ip6_dst_idev(skb->dst),
 		      IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
@@ -550,7 +551,8 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 					  head->csum);
 
 	rcu_read_lock();
-	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
+	IP6_INC_STATS_BH(dev_net(dev),
+			 __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
 	rcu_read_unlock();
 	fq->q.fragments = NULL;
 	return 1;
@@ -564,7 +566,8 @@ out_oom:
 		printk(KERN_DEBUG "ip6_frag_reasm: no memory for reassembly\n");
 out_fail:
 	rcu_read_lock();
-	IP6_INC_STATS_BH(__in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(dev_net(dev),
+			 __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 	rcu_read_unlock();
 	return -1;
 }
@@ -576,7 +579,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
 	struct net *net = dev_net(skb->dst->dev);
 
-	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMREQDS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
 	if (hdr->payload_len==0)
@@ -592,7 +595,8 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	if (!(fhdr->frag_off & htons(0xFFF9))) {
 		/* It is not a fragmented frame */
 		skb->transport_header += sizeof(struct frag_hdr);
-		IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMOKS);
+		IP6_INC_STATS_BH(net,
+				 ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMOKS);
 
 		IP6CB(skb)->nhoff = (u8 *)fhdr - skb_network_header(skb);
 		return 1;
@@ -614,7 +618,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return ret;
 	}
 
-	IP6_INC_STATS_BH(ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
+	IP6_INC_STATS_BH(net, ip6_dst_idev(skb->dst), IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 
-- 
1.5.3.rc5

