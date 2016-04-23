From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH v2 net-next 2/2] RDS: TCP: Call pskb_extract() helper function
Date: Fri, 22 Apr 2016 18:36:36 -0700
Message-ID: <c02458923ae68d120b4114d72cb2f2648795747e.1461368732.git.sowmini.varadhan@oracle.com>
References: <cover.1461368732.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com, eric.dumazet@gmail.com,
	marcelo.leitner@gmail.com
To: netdev@vger.kernel.org, rds-devel@oss.oracle.com,
	santosh.shilimkar@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41460 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbcDWBhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 21:37:11 -0400
In-Reply-To: <cover.1461368732.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1461368732.git.sowmini.varadhan@oracle.com>
References: <cover.1461368732.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rds-stress experiments with request size 256 bytes, 8K acks,
using 16 threads show a 40% improvment when pskb_extract()
replaces the {skb_clone(..); pskb_pull(..); pskb_trim(..);}
pattern in the Rx path, so we leverage the perf gain with
this commit.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/rds/tcp_recv.c |   14 +++-----------
 1 files changed, 3 insertions(+), 11 deletions(-)

diff --git a/net/rds/tcp_recv.c b/net/rds/tcp_recv.c
index 27a9921..d75d8b5 100644
--- a/net/rds/tcp_recv.c
+++ b/net/rds/tcp_recv.c
@@ -207,22 +207,14 @@ static int rds_tcp_data_recv(read_descriptor_t *desc, struct sk_buff *skb,
 		}
 
 		if (left && tc->t_tinc_data_rem) {
-			clone = skb_clone(skb, arg->gfp);
+			to_copy = min(tc->t_tinc_data_rem, left);
+
+			clone = pskb_extract(skb, offset, to_copy, arg->gfp);
 			if (!clone) {
 				desc->error = -ENOMEM;
 				goto out;
 			}
 
-			to_copy = min(tc->t_tinc_data_rem, left);
-			if (!pskb_pull(clone, offset) ||
-			    pskb_trim(clone, to_copy)) {
-				pr_warn("rds_tcp_data_recv: pull/trim failed "
-					"left %zu data_rem %zu skb_len %d\n",
-					left, tc->t_tinc_data_rem, skb->len);
-				kfree_skb(clone);
-				desc->error = -ENOMEM;
-				goto out;
-			}
 			skb_queue_tail(&tinc->ti_skb_list, clone);
 
 			rdsdebug("skb %p data %p len %d off %u to_copy %zu -> "
-- 
1.7.1
