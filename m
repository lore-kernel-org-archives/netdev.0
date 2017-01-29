From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] qed: Add infrastructure for PTP support.
Date: Sun, 29 Jan 2017 16:28:12 +0100
Message-ID: <20170129152812.GB2223@localhost.localdomain>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35989 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750990AbdA2Px5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 10:53:57 -0500
Received: by mail-wm0-f65.google.com with SMTP id r126so71441589wmr.3
        for <netdev@vger.kernel.org>; Sun, 29 Jan 2017 07:52:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 28, 2017 at 11:28:22PM -0800, Sudarsana Kalluru wrote:
> +/* Adjust the HW clock by a rate given in parts-per-million (ppm) units.
> + * FW/HW accepts the adjustment value in terms of 3 parameters:
> + *   Drift period - adjustment happens once in certain number of nano seconds.
> + *   Drift value - time is adjusted by a certain value, for example by 5 ns.
> + *   Drift direction - add or subtract the adjustment value.
> + * The routine translates ppm into the adjustment triplet in an optimal manner.
> + */
> +static int qed_ptp_hw_adjfreq(struct qed_dev *cdev, s32 ppb)
> +{
> +	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
> +	s64 period, period1, period2, dif, dif1, dif2;
> +	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
> +	int drift_dir, best_val, best_period;
> +	s64 best_dif, temp, val;
> +	u32 drift_ctr_cfg = 0;
> +	u32 drift_state;
> +
> +	best_dif = 1000000000;
> +	best_period = 1;
> +	best_val = 0;
> +	drift_dir = 1;
> +
> +	if (ppb < 0) {
> +		ppb = -ppb;
> +		drift_dir = 0;
> +	}
> +
> +	if (ppb == 0) {
> +		/* No clock adjustment required */
> +		best_val = 0;
> +		best_period = 0xFFFFFFF;
> +	} else {
> +		/* Adjustment value is up to +/-7ns, find an optimal value in
> +		 * this range.
> +		 */
> +		for (val = 0; val <= 7; val++) {
> +			period1 = val * 1000000000;
> +			do_div(period1, ppb);

One,

> +			period1 -= 8;
> +			do_div(period1, 16);

two,

> +			if (period1 < 1)
> +				period1 = 1;
> +			if (period1 > 0xFFFFFFE)
> +				period1 = 0xFFFFFFE;
> +			period2 = period1 + 1;
> +
> +			temp = val * 1000000000;
> +			do_div(temp, (period1 * 16 + 8));

three,

> +			dif1 = ppb - temp;
> +			if (dif1 < 0)
> +				dif1 = -dif1;
> +
> +			temp = val * 1000000000;
> +			do_div(temp, (period2 * 16 + 8));

four times seven makes twenty-eight 64 bit divisions per adjustment!

Isn't there a smarter way to do this?

Also, the case where val=0 makes little sense.


Thanks,
Richard

> +			dif2 = ppb - temp;
> +			if (dif2 < 0)
> +				dif2 = -dif2;
> +
> +			dif = min_t(s64, dif1, dif2);
> +			period = (dif1 < dif2) ? period1 : period2;
> +			if (dif < best_dif) {
> +				best_dif = dif;
> +				best_val = (int)val;
> +				best_period = (int)period;
> +			}
> +		}
> +	}
> +
> +	drift_ctr_cfg = (best_period << QED_DRIFT_CNTR_TIME_QUANTA_SHIFT) |
> +			(best_val << QED_DRIFT_CNTR_ADJUSTMENT_SHIFT) |
> +			(drift_dir << QED_DRIFT_CNTR_DIRECTION_SHIFT);
> +
> +	qed_wr(p_hwfn, p_ptt, NIG_REG_TSGEN_RST_DRIFT_CNTR, 0x1);
> +
> +	drift_state = qed_rd(p_hwfn, p_ptt, NIG_REG_TSGEN_RST_DRIFT_CNTR);
> +	if (drift_state & 1) {
> +		qed_wr(p_hwfn, p_ptt, NIG_REG_TSGEN_DRIFT_CNTR_CONF,
> +		       drift_ctr_cfg);
> +	} else {
> +		DP_INFO(p_hwfn, "Drift counter is not reset\n");
> +		return -EINVAL;
> +	}
> +
> +	qed_wr(p_hwfn, p_ptt, NIG_REG_TSGEN_RST_DRIFT_CNTR, 0x0);
> +
> +	return 0;
> +}
