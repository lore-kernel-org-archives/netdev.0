From: Andy Grover <andy.grover@oracle.com>
Subject: [PATCH 1/9] RDS: Fix m_rs_lock deadlock
Date: Mon, 30 Mar 2009 11:44:45 -0700
Message-ID: <1238438693-29540-2-git-send-email-andy.grover@oracle.com>
References: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Cc: rds-devel@oss.oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:27991 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758548AbZC3SpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 14:45:07 -0400
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n2UIir6J020873
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 18:44:54 GMT
In-Reply-To: <1238438693-29540-1-git-send-email-andy.grover@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rs_send_drop_to() is called during socket close. If it takes
m_rs_lock without disabling interrupts, then
rds_send_remove_from_sock() can run from the rx completion
handler and thus deadlock.

Signed-off-by: Andy Grover <andy.grover@oracle.com>
---
 net/rds/send.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/rds/send.c b/net/rds/send.c
index 1b37364..104fe03 100644
--- a/net/rds/send.c
+++ b/net/rds/send.c
@@ -615,7 +615,7 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 {
 	struct rds_message *rm, *tmp;
 	struct rds_connection *conn;
-	unsigned long flags;
+	unsigned long flags, flags2;
 	LIST_HEAD(list);
 	int wake = 0;
 
@@ -651,9 +651,9 @@ void rds_send_drop_to(struct rds_sock *rs, struct sockaddr_in *dest)
 	list_for_each_entry(rm, &list, m_sock_item) {
 		/* We do this here rather than in the loop above, so that
 		 * we don't have to nest m_rs_lock under rs->rs_lock */
-		spin_lock(&rm->m_rs_lock);
+		spin_lock_irqsave(&rm->m_rs_lock, flags2);
 		rm->m_rs = NULL;
-		spin_unlock(&rm->m_rs_lock);
+		spin_unlock_irqrestore(&rm->m_rs_lock, flags2);
 
 		/*
 		 * If we see this flag cleared then we're *sure* that someone
-- 
1.5.6.3

