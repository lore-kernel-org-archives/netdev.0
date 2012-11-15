From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 05/14] ipv4: Switch to using the new offload infrastructure.
Date: Thu, 15 Nov 2012 13:49:14 -0500
Message-ID: <1353005363-6974-6-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50887 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768708Ab2KOStd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:33 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch IPv4 code base to using the new GRO/GSO calls and data.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/net/protocol.h |    6 ------
 net/ipv4/af_inet.c     |   30 ++++++++++++++++--------------
 2 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 637e1bb..3bb7051 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -40,12 +40,6 @@ struct net_protocol {
 	void			(*early_demux)(struct sk_buff *skb);
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
-	int			(*gso_send_check)(struct sk_buff *skb);
-	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
-					       netdev_features_t features);
-	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
-					       struct sk_buff *skb);
-	int			(*gro_complete)(struct sk_buff *skb);
 	unsigned int		no_policy:1,
 				netns_ok:1;
 };
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 3918d86..66f63ce 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1251,7 +1251,7 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
 
 static int inet_gso_send_check(struct sk_buff *skb)
 {
-	const struct net_protocol *ops;
+	const struct net_offload *ops;
 	const struct iphdr *iph;
 	int proto;
 	int ihl;
@@ -1275,7 +1275,7 @@ static int inet_gso_send_check(struct sk_buff *skb)
 	err = -EPROTONOSUPPORT;
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet_protos[proto]);
+	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->gso_send_check))
 		err = ops->gso_send_check(skb);
 	rcu_read_unlock();
@@ -1288,7 +1288,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	const struct net_protocol *ops;
+	const struct net_offload *ops;
 	struct iphdr *iph;
 	int proto;
 	int ihl;
@@ -1325,7 +1325,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet_protos[proto]);
+	ops = rcu_dereference(inet_offloads[proto]);
 	if (likely(ops && ops->gso_segment))
 		segs = ops->gso_segment(skb, features);
 	rcu_read_unlock();
@@ -1356,7 +1356,7 @@ out:
 static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
-	const struct net_protocol *ops;
+	const struct net_offload *ops;
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
 	const struct iphdr *iph;
@@ -1378,7 +1378,7 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 	proto = iph->protocol;
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet_protos[proto]);
+	ops = rcu_dereference(inet_offloads[proto]);
 	if (!ops || !ops->gro_receive)
 		goto out_unlock;
 
@@ -1435,7 +1435,7 @@ static int inet_gro_complete(struct sk_buff *skb)
 {
 	__be16 newlen = htons(skb->len - skb_network_offset(skb));
 	struct iphdr *iph = ip_hdr(skb);
-	const struct net_protocol *ops;
+	const struct net_offload *ops;
 	int proto = iph->protocol;
 	int err = -ENOSYS;
 
@@ -1443,7 +1443,7 @@ static int inet_gro_complete(struct sk_buff *skb)
 	iph->tot_len = newlen;
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet_protos[proto]);
+	ops = rcu_dereference(inet_offloads[proto]);
 	if (WARN_ON(!ops || !ops->gro_complete))
 		goto out_unlock;
 
@@ -1558,10 +1558,6 @@ static const struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
 	.handler	=	tcp_v4_rcv,
 	.err_handler	=	tcp_v4_err,
-	.gso_send_check	=	tcp_v4_gso_send_check,
-	.gso_segment	=	tcp_tso_segment,
-	.gro_receive	=	tcp4_gro_receive,
-	.gro_complete	=	tcp4_gro_complete,
 	.no_policy	=	1,
 	.netns_ok	=	1,
 };
@@ -1576,8 +1572,6 @@ static const struct net_offload tcp_offload = {
 static const struct net_protocol udp_protocol = {
 	.handler =	udp_rcv,
 	.err_handler =	udp_err,
-	.gso_send_check = udp4_ufo_send_check,
-	.gso_segment = udp4_ufo_fragment,
 	.no_policy =	1,
 	.netns_ok =	1,
 };
@@ -1726,6 +1720,14 @@ static int __init inet_init(void)
 	tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
 
 	/*
+	 * Add offloads
+	 */
+	if (inet_add_offload(&udp_offload, IPPROTO_UDP) < 0)
+		pr_crit("%s: Cannot add UDP protocol offload\n", __func__);
+	if (inet_add_offload(&tcp_offload, IPPROTO_TCP) < 0)
+		pr_crit("%s: Cannot add TCP protocol offlaod\n", __func__);
+
+	/*
 	 *	Add all the base protocols.
 	 */
 
-- 
1.7.7.6
