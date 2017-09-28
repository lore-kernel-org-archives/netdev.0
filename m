From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time
 as a PTP hardware clock
Date: Thu, 28 Sep 2017 19:03:29 +0200
Message-ID: <20170928170329.GC14940@lunn.ch>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/* The 32-bit timestamp counter overflows every ~34.3 seconds; this task
> + * forces periodic reads so that we don't miss any wraparounds.
> + */
> +#define MV88E6XXX_TAI_OVERFLOW_PERIOD (34 * HZ / 2)
> +static void mv88e6xxx_ptp_overflow_check(struct work_struct *work)
> +{
> +	struct delayed_work *dw = to_delayed_work(work);
> +	struct mv88e6xxx_chip *chip =
> +		container_of(dw, struct mv88e6xxx_chip, overflow_work);
> +	bool timeout = time_is_before_jiffies(chip->last_overflow_check +
> +					      MV88E6XXX_TAI_OVERFLOW_PERIOD);
> +
> +	if (timeout) {

Why do you need this timeout? Do you think the kernel will call this
more often than required?

Also, if it did call this function early, you skip the read, and
reschedule. There is then a danger the next read is after the
wraparound.....

> +		mutex_lock(&chip->reg_lock);
> +		timecounter_read(&chip->tstamp_tc);
> +		chip->last_overflow_check = jiffies;
> +		mutex_unlock(&chip->reg_lock);
> +	}
> +
> +	schedule_delayed_work(&chip->overflow_work,
> +			      MV88E6XXX_TAI_OVERFLOW_PERIOD);
> +}

Thanks
	Andrew
