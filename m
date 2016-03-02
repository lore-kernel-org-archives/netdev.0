From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/8] net/flower: Introduce hardware offload
 support
Date: Wed, 2 Mar 2016 17:30:28 +0100
Message-ID: <20160302163028.GE2122@nanopsycho.orion>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-2-git-send-email-amir@vadai.me>
 <20160301144719.GA2098@nanopsycho.orion>
 <56d5c71f.a151c20a.cf0a8.ffffd4ad@mx.google.com>
 <20160301170128.GG2098@nanopsycho.orion>
 <CAJ3xEMje78ZB4SyBMKQWBDW2304NDK7R4UJiJsOPm4BjH84a7g@mail.gmail.com>
 <20160302132222.GB2122@nanopsycho.orion>
 <56D71358.6040205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Amir Vadai <amir@vadai.me>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34959 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797AbcCBQac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 11:30:32 -0500
Received: by mail-wm0-f67.google.com with SMTP id 1so10527126wmg.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 08:30:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56D71358.6040205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 02, 2016 at 05:22:48PM CET, john.fastabend@gmail.com wrote:
>On 16-03-02 05:22 AM, Jiri Pirko wrote:
>> Wed, Mar 02, 2016 at 12:14:39PM CET, gerlitz.or@gmail.com wrote:
>>> On Tue, Mar 1, 2016 at 7:01 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Tue, Mar 01, 2016 at 05:49:27PM CET, amir@vadai.me wrote:
>>>>> On Tue, Mar 01, 2016 at 03:47:19PM +0100, Jiri Pirko wrote:
>>>>>> Tue, Mar 01, 2016 at 03:24:43PM CET, amir@vadai.me wrote:
>>>>>>> This patch is based on a patch made by John Fastabend.
>>>
>>>>>>> It adds support for offloading cls_flower.
>>>>>>> A filter that is offloaded successfully by hardware, will not be added to
>>>>>>> the hashtable and won't be processed by software.
>>>
>>>>>> That is wrong. User should explicitly specify to not include rule into sw
>>>>>> by SKIP_KERNEL flag (does not exist now, with John's recent patch we'll
>>>>>> have only SKIP_HW). Please add that in this patchset.
>>>
>>>>> Why? If a rule is offloaded, why would the user want to reprocess it by software?
>>>
>>>>> If the user use SKIP_HW, it will be processed by SW. Else, the user
>>>>> would want it to be processed by HW or fallback to SW. I don't
>>>>> understand in which case the user would like to have it done twice.
>>>
>>>> For example if you turn on the offloading by unsetting NETIF_F_HW_TC.
>>>> Or if someone inserts skbs into rx path directly, for example pktgen.
>>>> We need SKIP_KERNEL to be set by user, not implicit.
>>>
>>> As discussed in netdev, we want to have three modes for TC offloads
>>>
>>> 1. SW only
>>> 2. HW only (and err if can't)
>>> 3. HW and if not supported fallback to SW
>>>
>>> Now, from your reply, I understand we want a fourth mode
>>>
>>> 4. Both (HW and SW)
>> 
>> I would perhaps do it a litte bit differently:
>> NO FLAG (default)- insert into kernel and HW now:
>> 		if NETIF_F_HW_TC is off (default)
>> 			-> push to kernel only (current behaviour)
>> 		if NETIF_F_HW_TC is on AND push to HW fails
>> 			-> return error
>> SKIP_HW - flag to tell kernel not to insert into HW
>> SKIP_SW - flag to tell kernel not to insert into kernel
>> 
>> to achieve hw only, user has to turn on the NETIF_F_HW_TC and
>> pass SKIP_SW flag.
>> 
>
>The modes Jiri describes here is exactly how I planned to build
>this. And at the moment the only one we are missing is SKIP_HW
>which I'm reworking now and should have in a few days.
>
>To resolve the error handling if the rule is SKIP_HW or NO_FLAG
>an error will be thrown if it can not be applied to software.
>Notice if an error happens on the software insert with NO_FLAG then
>the hardware insert is not attempted either. With SKIP_SW I will
>throw an error if the hardware insert fails because there is
>no software fallback in this mode.
>
>The only mode I haven't looked at doing is
>
>	3. HW and if not supported fallback to SW
>
>I'm not sure I have a use case for it at the moment. It is sufficient
>for me to just do a SKIP_SW command followed by a SKIP_HW command
>if needed. I guess someone else could implement it if they really need
>it.

I'd let user to resolve this as you described.
