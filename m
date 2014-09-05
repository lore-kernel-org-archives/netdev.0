From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 3/5] bonding: procfs: clean bond->lock usage and use RTNL
Date: Fri,  5 Sep 2014 20:16:49 +0200
Message-ID: <1409941011-5494-4-git-send-email-nikolay@redhat.com>
References: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751612AbaIESRJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 14:17:09 -0400
In-Reply-To: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RTNL because bond->primary_slave might change otherwise.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_procfs.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index de62c0385dfb..eee937afe94e 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -7,7 +7,6 @@
 
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	__acquires(RCU)
-	__acquires(&bond->lock)
 {
 	struct bonding *bond = seq->private;
 	struct list_head *iter;
@@ -15,8 +14,8 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 	loff_t off = 0;
 
 	/* make sure the bond won't be taken away */
+	rtnl_lock();
 	rcu_read_lock();
-	read_lock(&bond->lock);
 
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
@@ -53,13 +52,10 @@ static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void bond_info_seq_stop(struct seq_file *seq, void *v)
-	__releases(&bond->lock)
 	__releases(RCU)
 {
-	struct bonding *bond = seq->private;
-
-	read_unlock(&bond->lock);
 	rcu_read_unlock();
+	rtnl_unlock();
 }
 
 static void bond_info_show_master(struct seq_file *seq)
-- 
1.9.3
