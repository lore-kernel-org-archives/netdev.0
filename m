From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Tue, 9 Feb 2016 07:20:04 -0500
Message-ID: <56B9D974.3000203@mojatatu.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
 <20160203101109.GB20905@office.Home> <56B1D4A9.3050801@gmail.com>
 <56B1D713.3080803@mellanox.com> <56B1F0C9.3020802@mojatatu.com>
 <56B24B8B.1010205@gmail.com> <56B34E35.3020307@mojatatu.com>
 <56B9CC6B.6050509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: amir@vadai.me, jiri@resnulli.us, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: "Fastabend, John R" <john.fastabend@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33181 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356AbcBIMUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 07:20:07 -0500
Received: by mail-wm0-f68.google.com with SMTP id c200so3097982wme.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 04:20:06 -0800 (PST)
In-Reply-To: <56B9CC6B.6050509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-09 06:24 AM, Fastabend, John R wrote:
> On 2/4/2016 5:12 AM, Jamal Hadi Salim wrote:
>>
>> On 16-02-03 01:48 PM, Fastabend, John R wrote:
>>

>> Basically most hardware (or i should say driver implementations of
>> mostly TCAMS) allow you to add exactly the same filter as many times
>> as you want. They dont really look at what you want to filter on
>> and then scream "conflict". IOW, you (user) are responsible for
>> conflict resolution at the filter level. The driver sees this blob
>> and requests for some index/key from the hardware then just adds it.
>> You can then use this key/index to delete/replace etc.
>> This is what i meant by "append" mode.
>> However if a classifier implementation cares about filter ambiguity
>> resolution, then priorities are used. We need to worry about the
>> bigger picture.
>>
>
> Sure in other classifiers its used but its not needed in the set I
> planned to added it later.
>

If you leave it open for some other hardware to use we should be fine.

>>
>>> For this series using cls_u32 the handle gives you everything you need
>>> to put entries in the right table and row. Namely the ht # and order #
>>> from 'tc'.
>>
>> True - but with a caveat. There are only 2^12 max tables you can
>> have for example and up to 2^12 filters per bucket etc.
>>
>
> This is a software limitation as well right? If it hasn't showed up
> as a limitation on the software side why would it be an issue here?
> Do you have more than 2^12 tables on your devices? If so I guess we
> can tack on another 32bits somewhere.
>

That handle is used as an "Address" to the 32 bit filter.
Just beware of the semantics the handle has.
It hasnt shown up as a software limitation because the defaults
are good enough for most people. But if you ever want to install
a million rules that can be looked up at a reasonable pps rate
it will become very obvious quickly. I have a sample setup in the
talk tommorow which shows such an example.

>> I think you need to take the u32 address and map it to something in your
>> hardware. But at the same time it is important to have the abstraction
>> closely emulate your hardware.
>>
>
> IMO the hardware/interface must preserve the same ordering of
> filters/hash_Tables/etc. How it does that mapping should be
> a driver concern and it can always abort if it fails.
>

Sure.

>>> Also ran a few tests and can't see how priority works in u32 maybe you
>>> can shed some light but as best I can tell it doesn't have any effect
>>> on rule execution.
>>>
>>
>> True.
>> u32 doesnt care because it will give you a nodeid if you dont specify
>> one. i.e conflict resolution is mapped to you not specifying exactly
>> the same ht:bkt:nodeid more than once. And if you will let the
>> kernel do it for you (as i am assumming you are saying your hardware
>> will) then no need.
>
> Yep. Faithfully offloading u32 here not changing anything except
> I do have to abort on some cases with the simpler devices. fm10k for
> example can model hash nodes with divisors > 1.
>

I wonder if when we get to capabilities we can do this...

>>

>
> My issue is we can map flower onto u32 that is fine and u32 onto
> bpf. But we lose a lot of the power of each classifier when we
> do this. flower for example is nice because of its simplicity
> presumably this translates into faster updates, u32 is great because
> we get full parse graph support and hash tables, ebpf is the biggest
> beast of all and lets us load arbitrary functions into the device.
> All are nice in their own right.
>

Did i send you my slides? ;->


cheers,
jamal
