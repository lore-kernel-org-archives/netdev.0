From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v3 1/2] qed: Add infrastructure for PTP support.
Date: Thu, 2 Feb 2017 13:56:37 +0100
Message-ID: <20170202125637.GA3191@netboy>
References: <1485848869-22834-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485848869-22834-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Yuval.Mintz@cavium.com, tglx@linutronix.de
To: Sudarsana Kalluru <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34102 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdBBM4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 07:56:48 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so3962968wmi.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 04:56:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485848869-22834-2-git-send-email-Sudarsana.Kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(adding tglx on CC)

On Mon, Jan 30, 2017 at 11:47:48PM -0800, Sudarsana Kalluru wrote:
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
> +			period1 = div_s64(val * 1000000000, ppb);
> +			period1 -= 8;
> +			period1 >>= 4;
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

Forgetting the useless val=0 case, this still takes 21 64-bit
divisions on every adjustment.  There must be a better way.

@tglx - Do you have a hint for Sudarsana?

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
