From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net] openvswitch: upcall: Fix vlan handling.
Date: Mon, 26 Dec 2016 08:31:27 -0800
Message-ID: <1482769887-8022-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>, Jarno Rajahalme <jarno@ovn.org>,
        Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34109 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751234AbcLZQjS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2016 11:39:18 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so17106369pfb.1
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2016 08:39:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Networking stack accelerate vlan tag handling by
keeping topmost vlan header in skb. This works as
long as packet remains in OVS datapath. But during
OVS upcall vlan header is pushed on to the packet.
When such packet is sent back to OVS datapath, core
networking stack might not handle it correctly. Following
patch avoids this issue by accelerating the vlan tag
during flow key extract. This simplifies datapath by
bringing uniform packet processing for packets from
all code paths.

Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets").
CC: Jarno Rajahalme <jarno@ovn.org>
CC: Jiri Benc <jbenc@redhat.com>
Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/datapath.c |  1 -
 net/openvswitch/flow.c     | 54 +++++++++++++++++++++++-----------------------
 2 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2d4c4d3..9c62b63 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -606,7 +606,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	rcu_assign_pointer(flow->sf_acts, acts);
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
-	packet->protocol = flow->key.eth.type;
 
 	rcu_read_lock();
 	dp = get_dp_rcu(net, ovs_header->dp_ifindex);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 08aa926..2c0a00f 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -312,7 +312,8 @@ static bool icmp6hdr_ok(struct sk_buff *skb)
  * Returns 0 if it encounters a non-vlan or incomplete packet.
  * Returns 1 after successfully parsing vlan tag.
  */
-static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *key_vh)
+static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *key_vh,
+			  bool untag_vlan)
 {
 	struct vlan_head *vh = (struct vlan_head *)skb->data;
 
@@ -330,7 +331,20 @@ static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *key_vh)
 	key_vh->tci = vh->tci | htons(VLAN_TAG_PRESENT);
 	key_vh->tpid = vh->tpid;
 
-	__skb_pull(skb, sizeof(struct vlan_head));
+	if (unlikely(untag_vlan)) {
+		int offset = skb->data - skb_mac_header(skb);
+		u16 tci;
+		int err;
+
+		__skb_push(skb, offset);
+		err = __skb_vlan_pop(skb, &tci);
+		__skb_pull(skb, offset);
+		if (err)
+			return err;
+		__vlan_hwaccel_put_tag(skb, key_vh->tpid, tci);
+	} else {
+		__skb_pull(skb, sizeof(struct vlan_head));
+	}
 	return 1;
 }
 
@@ -351,13 +365,13 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 		key->eth.vlan.tpid = skb->vlan_proto;
 	} else {
 		/* Parse outer vlan tag in the non-accelerated case. */
-		res = parse_vlan_tag(skb, &key->eth.vlan);
+		res = parse_vlan_tag(skb, &key->eth.vlan, true);
 		if (res <= 0)
 			return res;
 	}
 
 	/* Parse inner vlan tag. */
-	res = parse_vlan_tag(skb, &key->eth.cvlan);
+	res = parse_vlan_tag(skb, &key->eth.cvlan, false);
 	if (res <= 0)
 		return res;
 
@@ -800,29 +814,15 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 	if (err)
 		return err;
 
-	if (ovs_key_mac_proto(key) == MAC_PROTO_NONE) {
-		/* key_extract assumes that skb->protocol is set-up for
-		 * layer 3 packets which is the case for other callers,
-		 * in particular packets recieved from the network stack.
-		 * Here the correct value can be set from the metadata
-		 * extracted above.
-		 */
-		skb->protocol = key->eth.type;
-	} else {
-		struct ethhdr *eth;
-
-		skb_reset_mac_header(skb);
-		eth = eth_hdr(skb);
-
-		/* Normally, setting the skb 'protocol' field would be
-		 * handled by a call to eth_type_trans(), but it assumes
-		 * there's a sending device, which we may not have.
-		 */
-		if (eth_proto_is_802_3(eth->h_proto))
-			skb->protocol = eth->h_proto;
-		else
-			skb->protocol = htons(ETH_P_802_2);
-	}
+	/* key_extract assumes that skb->protocol is set-up for
+	 * layer 3 packets which is the case for other callers,
+	 * in particular packets received from the network stack.
+	 * Here the correct value can be set from the metadata
+	 * extracted above.
+	 * For L2 packet key eth type would be zero. skb protocol
+	 * would be set to correct value later during key-extact.
+	 */
 
+	skb->protocol = key->eth.type;
 	return key_extract(skb, key);
 }
-- 
2.9.3
