From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 19/27] bonding: convert first/last slave logic to use neighbours
Date: Tue, 24 Sep 2013 13:46:59 +0200
Message-ID: <1380023227-9576-20-git-send-email-vfalico@redhat.com>
References: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21551 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753549Ab3IXLr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 07:47:29 -0400
In-Reply-To: <1380023227-9576-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For that, use netdev_adjacent_get_private(list_head) on bond's lower
neighbour list members. Also, add a small macro - bond_slave_list(bond),
which returns the bond list via neighbour list.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3  -> v4:
    No change.
    
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    Rename neieghour_dev_list to adj_list.

 drivers/net/bonding/bonding.h | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4b3878e..0b4c4ff 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -72,19 +72,24 @@
 	res; })
 
 /* slave list primitives */
-#define bond_has_slaves(bond) !list_empty(&(bond)->dev->adj_list.lower)
+#define bond_slave_list(bond) (&(bond)->dev->adj_list.lower)
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
