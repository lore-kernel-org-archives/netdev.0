From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/7] fou: Add GRO support
Date: Thu, 11 Sep 2014 13:07:32 -0700
Message-ID: <1410466056-30239-4-git-send-email-therbert@google.com>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:63862 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbaIKUIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 16:08:11 -0400
Received: by mail-pa0-f54.google.com with SMTP id lj1so11439997pab.13
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 13:08:10 -0700 (PDT)
In-Reply-To: <1410466056-30239-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement fou_gro_receive and fou_gro_complete, and populate these
in the corresponding udp_offloads for the socket. Added ipproto to
udp_offloads and pass this from UDP to the fou GRO routine in proto
field of napi_gro_cb structure.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  3 +-
 net/ipv4/fou.c            | 92 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp_offload.c    |  5 ++-
 3 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ba72f6b..a195e11 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1874,7 +1874,7 @@ struct napi_gro_cb {
 	/* jiffies when first packet was created/queued */
 	unsigned long age;
 
-	/* Used in ipv6_gro_receive() */
+	/* Used in ipv6_gro_receive() and foo-over-udp */
 	u16	proto;
 
 	/* Used in udp_gro_receive */
@@ -1925,6 +1925,7 @@ struct packet_offload {
 
 struct udp_offload {
 	__be16			 port;
+	u8			 ipproto;
 	struct offload_callbacks callbacks;
 };
 
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index f69df75..41b692c 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -9,6 +9,7 @@
 #include <net/fou.h>
 #include <net/genetlink.h>
 #include <net/ip.h>
+#include <net/protocol.h>
 #include <net/udp.h>
 #include <net/xfrm.h>
 #include <uapi/linux/fou.h>
@@ -21,6 +22,7 @@ struct fou {
 	struct socket *sock;
 	u8 protocol;
 	u16 port;
+	struct udp_offload udp_offloads;
 	struct list_head list;
 };
 
@@ -57,6 +59,70 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 					  sizeof(struct udphdr));
 }
 
+static inline struct sk_buff **fou_gro_receive(struct sk_buff **head,
+					       struct sk_buff *skb,
+					       const struct net_offload
+							     **offloads)
+{
+	const struct net_offload *ops;
+	struct sk_buff **pp = NULL;
+	u8 proto = NAPI_GRO_CB(skb)->proto;
+
+	rcu_read_lock();
+	ops = rcu_dereference(offloads[proto]);
+	if (!ops || !ops->callbacks.gro_receive)
+		goto out_unlock;
+
+	pp = ops->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+
+	return pp;
+}
+
+static inline int fou_gro_complete(struct sk_buff *skb, int nhoff,
+				   const struct net_offload **offloads)
+{
+	const struct net_offload *ops;
+	u8 proto = NAPI_GRO_CB(skb)->proto;
+	int err = -ENOSYS;
+
+	rcu_read_lock();
+	ops = rcu_dereference(offloads[proto]);
+	if (WARN_ON(!ops || !ops->callbacks.gro_complete))
+		goto out_unlock;
+
+	err = ops->callbacks.gro_complete(skb, nhoff);
+
+out_unlock:
+	rcu_read_unlock();
+
+	return err;
+}
+
+static struct sk_buff **fou4_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	return fou_gro_receive(head, skb, inet_offloads);
+}
+
+static int fou4_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	return fou_gro_complete(skb, nhoff, inet_offloads);
+}
+
+static struct sk_buff **fou6_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	return fou_gro_receive(head, skb, inet6_offloads);
+}
+
+static int fou6_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	return fou_gro_complete(skb, nhoff, inet6_offloads);
+}
+
 static int fou_add_to_port_list(struct fou *fou)
 {
 	struct fou *fout;
@@ -129,6 +195,29 @@ int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	sk->sk_allocation = GFP_ATOMIC;
 
+	switch (cfg->udp_config.family) {
+	case AF_INET:
+		fou->udp_offloads.callbacks.gro_receive = fou4_gro_receive;
+		fou->udp_offloads.callbacks.gro_complete = fou4_gro_complete;
+		break;
+	case AF_INET6:
+		fou->udp_offloads.callbacks.gro_receive = fou6_gro_receive;
+		fou->udp_offloads.callbacks.gro_complete = fou6_gro_complete;
+		break;
+	default:
+		err = -EPFNOSUPPORT;
+		goto error;
+	}
+
+	fou->udp_offloads.port = cfg->udp_config.local_udp_port;
+	fou->udp_offloads.ipproto = cfg->protocol;
+
+	if (cfg->udp_config.family == AF_INET) {
+		err = udp_add_offload(&fou->udp_offloads);
+		if (err)
+			goto error;
+	}
+
 	err = fou_add_to_port_list(fou);
 	if (err)
 		goto error;
@@ -156,6 +245,7 @@ int fou_destroy(struct net *net, struct fou_cfg *cfg)
 	spin_lock(&fou_lock);
 	list_for_each_entry(fou, &fou_list, list) {
 		if (fou->port == port) {
+			udp_del_offload(&fou->udp_offloads);
 			fou_release(fou);
 			err = 0;
 			break;
@@ -206,6 +296,8 @@ static int parse_nl_config(struct genl_info *info,
 
 	if (info->attrs[FOU_ATTR_IPPROTO])
 		cfg->protocol = nla_get_u8(info->attrs[FOU_ATTR_IPPROTO]);
+
+	return 0;
 }
 
 static int fou_nl_cmd_add_port(struct sk_buff *skb, struct genl_info *info)
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 52d5f46..18b7d69 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -276,6 +276,7 @@ unflush:
 
 	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
 	skb_gro_postpull_rcsum(skb, uh, sizeof(struct udphdr));
+	NAPI_GRO_CB(skb)->proto = uo_priv->offload->ipproto;
 	pp = uo_priv->offload->callbacks.gro_receive(head, skb);
 
 out_unlock:
@@ -329,8 +330,10 @@ int udp_gro_complete(struct sk_buff *skb, int nhoff)
 			break;
 	}
 
-	if (uo_priv != NULL)
+	if (uo_priv != NULL) {
+		NAPI_GRO_CB(skb)->proto = uo_priv->offload->ipproto;
 		err = uo_priv->offload->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr));
+	}
 
 	rcu_read_unlock();
 	return err;
-- 
2.1.0.rc2.206.gedb03e5
