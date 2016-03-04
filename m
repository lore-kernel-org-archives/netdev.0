From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next v2] arp: correct return value of arp_rcv
Date: Fri,  4 Mar 2016 14:07:54 +0000
Message-ID: <1457100474-18580-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:2410 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751337AbcCDOGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 09:06:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, arp_rcv() always return zero on a packet delivery upcall.

To make its behavior more compliant with the way this API should be
used, this patch changes this to let it return NET_RX_SUCCESS when the
packet is proper handled, and NET_RX_DROP otherwise.

v1->v2:
If sanity check is failed, call kfree_skb() instead of consume_skb(), then
return the correct return value.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/ipv4/arp.c | 35 ++++++++++++++++++++---------------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c102eb5..c34c754 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -665,7 +665,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	 */
 
 	if (!in_dev)
-		goto out;
+		goto out_free_skb;
 
 	arp = arp_hdr(skb);
 
@@ -673,7 +673,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 	default:
 		if (arp->ar_pro != htons(ETH_P_IP) ||
 		    htons(dev_type) != arp->ar_hrd)
-			goto out;
+			goto out_free_skb;
 		break;
 	case ARPHRD_ETHER:
 	case ARPHRD_FDDI:
@@ -690,17 +690,17 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		if ((arp->ar_hrd != htons(ARPHRD_ETHER) &&
 		     arp->ar_hrd != htons(ARPHRD_IEEE802)) ||
 		    arp->ar_pro != htons(ETH_P_IP))
-			goto out;
+			goto out_free_skb;
 		break;
 	case ARPHRD_AX25:
 		if (arp->ar_pro != htons(AX25_P_IP) ||
 		    arp->ar_hrd != htons(ARPHRD_AX25))
-			goto out;
+			goto out_free_skb;
 		break;
 	case ARPHRD_NETROM:
 		if (arp->ar_pro != htons(AX25_P_IP) ||
 		    arp->ar_hrd != htons(ARPHRD_NETROM))
-			goto out;
+			goto out_free_skb;
 		break;
 	}
 
@@ -708,7 +708,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	if (arp->ar_op != htons(ARPOP_REPLY) &&
 	    arp->ar_op != htons(ARPOP_REQUEST))
-		goto out;
+		goto out_free_skb;
 
 /*
  *	Extract fields
@@ -733,7 +733,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
  */
 	if (ipv4_is_multicast(tip) ||
 	    (!IN_DEV_ROUTE_LOCALNET(in_dev) && ipv4_is_loopback(tip)))
-		goto out;
+		goto out_free_skb;
 
  /*
   *	For some 802.11 wireless deployments (and possibly other networks),
@@ -741,7 +741,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
   *	and thus should not be accepted.
   */
 	if (sip == tip && IN_DEV_ORCONF(in_dev, DROP_GRATUITOUS_ARP))
-		goto out;
+		goto out_free_skb;
 
 /*
  *     Special case: We must set Frame Relay source Q.922 address
@@ -778,7 +778,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		    !arp_ignore(in_dev, sip, tip))
 			arp_send_dst(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip,
 				     sha, dev->dev_addr, sha, reply_dst);
-		goto out;
+		goto out_consume_skb;
 	}
 
 	if (arp->ar_op == htons(ARPOP_REQUEST) &&
@@ -803,7 +803,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 					neigh_release(n);
 				}
 			}
-			goto out;
+			goto out_consume_skb;
 		} else if (IN_DEV_FORWARD(in_dev)) {
 			if (addr_type == RTN_UNICAST  &&
 			    (arp_fwd_proxy(in_dev, dev, rt) ||
@@ -826,7 +826,7 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 						       in_dev->arp_parms, skb);
 					goto out_free_dst;
 				}
-				goto out;
+				goto out_consume_skb;
 			}
 		}
 	}
@@ -876,11 +876,16 @@ static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 		neigh_release(n);
 	}
 
-out:
+out_consume_skb:
 	consume_skb(skb);
+
 out_free_dst:
 	dst_release(reply_dst);
-	return 0;
+	return NET_RX_SUCCESS;
+
+out_free_skb:
+	kfree_skb(skb);
+	return NET_RX_DROP;
 }
 
 static void parp_redo(struct sk_buff *skb)
@@ -924,11 +929,11 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 consumeskb:
 	consume_skb(skb);
-	return 0;
+	return NET_RX_SUCCESS;
 freeskb:
 	kfree_skb(skb);
 out_of_mem:
-	return 0;
+	return NET_RX_DROP;
 }
 
 /*
-- 
1.8.3.1
