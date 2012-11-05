From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH] bonding: extend bond_arp_send_all to bridge devices
Date: Mon,  5 Nov 2012 14:14:08 -0600
Message-ID: <1352146448-8921-1-git-send-email-chris.j.arges@canonical.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris J Arges <chris.j.arges@canonical.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARP monitoring does not work when we have a network in the
following configuration:

eth0----+ +----bond0.100----br0-100---{+virtual machines
          | |
          +----bond0----+----br0---(fixed IP)->--{LAN arp_ip_target}
          | |
eth1----+ +----bond0.200----br0-200---{+virtual machines

This patch extends bond_arp_send_all to also check if a device
is also in a bridge.

This is related to the following issues:
http://launchpad.net/bugs/736226
http://bugzilla.kernel.org/show_bug.cgi?id=31822

Thanks to help from Andy Gospodarek.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 drivers/net/bonding/bond_main.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6c284d1..f11a2e1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2670,6 +2670,19 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			continue;
 		}
 
+		/*
+		 * Check if the target is part of a bridge.
+		 */
+		if (rt->dst.dev->priv_flags & IFF_EBRIDGE) {
+			printk("bondbridge: %s->priv_flags has IFF_EBRIDGE\n", rt->dst.dev->name);
+
+			/* Send ARP request */
+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], bond->master_ip, 0);
+			printk("bondbridge: bond_arp_send %d\n", 0);
+
+			continue;
+		}
+
 		if (net_ratelimit()) {
 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 				   bond->dev->name, &targets[i],
-- 
1.7.9.5
