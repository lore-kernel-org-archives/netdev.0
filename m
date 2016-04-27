From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 14/17] ipv6: rename IP6_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:40 -0700
Message-ID: <1461800683-25034-15-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33141 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153AbcD0XpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:25 -0400
Received: by mail-pa0-f52.google.com with SMTP id zm5so27876271pac.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:25 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename IP6_INC_STATS_BH() to __IP6_INC_STATS()
and IP6_ADD_STATS_BH() to __IP6_ADD_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h             |  4 +--
 net/bridge/br_netfilter_ipv6.c | 10 +++----
 net/ipv6/exthdrs.c             | 66 +++++++++++++++++++++---------------------
 net/ipv6/ip6_input.c           | 28 +++++++++---------
 net/ipv6/ip6_output.c          | 34 +++++++++++-----------
 net/ipv6/ip6mr.c               |  8 ++---
 net/ipv6/reassembly.c          | 32 ++++++++++----------
 7 files changed, 91 insertions(+), 91 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a620fc56e2f5..aba8760dd108 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -167,11 +167,11 @@ extern int sysctl_mld_qrv;
 
 #define IP6_INC_STATS(net, idev,field)		\
 		_DEVINC(net, ipv6, 64, idev, field)
-#define IP6_INC_STATS_BH(net, idev,field)	\
+#define __IP6_INC_STATS(net, idev,field)	\
 		_DEVINC(net, ipv6, 64_BH, idev, field)
 #define IP6_ADD_STATS(net, idev,field,val)	\
 		_DEVADD(net, ipv6, 64, idev, field, val)
-#define IP6_ADD_STATS_BH(net, idev,field,val)	\
+#define __IP6_ADD_STATS(net, idev,field,val)	\
 		_DEVADD(net, ipv6, 64_BH, idev, field, val)
 #define IP6_UPD_PO_STATS(net, idev,field,val)   \
 		_DEVUPD(net, ipv6, 64, idev, field, val)
diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index d61f56efc8dc..5e59a8457e7b 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -122,13 +122,13 @@ int br_validate_ipv6(struct net *net, struct sk_buff *skb)
 
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
 		if (pkt_len + ip6h_len > skb->len) {
-			IP6_INC_STATS_BH(net, idev,
-					 IPSTATS_MIB_INTRUNCATEDPKTS);
+			__IP6_INC_STATS(net, idev,
+					IPSTATS_MIB_INTRUNCATEDPKTS);
 			goto drop;
 		}
 		if (pskb_trim_rcsum(skb, pkt_len + ip6h_len)) {
-			IP6_INC_STATS_BH(net, idev,
-					 IPSTATS_MIB_INDISCARDS);
+			__IP6_INC_STATS(net, idev,
+					IPSTATS_MIB_INDISCARDS);
 			goto drop;
 		}
 	}
@@ -142,7 +142,7 @@ int br_validate_ipv6(struct net *net, struct sk_buff *skb)
 	return 0;
 
 inhdr_error:
-	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
+	__IP6_INC_STATS(net, idev, IPSTATS_MIB_INHDRERRORS);
 drop:
 	return -1;
 }
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index ea7c4d64a00a..8de5dd7aaa05 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -258,8 +258,8 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
-		IP6_INC_STATS_BH(dev_net(dst->dev), ip6_dst_idev(dst),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(dev_net(dst->dev), ip6_dst_idev(dst),
+				IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -280,8 +280,8 @@ static int ipv6_destopt_rcv(struct sk_buff *skb)
 		return 1;
 	}
 
-	IP6_INC_STATS_BH(dev_net(dst->dev),
-			 ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
+	__IP6_INC_STATS(dev_net(dst->dev),
+			ip6_dst_idev(dst), IPSTATS_MIB_INHDRERRORS);
 	return -1;
 }
 
@@ -309,8 +309,8 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, skb_transport_offset(skb) + 8) ||
 	    !pskb_may_pull(skb, (skb_transport_offset(skb) +
 				 ((skb_transport_header(skb)[1] + 1) << 3)))) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+				IPSTATS_MIB_INHDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -319,8 +319,8 @@ static int ipv6_rthdr_rcv(struct sk_buff *skb)
 
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr) ||
 	    skb->pkt_type != PACKET_HOST) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-				 IPSTATS_MIB_INADDRERRORS);
+		__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+				IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -334,8 +334,8 @@ looped_back:
 			 * processed by own
 			 */
 			if (!addr) {
-				IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-						 IPSTATS_MIB_INADDRERRORS);
+				__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+						IPSTATS_MIB_INADDRERRORS);
 				kfree_skb(skb);
 				return -1;
 			}
