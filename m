From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 08/11] net: Add VLAN ID to flow_keys
Date: Thu, 28 May 2015 11:19:05 -0700
Message-ID: <1432837148-1359931-9-git-send-email-tom@herbertland.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33152 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754184AbbE1STe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 14:19:34 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4SIFvKs016291
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:34 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1up5n4gbpp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:34 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 169a5d2c056611e5b63c0002c991e86a-6ced23a0 for <netdev@vger.kernel.org>;	Thu,
 28 May 2015 11:19:33 -0700
In-Reply-To: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow_dissector set vlan_id in flow_keys when VLAN is found.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h |  6 ++++++
 net/core/flow_dissector.c    | 14 ++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 59f00f9..08480fb 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -27,6 +27,10 @@ struct flow_dissector_key_basic {
 	u8	padding;
 };
 
+struct flow_dissector_key_tags {
+	u32	vlan_id:12;
+};
+
 /**
  * struct flow_dissector_key_ipv4_addrs:
  * @src: source ip address
@@ -106,6 +110,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
+	FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
@@ -142,6 +147,7 @@ struct flow_keys {
 	struct flow_dissector_key_control control;
 #define FLOW_KEYS_HASH_START_FIELD basic
 	struct flow_dissector_key_basic basic;
+	struct flow_dissector_key_tags tags;
 	struct flow_dissector_key_ports ports;
 	struct flow_dissector_key_addrs addrs;
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 5348a46..5c66cb2 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -126,6 +126,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_basic *key_basic;
 	struct flow_dissector_key_addrs *key_addrs;
 	struct flow_dissector_key_ports *key_ports;
+	struct flow_dissector_key_tags *key_tags;
 	u8 ip_proto;
 
 	if (!data) {
@@ -246,6 +247,15 @@ flow_label:
 		if (!vlan)
 			return false;
 
+		if (skb_flow_dissector_uses_key(flow_dissector,
+						FLOW_DISSECTOR_KEY_VLANID)) {
+			key_tags = skb_flow_dissector_target(flow_dissector,
+							     FLOW_DISSECTOR_KEY_VLANID,
+							     target_container);
+
+			key_tags->vlan_id = skb_vlan_tag_get_id(skb);
+		}
+
 		proto = vlan->h_vlan_encapsulated_proto;
 		nhoff += sizeof(*vlan);
 		goto again;
@@ -645,6 +655,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 		.key_id = FLOW_DISSECTOR_KEY_PORTS,
 		.offset = offsetof(struct flow_keys, ports),
 	},
+	{
+		.key_id = FLOW_DISSECTOR_KEY_VLANID,
+		.offset = offsetof(struct flow_keys, tags),
+	},
 };
 
 static const struct flow_dissector_key flow_keys_buf_dissector_keys[] = {
-- 
1.8.1
