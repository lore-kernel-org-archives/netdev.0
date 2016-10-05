From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed,  5 Oct 2016 15:07:26 +0200
Message-ID: <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
References: <cover.1475672568.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752488AbcJENHm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 09:07:42 -0400
In-Reply-To: <cover.1475672568.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to how the core networking stack behaves, let the first vlan tag
be always stored in skb->vlan_tci. This is already ensured in
__netif_receive_skb_core for packets that were received from the kernel and
honored by skb_vlan_push and skb_vlan_pop. The only remaining place are
packets received from the user space. Just do the same things with vlan
frames as __netif_receive_skb_core does.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/openvswitch/datapath.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4d67ea856067..c47b3da8ecf2 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -594,6 +594,16 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	else
 		packet->protocol = htons(ETH_P_802_2);
 
+	if (eth_type_vlan(packet->protocol)) {
+		__skb_pull(packet, ETH_HLEN);
+		skb_reset_network_header(packet);
+		skb_reset_mac_len(packet);
+		packet = skb_vlan_untag(packet);
+		if (unlikely(!packet))
+			goto err;
+		skb_push(packet, ETH_HLEN);
+	}
+
 	/* Set packet's mru */
 	if (a[OVS_PACKET_ATTR_MRU]) {
 		mru = nla_get_u16(a[OVS_PACKET_ATTR_MRU]);
-- 
1.8.3.1
