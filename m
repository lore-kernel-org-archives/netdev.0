From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net] net/qlcnic: fix mac address restore in bond mode 5/6
Date: Fri,  6 Nov 2015 09:25:31 -0500
Message-ID: <1446819931-60897-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, Dept-GELinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, Manish Chopra <manish.chopra@qlogic.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bonding driver saves a copy of slaves' original mac address and then
assigns whatever mac as needed to the slave, depending on mode. In at
least modes 5 and 6 (balance-tlb, balance-alb), it often ends up being the
mac address of another slave. On release from the bond, the original mac
address is supposed to get restored via a dev_set_mac_address() call in
the bonding driver's __bond_release_one() function, which calls the
slave's ndo_set_mac_address function, which for qlcnic, is
qlcnic_set_mac().

Now, this function tries to be somewhat intelligent and exit early if
you're trying to set the mac address to the same thing that is already
set. The problem here is that adapter->mac_addr isn't in sync with
netdev->dev_addr. The qlcnic driver still has the original mac stored in
adapter->mac_addr, while the bonding driver has updated netdev->dev_addr,
so qlcnic thinks we're trying to set the same address it already has.

I think the way to go here, since the function updates both netdev and
adapter's stored mac addresses, is to check if either of them doesn't
match the newly requested mac. Simply checking netdev's value only could
result in a similar mismatch and non-update, so look at both.

CC: Dept-GELinuxNICDev@qlogic.com
CC: netdev@vger.kernel.org
CC: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d448145..1205f6f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -353,7 +353,8 @@ static int qlcnic_set_mac(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
 
-	if (ether_addr_equal_unaligned(adapter->mac_addr, addr->sa_data))
+	if (ether_addr_equal_unaligned(adapter->mac_addr, addr->sa_data) &&
+	    ether_addr_equal_unaligned(netdev->dev_addr, addr->sa_data))
 		return 0;
 
 	if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
-- 
1.8.3.1
