From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 12/12] net: dsa: mv88e6xxx: add support
 for DSA ageing time
Date: Mon, 18 Jul 2016 21:16:44 +0200
Message-ID: <20160718191644.GG31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-13-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 02:46:28PM -0400, Vivien Didelot wrote:
> Implement the DSA driver function to configure the bridge ageing time.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 14 ++++++++++++++
>  1 file changed, 14 insertions(+)
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index e2627a8..2101241 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -3002,6 +3002,19 @@ static int mv88e6xxx_g1_set_age_time(struct mv88e6xxx_chip *chip,
>  	return mv88e6xxx_write(chip, REG_GLOBAL, GLOBAL_ATU_CONTROL, val);
>  }
>  
> +static int mv88e6xxx_set_ageing_time(struct dsa_switch *ds,
> +				     unsigned int ageing_time)
> +{
> +	struct mv88e6xxx_chip *chip = ds_to_priv(ds);
> +	int err;
> +
> +	mutex_lock(&chip->reg_lock);
> +	err = mv88e6xxx_g1_set_age_time(chip, ageing_time);
> +	mutex_unlock(&chip->reg_lock);
> +
> +	return err;
> +}
> +
>  static int mv88e6xxx_g1_setup(struct mv88e6xxx_chip *chip)
>  {
>  	struct dsa_switch *ds = chip->ds;
> @@ -3985,6 +3998,7 @@ static struct dsa_switch_driver mv88e6xxx_switch_driver = {
>  	.set_eeprom		= mv88e6xxx_set_eeprom,
>  	.get_regs_len		= mv88e6xxx_get_regs_len,
>  	.get_regs		= mv88e6xxx_get_regs,
> +	.set_ageing_time	= mv88e6xxx_set_ageing_time,
>  	.port_bridge_join	= mv88e6xxx_port_bridge_join,
>  	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
>  	.port_stp_state_set	= mv88e6xxx_port_stp_state_set,

Hi Vivien

This is way too simplistic.

The switchdev call is per port. This manipulates the whole switch. We
need to somehow handle the difference.

I've not look at the bridge code, but i assume it initially sets each
port to a long age time, probably 5 minutes. When there is a topology
change, it enables fast ageing by setting a shorter age time in each
port. After a while it will return to the default age time. Although
the switchdev call is per port, i think the age time is a property of
the bridge, not a port.

For the Marvell devices, we only have a global setting. It will apply
to all bridges we create on the switch. So if one bridge requests fast
ageing, we need to apply it to all bridges. We should only go back to
slow ageing when all bridges are out of fast ageing. That is, we need
some sort of reference counting.

I'm not sure we have enough information to know why the bridge changed
the age timing. Did the use change the forwarding delay, or have we
entered fast ageing? So i think for Marvell devices, we need an
additional property passed down. Is this a fast or a slow age time?
We can then determine what is the fastest fast ageing, and the fastest
slow ageing is, perform reference counting as appropriate, and set the
global setting as needed.

       Andrew
