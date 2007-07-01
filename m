From: "=?ISO-8859-1?Q?T=F6r=F6k_Edvin?=" <edwintorok@gmail.com>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sun, 1 Jul 2007 15:49:23 +0300
Message-ID: <4354d3270707010549x940a593v1cac2a7478fdd46f@mail.gmail.com>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com>
	 <20070630081302.66b1d984@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, power@bughost.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:28733 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837AbXGAMtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2007 08:49:23 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1920709wah
        for <netdev@vger.kernel.org>; Sun, 01 Jul 2007 05:49:23 -0700 (PDT)
In-Reply-To: <20070630081302.66b1d984@oldman>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 6/30/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
>
> This is a non-standard formatting for comments, please follow
> Coding style:

Thanks, I have updated the patch.

When the interface is down (or driver removed), the BroadCom 44xx card
remains powered on,
and both its MAC and PHY is using up power.
This patch makes the driver issue a MAC_CTRL_PHY_PDOWN when the
interface is halted.
Also doing a partial chip reset turns off the activity LEDs too.

Signed-off-by: Torok Edwin <edwintorok@gmail.com>
---
 b44.c |   28 +++++++++++++++++++++++-----
  1 file changed, 23 insertions(+), 5 deletions(-)
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 879a2ff..43926fd 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -113,6 +113,8 @@ static void b44_init_rings(struct b44 *);
 #define B44_FULL_RESET		1
 #define B44_FULL_RESET_SKIP_PHY	2
 #define B44_PARTIAL_RESET	3
+#define B44_CHIP_RESET_FULL     4
+#define B44_CHIP_RESET_PARTIAL  5

 static void b44_init_hw(struct b44 *, int);

@@ -1283,7 +1285,7 @@ static void b44_clear_stats(struct b44 *bp)
 }

 /* bp->lock is held. */
-static void b44_chip_reset(struct b44 *bp)
+static void b44_chip_reset(struct b44 *bp, int reset_kind)
 {
 	if (ssb_is_core_up(bp)) {
 		bw32(bp, B44_RCV_LAZY, 0);
@@ -1307,6 +1309,13 @@ static void b44_chip_reset(struct b44 *bp)

 	b44_clear_stats(bp);

+	/*
+	 * Don't enable PHY if we are doing a partial reset
+	 * we are probably going to power down
+	 */
+	if (reset_kind == B44_CHIP_RESET_PARTIAL)
+		return;
+
 	/* Make PHY accessible. */
 	bw32(bp, B44_MDIO_CTRL, (MDIO_CTRL_PREAMBLE |
 			     (0x0d & MDIO_CTRL_MAXF_MASK)));
@@ -1332,7 +1341,14 @@ static void b44_chip_reset(struct b44 *bp)
 static void b44_halt(struct b44 *bp)
 {
 	b44_disable_ints(bp);
-	b44_chip_reset(bp);
+	/* reset PHY */
+	b44_phy_reset(bp);
+	/* power down PHY */
+	printk(KERN_INFO PFX "%s: powering down PHY\n", bp->dev->name);
+	bw32(bp, B44_MAC_CTRL, MAC_CTRL_PHY_PDOWN);
+	/* now reset the chip, but without enabling the MAC&PHY
+	 * part of it. This has to be done _after_ we shut down the PHY */
+	b44_chip_reset(bp, B44_CHIP_RESET_PARTIAL);
 }

 /* bp->lock is held. */
@@ -1376,7 +1392,7 @@ static void b44_init_hw(struct b44 *bp, int reset_kind)
 {
 	u32 val;

-	b44_chip_reset(bp);
+	b44_chip_reset(bp, B44_CHIP_RESET_FULL);
 	if (reset_kind == B44_FULL_RESET) {
 		b44_phy_reset(bp);
 		b44_setup_phy(bp);
@@ -1430,7 +1446,7 @@ static int b44_open(struct net_device *dev)

 	err = request_irq(dev->irq, b44_interrupt, IRQF_SHARED, dev->name, dev);
 	if (unlikely(err < 0)) {
-		b44_chip_reset(bp);
+		b44_chip_reset(bp, B44_CHIP_RESET_PARTIAL);
 		b44_free_rings(bp);
 		b44_free_consistent(bp);
 		goto out;
@@ -2250,7 +2266,7 @@ static int __devinit b44_init_one(struct pci_dev *pdev,
 	/* Chip reset provides power to the b44 MAC & PCI cores, which
 	 * is necessary for MAC register access.
 	 */
-	b44_chip_reset(bp);
+	b44_chip_reset(bp, B44_CHIP_RESET_FULL);

 	printk(KERN_INFO "%s: Broadcom 4400 10/100BaseT Ethernet ", dev->name);
 	for (i = 0; i < 6; i++)
@@ -2284,6 +2300,7 @@ static void __devexit b44_remove_one(struct pci_dev *pdev)
 	free_netdev(dev);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
 	pci_set_drvdata(pdev, NULL);
 }

@@ -2312,6 +2329,7 @@ static int b44_suspend(struct pci_dev *pdev,
pm_message_t state)
 		b44_setup_wol(bp);
 	}
 	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
 	return 0;
 }
