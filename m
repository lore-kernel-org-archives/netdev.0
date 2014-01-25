From: Stanislaw Gruszka <stf_xl@wp.pl>
Subject: [PATCH] sky2: initialize napi before registering device
Date: Sat, 25 Jan 2014 11:34:54 +0100
Message-ID: <20140125103454.GA2490@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.7]:59621 "EHLO mx3.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551AbaAYVjd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jan 2014 16:39:33 -0500
Received: from ip-94-112-189-223.net.upcbroadband.cz (HELO localhost) (stf_xl@wp.pl@[94.112.189.223])
          (envelope-sender <stf_xl@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with AES128-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 25 Jan 2014 11:32:49 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is race condition when call netif_napi_add() after
register_netdevice(), as ->open() can be called without napi initialized
and trigger BUG_ON() on napi_enable(), like on below messages:

[    9.699863] sky2: driver version 1.30
[    9.699960] sky2 0000:02:00.0: Yukon-2 EC Ultra chip revision 2
[    9.700020] sky2 0000:02:00.0: irq 45 for MSI/MSI-X
[    9.700498] ------------[ cut here ]------------
[    9.703391] kernel BUG at include/linux/netdevice.h:501!
[    9.703391] invalid opcode: 0000 [#1] PREEMPT SMP
<snip>
[    9.830018] Call Trace:
[    9.830018]  [<fa996169>] sky2_open+0x309/0x360 [sky2]
[    9.830018]  [<c1007210>] ? via_no_dac+0x40/0x40
[    9.830018]  [<c1007210>] ? via_no_dac+0x40/0x40
[    9.830018]  [<c135ed4b>] __dev_open+0x9b/0x120
[    9.830018]  [<c1431cbe>] ? _raw_spin_unlock_bh+0x1e/0x20
[    9.830018]  [<c135efd9>] __dev_change_flags+0x89/0x150
[    9.830018]  [<c135f148>] dev_change_flags+0x18/0x50
[    9.830018]  [<c13bb8e0>] devinet_ioctl+0x5d0/0x6e0
[    9.830018]  [<c13bcced>] inet_ioctl+0x6d/0xa0

To fix the problem patch changes the order of initialization.

Bug report:
https://bugzilla.kernel.org/show_bug.cgi?id=67151

Reported-and-tested-by: ebrahim.azarisooreh@gmail.com
Signed-off-by: Stanislaw Gruszka <stf_xl@wp.pl>
---
 drivers/net/ethernet/marvell/sky2.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 43aa7acd..2564eda 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -5020,6 +5020,8 @@ static int sky2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
  	}
 
+	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "cannot register net device\n");
@@ -5028,8 +5030,6 @@ static int sky2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netif_carrier_off(dev);
 
-	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
-
 	sky2_show_addr(dev);
 
 	if (hw->ports > 1) {
-- 
1.7.4.4
