From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: fix enslaving in alb mode when link down
Date: Wed, 18 Jan 2012 17:45:21 -0800
Message-ID: <23580.1326937521@death>
References: <20120118222454.GA11966@midget.suse.cz>
Cc: netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:34853 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab2ASBp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 20:45:28 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 18 Jan 2012 18:45:28 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 23C891FF0047
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 18:45:24 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0J1jPEF149658
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 18:45:25 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0J1jOdu005728
	for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 18:45:24 -0700
In-reply-to: <20120118222454.GA11966@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>bond_alb_init_slave() is called from bond_enslave() and sets the slave's MAC
>address. This is done differently for TLB and ALB modes.
>bond->alb_info.rlb_enabled is used to discriminate between the two modes but
>this flag may be uninitialized if the slave is being enslaved prior to calling
>bond_open() -> bond_alb_initialize() on the master.
>
>It turns out all the callers of alb_set_slave_mac_addr() pass
>bond->alb_info.rlb_enabled as the hw parameter.
>
>This patch cleans up the unnecessary parameter of alb_set_slave_mac_addr() and
>makes the function decide based on the bonding mode instead, which fixes the
>above problem.
>
>Signed-off-by: Jiri Bohac <jbohac@suse.cz>

	Looks reasonable.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index 342626f..f820b26 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -909,16 +909,12 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
> 	}
> }
>
>-/* hw is a boolean parameter that determines whether we should try and
>- * set the hw address of the device as well as the hw address of the
>- * net_device
>- */
>-static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[], int hw)
>+static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
> {
> 	struct net_device *dev = slave->dev;
> 	struct sockaddr s_addr;
>
>-	if (!hw) {
>+	if (slave->bond->params.mode == BOND_MODE_TLB) {
> 		memcpy(dev->dev_addr, addr, dev->addr_len);
> 		return 0;
> 	}
>@@ -948,8 +944,8 @@ static void alb_swap_mac_addr(struct bonding *bond, struct slave *slave1, struct
> 	u8 tmp_mac_addr[ETH_ALEN];
>
> 	memcpy(tmp_mac_addr, slave1->dev->dev_addr, ETH_ALEN);
>-	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr, bond->alb_info.rlb_enabled);
>-	alb_set_slave_mac_addr(slave2, tmp_mac_addr, bond->alb_info.rlb_enabled);
>+	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr);
>+	alb_set_slave_mac_addr(slave2, tmp_mac_addr);
>
> }
>
>@@ -1096,8 +1092,7 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
>
> 		/* Try setting slave mac to bond address and fall-through
> 		   to code handling that situation below... */
>-		alb_set_slave_mac_addr(slave, bond->dev->dev_addr,
>-				       bond->alb_info.rlb_enabled);
>+		alb_set_slave_mac_addr(slave, bond->dev->dev_addr);
> 	}
>
> 	/* The slave's address is equal to the address of the bond.
>@@ -1133,8 +1128,7 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
> 	}
>
> 	if (free_mac_slave) {
>-		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr,
>-				       bond->alb_info.rlb_enabled);
>+		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr);
>
> 		pr_warning("%s: Warning: the hw address of slave %s is in use by the bond; giving it the hw address of %s\n",
> 			   bond->dev->name, slave->dev->name,
>@@ -1491,8 +1485,7 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
> {
> 	int res;
>
>-	res = alb_set_slave_mac_addr(slave, slave->perm_hwaddr,
>-				     bond->alb_info.rlb_enabled);
>+	res = alb_set_slave_mac_addr(slave, slave->perm_hwaddr);
> 	if (res) {
> 		return res;
> 	}
>@@ -1643,8 +1636,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
> 		alb_swap_mac_addr(bond, swap_slave, new_slave);
> 	} else {
> 		/* set the new_slave to the bond mac address */
>-		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr,
>-				       bond->alb_info.rlb_enabled);
>+		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr);
> 	}
>
> 	if (swap_slave) {
>@@ -1704,8 +1696,7 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
> 		alb_swap_mac_addr(bond, swap_slave, bond->curr_active_slave);
> 		alb_fasten_mac_swap(bond, swap_slave, bond->curr_active_slave);
> 	} else {
>-		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr,
>-				       bond->alb_info.rlb_enabled);
>+		alb_set_slave_mac_addr(bond->curr_active_slave, bond_dev->dev_addr);
>
> 		read_lock(&bond->lock);
> 		alb_send_learning_packets(bond->curr_active_slave, bond_dev->dev_addr);
>-- 
>Jiri Bohac <jbohac@suse.cz>
>SUSE Labs, SUSE CZ
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
