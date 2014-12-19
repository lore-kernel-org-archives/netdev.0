From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH] bonding: avoid re-entry of bond_release
Date: Fri, 19 Dec 2014 16:56:57 +0800
Message-ID: <1418979417-28867-1-git-send-email-wen.gang.wang@oracle.com>
Cc: wen.gang.wang@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39541 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbaLSIza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 03:55:30 -0500
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id sBJ8tTtR024802
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 08:55:29 GMT
Received: from userz7022.oracle.com (userz7022.oracle.com [156.151.31.86])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id sBJ8tSlj016437
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 08:55:28 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userz7022.oracle.com (8.14.5+Sun/8.14.4) with ESMTP id sBJ8tRfJ002512
	for <netdev@vger.kernel.org>; Fri, 19 Dec 2014 08:55:28 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bond_release is run against an interface which is already detached from
it's master, then there is an error message shown like
	"<master name> cannot release <slave name>".

The call path is:
	bond_do_ioctl()
		bond_release()
			__bond_release_one()

Though it does not really harm, the message the message is misleading.
This patch tries to avoid the message.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
---
 drivers/net/bonding/bond_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 184c434..4a71bbd 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3256,7 +3256,10 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		break;
 	case BOND_RELEASE_OLD:
 	case SIOCBONDRELEASE:
-		res = bond_release(bond_dev, slave_dev);
+		if (slave_dev->flags & IFF_SLAVE)
+			res = bond_release(bond_dev, slave_dev);
+		else
+			res = 0;
 		break;
 	case BOND_SETHWADDR_OLD:
 	case SIOCBONDSETHWADDR:
-- 
1.8.3.1
