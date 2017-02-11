From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] qed: Add infrastructure for PTP support.
Date: Sat, 11 Feb 2017 09:58:10 +0100
Message-ID: <20170211085810.GA4006@localhost.localdomain>
References: <1486536194-30872-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, Yuval.Mintz@cavium.com
To: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35585 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753308AbdBKI6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 03:58:15 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so10278284wmu.2
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 00:58:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486536194-30872-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 10:43:13PM -0800, Sudarsana Kalluru wrote:
> +/* Adjust the HW clock by a rate given in parts-per-billion (ppb) units.
> + * FW/HW accepts the adjustment value in terms of 3 parameters:
> + *   Drift period - adjustment happens once in certain number of nano seconds.
> + *   Drift value - time is adjusted by a certain value, for example by 5 ns.
> + *   Drift direction - add or subtract the adjustment value.
> + * The routine translates ppb into the adjustment triplet in an optimal manner.
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
> +	best_dif = ppb;
> +	best_period = 2;
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
> +		for (val = 1; val <= 7; val++) {
> +			period1 = div_s64(val * 1000000000, ppb);

You don't round this, but you should.

> +			period1 -= 8;
> +			period1 >>= 4;

You should round here as well and spare yourself the following two
divisions.

> +			if (period1 < 1)
> +				period1 = 1;
> +			if (period1 > 0xFFFFFFE)
> +				period1 = 0xFFFFFFE;
> +			period2 = period1 + 1;
> +
> +			temp = div_s64(val * 1000000000, (period1 * 16 + 8));
> +			dif1 = ppb - temp;
> +			if (dif1 < 0)
> +				dif1 = -dif1;
> +
> +			temp = div_s64(val * 1000000000, (period2 * 16 + 8));
> +			dif2 = ppb - temp;
> +			if (dif2 < 0)
> +				dif2 = -dif2;
> +
> +			dif = min_t(s64, dif1, dif2);
> +			period = (dif1 < dif2) ? period1 : period2;
> +			if (dif < best_dif) {

Consider testing for (dif <= best) instead.

If I am not mistaken, then you can skip the cases val==2 and val==3,
because they are equivalent to val==4 and 6.

> +				best_dif = dif;
> +				best_val = (int)val;
> +				best_period = (int)period;
> +			}
> +		}
> +	}

Thanks,
Richard
