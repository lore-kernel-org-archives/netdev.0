From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCHv3 1/4] net: phy: decouple PHY id and PHY address in fixed
 PHY driver
Date: Tue, 4 Mar 2014 10:43:12 -0800
Message-ID: <CAGVrzcYF0g-vDpkP_fnqb13faPtOOSy_Pqfo-Pgti0S26-1nSg@mail.gmail.com>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1393930704-24374-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:44139 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754105AbaCDSnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:43:53 -0500
In-Reply-To: <1393930704-24374-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-04 2:58 GMT-08:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Until now, the fixed_phy_add() function was taking as argument
> 'phy_id', which was used both as the PHY address on the fake fixed
> MDIO bus, and as the PHY id, as available in the MII_PHYSID1 and
> MII_PHYSID2 registers. However, those two informations are completely
> unrelated.
>
> This patch decouples them. The PHY id of fixed PHYs is hardcoded to be
> 0xdeadbeef. Ideally, a really reserved value would be nicer, but there
> doesn't seem to be an easy of making sure a dummy value can be
> assigned to the Linux kernel for such usage.
>
> The PHY address remains passed by the caller of phy_fixed_add().
>
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> ---
>  drivers/net/phy/fixed.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
>
> diff --git a/drivers/net/phy/fixed.c b/drivers/net/phy/fixed.c
> index ba55adf..0f02403 100644
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
> +       fp->regs[MII_PHYSID1] = 0xdead;
> +       fp->regs[MII_PHYSID2] = 0xbeef;

I am still scratching my head as to whether we want that change to be
in this particular version of changes, or if we want that to happen at
a later time when (if?) we can finally get some proper OUI number
allocation.

Technically we are presenting some sort of ABI to user-space, although
detecting a fixed PHY device by reading its MII_PHYSID1/2 and matching
it against its PHY address on the fixed MDIO bus would have been a
little "weak" (especially when you can check that the parent device in
sysfs is the fixed-0 bus).

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
> 1.8.3.2



-- 
Florian
