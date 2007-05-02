From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 3/4] s390: fix Oops when unloading module netiucv
Date: Wed, 2 May 2007 15:18:44 +0200
Message-ID: <20070502131844.GC25700@de.ibm.com>
References: <20070502131331.GA13217@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:36493 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993128AbXEBNPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 09:15:52 -0400
Content-Disposition: inline
In-Reply-To: <20070502131331.GA13217@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

don't remove an entry from iucv_connection_list in netiucv_exit().
netiucv_free_netdevice is called anyway, which takes care of entry
removal.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
netiucv.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/netiucv.c b/drivers/s390/net/netiucv.c
index e10e85e..c358764 100644
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -1862,12 +1862,14 @@ static void netiucv_remove_connection(struct iucv_connection *conn)
 	write_lock_bh(&iucv_connection_rwlock);
 	list_del_init(&conn->list);
 	write_unlock_bh(&iucv_connection_rwlock);
+	fsm_deltimer(&conn->timer);
+	netiucv_purge_skb_queue(&conn->collect_queue);
 	if (conn->path) {
 		iucv_path_sever(conn->path, iucvMagic);
 		kfree(conn->path);
 		conn->path = NULL;
 	}
-	fsm_deltimer(&conn->timer);
+	netiucv_purge_skb_queue(&conn->commit_queue);
 	kfree_fsm(conn->fsm);
 	kfree_skb(conn->rx_buff);
 	kfree_skb(conn->tx_buff);
@@ -2115,7 +2117,6 @@ static void __exit netiucv_exit(void)
 	while (!list_empty(&iucv_connection_list)) {
 		cp = list_entry(iucv_connection_list.next,
 				struct iucv_connection, list);
-		list_del(&cp->list);
 		ndev = cp->netdev;
 		priv = netdev_priv(ndev);
 		dev = priv->dev;
-- 
1.5.1.2

