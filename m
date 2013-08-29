From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/2] bonding: remove bond_vlan_used()
Date: Thu, 29 Aug 2013 23:38:56 +0200
Message-ID: <1377812337-19551-2-git-send-email-vfalico@redhat.com>
References: <1377812337-19551-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56913 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515Ab3H2Vip (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 17:38:45 -0400
In-Reply-To: <1377812337-19551-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're using it currently to verify if we have vlans before getting the tag
from the skb we're about to send. It's useless because the vlan_get_tag()
verifies if the skb has the tag (and returns an error if not), and we can
receive tagged skbs only if we *already* have vlans.

Plus, the current RCUed implementation is kind of useless anyway - the we
can remove the last vlan in the moment we return from the function.

So remove the only usage of it and the whole function.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c |  6 ++----
 drivers/net/bonding/bonding.h  | 18 ------------------
 2 files changed, 2 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 0182352..27b03fa 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -694,10 +694,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 			client_info->ntt = 0;
 		}
 
-		if (bond_vlan_used(bond)) {
-			if (!vlan_get_tag(skb, &client_info->vlan_id))
-				client_info->tag = 1;
-		}
+		if (!vlan_get_tag(skb, &client_info->vlan_id))
+			client_info->tag = 1;
 
 		if (!client_info->assigned) {
 			u32 prev_tbl_head = bond_info->rx_hashtbl_used_head;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 4abc925..f7ab161 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -261,24 +261,6 @@ struct bonding {
 #endif /* CONFIG_DEBUG_FS */
 };
 
-/* if we hold rtnl_lock() - call vlan_uses_dev() */
-static inline bool bond_vlan_used(struct bonding *bond)
-{
-	struct net_device *upper;
-	struct list_head *iter;
-
-	rcu_read_lock();
-	netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
-		if (upper->priv_flags & IFF_802_1Q_VLAN) {
-			rcu_read_unlock();
-			return true;
-		}
-	}
-	rcu_read_unlock();
-
-	return false;
-}
-
 #define bond_slave_get_rcu(dev) \
 	((struct slave *) rcu_dereference(dev->rx_handler_data))
 
-- 
1.8.4
