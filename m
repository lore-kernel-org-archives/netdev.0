From: <erik.hugne@ericsson.com>
Subject: [PATCH] tipc: fix dereference before check warning
Date: Wed, 13 Nov 2013 09:35:11 +0100
Message-ID: <1384331711-13707-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <jon.maloy@ericsson.com>, <paul.gortmaker@windriver.com>,
	<dan.carpenter@oracle.com>, <maloy@donjonn.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:55003 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141Ab3KMIi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 03:38:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

This fixes the following Smatch warning:
net/tipc/link.c:2364 tipc_link_recv_fragment()
    warn: variable dereferenced before check '*head' (see line 2361)

A null pointer might be passed to skb_try_coalesce if
a malicious sender injects orphan fragments on a link.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/link.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index cf465d6..69cd9bf 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2358,7 +2358,8 @@ int tipc_link_recv_fragment(struct sk_buff **head, struct sk_buff **tail,
 		*head = frag;
 		skb_frag_list_init(*head);
 		return 0;
-	} else if (skb_try_coalesce(*head, frag, &headstolen, &delta)) {
+	} else if (*head &&
+		   skb_try_coalesce(*head, frag, &headstolen, &delta)) {
 		kfree_skb_partial(frag, headstolen);
 	} else {
 		if (!*head)
-- 
1.7.9.5
