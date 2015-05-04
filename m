From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 4/5] openvswitch: Use eth_proto_is_802_3
Date: Mon, 04 May 2015 14:34:05 -0700
Message-ID: <20150504213405.2536.53256.stgit@ahduyck-vm-fedora22>
References: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752235AbbEDVeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 17:34:05 -0400
In-Reply-To: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace "ntohs(proto) >= ETH_P_802_3_MIN" w/ eth_proto_is_802_3(proto).

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/openvswitch/datapath.c     |    2 +-
 net/openvswitch/flow.c         |    4 ++--
 net/openvswitch/flow_netlink.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 096c6276e6b9..3b90461317ec 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -545,7 +545,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	/* Normally, setting the skb 'protocol' field would be handled by a
 	 * call to eth_type_trans(), but it assumes there's a sending
 	 * device, which we may not have. */
-	if (ntohs(eth->h_proto) >= ETH_P_802_3_MIN)
+	if (eth_proto_is_802_3(eth->h_proto))
 		packet->protocol = eth->h_proto;
 	else
 		packet->protocol = htons(ETH_P_802_2);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 2dacc7b5af23..bc7b0aba994a 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -332,7 +332,7 @@ static __be16 parse_ethertype(struct sk_buff *skb)
 	proto = *(__be16 *) skb->data;
 	__skb_pull(skb, sizeof(__be16));
 
-	if (ntohs(proto) >= ETH_P_802_3_MIN)
+	if (eth_proto_is_802_3(proto))
 		return proto;
 
 	if (skb->len < sizeof(struct llc_snap_hdr))
@@ -349,7 +349,7 @@ static __be16 parse_ethertype(struct sk_buff *skb)
 
 	__skb_pull(skb, sizeof(struct llc_snap_hdr));
 
-	if (ntohs(llc->ethertype) >= ETH_P_802_3_MIN)
+	if (eth_proto_is_802_3(llc->ethertype))
 		return llc->ethertype;
 
 	return htons(ETH_P_802_2);
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index c691b1a1eee0..624e41c4267f 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -816,7 +816,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
 		if (is_mask) {
 			/* Always exact match EtherType. */
 			eth_type = htons(0xffff);
-		} else if (ntohs(eth_type) < ETH_P_802_3_MIN) {
+		} else if (!eth_proto_is_802_3(eth_type)) {
 			OVS_NLERR(log, "EtherType %x is less than min %x",
 				  ntohs(eth_type), ETH_P_802_3_MIN);
 			return -EINVAL;
