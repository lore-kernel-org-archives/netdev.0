From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/20] mib: add net to IP_INC_STATS_BH
Date: Wed, 16 Jul 2008 12:12:27 +0400
Message-ID: <487DAD6B.2080107@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36875 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755072AbYGPIOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:14:30 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h                |    2 +-
 net/dccp/ipv4.c                 |    2 +-
 net/ipv4/datagram.c             |    2 +-
 net/ipv4/inet_connection_sock.c |    4 ++--
 net/ipv4/ip_forward.c           |    4 ++--
 net/ipv4/ip_fragment.c          |   17 ++++++++++-------
 net/ipv4/ip_input.c             |   30 ++++++++++++++++--------------
 net/ipv4/ipmr.c                 |    4 ++--
 net/ipv4/route.c                |    3 ++-
 net/ipv4/tcp_ipv4.c             |    2 +-
 net/ipv4/udp.c                  |    2 +-
 net/sctp/output.c               |    3 ++-
 12 files changed, 41 insertions(+), 34 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index b9aaa32..9973ce0 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -158,7 +158,7 @@ struct ipv4_config
 extern struct ipv4_config ipv4_config;
 DECLARE_SNMP_STAT(struct ipstats_mib, ip_statistics);
 #define IP_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(ip_statistics, field); } while (0)
-#define IP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(ip_statistics, field)
+#define IP_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(ip_statistics, field); } while (0)
 #define IP_ADD_STATS_BH(field, val)	SNMP_ADD_STATS_BH(ip_statistics, field, val)
 DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS(field)		SNMP_INC_STATS(net_statistics, field)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 2b03c47..9f760a1 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -465,7 +465,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 
 	security_skb_classify_flow(skb, &fl);
 	if (ip_route_output_flow(net, &rt, &fl, sk, 0)) {
-		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
 
diff --git a/net/ipv4/datagram.c b/net/ipv4/datagram.c
index 0c0c73f..5e6c5a0 100644
--- a/net/ipv4/datagram.c
+++ b/net/ipv4/datagram.c
@@ -52,7 +52,7 @@ int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			       inet->sport, usin->sin_port, sk, 1);
 	if (err) {
 		if (err == -ENETUNREACH)
-			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 		return err;
 	}
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8338e10..bb81c95 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -342,12 +342,12 @@ struct dst_entry* inet_csk_route_req(struct sock *sk,
 
 	security_req_classify_flow(req, &fl);
 	if (ip_route_output_flow(net, &rt, &fl, sk, 0)) {
-		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
 	if (opt && opt->is_strictroute && rt->rt_dst != rt->rt_gateway) {
 		ip_rt_put(rt);
-		IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
 	return &rt->u.dst;
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 7f78a5a..450016b 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -42,7 +42,7 @@ static int ip_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_INC_STATS_BH(dev_net(skb->dst->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
@@ -123,7 +123,7 @@ sr_failed:
 
 too_many_hops:
 	/* Tell the sender its packet died... */
-	IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(dev_net(skb->dst->dev), IPSTATS_MIB_INHDRERRORS);
 	icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index e23be5b..65364c0 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -199,8 +199,8 @@ static void ip_expire(unsigned long arg)
 
 	ipq_kill(qp);
 
-	IP_INC_STATS_BH(IPSTATS_MIB_REASMTIMEOUT);
-	IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 
 	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
 		struct sk_buff *head = qp->q.fragments;
@@ -261,7 +261,10 @@ static inline int ip_frag_too_far(struct ipq *qp)
 	rc = qp->q.fragments && (end - start) > max;
 
 	if (rc) {
-		IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+		struct net *net;
+
+		net = container_of(qp->q.net, struct net, ipv4.frags);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 	}
 
 	return rc;
@@ -545,7 +548,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 	iph = ip_hdr(head);
 	iph->frag_off = 0;
 	iph->tot_len = htons(len);
-	IP_INC_STATS_BH(IPSTATS_MIB_REASMOKS);
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	return 0;
 
@@ -560,7 +563,7 @@ out_oversize:
 			"Oversized IP packet from " NIPQUAD_FMT ".\n",
 			NIPQUAD(qp->saddr));
 out_fail:
-	IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_REASMFAILS);
 	return err;
 }
 
@@ -571,7 +574,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	struct net *net;
 
 	net = skb->dev ? dev_net(skb->dev) : dev_net(skb->dst->dev);
-	IP_INC_STATS_BH(IPSTATS_MIB_REASMREQDS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
 	/* Start by cleaning up the memory. */
 	if (atomic_read(&net->ipv4.frags.mem) > net->ipv4.frags.high_thresh)
@@ -590,7 +593,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 		return ret;
 	}
 
-	IP_INC_STATS_BH(IPSTATS_MIB_REASMFAILS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -ENOMEM;
 }
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 7c26428..043f640 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -230,16 +230,16 @@ static int ip_local_deliver_finish(struct sk_buff *skb)
 				protocol = -ret;
 				goto resubmit;
 			}
-			IP_INC_STATS_BH(IPSTATS_MIB_INDELIVERS);
+			IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
 		} else {
 			if (!raw) {
 				if (xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-					IP_INC_STATS_BH(IPSTATS_MIB_INUNKNOWNPROTOS);
+					IP_INC_STATS_BH(net, IPSTATS_MIB_INUNKNOWNPROTOS);
 					icmp_send(skb, ICMP_DEST_UNREACH,
 						  ICMP_PROT_UNREACH, 0);
 				}
 			} else
-				IP_INC_STATS_BH(IPSTATS_MIB_INDELIVERS);
+				IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
 			kfree_skb(skb);
 		}
 	}
