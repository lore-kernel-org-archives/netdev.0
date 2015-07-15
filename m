From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net] bonding: correctly handle bonding type change on enslave failure
Date: Wed, 15 Jul 2015 22:57:01 +0200
Message-ID: <1436993821-4114-1-git-send-email-razor@blackwall.org>
Cc: monis@voltaire.com, j.vosburgh@gmail.com,
	gospo@cumulusnetworks.com, vfalico@gmail.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35431 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbbGOU5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 16:57:08 -0400
Received: by wgjx7 with SMTP id x7so42869619wgj.2
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 13:57:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

If the bond is enslaving a device with different type it will be setup
by it, but if after being setup the enslave fails the bond doesn't
switch back its type and also keeps pointers to foreign structures that can
be long gone. Thus revert back any type changes if the enslave failed and
the bond had to change its type.
Example:
 Before patch:
$ echo lo > bond0/bonding/slaves
-bash: echo: write error: Cannot assign requested address
$ ip l sh bond0
20: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
mode DEFAULT group default
    link/loopback 16:54:78:34:bd:41 brd 00:00:00:00:00:00
$ echo +eth1 > bond0/bonding/slaves
$ ip l sh bond0
20: bond0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN mode
DEFAULT group default qlen 1000
    link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff
(notice the MASTER flag is gone)

 After patch:
$ echo lo > bond0/bonding/slaves
-bash: echo: write error: Cannot assign requested address
$ ip l sh bond0
21: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
mode DEFAULT group default qlen 1000
    link/ether 6e:66:94:f6:07:fc brd ff:ff:ff:ff:ff:ff
$ echo +eth1 > bond0/bonding/slaves
$ ip l sh bond0
21: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
mode DEFAULT group default qlen 1000
    link/ether 52:54:00:3f:47:69 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Fixes: e36b9d16c6a6 ("bonding: clean muticast addresses when device changes type")
---
 drivers/net/bonding/bond_main.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ec1404ec4d2f..1d26d6700c1d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1725,9 +1725,16 @@ err_free:
 
 err_undo_flags:
 	/* Enslave of first slave has failed and we need to fix master's mac */
-	if (!bond_has_slaves(bond) &&
-	    ether_addr_equal_64bits(bond_dev->dev_addr, slave_dev->dev_addr))
-		eth_hw_addr_random(bond_dev);
+	if (!bond_has_slaves(bond)) {
+		if (ether_addr_equal_64bits(bond_dev->dev_addr,
+					    slave_dev->dev_addr))
+			eth_hw_addr_random(bond_dev);
+		if (bond_dev->type != ARPHRD_ETHER) {
+			ether_setup(bond_dev);
+			bond_dev->flags |= IFF_MASTER;
+			bond_dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+		}
+	}
 
 	return res;
 }
-- 
1.9.3
