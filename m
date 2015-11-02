From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next] net: dsa: mv88e6xxx: assert SMI lock
Date: Mon, 2 Nov 2015 16:02:18 +0100
Message-ID: <20151102150218.GC7963@lunn.ch>
References: <1446245805-24128-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446245805-24128-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2015 at 06:56:45PM -0400, Vivien Didelot wrote:
> It's easy to forget to lock the smi_mutex before calling the low-level
> _mv88e6xxx_reg_{read,write}, so add a assert_smi_lock function in them.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Acked-by: Andrew Lunn <andrew@lunn.ch>


Since there is no followup fixes patch, i assume we actually have it
correct at the moment?

Thanks
	Andrew

> ---
>  drivers/net/dsa/mv88e6xxx.c | 25 ++++++++++++++-----------
>  1 file changed, 14 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
> index b1b14f5..78a179b 100644
> --- a/drivers/net/dsa/mv88e6xxx.c
> +++ b/drivers/net/dsa/mv88e6xxx.c
> @@ -24,6 +24,16 @@
>  #include <net/switchdev.h>
>  #include "mv88e6xxx.h"
>  
> +static void assert_smi_lock(struct dsa_switch *ds)
> +{
> +	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +
> +	if (unlikely(!mutex_is_locked(&ps->smi_mutex))) {
> +		dev_err(ds->master_dev, "SMI lock not held!\n");
> +		dump_stack();
> +	}
> +}
> +
>  /* If the switch's ADDR[4:0] strap pins are strapped to zero, it will
>   * use all 32 SMI bus addresses on its SMI bus, and all switch registers
>   * will be directly accessible on some {device address,register address}
> @@ -80,12 +90,13 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
>  	return ret & 0xffff;
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
>  {
>  	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
>  	int ret;
>  
> +	assert_smi_lock(ds);
> +
>  	if (bus == NULL)
>  		return -EINVAL;
>  
> @@ -143,12 +154,13 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
>  	return 0;
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg,
>  				u16 val)
>  {
>  	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
>  
> +	assert_smi_lock(ds);
> +
>  	if (bus == NULL)
>  		return -EINVAL;
>  
> @@ -204,7 +216,6 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
>  	return 0;
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
>  {
>  	if (addr >= 0)
> @@ -212,7 +223,6 @@ static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
>  	return 0xffff;
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum,
>  				u16 val)
>  {
> @@ -538,7 +548,6 @@ out:
>  	mutex_unlock(&ps->smi_mutex);
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
>  {
>  	int ret;
> @@ -553,7 +562,6 @@ static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
>  	return -ETIMEDOUT;
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
>  {
>  	int ret;
> @@ -576,7 +584,6 @@ static int _mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
>  	return 0;
>  }
>  
> -/* Must be called with SMI mutex held */
>  static void _mv88e6xxx_stats_read(struct dsa_switch *ds, int stat, u32 *val)
>  {
>  	u32 _val;
> @@ -789,7 +796,6 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
>  	}
>  }
>  
> -/* Must be called with SMI lock held */
>  static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
>  			   u16 mask)
>  {
> @@ -839,14 +845,12 @@ int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
>  			      GLOBAL2_EEPROM_OP_BUSY);
>  }
>  
> -/* Must be called with SMI lock held */
>  static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
>  {
>  	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_ATU_OP,
>  			       GLOBAL_ATU_OP_BUSY);
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
>  					int regnum)
>  {
> @@ -865,7 +869,6 @@ static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
>  	return _mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_SMI_DATA);
>  }
>  
> -/* Must be called with SMI mutex held */
>  static int _mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr,
>  					 int regnum, u16 val)
>  {
> -- 
> 2.6.2
> 
