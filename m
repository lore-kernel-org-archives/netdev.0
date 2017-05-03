From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] net: ipv6: Do not duplicate DAD on link up
Date: Wed, 3 May 2017 15:29:23 -0600
Message-ID: <e8477d7d-3adb-500c-cca1-783cf90872f1@gmail.com>
References: <1493761424-17407-1-git-send-email-dsahern@gmail.com>
 <CAM_iQpVJZRzYmWqhYBhoAnv71GkM=0HQW7yUvzUQgVT-5hy_3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:32801 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdECV30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 17:29:26 -0400
Received: by mail-pg0-f66.google.com with SMTP id s62so278982pgc.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 14:29:26 -0700 (PDT)
In-Reply-To: <CAM_iQpVJZRzYmWqhYBhoAnv71GkM=0HQW7yUvzUQgVT-5hy_3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/3/17 3:22 PM, Cong Wang wrote:
>> Andrey's reproducer program runs in a very tight loop, calling
>> 'unshare -n' and then spawning 2 sets of 14 threads running random ioctl
>> calls. The relevant networking sequence:
>>
>> 1. New network namespace created via unshare -n
>> - ip6tnl0 device is created in down state
>>
>> 2. address added to ip6tnl0
>> - equivalent to ip -6 addr add dev ip6tnl0 fd00::bb/1
>> - DAD is started on the address and when it completes the host
>>   route is inserted into the FIB
>>
>> 3. ip6tnl0 is brought up
>> - the new fixup_permanent_addr function restarts DAD on the address
>>
>> 4. exit namespace
>> - teardown / cleanup sequence starts
>> - once in a blue moon, lo teardown appears to happen BEFORE teardown
>>   of ip6tunl0
> 
> Why is this possible? Loopback device should be always the first one to
> register therefore the last one to unregister.

Andrey's config builds in all of the devices. Once in a blue moon I
would see the host route get deleted b/c 'lo' was taken down.

> 
> Hmm? But addrconf_ifdown() is called when the device is going from UP
> to down, how does your patch prevent a duplicated DAD for a device which
> is going from DOWN to UP in step 3? This is very confusing.
> 

read the sequence:
1. ip6tnl0 is in the down state

2. address is added to ip6tnl0
   DAD starts, completes, inserts host route into FIB

3. ip6tnl0 is brought up
   DAD starts, completes, inserts host route into FIB

Between 2. and 3. lo is taken down.

Since DAD is done for an address in 2, it does not need to be repeated in 3.

The DAD in 3. was meant for addresses kept on an admin down. This patch
does that.
