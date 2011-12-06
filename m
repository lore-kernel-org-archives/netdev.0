From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/13 net-3.1-stable] qeth: l3 fix rcu splat in xmit
Date: Tue, 06 Dec 2011 16:33:26 -0500 (EST)
Message-ID: <20111206.163326.2285528514364780297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565Ab1LFVd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:28 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXQuW024161
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:27 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Frank Blaschka <frank.blaschka@de.ibm.com>

[ Upstream commit 1d36cb479f204a0fedc1a3e7ce7b32c0a2c48769 ]

when use dst_get_neighbour to get neighbour, we need
rcu_read_lock to protect, since dst_get_neighbour uses
rcu_dereference.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/s390/net/qeth_l3_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index fafb8c2..c74e867 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2740,11 +2740,13 @@ int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 	struct neighbour *n = NULL;
 	struct dst_entry *dst;
 
+	rcu_read_lock();
 	dst = skb_dst(skb);
 	if (dst)
 		n = dst_get_neighbour(dst);
 	if (n) {
 		cast_type = n->type;
+		rcu_read_unlock();
 		if ((cast_type == RTN_BROADCAST) ||
 		    (cast_type == RTN_MULTICAST) ||
 		    (cast_type == RTN_ANYCAST))
@@ -2752,6 +2754,8 @@ int inline qeth_l3_get_cast_type(struct qeth_card *card, struct sk_buff *skb)
 		else
 			return RTN_UNSPEC;
 	}
+	rcu_read_unlock();
+
 	/* try something else */
 	if (skb->protocol == ETH_P_IPV6)
 		return (skb_network_header(skb)[24] == 0xff) ?
@@ -2807,6 +2811,8 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 	}
 
 	hdr->hdr.l3.length = skb->len - sizeof(struct qeth_hdr);
+
+	rcu_read_lock();
 	dst = skb_dst(skb);
 	if (dst)
 		n = dst_get_neighbour(dst);
@@ -2853,6 +2859,7 @@ static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 				QETH_CAST_UNICAST | QETH_HDR_PASSTHRU;
 		}
 	}
+	rcu_read_unlock();
 }
 
 static inline void qeth_l3_hdr_csum(struct qeth_card *card,
-- 
1.7.7.3
