From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 net-next 3/7] fou: Add GRO support
Date: Mon, 15 Sep 2014 20:30:20 -0700
Message-ID: <1410838224-19777-4-git-send-email-therbert@google.com>
References: <1410838224-19777-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:51377 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbaIPDaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 23:30:55 -0400
Received: by mail-pd0-f173.google.com with SMTP id ft15so7774375pdb.4
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 20:30:55 -0700 (PDT)
In-Reply-To: <1410838224-19777-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement fou_gro_receive and fou_gro_complete, and populate these
in the correponsing udp_offloads for the socket. Added ipproto to
udp_offloads and pass this from UDP to the fou GRO routine in proto
field of napi_gro_cb structure.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  3 +-
 net/ipv4/fou.c            | 89 +++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp_offload.c    |  5 ++-
 3 files changed, 95 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f9e81d1..d380574 100644
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
index de2af74..ac430d1 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -8,6 +8,7 @@
 #include <linux/kernel.h>
 #include <net/genetlink.h>
 #include <net/ip.h>
+#include <net/protocol.h>
 #include <net/udp.h>
 #include <net/udp_tunnel.h>
 #include <net/xfrm.h>
@@ -21,6 +22,7 @@ struct fou {
 	struct socket *sock;
 	u8 protocol;
 	u16 port;
+	struct udp_offload udp_offloads;
 	struct list_head list;
 };
 
@@ -62,6 +64,69 @@ static int fou_udp_recv(struct sock *sk, struct sk_buff *skb)
 					  sizeof(struct udphdr));
 }
 
+static struct sk_buff **fou_gro_receive(struct sk_buff **head,
+					struct sk_buff *skb,
+					const struct net_offload **offloads)
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
+static int fou_gro_complete(struct sk_buff *skb, int nhoff,
+			    const struct net_offload **offloads)
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
@@ -134,6 +199,29 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
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
@@ -160,6 +248,7 @@ static int fou_destroy(struct net *net, struct fou_cfg *cfg)
 	spin_lock(&fou_lock);
 	list_for_each_entry(fou, &fou_list, list) {
 		if (fou->port == port) {
+			udp_del_offload(&fou->udp_offloads);
 			fou_release(fou);
 			err = 0;
 			break;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index adab393..d7c43f7 100644
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
