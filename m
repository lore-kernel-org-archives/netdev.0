From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v4 09/13] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Tue, 6 Dec 2016 10:45:55 -0600
Message-ID: <4e7888b6-9f1c-ca31-e83e-15109bf1df3f@ti.com>
References: <20161205200525.16664-1-grygorii.strashko@ti.com>
 <20161205200525.16664-10-grygorii.strashko@ti.com>
 <20161206134037.GA15946@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
        Wingman Kwok <w-kwok2-l0cyMroinI0@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161206134037.GA15946-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 12/06/2016 07:40 AM, Richard Cochran wrote:
> On Mon, Dec 05, 2016 at 02:05:21PM -0600, Grygorii Strashko wrote:
>> @@ -372,34 +354,27 @@ void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
>>  }
>>  EXPORT_SYMBOL_GPL(cpts_tx_timestamp);
>>  
>> -int cpts_register(struct device *dev, struct cpts *cpts,
>> -		  u32 mult, u32 shift)
>> +int cpts_register(struct cpts *cpts)
>>  {
>>  	int err, i;
>>  
>> -	cpts->info = cpts_info;
>> -	spin_lock_init(&cpts->lock);
>> -
>> -	cpts->cc.read = cpts_systim_read;
>> -	cpts->cc.mask = CLOCKSOURCE_MASK(32);
>> -	cpts->cc_mult = mult;
>> -	cpts->cc.mult = mult;
>> -	cpts->cc.shift = shift;
>> -
>>  	INIT_LIST_HEAD(&cpts->events);
>>  	INIT_LIST_HEAD(&cpts->pool);
>>  	for (i = 0; i < CPTS_MAX_EVENTS; i++)
>>  		list_add(&cpts->pool_data[i].list, &cpts->pool);
>>  
>> -	cpts_clk_init(dev, cpts);
>> +	clk_enable(cpts->refclk);
>> +
>>  	cpts_write32(cpts, CPTS_EN, control);
>>  	cpts_write32(cpts, TS_PEND_EN, int_enable);
>>  
>> +	/* reinitialize cc.mult to original value as it can be modified
>> +	 * by cpts_ptp_adjfreq().
>> +	 */
>> +	cpts->cc.mult = cpts->cc_mult;
> 
> This still isn't quite right.  First of all, you shouldn't clobber the
> learned cc.mult value in cpts_register().  Presumably, if PTP had been
> run on this port before, then the learned frequency is approximately
> correct, and it should be left alone.
> 
> [ BTW, resetting the timecounter here makes no sense either.  Why
>   reset the clock just because the interface goes down?  ]
> 

Huh. This is how it works now (even before my changes) - this is just refactoring!
(really new thing is the only cpts_calc_mult_shift()).

Also, this is how cpts is supported now as part of cpsw (and keystone):
configure cpsw (cpts)
- ifup
   cpsw (*soft_reset*, full reconfiguration of cpsw)
  (start cpts) - cpts/ptp active

- ifdown
   if last netdev - shutdown/poweroff cpsw (cpts)

in other words, cpts/ptp is expected to work once and until at least one cpsw netdev is active.

Also there are additional questions such as:
- is there guarantee that cpsw port will be connected to the same network after ifup?
- should there be possibility to reset cc.mult if it's value will be kept from the previous run?

> Secondly, you have made the initialization order of these fields hard
> to follow.  With the whole series applied:
> 
> probe()
> 	cpts_create()
> 		cpts_of_parse()
> 		{
> 			/* Set cc_mult but not cc.mult! */
> 			set cc_mult
> 			set cc.shift
> 		}
> 		cpts_calc_mult_shift()
> 		{
> 			/* Set them both. */
> 			cpts->cc_mult = mult;
> 			cpts->cc.mult = mult; 

^^ this assignment of cpts->cc.mult not required.

> 			cpts->cc.shift = shift;
			

only in case there were not set in DT before
(I have a requirement to support both - DT and cpts_calc_mult_shift and
 that introduces a bit of complexity)

Also, I've tried not to add more fields in struct cpts.

> 		}
> /* later on */
> cpts_register()
> 	cpts->cc.mult = cpts->cc_mult;
> 
> There is no need for such complexity.  Simply set cc.mult in
> cpts_create() _once_, immediately after the call to
> cpts_calc_mult_shift().
> 
> You can remove the assignment from cpts_calc_mult_shift() and
> cpts_register().

Just to clarify: do you propose to get rid of cpts->cc_mult at all?

static int cpts_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
{
...
	if (ppb < 0) {
		neg_adj = 1;
		ppb = -ppb;
	}
	mult = cpts->cc_mult;
		^^^^^^^^^^^^^^
	adj = mult;
	adj *= ppb;
	diff = div_u64(adj, 1000000000ULL);
...
	cpts->cc.mult = neg_adj ? mult - diff : mult + diff;

Honestly, i'd not prefer to change functional behavior of ptp clock as part of
this series.

-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
