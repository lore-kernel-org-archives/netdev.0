From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/7] bonding: fix ASSERT_RTNL that produces spurious warnings
Date: Thu, 17 Jan 2008 16:24:58 -0800
Message-ID: <12006159071917-git-send-email-fubar@us.ibm.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
 <12006159063217-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42519 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230AbYARAZM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:25:12 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0PAbd025638
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:10 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0P9n3254026
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:09 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0P8Tv022145
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:09 -0500
In-Reply-To: <12006159063217-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Move an ASSERT_RTNL down to where we should hold only RTNL;
the existing check produces spurious warnings because we hold additional
locks at _bh, tripping a debug warning in spin_lock_mutex().

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_alb.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 25b8dbf..9b55a12 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1601,9 +1601,6 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	struct slave *swap_slave;
 	int i;
 
-	if (new_slave)
-		ASSERT_RTNL();
-
 	if (bond->curr_active_slave == new_slave) {
 		return;
 	}
@@ -1649,6 +1646,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	write_unlock_bh(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
 
+	ASSERT_RTNL();
+
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
 	if (swap_slave) {
 		/* swap mac address */
-- 
1.5.3.4.206.g58ba4-dirty

