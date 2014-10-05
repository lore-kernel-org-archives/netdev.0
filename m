From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] ipv4: igmp: fix v3 general query drop monitor false positive
Date: Sun,  5 Oct 2014 17:27:50 +0200
Message-ID: <1412522870-26335-1-git-send-email-dborkman@redhat.com>
Cc: edumazet@google.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55555 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711AbaJEP1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 11:27:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case we find a general query with non-zero number of sources, we
are dropping the skb as it's malformed.

RFC3376, section 4.1.8. Number of Sources (N):

  This number is zero in a General Query or a Group-Specific Query,
  and non-zero in a Group-and-Source-Specific Query.

Therefore, reflect that by using kfree_skb() instead of consume_skb().

Fixes: d679c5324d9a ("igmp: avoid drop_monitor false positives")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 [ net-next as it's not really urgent. ]

 net/ipv4/igmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 4146153..fb70e3e 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -931,7 +931,7 @@ static bool igmp_heard_query(struct in_device *in_dev, struct sk_buff *skb,
 			in_dev->mr_qrv = ih3->qrv;
 		if (!group) { /* general query */
 			if (ih3->nsrcs)
-				return false;	/* no sources allowed */
+				return true;	/* no sources allowed */
 			igmp_gq_start_timer(in_dev);
 			return false;
 		}
-- 
1.7.11.7
