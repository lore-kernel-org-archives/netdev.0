From: Julian Anastasov <ja@ssi.bg>
Subject: Change proxy_arp to respond only for valid neighbours
Date: Sun, 8 Feb 2004 22:44:05 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	Appended is a patch that modifies proxy_arp to check
the target's neighbour state before reporting any information
to requestors. The benefit is that the availability of the target
host is properly reported to the requestor, we prefer not to send
replies when target is unreachable. The changes:

- now pneigh_lookup has more priority compared to arp_fwd_proxy

- neigh_event_ns is called only once per request, not twice

- the 'skb->pkt_type == PACKET_HOST' check has no semantic anymore,
the requestor should have same information no matter the packet
type. In all cases we add response delay for all requests, broadcast
or unicast, to help other authoritative hosts to reply before us.

- the RTCF_DNAT case is not delayed anymore (may be it is not used
anymore, IIRC)

Remaining questions:

- do we need to delay the pneigh_lookup case? Now it is still delayed
as before.

Comments?

Regards

--
Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.2/linux/net/ipv4/arp.c linux/net/ipv4/arp.c
--- v2.6.2/linux/net/ipv4/arp.c	2004-02-05 00:23:18.000000000 +0200
+++ linux/net/ipv4/arp.c	2004-02-08 21:06:49.843123528 +0200
@@ -758,24 +758,36 @@
 			}
 			goto out;
 		} else if (IN_DEV_FORWARD(in_dev)) {
+			int fwd_proxy = 0, delay = 0;
+
 			if ((rt->rt_flags&RTCF_DNAT) ||
 			    (addr_type == RTN_UNICAST  && rt->u.dst.dev != dev &&
-			     (arp_fwd_proxy(in_dev, rt) || pneigh_lookup(&arp_tbl, &tip, dev, 0)))) {
-				n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
-				if (n)
-					neigh_release(n);
-
-				if (skb->stamp.tv_sec == 0 ||
-				    skb->pkt_type == PACKET_HOST ||
-				    in_dev->arp_parms->proxy_delay == 0) {
-					arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
-				} else {
-					pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
-					in_dev_put(in_dev);
-					return 0;
-				}
+			     ((delay = in_dev->arp_parms->proxy_delay,
+			       pneigh_lookup(&arp_tbl, &tip, dev, 0)) ||
+			      (fwd_proxy = arp_fwd_proxy(in_dev, rt))))) {
+
+				if (skb->stamp.tv_sec) {
+					n = neigh_event_ns(&arp_tbl, sha, &sip, dev);
+					if (n)
+						neigh_release(n);
+					if ((fwd_proxy &&
+					    (n = rt->u.dst.neighbour) &&
+					    /* We need the actual state ASAP */
+					    neigh_event_send(n, NULL)) || delay) {
+						if (delay) {
+							pneigh_enqueue(&arp_tbl, in_dev->arp_parms, skb);
+							skb = NULL;
+						}
+						goto out;
+					}
+				} else if (fwd_proxy && (n = rt->u.dst.neighbour) &&
+					   !neigh_is_valid(n))
+					goto out;
+
+				arp_send(ARPOP_REPLY,ETH_P_ARP,sip,dev,tip,sha,dev->dev_addr,sha);
+				goto out;
+			} else if (!skb->stamp.tv_sec)
 				goto out;
-			}
 		}
 	}
 
@@ -819,7 +831,8 @@
 out:
 	if (in_dev)
 		in_dev_put(in_dev);
-	kfree_skb(skb);
+	if (skb)
+		kfree_skb(skb);
 	return 0;
 }
 
