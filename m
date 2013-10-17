From: jianhai luan <jianhai.luan@oracle.com>
Subject: Re: [Xen-devel] [PATCH net] xen-netback: add the scenario which now
 beyond the range time_after_eq().
Date: Thu, 17 Oct 2013 17:02:23 +0800
Message-ID: <525FA79F.8060601@oracle.com>
References: <1381944167-24918-1-git-send-email-jianhai.luan@oracle.com> <525FBB4F02000078000FBB30@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: david.vrabel@citrix.com, ian.campbell@citrix.com,
	wei.liu2@citrix.com, xen-devel@lists.xenproject.org,
	annie.li@oracle.com, netdev@vger.kernel.org
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39976 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137Ab3JQJCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 05:02:36 -0400
In-Reply-To: <525FBB4F02000078000FBB30@nat28.tlf.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2013-10-17 16:26, Jan Beulich wrote:
>>>> On 16.10.13 at 19:22, Jason Luan <jianhai.luan@oracle.com> wrote:
>> time_after_eq() only works if the delta is < MAX_ULONG/2.
>>
>> If netfront sends at a very low rate, the time between subsequent calls
>> to tx_credit_exceeded() may exceed MAX_ULONG/2 and the test for
>> timer_after_eq() will be incorrect.  Credit will not be replenished and
>> the guest may become unable to send (e.g., if prior to the long gap, all
>> credit was exhausted).
>>
>> We should add the scenario which now beyond next_credit+MAX_UNLONG/2. Because
>> the fact now must be not before than expire, time_before(now, expire) == true
>> will verify the scenario.
>>      time_after_eq(now, next_credit) || time_before (now, expire)
>>      ==
>>      !time_in_range_open(now, expire, next_credit)
> So first of all this must be with a 32-bit netback. And the not
> coverable gap between activity is well over 240 days long. _If_
> this really needs dealing with, then why is extending this from
> 240+ to 480+ days sufficient? I.e. why don't you simply
> change to 64-bit jiffy values, and use time_after_eq64()?

Yes, the issue only can be  reproduced in 32-bit Dom0 (Beyond 
MAX_ULONG/2 in 64-bit will need long long time)

I think the gap should be think all environment even now extending 480+. 
if now fall in the gap,  one timer will be pending and replenish will be 
in time.  Please run the attachment test program.

If use time_after_eq64(), expire ,next_credit and other member will must 
be u64.
>
> Jan
>
>> Signed-off-by: Jason Luan <jianhai.luan@oracle.com>
>> ---
>>   drivers/net/xen-netback/netback.c |    7 +++++--
>>   1 files changed, 5 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/xen-netback/netback.c
>> b/drivers/net/xen-netback/netback.c
>> index f3e591c..31eedaf 100644
>> --- a/drivers/net/xen-netback/netback.c
>> +++ b/drivers/net/xen-netback/netback.c
>> @@ -1194,8 +1194,11 @@ static bool tx_credit_exceeded(struct xenvif *vif,
>> unsigned size)
>>   	if (timer_pending(&vif->credit_timeout))
>>   		return true;
>>   
>> -	/* Passed the point where we can replenish credit? */
>> -	if (time_after_eq(now, next_credit)) {
>> +	/* Credit should be replenished when now does not fall into the
>> +	 * range from expires to next_credit, and time_in_range_open()
>> +	 * is used to verify whether this case happens.
>> +	 */
>> +	if (!time_in_range_open(now, vif->credit_timeout.expires, next_credit)) {
>>   		vif->credit_timeout.expires = now;
>>   		tx_add_credit(vif);
>>   	}
>> -- 
>> 1.7.6.5
>>
>>
>> _______________________________________________
>> Xen-devel mailing list
>> Xen-devel@lists.xen.org
>> http://lists.xen.org/xen-devel
>
>
