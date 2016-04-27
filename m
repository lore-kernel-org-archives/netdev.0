From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/17] net: rename IP_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:35 -0700
Message-ID: <1461800683-25034-10-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32951 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbcD0XpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:14 -0400
Received: by mail-pf0-f169.google.com with SMTP id 206so26376231pfu.0
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:13 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename IP_INC_STATS_BH() to __IP_INC_STATS(), to
better express this is used in non preemptible context.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h                |  2 +-
 net/bridge/br_netfilter_hooks.c |  6 +++---
 net/dccp/ipv4.c                 |  2 +-
 net/ipv4/inet_connection_sock.c |  4 ++--
 net/ipv4/ip_forward.c           |  4 ++--
 net/ipv4/ip_fragment.c          | 14 +++++++-------
 net/ipv4/ip_input.c             | 20 ++++++++++----------
 net/ipv4/route.c                |  6 +++---
 8 files changed, 29 insertions(+), 29 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index ae0e85d018e8..0be0af3017ba 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -187,7 +187,7 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 			   unsigned int len);
 
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
-#define IP_INC_STATS_BH(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
+#define __IP_INC_STATS(net, field)	SNMP_INC_STATS64_BH((net)->mib.ip_statistics, field)
 #define IP_ADD_STATS(net, field, val)	SNMP_ADD_STATS64((net)->mib.ip_statistics, field, val)
 #define IP_ADD_STATS_BH(net, field, val) SNMP_ADD_STATS64_BH((net)->mib.ip_statistics, field, val)
 #define IP_UPD_PO_STATS(net, field, val) SNMP_UPD_PO_STATS64((net)->mib.ip_statistics, field, val)
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 44114a94c576..2d25979273a6 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -217,13 +217,13 @@ static int br_validate_ipv4(struct net *net, struct sk_buff *skb)
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_INTRUNCATEDPKTS);
+		__IP_INC_STATS(net, IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
 
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
+		__IP_INC_STATS(net, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -236,7 +236,7 @@ static int br_validate_ipv4(struct net *net, struct sk_buff *skb)
 	return 0;
 
 inhdr_error:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
+	__IP_INC_STATS(net, IPSTATS_MIB_INHDRERRORS);
 drop:
 	return -1;
 }
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 14e30584e59d..a9c75e79ba99 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -462,7 +462,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_flow(net, &fl4, sk);
 	if (IS_ERR(rt)) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+		__IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
 		return NULL;
 	}
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index ab69da2d2a77..7ce112aa3a7b 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -427,7 +427,7 @@ struct dst_entry *inet_csk_route_req(const struct sock *sk,
 route_err:
 	ip_rt_put(rt);
 no_route:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+	__IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(inet_csk_route_req);
@@ -466,7 +466,7 @@ route_err:
 	ip_rt_put(rt);
 no_route:
 	rcu_read_unlock();
-	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+	__IP_INC_STATS(net, IPSTATS_MIB_OUTNOROUTES);
 	return NULL;
 }
 EXPORT_SYMBOL_GPL(inet_csk_route_child_sock);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index af18f1e4889e..42fbd59b0ba8 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -65,7 +65,7 @@ static int ip_forward_finish(struct net *net, struct sock *sk, struct sk_buff *s
 {
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
-	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
+	__IP_INC_STATS(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP_ADD_STATS_BH(net, IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	if (unlikely(opt->optlen))
@@ -157,7 +157,7 @@ sr_failed:
 
 too_many_hops:
 	/* Tell the sender its packet died... */
-	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
+	__IP_INC_STATS(net, IPSTATS_MIB_INHDRERRORS);
 	icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index efbd47d1a531..bbe7f72db9c1 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -204,14 +204,14 @@ static void ip_expire(unsigned long arg)
 		goto out;
 
 	ipq_kill(qp);
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
+	__IP_INC_STATS(net, IPSTATS_MIB_REASMFAILS);
 
 	if (!inet_frag_evicting(&qp->q)) {
 		struct sk_buff *head = qp->q.fragments;
 		const struct iphdr *iph;
 		int err;
 
-		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMTIMEOUT);
+		__IP_INC_STATS(net, IPSTATS_MIB_REASMTIMEOUT);
 
 		if (!(qp->q.flags & INET_FRAG_FIRST_IN) || !qp->q.fragments)
 			goto out;
@@ -291,7 +291,7 @@ static int ip_frag_too_far(struct ipq *qp)
 		struct net *net;
 
 		net = container_of(qp->q.net, struct net, ipv4.frags);
-		IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
+		__IP_INC_STATS(net, IPSTATS_MIB_REASMFAILS);
 	}
 
 	return rc;
@@ -635,7 +635,7 @@ static int ip_frag_reasm(struct ipq *qp, struct sk_buff *prev,
 
 	ip_send_check(iph);
 
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMOKS);
+	__IP_INC_STATS(net, IPSTATS_MIB_REASMOKS);
 	qp->q.fragments = NULL;
 	qp->q.fragments_tail = NULL;
 	return 0;
@@ -647,7 +647,7 @@ out_nomem:
 out_oversize:
 	net_info_ratelimited("Oversized IP packet from %pI4\n", &qp->saddr);
 out_fail:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
+	__IP_INC_STATS(net, IPSTATS_MIB_REASMFAILS);
 	return err;
 }
 
@@ -658,7 +658,7 @@ int ip_defrag(struct net *net, struct sk_buff *skb, u32 user)
 	int vif = l3mdev_master_ifindex_rcu(dev);
 	struct ipq *qp;
 
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
+	__IP_INC_STATS(net, IPSTATS_MIB_REASMREQDS);
 	skb_orphan(skb);
 
 	/* Lookup (or create) queue header */
@@ -675,7 +675,7 @@ int ip_defrag(struct net *net, struct sk_buff *skb, u32 user)
 		return ret;
 	}
 
-	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
+	__IP_INC_STATS(net, IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -ENOMEM;
 }
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e3d782746d9d..cca6729cd6ee 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -218,17 +218,17 @@ static int ip_local_deliver_finish(struct net *net, struct sock *sk, struct sk_b
 				protocol = -ret;
 				goto resubmit;
 			}
-			IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
+			__IP_INC_STATS(net, IPSTATS_MIB_INDELIVERS);
 		} else {
 			if (!raw) {
 				if (xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb)) {
-					IP_INC_STATS_BH(net, IPSTATS_MIB_INUNKNOWNPROTOS);
+					__IP_INC_STATS(net, IPSTATS_MIB_INUNKNOWNPROTOS);
 					icmp_send(skb, ICMP_DEST_UNREACH,
 						  ICMP_PROT_UNREACH, 0);
 				}
 				kfree_skb(skb);
 			} else {
-				IP_INC_STATS_BH(net, IPSTATS_MIB_INDELIVERS);
+				__IP_INC_STATS(net, IPSTATS_MIB_INDELIVERS);
 				consume_skb(skb);
 			}
 		}
