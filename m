From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v4 3/4] net: Add inet_proto_csum_replace_by_diff utility function
Date: Mon, 17 Aug 2015 13:42:26 -0700
Message-ID: <1439844147-1286627-4-git-send-email-tom@herbertland.com>
References: <1439844147-1286627-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:17877 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750762AbbHQWXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 18:23:19 -0400
Received: from pps.filterd (m0042983 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7HMMGvF000383
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 15:23:18 -0700
Received: from pps.reinject (localhost [127.0.0.1])
	by mx0a-00082601.pphosted.com with ESMTP id 1w92w2rjfb-2
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 15:23:18 -0700
Received: from pps.reinject (m0042983 [127.0.0.1])
	by pps.reinject (8.14.5/8.14.5) with SMTP id t7HLcYRx006887
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 14:38:38 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wbp78r6d4-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Aug 2015 13:43:27 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 84a3ee9c452011e582a40002c9521c9e-9ebf02b0 for <netdev@vger.kernel.org>;	Mon,
 17 Aug 2015 13:42:47 -0700
In-Reply-To: <1439844147-1286627-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function updates a checksum field value and skb->csum based on
a value which is the difference between the old and new checksum.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/checksum.h |  2 ++
 net/core/utils.c       | 13 +++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 619f344..9fcaedf 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -144,6 +144,8 @@ void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 			       const __be32 *from, const __be32 *to,
 			       bool pseudohdr);
+void inet_proto_csum_replace_by_diff(__sum16 *sum, struct sk_buff *skb,
+				     __wsum diff, bool pseudohdr);
 
 static inline void inet_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
 					    __be16 from, __be16 to,
diff --git a/net/core/utils.c b/net/core/utils.c
index cd7d202..3dffce9 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -336,6 +336,19 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
 
+void inet_proto_csum_replace_by_diff(__sum16 *sum, struct sk_buff *skb,
+				     __wsum diff, bool pseudohdr)
+{
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		*sum = csum_fold(csum_add(diff, ~csum_unfold(*sum)));
+		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
+			skb->csum = ~csum_add(diff, ~skb->csum);
+	} else if (pseudohdr) {
+		*sum = ~csum_fold(csum_add(diff, csum_unfold(*sum)));
+	}
+}
+EXPORT_SYMBOL(inet_proto_csum_replace_by_diff);
+
 struct __net_random_once_work {
 	struct work_struct work;
 	struct static_key *key;
-- 
1.8.1
