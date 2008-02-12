From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 9937] New: Bug in bonding driver - Kernel oops whenever driver is loaded with max_bonds parameter
Date: Mon, 11 Feb 2008 17:21:19 -0800
Message-ID: <23745.1202779279@death>
References: <bug-9937-10286@http.bugzilla.kernel.org/> <20080211155608.b60858d7.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	kantica@gmail.com, stable@kernel.vger.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:48507 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754697AbYBLBV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 20:21:27 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1C1LRuo026338
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 20:21:27 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1C1LQ5e215344
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 18:21:26 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1C1LPQZ029324
	for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 18:21:26 -0700
In-reply-to: <20080211155608.b60858d7.akpm@linux-foundation.org> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:

>> Problem Description: Kernel oops whenever bonding driver with max_bonds=2 (or >
>> 2) is loaded ...

	I believe this is fixed by the following (from linux-2.6):

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 29 Jan 2008 18:07:45 -0800
Subject: [PATCH] bonding: fix NULL pointer deref in startup processing

	Fix the "are we creating a duplicate" check to not compare
the name if the name is NULL (meaning that the system should select
a name).  Bug reported by Benny Amorsen <benny+usenet@amorsen.dk>.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Jeff Garzik <jeff@garzik.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bonding/bond_main.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 65c7eba..81b4574 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4896,14 +4896,16 @@ int bond_create(char *name, struct bond_params *params, struct bonding **newbond
 	down_write(&bonding_rwsem);
 
 	/* Check to see if the bond already exists. */
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
-		if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
-			printk(KERN_ERR DRV_NAME
+	if (name) {
+		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
+				printk(KERN_ERR DRV_NAME
 			       ": cannot add bond %s; it already exists\n",
-			       name);
-			res = -EPERM;
-			goto out_rtnl;
-		}
+				       name);
+				res = -EPERM;
+				goto out_rtnl;
+			}
+	}
 
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				ether_setup);
-- 
1.5.2.4

