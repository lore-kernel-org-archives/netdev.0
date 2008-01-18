From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 7/7] bonding: Don't hold lock when calling rtnl_unlock
Date: Thu, 17 Jan 2008 16:25:03 -0800
Message-ID: <12006159131703-git-send-email-fubar@us.ibm.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
 <12006159063217-git-send-email-fubar@us.ibm.com>
 <12006159071917-git-send-email-fubar@us.ibm.com>
 <12006159081875-git-send-email-fubar@us.ibm.com>
 <12006159102124-git-send-email-fubar@us.ibm.com>
 <12006159111680-git-send-email-fubar@us.ibm.com>
 <12006159123054-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:42535 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230AbYARAZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:25:16 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0PGnC025689
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:16 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0PFth153794
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:15 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0PEct022694
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:15 -0500
In-Reply-To: <12006159123054-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change bond_mii_monitor to not hold any locks when calling rtnl_unlock,
as rtnl_unlock can sleep (when acquring another mutex in netdev_run_todo).

Bug reported by Makito SHIOKAWA <mshiokawa@miraclelinux.com>, who
included a different patch.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2c6da49..49a1982 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2386,7 +2386,9 @@ void bond_mii_monitor(struct work_struct *work)
 		rtnl_lock();
 		read_lock(&bond->lock);
 		__bond_mii_monitor(bond, 1);
-		rtnl_unlock();
+		read_unlock(&bond->lock);
+		rtnl_unlock();	/* might sleep, hold no other locks */
+		read_lock(&bond->lock);
 	}
 
 	delay = ((bond->params.miimon * HZ) / 1000) ? : 1;
-- 
1.5.3.4.206.g58ba4-dirty

