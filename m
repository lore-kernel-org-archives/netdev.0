From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 4/4] openvswitch: make skb->csum consistent with rest of networking stack.
Date: Wed, 12 Jun 2013 15:57:16 -0700
Message-ID: <1371077836-19796-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog114.obsmtp.com ([74.125.149.211]:44498 "HELO
	na3sys009aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932112Ab3FLW5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:57:20 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so4482694pdi.41
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 15:57:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch keeps skb->csum correct across ovs.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c            |    4 ++++
 net/openvswitch/datapath.c           |    1 +
 net/openvswitch/flow.c               |    3 +++
 net/openvswitch/vport-internal_dev.c |    1 +
 net/openvswitch/vport-netdev.c       |    2 ++
 net/openvswitch/vport.h              |    7 +++++++
 6 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 894b6cb..596d637 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -130,9 +130,13 @@ static int set_eth_addr(struct sk_buff *skb,
 	if (unlikely(err))
 		return err;
 
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
+
 	memcpy(eth_hdr(skb)->h_source, eth_key->eth_src, ETH_ALEN);
 	memcpy(eth_hdr(skb)->h_dest, eth_key->eth_dst, ETH_ALEN);
 
+	ovs_skb_postpush_rcsum(skb, eth_hdr(skb), ETH_ALEN * 2);
+
 	return 0;
 }
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 39cd821..e6ffb82 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -406,6 +406,7 @@ static int queue_userspace_packet(struct net *net, int dp_ifindex,
 		nskb = __vlan_put_tag(nskb, nskb->vlan_proto, vlan_tx_tag_get(nskb));
 		if (!nskb)
 			return -ENOMEM;
+		ovs_skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
 
 		nskb->vlan_tci = 0;
 		skb = nskb;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 150f181..cc39085 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -618,6 +618,9 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 	memcpy(key->eth.dst, eth->h_dest, ETH_ALEN);
 
 	__skb_pull(skb, 2 * ETH_ALEN);
+	/* We are going to push all headers that we pull, so no need to
+	 * update skb->csum here.
+	 */
 
 	if (vlan_tx_tag_present(skb))
 		key->eth.tci = htons(skb->vlan_tci);
diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 84e0a03..e284c7e 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -221,6 +221,7 @@ static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	skb->dev = netdev;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, netdev);
+	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
 	netif_rx(skb);
 
diff --git a/net/openvswitch/vport-netdev.c b/net/openvswitch/vport-netdev.c
index c3ee7de..018aadf 100644
--- a/net/openvswitch/vport-netdev.c
+++ b/net/openvswitch/vport-netdev.c
@@ -49,6 +49,8 @@ static void netdev_port_receive(struct vport *vport, struct sk_buff *skb)
 		return;
 
 	skb_push(skb, ETH_HLEN);
+	ovs_skb_postpush_rcsum(skb, skb->data, ETH_HLEN);
+
 	ovs_vport_receive(vport, skb);
 	return;
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 75d3ccb..98f3341 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -195,4 +195,11 @@ void ovs_vport_record_error(struct vport *, enum vport_err_type err_type);
 extern const struct vport_ops ovs_netdev_vport_ops;
 extern const struct vport_ops ovs_internal_vport_ops;
 
+static inline void ovs_skb_postpush_rcsum(struct sk_buff *skb,
+				      const void *start, unsigned int len)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
+}
+
 #endif /* vport.h */
-- 
1.7.1
