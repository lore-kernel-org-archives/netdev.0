From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 10/26] phy: add I2C mdio bus
Date: Tue, 08 Dec 2015 10:15:08 -0800
Message-ID: <56671E2C.4000508@gmail.com>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk> <E1a5zje-00075T-LA@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35903 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbbLHSPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 13:15:16 -0500
Received: by pacdm15 with SMTP id dm15so15663953pac.3
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 10:15:16 -0800 (PST)
In-Reply-To: <E1a5zje-00075T-LA@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/15 09:38, Russell King wrote:
> Add an I2C MDIO bus bridge library, to allow phylib to access PHYs which
> are connected to an I2C bus instead of the more conventional MDIO bus.
> Such PHYs can be found in SFP adapters and SFF modules.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
[snip]
> +static int i2c_mii_read(struct mii_bus *bus, int phy_id, int reg)
> +{
> +	struct i2c_adapter *i2c = bus->priv;
> +	struct i2c_msg msgs[2];
> +	u8 data[2], dev_addr = reg;
> +	int bus_addr, ret;
> +
> +	bus_addr = 0x40 + phy_id;
> +	if (bus_addr == 0x50 || bus_addr == 0x51)
> +		return 0xffff;

These could deserve a local definition for these specific addresses so
we know why there is such logic here.

> +
> +	msgs[0].addr = bus_addr;
> +	msgs[0].flags = 0;
> +	msgs[0].len = 1;
> +	msgs[0].buf = &dev_addr;
> +	msgs[1].addr = bus_addr;
> +	msgs[1].flags = I2C_M_RD;
> +	msgs[1].len = sizeof(data);
> +	msgs[1].buf = data;
> +
> +	ret = i2c_transfer(i2c, msgs, ARRAY_SIZE(msgs));
> +	if (ret != ARRAY_SIZE(msgs))
> +		return 0xffff;
> +
> +	return data[0] << 8 | data[1];
> +}
> +
> +static int i2c_mii_write(struct mii_bus *bus, int phy_id, int reg, u16 val)
> +{
> +	struct i2c_adapter *i2c = bus->priv;
> +	struct i2c_msg msg;
> +	int bus_addr, ret;
> +	u8 data[3];
> +
> +	bus_addr = 0x40 + phy_id;
> +	if (bus_addr == 0x50 || bus_addr == 0x51)
> +		return 0;

Same here.
-- 
Florian
