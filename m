From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [Problem] broadcom tg3 network driver disconnects under high
 load
Date: Tue, 28 Apr 2015 12:01:52 -0700
Message-ID: <1430247712.26841.18.camel@prashant>
References: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
	 <1429908991.3920.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAGNmLEMB-hpG_TW3qQGbiHM2Vfd30P=D5H3_ioeY56+iKt14hA@mail.gmail.com>
	 <1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zJhIXkR4BnhdGNnH7IiG"
Cc: Toan Pham <tpham3783@gmail.com>, <sanjeevb@broadcom.com>,
	<netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:44331 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030934AbbD1TLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 15:11:36 -0400
In-Reply-To: <1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-zJhIXkR4BnhdGNnH7IiG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2015-04-28 at 11:11 -0700, Michael Chan wrote:
> On Mon, 2015-04-27 at 22:10 +0000, Toan Pham wrote: 
> > Michael,
> > 
> > 
> > Please see attach files.
> > 
> > BTW, I have also tested this bug on at least 8 different HP 705 PCs
> > with the 5762 NIC, so it is probably not a manufacturer defect.  In
> > addition, I can never replicate the same issue on the older chipset,
> > BCM5761, which can be found on the HP model 6005.  I hope this
> > information is helpful.  Thanks
> 
> Thanks for the data.  The memory enable bit is cleared and there are
> some correctable error bits set.  My colleague Sanjeev will look into
> this.
> 
> Do you have PCIE Advanced Error Reporting (CONFIG_PCIEAER) enabled in
> your kernel?
> 

5762 NIC has a bug due to which the chip would detect false 4G boundary
crossing and it would stall the chip. With the data you have provided it
is not clear whether we are hitting this problem or not. Register 0x4c04
bit 5 would be set when this condition occurs. But since the memory
enable bit is clear the register dump collected before the chip was
reset is having all garbage in it. 

We were able to reproduce this issue internally only with iommu enabled.
In your dmesg logs I do not see iommu enabled. So unless we have a pcie
trace we cannot confirm if this HW bug is indeed the problem you are
seeing.

Meanwhile can you try the attached patch and see if you are able to
reproduce the problem ? This patch will restrict all DMA address given
to the chip to 31 bits.

Toan, thanks for bringing this to our notice, also please cc maintainers
so that mails are not missed.

--=-zJhIXkR4BnhdGNnH7IiG
Content-Disposition: attachment;
	filename="Restrict-DMA-address-to-31-bits-for-5762-device.patch"
Content-Type: text/x-patch;
	name="Restrict-DMA-address-to-31-bits-for-5762-device.patch";
	charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 488fd699985f73d361d04d4788de48833c6442ca Mon Sep 17 00:00:00 2001
From: Prashant Sreedharan <prashant@broadcom.com>
Date: Tue, 28 Apr 2015 11:32:56 -0700
Subject: [PATCH] tg3: Restrict DMA address to 31 bits for 5762 device

---
 drivers/net/ethernet/broadcom/tg3.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 069952f..e980c96 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -17707,6 +17707,8 @@ static int tg3_init_one(struct pci_dev *pdev,
 	 */
 	if (tg3_flag(tp, IS_5788))
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(32);
+	else if (tg3_asic_rev(tp) == ASIC_REV_5762)
+		persist_dma_mask = dma_mask = DMA_BIT_MASK(31);
 	else if (tg3_flag(tp, 40BIT_DMA_BUG)) {
 		persist_dma_mask = dma_mask = DMA_BIT_MASK(40);
 #ifdef CONFIG_HIGHMEM
@@ -17736,6 +17738,17 @@ static int tg3_init_one(struct pci_dev *pdev,
 				"No usable DMA configuration, aborting\n");
 			goto err_out_apeunmap;
 		}
+	} else {
+		err = pci_set_dma_mask(pdev, dma_mask);
+		if (!err) {
+			err = pci_set_consistent_dma_mask(pdev,
+							  persist_dma_mask);
+		}
+		if (err) {
+			dev_err(&pdev->dev,
+				"No usable DMA configuration, aborting\n");
+			goto err_out_apeunmap;
+		}
 	}
 
 	tg3_init_bufmgr_config(tp);
-- 
1.7.1


--=-zJhIXkR4BnhdGNnH7IiG--
