From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH] net/bonding: fix propagation of user-specified bond MAC
Date: Fri,  5 Jun 2015 18:24:07 -0400
Message-ID: <1433543047-34803-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org (open list:BONDING DRIVER)
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Its possible for users to specify their own MAC address for a bonded link,
and this used to work, until sometime in 2013...

First, commit 409cc1f8a changed a condition to set the bond's mac to a
slave device's, dropping the is_zero_ether_addr() check in favor of using
bond->dev_addr_from_first.

Next, commit 6c8c4e4c2 added a bond->slave_cnt == 0 condition.

Then, commit 97a1e6396 removed dev_addr_from_first and keyed off of
bond->dev->addr_assign_type.

The other contitional in the check to call bond_set_dev_addr() has gone
 through some permutations, finally landing at the following check:

	if (!bond_has_slaves(bond) &&
	    bond->dev->addr_assign_type == NET_ADDR_RANDOM)
		bond_set_dev_addr(bond->dev, slave_dev);

When the bond is initially brought up, with no active slaves, it gets
assigned a random address, and addr_assign_type is set to NET_ADDR_RANDOM.
Next up though, the user can provide their own MAC, which ultimately calls
bond_set_mac_address(). However, because addr_assign_type isn't touched,
the above conditions are still met, and the slave's MAC overwrites the
user-provided MAC.

The simple fix is to set addr_assign_type = NET_ADDR_SET at the tail end
of bond_set_mac_address() doing its thing, and user-specified MAC
addresses no longer get overwritten.

Nb: this is slightly tricky to test on current Fedora, as nmcli seems to
be braindead when it comes to setting a MAC address for a bond. I can do a
"nmcli con edit bond0", set ethernet.mac-address "xx:yy:zz:aa:bb:cc", but
it doesn't ever seem to do anything, and it doesn't persist to the next
boot. Manual tinkering was required to verify the issue and the fix using
ip link set commands.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org (open list:BONDING DRIVER)
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 19eb990..2aa5b5f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3544,6 +3544,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 
 	/* success */
 	memcpy(bond_dev->dev_addr, sa->sa_data, bond_dev->addr_len);
+	bond_dev->addr_assign_type = NET_ADDR_SET;
 	return 0;
 
 unwind:
-- 
1.8.3.1