@@ -281,7 +281,7 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 					      --ANK (980813)
 	*/
 	if (skb_cow(skb, skb_headroom(skb))) {
-		IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -290,7 +290,7 @@ static inline int ip_rcv_options(struct sk_buff *skb)
 	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
 
 	if (ip_options_compile(dev_net(dev), opt, skb)) {
-		IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
@@ -334,9 +334,11 @@ static int ip_rcv_finish(struct sk_buff *skb)
 					 skb->dev);
 		if (unlikely(err)) {
 			if (err == -EHOSTUNREACH)
-				IP_INC_STATS_BH(IPSTATS_MIB_INADDRERRORS);
+				IP_INC_STATS_BH(dev_net(skb->dev),
+						IPSTATS_MIB_INADDRERRORS);
 			else if (err == -ENETUNREACH)
-				IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
+				IP_INC_STATS_BH(dev_net(skb->dev),
+						IPSTATS_MIB_INNOROUTES);
 			goto drop;
 		}
 	}
@@ -357,9 +359,9 @@ static int ip_rcv_finish(struct sk_buff *skb)
 
 	rt = skb->rtable;
 	if (rt->rt_type == RTN_MULTICAST)
-		IP_INC_STATS_BH(IPSTATS_MIB_INMCASTPKTS);
+		IP_INC_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INMCASTPKTS);
 	else if (rt->rt_type == RTN_BROADCAST)
-		IP_INC_STATS_BH(IPSTATS_MIB_INBCASTPKTS);
+		IP_INC_STATS_BH(dev_net(rt->u.dst.dev), IPSTATS_MIB_INBCASTPKTS);
 
 	return dst_input(skb);
 
@@ -382,10 +384,10 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	if (skb->pkt_type == PACKET_OTHERHOST)
 		goto drop;
 
-	IP_INC_STATS_BH(IPSTATS_MIB_INRECEIVES);
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INRECEIVES);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
 
@@ -418,7 +420,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
@@ -428,7 +430,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	 * Note this now means skb->len holds ntohs(iph->tot_len).
 	 */
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -439,7 +441,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		       ip_rcv_finish);
 
 inhdr_error:
-	IP_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
 drop:
 	kfree_skb(skb);
 out:
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c9ab47b..033c712 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1178,7 +1178,7 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
 {
 	struct ip_options * opt	= &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_INC_STATS_BH(dev_net(skb->dst->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
@@ -1241,7 +1241,7 @@ static void ipmr_queue_xmit(struct sk_buff *skb, struct mfc_cache *c, int vifi)
 		   to blackhole.
 		 */
 
-		IP_INC_STATS_BH(IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 		ip_rt_put(rt);
 		goto out_free;
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 79c1e74..e4ab0ac 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1429,7 +1429,8 @@ static int ip_error(struct sk_buff *skb)
 			break;
 		case ENETUNREACH:
 			code = ICMP_NET_UNREACH;
-			IP_INC_STATS_BH(IPSTATS_MIB_INNOROUTES);
+			IP_INC_STATS_BH(dev_net(rt->u.dst.dev),
+					IPSTATS_MIB_INNOROUTES);
 			break;
 		case EACCES:
 			code = ICMP_PKT_FILTERED;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0fefd44..7797d52 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -175,7 +175,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
 			       inet->sport, usin->sin_port, sk, 1);
 	if (tmp < 0) {
 		if (tmp == -ENETUNREACH)
-			IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+			IP_INC_STATS_BH(sock_net(sk), IPSTATS_MIB_OUTNOROUTES);
 		return tmp;
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 048ef57..1560d11 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -662,7 +662,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		err = ip_route_output_flow(net, &rt, &fl, sk, 1);
 		if (err) {
 			if (err == -ENETUNREACH)
-				IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
 			goto out;
 		}
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index abcd00d..9a63a3f 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -50,6 +50,7 @@
 #include <linux/init.h>
 #include <net/inet_ecn.h>
 #include <net/icmp.h>
+#include <net/net_namespace.h>
 
 #ifndef TEST_FRAME
 #include <net/tcp.h>
@@ -595,7 +596,7 @@ out:
 	return err;
 no_route:
 	kfree_skb(nskb);
-	IP_INC_STATS_BH(IPSTATS_MIB_OUTNOROUTES);
+	IP_INC_STATS_BH(&init_net, IPSTATS_MIB_OUTNOROUTES);
 
 	/* FIXME: Returning the 'err' will effect all the associations
 	 * associated with a socket, although only one of the paths of the
-- 
1.5.5.1

