From: Chris J Arges <chris.j.arges@canonical.com>
Subject: [PATCH v4 net-next] bonding: extend bond_arp_send_all to bridge devices
Date: Tue,  6 Nov 2012 07:56:45 -0600
Message-ID: <1352210205-24558-1-git-send-email-chris.j.arges@canonical.com>
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

This patch extends bond_arp_send_all to check if a device
is also in a bridge.

This is related to the following issues:
http://launchpad.net/bugs/736226
http://bugzilla.kernel.org/show_bug.cgi?id=31822

Thanks to help from Andy Gospodarek <andy@greyhouse.net>.

Signed-off-by: Chris J Arges <chris.j.arges@canonical.com>
---
 drivers/net/bonding/bond_main.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b2530b0..62931b0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2708,6 +2708,14 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 			continue;
 		}
 
+		/* Check if the target is part of a bridge.
+		 */
+		if (rt->dst.dev->priv_flags & IFF_EBRIDGE) {
+			addr = bond_confirm_addr(rt->dst.dev, targets[i], 0);
+			bond_arp_send(slave->dev, ARPOP_REQUEST, targets[i], addr, 0);
+			continue;
+		}
+
 		if (net_ratelimit()) {
 			pr_warning("%s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 				   bond->dev->name, &targets[i],
-- 
1.7.9.5
