From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/14] tipc: Check for disabled bearer when processing incoming messages
Date: Tue, 17 Aug 2010 17:00:07 -0400
Message-ID: <1282078816-11844-6-git-send-email-paul.gortmaker@windriver.com>
References: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57124 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab0HQVAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:24 -0400
In-Reply-To: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Add a check to tipc_recv_msg() to ensure it discards messages
arriving on a newly disabled bearer.  This is needed to deal with a
race condition that can arise if the bearer is in the midst of being
disabled when it receives a message.  Performing the check after
tipc_net_lock has been taken ensures that TIPC's bearers are in a
stable state while the message is being processed.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index a3616b9..9d18c9b 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1802,6 +1802,15 @@ static int link_recv_buf_validate(struct sk_buff *buf)
 	return pskb_may_pull(buf, hdr_size);
 }
 
+/**
+ * tipc_recv_msg - process TIPC messages arriving from off-node
+ * @head: pointer to message buffer chain
+ * @tb_ptr: pointer to bearer message arrived on
+ *
+ * Invoked with no locks held.  Bearer pointer must point to a valid bearer
+ * structure (i.e. cannot be NULL), but bearer can be inactive.
+ */
+
 void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 {
 	read_lock_bh(&tipc_net_lock);
@@ -1819,6 +1828,11 @@ void tipc_recv_msg(struct sk_buff *head, struct tipc_bearer *tb_ptr)
 
 		head = head->next;
 
+		/* Ensure bearer is still enabled */
+
+		if (unlikely(!b_ptr->active))
+			goto cont;
+
 		/* Ensure message is well-formed */
 
 		if (unlikely(!link_recv_buf_validate(buf)))
-- 
1.7.2.1

