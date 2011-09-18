From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/28] tipc: Ensure congested links receive bearer status updates
Date: Sat, 17 Sep 2011 23:32:13 -0400
Message-ID: <1316316744-29514-18-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49989 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323Ab1IRDcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:54 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies code that disables a bearer to ensure that all of its links
are deleted, not just its uncongested links. Similarly, modifies code
that blocks a bearer to ensure that all of its links are reset, not
just its uncongested links.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index e465a92..e2202de 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -604,6 +604,7 @@ int tipc_block_bearer(const char *name)
 	info("Blocking bearer <%s>\n", name);
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
+	list_splice_init(&b_ptr->cong_links, &b_ptr->links);
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		struct tipc_node *n_ptr = l_ptr->owner;
 
@@ -631,6 +632,7 @@ static void bearer_disable(struct tipc_bearer *b_ptr)
 	spin_lock_bh(&b_ptr->lock);
 	b_ptr->blocked = 1;
 	b_ptr->media->disable_bearer(b_ptr);
+	list_splice_init(&b_ptr->cong_links, &b_ptr->links);
 	list_for_each_entry_safe(l_ptr, temp_l_ptr, &b_ptr->links, link_list) {
 		tipc_link_delete(l_ptr);
 	}
-- 
1.7.4.4
