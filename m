From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/2] tipc: fix a loop style problem
Date: Fri, 14 Feb 2014 16:40:43 -0500
Message-ID: <1392414044-14326-2-git-send-email-jon.maloy@ericsson.com>
References: <1392414044-14326-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.bf1.yahoo.com ([98.139.221.63]:21118 "HELO
	smtp104.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752778AbaBNVr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 16:47:59 -0500
In-Reply-To: <1392414044-14326-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 7d33939f475d403e79124e3143d7951dcfe8629f
("tipc: delay delete of link when failover is needed") we
introduced a loop for finding and removing a link pointer
in an array. The removal is done after we have left the loop,
giving the impression that one may remove the wrong pointer
if no matching element is found.

This is not really a bug, since we know that there will always
be a matching element, but it looks wrong, and causes a smatch
warning.

We fix this loop with this commit.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/node.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 833324b..8596880 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -252,12 +252,12 @@ void tipc_node_detach_link(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	int i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		if (l_ptr == n_ptr->links[i])
-			break;
+		if (l_ptr != n_ptr->links[i])
+			continue;
+		n_ptr->links[i] = NULL;
+		atomic_dec(&tipc_num_links);
+		n_ptr->link_cnt--;
 	}
-	n_ptr->links[i] = NULL;
-	atomic_dec(&tipc_num_links);
-	n_ptr->link_cnt--;
 }
 
 static void node_established_contact(struct tipc_node *n_ptr)
-- 
1.7.9.5
