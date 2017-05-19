From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: start hello_timer when enabling KERNEL_STP in
 br_stp_start
Date: Fri, 19 May 2017 18:05:57 +0300
Message-ID: <3c987d40-6e47-3d7c-c6b9-b46ee5afcd57@cumulusnetworks.com>
References: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
 <cf69d5e5-1acf-2ed4-b6cc-fdb1236e7a66@cumulusnetworks.com>
 <CA+Nub0YKgM7dMDYdi43sO2znVtCzToq0dAr5TFEb4Jmw+6zw+w@mail.gmail.com>
 <026b6024-4ec8-5060-f19a-163ed485207c@cumulusnetworks.com>
 <CA+Nub0Zi6-2PL3+6v5r3t3CD6NowJY_j=bd+x4NA42KKiPPp7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: ivan.vecera@cera.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:34328 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751228AbdESPGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 11:06:00 -0400
Received: by mail-wr0-f182.google.com with SMTP id l9so18944116wre.1
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 08:06:00 -0700 (PDT)
In-Reply-To: <CA+Nub0Zi6-2PL3+6v5r3t3CD6NowJY_j=bd+x4NA42KKiPPp7A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 6:03 PM, Ivan Vecera wrote:
> 2017-05-19 16:57 GMT+02:00 Nikolay Aleksandrov <nikolay@cumulusnetworks.com>:
>> On 5/19/17 5:51 PM, Ivan Vecera wrote:
>>>
>>> 2017-05-19 16:45 GMT+02:00 Nikolay Aleksandrov
>>> <nikolay@cumulusnetworks.com>:
>>>>
>>>> On 5/19/17 5:20 PM, Xin Long wrote:
>>>>>
>>>>>
>>>>> Since commit 76b91c32dd86 ("bridge: stp: when using userspace stp stop
>>>>> kernel hello and hold timers"), bridge would not start hello_timer if
>>>>> stp_enabled is not KERNEL_STP when br_dev_open.
>>>>>
>>>>> The problem is even if users set stp_enabled with KERNEL_STP later,
>>>>> the timer will still not be started. It causes that KERNEL_STP can
>>>>> not really work. Users have to re-ifup the bridge to avoid this.
>>>>>
>>>>> This patch is to fix it by starting br->hello_timer when enabling
>>>>> KERNEL_STP in br_stp_start.
>>>>>
>>>>> As an improvement, it's also to start hello_timer again only when
>>>>> br->stp_enabled is KERNEL_STP in br_hello_timer_expired, there is
>>>>> no reason to start the timer again when it's NO_STP.
>>>>>
>>>>> Fixes: 76b91c32dd86 ("bridge: stp: when using userspace stp stop kernel
>>>>> hello and hold timers")
>>>>> Reported-by: Haidong Li <haili@redhat.com>
>>>>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>>>>> ---
>>>>>     net/bridge/br_stp_if.c    | 1 +
>>>>>     net/bridge/br_stp_timer.c | 2 +-
>>>>>     2 files changed, 2 insertions(+), 1 deletion(-)
>>>>>
>>>>
>>>> This doesn't make much sense to me, how do you change from USER_STP to
>>>> KERNEL_STP without first going through NO_STP ?
>>>>
>>>> If you go through NO_STP then all will be fine because br_stp_stop will
>>>> restart
>>>> the timers if the previous val was USER_STP.
>>>>
>>> The problem occurs when KERNEL_STP is enabled if the bridge itself is
>>> already
>>> up. Then the hello_timer is not started. If the hello and hold timers
>>> should run only
>>> when KERNEL_STP is used then there are another problematic places
>>> (will send follow-up).
>>>
>>> Ivan
>>>
>>
>> Oh, the problem seems to be rather going from NO_STP -> KERNEL_STP only
>> then, because you cannot do direct USER_STP -> KERNEL_STP.
>>
> No only NO_STP->KERNEL_STP but KERNEL_STP->NO_STP as well as USER_STP->NO_STP:
> 
> 1) NO_STP->KERNEL_STP issue
> hello_timer should be started in br_stp_start() - this patch
> 

Right, I was talking only about this patch. By the way what about
the port hold_timers ? This patch only starts the hello_timer.

> 2) KERNEL_STP->NO_STP issue
> hello timer and hold timers should be stopped (deleted) in br_stp_stop()
> 
> 3) USER_STP->NO_STP issue
> hello timer and hold timers should NOT be started in br_stp_stop()
> 

Yep, ack.

> Ivan
> 
