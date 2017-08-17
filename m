From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH] netfilter: ipset: ipset list may return wrong member count for set with timeout
Date: Thu, 17 Aug 2017 01:23:55 -0400
Message-ID: <1502947435-18549-1-git-send-email-vpai@akamai.com>
Cc: johunt@akamai.com, pai.vishwain@gmail.com, vpai@akamai.com,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00190b01.pphosted.com ([67.231.157.127]:54155 "EHLO
        mx0b-00190b01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750800AbdHQFYK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 01:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simple testcase:

$ ipset create test hash:ip timeout 5
$ ipset add test 1.2.3.4
$ ipset add test 1.2.2.2
$ sleep 5

$ ipset l
Name: test
Type: hash:ip
Revision: 5
Header: family inet hashsize 1024 maxelem 65536 timeout 5
Size in memory: 296
References: 0
Number of entries: 2
Members:

We return "Number of entries: 2" but no members are listed. That is
because mtype_list runs "ip_set_timeout_expired" and does not list the
expired entries, but set->elements is never upated (until mtype_gc
cleans it up later).

Reviewed-by: Joshua Hunt <johunt@akamai.com>
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index f236c0b..ff3d31c 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -1041,12 +1041,22 @@ struct htype {
 static int
 mtype_head(struct ip_set *set, struct sk_buff *skb)
 {
-	const struct htype *h = set->data;
+	struct htype *h = set->data;
 	const struct htable *t;
 	struct nlattr *nested;
 	size_t memsize;
 	u8 htable_bits;
 
+	/* If any members have expired, set->elements will be wrong
+	 * mytype_expire function will update it with the right count.
+	 * we do not hold set->lock here, so grab it first.
+	 */
+	if (SET_WITH_TIMEOUT(set)) {
+		spin_lock_bh(&set->lock);
+		mtype_expire(set, h);
+		spin_unlock_bh(&set->lock);
+	}
+
 	rcu_read_lock_bh();
 	t = rcu_dereference_bh_nfnl(h->table);
 	memsize = mtype_ahash_memsize(h, t) + set->ext_size;
-- 
1.9.1
