From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 1/2] flow disector: ARP support
Date: Wed, 11 Jan 2017 11:02:21 +0100
Message-ID: <1484128942-11745-2-git-send-email-simon.horman@netronome.com>
References: <1484128942-11745-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f177.google.com ([209.85.210.177]:35154 "EHLO
        mail-wj0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965467AbdAKKCv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 05:02:51 -0500
Received: by mail-wj0-f177.google.com with SMTP id i20so97785150wjn.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 02:02:51 -0800 (PST)
In-Reply-To: <1484128942-11745-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow dissection of (R)ARP operation hardware and protocol addresses
for Ethernet hardware and IPv4 protocol addresses.

There are currently no users of FLOW_DISSECTOR_KEY_ARP.
A follow-up patch will allow FLOW_DISSECTOR_KEY_ARP to be used by the
flower classifier.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/net/flow_dissector.h | 19 +++++++++++++++
 net/core/flow_dissector.c    | 57 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index d896a33e00d4..ac9703018a3a 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -89,6 +89,24 @@ struct flow_dissector_key_addrs {
 };
 
 /**
+ * flow_dissector_key_arp:
+ *	@ports: Operation, source and target addresses for an ARP header
+ *              for Ethernet hardware addresses and IPv4 protocol addresses
+ *		sip: Sender IP address
+ *		tip: Target IP address
+ *		op:  Operation
+ *		sha: Sender hardware address
+ *		tpa: Target hardware address
+ */
+struct flow_dissector_key_arp {
+	__u32 sip;
+	__u32 tip;
+	__u8 op;
+	unsigned char sha[ETH_ALEN];
+	unsigned char tha[ETH_ALEN];
+};
+
+/**
  * flow_dissector_key_tp_ports:
  *	@ports: port numbers of Transport header
  *		src: source port number
@@ -141,6 +159,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_ICMP, /* struct flow_dissector_key_icmp */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
+	FLOW_DISSECTOR_KEY_ARP, /* struct flow_dissector_key_arp */
 	FLOW_DISSECTOR_KEY_VLAN, /* struct flow_dissector_key_flow_vlan */
 	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_tags */
 	FLOW_DISSECTOR_KEY_GRE_KEYID, /* struct flow_dissector_key_keyid */
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index fe4e1531976c..5b3800fe20f3 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -138,6 +138,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_control *key_control;
 	struct flow_dissector_key_basic *key_basic;
 	struct flow_dissector_key_addrs *key_addrs;
+	struct flow_dissector_key_arp *key_arp;
 	struct flow_dissector_key_ports *key_ports;
 	struct flow_dissector_key_icmp *key_icmp;
 	struct flow_dissector_key_tags *key_tags;
@@ -379,6 +380,62 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 		nhoff += FCOE_HEADER_LEN;
 		goto out_good;
+
+	case htons(ETH_P_ARP):
+	case htons(ETH_P_RARP): {
+		struct {
+			unsigned char ar_sha[ETH_ALEN];
+			unsigned char ar_sip[4];
+			unsigned char ar_tha[ETH_ALEN];
+			unsigned char ar_tip[4];
+		} *arp_eth, _arp_eth;
+		const struct arphdr *arp;
+		struct arphdr *_arp;
+
+		arp = __skb_header_pointer(skb, nhoff, sizeof(_arp), data,
+					   hlen, &_arp);
+		if (!arp)
+			goto out_bad;
+
+		if (arp->ar_hrd != htons(ARPHRD_ETHER) ||
+		    arp->ar_pro != htons(ETH_P_IP) ||
+		    arp->ar_hln != ETH_ALEN ||
+		    arp->ar_pln != 4 ||
+		    (arp->ar_op != htons(ARPOP_REPLY) &&
+		     arp->ar_op != htons(ARPOP_REQUEST)))
+			goto out_bad;
+
+		arp_eth = __skb_header_pointer(skb, nhoff + sizeof(_arp),
+					       sizeof(_arp_eth), data,
+					       hlen - sizeof(_arp),
+					       &_arp_eth);
+		if (!arp)
+			goto out_bad;
+
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_ARP)) {
+
+			key_arp = skb_flow_dissector_target(flow_dissector,
+							    FLOW_DISSECTOR_KEY_ARP,
+							    target_container);
+
+			memcpy(&key_arp->sip, arp_eth->ar_sip,
+			       sizeof(key_arp->sip));
+			memcpy(&key_arp->tip, arp_eth->ar_tip,
+			       sizeof(key_arp->tip));
+
+			/* Only store the lower byte of the opcode;
+			 * this covers ARPOP_REPLY and ARPOP_REQUEST.
+			 */
+			key_arp->op = ntohs(arp->ar_op) & 0xff;
+
+			ether_addr_copy(key_arp->sha, arp_eth->ar_sha);
+			ether_addr_copy(key_arp->tha, arp_eth->ar_tha);
+		}
+
+		goto out_good;
+	}
+
 	default:
 		goto out_bad;
 	}
-- 
2.7.0.rc3.207.g0ac5344
