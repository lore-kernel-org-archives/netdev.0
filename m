From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 2/4] bonding: use rcu_dereference() to access curr_active_slave
Date: Fri, 21 Feb 2014 16:08:53 +0800
Message-ID: <1392970135-11904-3-git-send-email-dingtianhong@huawei.com>
References: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:32145 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbaBUIJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 03:09:22 -0500
In-Reply-To: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_info_show_master already in RCU read-side critical section,
and the we access curr_active_slave without the curr_slave_lock, we
could not sure whether the curr_active_slave will be changed during
the processing, so use RCU to protected the pointer.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_procfs.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 434df73..588cf39 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -69,9 +69,7 @@ static void bond_info_show_master(struct seq_file *seq)
 	struct slave *curr;
 	int i;
 
-	read_lock(&bond->curr_slave_lock);
-	curr = bond->curr_active_slave;
-	read_unlock(&bond->curr_slave_lock);
+	curr = rcu_dereference(bond->curr_active_slave);
 
 	seq_printf(seq, "Bonding Mode: %s",
 		   bond_mode_name(bond->params.mode));
-- 
1.8.0
