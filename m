From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH RFC net-next 2/2] RDS: TCP:  Call pskb_extract() helper function
Date: Mon, 18 Apr 2016 06:21:09 -0700
Message-ID: <ec8bc8b263c555b240967e0d912d0e41e1b6b17c.1460928360.git.sowmini.varadhan@oracle.com>
References: <cover.1460928360.git.sowmini.varadhan@oracle.com>
Cc: sowmini.varadhan@oracle.com
To: eric.dumazet@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19861 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbcDRNV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 09:21:26 -0400
In-Reply-To: <cover.1460928360.git.sowmini.varadhan@oracle.com>
In-Reply-To: <cover.1460928360.git.sowmini.varadhan@oracle.com>
References: <cover.1460928360.git.sowmini.varadhan@oracle.com>
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
