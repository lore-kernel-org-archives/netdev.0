From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 4/6] bonding: don't trust arp requests unless active slave really works
Date: Thu, 20 Jun 2013 18:35:03 +0200
Message-ID: <1371746105-2482-5-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com, nikolay@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965608Ab3FTQf2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 12:35:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if we receive any arp packet on a backup slave in active-backup
mode and arp_validate enabled, we suppose that it's an arp request, swap
source/target ip and try to validate it. This optimization gives us
virtually no downtime in the most common situation (active and backup
slaves are in the same broadcast domain and the active slave failed).

However, if we can't reach the arp_ip_target(s), we end up in an endless
loop of reselecting slaves, because we receive our arp requests, sent by
the active slave, and think that backup slaves are up, thus selecting them
as active and, again, sending arp requests, which fool our backup slaves.

Fix this by not validating the swapped arp packets if the current active
slave didn't receive any arp reply after it was selected as active. This
way we will only accept arp requests if we know that the current active
slave can actually reach arp_ip_target.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7fe9802..f51c379 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2677,10 +2677,15 @@ static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
 	 * configuration, the ARP probe will (hopefully) travel from
 	 * the active, through one switch, the router, then the other
 	 * switch before reaching the backup.
+	 *
+	 * We 'trust' the arp requests if there is an active slave and
+	 * it received valid arp reply(s) after it became active. This
+	 * is done to avoid endless looping when we can't reach the
+	 * arp_ip_target and fool ourselves with our own arp requests.
 	 */
 	if (bond_is_active_slave(slave))
 		bond_validate_arp(bond, slave, sip, tip);
-	else
+	else if (bond->curr_active_slave && time_after(slave_last_rx(bond, bond->curr_active_slave), bond->curr_active_slave->jiffies))
 		bond_validate_arp(bond, slave, tip, sip);
 
 out_unlock:
-- 
1.7.1
