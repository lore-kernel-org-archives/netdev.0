From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH 15/19] tg3: remove unnecessary read of
 PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 13:38:25 -0700
Message-ID: <20110627203825.GA6010@mcarlson.broadcom.com>
References: <1309196854-16232-1-git-send-email-jdmason@kudzu.us>
 <20110627184203.GA5817@mcarlson.broadcom.com>
 <BANLkTi=-aoj=zg7BZbkzVikF7V9Si8c1xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>
To: "Jon Mason" <jdmason@kudzu.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3863 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754295Ab1F0Udb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 16:33:31 -0400
In-Reply-To: <BANLkTi=-aoj=zg7BZbkzVikF7V9Si8c1xA@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2011 at 01:23:04PM -0700, Jon Mason wrote:
> On Mon, Jun 27, 2011 at 1:42 PM, Matt Carlson <mcarlson@broadcom.com> wrote:
> > On Mon, Jun 27, 2011 at 10:47:34AM -0700, Jon Mason wrote:
> >> The PCIE capability offset is saved during PCI bus walking.  Use the
> >> value from pci_dev instead of checking in the driver and saving it off
> >> the the driver specific structure.  It will remove an unnecessary search
> >> in the PCI configuration space if this value is referenced instead of
> >> reacquiring it.  Also, there is no need to set a driver specific flag to
> >> show whether the device is PCIE.  pci_is_pcie can be used for this
> >> purpose (thus removing the need for this flag).
> >>
> >> Signed-off-by: Jon Mason <jdmason@kudzu.us>
> >
> > I like the direction this is taking the code, but there are hidden dangers
> > here you might not be aware of.  BCM5785 devices are effectively PCIe
> > devices, and should follow PCIe codepaths, but do not have a PCIe
> > capabilities section.
> 
> Ah, that could cause a problem.  Good catch!
> 
> > Instead, can we keep the PCI_EXPRESS flag, but change all occurrances of
> > 'tp->pcie_cap' to either pci_pcie_cap(tp->pdev) or
> > pci_is_pcie(tp->pdev)?  We should probably add the following next to the
> > TG3_FLAG_PCI_EXPRESS enumeration too:
> >
> > /* BCM5785 + pci_is_pcie() */
> 
> Yes, I can revert that 1/2 of the patch, make the change above, and resubmit.
> 
> FYI, this e-mail didn't CC netdev.  You might wanna nack it there :)

Yes.  You are right.  Added netdev to the recipient list.

Consider it NAK'd. :)

