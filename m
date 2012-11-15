From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH V2 02/14] net:  Switch to using the new packet offload infrustructure
Date: Thu, 15 Nov 2012 13:49:11 -0500
Message-ID: <1353005363-6974-3-git-send-email-vyasevic@redhat.com>
References: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24802 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768600Ab2KOSt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 13:49:28 -0500
In-Reply-To: <1353005363-6974-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to using the new GSO/GRO registration mechanism and new
packet offload structure.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/linux/netdevice.h |    6 ------
 net/core/dev.c            |   19 +++++++++----------
 net/ipv4/af_inet.c        |    5 +++++
 net/ipv6/af_inet6.c       |    6 ++++++
 4 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a896a47..12c217d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1499,12 +1499,6 @@ struct packet_type {
 					 struct net_device *,
 					 struct packet_type *,
 					 struct net_device *);
-	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
-						netdev_features_t features);
-	int			(*gso_send_check)(struct sk_buff *skb);
-	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
-					       struct sk_buff *skb);
-	int			(*gro_complete)(struct sk_buff *skb);
 	bool			(*id_match)(struct packet_type *ptype,
 					    struct sock *sk);
 	void			*af_packet_priv;
diff --git a/net/core/dev.c b/net/core/dev.c
index 10967e5..13f9b85 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2072,7 +2072,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
-	struct packet_type *ptype;
+	struct packet_offload *ptype;
 	__be16 type = skb->protocol;
 	int vlan_depth = ETH_HLEN;
 	int err;
@@ -2101,9 +2101,8 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 	}
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(ptype,
-			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
-		if (ptype->type == type && !ptype->dev && ptype->gso_segment) {
+	list_for_each_entry_rcu(ptype, &offload_base, list) {
+		if (ptype->type == type && ptype->gso_segment) {
 			if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
 				err = ptype->gso_send_check(skb);
 				segs = ERR_PTR(err);
@@ -3522,9 +3521,9 @@ static void flush_backlog(void *arg)
 
 static int napi_gro_complete(struct sk_buff *skb)
 {
-	struct packet_type *ptype;
+	struct packet_offload *ptype;
 	__be16 type = skb->protocol;
-	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
+	struct list_head *head = &offload_base;
 	int err = -ENOENT;
 
 	if (NAPI_GRO_CB(skb)->count == 1) {
@@ -3534,7 +3533,7 @@ static int napi_gro_complete(struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
-		if (ptype->type != type || ptype->dev || !ptype->gro_complete)
+		if (ptype->type != type || !ptype->gro_complete)
 			continue;
 
 		err = ptype->gro_complete(skb);
@@ -3584,9 +3583,9 @@ EXPORT_SYMBOL(napi_gro_flush);
 enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
-	struct packet_type *ptype;
+	struct packet_offload *ptype;
 	__be16 type = skb->protocol;
-	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
+	struct list_head *head = &offload_base;
 	int same_flow;
 	int mac_len;
 	enum gro_result ret;
@@ -3599,7 +3598,7 @@ enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
-		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
+		if (ptype->type != type || !ptype->gro_receive)
 			continue;
 
 		skb_set_network_header(skb, skb_gro_offset(skb));
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 766c596..4c99c5f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1662,6 +1662,10 @@ static int ipv4_proc_init(void);
 static struct packet_type ip_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
 	.func = ip_rcv,
+};
+
+static struct packet_offload ip_packet_offload __read_mostly = {
+	.type = cpu_to_be16(ETH_P_IP),
 	.gso_send_check = inet_gso_send_check,
 	.gso_segment = inet_gso_segment,
 	.gro_receive = inet_gro_receive,
@@ -1781,6 +1785,7 @@ static int __init inet_init(void)
 
 	ipfrag_init();
 
+	dev_add_offload(&ip_packet_offload);
 	dev_add_pack(&ip_packet_type);
 
 	rc = 0;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a974247..6e24517 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -938,6 +938,10 @@ out_unlock:
 static struct packet_type ipv6_packet_type __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
 	.func = ipv6_rcv,
+};
+
+static struct packet_offload ipv6_packet_offload __read_mostly = {
+	.type = cpu_to_be16(ETH_P_IPV6),
 	.gso_send_check = ipv6_gso_send_check,
 	.gso_segment = ipv6_gso_segment,
 	.gro_receive = ipv6_gro_receive,
@@ -946,6 +950,7 @@ static struct packet_type ipv6_packet_type __read_mostly = {
 
 static int __init ipv6_packet_init(void)
 {
+	dev_add_offload(&ipv6_packet_offload);
 	dev_add_pack(&ipv6_packet_type);
 	return 0;
 }
@@ -953,6 +958,7 @@ static int __init ipv6_packet_init(void)
 static void ipv6_packet_cleanup(void)
 {
 	dev_remove_pack(&ipv6_packet_type);
+	dev_remove_offload(&ipv6_packet_offload);
 }
 
 static int __net_init ipv6_init_mibs(struct net *net)
-- 
1.7.7.6
