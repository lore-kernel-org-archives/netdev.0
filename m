From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/14] tipc: Prevent crash when broadcast link cannot send to all nodes
Date: Tue, 17 Aug 2010 17:00:08 -0400
Message-ID: <1282078816-11844-7-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57126 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242Ab0HQVAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:24 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Allow TIPC's broadcast link to continue operation when it is unable
to send a message to all nodes in the cluster.  Previously, the
broadcast link attempted to put the broadcast pseudo-bearer into a
blocked state; however, this caused a crash because the associated
bearer structure is only partially initialized.  Further
investigation has revealed some conceptual problems with blocking
the pseudo-bearer; consequently, this functionality has been
disabled for the time being and the undelivered message is
eventually resent by the broadcast link's existing message
retransmission mechanism (if possible).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a008c66..42b1737 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -609,11 +609,13 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		bcbearer->remains = bcbearer->remains_new;
 	}
 
-	/* Unable to reach all targets */
+	/*
+	 * Unable to reach all targets (indicate success, since currently
+	 * there isn't code in place to properly block & unblock the
+	 * pseudo-bearer used by the broadcast link)
+	 */
 
-	bcbearer->bearer.publ.blocked = 1;
-	bcl->stats.bearer_congs++;
-	return 1;
+	return TIPC_OK;
 }
 
 /**
-- 
1.7.2.1

