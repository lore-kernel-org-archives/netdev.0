From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 2/8] tipc: limit error messages relating to memory leak to one line
Date: Thu, 12 Jul 2012 12:39:55 -0400
Message-ID: <1342111201-9426-3-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43534 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161220Ab2GLQk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:27 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the default name table size of 1024, it is possible that
the sanity check in tipc_nametbl_stop could spam out 1024
essentially identical error messages if memory was corrupted
or similar.  Limit it to issuing no more than a single message.

The actual chain number (i.e. 0 --> 1023) wouldn't provide any
useful insight if/when such an instance happened, so don't
bother printing out that value.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/name_table.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 13fb9d5..cade0ac 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -940,8 +940,10 @@ void tipc_nametbl_stop(void)
 	/* Verify name table is empty, then release it */
 	write_lock_bh(&tipc_nametbl_lock);
 	for (i = 0; i < tipc_nametbl_size; i++) {
-		if (!hlist_empty(&table.types[i]))
-			err("tipc_nametbl_stop(): hash chain %u is non-null\n", i);
+		if (hlist_empty(&table.types[i]))
+			continue;
+		err("tipc_nametbl_stop(): orphaned hash chain detected\n");
+		break;
 	}
 	kfree(table.types);
 	table.types = NULL;
-- 
1.7.9.7
