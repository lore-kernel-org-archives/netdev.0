From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/8] net: Checks skb_dst to be NULL in inet_iif
Date: Tue, 5 Apr 2016 08:22:49 -0700
Message-ID: <1459869776-2090500-2-git-send-email-tom@herbertland.com>
References: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60026 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758877AbcDEPXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:23:11 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u35FIrt0013280
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:23:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 222xhgbe9p-5
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:23:09 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 4b802828fb4211e5b9fc24be05956610-e6fc13f0 for <netdev@vger.kernel.org>;	Tue,
 05 Apr 2016 08:23:06 -0700
In-Reply-To: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In inet_iif check if skb_rtable is NULL for the skb and return
skb->skb_iif if it is.

This change allows inet_iif to be called before the dst
information has been set in the skb (e.g. when doing socket based
UDP GRO).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/route.h | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 9b0a523..f4b11ee 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -322,10 +322,11 @@ static inline struct rtable *ip_route_newports(struct flowi4 *fl4, struct rtable
 
 static inline int inet_iif(const struct sk_buff *skb)
 {
-	int iif = skb_rtable(skb)->rt_iif;
+	struct rtable *rt = skb_rtable(skb);
+
+	if (rt && rt->rt_iif)
+		return rt->rt_iif;
 
-	if (iif)
-		return iif;
 	return skb->skb_iif;
 }
 
-- 
2.8.0.rc2
