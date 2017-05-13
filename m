From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Sat, 13 May 2017 16:56:09 +0200
Message-ID: <20170513145609.GD14058@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A632C2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        davem@davemloft.net, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57721 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753694AbdEMO4P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 13 May 2017 10:56:15 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A632C2@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int get_vlan_table(struct dsa_switch *ds, u16 vid, u32 *vlan_table)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	u8 data;
> +	int timeout = 1000;
> +
> +	ksz_write16(dev, REG_SW_VLAN_ENTRY_INDEX__2, vid & VLAN_INDEX_M);
> +	ksz_write8(dev, REG_SW_VLAN_CTRL, VLAN_READ | VLAN_START);
> +	/* wait to be cleared */
> +	data = 0;
> +	do {

A blanks line before the comment would be nice.

> +static int ksz_reset_switch(struct dsa_switch *ds)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	u8 data8;
> +	u16 data16;
> +	u32 data32;
> +

...

> +
> +	memset(dev->vlan_cache, 0, sizeof(*dev->vlan_cache) * dev->num_vlans);
> +
> +	return 0;
> +}

> +static int ksz_setup(struct dsa_switch *ds)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	int ret = 0;
> +
> +	dev->vlan_cache = devm_kmalloc_array(dev->dev,
> +					     sizeof(struct vlan_table),
> +					     dev->num_vlans, GFP_KERNEL);

You should check, but i think devm_kmalloc_array sets the allocated
memory to 0. So i don't think you need the memset. If it is needed, i
would move it here, after the check the allocation is successful.


> +static int ksz_enable_port(struct dsa_switch *ds, int port,
> +			   struct phy_device *phy)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	u8 data8;
> +	u16 data16;
> +
> +	ksz_port_cfg(dev, port, REG_PORT_CTRL_0, PORT_MAC_LOOPBACK, false);
> +
> +	/* set back pressure */
> +	ksz_port_cfg(dev, port, REG_PORT_MAC_CTRL_1, PORT_BACK_PRESSURE, true);
> +
> +	/* set flow control */
> +	ksz_port_cfg(dev, port, REG_PORT_CTRL_0,
> +		     PORT_FORCE_TX_FLOW_CTRL | PORT_FORCE_RX_FLOW_CTRL, true);
> +
> +	/* enable boradcast storm limit */

broadcast.

