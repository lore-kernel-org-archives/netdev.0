From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 5/5] net: Add GRE keyid in flow_keys
Date: Tue, 12 May 2015 08:23:02 -0700
Message-ID: <1431444182-3935169-6-git-send-email-tom@herbertland.com>
References: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:25799 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932996AbbELPXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:23:42 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4CFKOe4020503
	for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:23:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ubjcc0dev-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:23:42 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 d4409520f8ba11e4a7720002c991e86a-9bfe11e0 for <netdev@vger.kernel.org>;	Tue,
 12 May 2015 08:23:23 -0700
In-Reply-To: <1431444182-3935169-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow dissector if a GRE header contains a keyid this is saved in the
new extra entropy field of flow_keys. The GRE keyid is then represented
in the flow hash function input.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_keys.h   |  1 +
 net/core/flow_dissector.c | 15 ++++++++++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 906d47a..779e42f 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -28,6 +28,7 @@ struct flow_keys {
 	u8	padding;
 	u32	vlan_id:12,
 		flow_label:20;
+	u32	extra_entropy;
 
 	union {
 		__be32 ports;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index f1fb7a5..1b204ed 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -195,8 +195,21 @@ ipv6:
 			nhoff += 4;
 			if (hdr->flags & GRE_CSUM)
 				nhoff += 4;
-			if (hdr->flags & GRE_KEY)
+			if (hdr->flags & GRE_KEY) {
+				const __be32 *keyid;
+				__be32 _keyid;
+
+				keyid = __skb_header_pointer(skb, nhoff,
+							     sizeof(_keyid),
+							     data, hlen,
+							     &_keyid);
+				if (!keyid)
+					return false;
+
+				flow->extra_entropy ^= ntohl(*keyid);
+
 				nhoff += 4;
+			}
 			if (hdr->flags & GRE_SEQ)
 				nhoff += 4;
 			if (proto == htons(ETH_P_TEB)) {
-- 
1.8.1
