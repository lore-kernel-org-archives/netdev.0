From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Wed, 24 Jun 2009 11:57:31 +0900
Message-ID: <4A41961B.2090206@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:26070 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbZFXC5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jun 2009 22:57:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael

I found a little bug.

When configure in ifcfg-eth* is ONBOOT=no,
the behavior of ethtool command is wrong.

    # grep ONBOOT /etc/sysconfig/network-scripts/ifcfg-eth2
    ONBOOT=no
    # ethtool eth2 | tail -n1
            Link detected: yes

I think "Link detected" should be "no".

The bnx2 driver should run netif_carrier_off() in initialization
until bnx2_open() is called.

The following is my patch.
It move netif_carrier_off() to bnx2_init_one().
I had already tested this patch. The result is good for me.

Could you please check the my patch ?


Best Regards,
Naohiro Ooiwa


Signed-off-by: Naohiro Ooiwa <nooiwa@meriraclelinux.com>
---
 drivers/net/bnx2.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 38f1c33..9eee986 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6151,8 +6151,6 @@ bnx2_open(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;

-	netif_carrier_off(dev);
-
 	bnx2_set_power_state(bp, PCI_D0);
 	bnx2_disable_int(bp);

@@ -8066,6 +8064,9 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (CHIP_NUM(bp) == CHIP_NUM_5709)
 		dev->features |= NETIF_F_TSO6;

+	/* Should set nocarrier until bnx2_open() is called */
+	netif_carrier_off(dev);
+
 	if ((rc = register_netdev(dev))) {
 		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto error;
-- 
1.5.4.1

