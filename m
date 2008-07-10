From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 5/7 net-next-2.6] tipc: Fix bug in scope checking for multicast messages
Date: Thu, 10 Jul 2008 17:26:09 -0400
Message-ID: <1215725171-10094-6-git-send-email-allan.stephens@windriver.com>
References: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:33123 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753758AbYGJVZL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 17:25:11 -0400
In-Reply-To: <1215725171-10094-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that TIPC's multicast message name lookup
algorithm does individualized scope checking for each published
name it examines.  Previously, scope checking was only done for
the first name in a name table publication list, which could
result in incoming multicast messages being delivered to ports
publishing names with "node" scope, or not being delivered to
ports publishing names with "cluster" or "zone" scope.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/name_table.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 096f7bd..1e53b0c 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -710,9 +710,11 @@ int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
 		if (sseq->lower > upper)
 			break;
 		publ = sseq->cluster_list;
-		if (publ && (publ->scope <= limit))
+		if (publ)
 			do {
-				if (publ->node == tipc_own_addr)
+				if (publ->scope > limit)
+					/* ignore out-of-scope publication */ ;
+				else if (publ->node == tipc_own_addr)
 					tipc_port_list_add(dports, publ->ref);
 				else
 					res = 1;
-- 
1.5.4.3

