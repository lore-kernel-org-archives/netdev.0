From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] flow_dissector: Fix function argument ordering dependency
Date: Tue, 1 Sep 2015 18:11:04 -0700
Message-ID: <1441156264-38469-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57470 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753621AbbIBBLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 21:11:11 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t8219PSL004108
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 18:11:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1wnkvngd4f-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 18:11:11 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 7e839224510f11e58f9624be0595f910-53bf7240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 18:11:09 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c6cc1ca7f4d70c ("flowi: Abstract out functions to get flow hash
based on flowi") introduced a bug in __skb_set_sw_hash where we
require a dependency on evaluating arguments in a function in order.
There is no such ordering enforced in C, so this incorrect. This
patch fixes that by splitting out the arguments. This bug was
found via a compiler warning that keys may be uninitialized.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9e62687..eabfb81 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1035,9 +1035,9 @@ static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
 {
 	if (!skb->l4_hash && !skb->sw_hash) {
 		struct flow_keys keys;
+		__u32 hash = __get_hash_from_flowi6(fl6, &keys);
 
-		__skb_set_sw_hash(skb, __get_hash_from_flowi6(fl6, &keys),
-				  flow_keys_have_l4(&keys));
+		__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys));
 	}
 
 	return skb->hash;
@@ -1049,9 +1049,9 @@ static inline __u32 skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl4)
 {
 	if (!skb->l4_hash && !skb->sw_hash) {
 		struct flow_keys keys;
+		__u32 hash = __get_hash_from_flowi4(fl4, &keys);
 
-		__skb_set_sw_hash(skb, __get_hash_from_flowi4(fl4, &keys),
-				  flow_keys_have_l4(&keys));
+		__skb_set_sw_hash(skb, hash, flow_keys_have_l4(&keys));
 	}
 
 	return skb->hash;
-- 
1.8.1
