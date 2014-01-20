From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V5 net-next 1/3] net: Add GRO support for UDP encapsulating protocols
Date: Mon, 20 Jan 2014 13:59:19 +0200
Message-ID: <1390219161-9881-2-git-send-email-ogerlitz@mellanox.com>
References: <1390219161-9881-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, hkchu@google.com, edumazet@google.com,
	herbert@gondor.apana.org.au, yanb@mellanox.com,
	shlomop@mellanox.com, therbert@google.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41587 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750773AbaATL7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jan 2014 06:59:30 -0500
In-Reply-To: <1390219161-9881-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GRO handlers for protocols that do UDP encapsulation, with the intent of
being able to coalesce packets which encapsulate packets belonging to
the same TCP session.

For GRO purposes, the destination UDP port takes the role of the ether type
field in the ethernet header or the next protocol in the IP header.

The UDP GRO handler will only attempt to coalesce packets whose destination
port is registered to have gro handler.

Use a mark on the skb GRO CB data to disallow (flush) running the udp gro receive
code twice on a packet. This solves the problem of udp encapsulated packets whose
inner VM packet is udp and happen to carry a port which has registered offloads.

Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/netdevice.h |   10 +++-
 include/net/protocol.h    |    3 +
 net/core/dev.c            |    1 +
 net/ipv4/udp_offload.c    |  143 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 156 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 83ce2ae..c310229 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1675,7 +1675,10 @@ struct napi_gro_cb {
 	unsigned long age;
 
 	/* Used in ipv6_gro_receive() */
-	int	proto;
+	u16	proto;
+
+	/* Used in udp_gro_receive */
+	u16	udp_mark;
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
@@ -1714,6 +1717,11 @@ struct packet_offload {
 	struct list_head	 list;
 };
 
+struct udp_offload {
+	__be16			 port;
+	struct offload_callbacks callbacks;
+};
+
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_sw_netstats {
 	u64     rx_packets;
diff --git a/include/net/protocol.h b/include/net/protocol.h
index 0e5f866..a7e986b 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -108,6 +108,9 @@ int inet_del_offload(const struct net_offload *prot, unsigned char num);
 void inet_register_protosw(struct inet_protosw *p);
 void inet_unregister_protosw(struct inet_protosw *p);
 
+int  udp_add_offload(struct udp_offload *prot);
+void udp_del_offload(struct udp_offload *prot);
+
 #if IS_ENABLED(CONFIG_IPV6)
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
 int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
diff --git a/net/core/dev.c b/net/core/dev.c
index fb99f64..1578fd7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3893,6 +3893,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->same_flow = 0;
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
+		NAPI_GRO_CB(skb)->udp_mark = 0;
 
 		pp = ptype->callbacks.gro_receive(&napi->gro_list, skb);
 		break;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 79c62bd..ee853c5 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -14,6 +14,15 @@
 #include <net/udp.h>
 #include <net/protocol.h>
 
+static DEFINE_SPINLOCK(udp_offload_lock);
+static struct udp_offload_priv *udp_offload_base __read_mostly;
+
+struct udp_offload_priv {
+	struct udp_offload	*offload;
+	struct rcu_head		rcu;
+	struct udp_offload_priv __rcu *next;
+};
+
 static int udp4_ufo_send_check(struct sk_buff *skb)
 {
 	if (!pskb_may_pull(skb, sizeof(struct udphdr)))
@@ -89,10 +98,144 @@ out:
 	return segs;
 }
 
+int udp_add_offload(struct udp_offload *uo)
+{
+	struct udp_offload_priv **head = &udp_offload_base;
+	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_KERNEL);
+
+	if (!new_offload)
+		return -ENOMEM;
+
+	new_offload->offload = uo;
+
+	spin_lock(&udp_offload_lock);
+	rcu_assign_pointer(new_offload->next, rcu_dereference(*head));
+	rcu_assign_pointer(*head, rcu_dereference(new_offload));
+	spin_unlock(&udp_offload_lock);
+
+	return 0;
+}
+EXPORT_SYMBOL(udp_add_offload);
+
+static void udp_offload_free_routine(struct rcu_head *head)
+{
+	struct udp_offload_priv *ou_priv = container_of(head, struct udp_offload_priv, rcu);
+	kfree(ou_priv);
+}
+
+void udp_del_offload(struct udp_offload *uo)
+{
+	struct udp_offload_priv __rcu **head = &udp_offload_base;
+	struct udp_offload_priv *uo_priv;
+
+	spin_lock(&udp_offload_lock);
+
+	uo_priv = rcu_dereference(*head);
+	for (; uo_priv != NULL;
+		uo_priv = rcu_dereference(*head)) {
+
+		if (uo_priv->offload == uo) {
+			rcu_assign_pointer(*head, rcu_dereference(uo_priv->next));
+			goto unlock;
+		}
+		head = &uo_priv->next;
+	}
+	pr_warn("udp_del_offload: didn't find offload for port %d\n", htons(uo->port));
+unlock:
+	spin_unlock(&udp_offload_lock);
+	if (uo_priv != NULL)
+		call_rcu(&uo_priv->rcu, udp_offload_free_routine);
+}
+EXPORT_SYMBOL(udp_del_offload);
+
+static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct udp_offload_priv *uo_priv;
+	struct sk_buff *p, **pp = NULL;
+	struct udphdr *uh, *uh2;
+	unsigned int hlen, off;
+	int flush = 1;
+
+	if (NAPI_GRO_CB(skb)->udp_mark ||
+	    (!skb->encapsulation && skb->ip_summed != CHECKSUM_COMPLETE))
+		goto out;
+
+	/* mark that this skb passed once through the udp gro layer */
+	NAPI_GRO_CB(skb)->udp_mark = 1;
+
+	off  = skb_gro_offset(skb);
+	hlen = off + sizeof(*uh);
+	uh   = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, hlen)) {
+		uh = skb_gro_header_slow(skb, hlen, off);
+		if (unlikely(!uh))
+			goto out;
+	}
+
+	rcu_read_lock();
+	uo_priv = rcu_dereference(udp_offload_base);
+	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
+		if (uo_priv->offload->port == uh->dest &&
+		    uo_priv->offload->callbacks.gro_receive)
+			goto unflush;
+	}
+	goto out_unlock;
+
+unflush:
+	flush = 0;
+
+	for (p = *head; p; p = p->next) {
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		uh2 = (struct udphdr   *)(p->data + off);
+		if ((*(u32 *)&uh->source != *(u32 *)&uh2->source)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+	}
+
+	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
+	pp = uo_priv->offload->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+	return pp;
+}
+
+static int udp_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct udp_offload_priv *uo_priv;
+	__be16 newlen = htons(skb->len - nhoff);
+	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
+	int err = -ENOSYS;
+
+	uh->len = newlen;
+
+	rcu_read_lock();
+
+	uo_priv = rcu_dereference(udp_offload_base);
+	for (; uo_priv != NULL; uo_priv = rcu_dereference(uo_priv->next)) {
+		if (uo_priv->offload->port == uh->dest &&
+		    uo_priv->offload->callbacks.gro_complete)
+			break;
+	}
+
+	if (uo_priv != NULL)
+		err = uo_priv->offload->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr));
+
+	rcu_read_unlock();
+	return err;
+}
+
 static const struct net_offload udpv4_offload = {
 	.callbacks = {
 		.gso_send_check = udp4_ufo_send_check,
 		.gso_segment = udp4_ufo_fragment,
+		.gro_receive  =	udp_gro_receive,
+		.gro_complete =	udp_gro_complete,
 	},
 };
 
-- 
1.7.1
