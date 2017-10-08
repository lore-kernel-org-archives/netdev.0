From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 4/9] net: dsa: mv88e6xxx: add support for
 event capture
Date: Sun, 8 Oct 2017 11:06:34 -0400
Message-ID: <20171008150634.hb7nxwbbmi5xff7m@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-5-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-5-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


There are some issues here.

On Thu, Sep 28, 2017 at 10:25:36AM -0500, Brandon Streiff wrote:
> +static int mv88e6xxx_config_periodic_trig(struct mv88e6xxx_chip *chip,
> +					  u32 ns, u16 picos)
> +{
> +	int err;
> +	u16 global_config;
> +
> +	if (picos >= 1000)
> +		return -ERANGE;
> +
> +	/* TRIG generation is in units of 8 ns clock periods. Convert ns
> +	 * and ps into 8 ns clock periods and up to 8000 additional ps
> +	 */
> +	picos += (ns & 0x7) * 1000;
> +	ns = ns >> 3;

Again, the 8 nanosecounds shouldn't be hard coded.

	...

> +	return err;
> +}

> +static void mv88e6xxx_tai_event_work(struct work_struct *ugly)
> +{
> +	struct delayed_work *dw = to_delayed_work(ugly);
> +	struct mv88e6xxx_chip *chip =
> +		container_of(dw, struct mv88e6xxx_chip, tai_event_work);
> +	u16 ev_status[4];
> +	int err;
> +
> +	mutex_lock(&chip->reg_lock);
> +
> +	err = mv88e6xxx_tai_read(chip, MV88E6XXX_TAI_EVENT_STATUS,
> +				 ev_status, ARRAY_SIZE(ev_status));
> +	if (err) {
> +		mutex_unlock(&chip->reg_lock);
> +		return;
> +	}
> +
> +	if (ev_status[0] & MV88E6XXX_TAI_EVENT_STATUS_ERROR)
> +		dev_warn(chip->dev, "missed event capture\n");
> +
> +	if (ev_status[0] & MV88E6XXX_TAI_EVENT_STATUS_VALID) {

Avoid IfOk.

> +		struct ptp_clock_event ev;
> +		u32 raw_ts = ((u32)ev_status[2] << 16) | ev_status[1];
> +
> +		/* Clear the valid bit so the next timestamp can come in */
> +		ev_status[0] &= ~MV88E6XXX_TAI_EVENT_STATUS_VALID;
> +		err = mv88e6xxx_tai_write(chip, MV88E6XXX_TAI_EVENT_STATUS,
> +					  ev_status[0]);
> +
> +		if (ev_status[0] & MV88E6XXX_TAI_EVENT_STATUS_CAP_TRIG) {
> +			/* TAI is configured to timestamp internal events.
> +			 * This will be a PPS event.
> +			 */
> +			ev.type = PTP_CLOCK_PPS;
> +		} else {
> +			/* Otherwise this is an external timestamp */
> +			ev.type = PTP_CLOCK_EXTTS;
> +		}
> +		/* We only have one timestamping channel. */
> +		ev.index = 0;
> +		ev.timestamp = timecounter_cyc2time(&chip->tstamp_tc, raw_ts);
> +
> +		ptp_clock_event(chip->ptp_clock, &ev);
> +	}
> +
> +	mutex_unlock(&chip->reg_lock);
> +
> +	schedule_delayed_work(&chip->tai_event_work, TAI_EVENT_WORK_INTERVAL);
> +}
> +

> +static int mv88e6xxx_ptp_enable_perout(struct mv88e6xxx_chip *chip,
> +				       struct ptp_clock_request *rq, int on)
> +{
> +	struct timespec ts;
> +	u64 ns;
> +	int pin;
> +	int err;
> +
> +	pin = ptp_find_pin(chip->ptp_clock, PTP_PF_PEROUT, rq->extts.index);
> +
> +	if (pin < 0)
> +		return -EBUSY;
> +
> +	ts.tv_sec = rq->perout.period.sec;
> +	ts.tv_nsec = rq->perout.period.nsec;
> +	ns = timespec_to_ns(&ts);
> +
> +	if (ns > U32_MAX)
> +		return -ERANGE;
> +
> +	mutex_lock(&chip->reg_lock);
> +
> +	err = mv88e6xxx_config_periodic_trig(chip, (u32)ns, 0);

Here you ignore the phase of the signal given in the trq->perout.start
field.  That is not what the user expects.  For periodic outputs where
the phase cannot be set, we really would need a new ioctl.

However, in this case, you should just drop this functionality.  I
understand that this works with your adjustable external oscillator,
but we cannot support that in mainline (at least, not yet).

Thanks,
Richard


> +	if (err)
> +		goto out;
> +
> +	if (on) {
> +		err = mv88e6xxx_g2_set_gpio_config(
> +			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_TRIG,
> +			MV88E6XXX_G2_SCRATCH_GPIO_DIR_OUT);
> +	} else {
> +		err = mv88e6xxx_g2_set_gpio_config(
> +			chip, pin, MV88E6XXX_G2_SCRATCH_GPIO_MODE_GPIO,
> +			MV88E6XXX_G2_SCRATCH_GPIO_DIR_IN);
> +	}
> +
> +out:
> +	mutex_unlock(&chip->reg_lock);
> +
> +	return err;
> +}
