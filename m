From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v5 3/4] net: phy: Allow pre-declaration of MDIO
 devices
Date: Mon, 6 Feb 2017 15:04:43 +0100
Message-ID: <20170206140443.GH32506@lunn.ch>
References: <20170204210245.14812-1-f.fainelli@gmail.com>
 <20170204210245.14812-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170204210245.14812-4-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/**
> + * mdio_register_board_info - register MDIO devices for a given board
> + * @info: array of devices descriptors
> + * @n: number of descriptors provided
> + * Context: can sleep
> + *
> + * The board info passed can be marked with __initdata but be pointers
> + * such as platform_data etc. are copied as-is
> + */
> +int mdiobus_register_board_info(const struct mdio_board_info *info,
> +				unsigned int n)
> +{
> +	struct mdio_board_entry *be;
> +	unsigned int i;
> +
> +	be = kcalloc(n, sizeof(*be), GFP_KERNEL);
> +	if (!be)
> +		return -ENOMEM;
> +
> +	for (i = 0; i < n; i++, be++, info++) {
> +		memcpy(&be->board_info, info, sizeof(*info));
> +		mutex_lock(&mdio_board_lock);
> +		list_add_tail(&be->list, &mdio_board_list);
> +		mutex_unlock(&mdio_board_lock);
> +	}
> +
> +	return 0;

Hi Florian

I've recently been playing with a hot-pluggable SPI bus controller. It
is a USB device, hence can come and go. On the SPI bus i have an
SRAM. On order to instantiate the MTD device, i need SPI board info. I
cannot add the board info until after the SPI bus master appears,
since i need to know its ID to fill in the board info. At the moment,
i have udev script which when the SPI bus master appears loads a
little kernel module which registers the board info.

Such a scheme will not work here. You need to iterate the list of MDIO
devices at the end of mdiobus_register_board_info() to see if the just
registered board info applies to any existing MDIO bus.

I don't think we yet have any hardware which would do this. But there
have been patches to one of the USB-Ethernet dongles to allow it run
without a PHY. My guess is, to allow an SFP module. But it is not too
big a step for somebody to make a USB attached Ethernet switch.

Maybe consider adding this functionality? Also an unregister call?

      Andrew
