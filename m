From: Milos Vyletel <milos.vyletel@sde.cz>
Subject: [PATCH] bonding: unset primary slave via sysfs
Date: Fri, 25 Jan 2013 13:41:49 -0500
Message-ID: <47084655-E363-4D67-94B3-B6A3471B4D4E@sde.cz>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sde.cz ([85.93.125.197]:37942 "EHLO sde.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755459Ab3AYSvQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 13:51:16 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by sde.cz (Postfix) with ESMTP id 821FC69F4081
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 19:41:53 +0100 (CET)
Received: from sde.cz ([127.0.0.1])
	by localhost (zimbra.sde [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oine501MID0S for <netdev@vger.kernel.org>;
	Fri, 25 Jan 2013 19:41:53 +0100 (CET)
Received: from [172.16.99.4] (cpe-075-177-134-192.nc.res.rr.com [75.177.134.192])
	by sde.cz (Postfix) with ESMTPSA id 960FF69F4081
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 19:41:52 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bonding module is loaded with primary parameter and one decides to unset primary slave using sysfs these settings are not preserved during bond device restart.  Primary slave is only unset once and it's not remembered in bond->params structure. Below is example of recreation. Fix is simple one-liner

# grep OPTS /etc/sysconfig/network-scripts/ifcfg-bond0
BONDING_OPTS="mode=active-backup miimon=100 primary=eth01"
# grep "Primary Slave" /proc/net/bonding/bond0 
Primary Slave: eth01 (primary_reselect always)

# echo "" > /sys/class/net/bond0/bonding/primary
# grep "Primary Slave" /proc/net/bonding/bond0 
Primary Slave: None

# sed -i -e 's/primary=eth01//' /etc/sysconfig/network-scripts/ifcfg-bond0
# grep OPTS /etc/sysconfig/network-scripts/ifcfg-bond 
BONDING_OPTS="mode=active-backup miimon=100 "
# ifdown bond0 && ifup bond0

without patch:
# grep "Primary Slave" /proc/net/bonding/bond0 
Primary Slave: eth01 (primary_reselect always)

with patch:
# grep "Primary Slave" /proc/net/bonding/bond0 
Primary Slave: None


---
 drivers/net/bonding/bond_sysfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1877ed7..50f7eef 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1053,6 +1053,7 @@ static ssize_t bonding_store_primary(struct device *d,
                pr_info("%s: Setting primary slave to None.\n",
                        bond->dev->name);
                bond->primary_slave = NULL;
+               memset(bond->params.primary, '\0', sizeof(bond->params.primary));
                bond_select_active_slave(bond);
                goto out;
        }
-- 
1.8.1
