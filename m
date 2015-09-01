From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 09/11] flow_dissector: Add flag to stop parsing when an IPv6 flow label is seen
Date: Tue, 1 Sep 2015 09:24:31 -0700
Message-ID: <1441124673-3438470-10-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:33969 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753410AbbIAQZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:21 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GKuO2017611
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wna1drsh5-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:20 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 099ab4a450c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:19 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an input flag to flow dissector on rather dissection should be
stopped when a flow label is encountered. Presumably, the flow label
is derived from a sufficient hash of an inner transport packet so
further dissection is not needed (that is ports are not included in
the flow hash). Using the flow label instead of ports has the additional
benefit that packet fragments should hash to same value as non-fragments
for a flow (assuming that the same flow label is used).

We set this flag by default in for skb_get_hash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h | 1 +
 net/core/flow_dissector.c    | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index bb81e3b..66dbc34 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -126,6 +126,7 @@ enum flow_dissector_key_id {
 
 #define FLOW_DISSECTOR_F_PARSE_1ST_FRAG		BIT(0)
 #define FLOW_DISSECTOR_F_STOP_AT_L3		BIT(1)
+#define FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL	BIT(2)
 
 struct flow_dissector_key {
 	enum flow_dissector_key_id key_id;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 94fd841..094e343 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -239,6 +239,8 @@ ipv6:
 								     target_container);
 				key_tags->flow_label = ntohl(flow_label);
 			}
+			if (flags & FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL)
+				goto out_good;
 		}
 
 		if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
@@ -599,7 +601,8 @@ EXPORT_SYMBOL(flow_hash_from_keys);
 static inline u32 ___skb_get_hash(const struct sk_buff *skb,
 				  struct flow_keys *keys, u32 keyval)
 {
-	if (!skb_flow_dissect_flow_keys(skb, keys, 0))
+	if (!skb_flow_dissect_flow_keys(skb, keys,
+					FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL))
 		return 0;
 
 	return __flow_hash_from_keys(keys, keyval);
-- 
1.8.1
