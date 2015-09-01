From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 11/11] flow_dissector: Ignore flow dissector return value from ___skb_get_hash
Date: Tue, 1 Sep 2015 09:24:33 -0700
Message-ID: <1441124673-3438470-12-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39901 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753486AbbIAQZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:24 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GPNLY005424
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:23 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wnake8mas-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:23 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 0b49d78a50c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:22 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ___skb_get_hash ignore return value from skb_flow_dissect_flow_keys.
A failure in that function likely means that there was a parse error,
so we may as well use whatever fields were found before the error was
hit.  This is also good because it means we won't keep trying to derive
the hash on subsequent calls to skb_get_hash for the same packet.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 8d89013..b5633394 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -616,9 +616,8 @@ EXPORT_SYMBOL(flow_hash_from_keys);
 static inline u32 ___skb_get_hash(const struct sk_buff *skb,
 				  struct flow_keys *keys, u32 keyval)
 {
-	if (!skb_flow_dissect_flow_keys(skb, keys,
-					FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL))
-		return 0;
+	skb_flow_dissect_flow_keys(skb, keys,
+				   FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL);
 
 	return __flow_hash_from_keys(keys, keyval);
 }
@@ -662,15 +661,10 @@ EXPORT_SYMBOL(make_flow_keys_digest);
 void __skb_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys keys;
-	u32 hash;
 
 	__flow_hash_secret_init();
 
-	hash = ___skb_get_hash(skb, &keys, hashrnd);
-	if (!hash)
-		return;
-
-	__skb_set_sw_hash(skb, hash,
+	__skb_set_sw_hash(skb, ___skb_get_hash(skb, &keys, hashrnd),
 			  flow_keys_have_l4(&keys));
 }
 EXPORT_SYMBOL(__skb_get_hash);
-- 
1.8.1
