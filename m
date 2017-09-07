From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 8 Sep 2017 00:36:25 +0200
Message-ID: <20170907223625.GW11248@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2017 at 09:17:16PM +0000, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Add KSZ8795 switch support with function code.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/drivers/net/dsa/microchip/ksz8795.c b/drivers/net/dsa/microchip/ksz8795.c
> new file mode 100644
> index 0000000..e4d4e6a
> --- /dev/null
> +++ b/drivers/net/dsa/microchip/ksz8795.c
> @@ -0,0 +1,2066 @@
> +/*
> + * Microchip KSZ8795 switch driver
> + *
> + * Copyright (C) 2017 Microchip Technology Inc.
> + *	Tristram Ha <Tristram.Ha@microchip.com>
> + *
> + * Permission to use, copy, modify, and/or distribute this software for any
> + * purpose with or without fee is hereby granted, provided that the above
> + * copyright notice and this permission notice appear in all copies.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
> + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
> + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
> + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
> + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
> + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
> + * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
> + */
> +
> +#include <linux/delay.h>
> +#include <linux/export.h>
> +#include <linux/gpio.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/platform_data/microchip-ksz.h>
> +#include <linux/phy.h>
> +#include <linux/etherdevice.h>
> +#include <linux/if_bridge.h>
> +#include <net/dsa.h>
> +#include <net/switchdev.h>
> +
> +#include "ksz_priv.h"
> +#include "ksz8795.h"
> +
> +/**
> + * Some counters do not need to be read too often because they are less likely
> + * to increase much.
> + */

What does comment mean? Are you caching statistics, and updating
different values at different rates?

> +static const struct {
> +	int interval;
> +	char string[ETH_GSTRING_LEN];
> +} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
> +	{ 1, "rx_hi" },
> +	{ 4, "rx_undersize" },
> +	{ 4, "rx_fragments" },
> +	{ 4, "rx_oversize" },
> +	{ 4, "rx_jabbers" },
> +	{ 4, "rx_symbol_err" },
> +	{ 4, "rx_crc_err" },
> +	{ 4, "rx_align_err" },
> +	{ 4, "rx_mac_ctrl" },
> +	{ 1, "rx_pause" },
> +	{ 1, "rx_bcast" },
> +	{ 1, "rx_mcast" },
> +	{ 1, "rx_ucast" },
> +	{ 2, "rx_64_or_less" },
> +	{ 2, "rx_65_127" },
> +	{ 2, "rx_128_255" },
> +	{ 2, "rx_256_511" },
> +	{ 2, "rx_512_1023" },
> +	{ 2, "rx_1024_1522" },
> +	{ 2, "rx_1523_2000" },
> +	{ 2, "rx_2001" },
> +	{ 1, "tx_hi" },
> +	{ 4, "tx_late_col" },
> +	{ 1, "tx_pause" },
> +	{ 1, "tx_bcast" },
> +	{ 1, "tx_mcast" },
> +	{ 1, "tx_ucast" },
> +	{ 4, "tx_deferred" },
> +	{ 4, "tx_total_col" },
> +	{ 4, "tx_exc_col" },
> +	{ 4, "tx_single_col" },
> +	{ 4, "tx_mult_col" },
> +	{ 1, "rx_total" },
> +	{ 1, "tx_total" },
> +	{ 2, "rx_discards" },
> +	{ 2, "tx_discards" },
> +};
> +
> +static void ksz_cfg(struct ksz_device *dev, u32 addr, u8 bits, bool set)
> +{
> +	u8 data;
> +
> +	ksz_read8(dev, addr, &data);
> +	if (set)
> +		data |= bits;
> +	else
> +		data &= ~bits;
> +	ksz_write8(dev, addr, data);
> +}

Shouldn't this function be in the shared code? There is an exact copy
currently in ksz_common.c.

> +static void ksz_port_cfg(struct ksz_device *dev, int port, int offset, u8 bits,
> +			 bool set)
> +{
> +	u32 addr;
> +	u8 data;
> +
> +	addr = PORT_CTRL_ADDR(port, offset);
> +	ksz_read8(dev, addr, &data);
> +
> +	if (set)
> +		data |= bits;
> +	else
> +		data &= ~bits;
> +
> +	ksz_write8(dev, addr, data);
> +}

And this also appears to be shared.

> +static void port_r_mib_cnt(struct ksz_device *dev, int port, u16 addr, u64 *cnt)

It would be good to use the ksz8795_ prefix for functions specific to
the KSZ8795.

