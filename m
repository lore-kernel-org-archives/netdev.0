From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: ensure that TLB mode's active slave has correct mac filter
Date: Mon,  7 Oct 2013 09:17:20 +0200
Message-ID: <1381130240-3561-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Yuval Mintz <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689Ab3JGHQ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 03:16:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, in TLB mode we change mac addresses only by memcpy-ing the to
net_device->dev_addr, without actually setting them via
dev_set_mac_address(). This permits us to receive all the traffic always on
one mac address.

However, in case the interface flips, some drivers might enforce the
mac filtering for its FW/HW based on current ->dev_addr, and thus we won't
be able to receive traffic on that interface, in case it will be selected
as active in TLB mode.

Fix it by setting the mac address forcefully on every new active slave that
we select in TLB mode.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Yuval Mintz <yuvalmin@broadcom.com>
Reported-by: Yuval Mintz <yuvalmin@broadcom.com>
Tested-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    It seems that it's the least intrusive fix. The, maybe, better
    way would be to leave the dev_addr unchainged and play around
    with mac addresses in logic, however it's making the code a lot
    more bloated, error prone and hard to read, so it's not worth it,
    imho.

 drivers/net/bonding/bond_alb.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e960418..576ccea 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1699,6 +1699,23 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 
 	ASSERT_RTNL();
 
+	/* in TLB mode, the slave might flip down/up with the old dev_addr,
+	 * and thus filter bond->dev_addr's packets, so force bond's mac
+	 */
+	if (bond->params.mode == BOND_MODE_TLB) {
+		struct sockaddr sa;
+		u8 tmp_addr[ETH_ALEN];
+
+		memcpy(tmp_addr, new_slave->dev->dev_addr, ETH_ALEN);
+
+		memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev->addr_len);
+		sa.sa_family = bond->dev->type;
+		/* we don't care if it can't change its mac, best effort */
+		dev_set_mac_address(new_slave->dev, &sa);
+
+		memcpy(new_slave->dev->dev_addr, tmp_addr, ETH_ALEN);
+	}
+
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
 	if (swap_slave) {
 		/* swap mac address */
-- 
1.8.4