@@ -360,8 +360,8 @@ looped_back:
 			goto unknown_rh;
 		/* Silently discard invalid RTH type 2 */
 		if (hdr->hdrlen != 2 || hdr->segments_left != 1) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-					 IPSTATS_MIB_INHDRERRORS);
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_INHDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
@@ -379,8 +379,8 @@ looped_back:
 	n = hdr->hdrlen >> 1;
 
 	if (hdr->segments_left > n) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+				IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((&hdr->segments_left) -
 				   skb_network_header(skb)));
@@ -393,8 +393,8 @@ looped_back:
 	if (skb_cloned(skb)) {
 		/* the copy is a forwarded packet */
 		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-					 IPSTATS_MIB_OUTDISCARDS);
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_OUTDISCARDS);
 			kfree_skb(skb);
 			return -1;
 		}
@@ -416,14 +416,14 @@ looped_back:
 		if (xfrm6_input_addr(skb, (xfrm_address_t *)addr,
 				     (xfrm_address_t *)&ipv6_hdr(skb)->saddr,
 				     IPPROTO_ROUTING) < 0) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-					 IPSTATS_MIB_INADDRERRORS);
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
 		if (!ipv6_chk_home_addr(dev_net(skb_dst(skb)->dev), addr)) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-					 IPSTATS_MIB_INADDRERRORS);
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_INADDRERRORS);
 			kfree_skb(skb);
 			return -1;
 		}
@@ -434,8 +434,8 @@ looped_back:
 	}
 
 	if (ipv6_addr_is_multicast(addr)) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-				 IPSTATS_MIB_INADDRERRORS);
+		__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+				IPSTATS_MIB_INADDRERRORS);
 		kfree_skb(skb);
 		return -1;
 	}
@@ -454,8 +454,8 @@ looped_back:
 
 	if (skb_dst(skb)->dev->flags&IFF_LOOPBACK) {
 		if (ipv6_hdr(skb)->hop_limit <= 1) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-					 IPSTATS_MIB_INHDRERRORS);
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_INHDRERRORS);
 			icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT,
 				    0);
 			kfree_skb(skb);
@@ -470,7 +470,7 @@ looped_back:
 	return -1;
 
 unknown_rh:
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INHDRERRORS);
+	__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_INHDRERRORS);
 	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 			  (&hdr->type) - skb_network_header(skb));
 	return -1;
@@ -568,28 +568,28 @@ static bool ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
 	if (nh[optoff + 1] != 4 || (optoff & 3) != 2) {
 		net_dbg_ratelimited("ipv6_hop_jumbo: wrong jumbo opt length/alignment %d\n",
 				    nh[optoff+1]);
-		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, ipv6_skb_idev(skb),
+				IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
 	pkt_len = ntohl(*(__be32 *)(nh + optoff + 2));
 	if (pkt_len <= IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, ipv6_skb_idev(skb),
+				IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff+2);
 		return false;
 	}
 	if (ipv6_hdr(skb)->payload_len) {
-		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, ipv6_skb_idev(skb),
+				IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, optoff);
 		return false;
 	}
 
 	if (pkt_len > skb->len - sizeof(struct ipv6hdr)) {
-		IP6_INC_STATS_BH(net, ipv6_skb_idev(skb),
-				 IPSTATS_MIB_INTRUNCATEDPKTS);
+		__IP6_INC_STATS(net, ipv6_skb_idev(skb),
+				IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	}
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index c05c425c2389..218bb906c620 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -82,7 +82,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL ||
 	    !idev || unlikely(idev->cnf.disable_ipv6)) {
-		IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDISCARDS);
+		__IP6_INC_STATS(net, idev, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -109,10 +109,10 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (hdr->version != 6)
 		goto err;
 
-	IP6_ADD_STATS_BH(net, idev,
-			 IPSTATS_MIB_NOECTPKTS +
+	__IP6_ADD_STATS(net, idev,
+			IPSTATS_MIB_NOECTPKTS +
 				(ipv6_get_dsfield(hdr) & INET_ECN_MASK),
-			 max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
+			max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
 	/*
 	 * RFC4291 2.5.3
 	 * A packet received on an interface with a destination address
@@ -169,12 +169,12 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* pkt_len may be zero if Jumbo payload option is present */
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
 		if (pkt_len + sizeof(struct ipv6hdr) > skb->len) {
-			IP6_INC_STATS_BH(net,
-					 idev, IPSTATS_MIB_INTRUNCATEDPKTS);
+			__IP6_INC_STATS(net,
+					idev, IPSTATS_MIB_INTRUNCATEDPKTS);
 			goto drop;
 		}
 		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr))) {
-			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
+			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INHDRERRORS);
 			goto drop;
 		}
 		hdr = ipv6_hdr(skb);
