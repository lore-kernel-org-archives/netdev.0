From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Thu, 17 Oct 2013 17:59:29 +0800
Message-ID: <525FB501.2060901@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FC98002000078000FBBB5@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com, xen-devel@lists.xenproject.org,
	annie.li@oracle.com, netdev@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30232 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156Ab3JQJ7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 05:59:43 -0400
In-Reply-To: <525FC98002000078000FBBB5@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-17 17:26, Jan Beulich wrote:
>>>> On 17.10.13 at 11:02, jianhai luan <jianhai.luan@oracle.com> wrote:
>> On 2013-10-17 16:26, Jan Beulich wrote:
>>>>>> On 16.10.13 at 19:22, Jason Luan <jianhai.luan@oracle.com> wrote:
>>>> time_after_eq() only works if the delta is < MAX_ULONG/2.
>>>>
>>>> If netfront sends at a very low rate, the time between subsequent calls
>>>> to tx_credit_exceeded() may exceed MAX_ULONG/2 and the test for
>>>> timer_after_eq() will be incorrect.  Credit will not be replenished and
>>>> the guest may become unable to send (e.g., if prior to the long gap, all
>>>> credit was exhausted).
>>>>
>>>> We should add the scenario which now beyond next_credit+MAX_UNLONG/2.
>> Because
>>>> the fact now must be not before than expire, time_before(now, expire) ==
>> true
>>>> will verify the scenario.
>>>>       time_after_eq(now, next_credit) || time_before (now, expire)
>>>>       ==
>>>>       !time_in_range_open(now, expire, next_credit)
>>> So first of all this must be with a 32-bit netback. And the not
>>> coverable gap between activity is well over 240 days long. _If_
>>> this really needs dealing with, then why is extending this from
>>> 240+ to 480+ days sufficient? I.e. why don't you simply
>>> change to 64-bit jiffy values, and use time_after_eq64()?
>> Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond
>> MAX_ULONG/2 in 64-bit will need long long time)
>>
>> I think the gap should be think all environment even now extending 480+.
>> if now fall in the gap,  one timer will be pending and replenish will be
>> in time.  Please run the attachment test program.
> Not sure what this is supposed to tell me. I recognize that there
> are overflow conditions not handled properly, but (a) I have a
> hard time thinking of a sensible guest that sits idle for over 240
> days (host uptime usually isn't even coming close to that due to
> maintenance requirements) and (b) if there is such a sensible
> guest, then I can't see why dealing with one being idle for over
> 480 days should be required too.

The issue can be reproduced when now beyond MAX_ULONG/2 (if the gust 
will send lesser package).
Jiffies beyond than MAX_UNLONG/2 will need below time:
     HZ         days
    100        248.55        (((0xffffffff/2)/HZ)/3600)/24
    250        99.42          (((0xffffffff/2)/HZ)/3600)/24
   1000       24.86          (((0xffffffff/2)/HZ)/3600)/24

Because we use 250,  the issue be found when uptime large than 100 days.

Jason
>> If use time_after_eq64(), expire ,next_credit and other member will must
>> be u64.
> Exactly - that's what I was telling you to do.
>
> Jan
>
