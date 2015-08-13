From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/3] net: Add inet_proto_csum_replace_by_diff utility function
Date: Thu, 13 Aug 2015 09:54:02 -0700
Message-ID: <1439484843-3848061-3-git-send-email-tom@herbertland.com>
References: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tgraf@suug.ch>, <roopa@cumulusnetworks.com>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:49975 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753203AbbHMQyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 12:54:43 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7DGqGnb023393
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:54:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w8x9fr582-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2015 09:54:42 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 fd30c77441db11e59ee824be0593f280-dd3fc2b0 for <netdev@vger.kernel.org>;	Thu,
 13 Aug 2015 09:54:40 -0700
In-Reply-To: <1439484843-3848061-1-git-send-email-tom@herbertland.com>
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
index 2d1d73c..0e0c987 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -144,6 +144,8 @@ void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 			       const __be32 *from, const __be32 *to,
 			       int pseudohdr);
+void inet_proto_csum_replace_by_diff(__sum16 *sum, struct sk_buff *skb,
+				     __wsum diff, int pseudohdr);
 
 static inline void inet_proto_csum_replace2(__sum16 *sum, struct sk_buff *skb,
 					    __be16 from, __be16 to,
diff --git a/net/core/utils.c b/net/core/utils.c
index a7732a0..89ccfb1 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -336,6 +336,19 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
 
+void inet_proto_csum_replace_by_diff(__sum16 *sum, struct sk_buff *skb,
+				     __wsum diff, int pseudohdr)
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