@@ -182,7 +182,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
 		if (ipv6_parse_hopopts(skb) < 0) {
-			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
+			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INHDRERRORS);
 			rcu_read_unlock();
 			return NET_RX_DROP;
 		}
@@ -197,7 +197,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 		       net, NULL, skb, dev, NULL,
 		       ip6_rcv_finish);
 err:
-	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
+	__IP6_INC_STATS(net, idev, IPSTATS_MIB_INHDRERRORS);
 drop:
 	rcu_read_unlock();
 	kfree_skb(skb);
@@ -259,18 +259,18 @@ resubmit:
 		if (ret > 0)
 			goto resubmit;
 		else if (ret == 0)
-			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
+			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INDELIVERS);
 	} else {
 		if (!raw) {
 			if (xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-				IP6_INC_STATS_BH(net, idev,
-						 IPSTATS_MIB_INUNKNOWNPROTOS);
+				__IP6_INC_STATS(net, idev,
+						IPSTATS_MIB_INUNKNOWNPROTOS);
 				icmpv6_send(skb, ICMPV6_PARAMPROB,
 					    ICMPV6_UNK_NEXTHDR, nhoff);
 			}
 			kfree_skb(skb);
 		} else {
-			IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
+			__IP6_INC_STATS(net, idev, IPSTATS_MIB_INDELIVERS);
 			consume_skb(skb);
 		}
 	}
@@ -278,7 +278,7 @@ resubmit:
 	return 0;
 
 discard:
-	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDISCARDS);
+	__IP6_INC_STATS(net, idev, IPSTATS_MIB_INDISCARDS);
 	rcu_read_unlock();
 	kfree_skb(skb);
 	return 0;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 171518e3ca21..2b3ffc582d16 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -395,8 +395,8 @@ int ip6_forward(struct sk_buff *skb)
 		goto drop;
 
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_FWD, skb)) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
-				 IPSTATS_MIB_INDISCARDS);
+		__IP6_INC_STATS(net, ip6_dst_idev(dst),
+				IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -427,8 +427,8 @@ int ip6_forward(struct sk_buff *skb)
 		/* Force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_TIME_EXCEED, ICMPV6_EXC_HOPLIMIT, 0);
-		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, ip6_dst_idev(dst),
+				IPSTATS_MIB_INHDRERRORS);
 
 		kfree_skb(skb);
 		return -ETIMEDOUT;
@@ -441,15 +441,15 @@ int ip6_forward(struct sk_buff *skb)
 		if (proxied > 0)
 			return ip6_input(skb);
 		else if (proxied < 0) {
-			IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
-					 IPSTATS_MIB_INDISCARDS);
+			__IP6_INC_STATS(net, ip6_dst_idev(dst),
+					IPSTATS_MIB_INDISCARDS);
 			goto drop;
 		}
 	}
 
 	if (!xfrm6_route_forward(skb)) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
-				 IPSTATS_MIB_INDISCARDS);
+		__IP6_INC_STATS(net, ip6_dst_idev(dst),
+				IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 	dst = skb_dst(skb);
@@ -505,17 +505,17 @@ int ip6_forward(struct sk_buff *skb)
 		/* Again, force OUTPUT device used as source address */
 		skb->dev = dst->dev;
 		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
-				 IPSTATS_MIB_INTOOBIGERRORS);
-		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
-				 IPSTATS_MIB_FRAGFAILS);
+		__IP6_INC_STATS(net, ip6_dst_idev(dst),
+				IPSTATS_MIB_INTOOBIGERRORS);
+		__IP6_INC_STATS(net, ip6_dst_idev(dst),
+				IPSTATS_MIB_FRAGFAILS);
 		kfree_skb(skb);
 		return -EMSGSIZE;
 	}
 
 	if (skb_cow(skb, dst->dev->hard_header_len)) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(dst),
-				 IPSTATS_MIB_OUTDISCARDS);
+		__IP6_INC_STATS(net, ip6_dst_idev(dst),
+				IPSTATS_MIB_OUTDISCARDS);
 		goto drop;
 	}
 
@@ -525,14 +525,14 @@ int ip6_forward(struct sk_buff *skb)
 
 	hdr->hop_limit--;
 
-	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
-	IP6_ADD_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTOCTETS, skb->len);
+	__IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	__IP6_ADD_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTOCTETS, skb->len);
 	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD,
 		       net, NULL, skb, skb->dev, dst->dev,
 		       ip6_forward_finish);
 
 error:
