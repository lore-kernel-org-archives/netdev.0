From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 7/8] fou: Support flow dissection
Date: Thu, 28 Sep 2017 16:52:29 -0700
Message-ID: <20170928235230.22158-8-tom@quantonium.net>
References: <20170928235230.22158-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:54336 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbdI1XxM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:53:12 -0400
Received: by mail-pg0-f42.google.com with SMTP id c137so1770654pga.11
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:53:11 -0700 (PDT)
In-Reply-To: <20170928235230.22158-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Populate offload flow_dissect callabck appropriately for fou and gue.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 net/ipv4/fou.c | 63 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 1540db65241a..a831dd49fb28 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -282,6 +282,20 @@ static int fou_gro_complete(struct sock *sk, struct sk_buff *skb,
 	return err;
 }
 
+static enum flow_dissect_ret fou_flow_dissect(struct sock *sk,
+			const struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	*p_ip_proto = fou_from_sock(sk)->protocol;
+	*p_nhoff += sizeof(struct udphdr);
+
+	return FLOW_DISSECT_RET_IPPROTO_AGAIN;
+}
+
 static struct guehdr *gue_gro_remcsum(struct sk_buff *skb, unsigned int off,
 				      struct guehdr *guehdr, void *data,
 				      size_t hdrlen, struct gro_remcsum *grc,
@@ -500,6 +514,53 @@ static int gue_gro_complete(struct sock *sk, struct sk_buff *skb, int nhoff)
 	return err;
 }
 
+static enum flow_dissect_ret gue_flow_dissect(struct sock *sk,
+			const struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	struct guehdr *guehdr, _guehdr;
+
+	guehdr = __skb_header_pointer(skb, *p_nhoff + sizeof(struct udphdr),
+				      sizeof(_guehdr), data, *p_hlen, &_guehdr);
+	if (!guehdr)
+		return FLOW_DISSECT_RET_OUT_BAD;
+
+	switch (guehdr->version) {
+	case 0:
+		if (unlikely(guehdr->control))
+			return FLOW_DISSECT_RET_CONTINUE;
+
+		*p_ip_proto = guehdr->proto_ctype;
+		*p_nhoff += sizeof(struct udphdr) +
+		    sizeof(*guehdr) + (guehdr->hlen << 2);
+
+		break;
+	case 1:
+		switch (((struct iphdr *)guehdr)->version) {
+		case 4:
+			*p_ip_proto = IPPROTO_IPIP;
+			break;
+		case 6:
+			*p_ip_proto = IPPROTO_IPV6;
+			break;
+		default:
+			return FLOW_DISSECT_RET_CONTINUE;
+		}
+
+		*p_nhoff += sizeof(struct udphdr);
+
+		break;
+	default:
+		return FLOW_DISSECT_RET_CONTINUE;
+	}
+
+	return FLOW_DISSECT_RET_IPPROTO_AGAIN;
+}
+
 static int fou_add_to_port_list(struct net *net, struct fou *fou)
 {
 	struct fou_net *fn = net_generic(net, fou_net_id);
@@ -570,12 +631,14 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 		tunnel_cfg.encap_rcv = fou_udp_recv;
 		tunnel_cfg.gro_receive = fou_gro_receive;
 		tunnel_cfg.gro_complete = fou_gro_complete;
+		tunnel_cfg.flow_dissect = fou_flow_dissect;
 		fou->protocol = cfg->protocol;
 		break;
 	case FOU_ENCAP_GUE:
 		tunnel_cfg.encap_rcv = gue_udp_recv;
 		tunnel_cfg.gro_receive = gue_gro_receive;
 		tunnel_cfg.gro_complete = gue_gro_complete;
+		tunnel_cfg.flow_dissect = gue_flow_dissect;
 		break;
 	default:
 		err = -EINVAL;
-- 
2.11.0
