From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/8] ipv4: Add GRO infrastructure
Date: Fri, 12 Dec 2008 16:31:52 +1100
Message-ID: <E1LB0cy-0000rD-Pr@gondolin.me.apana.org.au>
References: <20081212053116.GA2927@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59003 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756743AbYLLFb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:31:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv4: Add GRO infrastructure

This patch adds GRO support for IPv4.

The criteria for merging is more stringent than LRO, in particular,
we require all fields in the IP header to be identical except for
the length, ID and checksum.  In addition, the ID must form an
arithmetic sequence with a difference of one.

The ID requirement might seem overly strict, however, most hardware
TSO solutions already obey this rule.  Linux itself also obeys this
whether GSO is in use or not.

In future we could relax this rule by storing the IDs (or rather
making sure that we don't drop them when pulling the aggregate
skb's tail).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/protocol.h |    3 +
 net/ipv4/af_inet.c     |   96 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 99 insertions(+)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 8d024d7..cb2965a 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -39,6 +39,9 @@ struct net_protocol {
 	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
 					       int features);
+	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
+					       struct sk_buff *skb);
+	int			(*gro_complete)(struct sk_buff *skb);
 	unsigned int		no_policy:1,
 				netns_ok:1;
 };
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 1aa2dc9..260f081 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -94,6 +94,7 @@
 #include <linux/igmp.h>
 #include <linux/inetdevice.h>
 #include <linux/netdevice.h>
+#include <net/checksum.h>
 #include <net/ip.h>
 #include <net/protocol.h>
 #include <net/arp.h>
@@ -1245,6 +1246,99 @@ out:
 	return segs;
 }
 
+static struct sk_buff **inet_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	struct net_protocol *ops;
+	struct sk_buff **pp = NULL;
+	struct sk_buff *p;
+	struct iphdr *iph;
+	int flush = 1;
+	int proto;
+	int id;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
+		goto out;
+
+	iph = ip_hdr(skb);
+	proto = iph->protocol & (MAX_INET_PROTOS - 1);
+
+	rcu_read_lock();
+	ops = rcu_dereference(inet_protos[proto]);
+	if (!ops || !ops->gro_receive)
+		goto out_unlock;
+
+	if (iph->version != 4 || iph->ihl != 5)
+		goto out_unlock;
+
+	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
+		goto out_unlock;
+
+	flush = ntohs(iph->tot_len) != skb->len ||
+		iph->frag_off != htons(IP_DF);
+	id = ntohs(iph->id);
+
+	for (p = *head; p; p = p->next) {
+		struct iphdr *iph2;
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		iph2 = ip_hdr(p);
+
+		if (iph->protocol != iph2->protocol ||
+		    memcmp(&iph->saddr, &iph2->saddr, 8)) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+
+		/* All fields must match except length and checksum. */
+		NAPI_GRO_CB(p)->flush |=
+			memcmp(&iph->frag_off, &iph2->frag_off, 4) ||
+			(u16)(ntohs(iph2->id) + NAPI_GRO_CB(p)->count) != id;
+
+		NAPI_GRO_CB(p)->flush |= flush;
+	}
+
+	NAPI_GRO_CB(skb)->flush |= flush;
+	__skb_pull(skb, sizeof(*iph));
+	skb_reset_transport_header(skb);
+
+	pp = ops->gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int inet_gro_complete(struct sk_buff *skb)
+{
+	struct net_protocol *ops;
+	struct iphdr *iph = ip_hdr(skb);
+	int proto = iph->protocol & (MAX_INET_PROTOS - 1);
+	int err = -ENOSYS;
+	__be16 newlen = htons(skb->len - skb_network_offset(skb));
+
+	csum_replace2(&iph->check, iph->tot_len, newlen);
+	iph->tot_len = newlen;
+
+	rcu_read_lock();
+	ops = rcu_dereference(inet_protos[proto]);
+	if (WARN_ON(!ops || !ops->gro_complete))
+		goto out_unlock;
+
+	err = ops->gro_complete(skb);
+
+out_unlock:
+	rcu_read_unlock();
+
+	return err;
+}
+
 int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 			 unsigned short type, unsigned char protocol,
 			 struct net *net)
@@ -1411,6 +1505,8 @@ static struct packet_type ip_packet_type = {
 	.func = ip_rcv,
 	.gso_send_check = inet_gso_send_check,
 	.gso_segment = inet_gso_segment,
+	.gro_receive = inet_gro_receive,
+	.gro_complete = inet_gro_complete,
 };
 
 static int __init inet_init(void)