-	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_INADDRERRORS);
+	__IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_INADDRERRORS);
 drop:
 	kfree_skb(skb);
 	return -EINVAL;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index bf678324fd52..f2e2013f8346 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1984,10 +1984,10 @@ int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 
 static inline int ip6mr_forward2_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-			 IPSTATS_MIB_OUTFORWDATAGRAMS);
-	IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-			 IPSTATS_MIB_OUTOCTETS, skb->len);
+	__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+			IPSTATS_MIB_OUTFORWDATAGRAMS);
+	__IP6_ADD_STATS(net, ip6_dst_idev(skb_dst(skb)),
+			IPSTATS_MIB_OUTOCTETS, skb->len);
 	return dst_output(net, sk, skb);
 }
 
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index e2ea31175ef9..2160d5d009cb 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -145,12 +145,12 @@ void ip6_expire_frag_queue(struct net *net, struct frag_queue *fq,
 	if (!dev)
 		goto out_rcu_unlock;
 
-	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	__IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 
 	if (inet_frag_evicting(&fq->q))
 		goto out_rcu_unlock;
 
-	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
+	__IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMTIMEOUT);
 
 	/* Don't send error if the first segment did not arrive. */
 	if (!(fq->q.flags & INET_FRAG_FIRST_IN) || !fq->q.fragments)
@@ -223,8 +223,8 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			((u8 *)(fhdr + 1) - (u8 *)(ipv6_hdr(skb) + 1)));
 
 	if ((unsigned int)end > IPV6_MAXPLEN) {
-		IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-				 IPSTATS_MIB_INHDRERRORS);
+		__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+				IPSTATS_MIB_INHDRERRORS);
 		icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 				  ((u8 *)&fhdr->frag_off -
 				   skb_network_header(skb)));
@@ -258,8 +258,8 @@ static int ip6_frag_queue(struct frag_queue *fq, struct sk_buff *skb,
 			/* RFC2460 says always send parameter problem in
 			 * this case. -DaveM
 			 */
-			IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-					 IPSTATS_MIB_INHDRERRORS);
+			__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+					IPSTATS_MIB_INHDRERRORS);
 			icmpv6_param_prob(skb, ICMPV6_HDR_FIELD,
 					  offsetof(struct ipv6hdr, payload_len));
 			return -1;
@@ -361,8 +361,8 @@ found:
 discard_fq:
 	inet_frag_kill(&fq->q, &ip6_frags);
 err:
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-			 IPSTATS_MIB_REASMFAILS);
+	__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+			IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 }
@@ -500,7 +500,7 @@ static int ip6_frag_reasm(struct frag_queue *fq, struct sk_buff *prev,
 			   skb_network_header_len(head));
 
 	rcu_read_lock();
-	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
+	__IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMOKS);
 	rcu_read_unlock();
 	fq->q.fragments = NULL;
 	fq->q.fragments_tail = NULL;
@@ -513,7 +513,7 @@ out_oom:
 	net_dbg_ratelimited("ip6_frag_reasm: no memory for reassembly\n");
 out_fail:
 	rcu_read_lock();
-	IP6_INC_STATS_BH(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
+	__IP6_INC_STATS(net, __in6_dev_get(dev), IPSTATS_MIB_REASMFAILS);
 	rcu_read_unlock();
 	return -1;
 }
@@ -528,7 +528,7 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	if (IP6CB(skb)->flags & IP6SKB_FRAGMENTED)
 		goto fail_hdr;
 
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
+	__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMREQDS);
 
 	/* Jumbo payload inhibits frag. header */
 	if (hdr->payload_len == 0)
@@ -544,8 +544,8 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 	if (!(fhdr->frag_off & htons(0xFFF9))) {
 		/* It is not a fragmented frame */
 		skb->transport_header += sizeof(struct frag_hdr);
-		IP6_INC_STATS_BH(net,
-				 ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMOKS);
+		__IP6_INC_STATS(net,
+				ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMOKS);
 
 		IP6CB(skb)->nhoff = (u8 *)fhdr - skb_network_header(skb);
 		IP6CB(skb)->flags |= IP6SKB_FRAGMENTED;
@@ -566,13 +566,13 @@ static int ipv6_frag_rcv(struct sk_buff *skb)
 		return ret;
 	}
 
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMFAILS);
+	__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -1;
 
 fail_hdr:
-	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
-			 IPSTATS_MIB_INHDRERRORS);
+	__IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)),
+			IPSTATS_MIB_INHDRERRORS);
 	icmpv6_param_prob(skb, ICMPV6_HDR_FIELD, skb_network_header_len(skb));
 	return -1;
 }
-- 
2.8.0.rc3.226.g39d4020
