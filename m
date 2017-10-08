From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time
 as a PTP hardware clock
Date: Sun, 8 Oct 2017 10:52:38 -0400
Message-ID: <20171008145238.wfsc2hd6nul2hedm@localhost>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
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
In-Reply-To: <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:25:34AM -0500, Brandon Streiff wrote:
> +static int mv88e6xxx_ptp_adjfine(struct ptp_clock_info *ptp, long scaled_ppm)
> +{
> +	if (scaled_ppm == 0)
> +		return 0;
> +
> +	return -EOPNOTSUPP;
> +}

We really want to have an adjustable clock here.  More below.

> +int mv88e6xxx_ptp_setup(struct mv88e6xxx_chip *chip)
> +{
> +	/* Set up the cycle counter */
> +	memset(&chip->tstamp_cc, 0, sizeof(chip->tstamp_cc));
> +	chip->tstamp_cc.read	= mv88e6xxx_ptp_clock_read;
> +	chip->tstamp_cc.mask	= CYCLECOUNTER_MASK(32);
> +	/* Raw timestamps are in units of 8-ns clock periods. */
> +	chip->tstamp_cc.mult	= 8;
> +	chip->tstamp_cc.shift	= 0;

First of all, the switch can use an external clock, and so at the very
least, the period should be a macro so that if and when we support the
external clock, the macro may be converted into a variable.

Secondly, the mult/shift should be chosen to allow the finest possible
frequency adjustment.  Here is what I did:

---
#define N 28
#define CC_MULT (8 << N)

int mv88e635x_setup(struct dsa_switch *ds)
{
	struct mv88e6xxx_chip *ps = ds->priv;

	ps->cc.read = mv88e635x_global_time_read;
	ps->cc.mask = CLOCKSOURCE_MASK(32);
	ps->cc.mult = CC_MULT;
	ps->cc.shift = N;
	timecounter_init(&ps->tc, &ps->cc, ktime_to_ns(ktime_get_real()));
	...
}

static int mv88e635x_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
{
	u64 adj;
	u32 diff, mult;
	int neg_adj = 0;
	struct mv88e6xxx_chip *ps =
		container_of(ptp, struct mv88e6xxx_chip, ptp_info);

	if (ppb < 0) {
		neg_adj = 1;
		ppb = -ppb;
	}
	mult = CC_MULT;
	adj = mult;
	adj *= ppb;
	diff = div_u64(adj, 1000000000ULL);

	mutex_lock(&ps->clock_mutex);
	timecounter_read(&ps->tc);
	ps->cc.mult = neg_adj ? mult - diff : mult + diff;
	mutex_unlock(&ps->clock_mutex);

	return 0;
}
---

(This is the legacy adjfreq method, but you can easily convert it into
 the adjfine method.)

Of course, this means that you'll have to drop the periodic output
signal code.

Thanks,
Richard
