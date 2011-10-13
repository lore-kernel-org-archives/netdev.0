From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH v3 1/3] phylib: Convert MDIO and PHY Lib drivers to support
 10G
Date: Thu, 13 Oct 2011 09:00:03 -0700
Message-ID: <4E970B03.9060200@cavium.com>
References: <1318516660-25452-1-git-send-email-afleming@freescale.com> <1318516660-25452-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:9331 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756389Ab1JMQAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 12:00:04 -0400
In-Reply-To: <1318516660-25452-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/13/2011 07:37 AM, Andy Fleming wrote:
> 10G MDIO is a totally different protocol (clause 45 of 802.3).
> Supporting this new protocol requires a couple of changes:
>
> * Add a new parameter to the mdiobus_read functions to specify the
>    "device address" inside the PHY.
> * Add a phy45_read/write function which takes advantage of that
>    new parameter
> * Convert all of the existing drivers to use the new format
>
> I created a new clause-45-specific read/write functions because:
> 1) phy_read and phy_write are highly overloaded functions, and
>     finding every instance which is actually the PHY Lib version
>     was quite difficult
> 2) Most code which invokes phy_read/phy_write inside PHY Lib is
>     Clause-22-specific. None of the phy_read/phy_write invocations
>     were useable on 10G PHYs
>

I think converting all these phy_read/phy_write to take an extra
parameter is a mistake.  99% of the users have no need for the "device
address".  Also you are still passing the protocol mode as a high
order bit in the register address, so that part is still quite ugly.

The existing infrastructure where we pass the "device address" in bits
16..20 of the register number is much less disruptive.

If you don't like it, an easy and much less intrusive approach might
be a simple (untested) wrapper:

static inline int phy45_read(struct phy_device *phydev,
                              int devad, u16 regnum)
{
	u32 c45_reg = MII_ADDR_C45 | ((devad & 0x1f) << 16) | regnum;
	return phy_read(phydev, c45_reg)
}

static inline int phy45_write(struct phy_device *phydev,
                               int devad, u16 regnum, u16 val)
{
	u32 c45_reg = MII_ADDR_C45 | ((devad & 0x1f) << 16) | regnum;
	return phy_write(phydev, c45_reg, val)
}


> Signed-off-by: Andy Fleming<afleming@freescale.com>
> ---
> v2: Convert newer buses, split out generic PHY support
> v3: Make patch series more coherent
>
>   Documentation/networking/phy.txt                  |   15 +++--
>   arch/powerpc/platforms/pasemi/gpio_mdio.c         |    6 +-
>   drivers/net/ethernet/adi/bfin_mac.c               |    7 +-
>   drivers/net/ethernet/aeroflex/greth.c             |    5 +-
>   drivers/net/ethernet/amd/au1000_eth.c             |    7 +-
>   drivers/net/ethernet/broadcom/bcm63xx_enet.c      |    4 +-
>   drivers/net/ethernet/broadcom/sb1250-mac.c        |    7 +-
>   drivers/net/ethernet/broadcom/tg3.c               |    5 +-
>   drivers/net/ethernet/cadence/macb.c               |    7 +-
>   drivers/net/ethernet/dnet.c                       |    7 +-
>   drivers/net/ethernet/ethoc.c                      |    5 +-
>   drivers/net/ethernet/faraday/ftgmac100.c          |    5 +-
>   drivers/net/ethernet/freescale/fec.c              |    7 +-
>   drivers/net/ethernet/freescale/fec_mpc52xx_phy.c  |    7 +-
>   drivers/net/ethernet/freescale/fs_enet/mii-fec.c  |    6 +-
>   drivers/net/ethernet/freescale/fsl_pq_mdio.c      |   13 ++--
>   drivers/net/ethernet/freescale/fsl_pq_mdio.h      |   11 ++-
>   drivers/net/ethernet/lantiq_etop.c                |    5 +-
>   drivers/net/ethernet/marvell/mv643xx_eth.c        |    5 +-
>   drivers/net/ethernet/marvell/pxa168_eth.c         |    7 +-
>   drivers/net/ethernet/rdc/r6040.c                  |    5 +-
>   drivers/net/ethernet/s6gmac.c                     |    5 +-
>   drivers/net/ethernet/smsc/smsc911x.c              |   22 ++++---
>   drivers/net/ethernet/smsc/smsc9420.c              |   10 ++-
>   drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c |    9 ++-
>   drivers/net/ethernet/ti/cpmac.c                   |    4 +-
>   drivers/net/ethernet/ti/davinci_mdio.c            |    5 +-
>   drivers/net/ethernet/toshiba/tc35815.c            |    5 +-
>   drivers/net/ethernet/xilinx/ll_temac_mdio.c       |    5 +-
>   drivers/net/ethernet/xilinx/xilinx_emaclite.c     |    9 ++-
>   drivers/net/ethernet/xscale/ixp4xx_eth.c          |    7 +-
>   drivers/net/phy/fixed.c                           |    5 +-
>   drivers/net/phy/icplus.c                          |   17 +++--
>   drivers/net/phy/mdio-bitbang.c                    |    5 +-
>   drivers/net/phy/mdio-octeon.c                     |    5 +-
>   drivers/net/phy/mdio_bus.c                        |    8 +-
>   drivers/net/phy/phy.c                             |    5 +-
>   drivers/net/phy/phy_device.c                      |   64 +++++++++++++------
>   include/linux/phy.h                               |   70 ++++++++++++++++++---
>   net/dsa/slave.c                                   |    5 +-
>   40 files changed, 270 insertions(+), 141 deletions(-)
>
