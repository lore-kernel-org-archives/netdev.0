From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] dsa: Fix conversion from host device to mii bus
Date: Fri, 17 Oct 2014 16:40:48 -0700
Message-ID: <5441A900.4030001@gmail.com>
References: <1413574258-21766-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413574258-21766-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2014 12:30 PM, Guenter Roeck wrote:
> Commit b4d2394d01bc ("dsa: Replace mii_bus with a generic host device")
> replaces mii_bus with a generic host_dev, and introduces
> dsa_host_dev_to_mii_bus() to support conversion from host_dev to mii_bus.
> However, in some cases it uses to_mii_bus to perform that conversion.
> Since host_dev is not the phy bus device but typically a platform device,
> this fails and results in a crash with the affected drivers.
> 
> BUG: unable to handle kernel NULL pointer dereference at           (null)
> IP: [<ffffffff81781d35>] __mutex_lock_slowpath+0x75/0x100
> PGD 406783067 PUD 406784067 PMD 0
> Oops: 0002 [#1] SMP
> ...
> Call Trace:
> [<ffffffff810a538b>] ? pick_next_task_fair+0x61b/0x880
> [<ffffffff81781de3>] mutex_lock+0x23/0x37
> [<ffffffff81533244>] mdiobus_read+0x34/0x60
> [<ffffffff8153b95a>] __mv88e6xxx_reg_read+0x8a/0xa0
> [<ffffffff8153b9bc>] mv88e6xxx_reg_read+0x4c/0xa0
> 
> Fixes: b4d2394d01bc ("dsa: Replace mii_bus with a generic host device")
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/dsa/mv88e6060.c | 16 ++++++++++++----
>  drivers/net/dsa/mv88e6xxx.c | 14 ++++++++++----
>  2 files changed, 22 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index 776e965..05b0ca3 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
> @@ -21,8 +21,12 @@
>  
>  static int reg_read(struct dsa_switch *ds, int addr, int reg)
>  {
> -	return mdiobus_read(to_mii_bus(ds->master_dev),
> -			    ds->pd->sw_addr + addr, reg);
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> +
> +	if (bus == NULL)
> +		return -EINVAL;
> +
> +	return mdiobus_read(bus, ds->pd->sw_addr + addr, reg);
>  }
>  
>  #define REG_READ(addr, reg)					\
> @@ -38,8 +42,12 @@ static int reg_read(struct dsa_switch *ds, int addr, int reg)
>  
>  static int reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
>  {
> -	return mdiobus_write(to_mii_bus(ds->master_dev),
> -			     ds->pd->sw_addr + addr, reg, val);
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
> +
> +	if (bus == NULL)
> +		return -EINVAL;
> +
> +	return mdiobus_write(bus, ds->pd->sw_addr + addr, reg, val);
>  }
>  
>  #define REG_WRITE(addr, reg, val)				\
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index d6f6428..a6c90cf 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -75,11 +75,14 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
>  int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
>  	int ret;
>  
> +	if (bus == NULL)
> +		return -EINVAL;
> +
>  	mutex_lock(&ps->smi_mutex);
> -	ret = __mv88e6xxx_reg_read(to_mii_bus(ds->master_dev),
> -				   ds->pd->sw_addr, addr, reg);
> +	ret = __mv88e6xxx_reg_read(bus, ds->pd->sw_addr, addr, reg);
>  	mutex_unlock(&ps->smi_mutex);
>  
>  	return ret;
> @@ -119,11 +122,14 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
>  int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
>  	int ret;
>  
> +	if (bus == NULL)
> +		return -EINVAL;
> +
>  	mutex_lock(&ps->smi_mutex);
> -	ret = __mv88e6xxx_reg_write(to_mii_bus(ds->master_dev),
> -				    ds->pd->sw_addr, addr, reg, val);
> +	ret = __mv88e6xxx_reg_write(bus, ds->pd->sw_addr, addr, reg, val);
>  	mutex_unlock(&ps->smi_mutex);
>  
>  	return ret;
> 
