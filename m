From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 8/9] bonding: don't use bond_next_slave() in bond_info_seq_next()
Date: Fri, 27 Sep 2013 16:12:04 +0200
Message-ID: <1380291125-5671-9-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab3I0OMA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:12:00 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We don't need the circular loop there and it's the only current user of
bond_next_slave() - so just use the standard bond_for_each_slave().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_procfs.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index 7af5646..fb868d6 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -31,17 +31,25 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 static void *bond_info_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct bonding *bond = seq->private;
-	struct slave *slave = v;
+	struct list_head *iter;
+	struct slave *slave;
+	bool found = false;
 
 	++*pos;
 	if (v == SEQ_START_TOKEN)
 		return bond_first_slave(bond);
 
-	if (bond_is_last_slave(bond, slave))
+	if (bond_is_last_slave(bond, v))
 		return NULL;
-	slave = bond_next_slave(bond, slave);
 
-	return slave;
+	bond_for_each_slave(bond, slave, iter) {
+		if (found)
+			return slave;
+		if (slave == v)
+			found = true;
+	}
+
+	return NULL;
 }
 
 static void bond_info_seq_stop(struct seq_file *seq, void *v)
-- 
1.8.4
