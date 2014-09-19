From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 28/29] fm10k: Add support for ptp to hw specific
 files
Date: Fri, 19 Sep 2014 07:36:56 -0700
Message-ID: <541C3F88.2090004@intel.com>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com> <20140918224023.10373.11456.stgit@ahduyck-bv4.jf.intel.com> <20140919073820.GA5954@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: davem@davemloft.net, nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56839 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756669AbaISOg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 10:36:58 -0400
In-Reply-To: <20140919073820.GA5954@netboy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 12:38 AM, Richard Cochran wrote:
> On Thu, Sep 18, 2014 at 06:40:30PM -0400, Alexander Duyck wrote:
> 
>> +static s32 fm10k_adjust_systime_pf(struct fm10k_hw *hw, s32 ppb)
>> +{
>> +	u64 systime_adjust;
>> +
>> +	/* if sw_addr is not set we don't have switch register access */
>> +	if (!hw->sw_addr)
>> +		return ppb ? FM10K_ERR_PARAM : 0;
>> +
>> +	/* we must convert the value from parts per billion to parts per
>> +	 * 2^48 cycles.  In addition we can only use the upper 30 bits of
>> +	 * the value when making the change so that restricts us futher.
>> +	 * The math for this is equivilent to ABS(pps) * 2^40 / 10 ^ 9,
> 
> Huh? Converting ppb to parts per 2^48 should be (ppb * 2^48 / 10^9),
> shouldn't it?
> 
> Did you mean, "we must convert ... to parts per 2^40 cycles" ?
> 
> Also, the comment about using the upper 30 bits is not clear. Do you
> mean that the hardware ignores the two least significant bits?

So to break it all down.

1.  The hardware provides a value that can be specified in parts per
2^48, however that value spans across 2 registers starting at bit 24 in
the first register.  You can actually make out a bit more if you look at
the end of the patch.  The layout for the registers look something like
this:

 /* Registers contained in BAR 4 for Switch management */
 #define FM10K_SW_SYSTIME_CFG	0x0224C
 #define FM10K_SW_SYSTIME_CFG_ADJUST_MASK	0xFF000000
 #define FM10K_SW_SYSTIME_ADJUST	0x0224D
 #define FM10K_SW_SYSTIME_ADJUST_MASK		0x3FFFFFFF
 #define FM10K_SW_SYSTIME_ADJUST_DIR_NEGATIVE	0x80000000

2.  The value is in 2 ^ 48 units, and the OS wants to give us a value in
parts per billion, not parts per 256 * 2 ^ 40.  So in order to simplify
things I dropped the lower 8 bits and only update
FM10K_SW_SYSTIME_ADJUST register giving me an adjust value multiplied by
256.   So the adjustment value I am using now is:
	(256 / (256 * (2 ^ 40)))
		this simplifies down to
	1 / (2 ^ 40)

The value 1 / (2 ^ 40) implies that we are still looking at something
close to parts per trillion, however since I am now only adjusting one
register instead of 2 it meets my needs since those lower 8 bits are an
even smaller part of the whole.

3.  The last bit in the adjustment is to deal with the the fact that we
have a power of 2, not a power of 10 and the adjustments are in parts
per billion.  So we would need to convert by 1024 ^ 3 / 1000 ^ 3.  So
the whole thing broken down would be:
	value / (10 ^ 9) == adj_val / (2 ^ 40)
		so if I solve for adj_val
	value * (2 ^ 40) / (10 ^ 9) == adj_val
		then reduce it by dropping the shared values of 2
	value * (2 ^ 31) / (5 ^ 9) == adj_val

Hopefully that explains how I came to that value.

Thanks,

Alex
