From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 6/6] vxlan: support flow dissect
Date: Tue, 29 Aug 2017 10:19:42 -0700
Message-ID: <20170829171942.8974-7-tom@quantonium.net>
References: <20170829171942.8974-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35913 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751333AbdH2RUY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 13:20:24 -0400
Received: by mail-pg0-f42.google.com with SMTP id r133so12583735pgr.3
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 10:20:24 -0700 (PDT)
In-Reply-To: <20170829171942.8974-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Populate offload flow_dissect callback appropriately for VXLAN and
VXLAN-GPE.
---
 drivers/net/vxlan.c | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ae3a1da703c2..41e50de40af4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1336,6 +1336,55 @@ static bool vxlan_ecn_decapsulate(struct vxlan_sock *vs, void *oiph,
 	return err <= 1;
 }
 
+static enum flow_dissect_ret vxlan_flow_dissect(struct sock *sk,
+			const struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	__be16 protocol = htons(ETH_P_TEB);
+	struct vxlanhdr *vhdr, _vhdr;
+	struct vxlan_sock *vs;
+
+	vhdr = __skb_header_pointer(skb, *p_nhoff + sizeof(struct udphdr),
+				    sizeof(_vhdr), data, *p_hlen, &_vhdr);
+	if (!vhdr)
+		return FLOW_DISSECT_RET_OUT_BAD;
+
+	vs = rcu_dereference_sk_user_data(sk);
+	if (!vs)
+		return FLOW_DISSECT_RET_OUT_BAD;
+
+	if (vs->flags & VXLAN_F_GPE) {
+		struct vxlanhdr_gpe *gpe = (struct vxlanhdr_gpe *)vhdr;
+
+		/* Need to have Next Protocol set for interfaces in GPE mode. */
+		if (gpe->version != 0 || !gpe->np_applied || gpe->oam_flag)
+			return FLOW_DISSECT_RET_CONTINUE;
+
+		switch (gpe->next_protocol) {
+		case VXLAN_GPE_NP_IPV4:
+			protocol = htons(ETH_P_IP);
+			break;
+		case VXLAN_GPE_NP_IPV6:
+			protocol = htons(ETH_P_IPV6);
+			break;
+		case VXLAN_GPE_NP_ETHERNET:
+			protocol = htons(ETH_P_TEB);
+			break;
+		default:
+			return FLOW_DISSECT_RET_CONTINUE;
+		}
+	}
+
+	*p_nhoff += sizeof(struct udphdr) + sizeof(_vhdr);
+	*p_proto = protocol;
+
+	return FLOW_DISSECT_RET_PROTO_AGAIN;
+}
+
 /* Callback from net/ipv4/udp.c to receive packets */
 static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 {
@@ -2864,6 +2913,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	tunnel_cfg.encap_destroy = NULL;
 	tunnel_cfg.gro_receive = vxlan_gro_receive;
 	tunnel_cfg.gro_complete = vxlan_gro_complete;
+	tunnel_cfg.flow_dissect = vxlan_flow_dissect;
 
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
 
-- 
2.11.0