> +{
> +	u32 data;
> +	u16 ctrl_addr;
> +	u8 check;
> +	int timeout;
> +
> +	ctrl_addr = addr + SWITCH_COUNTER_NUM * port;
> +
> +	ctrl_addr |= IND_ACC_TABLE(TABLE_MIB | TABLE_READ);
> +	mutex_lock(&dev->stats_mutex);
> +	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
> +
> +	for (timeout = 1; timeout > 0; timeout--) {

A rather short timeount!

> +		ksz_read8(dev, REG_IND_MIB_CHECK, &check);
> +
> +		if (check & MIB_COUNTER_VALID) {
> +			ksz_read32(dev, REG_IND_DATA_LO, &data);
> +			if (check & MIB_COUNTER_OVERFLOW)
> +				*cnt += MIB_COUNTER_VALUE + 1;
> +			*cnt += data & MIB_COUNTER_VALUE;
> +			break;
> +		}

Should there be a dev_err() here about timing out?


> +	}
> +	mutex_unlock(&dev->stats_mutex);
> +}
> +
> +static int valid_dyn_entry(struct ksz_device *dev, u8 *data)
> +{
> +	int timeout = 100;
> +
> +	do {
> +		ksz_read8(dev, REG_IND_DATA_CHECK, data);
> +		timeout--;
> +	} while ((*data & DYNAMIC_MAC_TABLE_NOT_READY) && timeout);
> +
> +	/* Entry is not ready for accessing. */
> +	if (*data & DYNAMIC_MAC_TABLE_NOT_READY) {
> +		return 1;

Use standard error code. -ETIMEOUT

> +	/* Entry is ready for accessing. */
> +	} else {
> +		ksz_read8(dev, REG_IND_DATA_8, data);
> +
> +		/* There is no valid entry in the table. */
> +		if (*data & DYNAMIC_MAC_TABLE_MAC_EMPTY)
> +			return 2;

-EINVAL?

> +	}
> +	return 0;
> +}

It also looks like these return values get propagated further. So you
really should be using error code.

