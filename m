From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] ipv6 Use get_hash_from_flowi6 for rt6 hash
Date: Wed, 23 Sep 2015 14:13:35 -0700
Message-ID: <1443042815-3458631-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <pch@ordbogen.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:42759 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753386AbbIWVNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:13:40 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t8NLAKFi024609
	for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 14:13:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1x43cbg5c6-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 14:13:39 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 f503d858623711e5b1c90002c95209d8-71dfa240 for <netdev@vger.kernel.org>;	Wed,
 23 Sep 2015 14:13:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rt6_info_hash_nhsfn replace the custom hashing over flowi6 that is
using xor with a call to common function get_hash_from_flowi6.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv6/route.c | 26 +-------------------------
 1 file changed, 1 insertion(+), 25 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 53617d7..111dead 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -421,31 +421,7 @@ static bool rt6_check_expired(const struct rt6_info *rt)
 static int rt6_info_hash_nhsfn(unsigned int candidate_count,
 			       const struct flowi6 *fl6)
 {
-	unsigned int val = fl6->flowi6_proto;
-
-	val ^= ipv6_addr_hash(&fl6->daddr);
-	val ^= ipv6_addr_hash(&fl6->saddr);
-
-	/* Work only if this not encapsulated */
-	switch (fl6->flowi6_proto) {
-	case IPPROTO_UDP:
-	case IPPROTO_TCP:
-	case IPPROTO_SCTP:
-		val ^= (__force u16)fl6->fl6_sport;
-		val ^= (__force u16)fl6->fl6_dport;
-		break;
-
-	case IPPROTO_ICMPV6:
-		val ^= (__force u16)fl6->fl6_icmp_type;
-		val ^= (__force u16)fl6->fl6_icmp_code;
-		break;
-	}
-	/* RFC6438 recommands to use flowlabel */
-	val ^= (__force u32)fl6->flowlabel;
-
-	/* Perhaps, we need to tune, this function? */
-	val = val ^ (val >> 7) ^ (val >> 12);
-	return val % candidate_count;
+	return get_hash_from_flowi6(fl6) % candidate_count;
 }
 
 static struct rt6_info *rt6_multipath_select(struct rt6_info *match,
-- 
2.4.6
