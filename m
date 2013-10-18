From: annie li <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Fri, 18 Oct 2013 14:48:19 +0800
Message-ID: <5260D9B3.2090301@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com> <525FA79F.8060601@oracle.com> <525FAABE.5080806@citrix.com> <525FB9BC.9010608@oracle.com> <525FBC7F.9040800@citrix.com> <525FED42.4040608@oracle.com> <20131017140611.GM16371@zion.uk.xensource.com> <526000F5.1090102@oracle.com> <5260015C.2030100@citrix.com> <52600542.4090100@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, ian.campbell@citrix.com,
	netdev@vger.kernel.org, Jan Beulich <JBeulich@suse.com>,
	xen-devel@lists.xenproject.org
To: jianhai luan <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30203 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895Ab3JRGsj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 02:48:39 -0400
In-Reply-To: <52600542.4090100@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-17 23:41, jianhai luan wrote:
>
> On 2013-10-17 23:25, David Vrabel wrote:
>> On 17/10/13 16:23, jianhai luan wrote:
>>> On 2013-10-17 22:06, Wei Liu wrote:
>>>> On Thu, Oct 17, 2013 at 09:59:30PM +0800, jianhai luan wrote:
>>>> [...]
>>>>>>>>> If use time_after_eq64(), expire ,next_credit and other member
>>>>>>>>> will must
>>>>>>>>> be u64.
>>>>>>>> Yes, you'll need to store next_credit as a u64 in vif instead of
>>>>>>>> calculating it in tx_credit_exceeded from expires (which is 
>>>>>>>> only an
>>>>>>>> unsigned long).
>>>>>>> I know that.  Even we use u64, time_after_eq()  will also do wrong
>>>>>>> judge
>>>>>>> in theory (not in reality because need long long time).
>>>>>> If jiffies_64 has millisecond resolution that would be more than
>>>>>> 500,000,000 years.
>>>>> Yes, I agree the fact.
>>>>>>> I think the two better fixed way is below:
>>>>>>>     - By time_before() to judge if now beyond MAX_ULONG/2
>>>>>> This is broken, so no.
>>>>> Where is broken?  would you like to help me point it out.
>>>> I think David means you didn't actually fix the problem. Your 
>>>> solution is
>>>> merely a workaround.
>>> I have think  about using u64, but more code need to be modified and
>>> that is not all.  Key point is how to change the element of struct
>>> time_list (expires)  and don't affect other thing?
>> I already suggested a way that didn't require changing the timer
>> structure -- calculate and store next_credit in advanced.
> I think that  modify next_credit only  will not fix the issue. please 
> think about:
>   - If jiffies have beyond 32 bit. i assume expire  is 0, jiffies_64 
> is  0x1000000ff.
>     next_credit = 0 +  <always 32-bit value >
>
>     time_after_eq64(jiffies_64, next_credit ) will always true. 
> replenish will always do, rate control will lost their function.

At first, the case above only exists when the network device keep idle 
for a long time, not frequently happens. If this case really happens, it 
means lots of jiffies are available for the credit, so there is no 
necessary to add the timer. The code operates correctly and rate control 
does not lose. This case can be shown with following config,
------old_next_credit(expires replaced)----------next_credit--------now----

So till now, two solutions are available: one is the current one to 
change if condition, another is to change all connected variant to 64. I 
incline to the former one since it involves less code change than the 
latter one.

Thanks
Annie
