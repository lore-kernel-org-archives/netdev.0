From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCHv4 1/5] net: phy: decouple PHY id and PHY address in fixed
 PHY driver
Date: Fri, 16 May 2014 11:30:36 -0700
Message-ID: <CAGVrzcYFjROVwHsSTyO-+PAb9G9y55h93AsMk2Viui5Sb4jBpQ@mail.gmail.com>
References: <1400249647-4643-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1400249647-4643-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <robh+dt@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:45268 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755068AbaEPSbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 14:31:17 -0400
In-Reply-To: <1400249647-4643-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-16 7:14 GMT-07:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Until now, the fixed_phy_add() function was taking as argument
> 'phy_id', which was used both as the PHY address on the fake fixed
> MDIO bus, and as the PHY id, as available in the MII_PHYSID1 and
> MII_PHYSID2 registers. However, those two informations are completely
> unrelated.
>
> This patch decouples them. The PHY id of fixed PHYs is hardcoded to be
> 0x0. Ideally, a really reserved value would be nicer, but there
> doesn't seem to be an easy of making sure a dummy value can be
> assigned to the Linux kernel for such usage.
>
> The PHY address remains passed by the caller of phy_fixed_add().
>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/phy/fixed.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index ba55adf..e41546d 100644
> --- a/drivers/net/phy/fixed.c
> +++ b/drivers/net/phy/fixed.c
> @@ -31,7 +31,7 @@ struct fixed_mdio_bus {
>  };
>
>  struct fixed_phy {
> -       int id;
> +       int addr;
>         u16 regs[MII_REGS_NUM];
>         struct phy_device *phydev;
>         struct fixed_phy_status status;
> @@ -104,8 +104,8 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
>         if (fp->status.asym_pause)
>                 lpa |= LPA_PAUSE_ASYM;
>
> -       fp->regs[MII_PHYSID1] = fp->id >> 16;
> -       fp->regs[MII_PHYSID2] = fp->id;
> +       fp->regs[MII_PHYSID1] = 0;
> +       fp->regs[MII_PHYSID2] = 0;
>
>         fp->regs[MII_BMSR] = bmsr;
>         fp->regs[MII_BMCR] = bmcr;
> @@ -115,7 +115,7 @@ static int fixed_phy_update_regs(struct fixed_phy *fp)
>         return 0;
>  }
>
> -static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int reg_num)
> +static int fixed_mdio_read(struct mii_bus *bus, int phy_addr, int reg_num)
>  {
>         struct fixed_mdio_bus *fmb = bus->priv;
>         struct fixed_phy *fp;
> @@ -124,7 +124,7 @@ static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int reg_num)
>                 return -1;
>
>         list_for_each_entry(fp, &fmb->phys, node) {
> -               if (fp->id == phy_id) {
> +               if (fp->addr == phy_addr) {
>                         /* Issue callback if user registered it. */
>                         if (fp->link_update) {
>                                 fp->link_update(fp->phydev->attached_dev,
> @@ -138,7 +138,7 @@ static int fixed_mdio_read(struct mii_bus *bus, int phy_id, int reg_num)
>         return 0xFFFF;
>  }
>
> -static int fixed_mdio_write(struct mii_bus *bus, int phy_id, int reg_num,
> +static int fixed_mdio_write(struct mii_bus *bus, int phy_addr, int reg_num,
>                             u16 val)
>  {
>         return 0;
> @@ -160,7 +160,7 @@ int fixed_phy_set_link_update(struct phy_device *phydev,
>                 return -EINVAL;
>
>         list_for_each_entry(fp, &fmb->phys, node) {
> -               if (fp->id == phydev->phy_id) {
> +               if (fp->addr == phydev->addr) {
>                         fp->link_update = link_update;
>                         fp->phydev = phydev;
>                         return 0;
> @@ -171,7 +171,7 @@ int fixed_phy_set_link_update(struct phy_device *phydev,
>  }
>  EXPORT_SYMBOL_GPL(fixed_phy_set_link_update);
>
> -int fixed_phy_add(unsigned int irq, int phy_id,
> +int fixed_phy_add(unsigned int irq, int phy_addr,
>                   struct fixed_phy_status *status)
>  {
>         int ret;
> @@ -184,9 +184,9 @@ int fixed_phy_add(unsigned int irq, int phy_id,
>
>         memset(fp->regs, 0xFF,  sizeof(fp->regs[0]) * MII_REGS_NUM);
>
> -       fmb->irqs[phy_id] = irq;
> +       fmb->irqs[phy_addr] = irq;
>
> -       fp->id = phy_id;
> +       fp->addr = phy_addr;
>         fp->status = *status;
>
>         ret = fixed_phy_update_regs(fp);
> --
> 1.9.3



-- 
Florian
