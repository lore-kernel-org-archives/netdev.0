From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 10/11] net: Add GRE keyid in flow_keys
Date: Thu, 21 May 2015 17:11:45 -0700
Message-ID: <1432253506-3646977-11-git-send-email-tom@herbertland.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:52589 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756134AbbEVAMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:12:14 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4M0B86T029595
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1uhrtq02rs-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:12:13 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 31e9e5ce001711e5b3f40002c9521c9e-aa7fa3a0 for <netdev@vger.kernel.org>;	Thu,
 21 May 2015 17:12:12 -0700
In-Reply-To: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow dissector if a GRE header contains a keyid this is saved in the
new keyid field of flow_keys. The GRE keyid is then represented
in the flow hash function input.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h |  6 ++++++
 net/core/flow_dissector.c    | 25 ++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index effe607..f9a3084 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -32,6 +32,10 @@ struct flow_dissector_key_tags {
 		flow_label:20;
 };
 
+struct flow_dissector_key_keyid {
+	u32	keyid;
+};
+
 /**
  * struct flow_dissector_key_ipv4_addrs:
  * @src: source ip address
@@ -113,6 +117,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
 	FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
 	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_label */
+	FLOW_DISSECTOR_KEY_GRE_KEYID, /* struct flow_dissector_key_keyid */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
@@ -150,6 +155,7 @@ struct flow_keys {
 #define FLOW_KEYS_HASH_START_FIELD basic
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_tags tags;
+	struct flow_dissector_key_keyid keyid;
 	struct flow_dissector_key_ports ports;
 	struct flow_dissector_key_addrs addrs;
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 2fba492..20ce55d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -127,6 +127,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_addrs *key_addrs;
 	struct flow_dissector_key_ports *key_ports;
 	struct flow_dissector_key_tags *key_tags;
+	struct flow_dissector_key_keyid *key_keyid;
 	u8 ip_proto;
 
 	if (!data) {
@@ -313,8 +314,26 @@ ipv6:
 		nhoff += 4;
 		if (hdr->flags & GRE_CSUM)
 			nhoff += 4;
-		if (hdr->flags & GRE_KEY)
+		if (hdr->flags & GRE_KEY) {
+			const __be32 *keyid;
+			__be32 _keyid;
+
+			keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
+						     data, hlen, &_keyid);
+
+			if (!keyid)
+				return false;
+
+			if (skb_flow_dissector_uses_key(flow_dissector,
+					FLOW_DISSECTOR_KEY_GRE_KEYID)) {
+				key_keyid = skb_flow_dissector_target(
+						flow_dissector,
+						FLOW_DISSECTOR_KEY_GRE_KEYID,
+						target_container);
+				key_keyid->keyid = (__force u32)*keyid;
+			}
 			nhoff += 4;
+		}
 		if (hdr->flags & GRE_SEQ)
 			nhoff += 4;
 		if (proto == htons(ETH_P_TEB)) {
@@ -648,6 +667,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 		.key_id = FLOW_DISSECTOR_KEY_FLOW_LABEL,
 		.offset = offsetof(struct flow_keys, tags),
 	},
+	{
+		.key_id = FLOW_DISSECTOR_KEY_GRE_KEYID,
+		.offset = offsetof(struct flow_keys, keyid),
+	},
 };
 
 static const struct flow_dissector_key flow_keys_buf_dissector_keys[] = {
-- 
1.8.1
