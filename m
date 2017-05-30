From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next 3/5] dsa: add DSA switch driver for Microchip
 KSZ9477
Date: Wed, 31 May 2017 00:35:44 +0200
Message-ID: <20170530223544.GB9707@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40AA459F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, davem@davemloft.net,
        UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58932 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750992AbdE3Wfs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 18:35:48 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40AA459F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static int ksz_port_mdb_del(struct dsa_switch *ds, int port,
> +			    const struct switchdev_obj_port_mdb *mdb)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	u32 static_table[4];
> +	u32 data;
> +	int index;
> +	int ret = 0;
> +	u32 mac_hi, mac_lo;
> +
> +	mac_hi = ((mdb->addr[0] << 8) | mdb->addr[1]);
> +	mac_lo = ((mdb->addr[2] << 24) | (mdb->addr[3] << 16));
> +	mac_lo |= ((mdb->addr[4] << 8) | mdb->addr[5]);
> +
> +	mutex_lock(&dev->alu_mutex);
> +
> +	for (index = 0; index < dev->num_statics; index++) {
> +		/* find empty slot first */
> +		data = (index << ALU_STAT_INDEX_S) |
> +			ALU_STAT_READ | ALU_STAT_START;
> +		ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
> +
> +		/* wait to be finished */
> +		ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
> +		if (ret < 0) {
> +			dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
> +			goto exit;
> +		}
> +
> +		/* read ALU static table */
> +		read_table(ds, static_table);
> +
> +		mutex_unlock(&dev->alu_mutex);

Is this mutex unlock here correct? It looks like we will unlock it
again when we eventually get to exit: below.

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
> +		}
> +	}
> +
> +	/* no available entry */
> +	if (index == dev->num_statics) {
> +		ret = -EINVAL;
> +		goto exit;
> +	}
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
> +	write_table(ds, static_table);
> +
> +	data = (index << ALU_STAT_INDEX_S) | ALU_STAT_START;
> +	ksz_write32(dev, REG_SW_ALU_STAT_CTRL__4, data);
> +
> +	/* wait to be finished */
> +	ret = wait_alu_sta_ready(dev, ALU_STAT_START, 1000);
> +	if (ret < 0)
> +		dev_dbg(dev->dev, "Failed to read ALU STATIC\n");
> +
> +exit:
> +	mutex_unlock(&dev->alu_mutex);
> +
> +	return ret;
> +}
