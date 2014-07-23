From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [PATCH v2 0/2] net: phy: Prevent an MDIO bus from being unloaded while in use
Date: Wed, 23 Jul 2014 16:47:30 -0300
Message-ID: <1406144852-7379-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:43315 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932665AbaGWTsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 15:48:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes from v1:
  * Dropped the unneeded module_put() on phy_attach_direct().

The motivation of this small series is to fix the current lack of relationship
between an ethernet driver and the MDIO bus behind the PHY device. In such
cases, we would find no visible link between the drivers:

  $ lsmod
  Module                  Size  Used by    Not tainted
  mvmdio                  2941  0 
  mvneta                 22069  0 

Which means nothing prevents the MDIO driver from being removed:

  $ modprobe -r mvmdio

  # Unable to handle kernel NULL pointer dereference at virtual address 00000060
  pgd = c0004000
  [00000060] *pgd=00000000
  Internal error: Oops: 17 [#1] SMP ARM
  Modules linked in: mvneta [last unloaded: mvmdio]
  CPU: 0 PID: 22 Comm: kworker/0:1 Not tainted 3.16.0-rc5-01127-g62c0816-dirty #608
  Workqueue: events_power_efficient phy_state_machine
  task: df5ec840 ti: df67a000 task.ti: df67a000
  PC is at phy_state_machine+0x1c/0x468
  LR is at phy_state_machine+0x18/0x468
  [snip]

This patchset fixes this problem by adding a pair of module_{get,put},
so the module reference count is increased when the PHY device is attached
and is decreased when the PHY is detached.

Tested with mvneta and mv643xx_eth drivers, which depend on the mvmdio
driver to handle MDIO. This series applies on both net and net-next branches.

Ezequiel Garcia (2):
  net: phy: Set the driver when registering an MDIO bus device
  net: phy: Ensure the MDIO bus module is held

 drivers/net/phy/mdio_bus.c   |  1 +
 drivers/net/phy/phy_device.c | 13 +++++++++++++
 2 files changed, 14 insertions(+)

-- 
2.0.1
