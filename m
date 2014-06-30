From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net v4 1/3] net: libphy: Add phy specific function to
 access mmd phy registers
Date: Mon, 30 Jun 2014 14:27:42 -0700
Message-ID: <CAGVrzcZtFfGb+vELbUzVC-=ThqFxrCLKy9RoFoSCJvQXakc0Rg@mail.gmail.com>
References: <1404092124-18704-1-git-send-email-vbridgers2013@gmail.com> <1404092124-18704-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Randy Dunlap <rdunlap@infradead.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, vbridger@altera.com
To: Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:44222 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755967AbaF3V2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 17:28:23 -0400
Received: by mail-ob0-f177.google.com with SMTP id uy5so9217862obc.22
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 14:28:23 -0700 (PDT)
In-Reply-To: <1404092124-18704-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vince,

2014-06-29 18:35 GMT-07:00 Vince Bridgers <vbridgers2013@gmail.com>:
> libphy was originally written assuming all phy devices support clause 45
> access extensions to the mmd registers through the indirection registers
> located within the first 16 phy registers. This assumption is not true
> in all cases, and one specific example is the Micrel ksz9021 10/100/1000
> Mbps phy. Using the stmmac driver, accessing the mmd registers to query
> and configure energy efficient Ethernet (EEE) features yielded unexpected
> behavior.
>
> This patch adds mmd access functions to the phy driver that can be
> overriden by the phy specific driver if the phy does not support this
> mechanism or uses it's own non-standard access mechanism. By default,
> the IEEE Compatible clause 45 access mechanism described in clause 22
> is used. With this patch, EEE query/configure functions as expected
> using the stmmac and the Micrel ksz9021 phy.
>
> Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>

Just one minor nit before this series can go in

[snip]

> - * phy_read_mmd_indirect - reads data from the MMD registers
> - * @bus: the target MII bus
> + * gen_rd_mmd_indirect - reads data from the MMD registers
> + * @phydev: The PHY device bus
>   * @prtad: MMD Address
>   * @devad: MMD DEVAD
>   * @addr: PHY address on the MII bus
> @@ -935,18 +935,18 @@ static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
>   * 3) Write reg 13 // MMD Data Command for MMD DEVAD
>   * 3) Read  reg 14 // Read MMD data
>   */
> -static int phy_read_mmd_indirect(struct mii_bus *bus, int prtad, int devad,
> -                                int addr)
> +int gen_rd_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
> +                       int addr)
>  {
> -       mmd_phy_indirect(bus, prtad, devad, addr);
> +       mmd_phy_indirect(phydev->bus, prtad, devad, addr);
>
>         /* Read the content of the MMD's selected register */
> -       return bus->read(bus, addr, MII_MMD_DATA);
> +       return phydev->bus->read(phydev->bus, addr, MII_MMD_DATA);

Throughout the PHY library, phy_* prefix means that this function will
perform the required level of abstraction, that is either using the
driver defined function, or falling back to the generic one.

I would like to reduce the number of changes involved here and keep
phy_read_mmd_indirect, but have it check the driver specific
implementation and fallback to the generic one.
--
Florian
