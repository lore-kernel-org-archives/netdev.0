From: Joe Stringer <joestringer@nicira.com>
Subject: [RFCv2 net-next 6/7] net: Refactor ip_defrag() APIs
Date: Mon,  2 Mar 2015 13:55:04 -0800
Message-ID: <1425333305-19702-7-git-send-email-joestringer@nicira.com>
References: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Cc: Andy Zhou <azhou@nicira.com>, linux-kernel@vger.kernel.org,
	Justin Pettit <jpettit@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:54438 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754601AbbCBVzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:55:46 -0500
Received: by mail-pa0-f46.google.com with SMTP id fa1so11573265pad.3
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 13:55:45 -0800 (PST)
In-Reply-To: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

Currently, ip_defrag() does not keep track of the maximum fragmentation
size for each fragmented packet. This information is not necessary since
current Linux IP fragmentation always fragments a packet based on output
devices' MTU.

However, this becomes more tricky when integrating with output ports that
do not have a netdevice attached, for example OVS vports. In this case,
the MTU of the output port is not always known. If the incoming maximum
fragment size is tracked during defragmentation, then these users can
refragment into reasonable sizes when sending the packets.

This patch modifies the ip_defrag() to keep track of the maximum
fragment size for each packet and report this size back to the caller
once a packet is successfully reassembled. This will be used by the
next patch.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 drivers/net/macvlan.c               |    2 +-
 include/net/ip.h                    |   10 +++++---
 net/ipv4/ip_fragment.c              |   46 +++++++++++++++++++++++++----------
 net/ipv4/ip_input.c                 |    5 ++--
 net/ipv4/netfilter/nf_defrag_ipv4.c |    2 +-
 net/netfilter/ipvs/ip_vs_core.c     |    2 +-
 net/packet/af_packet.c              |    2 +-
 7 files changed, 47 insertions(+), 22 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1df38bd..eb978e4 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -412,7 +412,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 
 	port = macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
+		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN, NULL);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
 		eth = eth_hdr(skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index e73ac20..5035deb 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -494,11 +494,15 @@ enum ip_defrag_users {
 	IP_DEFRAG_MACVLAN,
 };
 
-int ip_defrag(struct sk_buff *skb, u32 user);
+int ip_defrag_net(struct net *net, struct sk_buff *skb, u32 user,
+		  unsigned int *mru);
+int ip_defrag(struct sk_buff *skb, u32 user, unsigned int *mru);
 #ifdef CONFIG_INET
-struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user);
+struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user,
+				unsigned int *mru);
 #else
-static inline struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
+static inline struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user,
+					      unsigned int *mru)
 {
 	return skb;
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index e5b6d0d..313ca80 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -77,6 +77,7 @@ struct ipq {
 	u8		ecn; /* RFC3168 support */
 	int             iif;
 	unsigned int    rid;
+	unsigned int    mru; /* Maximum received packet fragment size */
 	struct inet_peer *peer;
 };
 
@@ -138,6 +139,7 @@ static void ip4_frag_init(struct inet_frag_queue *q, const void *a)
 
 	const struct ip4_create_arg *arg = a;
 
+	qp->mru = 0;
 	qp->protocol = arg->iph->protocol;
 	qp->id = arg->iph->id;
 	qp->ecn = ip4_frag_ecn(arg->iph->tos);
@@ -315,7 +317,7 @@ static int ip_frag_reinit(struct ipq *qp)
 }
 
 /* Add new segment to existing queue. */
-static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
+static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb, unsigned int *mru)
 {
 	struct sk_buff *prev, *next;
 	struct net_device *dev;
@@ -323,6 +325,7 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	int ihl, end;
 	int err = -ENOENT;
 	u8 ecn;
+	unsigned int len = skb->len;
 
 	if (qp->q.flags & INET_FRAG_COMPLETE)
 		goto err;
@@ -396,6 +399,12 @@ static int ip_frag_queue(struct ipq *qp, struct sk_buff *skb)
 	}
 
 found:
