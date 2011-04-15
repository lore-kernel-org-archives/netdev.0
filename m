From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC net-next] bonding: notify when bonding device address changes
Date: Fri, 15 Apr 2011 12:28:24 -0700
Message-ID: <11728.1302895704@death>
References: <20110415184407.550abd88@pomiocik.lan> <4DA89114.9040900@gmail.com> <10227.1302893590@death> <20110415121054.73717900@nehalam>
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>,
	=?UTF-8?B?TWljaGHFgiBHw7Nybnk=?= <mgorny@gentoo.org>,
	netdev@vger.kernel.org, roy@marples.name,
	Andy Gospodarek <andy@greyhouse.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:34420 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752924Ab1DOT23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 15:28:29 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3FJ8MwI009288
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:08:22 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3FJSRZ5339364
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 15:28:27 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3FJSQFc031849
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 16:28:27 -0300
In-reply-to: <20110415121054.73717900@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>When a device changes its hardware address, it needs to call the network
>device notifiers to inform protocols.
>
>Compile tested only.

	We'll need to test this, I think.  If I'm not mistaken, I
believe that inetdev_event will issue gratuitous ARPs when it gets the
NETDEV_CHANGEADDR, and we need to make sure those are correct for all
cases.

>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
>--- a/drivers/net/bonding/bond_main.c	2011-04-15 11:21:02.142866195 -0700
>+++ b/drivers/net/bonding/bond_main.c	2011-04-15 11:28:06.491408825 -0700
>@@ -967,9 +967,11 @@ static void bond_do_fail_over_mac(struct
>
> 	switch (bond->params.fail_over_mac) {
> 	case BOND_FOM_ACTIVE:
>-		if (new_active)
>+		if (new_active) {
> 			memcpy(bond->dev->dev_addr,  new_active->dev->dev_addr,
> 			       new_active->dev->addr_len);
>+			call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>+		}
> 		break;
> 	case BOND_FOM_FOLLOW:
> 		/*
>@@ -1386,6 +1388,7 @@ static int bond_sethwaddr(struct net_dev
> 	pr_debug("slave_dev=%p\n", slave_dev);
> 	pr_debug("slave_dev->addr_len=%d\n", slave_dev->addr_len);
> 	memcpy(bond_dev->dev_addr, slave_dev->dev_addr, slave_dev->addr_len);
>+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);
> 	return 0;
> }
>
>@@ -1644,10 +1647,11 @@ int bond_enslave(struct net_device *bond
>
> 	/* If this is the first slave, then we need to set the master's hardware
> 	 * address to be the same as the slave's. */
>-	if (is_zero_ether_addr(bond->dev->dev_addr))
>+	if (is_zero_ether_addr(bond->dev->dev_addr)) {
> 		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
> 		       slave_dev->addr_len);
>-
>+		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond->dev);
>+	}
>
> 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
> 	if (!new_slave) {
>@@ -2067,6 +2071,7 @@ int bond_release(struct net_device *bond
> 		 * to the mac address of the first slave
> 		 */
> 		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>+		call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);

	This one in particular I'm not sure about; should the system
send a gratuitous ARP for a MAC address of all zeroes?

> 		if (!bond->vlgrp) {
> 			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
>@@ -2252,6 +2257,7 @@ static int bond_release_all(struct net_d
> 	 * first slave
> 	 */
> 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
>+	call_netdevice_notifiers(NETDEV_CHANGEADDR, bond_dev);

	Same comment for this one.

> 	if (!bond->vlgrp) {
> 		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
