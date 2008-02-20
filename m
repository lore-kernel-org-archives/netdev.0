From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: e1000: Question about polling
Date: Wed, 20 Feb 2008 12:15:01 +0300
Message-ID: <47BBEF95.6010307@bigtelecom.ru>
References: <47B94D5C.2070509@bigtelecom.ru> <36D9DB17C6DE9E40B059440DB8D95F520474680C@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:50052 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757890AbYBTJPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 04:15:10 -0500
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F520474680C@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Very big thanks for this answer. You ask for all my questions and for 
all future questions too. Thanks Again!
> Badalian Vyacheslav wrote:
>   
>> Hello all.
>>
>> Interesting think:
>>
>> Have PC that do NAT. Bandwidth about 600 mbs.
>>
>> Have  4 CPU (2xCoRe 2 DUO "HT OFF" 3.2 HZ).
>>
>> irqbalance in kernel is off.
>>
>> nat2 ~ # cat /proc/irq/217/smp_affinity
>> 00000001
>>     
> this binds all 217 irq interrupts to cpu 0
>
>   
>> nat2 ~ # cat /proc/irq/218/smp_affinity
>> 00000003
>>     
>
> do you mean to be balancing interrupts between core 1 and 2 here?
> 1 = cpu 0
> 2 = cpu 1
> 4 = cpu 2
> 8 = cpu 3
>
> so 1+2 = 3 for irq 218, ie balancing between the two.
>
> sometimes the cpus will have a paired cache, depending on your bios it
> will be organized like cpu 0/2 = shared cache, and cput 1/3 = shared
> cache.
> you can find this out by looking at physical ID and CORE ID in
> /proc/cpuinfo
>
>   
>> Load SI on CPU0 and CPU1 is about 90%
>>
>> Good... try do
>> echo ffffffff > /proc/irq/217/smp_affinity
>> echo ffffffff > /proc/irq/218/smp_affinity
>>
>> Get 100% SI at CPU0
>>
>> Question Why?
>>     
>
> because as each adapter generating interrupts gets rotated through cpu0,
> it gets "stuck" on cpu0 because the napi scheduling can only run one at
> a time, and so each is always waiting in line behind the other to run
> its napi poll, always fills its quota (work_done is always != 0) and
> keeps interrupts disabled "forever"
>
>   
>> I listen that if use IRQ from 1 netdevice to 1 CPU i can get 30%
>> perfomance... but i have 4 CPU... i must get more perfomance if i cat
>> "ffffffff"  to smp_affinity.
>>     
>
> only if your performance is not cache limited but cpu horsepower
> limited.  you're sacrificing cache coherency for cpu power, but if that
> works for you then great.
>  
>   
>> picture looks liks this:
>> 0-3 CPU get over 50% SI.... bandwith up.... 55% SI... bandwith up...
>> 100% SI on CPU0....
>>
>> I remember patch to fix problem like it... patched function
>> e1000_clean...  kernel on pc have this patch (2.6.24-rc7-git2)...
>> e1000 driver work much better (i up to 1.5-2x bandwidth before i get
>> 100% SI), but i think that it not get 100% that it can =)
>>     
>
> the patch helps a little because it decreases the amount of time the
> driver spends in napi mode, basically shortening the exit condition
> (which reenables interrupts, and therefore balancing) to work_done <
> budget, not work_done == 0.
>
>   
>> Thanks for answers and sorry for my English
>>     
>
> you basically can't get much more than one cpu can do for each nic.  its
> possible to get a little more, but my guess is you won't get much.  The
> best thing you can do is make sure as much traffic as possible stays in
> the same cache, on two different cores.
>
> you can try turning off NAPI mode either in the .config, or build the
> sourceforge driver with CFLAGS_EXTRA=-DE1000_NO_NAPI,  which seems
> counterintuitive, but with the non-napi e1000 pushing packets to the
> backlog queue on each cpu, you may actually get better performance due
> to the balancing.
>
> some day soon (maybe) we'll have some coherent way to have one tx and rx
> interrupt per core, and enough queues for each port to be able to handle
> 1 queue per core.
>
> good luck,
>   Jesse  
>
>   

