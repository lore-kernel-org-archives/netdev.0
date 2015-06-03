From: Tom Herbert <tom@herbertland.com>
Subject: [RFC net-next 1/6] net: Checksum functions to replace 8 bytes at a time
Date: Wed, 3 Jun 2015 12:58:17 -0700
Message-ID: <1433361502-3478761-2-git-send-email-tom@herbertland.com>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <agartrell@fb.com>, <maheshb@google.com>,
	<tgraf@suug.ch>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:14311 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754785AbbFCT6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 15:58:44 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t53Jvwjk008260
	for <netdev@vger.kernel.org>; Wed, 3 Jun 2015 12:58:43 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ut7h4r4gq-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 12:58:43 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 eeadcfa00a2a11e5861f0002c95209d8-e56dc280 for <netdev@vger.kernel.org>;	Wed,
 03 Jun 2015 12:58:41 -0700
In-Reply-To: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are convenience functions for update a checksum in ILA where we
are overwriting the locator (first eight bytes of an ILA IPv6 address).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/checksum.h |  3 +++
 net/core/utils.c       | 19 +++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/net/checksum.h b/include/net/checksum.h
index 2d1d73c..af76b8e 100644
--- a/include/net/checksum.h
+++ b/include/net/checksum.h
@@ -141,6 +141,9 @@ static inline void csum_replace2(__sum16 *sum, __be16 old, __be16 new)
 struct sk_buff;
 void inet_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
 			      __be32 from, __be32 to, int pseudohdr);
+void inet_proto_csum_replace8(__sum16 *sum, struct sk_buff *skb,
+			      const __be32 *from, const __be32 *to,
+			      int pseudohdr);
 void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 			       const __be32 *from, const __be32 *to,
 			       int pseudohdr);
diff --git a/net/core/utils.c b/net/core/utils.c
index a7732a0..79d1067 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -336,6 +336,25 @@ void inet_proto_csum_replace16(__sum16 *sum, struct sk_buff *skb,
 }
 EXPORT_SYMBOL(inet_proto_csum_replace16);
 
+void inet_proto_csum_replace8(__sum16 *sum, struct sk_buff *skb,
+			      const __be32 *from, const __be32 *to,
+			      int pseudohdr)
+{
+	__be32 diff[] = {
+		~from[0], ~from[1], to[0], to[1],
+	};
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		*sum = csum_fold(csum_partial(diff, sizeof(diff),
+				 ~csum_unfold(*sum)));
+		if (skb->ip_summed == CHECKSUM_COMPLETE && pseudohdr)
+			skb->csum = ~csum_partial(diff, sizeof(diff),
+						  ~skb->csum);
+	} else if (pseudohdr)
+		*sum = ~csum_fold(csum_partial(diff, sizeof(diff),
+				  csum_unfold(*sum)));
+}
+EXPORT_SYMBOL(inet_proto_csum_replace8);
+
 struct __net_random_once_work {
 	struct work_struct work;
 	struct static_key *key;
-- 
1.8.1
