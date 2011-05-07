From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Sat, 07 May 2011 14:25:41 -0700
Message-ID: <23896.1304803541@death>
References: <20110507012717.GA15854@x61.tchesoft.com> <1304733100.11874.33.camel@Joe-Laptop> <20110507173141.GA4204@x61.tchesoft.com> <1304791360.1738.6.camel@Joe-Laptop>
Cc: aquini@linux.com, kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:35805 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624Ab1EGVZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 17:25:49 -0400
In-reply-to: <1304791360.1738.6.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

>On Sat, 2011-05-07 at 14:31 -0300, Rafael Aquini wrote:
>> To exemplify my point, I'll taking that very  __ad_timer_to_ticks() as an example:
>> static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
>> {
>>         u16 retval = 0;
>> 
>>         switch (timer_type) {
>>         case AD_CURRENT_WHILE_TIMER:    /* for rx machine usage */
>>                 if (par)
>>                         retval = (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec);
>>                 else
>>                         retval = (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec);
>>                 break;
>>         case AD_ACTOR_CHURN_TIMER:      /* for local churn machine */
>>                 retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
>>                 break;
>>         case AD_PERIODIC_TIMER:         /* for periodic machine */
>>                 retval = (par*ad_ticks_per_sec);
>>                 break;
>>         case AD_PARTNER_CHURN_TIMER:    /* for remote churn machine */
>>                 retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
>>                 break;
>>         case AD_WAIT_WHILE_TIMER:       /* for selection machine */
>>                 retval = (AD_AGGREGATE_WAIT_TIME*ad_ticks_per_sec);
>>                 break;
>>         }
>>         return retval;
>> }
>> 
>> If, for some unknown reason timer_type receives an 'alien' value, and
>> we were
>> using retval uninitialized, this function, as it is, would return an
>> unpredictable value to its caller. Unless we have the switch block
>> re-factored, we cannot leave retval uninitialized. So, it's not just a
>> matter of leaving the variable uninitialized, or initialize it just to
>> get rid of a compiler warning. That's why those comments are not
>> helpful anyway.

	The comments are helpful, because they mark places where the
code could use some improvement to better handle "impossible"
conditions.  The only reason we need the initializer is because the
function doesn't handle all possible inputs.  This is probably not the
comment's intended purpose, but they're useful for this nevertheless.

>I'd write this not using a retval variable at all as:
>
>	switch (timer_type) {
>	case AD_CURRENT_WHILE_TIMER:	/* for rx machine usage */
>		if (par)
>			return AD_SHORT_TIMEOUT_TIME * ad_ticks_per_sec;
>		return AD_LONG_TIMEOUT_TIME * ad_ticks_per_sec;
>	case AD_ACTOR_CHURN_TIMER:	/* for local churn machine */
>		return AD_CHURN_DETECTION_TIME * ad_ticks_per_sec;
>	...
>	}
>	WARN(1, "Invalid timer type: %u\n", timer_type)
>	return 0;
>}

	Most (perhaps all) of the "silence compiler" comments in this
code exist in places that, like the above, will silently misbehave if
unexpected input arrives.  Granted, for the __ad_timer_to_ticks
function, there aren't a lot of call sites, but the other similar cases
exist within the state machine handler code.

	My preference would be to only remove the "silence compiler"
comments if the possibility of silent misbehavior is also eliminated.
For __ad_timer_to_ticks, that would mean either a default: case in the
current arrangement, or something like what Joe suggests above.

	If this is beyond the scope of what you, Rafeal, want to do,
that's fine, but in that case leave the "silence" notes in place.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
