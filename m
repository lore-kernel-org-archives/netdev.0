From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 21/27] bonding: add __bond_next_slave() which uses neighbours
Date: Wed, 25 Sep 2013 09:20:26 +0200
Message-ID: <1380093632-1842-22-git-send-email-vfalico@redhat.com>
References: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25743 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774Ab3IYHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 03:21:09 -0400
In-Reply-To: <1380093632-1842-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new function, __bond_next_slave(), which uses neighbours to find the
next slave after the slave provided. It will be further used to gradually
go start using neighbour netdev_adjacent infrastructure instead of
bonding's own lists.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v4  -> v5
    No change.
    
    RFC -> v4:
    New patch.

 drivers/net/bonding/bonding.h | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 454d6af..4a3fbe3 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -250,6 +250,34 @@ struct bonding {
 	((struct slave *) rtnl_dereference(dev->rx_handler_data))
 
 /**
+ * __bond_next_slave - get the next slave after the one provided
+ * @bond - bonding struct
+ * @slave - the slave provided
+ *
+ * Returns the next slave after the slave provided, first slave if the
+ * slave provided is the last slave and NULL if slave is not found
+ */
+static inline struct slave *__bond_next_slave(struct bonding *bond,
+					      struct slave *slave)
+{
+	struct slave *slave_iter;
+	struct list_head *iter;
+	bool found = false;
+
+	netdev_for_each_lower_private(bond->dev, slave_iter, iter) {
+		if (found)
+			return slave_iter;
+		if (slave_iter == slave)
+			found = true;
+	}
+
+	if (found)
+		return bond_first_slave(bond);
+
+	return NULL;
+}
+
+/**
  * Returns NULL if the net_device does not belong to any of the bond's slaves
  *
  * Caller must hold bond lock for read
-- 
1.8.4
