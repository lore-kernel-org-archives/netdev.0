From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Subject: Re: [patch net-next 0/3] net/sched: Improve getting objects by
 indexes
Date: Wed, 16 Aug 2017 10:31:35 +0200
Message-ID: <e3cb8f8e-7808-48b4-d90d-67f30ab39687@amd.com>
References: <1502849538-14284-1-git-send-email-chrism@mellanox.com>
 <144b87a3-bbe4-a194-ed83-e54840d7c7c2@amd.com>
 <20170816081631.GC1868@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Mi <chrism@mellanox.com>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0050.outbound.protection.outlook.com ([104.47.38.50]:47808
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751224AbdHPIbv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 04:31:51 -0400
In-Reply-To: <20170816081631.GC1868@nanopsycho>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 16.08.2017 um 10:16 schrieb Jiri Pirko:
> Wed, Aug 16, 2017 at 09:49:07AM CEST, christian.koenig@amd.com wrote:
>> Am 16.08.2017 um 04:12 schrieb Chris Mi:
>>> Using current TC code, it is very slow to insert a lot of rules.
>>>
>>> In order to improve the rules update rate in TC,
>>> we introduced the following two changes:
>>>           1) changed cls_flower to use IDR to manage the filters.
>>>           2) changed all act_xxx modules to use IDR instead of
>>>              a small hash table
>>>
>>> But IDR has a limitation that it uses int. TC handle uses u32.
>>> To make sure there is no regression, we also changed IDR to use
>>> unsigned long. All clients of IDR are changed to use new IDR API.
>> WOW, wait a second. The idr change is touching a lot of drivers and to be
>> honest doesn't looks correct at all.
>>
>> Just look at the first chunk of your modification:
>>> @@ -998,8 +999,9 @@ int bsg_register_queue(struct request_queue *q, struct device *parent,
>>>    	mutex_lock(&bsg_mutex);
>>> -	ret = idr_alloc(&bsg_minor_idr, bcd, 0, BSG_MAX_DEVS, GFP_KERNEL);
>>> -	if (ret < 0) {
>>> +	ret = idr_alloc(&bsg_minor_idr, bcd, &idr_index, 0, BSG_MAX_DEVS,
>>> +			GFP_KERNEL);
>>> +	if (ret) {
>>>    		if (ret == -ENOSPC) {
>>>    			printk(KERN_ERR "bsg: too many bsg devices\n");
>>>    			ret = -EINVAL;
>> The condition "if (ret)" will now always be true after the first allocation
>> and so we always run into the error handling after that.
> On success, idr_alloc returns 0.

Ah, I see. You change the idr_alloc to return the resulting index as 
separate parameter.

You should explicit note that in the commit message, cause that is 
something easily overlooked.

In general I strongly suggest to add a separate interface for allocating 
unsigned long handles, use that for the while being and then move the 
existing drivers over bit by bit.

A single patch which touches so many different driver is practically 
impossible to review consequently.

>> I've never read the bsg code before, but that's certainly not correct. And
>> that incorrect pattern repeats over and over again in this code.
>>
>> Apart from that why the heck do you want to allocate more than 1<<31 handles?
> tc action indexes for example. That is part of this patchset.

Well, let me refine the question: Why does tc action indexes need more 
than 31 bits? From an outside view that looks like pure overkill.

Regards,
Christian.
