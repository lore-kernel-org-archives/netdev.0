From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 7/9] net: ethernet: ti: cpts: calc mult and shift from
 refclk freq
Date: Wed, 14 Sep 2016 22:59:53 +0300
Message-ID: <df77795a-c0f9-b6c4-497a-6386a0a6b1e5@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-8-grygorii.strashko@ti.com>
 <20160914142210.GE28592@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914142210.GE28592@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 05:22 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 04:02:29PM +0300, Grygorii Strashko wrote:
>> @@ -35,6 +33,8 @@ Optional properties:
>>  			  For example in dra72x-evm, pcf gpio has to be
>>  			  driven low so that cpsw slave 0 and phy data
>>  			  lines are connected via mux.
>> +- cpts_clock_mult	: Numerator to convert input clock ticks into nanoseconds
>> +- cpts_clock_shift	: Denominator to convert input clock ticks into nanoseconds
>
> You should explain to the reader how these will be calculated when the
> properties are missing.

Not sure how full should it be explained in bindings - I'll try.


>
>> diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
>> index ff8bb85..8046a21 100644
>> --- a/drivers/net/ethernet/ti/cpts.c
>> +++ b/drivers/net/ethernet/ti/cpts.c
>> @@ -418,18 +418,60 @@ void cpts_unregister(struct cpts *cpts)
>>  	clk_disable(cpts->refclk);
>>  }
>>
>> +static void cpts_calc_mult_shift(struct cpts *cpts)
>> +{
>> +	u64 maxsec;
>> +	u32 freq;
>> +	u32 mult;
>> +	u32 shift;
>> +	u64 ns;
>> +	u64 frac;
>
> Why so many new lines?  This isn't good style.  Please combine
> variables of the same type into one line and sort the lists
> alphabetically.

Its matter of preferences :), but sure - I'll update.
>
>> +	if (cpts->cc_mult || cpts->cc.shift)
>> +		return;
>> +
>> +	freq = clk_get_rate(cpts->refclk);
>> +
>> +	/* Calc the maximum number of seconds which we can run before
>> +	 * wrapping around.
>> +	 */
>> +	maxsec = cpts->cc.mask;
>> +	do_div(maxsec, freq);
>> +	if (!maxsec)
>> +		maxsec = 1;
>> +	else if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
>> +		maxsec = 600;
>> +
>> +	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
>> +
>> +	cpts->cc_mult = mult;
>> +	cpts->cc.mult = mult;
>> +	cpts->cc.shift = shift;
>> +	/* Check calculations and inform if not precise */
>
> Contrary to this comment, you are not making any kind of judgment
> about whether the calculations are precise or not.
>
>> +	frac = 0;
>> +	ns = cyclecounter_cyc2ns(&cpts->cc, freq, cpts->cc.mask, &frac);
>> +
>> +	dev_info(cpts->dev,
>> +		 "CPTS: ref_clk_freq:%u calc_mult:%u calc_shift:%u error:%lld nsec/sec\n",
>> +		 freq, cpts->cc_mult, cpts->cc.shift, (ns - NSEC_PER_SEC));
>> +}
>> +
>

Thanks for the review.

-- 
regards,
-grygorii
