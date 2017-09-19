From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 13/14] gtp: Support for GRO
Date: Mon, 18 Sep 2017 17:39:03 -0700
Message-ID: <20170919003904.5124-14-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:45201 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751541AbdISAkD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:40:03 -0400
Received: by mail-pf0-f173.google.com with SMTP id q76so1109936pfq.2
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:40:03 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Populate GRO receive and GRO complete functions for GTP-Uv0 and v1.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 204 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 204 insertions(+)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index b53946f8b10b..2f9d810cf19f 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -22,6 +22,7 @@
 #include <linux/jhash.h>
 #include <linux/if_tunnel.h>
 #include <linux/net.h>
+#include <linux/netdevice.h>
 #include <linux/file.h>
 #include <linux/gtp.h>
 
@@ -429,6 +430,205 @@ static int gtp1u_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	return 1;
 }
 
+static struct sk_buff **gtp_gro_receive_finish(struct sock *sk,
+					       struct sk_buff **head,
+					       struct sk_buff *skb,
+					       void *hdr, size_t hdrlen)
+{
+	const struct packet_offload *ptype;
+	struct sk_buff **pp;
+	__be16 type;
+
+	type = ipver_to_eth((struct iphdr *)((void *)hdr + hdrlen));
+	if (!type)
+		goto out_err;
+
+	rcu_read_lock();
+
+	ptype = gro_find_receive_by_type(type);
+	if (!ptype)
+		goto out_unlock_err;
+
+	skb_gro_pull(skb, hdrlen);
+	skb_gro_postpull_rcsum(skb, hdr, hdrlen);
+	pp = call_gro_receive(ptype->callbacks.gro_receive, head, skb);
+
+	rcu_read_unlock();
+
+	return pp;
+
+out_unlock_err:
+	rcu_read_unlock();
+out_err:
+	NAPI_GRO_CB(skb)->flush |= 1;
+	return NULL;
+}
+
+static struct sk_buff **gtp0_gro_receive(struct sock *sk,
+					 struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	struct gtp0_header *gtp0;
+	size_t len, hdrlen, off;
+	struct sk_buff *p;
+
+	off = skb_gro_offset(skb);
+	len = off + sizeof(*gtp0);
+	hdrlen = sizeof(*gtp0);
+
+	gtp0 = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, len)) {
+		gtp0 = skb_gro_header_slow(skb, len, off);
+		if (unlikely(!gtp0))
+			goto out;
+	}
+
+	if ((gtp0->flags >> 5) != GTP_V0 || gtp0->type != GTP_TPDU)
+		goto out;
+
+	hdrlen += sizeof(*gtp0);
+
+	/* To get IP version */
+	len += sizeof(struct iphdr);
+
+	/* Now get header with GTP header an IPv4 header (for version) */
+	if (skb_gro_header_hard(skb, len)) {
+		gtp0 = skb_gro_header_slow(skb, len, off);
+		if (unlikely(!gtp0))
+			goto out;
+	}
+
+	for (p = *head; p; p = p->next) {
+		const struct gtp0_header *gtp0_t;
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		gtp0_t = (struct gtp0_header *)(p->data + off);
+
+		if (gtp0->flags != gtp0_t->flags ||
+		    gtp0->type != gtp0_t->type ||
+		    gtp0->flow != gtp0_t->flow ||
+		    gtp0->tid != gtp0_t->tid) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+	}
+
+	return gtp_gro_receive_finish(sk, head, skb, gtp0, hdrlen);
+
+out:
+	NAPI_GRO_CB(skb)->flush |= 1;
+
+	return NULL;
+}
+
+static struct sk_buff **gtp1u_gro_receive(struct sock *sk,
+					  struct sk_buff **head,
+					  struct sk_buff *skb)
+{
+	struct gtp1_header *gtp1;
+	size_t len, hdrlen, off;
+	struct sk_buff *p;
+
+	off = skb_gro_offset(skb);
+	len = off + sizeof(*gtp1);
+	hdrlen = sizeof(*gtp1);
+
+	gtp1 = skb_gro_header_fast(skb, off);
+	if (skb_gro_header_hard(skb, len)) {
+		gtp1 = skb_gro_header_slow(skb, len, off);
+		if (unlikely(!gtp1))
+			goto out;
+	}
+
+	if ((gtp1->flags >> 5) != GTP_V1 || gtp1->type != GTP_TPDU)
+		goto out;
+
+	if (gtp1->flags & GTP1_F_MASK) {
+		hdrlen += 4;
+		len += 4;
+	}
+
+	len += sizeof(struct iphdr);
+
+	/* Now get header with GTP header an IPv4 header (for version) */
+	if (skb_gro_header_hard(skb, len)) {
+		gtp1 = skb_gro_header_slow(skb, len, off);
+		if (unlikely(!gtp1))
+			goto out;
+	}
+
+	for (p = *head; p; p = p->next) {
+		const struct gtp1_header *gtp1_t;
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		gtp1_t = (struct gtp1_header *)(p->data + off);
+
+		if (gtp1->flags != gtp1_t->flags ||
+		    gtp1->type != gtp1_t->type ||
+		    gtp1->tid != gtp1_t->tid) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+	}
+
+	return gtp_gro_receive_finish(sk, head, skb, gtp1, hdrlen);
+
+out:
+	NAPI_GRO_CB(skb)->flush = 1;
+
+	return NULL;
+}
+
+static int gtp_gro_complete_finish(struct sock *sk, struct sk_buff *skb,
+				   int nhoff, size_t hdrlen)
+{
+	struct packet_offload *ptype;
+	int err = -EINVAL;
+	__be16 type;
+
+	type = ipver_to_eth((struct iphdr *)(skb->data + nhoff + hdrlen));
+	if (!type)
+		return err;
+
+	rcu_read_lock();
+	ptype = gro_find_complete_by_type(type);
+	if (ptype)
+		err = ptype->callbacks.gro_complete(skb, nhoff + hdrlen);
+
+	rcu_read_unlock();
+
+	skb_set_inner_mac_header(skb, nhoff + hdrlen);
+
+	return err;
+}
+
+static int gtp0_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
+{
+	struct gtp0_header *gtp0 = (struct gtp0_header *)(skb->data + nhoff);
+	size_t hdrlen = sizeof(struct gtp0_header);
+
+	gtp0->length = htons(skb->len - nhoff - hdrlen);
+
+	return gtp_gro_complete_finish(sk, skb, nhoff, hdrlen);
+}
+
+static int gtp1u_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
+{
+	struct gtp1_header *gtp1 = (struct gtp1_header *)(skb->data + nhoff);
+	size_t hdrlen = sizeof(struct gtp1_header);
+
+	if (gtp1->flags & GTP1_F_MASK)
+		hdrlen += 4;
+
+	gtp1->length = htons(skb->len - nhoff - hdrlen);
+
+	return gtp_gro_complete_finish(sk, skb, nhoff, hdrlen);
+}
+
 static void gtp_encap_destroy(struct sock *sk)
 {
 	struct gtp_dev *gtp;
@@ -946,9 +1146,13 @@ static int gtp_encap_enable_sock(struct socket *sock, int type,
 	switch (type) {
 	case UDP_ENCAP_GTP0:
 		tuncfg.encap_rcv = gtp0_udp_encap_recv;
+		tuncfg.gro_receive = gtp0_gro_receive;
+		tuncfg.gro_complete = gtp0_gro_complete;
 		break;
 	case UDP_ENCAP_GTP1U:
 		tuncfg.encap_rcv = gtp1u_udp_encap_recv;
+		tuncfg.gro_receive = gtp1u_gro_receive;
+		tuncfg.gro_complete = gtp1u_gro_complete;
 		break;
 	default:
 		pr_debug("Unknown encap type %u\n", type);
-- 
2.11.0
