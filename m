From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: [PATCH 7/9] net: ethernet: ti: cpts: calc mult and shift from
 refclk freq
Date: Wed, 14 Sep 2016 23:47:46 +0300
Message-ID: <4add2983-bdfe-8436-de62-4b2fdc2ea750@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-8-grygorii.strashko@ti.com>
 <20160914202618.GC12195@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        John Stultz <john.stultz@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160914202618.GC12195@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2016 11:26 PM, Richard Cochran wrote:
> On Wed, Sep 14, 2016 at 04:02:29PM +0300, Grygorii Strashko wrote:
>> +static void cpts_calc_mult_shift(struct cpts *cpts)
>> +{
>> +	u64 maxsec;
>> +	u32 freq;
>> +	u32 mult;
>> +	u32 shift;
>> +	u64 ns;
>> +	u64 frac;
>> +
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
> 
> This doesn't pass the smell test.  If the max counter value is M, you
> are figuring M*1/F which is the time in seconds corresponding to M.
> We set M=2^32-1, and so 'freq' would have to be greater than 4 GHz in
> order for 'maxsec' to be zero.  Do you really expect such high
> frequency input clocks?

no. can drop it.

> 
>> +	else if (maxsec > 600 && cpts->cc.mask > UINT_MAX)
>> +		maxsec = 600;
> 
> What is this all about?  cc.mask is always 2^32 - 1.

Oh. Not sure if we will update CPTS to support this, but on
 KS2 E/L (66AK2E) CPTS counter can work in 64bit mode.

> 
>> +	clocks_calc_mult_shift(&mult, &shift, freq, NSEC_PER_SEC, maxsec);
>> +
>> +	cpts->cc_mult = mult;
>> +	cpts->cc.mult = mult;
> 
> In order to get good resolution on the frequency adjustment, we want
> to keep 'mult' as large as possible.  I don't see your code doing
> this.  We can rely on the watchdog reader (work queue) to prevent
> overflows.

As I understand (and tested), clocks_calc_mult_shift() will 
return max possible mult which can be used without overflow.
if calculated results do not satisfy end user - the custom values can
be passed in DT.  

-- 
regards,
-grygorii
