From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 4/4] openvswitch: make skb->csum consistent with rest of networking stack.
Date: Thu, 13 Jun 2013 11:11:44 -0700
Message-ID: <1371147104-29295-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog106.obsmtp.com ([74.125.149.77]:59161 "HELO
	na3sys009aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758576Ab3FMSLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:11:47 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so5620547pbb.19
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:11:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch keeps skb->csum correct across ovs.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
v2:
skip csum of packets going to userspace.
---
 net/openvswitch/actions.c            |    4 ++++
 net/openvswitch/flow.c               |    3 +++
 net/openvswitch/vport-internal_dev.c |    1 +
 net/openvswitch/vport-netdev.c       |    2 ++
 net/openvswitch/vport.h              |    7 +++++++
 5 files changed, 17 insertions(+), 0 deletions(-)

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
 
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index efa53e3..fab4ba6 100644
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
