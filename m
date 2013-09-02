From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH RFC net-next 17/21] bonding: convert first/last slave logic to use neighbours
Date: Mon,  2 Sep 2013 23:39:21 +0200
Message-ID: <1378157965-17537-18-git-send-email-vfalico@redhat.com>
References: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932342Ab3IBVlg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 17:41:36 -0400
In-Reply-To: <1378157965-17537-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For that, use netdev_adjacent_get_private(list_head) on bond's lower
neighbour list members.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bonding.h | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 583077d..6731281 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -72,19 +72,24 @@
 	res; })
 
 /* slave list primitives */
-#define bond_has_slaves(bond) !list_empty(&(bond)->dev->neighbour_dev_list.lower)
+#define bond_slave_list(bond) (&(bond)->dev->neighbour_dev_list.lower)
+
+#define bond_has_slaves(bond) !list_empty(bond_slave_list(bond))
 
 #define bond_to_slave(ptr) list_entry(ptr, struct slave, list)
 
 /* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
 #define bond_first_slave(bond) \
-	list_first_entry_or_null(&(bond)->slave_list, struct slave, list)
+	(bond_has_slaves(bond) ? \
+		netdev_adjacent_get_private(bond_slave_list(bond)->next) : \
+		NULL)
 #define bond_last_slave(bond) \
-	(list_empty(&(bond)->slave_list) ? NULL : \
-					   bond_to_slave((bond)->slave_list.prev))
+	(bond_has_slaves(bond) ? \
+		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
+		NULL)
 
-#define bond_is_first_slave(bond, pos) ((pos)->list.prev == &(bond)->slave_list)
-#define bond_is_last_slave(bond, pos) ((pos)->list.next == &(bond)->slave_list)
+#define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
+#define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
 
 /* Since bond_first/last_slave can return NULL, these can return NULL too */
 #define bond_next_slave(bond, pos) \
-- 
1.8.4
