From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/3] bonding: fix ASSERT_RTNL that produces spurious warnings
Date: Mon,  7 Jan 2008 17:56:59 -0800
Message-ID: <1199757423867-git-send-email-fubar@us.ibm.com>
References: <11997574203125-git-send-email-fubar@us.ibm.com>
 <11997574222492-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:33690 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752951AbYAHB5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2008 20:57:06 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m081v5pO016840
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:05 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m081v51b060174
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:05 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m081v4uv022368
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 20:57:05 -0500
In-Reply-To: <11997574222492-git-send-email-fubar@us.ibm.com>
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

