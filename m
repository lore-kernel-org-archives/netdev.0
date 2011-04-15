From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC net-next] bonding: notify when bonding device address changes
Date: Fri, 15 Apr 2011 12:10:54 -0700
Message-ID: <20110415121054.73717900@nehalam>
References: <20110415184407.550abd88@pomiocik.lan>
	<4DA89114.9040900@gmail.com>
	<10227.1302893590@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	=?UTF-8?B?TWljaGHFgiBHw7Nybnk=?= <mgorny@gentoo.org>,
	netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57148 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756621Ab1DOTK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 15:10:58 -0400
In-Reply-To: <10227.1302893590@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a device changes its hardware address, it needs to call the network
device notifiers to inform protocols.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2011-04-15 11:21:02.142866195 -0700
+++ b/drivers/net/bonding/bond_main.c	2011-04-15 11:28:06.491408825 -0700
@@ -967,9 +967,11 @@ static void bond_do_fail_over_mac(struct
 
 	switch (bond->params.fail_over_mac) {
 	case BOND_FOM_ACTIVE:
-		if (new_active)
+		if (new_active) {
 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
 			       new_active->dev->addr_len);
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
+		}
 		break;
 	case BOND_FOM_FOLLOW:
 		/*
@@ -1386,6 +1388,7 @@ static int bond_sethwaddr(struct net_dev
 	pr_debug("slave_dev=%p\n", slave_dev);
 	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
 	return 0;
 }
 
@@ -1644,10 +1647,11 @@ int bond_enslave(struct net_device *bond
 
 	/* If this is the first slave, then we need to set the master's hardware
 	 * address to be the same as the slave's. */
-	if (is_zero_ether_addr(bond->dev->dev_addr))
+	if (is_zero_ether_addr(bond->dev->dev_addr)) {
 		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
 		       slave_dev->addr_len);
-
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
+	}
 
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
@@ -2067,6 +2071,7 @@ int bond_release(struct net_device *bond
 		 * to the mac address of the first slave
 		 */
 		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
 
 		if (!bond->vlgrp) {
 			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
@@ -2252,6 +2257,7 @@ static int bond_release_all(struct net_d
 	 * first slave
 	 */
 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
 
 	if (!bond->vlgrp) {
 		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