> Thanks,
> Jon
> 
> >
> >> ---
> >>  drivers/net/tg3.c |   53 ++++++++++++++++++++++++-----------------------------
> >>  drivers/net/tg3.h |    4 ----
> >>  2 files changed, 24 insertions(+), 33 deletions(-)
> >>
> >> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> >> index 97cd02d..5ecbc5c 100644
> >> --- a/drivers/net/tg3.c
> >> +++ b/drivers/net/tg3.c
> >> @@ -2679,11 +2679,11 @@ static int tg3_power_down_prepare(struct tg3 *tp)
> >>               u16 lnkctl;
> >>
> >>               pci_read_config_word(tp->pdev,
> >> -                                  tp->pcie_cap + PCI_EXP_LNKCTL,
> >> +                                  tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
> >>                                    &lnkctl);
> >>               lnkctl |= PCI_EXP_LNKCTL_CLKREQ_EN;
> >>               pci_write_config_word(tp->pdev,
> >> -                                   tp->pcie_cap + PCI_EXP_LNKCTL,
> >> +                                   tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
> >>                                     lnkctl);
> >>       }
> >>
> >> @@ -3485,7 +3485,7 @@ relink:
> >>               u16 oldlnkctl, newlnkctl;
> >>
> >>               pci_read_config_word(tp->pdev,
> >> -                                  tp->pcie_cap + PCI_EXP_LNKCTL,
> >> +                                  tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
> >>                                    &oldlnkctl);
> >>               if (tp->link_config.active_speed == SPEED_100 ||
> >>                   tp->link_config.active_speed == SPEED_10)
> >> @@ -3494,7 +3494,7 @@ relink:
> >>                       newlnkctl = oldlnkctl | PCI_EXP_LNKCTL_CLKREQ_EN;
> >>               if (newlnkctl != oldlnkctl)
> >>                       pci_write_config_word(tp->pdev,
> >> -                                           tp->pcie_cap + PCI_EXP_LNKCTL,
> >> +                                           tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
> >>                                             newlnkctl);
> >>       }
> >>
> >> @@ -4604,7 +4604,7 @@ static void tg3_dump_state(struct tg3 *tp)
> >>               return;
> >>       }
> >>
> >> -     if (tg3_flag(tp, PCI_EXPRESS)) {
> >> +     if (pci_is_pcie(tp->pdev)) {
> >>               /* Read up to but not including private PCI registers */
> >>               for (i = 0; i < TG3_PCIE_TLDLPL_PORT; i += sizeof(u32))
> >>                       regs[i / sizeof(u32)] = tr32(i);
> >> @@ -7064,7 +7064,7 @@ static void tg3_restore_pci_state(struct tg3 *tp)
> >>       pci_write_config_word(tp->pdev, PCI_COMMAND, tp->pci_cmd);
> >>
> >>       if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) {
> >> -             if (tg3_flag(tp, PCI_EXPRESS))
> >> +             if (pci_is_pcie(tp->pdev))
> >>                       pcie_set_readrq(tp->pdev, tp->pcie_readrq);
> >>               else {
> >>                       pci_write_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
> >> @@ -7172,7 +7172,7 @@ static int tg3_chip_reset(struct tg3 *tp)
> >>       /* do the reset */
> >>       val = GRC_MISC_CFG_CORECLK_RESET;
> >>
> >> -     if (tg3_flag(tp, PCI_EXPRESS)) {
> >> +     if (pci_is_pcie(tp->pdev)) {
> >>               /* Force PCIe 1.0a mode */
> >>               if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
> >>                   !tg3_flag(tp, 57765_PLUS) &&
> >> @@ -7226,7 +7226,7 @@ static int tg3_chip_reset(struct tg3 *tp)
> >>
> >>       udelay(120);
> >>
> >> -     if (tg3_flag(tp, PCI_EXPRESS) && tp->pcie_cap) {
> >> +     if (pci_is_pcie(tp->pdev)) {
> >>               u16 val16;
> >>
> >>               if (tp->pci_chip_rev_id == CHIPREV_ID_5750_A0) {
> >> @@ -7244,7 +7244,7 @@ static int tg3_chip_reset(struct tg3 *tp)
> >>
> >>               /* Clear the "no snoop" and "relaxed ordering" bits. */
> >>               pci_read_config_word(tp->pdev,
> >> -                                  tp->pcie_cap + PCI_EXP_DEVCTL,
> >> +                                  tp->pdev->pcie_cap + PCI_EXP_DEVCTL,
> >>                                    &val16);
> >>               val16 &= ~(PCI_EXP_DEVCTL_RELAX_EN |
> >>                          PCI_EXP_DEVCTL_NOSNOOP_EN);
> >> @@ -7255,14 +7255,14 @@ static int tg3_chip_reset(struct tg3 *tp)
> >>               if (!tg3_flag(tp, CPMU_PRESENT))
> >>                       val16 &= ~PCI_EXP_DEVCTL_PAYLOAD;
> >>               pci_write_config_word(tp->pdev,
> >> -                                   tp->pcie_cap + PCI_EXP_DEVCTL,
> >> +                                   tp->pdev->pcie_cap + PCI_EXP_DEVCTL,
> >>                                     val16);
> >>
> >>               pcie_set_readrq(tp->pdev, tp->pcie_readrq);
> >>
> >>               /* Clear error status */
> >>               pci_write_config_word(tp->pdev,
> >> -                                   tp->pcie_cap + PCI_EXP_DEVSTA,
> >> +                                   tp->pdev->pcie_cap + PCI_EXP_DEVSTA,
> >>                                     PCI_EXP_DEVSTA_CED |
> >>                                     PCI_EXP_DEVSTA_NFED |
> >>                                     PCI_EXP_DEVSTA_FED |
> >> @@ -7325,7 +7325,7 @@ static int tg3_chip_reset(struct tg3 *tp)
> >>
> >>       tg3_mdio_start(tp);
> >>
> >> -     if (tg3_flag(tp, PCI_EXPRESS) &&
> >> +     if (pci_is_pcie(tp->pdev) &&
> >>           tp->pci_chip_rev_id != CHIPREV_ID_5750_A0 &&
> >>           GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
> >>           !tg3_flag(tp, 57765_PLUS)) {
> >> @@ -8062,7 +8062,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
> >>        * chips and don't even touch the clocks if the CPMU is present.
> >>        */
> >>       if (!tg3_flag(tp, CPMU_PRESENT)) {
> >> -             if (!tg3_flag(tp, PCI_EXPRESS))
> >> +             if (!pci_is_pcie(tp->pdev))
> >>                       tp->pci_clock_ctrl |= CLOCK_CTRL_DELAY_PCI_GRANT;
> >>               tw32_f(TG3PCI_CLOCK_CTRL, tp->pci_clock_ctrl);
> >>       }
> >> @@ -8339,7 +8339,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
> >>               }
> >>       }
> >>
> >> -     if (tg3_flag(tp, PCI_EXPRESS))
> >> +     if (pci_is_pcie(tp->pdev))
> >>               rdmac_mode |= RDMAC_MODE_FIFO_LONG_BURST;
> >>
> >>       if (tg3_flag(tp, HW_TSO_1) ||
> >> @@ -12873,7 +12873,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
> >>                   (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
> >>                       tp->phy_flags |= TG3_PHYFLG_ENABLE_APD;
> >>
> >> -             if (tg3_flag(tp, PCI_EXPRESS) &&
> >> +             if (pci_is_pcie(tp->pdev) &&
> >>                   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
> >>                   !tg3_flag(tp, 57765_PLUS)) {
> >>                       u32 cfg3;
> >> @@ -13777,12 +13777,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> >>       pci_read_config_dword(tp->pdev, TG3PCI_PCISTATE,
> >>                             &pci_state_reg);
> >>
> >> -     tp->pcie_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_EXP);
> >> -     if (tp->pcie_cap != 0) {
> >> +     if (pci_is_pcie(tp->pdev)) {
> >>               u16 lnkctl;
> >>
> >> -             tg3_flag_set(tp, PCI_EXPRESS);
> >> -
> >>               tp->pcie_readrq = 4096;
> >>               if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
> >>                   GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
> >> @@ -13791,7 +13788,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> >>               pcie_set_readrq(tp->pdev, tp->pcie_readrq);
> >>
> >>               pci_read_config_word(tp->pdev,
> >> -                                  tp->pcie_cap + PCI_EXP_LNKCTL,
> >> +                                  tp->pdev->pcie_cap + PCI_EXP_LNKCTL,
> >>                                    &lnkctl);
> >>               if (lnkctl & PCI_EXP_LNKCTL_CLKREQ_EN) {
> >>                       if (GET_ASIC_REV(tp->pci_chip_rev_id) ==
> >> @@ -13807,8 +13804,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> >>               } else if (tp->pci_chip_rev_id == CHIPREV_ID_5717_A0) {
> >>                       tg3_flag_set(tp, L1PLLPD_EN);
> >>               }
> >> -     } else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
> >> -             tg3_flag_set(tp, PCI_EXPRESS);
> >>       } else if (!tg3_flag(tp, 5705_PLUS) ||
> >>                  tg3_flag(tp, 5780_CLASS)) {
> >>               tp->pcix_cap = pci_find_capability(tp->pdev, PCI_CAP_ID_PCIX);
> >> @@ -13829,7 +13824,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> >>        * posted to the chip in order.
> >>        */
> >>       if (pci_dev_present(tg3_write_reorder_chipsets) &&
> >> -         !tg3_flag(tp, PCI_EXPRESS))
> >> +         !pci_is_pcie(tp->pdev))
> >>               tg3_flag_set(tp, MBOX_WRITE_REORDER);
> >>
> >>       pci_read_config_byte(tp->pdev, PCI_CACHE_LINE_SIZE,
> >> @@ -13903,7 +13898,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
> >>       if (tg3_flag(tp, PCIX_TARGET_HWBUG))
> >>               tp->write32 = tg3_write_indirect_reg32;
> >>       else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
> >> -              (tg3_flag(tp, PCI_EXPRESS) &&
> >> +              (pci_is_pcie(tp->pdev) &&
> >>                 tp->pci_chip_rev_id == CHIPREV_ID_5750_A0)) {
> >>               /*
> >>                * Back to back register writes can cause problems on these
> >> @@ -14390,7 +14385,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
> >>        */
> >>       if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5700 &&
> >>           GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701 &&
> >> -         !tg3_flag(tp, PCI_EXPRESS))
> >> +         !pci_is_pcie(tp->pdev))
> >>               goto out;
> >>
> >>  #if defined(CONFIG_PPC64) || defined(CONFIG_IA64) || defined(CONFIG_PARISC)
> >> @@ -14422,7 +14417,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
> >>        * other than 5700 and 5701 which do not implement the
> >>        * boundary bits.
> >>        */
> >> -     if (tg3_flag(tp, PCIX_MODE) && !tg3_flag(tp, PCI_EXPRESS)) {
> >> +     if (tg3_flag(tp, PCIX_MODE) && !pci_is_pcie(tp->pdev)) {
> >>               switch (cacheline_size) {
> >>               case 16:
> >>               case 32:
> >> @@ -14447,7 +14442,7 @@ static u32 __devinit tg3_calc_dma_bndry(struct tg3 *tp, u32 val)
> >>                               DMA_RWCTRL_WRITE_BNDRY_384_PCIX);
> >>                       break;
> >>               }
> >> -     } else if (tg3_flag(tp, PCI_EXPRESS)) {
> >> +     } else if (pci_is_pcie(tp->pdev)) {
> >>               switch (cacheline_size) {
> >>               case 16:
> >>               case 32:
> >> @@ -14622,7 +14617,7 @@ static int __devinit tg3_test_dma(struct tg3 *tp)
> >>       if (tg3_flag(tp, 57765_PLUS))
> >>               goto out;
> >>
> >> -     if (tg3_flag(tp, PCI_EXPRESS)) {
> >> +     if (pci_is_pcie(tp->pdev)) {
> >>               /* DMA read watermark not used on PCIE */
> >>               tp->dma_rwctrl |= 0x00180000;
> >>       } else if (!tg3_flag(tp, PCIX_MODE)) {
> >> @@ -14880,7 +14875,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
> >>
> >>  static char * __devinit tg3_bus_string(struct tg3 *tp, char *str)
> >>  {
> >> -     if (tg3_flag(tp, PCI_EXPRESS)) {
> >> +     if (pci_is_pcie(tp->pdev)) {
> >>               strcpy(str, "PCI Express");
> >>               return str;
> >>       } else if (tg3_flag(tp, PCIX_MODE)) {
> >> diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
> >> index bedc3b4..ede661f 100644
> >> --- a/drivers/net/tg3.h
> >> +++ b/drivers/net/tg3.h
> >> @@ -2857,7 +2857,6 @@ enum TG3_FLAGS {
> >>       TG3_FLAG_IS_5788,
> >>       TG3_FLAG_MAX_RXPEND_64,
> >>       TG3_FLAG_TSO_CAPABLE,
> >> -     TG3_FLAG_PCI_EXPRESS,
> >>       TG3_FLAG_ASF_NEW_HANDSHAKE,
> >>       TG3_FLAG_HW_AUTONEG,
> >>       TG3_FLAG_IS_NIC,
> >> @@ -3022,10 +3021,7 @@ struct tg3 {
> >>
> >>       int                             pm_cap;
> >>       int                             msi_cap;
> >> -     union {
> >>       int                             pcix_cap;
> >> -     int                             pcie_cap;
> >> -     };
> >>       int                             pcie_readrq;
> >>
> >>       struct mii_bus                  *mdio_bus;
> >> --
> >> 1.7.5.4
> >>
> >>
> >
> >
> 

