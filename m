From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 RFC 6/7] Add MIB counter reading support
Date: Mon, 9 Oct 2017 13:07:34 -0700
Message-ID: <eeac17e3-b026-707f-cdf3-dfdcadf49947@gmail.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-7-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com, Andrew Lunn <andrew@lunn.ch>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-7-git-send-email-Tristram.Ha@microchip.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/06/2017 01:33 PM, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Add MIB counter reading support.
> Rename ksz_9477_reg.h to ksz9477_reg.h for consistency as the product
> name is always KSZ####.
> Header file ksz_priv.h no longer contains any chip specific data.

You should probably explain in the commit message that you are adding a
timer that reads counters every 30 seconds to avoid overflows, as this
is a pretty important piece of information.


> +static void ksz9477_phy_setup(struct ksz_device *dev, int port,
> +			      struct phy_device *phy)
> +{
> +	if (port < dev->phy_port_cnt) {
> +		/* SUPPORTED_Asym_Pause and SUPPORTED_Pause can be removed to
> +		 * disable flow control when rate limiting is used.
> +		 */
> +		phy->advertising = phy->supported;
> +	}
> +}

This appears to be an unrelated change here that you would want to put
in a separate patch.

> +
>  static void ksz9477_port_setup(struct ksz_device *dev, int port, bool cpu_port)
>  {
>  	u8 data8;
> @@ -1159,6 +1198,8 @@ static int ksz9477_setup(struct dsa_switch *ds)
>  	/* start switch */
>  	ksz_cfg(dev, REG_SW_OPERATION, SW_START, true);
>  
> +	ksz_init_mib_timer(dev);
> +
>  	return 0;
>  }
>  
> @@ -1168,6 +1209,7 @@ static int ksz9477_setup(struct dsa_switch *ds)
>  	.set_addr		= ksz9477_set_addr,
>  	.phy_read		= ksz9477_phy_read16,
>  	.phy_write		= ksz9477_phy_write16,
> +	.adjust_link		= ksz_adjust_link,
>  	.port_enable		= ksz_enable_port,
>  	.port_disable		= ksz_disable_port,
>  	.get_strings		= ksz9477_get_strings,
> @@ -1289,6 +1331,7 @@ static int ksz9477_switch_init(struct ksz_device *dev)
>  	if (!dev->ports)
>  		return -ENOMEM;
>  	for (i = 0; i < dev->mib_port_cnt; i++) {
> +		mutex_init(&dev->ports[i].mib.cnt_mutex);
>  		dev->ports[i].mib.counters =
>  			devm_kzalloc(dev->dev,
>  				     sizeof(u64) *
> @@ -1310,7 +1353,12 @@ static void ksz9477_switch_exit(struct ksz_device *dev)
>  	.get_port_addr = ksz9477_get_port_addr,
>  	.cfg_port_member = ksz9477_cfg_port_member,
>  	.flush_dyn_mac_table = ksz9477_flush_dyn_mac_table,
> +	.phy_setup = ksz9477_phy_setup,
>  	.port_setup = ksz9477_port_setup,
> +	.r_mib_cnt = ksz9477_r_mib_cnt,
> +	.r_mib_pkt = ksz9477_r_mib_pkt,
> +	.freeze_mib = ksz9477_freeze_mib,
> +	.port_init_cnt = ksz9477_port_init_cnt,
>  	.shutdown = ksz9477_reset_switch,
>  	.detect = ksz9477_switch_detect,
>  	.init = ksz9477_switch_init,
> diff --git a/drivers/net/dsa/microchip/ksz_9477_reg.h b/drivers/net/dsa/microchip/ksz9477_reg.h
> similarity index 100%
> rename from drivers/net/dsa/microchip/ksz_9477_reg.h
> rename to drivers/net/dsa/microchip/ksz9477_reg.h
> diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
> index 1c9c4c5..885b3e3 100644
> --- a/drivers/net/dsa/microchip/ksz_common.c
> +++ b/drivers/net/dsa/microchip/ksz_common.c
> @@ -50,6 +50,81 @@ void ksz_update_port_member(struct ksz_device *dev, int port)
>  	}
>  }
>  
> +static void port_r_cnt(struct ksz_device *dev, int port)
> +{
> +	struct ksz_port_mib *mib = &dev->ports[port].mib;
> +	u64 *dropped;
> +
> +	/* Some ports may not have MIB counters before SWITCH_COUNTER_NUM. */
> +	while (mib->cnt_ptr < dev->reg_mib_cnt) {
> +		dev->dev_ops->r_mib_cnt(dev, port, mib->cnt_ptr,
> +					&mib->counters[mib->cnt_ptr]);
> +		++mib->cnt_ptr;
> +	}
> +
> +	/* last one in storage */
> +	dropped = &mib->counters[dev->mib_cnt];
> +
> +	/* Some ports may not have MIB counters after SWITCH_COUNTER_NUM. */
> +	while (mib->cnt_ptr < dev->mib_cnt) {
> +		dev->dev_ops->r_mib_pkt(dev, port, mib->cnt_ptr,
> +					dropped, &mib->counters[mib->cnt_ptr]);
> +		++mib->cnt_ptr;
> +	}
> +	mib->cnt_ptr = 0;
> +}
> +
> +static void ksz_mib_read_work(struct work_struct *work)
> +{
> +	struct ksz_device *dev =
> +		container_of(work, struct ksz_device, mib_read);
> +	struct ksz_port *p;
> +	struct ksz_port_mib *mib;
> +	int i;
> +
> +	for (i = 0; i < dev->mib_port_cnt; i++) {
> +		p = &dev->ports[i];
> +		if (!p->on)
> +			continue;
> +		mib = &p->mib;
> +		mutex_lock(&mib->cnt_mutex);
> +
> +		/* read only dropped counters when link is not up */
> +		if (p->link_down)
> +			p->link_down = 0;
> +		else if (!p->link_up)
> +			mib->cnt_ptr = dev->reg_mib_cnt;

Can't you just check the ports' PHY device here instead of caching that
(which can get out of sync)?


> +void ksz_adjust_link(struct dsa_switch *ds, int port,
> +		     struct phy_device *phydev)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	struct ksz_port *p = &dev->ports[port];
> +
> +	if (phydev->link) {
> +		p->speed = phydev->speed;
> +		p->duplex = phydev->duplex;
> +		p->flow_ctrl = phydev->pause;
> +		p->link_up = 1;
> +		dev->live_ports |= (1 << port) & dev->on_ports;
> +	} else if (p->link_up) {
> +		p->link_up = 0;
> +		p->link_down = 1;
> +		dev->live_ports &= ~(1 << port);
> +	}
> +}

It would have been nice to explain why this is needed in the commit
message. dev->live_ports is read-only it seems?
-- 
Florian
