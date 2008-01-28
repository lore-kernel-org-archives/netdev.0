From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] [NET]: Remove PowerPC code from fec.c
Date: Tue, 29 Jan 2008 09:58:50 +1000
Message-ID: <479E6C3A.4070401@snapgear.com>
References: <4799F349.9090102@scram.de> <Pine.LNX.4.64.0801251544480.13060@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jochen Friedrich <jochen@scram.de>,
	"Garzik, Jeff" <jgarzik@pobox.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Scott Wood <scottwood@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>,
	"Kernel, Linux" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	linux-m68k@vger.kernel.org, uClinux list <uclinux-dev@uclinux.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764249AbYA1X7X@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0801251544480.13060@anakin>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


 > ---------- Forwarded message ----------
 > Date: Fri, 25 Jan 2008 15:33:45 +0100
 > From: Jochen Friedrich <jochen@scram.de>
 > To: "Garzik, Jeff" <jgarzik@pobox.com>
 > Cc: Vitaly Bordug <vitb@kernel.crashing.org>,
 >     Scott Wood <scottwood@freescale.com>,
 >     Kumar Gala <galak@kernel.crashing.org>,
 >     Geert Uytterhoeven <geert@linux-m68k.org>,
 >     "Kernel, Linux" <linux-kernel@vger.kernel.org>,
 >     "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 >     linuxppc-dev list <linuxppc-dev@ozlabs.org>, 
linux-m68k@vger.kernel.org
 > Subject: [PATCH] [NET]: Remove PowerPC code from fec.c
 >
 > fec.c is only used on M68k Coldfire CPUs. Remove leftover
 > PowerPC code from this driver.

I was always hoping that this driver would be supported on both
architectures. After all the underlying eth device is essentially
the same on both.

Anyway... I don't have a problem with this patch, looks ok
the me.

Acked-by: Greg Ungerer <gerg@uclinux.org>

Regards
Greg




 > Signed-off-by: Jochen Friedrich <jochen@scram.de>
 > ---
 >  drivers/net/fec.c |  136 
+---------------------------------------------------
 >  1 files changed, 3 insertions(+), 133 deletions(-)
 >
 > diff --git a/drivers/net/fec.c b/drivers/net/fec.c
 > index 0fbf1bb..0499cbb 100644
 > --- a/drivers/net/fec.c
 > +++ b/drivers/net/fec.c
 > @@ -23,6 +23,9 @@
 >   *
 >   * Bug fixes and cleanup by Philippe De Muyter (phdm@macqel.be)
 >   * Copyright (c) 2004-2006 Macq Electronique SA.
 > + *
 > + * This driver is now only used on ColdFire processors. Remove 
