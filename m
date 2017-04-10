From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next 3/3] l3mdev: Fix lookup in local table when using main table
Date: Mon, 10 Apr 2017 15:22:02 +0100
Message-ID: <1491834122-26252-4-git-send-email-rshearma@brocade.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
        "Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:45922 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753243AbdDJOWc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 10:22:32 -0400
In-Reply-To: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an l3mdev is set to use the main table then the l3mdev rules will
return this. This means that no lookup will be done in the local table
if split local/main table is in effect and the local table lookup rule
has been reordered to after the l3mdev rule. Related to this is that
the order of the rule for looking up in the main table isn't
respected.

Fix these two aspects by not returning a match if the l3mdev's table
id is the main table. Processing will then proceed normally to the
default rules and do the appropriate lookups.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/l3mdev/l3mdev.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/l3mdev/l3mdev.c b/net/l3mdev/l3mdev.c
index 8da86ceca33d..5147959243c5 100644
--- a/net/l3mdev/l3mdev.c
+++ b/net/l3mdev/l3mdev.c
@@ -12,6 +12,7 @@
 #include <linux/netdevice.h>
 #include <net/fib_rules.h>
 #include <net/l3mdev.h>
+#include <net/ip6_fib.h>
 
 /**
  *	l3mdev_master_ifindex - get index of L3 master device
@@ -142,23 +143,36 @@ int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
 {
 	struct net_device *dev;
 	int rc = 0;
+	u32 tb_id;
 
 	rcu_read_lock();
 
 	dev = dev_get_by_index_rcu(net, fl->flowi_oif);
 	if (dev && netif_is_l3_master(dev) &&
 	    dev->l3mdev_ops->l3mdev_fib_table) {
-		arg->table = dev->l3mdev_ops->l3mdev_fib_table(dev);
-		rc = 1;
-		goto out;
+		tb_id = dev->l3mdev_ops->l3mdev_fib_table(dev);
+		/* This requires the main table id to be consistent
+		 * between IPv4 and IPv6.
+		 */
+		BUILD_BUG_ON(RT_TABLE_MAIN != RT6_TABLE_MAIN);
+		/* main table is handled by default rules */
+		if (tb_id != RT_TABLE_MAIN) {
+			arg->table = tb_id;
+			rc = 1;
+			goto out;
+		}
 	}
 
 	dev = dev_get_by_index_rcu(net, fl->flowi_iif);
 	if (dev && netif_is_l3_master(dev) &&
 	    dev->l3mdev_ops->l3mdev_fib_table) {
-		arg->table = dev->l3mdev_ops->l3mdev_fib_table(dev);
-		rc = 1;
-		goto out;
+		tb_id = dev->l3mdev_ops->l3mdev_fib_table(dev);
+		/* main table is handled by default rules */
+		if (tb_id != RT_TABLE_MAIN) {
+			arg->table = tb_id;
+			rc = 1;
+			goto out;
+		}
 	}
 
 out:
-- 
2.1.4
