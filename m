From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH 1/1] bonding: properly unset current_arp_slave on slave link
 up
Date: Thu, 5 Apr 2012 15:47:43 +0200
Message-ID: <20120405134743.GB16870@darkmag.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a slave comes up, we're unsetting the current_arp_slave without
removing active flags from it, which can lead to situations where we have
more than one slave with active flags in active-backup mode.

To avoid this situation we must remove the active flags from a slave before
removing it as a current_arp_slave.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0c76186..ad731a1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3001,7 +3001,11 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 					   trans_start + delta_in_ticks)) ||
 			    bond->curr_active_slave != slave) {
 				slave->link = BOND_LINK_UP;
-				bond->current_arp_slave = NULL;
+				if (bond->current_arp_slave) {
+					bond_set_slave_inactive_flags(
+						bond->current_arp_slave);
+					bond->current_arp_slave = NULL;
+				}
 
 				pr_info("%s: link status definitely up for interface %s.\n",
 					bond->dev->name, slave->dev->name);
