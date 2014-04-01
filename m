From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH v2 1/5] bonding: Changed hashing function to just provide hash
Date: Mon, 31 Mar 2014 19:04:41 -0700
Message-ID: <1396317881-5124-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:56280 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbaDACMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 22:12:10 -0400
Received: by mail-pa0-f73.google.com with SMTP id kq14so1172285pab.4
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 19:12:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Modified the hash function to return just hash separating from the
modulo operation that can be performed by the caller. This is to
make way for the tlb mode to use the same hashing policies that
are used in the 802.3ad and Xor mode.

Change-Id: I276609e87e0ca213c4d1b17b79c5e0b0f3d0dd6f
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
v2
  Change the return type of bond_xmit_hash() from int to u32

 drivers/net/bonding/bond_3ad.c  |  3 ++-
 drivers/net/bonding/bond_main.c | 10 ++++------
 drivers/net/bonding/bonding.h   |  2 +-
 3 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b667a51ed215..ccf2639e916f 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -30,6 +30,7 @@
 #include <linux/etherdevice.h>
 #include <linux/if_bonding.h>
 #include <linux/pkt_sched.h>
+#include <net/sock.h>
 #include <net/net_namespace.h>
 #include "bonding.h"
 #include "bond_3ad.h"
@@ -2440,7 +2441,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 		goto err_free;
 	}
 
-	slave_agg_no = bond_xmit_hash(bond, skb, slaves_in_agg);
+	slave_agg_no = bond_xmit_hash(bond, skb) % slaves_in_agg;
 	first_ok_slave = NULL;
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 95a6ca7d9e51..6e96d510bc8d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3015,20 +3015,18 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
  * bond_xmit_hash - generate a hash value based on the xmit policy
  * @bond: bonding device
  * @skb: buffer to use for headers
- * @count: modulo value
  *
  * This function will extract the necessary headers from the skb buffer and use
  * them to generate a hash based on the xmit_policy set in the bonding device
- * which will be reduced modulo count before returning.
  */
-int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count)
+u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 {
 	struct flow_keys flow;
 	u32 hash;
 
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER2 ||
 	    !bond_flow_dissect(bond, skb, &flow))
-		return bond_eth_hash(skb) % count;
+		return bond_eth_hash(skb);
 
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER23 ||
 	    bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23)
@@ -3039,7 +3037,7 @@ int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count)
 	hash ^= (hash >> 16);
 	hash ^= (hash >> 8);
 
-	return hash % count;
+	return hash;
 }
 
 /*-------------------------- Device entry points ----------------------------*/
@@ -3666,7 +3664,7 @@ static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 
-	bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb, bond->slave_cnt));
+	bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) % bond->slave_cnt);
 
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b8bdd0acc8f3..c0948ca26389 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -499,7 +499,7 @@ int bond_sysfs_slave_add(struct slave *slave);
 void bond_sysfs_slave_del(struct slave *slave);
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-int bond_xmit_hash(struct bonding *bond, struct sk_buff *skb, int count);
+u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_create_debugfs(void);
-- 
1.9.1.423.g4596e3a
