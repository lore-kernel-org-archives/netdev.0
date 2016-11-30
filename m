From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/6] net: dsa: mv88e6xxx: add helper for switch
 ready
Date: Thu, 1 Dec 2016 00:38:10 +0100
Message-ID: <20161130233810.GT21645@lunn.ch>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
 <20161130225930.25510-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161130225930.25510-6-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static int mv88e6xxx_wait_switch_ready(struct mv88e6xxx_chip *chip)
> +{
> +	const unsigned long timeout = jiffies + 1 * HZ;
> +	bool ready;
> +	int err;
> +
> +	/* Wait up to 1 second for switch to be ready.
> +	 * The switch is ready when all units inside the device (ATU, VTU, etc.)
> +	 * have finished their initialization and are ready to accept frames.
> +	 */
> +	while (time_before(jiffies, timeout)) {
> +		err = mv88e6xxx_g1_init_ready(chip, &ready);
> +		if (err)
> +			return err;
> +
> +		if (ready)
> +			break;
> +
> +		usleep_range(1000, 2000);
> +	}
> +
> +	if (time_after(jiffies, timeout))
> +		return -ETIMEDOUT;

As we have seen in the past, this sort of loop is broken if we end up
sleeping for a long time. Please take the opportunity to replace it
with one of our _wait() helpers, e.g. mv88e6xxx_g1_wait()

> +int mv88e6xxx_g1_init_ready(struct mv88e6xxx_chip *chip, bool *ready)
> +{
> +	u16 val;
> +	int err;
> +
> +	/* Check the value of the InitReady bit 11 */
> +	err = mv88e6xxx_g1_read(chip, GLOBAL_STATUS, &val);
> +	if (err)
> +		return err;
> +
> +	*ready = !!(val & GLOBAL_STATUS_INIT_READY);

I would actually do the wait here.

> +
> +	return 0;
> +}
> +

Thanks

  Andrew
