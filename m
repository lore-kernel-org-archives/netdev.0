From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: [PATCH 2/3] IPV6: unify 3 similar code path in ndisc_recv_ns()
Date: Fri, 06 Feb 2004 18:10:06 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206.181006.79694138.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

[PATCH 2/3] IPV6: unify 3 similar code path in ndisc_recv_ns()

D: Unify 3 similar code path in ndisc_recv_ns().
D: This patch also fixes:
D:  - flags sent with NA in reply to this NS
D:  - missing random delay after receipt of NS against anycast

Thanks.

--- linux26-dad/net/ipv6/ndisc.c	Fri Feb  6 15:12:33 2004
+++ linux26-recv_ns/net/ipv6/ndisc.c	Fri Feb  6 16:38:16 2004
@@ -707,8 +707,10 @@ static void ndisc_recv_ns(struct sk_buff
 	struct ndisc_options ndopts;
 	struct net_device *dev = skb->dev;
 	struct inet6_ifaddr *ifp;
+	struct inet6_dev *idev = NULL;
 	struct neighbour *neigh;
 	int addr_type = ipv6_addr_type(saddr);
+	int inc;
 
 	if (ipv6_addr_is_multicast(&msg->target)) {
 		if (net_ratelimit())
@@ -757,6 +759,8 @@ static void ndisc_recv_ns(struct sk_buff
 		}
 	}
 
+	inc = ipv6_addr_is_multicast(daddr);
+
 	if ((ifp = ipv6_get_ifaddr(&msg->target, dev, 1)) != NULL) {
 		if (ifp->flags & IFA_F_TENTATIVE) {
 			/* Address is tentative. If the source
@@ -784,127 +788,72 @@ static void ndisc_recv_ns(struct sk_buff
 			addrconf_dad_failure(ifp); 
 			return;
 		}
-	
-		if (addr_type == IPV6_ADDR_ANY) {
-			struct in6_addr maddr;
 
-			ipv6_addr_all_nodes(&maddr);
-			ndisc_send_na(dev, NULL, &maddr, &ifp->addr, 
-				      ifp->idev->cnf.forwarding, 0, 
-				      1, 1);
-			in6_ifa_put(ifp);
+		idev = ifp->idev;
+	} else {
+		idev = in6_dev_get(dev);
+		if (!idev) {
+			/* XXX: count this drop? */
 			return;
 		}
 
-		if (addr_type & IPV6_ADDR_UNICAST) {
-			if (ipv6_addr_is_multicast(daddr))
-				nd_tbl.stats.rcv_probes_mcast++;
-			else
-				nd_tbl.stats.rcv_probes_ucast++;
-
-			/* 
-			 *	update / create cache entry
-			 *	for the source address
-			 */
+		if (ipv6_chk_acast_addr(dev, &msg->target) ||
+		    (idev->cnf.forwarding && 
+		     pneigh_lookup(&nd_tbl, &msg->target, dev, 0))) {
+			if (skb->stamp.tv_sec != 0 &&
+			    skb->pkt_type != PACKET_HOST &&
+			    inc != 0 &&
+			    idev->nd_parms->proxy_delay != 0) {
+				/*
+				 * for anycast or proxy,
+				 * sender should delay its response 
+				 * by a random time between 0 and 
+				 * MAX_ANYCAST_DELAY_TIME seconds.
+				 * (RFC2461) -- yoshfuji
+				 */
+				struct sk_buff *n = skb_clone(skb, GFP_ATOMIC);
+				if (n)
+					pneigh_enqueue(&nd_tbl, idev->nd_parms, n);
+				goto out;
+			}
+		} else
+			goto out;
+	}
 
-			neigh = neigh_event_ns(&nd_tbl, lladdr, saddr, dev);
+	if (addr_type == IPV6_ADDR_ANY) {
+		struct in6_addr maddr;
 
-			if (neigh || !dev->hard_header) {
-				ndisc_send_na(dev, neigh, saddr, &ifp->addr, 
-					      ifp->idev->cnf.forwarding, 1, 
-					      1, 1);
-				if (neigh)
-					neigh_release(neigh);
-			}
-		}
-		in6_ifa_put(ifp);
-	} else if (ipv6_chk_acast_addr(dev, &msg->target)) {
-		struct inet6_dev *idev = in6_dev_get(dev);
-	
-		/* anycast */
-	
-		if (!idev) {
-			/* XXX: count this drop? */
-			return;
-		}
-	
-		if (addr_type == IPV6_ADDR_ANY) {
-			struct in6_addr maddr;
-	
-			ipv6_addr_all_nodes(&maddr);
-			ndisc_send_na(dev, NULL, &maddr, &msg->target,
-				      idev->cnf.forwarding, 0, 0, 1);
-			in6_dev_put(idev);
-			return;
-		}
+		ipv6_addr_all_nodes(&maddr);
+		ndisc_send_na(dev, NULL, &maddr, &msg->target,
+			      idev->cnf.forwarding, 0, (ifp != NULL), 1);
+		goto out;
+	}
 
-		if (addr_type & IPV6_ADDR_UNICAST) {
-			int inc = ipv6_addr_is_multicast(daddr);
-			if (inc)  
-				nd_tbl.stats.rcv_probes_mcast++;
-			else
-				nd_tbl.stats.rcv_probes_ucast++;
-	
-			/*
-			 *   update / create cache entry
-			 *   for the source address
-			 */
+	if (inc)
+		nd_tbl.stats.rcv_probes_mcast++;
+	else
+		nd_tbl.stats.rcv_probes_ucast++;
+
+	/* 
+	 *	update / create cache entry
+	 *	for the source address
+	 */
+	neigh = neigh_event_ns(&nd_tbl, lladdr, saddr, dev);
 
-			neigh = neigh_event_ns(&nd_tbl, lladdr, saddr, skb->dev);
+	if (neigh || !dev->hard_header) {
+		ndisc_send_na(dev, neigh, saddr, &msg->target,
+			      idev->cnf.forwarding, 
+			      1, (ifp != NULL && inc), inc);
+		if (neigh)
+			neigh_release(neigh);
+	}
 
-			if (neigh || !dev->hard_header) {
-				ndisc_send_na(dev, neigh, saddr,
-					      &msg->target, 
-					      idev->cnf.forwarding, 1, 0, inc);
-				if (neigh)
-					neigh_release(neigh);
-			}
-		}
+out:
+	if (ifp)
+		in6_ifa_put(ifp);
+	else
 		in6_dev_put(idev);
-	} else {
-		struct inet6_dev *in6_dev = in6_dev_get(dev);
 
-		if (in6_dev && in6_dev->cnf.forwarding &&
-		    (addr_type & IPV6_ADDR_UNICAST ||
-		     addr_type == IPV6_ADDR_ANY) &&
-		    pneigh_lookup(&nd_tbl, &msg->target, dev, 0)) {
-			int inc = ipv6_addr_is_multicast(daddr);
-
-			if (skb->stamp.tv_sec == 0 ||
-			    skb->pkt_type == PACKET_HOST ||
-			    inc == 0 ||
-			    in6_dev->nd_parms->proxy_delay == 0) {
-				if (inc)
-					nd_tbl.stats.rcv_probes_mcast++;
-				else
-					nd_tbl.stats.rcv_probes_ucast++;
-					
-				if (addr_type & IPV6_ADDR_UNICAST) {
-					neigh = neigh_event_ns(&nd_tbl, lladdr, saddr, dev);
-
-					if (neigh) {
-						ndisc_send_na(dev, neigh, saddr, &msg->target,
-							      0, 1, 0, 1);
-						neigh_release(neigh);
-					}
-				} else {
-					/* proxy should also protect against DAD */
-					struct in6_addr maddr;
-					ipv6_addr_all_nodes(&maddr);
-					ndisc_send_na(dev, NULL, &maddr, &msg->target, 
-						      0, 0, 0, 1);
-				}
-			} else {
-				struct sk_buff *n = skb_clone(skb, GFP_ATOMIC);
-				if (n)
-					pneigh_enqueue(&nd_tbl, in6_dev->nd_parms, n);
-				in6_dev_put(in6_dev);
-				return;
-			}
-		}
-		if (in6_dev)
-			in6_dev_put(in6_dev);
-	}
 	return;
 }
 

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
