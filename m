From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next] gianfar: dont conditionally alloc Rx/Err irq structs
Date: Mon,  4 Feb 2013 14:49:42 -0500
Message-ID: <1360007382-7876-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35475 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755063Ab3BDTuB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 14:50:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ee873fda3bec7c668407b837fc5519eb961fcd37

    "gianfar: Pack struct gfar_priv_grp into three cachelines"

causes the following null dereference at driver init on sbc8548:

   libphy: Freescale PowerQUICC MII Bus: probed
   Unable to handle kernel paging request for data at address 0x00000000
   Faulting instruction address: 0xc01d6a38
   Oops: Kernel access of bad area, sig: 11 [#1]
   [...]
   NIP [c01d6a38] gfar_parse_group+0x228/0x280
   LR [c01d6a34] gfar_parse_group+0x224/0x280
   Call Trace:
   [ef82dd60] [c01d6a34] gfar_parse_group+0x224/0x280 (unreliable)
   [ef82dd90] [c01d73a4] gfar_probe+0x284/0xfe0

The reason is that the commit also changed the allocation of the
Rx and error handling irq structs to be skipped for !MQ_MG_MODE.
In the !MQ_MG_MODE case, only the Tx irq struct is allocated.

Digging further, we see that MQ_MG_MODE is set only if we find
the OF compatible string "fsl,etsec2".

A quick grep in the dts directory shows lots of boards that support
Rx/Tx/Err, but without this specific compat string.  And hence they
go after the unallocated Rx/Error structs and cause the above oops.

Hence such a change can not be deployed until all the dts files
are updated and sufficiently deployed.  Further, the optimization
is of limited value, since the kmalloc'd struct in question has only
a single unsigned int, and an (IFNAMSIZ + 6) sized string.

Note that no changes to the freeing code are needed here, as it
already did an unconditional free of Rx/Tx/Error gfar_irqinfo.

Cc: Claudiu Manoil <claudiu.manoil@freescale.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 19c54a0..75734bf 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -580,19 +580,11 @@ static int gfar_parse_group(struct device_node *np,
 	u32 *queue_mask;
 	int i;
 
-	if (priv->mode == MQ_MG_MODE) {
-		for (i = 0; i < GFAR_NUM_IRQS; i++) {
-			grp->irqinfo[i] = kzalloc(sizeof(struct gfar_irqinfo),
-						  GFP_KERNEL);
-			if (!grp->irqinfo[i])
-				return -ENOMEM;
-		}
-	} else {
-		grp->irqinfo[GFAR_TX] = kzalloc(sizeof(struct gfar_irqinfo),
-						GFP_KERNEL);
-		if (!grp->irqinfo[GFAR_TX])
+	for (i = 0; i < GFAR_NUM_IRQS; i++) {
+		grp->irqinfo[i] = kzalloc(sizeof(struct gfar_irqinfo),
+					  GFP_KERNEL);
+		if (!grp->irqinfo[i])
 			return -ENOMEM;
-		grp->irqinfo[GFAR_RX] = grp->irqinfo[GFAR_ER] = NULL;
 	}
 
 	grp->regs = of_iomap(np, 0);
-- 
1.8.1.2
