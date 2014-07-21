From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: [RFC 0/2] net: phy: Prevent an MDIO bus from being unloaded while in use
Date: Mon, 21 Jul 2014 15:26:08 -0300
Message-ID: <1405967170-19353-1-git-send-email-ezequiel.garcia@free-electrons.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:55866 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933219AbaGUS1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 14:27:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This small patchset is a first proposal to fix the current lack of relationship
between an ethernet driver and the MDIO bus behind the PHY device.

In such cases, we would find no visible link between the drivers:

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

This patchset fixes this by calling module_{get,put} in the ethernet driver.
After this patch, the mvmdio driver is no longer removable:

  $ modprobe -r mvmdio
  modprobe: can't unload module mvmdio: Resource temporarily unavailable

Of course, we can expect a few drivers to have the same need and therefore
we could argue about moving this to be part of the phydev connection.

Ezequiel Garcia (2):
  net: phy: Set the driver when registering an MDIO bus device
  net: mvneta: Ensure the MDIO bus module is held

 drivers/net/ethernet/marvell/mvneta.c | 12 ++++++++++++
 drivers/net/phy/mdio_bus.c            |  1 +
 2 files changed, 13 insertions(+)

-- 
2.0.1
