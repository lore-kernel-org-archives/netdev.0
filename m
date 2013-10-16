From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] DomU's network interface will hung when Dom0 running
 32bit
Date: Wed, 16 Oct 2013 17:39:43 +0800
Message-ID: <525E5EDF.4030904@oracle.com>
References: <52590DFE.6080203@oracle.com> <20131014111958.GE11739@zion.uk.xensource.com> <525CAC21.5040202@oracle.com> <1381826609.24708.135.camel@kazak.uk.xensource.com> <525D0C41.2080407@oracle.com> <20131015100624.GB29436@zion.uk.xensource.com> <525D2667.6040102@oracle.com> <20131015125802.GR11739@zion.uk.xensource.com> <525E41CF.7090008@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, xen-devel@lists.xenproject.org,
	Ian Campbell <Ian.Campbell@citrix.com>, netdev@vger.kernel.org
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42774 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760301Ab3JPJjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 05:39:53 -0400
In-Reply-To: <525E41CF.7090008@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-16 15:35, jianhai luan wrote:
>
> On 2013-10-15 20:58, Wei Liu wrote:
>> On Tue, Oct 15, 2013 at 07:26:31PM +0800, jianhai luan wrote:
>> [...]
>>>>>> Can you propose a patch?
>>>>> Because credit_timeout.expire always after jiffies, i judge the
>>>>> value over the range of time_after_eq() by time_before(now,
>>>>> vif->credit_timeout.expires). please check the patch.
>>>> I don't think this really fix the issue for you. You still have chance
>>>> that now wraps around and falls between expires and next_credit. In 
>>>> that
>>>> case it's stalled again.
>>> if time_before(now, vif->credit_timeout.expires) is true, time wrap
>>> and do operation. Otherwise time_before(now,
>>> vif->credit_timeout.expires) isn't true, now -
>>> vif->credit_timeout.expires should be letter than ULONG_MAX/2.
>>> Because next_credit large than vif->credit_timeout.expires
>>> (next_crdit = vif->credit_timeout.expires +
>>> msecs_to_jiffies(vif->credit_usec/1000)), the delta between now and
>>> next_credit should be in range of time_after_eq().  So
>>> time_after_eq() do correctly judge.
>>>
>> Not sure I understand you. Consider "now" is placed like this:
>>
>>     expires   now   next_credit
>>     ----time increases this direction--->
>>
>> * time_after_eq(now, next_credit) -> false
>> * time_before(now, expires) -> false
>>
>> Then it's stuck again. You're merely narrowing the window, not fixing
>> the real problem.
>
> The above environment isn't stack again. The netback will pending one 
> timer to process the environment.
>
> The attachment program will prove if !(time_after_eq(now, next_credit) 
> || time_before(now, vif->credit_timeout.expires)), now will only be 
> placed in  above environment [ expires next_credit),  and the above 
> environment will be processed by timer in soon.

Or check following to see what the if condition really do,

----------expires-------now-------credit----------    is the only case 
where we need to add a timer.

Other cases like following would match the if condition above, then no 
timer is added.
----------expires----------credit------now------
-----now-----expires----------credit----------

Or we can consider the extreme condition, when the rate control does not 
exist, "credit_usec" is zero, and "next_credit" is equal to "expires". 
The above if condition would cover all conditions, and no rate control 
really happens. If credit_usec is not zero, the "if condition" would 
cover the range outside of that from expires to next_credit.

Even if "now" is wrapped again into the range from "expires" to 
"next_credit", the "next_credit" that is set in __mod_timer is 
reasonable value(this can be gotten from credit_usec), and the timer 
would be hit soon.

Thanks
Annie
>>
>> Wei.
>>
>>> Jason
>>>> Wei.
> Jason.
>
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
