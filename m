From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH RFC 08/28] net: dsa: Keep the mii bus and address in the private structure
Date: Thu, 21 Jan 2016 15:41:23 -0500
Message-ID: <874me64qdo.fsf@ketchup.mtl.sfl>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch> <1450875402-20740-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	narmstrong@baylibre.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:52789 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbcAUUra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 15:47:30 -0500
In-Reply-To: <1450875402-20740-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> Rather than looking up the mii bus and address every time, do it once
> and setup, and keep it in the private structure.
>
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/dsa/mv88e6060.c | 23 +++++++++++++----------
>  drivers/net/dsa/mv88e6060.h | 11 +++++++++++
>  drivers/net/dsa/mv88e6xxx.c | 16 ++++++----------
>  drivers/net/dsa/mv88e6xxx.h |  6 ++++++
>  4 files changed, 36 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index 34bc374882c7..d48708dfd963 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -19,12 +19,9 @@
>  
>  static int reg_read(struct dsa_switch *ds, int addr, int reg)
>  {
> -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> +	struct mv88e6060_priv *priv = ds_to_priv(ds);
>  
> -	if (bus == NULL)
> -		return -EINVAL;
> -
> -	return mdiobus_read_nested(bus, ds->pd->sw_addr + addr, reg);
> +	return mdiobus_read_nested(priv->bus, priv->sw_addr + addr, reg);
>  }
>  
>  #define REG_READ(addr, reg)					\
> @@ -40,12 +37,9 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
>  
>  static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
>  {
> -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> -
> -	if (bus == NULL)
> -		return -EINVAL;
> +	struct mv88e6060_priv *priv = ds_to_priv(ds);
>  
> -	return mdiobus_write_nested(bus, ds->pd->sw_addr + addr, reg, val);
> +	return mdiobus_write_nested(priv->bus, priv->sw_addr + addr, reg, val);
>  }
>  
>  #define REG_WRITE(addr, reg, val)				\
> @@ -176,6 +170,15 @@ static int mv88e6060_setup(struct dsa_switch *ds, struct device *dev)
>  {
>  	int i;
>  	int ret;
> +	struct mv88e6060_priv *priv;
> +
> +	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
> +	if (!priv)
> +		return -ENOMEM;
> +
> +	ds->priv = priv;
> +	priv->bus = dsa_host_dev_to_mii_bus(ds->master_dev);

This patch drops the checks for !bus, and thus mdiobus_write_nested can
segfault later. Maybe restore the check here?

        if (!priv->bus)
                return -EINVAL;

> +	priv->sw_addr = ds->pd->sw_addr;
>  
>  	ret = mv88e6060_switch_reset(ds);
>  	if (ret < 0)
> diff --git a/drivers/net/dsa/mv88e6060.h b/drivers/net/dsa/mv88e6060.h
> index cc9b2ed4aff4..10249bd16292 100644
> --- a/drivers/net/dsa/mv88e6060.h
> +++ b/drivers/net/dsa/mv88e6060.h
> @@ -108,4 +108,15 @@
>  #define GLOBAL_ATU_MAC_23	0x0e
>  #define GLOBAL_ATU_MAC_45	0x0f
>  
> +struct mv88e6060_priv {
> +	/* MDIO bus and address on bus to use. When in single chip
> +	 * mode, address is 0, and the switch uses multiple addresses
> +	 * on the bus.  When in multi-chip mode, the switch uses a
> +	 * single address which contains two registers used for
> +	 * indirect access to more registers.
> +	 */
> +	struct mii_bus *bus;
> +	int sw_addr;
> +};
> +
>  #endif
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 772adc7f9397..170b98f3acbe 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -94,15 +94,12 @@ static int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr,
>  
>  static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
>  {
> -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  	int ret;
>  
>  	assert_smi_lock(ds);
>  
> -	if (bus == NULL)
> -		return -EINVAL;
> -
> -	ret = __mv88e6xxx_reg_read(bus, ds->pd->sw_addr, addr, reg);
> +	ret = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, addr, reg);
>  	if (ret < 0)
>  		return ret;
>  
> @@ -159,17 +156,14 @@ static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
>  static int _mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg,
>  				u16 val)
>  {
> -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
>  
>  	assert_smi_lock(ds);
>  
> -	if (bus == NULL)
> -		return -EINVAL;
> -
>  	dev_dbg(ds->master_dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
>  		addr, reg, val);
>  
> -	return __mv88e6xxx_reg_write(bus, ds->pd->sw_addr, addr, reg, val);
> +	return __mv88e6xxx_reg_write(ps->bus, ps->sw_addr, addr, reg, val);
>  }
>  
>  int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
> @@ -2197,6 +2191,8 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds, struct device *dev)
>  
>  	ds->priv = ps;
>  	ps->ds = ds;
> +	ps->bus = dsa_host_dev_to_mii_bus(ds->master_dev);

Same comment here.

> +	ps->sw_addr = ds->pd->sw_addr;
>  
>  	mutex_init(&ps->smi_mutex);
>  
> diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
> index 72f7dbbce0e2..62069b30f6e5 100644
> --- a/drivers/net/dsa/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx.h
> @@ -388,6 +388,12 @@ struct mv88e6xxx_priv_state {
>  	 */
>  	struct mutex	smi_mutex;
>  
> +	/* The MII bus and the address on the bus that is used to
> +	 * communication with the switch
> +	 */
> +	struct mii_bus *bus;
> +	int sw_addr;
> +
>  #ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
>  	/* Handles automatic disabling and re-enabling of the PHY
>  	 * polling unit.
> -- 
> 2.6.3

Thanks,
-v
