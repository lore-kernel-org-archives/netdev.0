From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH 2/3] bonding: Call netif_carrier_off after register_netdevice
Date: Mon, 14 Mar 2011 09:22:05 -0700
Message-ID: <1300119726-17529-3-git-send-email-kernel@linuxace.com>
References: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net,
	Phil Oester <kernel@linuxace.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:55784 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab1CNQWg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 12:22:36 -0400
Received: by qyg14 with SMTP id 14so4498008qyg.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 09:22:35 -0700 (PDT)
In-Reply-To: <1300119726-17529-1-git-send-email-kernel@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bringing up a bond interface with all network cables disconnected
does not properly set the interface as DOWN because the call to
netif_carrier_off occurs too early in bond_init.  The call needs
to occur after register_netdevice has set dev->reg_state to
NETREG_REGISTERED, so that netif_carrier_off will trigger the
call to linkwatch_fire_event.

Signed-off-by: Phil Oester <kernel@linuxace.com>
---
 drivers/net/bonding/bond_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a93d941..66c98e6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4980,8 +4980,6 @@ static int bond_init(struct net_device *bond_dev)
 
 	bond_set_lockdep_class(bond_dev);
 
-	netif_carrier_off(bond_dev);
-
 	bond_create_proc_entry(bond);
 	list_add_tail(&bond->bond_list, &bn->dev_list);
 
@@ -5051,6 +5049,8 @@ int bond_create(struct net *net, const char *name)
 
 	res = register_netdevice(bond_dev);
 
+	netif_carrier_off(bond_dev);
+
 out:
 	rtnl_unlock();
 	if (res < 0)
-- 
1.7.4

