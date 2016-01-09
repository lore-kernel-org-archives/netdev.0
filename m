From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next] bonding: make mii_status sysfs node consistent
Date: Fri,  8 Jan 2016 20:35:36 -0500
Message-ID: <1452303336-28203-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The spew in /proc/net/bonding/bond0 uses netif_carrier_ok() to determine
mii_status, while /sys/class/net/bond0/bonding/mii_status looks at
curr_active_slave, which doesn't actually seem to be set sometimes when
the bond actually is up. A mode 4 bond configured via ifcfg-foo files on a
Red Hat Enterprise Linux system, after boot, comes up clean and
functional, but the sysfs node shows mii_status of down, while proc shows
up. A simple enough fix here seems to be to use the same method for
determining up or down in both places, and I'd opt for the one that seems
to match reality.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 313dbac..e23c3ed 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -480,7 +480,7 @@ static ssize_t bonding_show_mii_status(struct device *d,
 				       char *buf)
 {
 	struct bonding *bond = to_bond(d);
-	bool active = !!rcu_access_pointer(bond->curr_active_slave);
+	bool active = netif_carrier_ok(bond->dev);
 
 	return sprintf(buf, "%s\n", active ? "up" : "down");
 }
-- 
1.8.3.1
