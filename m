From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 2/6] Create new file ksz9477.c from KSZ9477 code in
 ksz_common.c
Date: Thu, 7 Sep 2017 23:32:42 +0200
Message-ID: <20170907213242.GR11248@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218CF@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A06@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A06@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2017 at 09:09:04PM +0000, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Create new ksz9477.c file from original ksz_common.c.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/drivers/net/dsa/microchip/ksz9477.c b/drivers/net/dsa/microchip/ksz9477.c
> new file mode 100644
> index 0000000..bc722b4
> --- /dev/null
> +++ b/drivers/net/dsa/microchip/ksz9477.c
> @@ -0,0 +1,1317 @@
> +/*
> + * Microchip switch driver main logic
> + *
> + * Copyright (C) 2017
> + *
> + * Permission to use, copy, modify, and/or distribute this software for 
> +any
> + * purpose with or without fee is hereby granted, provided that the 
> +above

Tristram

It looks like something hand mangled this comment. "any" and "above"
appear to be on a line on there own.

> + * copyright notice and this permission notice appear in all copies.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL 
> +WARRANTIES
> + * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
> + * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE 
> +FOR
> + * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY 
> +DAMAGES
> + * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN 
> +AN
> + * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT 
> +OF
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
> +#include "ksz_9477_reg.h"
> +
> +static const struct {
> +	int index;
> +	char string[ETH_GSTRING_LEN];
> +} mib_names[TOTAL_SWITCH_COUNTER_NUM] = {
> +	{ 0x00, "rx_hi" },
> +	{ 0x01, "rx_undersize" },
> +	{ 0x02, "rx_fragments" },
> +	{ 0x03, "rx_oversize" },
> +	{ 0x04, "rx_jabbers" },
> +	{ 0x05, "rx_symbol_err" },
> +	{ 0x06, "rx_crc_err" },
> +	{ 0x07, "rx_align_err" },
> +	{ 0x08, "rx_mac_ctrl" },
> +	{ 0x09, "rx_pause" },
> +	{ 0x0A, "rx_bcast" },
> +	{ 0x0B, "rx_mcast" },
> +	{ 0x0C, "rx_ucast" },
> +	{ 0x0D, "rx_64_or_less" },
> +	{ 0x0E, "rx_65_127" },
> +	{ 0x0F, "rx_128_255" },
> +	{ 0x10, "rx_256_511" },
> +	{ 0x11, "rx_512_1023" },
> +	{ 0x12, "rx_1024_1522" },
> +	{ 0x13, "rx_1523_2000" },
> +	{ 0x14, "rx_2001" },
> +	{ 0x15, "tx_hi" },
> +	{ 0x16, "tx_late_col" },
> +	{ 0x17, "tx_pause" },
> +	{ 0x18, "tx_bcast" },
> +	{ 0x19, "tx_mcast" },
> +	{ 0x1A, "tx_ucast" },
> +	{ 0x1B, "tx_deferred" },
> +	{ 0x1C, "tx_total_col" },
> +	{ 0x1D, "tx_exc_col" },
> +	{ 0x1E, "tx_single_col" },
> +	{ 0x1F, "tx_mult_col" },
> +	{ 0x80, "rx_total" },
> +	{ 0x81, "tx_total" },
> +	{ 0x82, "rx_discards" },
> +	{ 0x83, "tx_discards" },
> +};
> +
> +static void ksz_cfg(struct ksz_device *dev, u32 addr, u8 bits, bool 
> +set) {

More mangling? Should set be on the end of the previous line?

> +static void read_table(struct dsa_switch *ds, u32 *table) {
> +	struct ksz_device *dev = ds->priv;
> +
> +	ksz_read32(dev, REG_SW_ALU_VAL_A, &table[0]);
> +	ksz_read32(dev, REG_SW_ALU_VAL_B, &table[1]);
> +	ksz_read32(dev, REG_SW_ALU_VAL_C, &table[2]);
> +	ksz_read32(dev, REG_SW_ALU_VAL_D, &table[3]); }
> +
> +static void write_table(struct dsa_switch *ds, u32 *table) {
> +	struct ksz_device *dev = ds->priv;
> +
> +	ksz_write32(dev, REG_SW_ALU_VAL_A, table[0]);
> +	ksz_write32(dev, REG_SW_ALU_VAL_B, table[1]);
> +	ksz_write32(dev, REG_SW_ALU_VAL_C, table[2]);
> +	ksz_write32(dev, REG_SW_ALU_VAL_D, table[3]); }

More mangling? } at the end of a line?

I will stop reading now and wait for a v2 this is not corrupt.

  Andrew
