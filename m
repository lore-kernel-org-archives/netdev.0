From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 1/3] net: Add GRO support for UDP encapsulating protocols
Date: Wed,  8 Jan 2014 22:34:36 +0200
Message-ID: <1389213278-2200-2-git-send-email-ogerlitz@mellanox.com>
References: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net, yanb@mellanox.com,
	shlomop@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: hkchu@google.com, edumazet@google.com, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52844 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757253AbaAHUeu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 15:34:50 -0500
In-Reply-To: <1389213278-2200-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add GRO handlers for protocols that do UDP encapsulation, with the intent of
being able to coalesce packets which encapsulate packets belonging to
the same TCP session.

For GRO purposes, the destination UDP port takes the role of the ether type
field in the ethernet header or the next protocol in the IP header.

The UDP GRO handler will only attempt to coalesce packets whose destination
port is registered to have gro handler.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/netdevice.h |   10 +++-
 include/net/protocol.h    |    3 +
 net/core/dev.c            |    1 +
 net/ipv4/udp_offload.c    |  129 +++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 142 insertions(+), 1 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a2a70cc..360551a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1652,7 +1652,9 @@ struct napi_gro_cb {
 	unsigned long age;
 
 	/* Used in ipv6_gro_receive() */
-	int	proto;
+	u16	proto;
+
+	u16	udp_mark;
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
@@ -1691,6 +1693,12 @@ struct packet_offload {
 	struct list_head	 list;
 };
 
+struct udp_offload {
+	__be16			 port;
+	struct offload_callbacks callbacks;
+	struct list_head	 list;
+};
+
 /* often modified stats are per cpu, other are shared (netdev->stats) */
 struct pcpu_sw_netstats {
 	u64     rx_packets;
diff --git a/include/net/protocol.h b/include/net/protocol.h
index fbf7676..fe9af94 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -103,6 +103,9 @@ int inet_del_offload(const struct net_offload *prot, unsigned char num);
 void inet_register_protosw(struct inet_protosw *p);
 void inet_unregister_protosw(struct inet_protosw *p);
 
+void udp_add_offload(struct udp_offload *prot);
+void udp_del_offload(struct udp_offload *prot);
+
 #if IS_ENABLED(CONFIG_IPV6)
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char num);
 int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char num);
diff --git a/net/core/dev.c b/net/core/dev.c
index ce01847..11f7acf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3858,6 +3858,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->same_flow = 0;
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
+		NAPI_GRO_CB(skb)->udp_mark = 0;
 
 		pp = ptype->callbacks.gro_receive(&napi->gro_list, skb);
 		break;
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 79c62bd..2846ade 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -13,6 +13,16 @@
 #include <linux/skbuff.h>
 #include <net/udp.h>
 #include <net/protocol.h>
+/*
+struct udp_offload {
+	__be16			 port;
+	struct offload_callbacks callbacks;
+	struct list_head	 list;
+};
+*/
+
+static DEFINE_SPINLOCK(udp_offload_lock);
+static struct list_head udp_offload_base __read_mostly;
 
 static int udp4_ufo_send_check(struct sk_buff *skb)
 {
@@ -89,14 +99,133 @@ out:
 	return segs;
 }
 
+void udp_add_offload(struct udp_offload *uo)
+{
+	struct list_head *head = &udp_offload_base;
+
+	spin_lock(&udp_offload_lock);
+	list_add_rcu(&uo->list, head);
+	spin_unlock(&udp_offload_lock);
+}
+EXPORT_SYMBOL(udp_add_offload);
+
+void udp_del_offload(struct udp_offload *uo)
+{
+	struct list_head *head = &udp_offload_base;
+	struct udp_offload *uo1;
+
+	spin_lock(&udp_offload_lock);
+	list_for_each_entry(uo1, head, list) {
+		if (uo == uo1) {
+			list_del_rcu(&uo->list);
+			goto out;
+		}
+	}
+
+	pr_warn("udp_remove_offload: %p not found port %d\n", uo, htons(uo->port));
+out:
+	spin_unlock(&udp_offload_lock);
+
+	synchronize_net();
+}
+EXPORT_SYMBOL(udp_del_offload);
+
+static struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb)
+{
+	struct list_head *ohead = &udp_offload_base;
+	struct udp_offload *poffload;
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
+	list_for_each_entry_rcu(poffload, ohead, list) {
+		if (poffload->port != uh->dest || !poffload->callbacks.gro_receive)
+			continue;
+		break;
+	}
+
+	if (&poffload->list == ohead)
+		goto out_unlock;
+
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
+		goto found;
+	}
+
+found:
+	skb_gro_pull(skb, sizeof(struct udphdr)); /* pull encapsulating udp header */
+	pp = poffload->callbacks.gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int udp_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct list_head *ohead = &udp_offload_base;
+	struct udp_offload *poffload;
+	__be16 newlen = htons(skb->len - nhoff);
+	struct udphdr *uh = (struct udphdr *)(skb->data + nhoff);
+	int err = -ENOSYS;
+
+	uh->len = newlen;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(poffload, ohead, list) {
+		if (poffload->port != uh->dest || !poffload->callbacks.gro_complete)
+			continue;
+		break;
+	}
+
+	if (&poffload->list != ohead)
+		err = poffload->callbacks.gro_complete(skb, nhoff + sizeof(struct udphdr));
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
 
 int __init udpv4_offload_init(void)
 {
+	INIT_LIST_HEAD(&udp_offload_base);
 	return inet_add_offload(&udpv4_offload, IPPROTO_UDP);
 }
-- 
1.7.1
