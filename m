From: Jasper Spaans <spaans@fox-it.com>
Subject: [PATCH] Remove bond_dev from xmit_hash_policy call.
Date: Fri, 23 Oct 2009 16:09:24 +0200
Message-ID: <20091023140924.GA24611@spaans.fox.local>
References: <4AE1A37F.8010203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:11762 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901AbZJWOJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 10:09:26 -0400
Content-Disposition: inline
In-Reply-To: <4AE1A37F.8010203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the bonding device is no longer used in determining the device to
which to send packets, it can be dropped from the argument list of the various
xmit_hash_policy calls.

Signed-off-by: Jasper Spaans <spaans@fox-it.com>
---
 drivers/net/bonding/bond_3ad.c  |   11 +++++------
 drivers/net/bonding/bond_main.c |   11 ++++-------
 drivers/net/bonding/bonding.h   |    3 +--
 3 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c3fa31c..3cd8153 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1956,7 +1956,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	struct port *port, *prev_port, *temp_port;
 	struct aggregator *aggregator, *new_aggregator, *temp_aggregator;
 	int select_new_active_agg = 0;
-	
+
 	// find the aggregator related to this slave
 	aggregator = &(SLAVE_AD_INFO(slave).aggregator);
 
@@ -2024,7 +2024,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 
 				// clear the aggregator
 				ad_clear_agg(aggregator);
-				
+
 				if (select_new_active_agg) {
 					ad_agg_selection_logic(__get_first_agg(port));
 				}
@@ -2075,7 +2075,7 @@ void bond_3ad_unbind_slave(struct slave *slave)
 			}
 		}
 	}
-	port->slave=NULL;	
+	port->slave=NULL;
 }
 
 /**
@@ -2301,7 +2301,7 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 }
 
 /*
- * set link state for bonding master: if we have an active 
+ * set link state for bonding master: if we have an active
  * aggregator, we're up, if not, we're down.  Presumes that we cannot
  * have an active aggregator if there are no slaves with link up.
  *
@@ -2395,7 +2395,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	slave_agg_no = bond->xmit_hash_policy(skb, dev, slaves_in_agg);
+	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
 
 	bond_for_each_slave(bond, slave, i) {
 		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
@@ -2468,4 +2468,3 @@ out:
 
 	return ret;
 }
-
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3f05267..13058c5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3657,8 +3657,7 @@ void bond_unregister_arp(struct bonding *bond)
  * Hash for the output device based upon layer 2 and layer 3 data. If
  * the packet is not IP mimic bond_xmit_hash_policy_l2()
  */
-static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
-				     struct net_device *bond_dev, int count)
+static int bond_xmit_hash_policy_l23(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	struct iphdr *iph = ip_hdr(skb);
@@ -3676,8 +3675,7 @@ static int bond_xmit_hash_policy_l23(struct sk_buff *skb,
  * the packet is a frag or not TCP or UDP, just use layer 3 data.  If it is
  * altogether not IP, mimic bond_xmit_hash_policy_l2()
  */
-static int bond_xmit_hash_policy_l34(struct sk_buff *skb,
-				    struct net_device *bond_dev, int count)
+static int bond_xmit_hash_policy_l34(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 	struct iphdr *iph = ip_hdr(skb);
@@ -3701,8 +3699,7 @@ static int bond_xmit_hash_policy_l34(struct sk_buff *skb,
 /*
  * Hash for the output device based upon layer 2 data
  */
-static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
-				   struct net_device *bond_dev, int count)
+static int bond_xmit_hash_policy_l2(struct sk_buff *skb, int count)
 {
 	struct ethhdr *data = (struct ethhdr *)skb->data;
 
@@ -4295,7 +4292,7 @@ static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 	if (!BOND_IS_OK(bond))
 		goto out;
 
-	slave_no = bond->xmit_hash_policy(skb, bond_dev, bond->slave_cnt);
+	slave_no = bond->xmit_hash_policy(skb, bond->slave_cnt);
 
 	bond_for_each_slave(bond, slave, i) {
 		slave_no--;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6824771..02e1f9e 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -204,7 +204,7 @@ struct bonding {
 #endif /* CONFIG_PROC_FS */
 	struct   list_head bond_list;
 	struct   dev_mc_list *mc_list;
-	int      (*xmit_hash_policy)(struct sk_buff *, struct net_device *, int);
+	int      (*xmit_hash_policy)(struct sk_buff *, int);
 	__be32   master_ip;
 	u16      flags;
 	u16      rr_tx_counter;
@@ -370,4 +370,3 @@ static inline void bond_unregister_ipv6_notifier(void)
 #endif
 
 #endif /* _LINUX_BONDING_H */
-
-- 
1.6.0.4


-- 
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624
