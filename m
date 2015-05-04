From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 5/6] net: Add GRE keyid in flow_keys
Date: Mon, 4 May 2015 16:02:39 -0700
Message-ID: <1430780560-2758924-6-git-send-email-tom@herbertland.com>
References: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:57082 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751894AbbEDXDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:03:07 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t44N0jau013911
	for <netdev@vger.kernel.org>; Mon, 4 May 2015 16:03:02 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u6emxrv46-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 May 2015 16:03:02 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 b5cee218f2b111e4a74f0002c991e86a-9afdf1e0 for <netdev@vger.kernel.org>;	Mon,
 04 May 2015 16:03:00 -0700
In-Reply-To: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
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
index de71e42..025b91f 100644
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
+				flow->extra_entropy ^= *keyid;
+
 				nhoff += 4;
+			}
 			if (hdr->flags & GRE_SEQ)
 				nhoff += 4;
 			if (proto == htons(ETH_P_TEB)) {
-- 
1.8.1
