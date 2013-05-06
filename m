From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH] rps_dev_flow_table_release(): no need to delay vfree()
Date: Mon, 6 May 2013 03:05:55 +0100
Message-ID: <20130506020555.GL25399@ZenIV.linux.org.uk>
References: <20130506020346.GK25399@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49391 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab3EFCF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 May 2013 22:05:56 -0400
Content-Disposition: inline
In-Reply-To: <20130506020346.GK25399@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same story as with fib_trie patch - vfree() from RCU callbacks
is legitimate now.
    
Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8898a4..a94a5a0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -593,7 +593,6 @@ struct rps_dev_flow {
 struct rps_dev_flow_table {
 	unsigned int mask;
 	struct rcu_head rcu;
-	struct work_struct free_work;
 	struct rps_dev_flow flows[0];
 };
 #define RPS_DEV_FLOW_TABLE_SIZE(_num) (sizeof(struct rps_dev_flow_table) + \
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 7427ab5..981fed3 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -606,21 +606,11 @@ static ssize_t show_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
 	return sprintf(buf, "%lu\n", val);
 }
 
-static void rps_dev_flow_table_release_work(struct work_struct *work)
-{
-	struct rps_dev_flow_table *table = container_of(work,
-	    struct rps_dev_flow_table, free_work);
-
-	vfree(table);
-}
-
 static void rps_dev_flow_table_release(struct rcu_head *rcu)
 {
 	struct rps_dev_flow_table *table = container_of(rcu,
 	    struct rps_dev_flow_table, rcu);
-
-	INIT_WORK(&table->free_work, rps_dev_flow_table_release_work);
-	schedule_work(&table->free_work);
+	vfree(table);
 }
 
 static ssize_t store_rps_dev_flow_table_cnt(struct netdev_rx_queue *queue,
