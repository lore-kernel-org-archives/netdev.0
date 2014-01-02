From: jiang.biao2@zte.com.cn
Subject: [Patch] netxen_nic: Bugfix for wrong RUNNING status of NX3031 NICs with no
 link
Date: Thu, 2 Jan 2014 11:37:44 +0800
Message-ID: <OFAE440C7C.FE33E30C-ON48257C54.0013C383-48257C54.0013F43B@zte.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org, li.fengmao@zte.com.cn
To: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1.zte.com.cn ([202.103.147.172]:53240 "EHLO zte.com.cn"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750708AbaABDxS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jan 2014 22:53:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Li Fengmao <li.fengmao@zte.com.cn>

Ifconfig command displays RUNNING status when there is no link on
NX3031 NICs. The problem is caused by the wrong calling order of
netif_carrier_off() and register_netdev() in netxen_setup_netdev(),
dev->reg_state is initialized to NETREG_UNINITIALIZED before
registering network device, so the linkwatch_fire_event() will not
be called to notify the link change event in netif_carrier_off(),
and the operational status of network device will be set to
IF_OPER_UNKNOWN. In that case, the IFF_RUNNING flags will be set,
which result in the wrong RUNNING status in the result of ifconfig
command.

It can be solved by calling netif_carrier_off() after
register_netdev() in netxen_setup_netdev() to ensure the
notification of the link change event. And then the operational
status of device will be set to IF_OPER_DOWN correctly.

Steps to reproduce the bug:
1. Prepare a NX3031 NIC with no network cable on it.
2. Reboot the system. (e.g exec reboot command)
3. Activate the interface. (e.g ifconfig eth0 up)
4. The operstatus of the NX3031 NIC will be RUNNING in the result of
ifconfig command.

Signed-off-by: Li Fengmao <li.fengmao@zte.com.cn>
Reviewed-by: Long Chun <long.chun@zte.com.cn>
Reviewed-by: Wang Liang <wang.liang82@zte.com.cn>
Reviewed-by: Cai Qu <cai.qu@zte.com.cn>
Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>

--- drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c	2013-09-26 09:51:39.115903504 +0800
+++ drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c	2013-09-26 09:53:13.868903522 +0800
@@ -1404,13 +1404,13 @@ netxen_setup_netdev(struct netxen_adapte
 	if (netxen_read_mac_addr(adapter))
 		dev_warn(&pdev->dev, "failed to read mac addr\n");

-	netif_carrier_off(netdev);
-
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pdev->dev, "failed to register net device\n");
 		return err;
 	}
+
+	netif_carrier_off(netdev);

 	return 0;
 }