@@ -273,7 +273,7 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 					      --ANK (980813)
 	*/
 	if (skb_cow(skb, skb_headroom(skb))) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		__IP_INC_STATS(dev_net(dev), IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -282,7 +282,7 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
 
 	if (ip_options_compile(dev_net(dev), opt, skb)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+		__IP_INC_STATS(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
 		goto drop;
 	}
 
@@ -413,7 +413,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
+		__IP_INC_STATS(net, IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
 
@@ -453,7 +453,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_INTRUNCATEDPKTS);
+		__IP_INC_STATS(net, IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
@@ -463,7 +463,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	 * Note this now means skb->len holds ntohs(iph->tot_len).
 	 */
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
+		__IP_INC_STATS(net, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -480,9 +480,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		       ip_rcv_finish);
 
 csum_error:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_CSUMERRORS);
+	__IP_INC_STATS(net, IPSTATS_MIB_CSUMERRORS);
 inhdr_error:
-	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
+	__IP_INC_STATS(net, IPSTATS_MIB_INHDRERRORS);
 drop:
 	kfree_skb(skb);
 out:
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 60398a9370e7..8c8c655bb2c4 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -915,11 +915,11 @@ static int ip_error(struct sk_buff *skb)
 	if (!IN_DEV_FORWARD(in_dev)) {
 		switch (rt->dst.error) {
 		case EHOSTUNREACH:
-			IP_INC_STATS_BH(net, IPSTATS_MIB_INADDRERRORS);
+			__IP_INC_STATS(net, IPSTATS_MIB_INADDRERRORS);
 			break;
 
 		case ENETUNREACH:
-			IP_INC_STATS_BH(net, IPSTATS_MIB_INNOROUTES);
+			__IP_INC_STATS(net, IPSTATS_MIB_INNOROUTES);
 			break;
 		}
 		goto out;
@@ -934,7 +934,7 @@ static int ip_error(struct sk_buff *skb)
 		break;
 	case ENETUNREACH:
 		code = ICMP_NET_UNREACH;
-		IP_INC_STATS_BH(net, IPSTATS_MIB_INNOROUTES);
+		__IP_INC_STATS(net, IPSTATS_MIB_INNOROUTES);
 		break;
 	case EACCES:
 		code = ICMP_PKT_FILTERED;
-- 
2.8.0.rc3.226.g39d4020
