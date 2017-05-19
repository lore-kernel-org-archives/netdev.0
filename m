From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] bridge: start hello_timer when enabling KERNEL_STP in
 br_stp_start
Date: Fri, 19 May 2017 18:03:34 +0300
Message-ID: <fcff40a1-8114-39d6-420c-210d0b6d73a6@cumulusnetworks.com>
References: <6e78bfea3969ca1a937b37e28e796a3047b82615.1495203629.git.lucien.xin@gmail.com>
 <cf69d5e5-1acf-2ed4-b6cc-fdb1236e7a66@cumulusnetworks.com>
 <20170519144823.GF28091@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Xin Long <lucien.xin@gmail.com>,
        network dev <netdev@vger.kernel.org>, davem@davemloft.net,
        cera@cera.cz
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37420 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdESPDi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 11:03:38 -0400
Received: by mail-wm0-f54.google.com with SMTP id d127so89041924wmf.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 08:03:37 -0700 (PDT)
In-Reply-To: <20170519144823.GF28091@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/19/17 5:48 PM, Florian Westphal wrote:
> Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
>> On 5/19/17 5:20 PM, Xin Long wrote:
>>> Since commit 76b91c32dd86 ("bridge: stp: when using userspace stp stop
>>> kernel hello and hold timers"), bridge would not start hello_timer if
>>> stp_enabled is not KERNEL_STP when br_dev_open.
>>>
>>> The problem is even if users set stp_enabled with KERNEL_STP later,
>>> the timer will still not be started. It causes that KERNEL_STP can
>>> not really work. Users have to re-ifup the bridge to avoid this.
>>>
>>> This patch is to fix it by starting br->hello_timer when enabling
>>> KERNEL_STP in br_stp_start.
>>>
>>> As an improvement, it's also to start hello_timer again only when
>>> br->stp_enabled is KERNEL_STP in br_hello_timer_expired, there is
>>> no reason to start the timer again when it's NO_STP.
>>>
>>> Fixes: 76b91c32dd86 ("bridge: stp: when using userspace stp stop kernel hello and hold timers")
>>> Reported-by: Haidong Li <haili@redhat.com>
>>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>>> ---
>>>   net/bridge/br_stp_if.c    | 1 +
>>>   net/bridge/br_stp_timer.c | 2 +-
>>>   2 files changed, 2 insertions(+), 1 deletion(-)
>>>
>>
>> This doesn't make much sense to me, how do you change from USER_STP to
>> KERNEL_STP without first going through NO_STP ?
> 
> This is easily rerpoduceable via:
> 
> ip link add vethin1 type veth peer name vethout1
> ip link add vethin2 type veth peer name vethout2
> 
> ip link set vethin1 up
> ip link set vethin2 up
> 
> ip link set vethout1 up
> ip link set vethout2 up
> 
> brctl addbr br0
> brctl addbr br1
> 
> brctl stp br0 on
> brctl stp br1 on

I think this step with moving NO_STP -> KERNEL_STP should be last, then
I can see how the timer won't be started.

> 
> brctl addif br0 vethin1
> brctl addif br0 vethin2
> 
> brctl addif br1 vethout1
> brctl addif br1 vethout2
> 
> ip link set br0 up
> ip link set br1 up
> 
