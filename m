From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] rds: Remove kfreed tcp conn from list
Date: Tue, 02 Nov 2010 14:54:01 +0300
Message-ID: <4CCFFBD9.6030509@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: rds-devel@oss.oracle.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Grover <andy.grover@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5909 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081Ab0KBLyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Nov 2010 07:54:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All the rds_tcp_connection objects are stored list, but when
being freed it should be removed from there.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/rds/tcp.c b/net/rds/tcp.c
index 08a8c6c..8e0a320 100644
--- a/net/rds/tcp.c
+++ b/net/rds/tcp.c
@@ -221,7 +221,13 @@ static int rds_tcp_conn_alloc(struct rds_connection *conn, gfp_t gfp)
 static void rds_tcp_conn_free(void *arg)
 {
 	struct rds_tcp_connection *tc = arg;
+	unsigned long flags;
 	rdsdebug("freeing tc %p\n", tc);
+
+	spin_lock_irqsave(&rds_tcp_conn_lock, flags);
+	list_del(&tc->t_tcp_node);
+	spin_unlock_irqrestore(&rds_tcp_conn_lock, flags);
+
 	kmem_cache_free(rds_tcp_conn_slab, tc);
 }
 
-- 
1.5.5.6

