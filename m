From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v5 1/2] qed: Add infrastructure for PTP support
Date: Mon, 13 Feb 2017 21:25:50 +0100
Message-ID: <20170213202550.GA3005@localhost.localdomain>
References: <1486993586-16431-1-git-send-email-Yuval.Mintz@cavium.com>
 <1486993586-16431-2-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Sudarsana.Kalluru@cavium.com
To: Yuval Mintz <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35104 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751731AbdBMUZ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 15:25:56 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so202400wmu.2
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 12:25:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1486993586-16431-2-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 03:46:25PM +0200, Yuval Mintz wrote:
> +static int qed_ptp_hw_adjfreq(struct qed_dev *cdev, s32 ppb)
> +{
> +	struct qed_hwfn *p_hwfn = QED_LEADING_HWFN(cdev);
> +	struct qed_ptt *p_ptt = p_hwfn->p_ptp_ptt;
> +	int drift_dir, best_val, best_period;
> +	s64 period, dif, dif2;
> +	u32 drift_ctr_cfg = 0;
> +	s64 best_dif, val;
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
> +		for (val = 7; val > 0; val++) {

This is an endless loop. ------------- ^^^^^

Besides that, this code returns some very strange values.  For
example, for ppb = 100106, 100107, and 100108.  Also ppb = 1...8
all return 0/40.

Trouble with the -= 8?

I can only recommend plotting all of the raw errors and also average
(RMS) error over the nominal interval ppb = 1...500000.


Thanks,
Richard

> +			period = div_s64(val * 1000000000, ppb);
> +			period -= 8;
> +			period >>= 4;
> +			if (period < 1)
> +				period = 1;
> +			if (period > 0xFFFFFFE)
> +				period = 0xFFFFFFE;
> +
> +			/* Check both rounding ends for approximate error */
> +			dif = ppb * (period * 16 + 8) - val * 1000000000;
> +			dif2 = dif + 16 * ppb;
> +
> +			if (dif < 0)
> +				dif = -dif;
> +			if (dif2 < 0)
> +				dif2 = -dif2;
> +			if (dif2 < dif) {
> +				period++;
> +				dif = dif2;
> +			}
> +
> +			/* Track best approximation found so far */
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