+	/* Maintain maximum received unit size of all the fragments we
+	 * have seen so far.
+	 */
+	if (len > qp->mru)
+		qp->mru = len;
+
 	/* We found where to put this one.  Check for overlap with
 	 * preceding fragment, and, if needed, align things so that
 	 * any overlaps are eliminated.
@@ -485,6 +494,8 @@ found:
 		skb->_skb_refdst = 0UL;
 		err = ip_frag_reasm(qp, prev, dev);
 		skb->_skb_refdst = orefdst;
+		if (!err && mru)
+			*mru = qp->mru;
 		return err;
 	}
 
@@ -628,39 +639,48 @@ out_fail:
 	return err;
 }
 
-/* Process an incoming IP datagram fragment. */
-int ip_defrag(struct sk_buff *skb, u32 user)
+int ip_defrag_net(struct net *net, struct sk_buff *skb, u32 user,
+		  unsigned int *mru)
 {
 	struct ipq *qp;
-	struct net *net;
 
-	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
-
-	/* Lookup (or create) queue header */
 	if ((qp = ip_find(net, ip_hdr(skb), user)) != NULL) {
 		int ret;
 
 		spin_lock(&qp->q.lock);
-
-		ret = ip_frag_queue(qp, skb);
-
+		ret = ip_frag_queue(qp, skb, mru);
 		spin_unlock(&qp->q.lock);
+
 		ipq_put(qp);
 		return ret;
 	}
-
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMFAILS);
 	kfree_skb(skb);
 	return -ENOMEM;
 }
+EXPORT_SYMBOL(ip_defrag_net);
+
+/* Process an incoming IP datagram fragment. */
+int ip_defrag(struct sk_buff *skb, u32 user, unsigned int *mru)
+{
+	struct net *net;
+
+	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
+
+	return ip_defrag_net(net, skb, user, mru);
+}
 EXPORT_SYMBOL(ip_defrag);
 
-struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
+struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user,
+				unsigned int *mru)
 {
 	struct iphdr iph;
 	u32 len;
 
+	if (mru)
+		*mru = 0;
+
 	if (skb->protocol != htons(ETH_P_IP))
 		return skb;
 
@@ -682,7 +702,7 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 			if (pskb_trim_rcsum(skb, len))
 				return skb;
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-			if (ip_defrag(skb, user))
+			if (ip_defrag(skb, user, mru))
 				return NULL;
 			skb_clear_hash(skb);
 		}
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 3d4da2c..d59e3f6 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -168,7 +168,8 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 		     sk->sk_bound_dev_if == dev->ifindex) &&
 		    net_eq(sock_net(sk), dev_net(dev))) {
 			if (ip_is_fragment(ip_hdr(skb))) {
-				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
+				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN,
+					      NULL))
 					return true;
 			}
 			if (last) {
@@ -249,7 +250,7 @@ int ip_local_deliver(struct sk_buff *skb)
 	 */
 
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER))
+		if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER, NULL))
 			return 0;
 	}
 
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 7e5ca6f..8bbe4df 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -29,7 +29,7 @@ static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
 	skb_orphan(skb);
 
 	local_bh_disable();
-	err = ip_defrag(skb, user);
+	err = ip_defrag(skb, user, NULL);
 	local_bh_enable();
 
 	if (!err) {
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index b87ca32..dab1f3d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -651,7 +651,7 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 	int err;
 
 	local_bh_disable();
-	err = ip_defrag(skb, user);
+	err = ip_defrag(skb, user, NULL);
 	local_bh_enable();
 	if (!err)
 		ip_send_check(ip_hdr(skb));
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 9db8369..0d8a8d2 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1359,7 +1359,7 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 	case PACKET_FANOUT_HASH:
 	default:
 		if (fanout_has_flag(f, PACKET_FANOUT_FLAG_DEFRAG)) {
-			skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
+			skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET, NULL);
 			if (!skb)
 				return 0;
 		}
-- 
1.7.10.4
