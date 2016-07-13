From: Beniamino Galvani <bgalvani@redhat.com>
Subject: [PATCH] bonding: set carrier off for devices created through netlink
Date: Wed, 13 Jul 2016 18:25:08 +0200
Message-ID: <1468427108-32516-1-git-send-email-bgalvani@redhat.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Phil Oester <kernel@linuxace.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532AbcGMQ0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 12:26:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e826eafa65c6 ("bonding: Call netif_carrier_off after
register_netdevice") moved netif_carrier_off() from bond_init() to
bond_create(), but the latter is called only for initial default
devices and ones created through sysfs:

 $ modprobe bonding
 $ echo +bond1 > /sys/class/net/bonding_masters
 $ ip link add bond2 type bond
 $ grep "MII Status" /proc/net/bonding/*
 /proc/net/bonding/bond0:MII Status: down
 /proc/net/bonding/bond1:MII Status: down
 /proc/net/bonding/bond2:MII Status: up

Ensure that carrier is initially off also for devices created through
netlink.

Signed-off-by: Beniamino Galvani <bgalvani@redhat.com>
---
 drivers/net/bonding/bond_netlink.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index db760e8..b8df0f5 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -446,7 +446,11 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
 	if (err < 0)
 		return err;
 
-	return register_netdevice(bond_dev);
+	err = register_netdevice(bond_dev);
+
+	netif_carrier_off(bond_dev);
+
+	return err;
 }
 
 static size_t bond_get_size(const struct net_device *bond_dev)
-- 
2.5.5
