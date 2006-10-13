From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 10/14] [TIPC] Fixed slow link reactivation when link tolerance is large
Date: Fri, 13 Oct 2006 13:37:51 +0200
Message-ID: <116073947515-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:48544 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751399AbWJMLiC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:02 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch corrects an issue wherein a previouly failed node could
not reestablish a links to a non-failing node in the TIPC network
until the latter node detected the link failure itself (which might
be configured to take up to 30 seconds).  The non-failing node now
responds to link setup requests from a previously failed node in at
most 1 second, allowing it to detect the link failure more quickly.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/discover.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f58cc3c..7ea4c12 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -195,7 +195,8 @@ void tipc_disc_recv_msg(struct sk_buff *
 		struct sk_buff *rbuf;
 		struct tipc_media_addr *addr;
 		struct node *n_ptr = tipc_node_find(orig);
-		int link_up;
+		int link_fully_up;
+
 		dbg(" in own cluster\n");
 		if (n_ptr == NULL) {
 			n_ptr = tipc_node_create(orig);
@@ -225,9 +226,9 @@ void tipc_disc_recv_msg(struct sk_buff *
 			memcpy(addr, &media_addr, sizeof(*addr));
 			tipc_link_reset(link);     
 		}
-		link_up = tipc_link_is_up(link);
+		link_fully_up = (link->state == WORKING_WORKING);
 		spin_unlock_bh(&n_ptr->lock);                
-		if ((type == DSC_RESP_MSG) || link_up)
+		if ((type == DSC_RESP_MSG) || link_fully_up)
 			return;
 		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, 1, orig, b_ptr);
 		if (rbuf != NULL) {
-- 
1.4.1