conditional
 > + * Powerpc code.
 >   */
 >
 >  #include <linux/module.h>
 > @@ -49,17 +52,9 @@
 >  #include <asm/pgtable.h>
 >  #include <asm/cacheflush.h>
 >
 > -#if defined(CONFIG_M523x) || defined(CONFIG_M527x) || \
 > -    defined(CONFIG_M5272) || defined(CONFIG_M528x) || \
 > -    defined(CONFIG_M520x) || defined(CONFIG_M532x)
 >  #include <asm/coldfire.h>
 >  #include <asm/mcfsim.h>
 >  #include "fec.h"
 > -#else
 > -#include <asm/8xx_immap.h>
 > -#include <asm/mpc8xx.h>
 > -#include "commproc.h"
 > -#endif
 >
 >  #if defined(CONFIG_FEC2)
 >  #define	FEC_MAX_PORTS	2
 > @@ -1223,14 +1218,9 @@ static phy_info_t const * const phy_info[] = {
 >
 >  /* 
------------------------------------------------------------------------- */
 >  #if !defined(CONFIG_M532x)
 > -#ifdef CONFIG_RPXCLASSIC
 > -static void
 > -mii_link_interrupt(void *dev_id);
 > -#else
 >  static irqreturn_t
 >  mii_link_interrupt(int irq, void * dev_id);
 >  #endif
 > -#endif
 >
 >  #if defined(CONFIG_M5272)
 >  /*
 > @@ -1800,121 +1790,6 @@ static void __inline__ fec_uncache(unsigned 
long addr)
 >  /* 
------------------------------------------------------------------------- */
 >
 >
 > -#else
 > -
 > -/*
 > - *	Code specific to the MPC860T setup.
 > - */
 > -static void __inline__ fec_request_intrs(struct net_device *dev)
 > -{
 > -	volatile immap_t *immap;
 > -
 > -	immap = (immap_t *)IMAP_ADDR;	/* pointer to internal registers */
 > -
 > -	if (request_8xxirq(FEC_INTERRUPT, fec_enet_interrupt, 0, "fec", 
dev) != 0)
 > -		panic("Could not allocate FEC IRQ!");
 > -
 > -#ifdef CONFIG_RPXCLASSIC
 > -	/* Make Port C, bit 15 an input that causes interrupts.
 > -	*/
 > -	immap->im_ioport.iop_pcpar &= ~0x0001;
 > -	immap->im_ioport.iop_pcdir &= ~0x0001;
 > -	immap->im_ioport.iop_pcso &= ~0x0001;
 > -	immap->im_ioport.iop_pcint |= 0x0001;
 > -	cpm_install_handler(CPMVEC_PIO_PC15, mii_link_interrupt, dev);
 > -
 > -	/* Make LEDS reflect Link status.
 > -	*/
 > -	*((uint *) RPX_CSR_ADDR) &= ~BCSR2_FETHLEDMODE;
 > -#endif
 > -#ifdef CONFIG_FADS
 > -	if (request_8xxirq(SIU_IRQ2, mii_link_interrupt, 0, "mii", dev) != 0)
 > -		panic("Could not allocate MII IRQ!");
 > -#endif
 > -}
 > -
 > -static void __inline__ fec_get_mac(struct net_device *dev)
 > -{
 > -	bd_t *bd;
 > -
 > -	bd = (bd_t *)__res;
 > -	memcpy(dev->dev_addr, bd->bi_enetaddr, ETH_ALEN);
 > -
 > -#ifdef CONFIG_RPXCLASSIC
 > -	/* The Embedded Planet boards have only one MAC address in
 > -	 * the EEPROM, but can have two Ethernet ports.  For the
 > -	 * FEC port, we create another address by setting one of
 > -	 * the address bits above something that would have (up to
 > -	 * now) been allocated.
 > -	 */
 > -	dev->dev_adrd[3] |= 0x80;
 > -#endif
 > -}
 > -
 > -static void __inline__ fec_set_mii(struct net_device *dev, struct 
fec_enet_private *fep)
 > -{
 > -	extern uint _get_IMMR(void);
 > -	volatile immap_t *immap;
 > -	volatile fec_t *fecp;
 > -
 > -	fecp = fep->hwp;
 > -	immap = (immap_t *)IMAP_ADDR;	/* pointer to internal registers */
 > -
 > -	/* Configure all of port D for MII.
 > -	*/
 > -	immap->im_ioport.iop_pdpar = 0x1fff;
 > -
 > -	/* Bits moved from Rev. D onward.
 > -	*/
 > -	if ((_get_IMMR() & 0xffff) < 0x0501)
 > -		immap->im_ioport.iop_pddir = 0x1c58;	/* Pre rev. D */
 > -	else
 > -		immap->im_ioport.iop_pddir = 0x1fff;	/* Rev. D and later */
 > -
 > -	/* Set MII speed to 2.5 MHz
 > -	*/
 > -	fecp->fec_mii_speed = fep->phy_speed =
 > -		((bd->bi_busfreq * 1000000) / 2500000) & 0x7e;
 > -}
 > -
 > -static void __inline__ fec_enable_phy_intr(void)
 > -{
 > -	volatile fec_t *fecp;
 > -
 > -	fecp = fep->hwp;
 > -
 > -	/* Enable MII command finished interrupt
 > -	*/
 > -	fecp->fec_ivec = (FEC_INTERRUPT/2) << 29;
 > -}
 > -
 > -static void __inline__ fec_disable_phy_intr(void)
 > -{
 > -}
 > -
 > -static void __inline__ fec_phy_ack_intr(void)
 > -{
 > -}
 > -
 > -static void __inline__ fec_localhw_setup(void)
 > -{
 > -	volatile fec_t *fecp;
 > -
 > -	fecp = fep->hwp;
 > -	fecp->fec_r_hash = PKT_MAXBUF_SIZE;
 > -	/* Enable big endian and don't care about SDMA FC.
 > -	*/
 > -	fecp->fec_fun_code = 0x78000000;
 > -}
 > -
 > -static void __inline__ fec_uncache(unsigned long addr)
 > -{
 > -	pte_t *pte;
 > -	pte = va_to_pte(mem_addr);
 > -	pte_val(*pte) |= _PAGE_NO_CACHE;
 > -	flush_tlb_page(init_mm.mmap, mem_addr);
 > -}
 > -
 >  #endif
 >
 >  /* 
------------------------------------------------------------------------- */
 > @@ -2126,13 +2001,8 @@ mii_discover_phy(uint mii_reg, struct 
net_device *dev)
 >
 >  /* This interrupt occurs when the PHY detects a link change.
 >  */
 > -#ifdef CONFIG_RPXCLASSIC
 > -static void
 > -mii_link_interrupt(void *dev_id)
 > -#else
 >  static irqreturn_t
 >  mii_link_interrupt(int irq, void * dev_id)
 > -#endif
 >  {
 >  	struct	net_device *dev = dev_id;
 >  	struct fec_enet_private *fep = netdev_priv(dev);

------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
SnapGear -- a Secure Computing Company      PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
