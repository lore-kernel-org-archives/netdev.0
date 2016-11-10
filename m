From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 1/8] openvswitch: use hard_header_len instead of hardcoded ETH_HLEN
Date: Thu, 10 Nov 2016 16:28:17 +0100
Message-ID: <64aa129b465ef5dce928f54fcb549e0e6403a60a.1478791347.git.jbenc@redhat.com>
References: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60220 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934190AbcKJP2r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:47 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On tx, use hard_header_len while deciding whether to refragment or drop the
packet. That way, all combinations are calculated correctly:

* L2 packet going to L2 interface (the L2 header len is subtracted),
* L2 packet going to L3 interface (the L2 header is included in the packet
  lenght),
* L3 packet going to L3 interface.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/actions.c |  3 ++-
 net/openvswitch/vport.c   | 10 ++++++----
 2 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 1105c4e29c62..49af167105d3 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -791,7 +791,8 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 				pskb_trim(skb, ETH_HLEN);
 		}
 
-		if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
+		if (likely(!mru ||
+		           (skb->len <= mru + vport->dev->hard_header_len))) {
 			ovs_vport_send(vport, skb);
 		} else if (mru <= vport->dev->mtu) {
 			struct net *net = read_pnet(&dp->net);
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 9bb85b35a1fb..3e131f6868f2 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -464,9 +464,10 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	return 0;
 }
 
-static unsigned int packet_length(const struct sk_buff *skb)
+static unsigned int packet_length(const struct sk_buff *skb,
+				  struct net_device *dev)
 {
-	unsigned int length = skb->len - ETH_HLEN;
+	unsigned int length = skb->len - dev->hard_header_len;
 
 	if (!skb_vlan_tag_present(skb) &&
 	    eth_type_vlan(skb->protocol))
@@ -484,10 +485,11 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 {
 	int mtu = vport->dev->mtu;
 
-	if (unlikely(packet_length(skb) > mtu && !skb_is_gso(skb))) {
+	if (unlikely(packet_length(skb, vport->dev) > mtu &&
+		     !skb_is_gso(skb))) {
 		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
 				     vport->dev->name,
-				     packet_length(skb), mtu);
+				     packet_length(skb, vport->dev), mtu);
 		vport->dev->stats.tx_errors++;
 		goto drop;
 	}
-- 
1.8.3.1
