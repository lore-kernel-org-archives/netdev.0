From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 8/8] udp: Remove udp_offloads
Date: Tue, 5 Apr 2016 08:22:56 -0700
Message-ID: <1459869776-2090500-9-git-send-email-tom@herbertland.com>
References: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37567 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758973AbcDEPXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:23:20 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u35FMLJf017959
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:23:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22483hakgk-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:23:19 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 528890e2fb4211e5b9fc24be05956610-e6fc13f0 for <netdev@vger.kernel.org>;	Tue,
 05 Apr 2016 08:23:17 -0700
In-Reply-To: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the UDP encapsulation GRO functions have been moved to the UDP
socket we not longer need the udp_offload insfrastructure so removing it.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h | 17 -------------
 include/net/protocol.h    |  3 ---
 net/ipv4/udp_offload.c    | 63 -----------------------------------------------
 3 files changed, 83 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb0d5d0..cb4e508 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2159,23 +2159,6 @@ struct packet_offload {
 	struct list_head	 list;
 };
 
-struct udp_offload;
-
-struct udp_offload_callbacks {
-	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
-						 struct sk_buff *skb,
-						 struct udp_offload *uoff);
-	int			(*gro_complete)(struct sk_buff *skb,
-						int nhoff,
-						struct udp_offload *uoff);
-};
-
-struct udp_offload {
-	__be16			 port;
-	u8			 ipproto;
-	struct udp_offload_callbacks callbacks;
-};
-
 /* often modified stats are per-CPU, other are shared (netdev->stats) */
 struct pcpu_sw_netstats {
 	u64     rx_packets;
diff --git a/include/net/protocol.h b/include/net/protocol.h
index da689f5..bf36ca3 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -107,9 +107,6 @@ int inet_del_offload(const struct net_offload *prot, unsigned char num);
 void inet_register_protosw(struct inet_protosw *p);
 void inet_unregister_protosw(struct inet_protosw *p);
 
-int  udp_add_offload(struct net *net, struct udp_offload *prot);
-void udp_del_offload(struct udp_offload *prot);
-
 #if IS_ENABLED(CONFIG_IPV6)
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
 int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 65c3fd3..6230cf4 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -14,18 +14,6 @@
 #include <net/udp.h>
 #include <net/protocol.h>
 
-static DEFINE_SPINLOCK(udp_offload_lock);
-static struct udp_offload_priv __rcu *udp_offload_base __read_mostly;
-
-#define udp_deref_protected(X) rcu_dereference_protected(X, lockdep_is_held(&udp_offload_lock))
-
-struct udp_offload_priv {
-	struct udp_offload	*offload;
-	possible_net_t	net;
-	struct rcu_head		rcu;
-	struct udp_offload_priv __rcu *next;
-};
-
 static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	netdev_features_t features,
 	struct sk_buff *(*gso_inner_segment)(struct sk_buff *skb,
@@ -254,56 +242,6 @@ out:
 	return segs;
 }
 
-int udp_add_offload(struct net *net, struct udp_offload *uo)
-{
-	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_ATOMIC);
-
-	if (!new_offload)
-		return -ENOMEM;
-
-	write_pnet(&new_offload->net, net);
-	new_offload->offload = uo;
-
-	spin_lock(&udp_offload_lock);
-	new_offload->next = udp_offload_base;
-	rcu_assign_pointer(udp_offload_base, new_offload);
-	spin_unlock(&udp_offload_lock);
-
-	return 0;
-}
-EXPORT_SYMBOL(udp_add_offload);
-
-static void udp_offload_free_routine(struct rcu_head *head)
-{
-	struct udp_offload_priv *ou_priv = container_of(head, struct udp_offload_priv, rcu);
-	kfree(ou_priv);
-}
-
-void udp_del_offload(struct udp_offload *uo)
-{
-	struct udp_offload_priv __rcu **head = &udp_offload_base;
-	struct udp_offload_priv *uo_priv;
-
-	spin_lock(&udp_offload_lock);
-
-	uo_priv = udp_deref_protected(*head);
-	for (; uo_priv != NULL;
-	     uo_priv = udp_deref_protected(*head)) {
-		if (uo_priv->offload == uo) {
-			rcu_assign_pointer(*head,
-					   udp_deref_protected(uo_priv->next));
-			goto unlock;
-		}
-		head = &uo_priv->next;
-	}
-	pr_warn("udp_del_offload: didn't find offload for port %d\n", ntohs(uo->port));
-unlock:
-	spin_unlock(&udp_offload_lock);
-	if (uo_priv)
-		call_rcu(&uo_priv->rcu, udp_offload_free_routine);
-}
-EXPORT_SYMBOL(udp_del_offload);
-
 struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 				 struct udphdr *uh, udp_lookup_t lookup)
 {
@@ -327,7 +265,6 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 
 	if (sk && udp_sk(sk)->gro_receive)
 		goto unflush;
-
 	goto out_unlock;
 
 unflush:
-- 
2.8.0.rc2
