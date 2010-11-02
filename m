From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] rds: Lost locking in loop connection freeing
Date: Tue, 02 Nov 2010 14:52:05 +0300
Message-ID: <4CCFFB65.6000404@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Grover <andy.grover@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18676 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004Ab0KBLwS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 07:52:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The conn is removed from list in there and this requires
proper lock protection.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/rds/loop.c b/net/rds/loop.c
index c390156..aeec1d4 100644
--- a/net/rds/loop.c
+++ b/net/rds/loop.c
@@ -134,8 +134,12 @@ static int rds_loop_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 static void rds_loop_conn_free(void *arg)
 {
 	struct rds_loop_connection *lc = arg;
+	unsigned long flags;
+
 	rdsdebug("lc %p\n", lc);
+	spin_lock_irqsave(&loop_conns_lock, flags);
 	list_del(&lc->loop_node);
+	spin_unlock_irqrestore(&loop_conns_lock, flags);
 	kfree(lc);
 }
 
-- 
1.5.5.6