> +static int ksz_r_dyn_mac_table(struct ksz_device *dev, u16 addr, u8 *mac_addr,
> +			       u8 *fid, u8 *src_port, u8 *timestamp,
> +			       u16 *entries)
> +{
> +	u32 data_hi;
> +	u32 data_lo;
> +	u16 ctrl_addr;
> +	int rc;
> +	u8 data;
> +
> +	ctrl_addr = IND_ACC_TABLE(TABLE_DYNAMIC_MAC | TABLE_READ) | addr;
> +
> +	ksz_write16(dev, REG_IND_CTRL_0, ctrl_addr);
> +
> +	rc = valid_dyn_entry(dev, &data);
> +	if (rc == 1) {
> +		if (addr == 0)
> +			*entries = 0;
> +	} else if (rc == 2) {
> +		*entries = 0;
> +	/* At least one valid entry in the table. */
> +	} else {
> +		u64 buf;
> +
> +		dev->ops->get(dev, REG_IND_DATA_HI, &buf, sizeof(buf));
> +		buf = be64_to_cpu(buf);
> +		data_hi = (u32)(buf >> 32);
> +		data_lo = (u32)buf;
> +
> +		/* Check out how many valid entry in the table. */
> +		*entries = (u16)(((((u16)
> +			data & DYNAMIC_MAC_TABLE_ENTRIES_H) <<
> +			DYNAMIC_MAC_ENTRIES_H_S) |
> +			(((data_hi & DYNAMIC_MAC_TABLE_ENTRIES) >>
> +			DYNAMIC_MAC_ENTRIES_S))) + 1);

When i see so many ((((( i think this needs splitting up to make it
readable.

> +
> +		*fid = (u8)((data_hi & DYNAMIC_MAC_TABLE_FID) >>
> +			DYNAMIC_MAC_FID_S);
> +		*src_port = (u8)((data_hi & DYNAMIC_MAC_TABLE_SRC_PORT) >>
> +			DYNAMIC_MAC_SRC_PORT_S);
> +		*timestamp = (u8)((
> +			data_hi & DYNAMIC_MAC_TABLE_TIMESTAMP) >>
> +			DYNAMIC_MAC_TIMESTAMP_S);

Are all the casts needed? Please go through all the code and see about
removing all the unneeded casts.

> +
> +	return rc;
> +}
> +
> +struct alu_struct {
> +	u8	is_static:1;
> +	u8	prio_age:3;
> +	u8	is_override:1;
> +	u8	is_use_fid:1;
> +	u8	port_forward:5;
> +	u8	fid:7;
> +	u8	mac[ETH_ALEN];
> +};
> +
> +static int ksz_r_sta_mac_table(struct ksz_device *dev, u16 addr,
> +			       struct alu_struct *alu)
> +{
> +	u64 data;
> +	u32 data_hi;
> +	u32 data_lo;
> +
> +	ksz_r_table_64(dev, TABLE_STATIC_MAC, addr, &data);
> +	data_hi = data >> 32;
> +	data_lo = (u32)data;
> +	if (data_hi & (STATIC_MAC_TABLE_VALID | STATIC_MAC_TABLE_OVERRIDE)) {
> +		alu->mac[5] = (u8)data_lo;
> +		alu->mac[4] = (u8)(data_lo >> 8);
> +		alu->mac[3] = (u8)(data_lo >> 16);
> +		alu->mac[2] = (u8)(data_lo >> 24);
> +		alu->mac[1] = (u8)data_hi;
> +		alu->mac[0] = (u8)(data_hi >> 8);
> +		alu->port_forward =
> +			(u8)((data_hi & STATIC_MAC_TABLE_FWD_PORTS) >>
> +			STATIC_MAC_FWD_PORTS_S);
> +		alu->is_override =
> +			(data_hi & STATIC_MAC_TABLE_OVERRIDE) ? 1 : 0;
> +		data_hi >>= 1;
> +		alu->is_use_fid = (data_hi & STATIC_MAC_TABLE_USE_FID) ? 1 : 0;
> +		alu->fid = (u8)((data_hi & STATIC_MAC_TABLE_FID) >>
> +			STATIC_MAC_FID_S);
> +		return 0;
> +	}
> +	return -1;

And what does -1 mean?

> +static void ksz_r_phy(struct ksz_device *dev, u16 phy, u16 reg, u16 *val)
> +{
> +	struct ksz_port *port;
> +	u8 ctrl;
> +	u8 restart;
> +	u8 link;
> +	u8 speed;
> +	u8 force;
> +	u8 p = phy;
> +	u16 data = 0;
> +	int processed = true;
> +
> +	port = &dev->ports[p];
> +	switch (reg) {
> +	case PHY_REG_CTRL:
> +		ksz_pread8(dev, p, P_LOCAL_CTRL, &ctrl);
> +		ksz_pread8(dev, p, P_NEG_RESTART_CTRL, &restart);
> +		ksz_pread8(dev, p, P_SPEED_STATUS, &speed);
> +		ksz_pread8(dev, p, P_FORCE_CTRL, &force);
> +		if (restart & PORT_PHY_LOOPBACK)
> +			data |= PHY_LOOPBACK;
> +		if (force & PORT_FORCE_100_MBIT)
> +			data |= PHY_SPEED_100MBIT;
> +		if (!(force & PORT_AUTO_NEG_DISABLE))
> +			data |= PHY_AUTO_NEG_ENABLE;
> +		if (restart & PORT_POWER_DOWN)
> +			data |= PHY_POWER_DOWN;

Same questions i asked Pavel

Is there a way to access the PHY registers over SPI? The datasheet
suggests there is, but it does not say how, as far as i can tell.

Ideally, we want to use just a normal PHY driver.

> +static int ksz_sset_count(struct dsa_switch *ds)
> +{
> +	return TOTAL_SWITCH_COUNTER_NUM;
> +}
> +
> +static void ksz_get_strings(struct dsa_switch *ds, int port, uint8_t *buf)
> +{
> +	int i;
> +
> +	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
> +		memcpy(buf + i * ETH_GSTRING_LEN, mib_names[i].string,
> +		       ETH_GSTRING_LEN);
> +	}
> +}
> +
> +static void ksz_get_ethtool_stats(struct dsa_switch *ds, int port,
> +				  uint64_t *buf)
> +{
> +	struct ksz_device *dev = ds->priv;
> +	struct ksz_port_mib *mib;
> +	struct ksz_port_mib_info *info;
> +	int i;
> +
> +	mib = &dev->ports[port].mib;
> +
> +	spin_lock(&dev->mib_read_lock);
> +	for (i = 0; i < TOTAL_SWITCH_COUNTER_NUM; i++) {
> +		info = &mib->info[i];
> +		buf[i] = info->counter;
> +		info->read_cnt += info->read_max;
> +	}
> +	spin_unlock(&dev->mib_read_lock);
> +
> +	mib->ctrl = 1;
> +	schedule_work(&dev->mib_read);

Humm. I want to take a closer look at this caching code...

> +}
> +
> +static u8 STP_MULTICAST_ADDR[] = {
> +	0x01, 0x80, 0xC2, 0x00, 0x00, 0x00
> +};

This could be const. And this is not python. Global variables don't
need to be all capitals.

     Andrew