> +static int ksz_port_vlan_dump(struct dsa_switch *ds, int port,
> +			      struct switchdev_obj_port_vlan *vlan,
> +			      int (*cb)(struct switchdev_obj *obj))
> +{
> +	struct ksz_device *dev = ds->priv;
> +	u16 vid;
> +	u16 data;
> +	struct vlan_table *vlan_cache;
> +	int err = 0;
> +
> +	/* use dev->vlan_cache due to lack of searching valid vlan entry */
> +	for (vid = vlan->vid_begin; vid < dev->num_vlans; vid++) {
> +		vlan_cache = &dev->vlan_cache[vid];
> +

I wounder if the vlan cache should be protected my a mutex?

> +	/* wait to be finished */
> +	do {
> +		ksz_read32(dev, REG_SW_ALU_CTRL__4, &data);
> +	} while (data & ALU_START);

Missing timeouts if the hardware stops responding. There are a few
other similar loop i spotted. Please add a timeout for them all. Maybe
add a generic helper function if it makes sense?

> +static void ksz_port_mdb_add(struct dsa_switch *ds, int port,
> +			     const struct switchdev_obj_port_mdb *mdb,
> +			     struct switchdev_trans *trans)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	u32 static_table[4];
> +	u32 data;
> +	int index;
> +	u32 mac_hi, mac_lo;
> +
> +	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
> +	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
> +	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
> +
> +	for (index = 0; index < dev->num_statics; index++) {
> +		mutex_lock(&dev->alu_mutex);
> +
> +		/* find empty slot first */
> +		data = (index << ALU_STAT_INDEX_S) |
> +			ALU_STAT_READ | ALU_STAT_START;
> +		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
> +
> +		/* wait to be finished */
> +		do {
> +			ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
> +		} while (data & ALU_STAT_START);
> +
> +		/* read ALU static table */
> +		read_table(ds, static_table);
> +
> +		mutex_unlock(&dev->alu_mutex);
> +
> +		if (static_table[0] & ALU_V_STATIC_VALID) {
> +			/* check this has same vid & mac address */
> +
> +			if (((static_table[2] >> ALU_V_FID_S) == (mdb->vid)) &&
> +			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
> +			    (static_table[3] == mac_lo)) {
> +				/* found matching one */
> +				break;
> +			}
> +		} else {
> +			/* found empty one */
> +			break;

Since the mutux has been released, could this empty entry be stolen by
some other parallel running thread? It seems like you should keep hold
of the mutex until you have at least marked it as used.

> +		}
> +	}
> +
> +	/* no available entry */
> +	if (index == dev->num_statics)
> +		return;
> +
> +	/* add entry */
> +	static_table[0] = ALU_V_STATIC_VALID;
> +	static_table[1] |= BIT(port);
> +	if (mdb->vid)
> +		static_table[1] |= ALU_V_USE_FID;
> +	static_table[2] = (mdb->vid << ALU_V_FID_S);
> +	static_table[2] |= mac_hi;
> +	static_table[3] = mac_lo;
> +
> +	mutex_lock(&dev->alu_mutex);
> +
> +	write_table(ds, static_table);
> +
> +	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
> +	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
> +
> +	/* wait to be finished */
> +	do {
> +		ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
> +	} while (data & ALU_STAT_START);
> +
> +	mutex_unlock(&dev->alu_mutex);
> +}
> +
> +static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
> +			    const struct switchdev_obj_port_mdb *mdb)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	u32 static_table[4];
> +	u32 data;
> +	int index;
> +	u32 mac_hi, mac_lo;
> +
> +	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
> +	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
> +	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
> +
> +	for (index = 0; index < dev->num_statics; index++) {
> +		mutex_lock(&dev->alu_mutex);
> +
> +		/* find empty slot first */
> +		data = (index << ALU_STAT_INDEX_S) |
> +			ALU_STAT_READ | ALU_STAT_START;
> +		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
> +
> +		/* wait to be finished */
> +		do {
> +			ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
> +		} while (data & ALU_STAT_START);
> +
> +		/* read ALU static table */
> +		read_table(ds, static_table);
> +
> +		mutex_unlock(&dev->alu_mutex);
> +

Here also, i wounder if it is safe the release the mutex and then
later claim it?

> +		if (static_table[0] & ALU_V_STATIC_VALID) {
> +			/* check this has same vid & mac address */
> +
> +			if (((static_table[2] >> ALU_V_FID_S) == (mdb->vid)) &&
> +			    ((static_table[2] & ALU_V_MAC_ADDR_HI) == mac_hi) &&
> +			    (static_table[3] == mac_lo)) {
> +				/* found matching one */
> +				break;
> +			}
> +		}
> +	}
> +
> +	/* no available entry */
> +	if (index == dev->num_statics)
> +		return -EINVAL;
> +
> +	/* clear port */
> +	static_table[1] &= ~BIT(port);
> +
> +	if ((static_table[1] & ALU_V_PORT_MAP) == 0) {
> +		/* delete entry */
> +		static_table[0] = 0;
> +		static_table[1] = 0;
> +		static_table[2] = 0;
> +		static_table[3] = 0;
> +	}
> +
> +	mutex_lock(&dev->alu_mutex);
> +
> +	write_table(ds, static_table);
> +
> +	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
> +	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
> +
> +	/* wait to be finished */
> +	do {
> +		ksz_read32(dev, REG_SW_ALU_STAT_CTRL__4, &data);
> +	} while (data & ALU_STAT_START);
> +
> +	mutex_unlock(&dev->alu_mutex);
> +
> +	return 0;
> +}

> +int ksz_switch_detect(struct ksz_device *dev)
> +{
> +	u8 data8;
> +	u32 id32;
> +	int ret;
> +
> +	/* turn off SPI DO Edge select */
> +	ret = ksz_read8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, &data8);
> +	if (ret)
> +		return ret;
> +
> +	data8 &= ~SPI_AUTO_EDGE_DETECTION;
> +	ret = ksz_write8(dev, REG_SW_GLOBAL_SERIAL_CTRL_0, data8);
> +	if (ret)
> +		return ret;
> +
> +	/* read chip id */
> +	ret = ksz_read32(dev, REG_CHIP_ID0__1, &id32);
> +	if (ret)
> +		return ret;
> +
> +	dev->chip_id = id32;
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL(ksz_switch_detect);
> +
> +int ksz_switch_register(struct ksz_device *dev)
> +{
> +	int ret;
> +
> +	if (dev->pdata) {
> +		dev->chip_id = dev->pdata->chip_id;
> +		dev->enabled_ports = dev->pdata->enabled_ports;
> +	}
> +
> +	if (!dev->chip_id && ksz_switch_detect(dev))
> +		return -EINVAL;

Is there a need for this? Is there silicon with the wrong ID in it?

> +static inline int ksz_spi_read_reg(struct spi_device *spi, u32 reg, u8 *val,
> +				   unsigned int len)

Please leave the compiler to decide if to inline the function. The
same applies everywhere in .c files.

Overall the code is nice, just a few small issues to sort out.

     Andrew
