From: Scott Wood <scottwood@freescale.com>
Subject: Re: [v2,3/9] fsl/fman: Add the FMan MAC FLIB
Date: Thu, 25 Jun 2015 20:55:51 -0500
Message-ID: <1435283751.4306.13.camel@freescale.com>
References: <1435174458-452-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	madalin.bucur@freescale.com, pebolle@tiscali.nl
To: igal.liberman@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0131.outbound.protection.outlook.com ([65.55.169.131]:52974
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751098AbbFZB4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 21:56:02 -0400
In-Reply-To: <1435174458-452-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-24 at 22:34 +0300, igal.liberman@freescale.com wrote:
> From: Igal Liberman <Igal.Liberman@freescale.com>
> 
> The FMan MAC FLib provides basic API used by the drivers to
> configure and control the FMan MAC hardware.
> 
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
...
> > +int fman_dtsec_mii_write_reg(struct dtsec_mii_reg __iomem *regs, uint8_t 
> addr,
> +                          uint8_t reg, uint16_t data, uint16_t dtsec_freq)
> +{
> +     uint32_t tmp;
> +
> +     /* Setup the MII Mgmt clock speed */
> +     iowrite32be((uint32_t)dtsec_mii_get_div(dtsec_freq), &regs->miimcfg);
> +     /* Memory barrier */
> +     wmb();
> +
> +     /* Stop the MII management read cycle */
> +     iowrite32be(0, &regs->miimcom);
> +     /* Dummy read to make sure MIIMCOM is written */
> +     tmp = ioread32be(&regs->miimcom);
> +     /* Memory barrier */
> +     wmb();
> +
> +     /* Setting up MII Management Address Register */
> +     tmp = (uint32_t)((addr << MIIMADD_PHY_ADDR_SHIFT) | reg);
> +     iowrite32be(tmp, &regs->miimadd);
> +     /* Memory barrier */
> +     wmb();
> +
> +     /* Setting up MII Management Control Register with data */
> +     iowrite32be((uint32_t)data, &regs->miimcon);
> +     /* Dummy read to make sure MIIMCON is written */
> +     tmp = ioread32be(&regs->miimcon);
> +     /* Memory barrier */
> +     wmb();

iowrite32be() should already contain a memory barrier.

> +
> +     /* Wait until MII management write is complete */
> +     /* todo: a timeout could be useful here */
> +     while ((ioread32be(&regs->miimind)) & MIIMIND_BUSY)
> +             ; /* busy wait */
> +
> +     return 0;
> +}

Please add the timeout.

> +     /* Read MII management status  */
> +     *data = (uint16_t)ioread32be(&regs->miimstat);

Unnecessary cast (please check for these throughout the patchset).

There are also casts in this patchset that are only needed because a variable 
was unnecessarily defined with a smaller-than-32-bit data type.


> +void fman_memac_reset(struct memac_regs __iomem *regs)
> +{
> +     uint32_t tmp;
> +
> +     tmp = ioread32be(&regs->command_config);
> +
> +     tmp |= CMD_CFG_SW_RESET;
> +
> +     iowrite32be(tmp, &regs->command_config);
> +
> +     while (ioread32be(&regs->command_config) & CMD_CFG_SW_RESET)
> +             ;
> +}

Timeout, here and in all such loops.

-Scott
