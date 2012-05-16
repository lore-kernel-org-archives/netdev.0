From: Chris Friesen <chris.friesen@genband.com>
Subject: [PATCH] bonding: only send arp monitor packets if no other traffic
Date: Wed, 16 May 2012 12:48:28 -0600
Message-ID: <4FB3F67C.6000401@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og123.obsmtp.com ([64.18.2.24]:60257 "EHLO
	exprod7og123.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429Ab2EPTZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:25:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to minimize network traffic, when using load balancing modes
only send out arp monitor packets if it's been more than delta_in_ticks
jiffies since we either received or transmitted packets.  The rationale
behind this is that if there is a lot of other traffic going on we don't
need the arp monitor packets to determine whether or not the link is
working.

This makes the most difference if you have a lot of hosts all arping
the same target at high frequency.

Signed-off-by: Chris Friesen <chris.friesen@genand.com>
---
 drivers/net/bonding/bond_main.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index bc13b3d..4c8459a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2885,8 +2885,12 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 		 * do - all replies will be rx'ed on same link causing slaves
 		 * to be unstable during low/no traffic periods
 		 */
-		if (IS_UP(slave->dev))
-			bond_arp_send_all(bond, slave);
+		if (IS_UP(slave->dev)) {
+			if (time_after_eq(jiffies, dev_trans_start(slave->dev) + delta_in_ticks) ||
+			    time_after_eq(jiffies, slave->dev->last_rx + delta_in_ticks)) {
+				bond_arp_send_all(bond, slave);
+			}
+		}
 	}
 
 	if (do_failover) {

-- 

Chris Friesen
Software Designer
3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
