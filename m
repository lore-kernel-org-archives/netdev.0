From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 8/8] vxlan: support flow dissect
Date: Thu, 28 Sep 2017 14:48:23 -0700
Message-ID: <20170928214823.2426-8-tom@quantonium.net>
References: <20170928214823.2426-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:56296 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751819AbdI1Vs4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 17:48:56 -0400
Received: by mail-pf0-f177.google.com with SMTP id r71so1495538pfe.12
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 14:48:56 -0700 (PDT)
In-Reply-To: <20170928214823.2426-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Populate offload flow_dissect callback appropriately for VXLAN and
VXLAN-GPE.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/vxlan.c | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d7c49cf1d5e9..80227050b2d4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1327,6 +1327,45 @@ static bool vxlan_ecn_decapsulate(struct vxlan_sock *vs, void *oiph,
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
+		protocol = tun_p_from_eth_p(gpe->next_protocol);
+		if (!protocol)
+			return FLOW_DISSECT_RET_CONTINUE;
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
@@ -2846,6 +2885,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, bool ipv6,
 	tunnel_cfg.encap_destroy = NULL;
 	tunnel_cfg.gro_receive = vxlan_gro_receive;
 	tunnel_cfg.gro_complete = vxlan_gro_complete;
+	tunnel_cfg.flow_dissect = vxlan_flow_dissect;
 
 	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
 
-- 
2.11.0
