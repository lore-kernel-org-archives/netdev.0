From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/2] dsa: Replace mii_bus with a generic host device
Date: Mon, 15 Sep 2014 14:48:21 -0700
Message-ID: <54175EA5.1040309@gmail.com>
References: <20140915165543.1261.2520.stgit@ahduyck-bv4.jf.intel.com> <20140915170024.1261.97226.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel@wantstofly.org, davem@davemloft.net
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:44801 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755038AbaIOVsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:48:32 -0400
Received: by mail-pd0-f171.google.com with SMTP id p10so7054319pdj.16
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 14:48:32 -0700 (PDT)
In-Reply-To: <20140915170024.1261.97226.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 10:00 AM, Alexander Duyck wrote:
> This change makes it so that instead of passing and storing a mii_bus we
> instead pass and store a host_dev.  From there we can test to determine the
> exact type of device, and can verify it is the correct device for our switch.
> 
> So for example it would be possible to pass a device pointer from a pci_dev
> and instead of checking for a PHY ID we could check for a vendor and/or device
> ID.

This introduce a small build failure with CONFIG_OF for which I will
send a patch shortly. Other than that, this is definitively a step in
the right direction, thanks!

> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  arch/arm/plat-orion/common.c      |    2 +-
>  drivers/net/dsa/bcm_sf2.c         |    2 +-
>  drivers/net/dsa/mv88e6060.c       |   13 +++++++++----
>  drivers/net/dsa/mv88e6123_61_65.c |    6 +++++-
>  drivers/net/dsa/mv88e6131.c       |    6 +++++-
>  drivers/net/dsa/mv88e6171.c       |    6 +++++-
>  drivers/net/dsa/mv88e6xxx.c       |    4 ++--
>  include/net/dsa.h                 |    9 +++++----
>  net/dsa/dsa.c                     |   24 ++++++++----------------
>  net/dsa/slave.c                   |    2 +-
>  10 files changed, 42 insertions(+), 32 deletions(-)
> 
> diff --git a/arch/arm/plat-orion/common.c b/arch/arm/plat-orion/common.c
> index 3ec6e8e..f5b00f4 100644
> --- a/arch/arm/plat-orion/common.c
> +++ b/arch/arm/plat-orion/common.c
> @@ -499,7 +499,7 @@ void __init orion_ge00_switch_init(struct dsa_platform_data *d, int irq)
>  
>  	d->netdev = &orion_ge00.dev;
>  	for (i = 0; i < d->nr_chips; i++)
> -		d->chip[i].mii_bus = &orion_ge00_shared.dev;
> +		d->chip[i].host_dev = &orion_ge00_shared.dev;
>  	orion_switch_device.dev.platform_data = d;
>  
>  	platform_device_register(&orion_switch_device);
> diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
> index e9918c7..02d7db3 100644
> --- a/drivers/net/dsa/bcm_sf2.c
> +++ b/drivers/net/dsa/bcm_sf2.c
> @@ -129,7 +129,7 @@ static int bcm_sf2_sw_get_sset_count(struct dsa_switch *ds)
>  	return BCM_SF2_STATS_SIZE;
>  }
>  
> -static char *bcm_sf2_sw_probe(struct mii_bus *bus, int sw_addr)
> +static char *bcm_sf2_sw_probe(struct device *host_dev, int sw_addr)
>  {
>  	return "Broadcom Starfighter 2";
>  }
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index d8037c1..776e965 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -21,7 +21,8 @@
>  
>  static int reg_read(struct dsa_switch *ds, int addr, int reg)
>  {
> -	return mdiobus_read(ds->master_mii_bus, ds->pd->sw_addr + addr, reg);
> +	return mdiobus_read(to_mii_bus(ds->master_dev),
> +			    ds->pd->sw_addr + addr, reg);
>  }
>  
>  #define REG_READ(addr, reg)					\
> @@ -37,8 +38,8 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
>  
>  static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
>  {
> -	return mdiobus_write(ds->master_mii_bus, ds->pd->sw_addr + addr,
> -			     reg, val);
> +	return mdiobus_write(to_mii_bus(ds->master_dev),
> +			     ds->pd->sw_addr + addr, reg, val);
>  }
>  
>  #define REG_WRITE(addr, reg, val)				\
> @@ -50,10 +51,14 @@ static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
>  			return __ret;				\
>  	})
>  
> -static char *mv88e6060_probe(struct mii_bus *bus, int sw_addr)
> +static char *mv88e6060_probe(struct device *host_dev, int sw_addr)
>  {
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
>  	int ret;
>  
> +	if (bus == NULL)
> +		return NULL;
> +
>  	ret = mdiobus_read(bus, sw_addr + REG_PORT(0), 0x03);
>  	if (ret >= 0) {
>  		ret &= 0xfff0;
> diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
> index 975774f..a332c53 100644
> --- a/drivers/net/dsa/mv88e6123_61_65.c
> +++ b/drivers/net/dsa/mv88e6123_61_65.c
> @@ -17,10 +17,14 @@
>  #include <net/dsa.h>
>  #include "mv88e6xxx.h"
>  
> -static char *mv88e6123_61_65_probe(struct mii_bus *bus, int sw_addr)
> +static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
>  {
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
>  	int ret;
>  
> +	if (bus == NULL)
> +		return NULL;
> +
>  	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
>  	if (ret >= 0) {
>  		if (ret == 0x1212)
> diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
> index 35541f2..244c735 100644
> --- a/drivers/net/dsa/mv88e6131.c
> +++ b/drivers/net/dsa/mv88e6131.c
> @@ -22,10 +22,14 @@
>  #define ID_6095		0x0950
>  #define ID_6131		0x1060
>  
> -static char *mv88e6131_probe(struct mii_bus *bus, int sw_addr)
> +static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
>  {
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
>  	int ret;
>  
> +	if (bus == NULL)
> +		return NULL;
> +
>  	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
>  	if (ret >= 0) {
>  		ret &= 0xfff0;
> diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
> index 03a7006..6365e30 100644
> --- a/drivers/net/dsa/mv88e6171.c
> +++ b/drivers/net/dsa/mv88e6171.c
> @@ -17,10 +17,14 @@
>  #include <net/dsa.h>
>  #include "mv88e6xxx.h"
>  
> -static char *mv88e6171_probe(struct mii_bus *bus, int sw_addr)
> +static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
>  {
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
>  	int ret;
>  
> +	if (bus == NULL)
> +		return NULL;
> +
>  	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
>  	if (ret >= 0) {
>  		if ((ret & 0xfff0) == 0x1710)
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index 901d2a9..d6f6428 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -78,7 +78,7 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
>  	int ret;
>  
>  	mutex_lock(&ps->smi_mutex);
> -	ret = __mv88e6xxx_reg_read(ds->master_mii_bus,
> +	ret = __mv88e6xxx_reg_read(to_mii_bus(ds->master_dev),
>  				   ds->pd->sw_addr, addr, reg);
>  	mutex_unlock(&ps->smi_mutex);
>  
> @@ -122,7 +122,7 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
>  	int ret;
>  
>  	mutex_lock(&ps->smi_mutex);
> -	ret = __mv88e6xxx_reg_write(ds->master_mii_bus,
> +	ret = __mv88e6xxx_reg_write(to_mii_bus(ds->master_dev),
>  				    ds->pd->sw_addr, addr, reg, val);
>  	mutex_unlock(&ps->smi_mutex);
>  
> diff --git a/include/net/dsa.h b/include/net/dsa.h
> index a55c4e6..c779e9b 100644
> --- a/include/net/dsa.h
> +++ b/include/net/dsa.h
> @@ -34,7 +34,7 @@ struct dsa_chip_data {
>  	/*
>  	 * How to access the switch configuration registers.
>  	 */
> -	struct device	*mii_bus;
> +	struct device	*host_dev;
>  	int		sw_addr;
>  
>  	/* Device tree node pointer for this specific switch chip
> @@ -134,9 +134,9 @@ struct dsa_switch {
>  	struct dsa_switch_driver	*drv;
>  
>  	/*
> -	 * Reference to mii bus to use.
> +	 * Reference to host device to use.
>  	 */
> -	struct mii_bus		*master_mii_bus;
> +	struct device		*master_dev;
>  
>  	/*
>  	 * Slave mii_bus and devices for the individual ports.
> @@ -178,7 +178,7 @@ struct dsa_switch_driver {
>  	/*
>  	 * Probing and setup.
>  	 */
> -	char	*(*probe)(struct mii_bus *bus, int sw_addr);
> +	char	*(*probe)(struct device *host_dev, int sw_addr);
>  	int	(*setup)(struct dsa_switch *ds);
>  	int	(*set_addr)(struct dsa_switch *ds, u8 *addr);
>  
> @@ -213,6 +213,7 @@ struct dsa_switch_driver {
>  
>  void register_switch_driver(struct dsa_switch_driver *type);
>  void unregister_switch_driver(struct dsa_switch_driver *type);
> +struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
>  
>  static inline void *ds_to_priv(struct dsa_switch *ds)
>  {
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 1df0a7c..b34d697 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -43,7 +43,7 @@ void unregister_switch_driver(struct dsa_switch_driver *drv)
>  EXPORT_SYMBOL_GPL(unregister_switch_driver);
>  
>  static struct dsa_switch_driver *
> -dsa_switch_probe(struct mii_bus *bus, int sw_addr, char **_name)
> +dsa_switch_probe(struct device *host_dev, int sw_addr, char **_name)
>  {
>  	struct dsa_switch_driver *ret;
>  	struct list_head *list;
> @@ -58,7 +58,7 @@ dsa_switch_probe(struct mii_bus *bus, int sw_addr, char **_name)
>  
>  		drv = list_entry(list, struct dsa_switch_driver, list);
>  
> -		name = drv->probe(bus, sw_addr);
> +		name = drv->probe(host_dev, sw_addr);
>  		if (name != NULL) {
>  			ret = drv;
>  			break;
> @@ -75,7 +75,7 @@ dsa_switch_probe(struct mii_bus *bus, int sw_addr, char **_name)
>  /* basic switch operations **************************************************/
>  static struct dsa_switch *
>  dsa_switch_setup(struct dsa_switch_tree *dst, int index,
> -		 struct device *parent, struct mii_bus *bus)
> +		 struct device *parent, struct device *host_dev)
>  {
>  	struct dsa_chip_data *pd = dst->pd->chip + index;
>  	struct dsa_switch_driver *drv;
> @@ -88,7 +88,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  	/*
>  	 * Probe for switch model.
>  	 */
> -	drv = dsa_switch_probe(bus, pd->sw_addr, &name);
> +	drv = dsa_switch_probe(host_dev, pd->sw_addr, &name);
>  	if (drv == NULL) {
>  		printk(KERN_ERR "%s[%d]: could not detect attached switch\n",
>  		       dst->master_netdev->name, index);
> @@ -109,8 +109,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
>  	ds->index = index;
>  	ds->pd = dst->pd->chip + index;
>  	ds->drv = drv;
> -	ds->master_mii_bus = bus;
> -
> +	ds->master_dev = host_dev;
>  
>  	/*
>  	 * Validate supplied switch configuration.
> @@ -285,7 +284,7 @@ static struct device *dev_find_class(struct device *parent, char *class)
>  	return device_find_child(parent, class, dev_is_class);
>  }
>  
> -static struct mii_bus *dev_to_mii_bus(struct device *dev)
> +struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
>  {
>  	struct device *d;
>  
> @@ -301,6 +300,7 @@ static struct mii_bus *dev_to_mii_bus(struct device *dev)
>  
>  	return NULL;
>  }
> +EXPORT_SYMBOL_GPL(dsa_host_dev_to_mii_bus);
>  
>  static struct net_device *dev_to_net_device(struct device *dev)
>  {
> @@ -566,17 +566,9 @@ static int dsa_probe(struct platform_device *pdev)
>  	dst->cpu_port = -1;
>  
>  	for (i = 0; i < pd->nr_chips; i++) {
> -		struct mii_bus *bus;
>  		struct dsa_switch *ds;
>  
> -		bus = dev_to_mii_bus(pd->chip[i].mii_bus);
> -		if (bus == NULL) {
> -			printk(KERN_ERR "%s[%d]: no mii bus found for "
> -				"dsa switch\n", dev->name, i);
> -			continue;
> -		}
> -
> -		ds = dsa_switch_setup(dst, i, &pdev->dev, bus);
> +		ds = dsa_switch_setup(dst, i, &pdev->dev, pd->chip[i].host_dev);
>  		if (IS_ERR(ds)) {
>  			printk(KERN_ERR "%s[%d]: couldn't create dsa switch "
>  				"instance (error %ld)\n", dev->name, i,
> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
> index e38a331..90c9689 100644
> --- a/net/dsa/slave.c
> +++ b/net/dsa/slave.c
> @@ -44,7 +44,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
>  	ds->slave_mii_bus->write = dsa_slave_phy_write;
>  	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d:%.2x",
>  			ds->index, ds->pd->sw_addr);
> -	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
> +	ds->slave_mii_bus->parent = ds->master_dev;
>  }
>  
>  
> 
