From: Sachin Sant <sachinp@in.ibm.com>
Subject: [Patch -next] Adapt s390 qeth & lcs driver code to use RCU
Date: Thu, 18 Nov 2010 14:48:46 +0530
Message-ID: <20101118091846.26534.38865.sendpatchset@localhost.localdomain>
Cc: Sachin Sant <sachinp@in.ibm.com>, linux-s390@vger.kernel.org,
	linux-next@vger.kernel.org, ursula.braun@de.ibm.com,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 1d7138de878d1d4210727c1200193e69596f93b3
igmp: RCU conversion of in_dev->mc_list

converted rwlock to RCU.

Update the s390 network drivers(qeth & lcs) code to adapt to this change.

Signed-off-by : Sachin Sant <sachinp@in.ibm.com>
---

Only compile tested.

diff -Narup linux-2.6-next/drivers/s390/net/lcs.c linux-2.6-next-new/drivers/s390/net/lcs.c
--- linux-2.6-next/drivers/s390/net/lcs.c	2010-11-17 11:38:25.000000000 +0530
+++ linux-2.6-next-new/drivers/s390/net/lcs.c	2010-11-18 11:59:46.000000000 +0530
@@ -1269,10 +1269,10 @@ lcs_register_mc_addresses(void *data)
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		goto out;
-	read_lock(&in4_dev->mc_list_lock);
+	rcu_read_lock();
 	lcs_remove_mc_addresses(card,in4_dev);
 	lcs_set_mc_addresses(card, in4_dev);
-	read_unlock(&in4_dev->mc_list_lock);
+	rcu_read_unlock();
 	in_dev_put(in4_dev);
 
 	netif_carrier_off(card->dev);
diff -Narup linux-2.6-next/drivers/s390/net/qeth_l3_main.c linux-2.6-next-new/drivers/s390/net/qeth_l3_main.c
--- linux-2.6-next/drivers/s390/net/qeth_l3_main.c	2010-10-30 12:54:22.000000000 +0530
+++ linux-2.6-next-new/drivers/s390/net/qeth_l3_main.c	2010-11-18 11:59:13.000000000 +0530
@@ -1828,9 +1828,9 @@ static void qeth_l3_add_vlan_mc(struct q
 		in_dev = in_dev_get(netdev);
 		if (!in_dev)
 			continue;
-		read_lock(&in_dev->mc_list_lock);
+		rcu_read_lock();
 		qeth_l3_add_mc(card, in_dev);
-		read_unlock(&in_dev->mc_list_lock);
+		rcu_read_unlock();
 		in_dev_put(in_dev);
 	}
 }
@@ -1843,10 +1843,10 @@ static void qeth_l3_add_multicast_ipv4(s
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		return;
-	read_lock(&in4_dev->mc_list_lock);
+	rcu_read_lock();
 	qeth_l3_add_mc(card, in4_dev);
 	qeth_l3_add_vlan_mc(card);
-	read_unlock(&in4_dev->mc_list_lock);
+	rcu_read_unlock();
 	in_dev_put(in4_dev);
 }
 
