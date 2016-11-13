From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 28/39] netfilter: ipset: Simplify mtype_expire() for hash types
Date: Sun, 13 Nov 2016 23:25:22 +0100
Message-ID: <1479075933-4491-29-git-send-email-pablo@netfilter.org>
References: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:47690 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965164AbcKMW0X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Nov 2016 17:26:23 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 154CBC1069
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:23 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 07D3DDA80B
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:23 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 12B02DA861
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 23:26:21 +0100 (CET)
In-Reply-To: <1479075933-4491-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

Remove one leve of intendation by using continue while
iterating over elements in bucket.

Ported from a patch proposed by Sergey Popovich <popovich_sergei@mail.ua>.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_hash_gen.h | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_hash_gen.h b/net/netfilter/ipset/ip_set_hash_gen.h
index c4877b6de74f..7999e4c556a5 100644
--- a/net/netfilter/ipset/ip_set_hash_gen.h
+++ b/net/netfilter/ipset/ip_set_hash_gen.h
@@ -487,21 +487,20 @@ mtype_expire(struct ip_set *set, struct htype *h)
 				continue;
 			}
 			data = ahash_data(n, j, dsize);
-			if (ip_set_timeout_expired(ext_timeout(data, set))) {
-				pr_debug("expired %u/%u\n", i, j);
-				clear_bit(j, n->used);
-				smp_mb__after_atomic();
+			if (!ip_set_timeout_expired(ext_timeout(data, set)))
+				continue;
+			pr_debug("expired %u/%u\n", i, j);
+			clear_bit(j, n->used);
+			smp_mb__after_atomic();
 #ifdef IP_SET_HASH_WITH_NETS
-				for (k = 0; k < IPSET_NET_COUNT; k++)
-					mtype_del_cidr(h,
-						NCIDR_PUT(DCIDR_GET(data->cidr,
-								    k)),
-						nets_length, k);
+			for (k = 0; k < IPSET_NET_COUNT; k++)
+				mtype_del_cidr(h,
+					NCIDR_PUT(DCIDR_GET(data->cidr, k)),
+					nets_length, k);
 #endif
-				ip_set_ext_destroy(set, data);
-				set->elements--;
-				d++;
-			}
+			ip_set_ext_destroy(set, data);
+			set->elements--;
+			d++;
 		}
 		if (d >= AHASH_INIT_SIZE) {
 			if (d >= n->size) {
-- 
2.1.4
