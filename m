From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 16:14:16 +0800
Message-ID: <5260EDD8.4020608@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com> <52601274.5010008@oracle.com> <526102DE02000078000FBFBB@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, david.vrabel@citrix.com,
	xen-devel@lists.xenproject.org,
	jianhai luan <jianhai.luan@oracle.com>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29011 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041Ab3JRIOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 04:14:39 -0400
In-Reply-To: <526102DE02000078000FBFBB@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-18 15:43, Jan Beulich wrote:
>>>> On 17.10.13 at 18:38, annie li <annie.li@oracle.com> wrote:
>> On 2013-10-17 17:26, Jan Beulich wrote:
>>>> Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond
>>>> MAX_ULONG/2 in 64-bit will need long long time)
>>>>
>>>> I think the gap should be think all environment even now extending 480+.
>>>> if now fall in the gap,  one timer will be pending and replenish will be
>>>> in time.  Please run the attachment test program.
>>> Not sure what this is supposed to tell me. I recognize that there
>>> are overflow conditions not handled properly, but (a) I have a
>>> hard time thinking of a sensible guest that sits idle for over 240
>>> days (host uptime usually isn't even coming close to that due to
>>> maintenance requirements) and (b) if there is such a sensible
>>> guest, then I can't see why dealing with one being idle for over
>>> 480 days should be required too.
>>>
>> If the guest contains multiple NICs, that situation probably happens
>> when one NIC keeps idle and others work under load. BTW, how do you get
>> the 240?
> 2^31 / 100 / 60 / 60 / 24
>
> Obviously with HZ=1000 the span would be smaller by a factor
> of 10, which would make it even more clear that doubling the
> span doesn't really help.

My understanding is this patch does not simply double the span, it is 
just stricter than the original one. Please check my previous comments, 
I paste it here.

The main change of this patch is copied here too,
if (!time_in_range_open(now, vif->credit_timeout.expires, next_credit))

comments:

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
