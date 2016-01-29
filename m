From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: [PATCH net] bonding: Fix ARP monitor validation
Date: Thu, 28 Jan 2016 17:33:08 -0800
Message-ID: <16766.1454031188@famine>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33750 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbcA2BdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 20:33:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	The current logic in bond_arp_rcv will accept an incoming ARP
for validation if (a) the receiving slave is either "active" (here
meaning the slave is functioning, not that it is the currently active
slave) or, (b) the currently active slave recently sent an ARP probe.

	This can fail if there is no currently active slave.  In this
case, the ARP probe logic cycles through all slaves, assigning each in
turn as the "current_arp_slave," setting that one as "active," and
sending an ARP probe from that slave.  The current logic expects the ARP
reply to arrive on this slave, however, due to switch FDB updating
delays, the reply may be directed to another slave.

	This leads to a pathological condition wherein the ARP target host
replies faster than the switch can update its forwarding table, causing
each ARP reply to be sent to the previous current_arp_slave.  This will
never pass the logic in bond_arp_rcv.

	Some experimentation on a LAN shows ARP reply round trips in the
200 usec range, but my available switches never update their FDB in less
than 4000 usec.

	This patch changes the logic to accept an ARP reply for validation
on any slave if there is a current ARP slave and it has recently sent an
ARP probe.

Fixes: aeea64ac717a ("bonding: don't trust arp requests unless active slave really works")
Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

---
 drivers/net/bonding/bond_main.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56b560558884..5a9c43b12999 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -214,6 +214,8 @@ static void bond_uninit(struct net_device *bond_dev);
 static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 						struct rtnl_link_stats64 *stats);
 static void bond_slave_arr_handler(struct work_struct *work);
+static bool bond_time_in_interval(struct bonding *bond, unsigned long last_act,
+				  int mod);
 
 /*---------------------------- General routines -----------------------------*/
 
@@ -2459,7 +2461,7 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 		 struct slave *slave)
 {
 	struct arphdr *arp = (struct arphdr *)skb->data;
-	struct slave *curr_active_slave;
+	struct slave *curr_active_slave, *curr_arp_slave;
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
 	int alen, is_arp = skb->protocol == __cpu_to_be16(ETH_P_ARP);
@@ -2506,6 +2508,7 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 		     &sip, &tip);
 
 	curr_active_slave = rcu_dereference(bond->curr_active_slave);
+	curr_arp_slave = rcu_dereference(bond->current_arp_slave);
 
 	/* Backup slaves won't see the ARP reply, but do come through
 	 * here for each ARP probe (so we swap the sip/tip to validate
@@ -2514,10 +2517,12 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	 * the active, through one switch, the router, then the other
 	 * switch before reaching the backup.
 	 *
-	 * We 'trust' the arp requests if there is an active slave and
-	 * it received valid arp reply(s) after it became active. This
-	 * is done to avoid endless looping when we can't reach the
-	 * arp_ip_target and fool ourselves with our own arp requests.
+	 * We 'trust' the arp requests if (a) there is an active slave and
+	 * it received valid arp reply(s) after it became active, or (b)
+	 * there is an ARP slave, and we receive a recent ARP reply on any
+	 * slave. This is done to avoid endless looping when we can't
+	 * reach the arp_ip_target and fool ourselves with our own arp
+	 * requests.
 	 */
 
 	if (bond_is_active_slave(slave))
@@ -2526,6 +2531,10 @@ int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 		 time_after(slave_last_rx(bond, curr_active_slave),
 			    curr_active_slave->last_link_up))
 		bond_validate_arp(bond, slave, tip, sip);
+	else if (curr_arp_slave && (arp->ar_op == htons(ARPOP_REPLY)) &&
+		 bond_time_in_interval(bond,
+				       dev_trans_start(curr_arp_slave->dev), 1))
+		bond_validate_arp(bond, slave, sip, tip);
 
 out_unlock:
 	if (arp != (struct arphdr *)skb->data)
-- 
1.9.1
