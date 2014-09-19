From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next PATCH 28/29] fm10k: Add support for ptp to hw specific
 files
Date: Fri, 19 Sep 2014 09:38:20 +0200
Message-ID: <20140919073820.GA5954@netboy>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
 <20140918224023.10373.11456.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:50632 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbaISHi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 03:38:26 -0400
Received: by mail-we0-f170.google.com with SMTP id u57so2050718wes.15
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 00:38:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140918224023.10373.11456.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 18, 2014 at 06:40:30PM -0400, Alexander Duyck wrote:

> +static s32 fm10k_adjust_systime_pf(struct fm10k_hw *hw, s32 ppb)
> +{
> +	u64 systime_adjust;
> +
> +	/* if sw_addr is not set we don't have switch register access */
> +	if (!hw->sw_addr)
> +		return ppb ? FM10K_ERR_PARAM : 0;
> +
> +	/* we must convert the value from parts per billion to parts per
> +	 * 2^48 cycles.  In addition we can only use the upper 30 bits of
> +	 * the value when making the change so that restricts us futher.
> +	 * The math for this is equivilent to ABS(pps) * 2^40 / 10 ^ 9,

Huh? Converting ppb to parts per 2^48 should be (ppb * 2^48 / 10^9),
shouldn't it?

Did you mean, "we must convert ... to parts per 2^40 cycles" ?

Also, the comment about using the upper 30 bits is not clear. Do you
mean that the hardware ignores the two least significant bits?

> +	 * the function below is roughly ABS(pps) * 2 ^ 31 / 5 ^ 9 which
> +	 * is as close as we can get to the exact value with numbers as
> +	 * small as possible.
> +	 */
> +	systime_adjust = (ppb < 0) ? -ppb : ppb;
> +	systime_adjust <<= 31;
> +	do_div(systime_adjust, 1953125);
> +
> +	/* verify the requested adjustment value is in range */
> +	if (systime_adjust > FM10K_SW_SYSTIME_ADJUST_MASK)
> +		return FM10K_ERR_PARAM;
> +
> +	if (ppb < 0)
> +		systime_adjust |= FM10K_SW_SYSTIME_ADJUST_DIR_NEGATIVE;
> +
> +	fm10k_write_sw_reg(hw, FM10K_SW_SYSTIME_ADJUST, (u32)systime_adjust);
> +
> +	return 0;
> +}

Thanks,
Richard
