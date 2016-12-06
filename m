From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v4 09/13] net: ethernet: ti: cpts: rework
 initialization/deinitialization
Date: Tue, 6 Dec 2016 11:49:14 -0600
Message-ID: <c0d6d670-cf44-c113-3443-3b5209e68ee2@ti.com>
References: <20161205200525.16664-1-grygorii.strashko@ti.com>
 <20161205200525.16664-10-grygorii.strashko@ti.com>
 <20161206134037.GA15946@localhost.localdomain>
 <4e7888b6-9f1c-ca31-e83e-15109bf1df3f@ti.com>
 <20161206171802.GA19646@localhost.localdomain>
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
In-Reply-To: <20161206171802.GA19646-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On 12/06/2016 11:18 AM, Richard Cochran wrote:
> On Tue, Dec 06, 2016 at 10:45:55AM -0600, Grygorii Strashko wrote:
>> On 12/06/2016 07:40 AM, Richard Cochran wrote:
>>> [ BTW, resetting the timecounter here makes no sense either.  Why
>>>   reset the clock just because the interface goes down?  ]
>>>
>>
>> Huh. This is how it works now (even before my changes) - this is just refactoring!
>> (really new thing is the only cpts_calc_mult_shift()).
> 
> The cpts_register() used to be called from probe(), but this changed
> without any review in f280e89ad.  That wasn't your fault, but still...
>  
>> Also there are additional questions such as:
>> - is there guarantee that cpsw port will be connected to the same network after ifup?
> 
> The network is not relevant.  PTP time is a global standard, just like
> with NTP.  We don't reset the NTP clock with ifup/down, do we?

But we do reset whole cpsw :( and that's required to support PM use cases as
suspend/resume.

There are also PM requirement to shutdown cpsw in case all interfaces are down.

More over, there are requirement to minimize cpsw power consumption in case all links are
disconnected (and cpts is special case here).

So, at least resetting of the timecounter still required.



> 
>> - should there be possibility to reset cc.mult if it's value will be kept from the previous run?
> 
> cc.mult will change naturally according to the operation of the user
> space PTP stack.  There is no need to reset it that I can see.
>  
>>> Secondly, you have made the initialization order of these fields hard
>>> to follow.  With the whole series applied:
>>>
>>> probe()
>>> 	cpts_create()
>>> 		cpts_of_parse()
>>> 		{
>>> 			/* Set cc_mult but not cc.mult! */
>>> 			set cc_mult
>>> 			set cc.shift
>>> 		}
>>> 		cpts_calc_mult_shift()
>>> 		{
>>> 			/* Set them both. */
>>> 			cpts->cc_mult = mult;
>>> 			cpts->cc.mult = mult; 
>>
>> ^^ this assignment of cpts->cc.mult not required.
> 
> You wrote the code, not me.

Sry, I meant, thank for catching this.

>  
>>> 			cpts->cc.shift = shift;
>> 			
>>
>> only in case there were not set in DT before
>> (I have a requirement to support both - DT and cpts_calc_mult_shift and
>>  that introduces a bit of complexity)
>>
>> Also, I've tried not to add more fields in struct cpts.
>>
>>> 		}
>>> /* later on */
>>> cpts_register()
>>> 	cpts->cc.mult = cpts->cc_mult;
>>>
>>> There is no need for such complexity.  Simply set cc.mult in
>>> cpts_create() _once_, immediately after the call to
>>> cpts_calc_mult_shift().
>>>
>>> You can remove the assignment from cpts_calc_mult_shift() and
>>> cpts_register().
>>
>> Just to clarify: do you propose to get rid of cpts->cc_mult at all?
> 
> No.  Read what I said before:
> 
>    There is no need for such complexity.  Simply set cc.mult in
>    cpts_create() _once_, immediately after the call to
>    cpts_calc_mult_shift().
> 
>> Honestly, i'd not prefer to change functional behavior of ptp clock as part of
>> this series.
> 
> Fair enough.  The bogus clock reset existed before your series.
> 
> But please don't obfuscate simple initialization routines.  The way
> you set cc.mult and cc_mult is illogical and convoluted.
> 

Ok. I'll try to optimize it following your directions.

Thanks.

-- 
regards,
-grygorii
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
