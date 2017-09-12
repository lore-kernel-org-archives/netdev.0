From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [RFC PATCH] net: Introduce a socket option to enable picking tx
 queue based on rx queue.
Date: Tue, 12 Sep 2017 15:31:45 -0700
Message-ID: <ef594f90-0f76-bdf5-63ce-e8750ee0d60f@intel.com>
References: <1504222032-6337-1-git-send-email-sridhar.samudrala@intel.com>
 <CALx6S35sM1CDrFuNE+L59Op_wKTRpATLAdRJafihr0mB9+vQ8g@mail.gmail.com>
 <1505188437.15310.137.camel@edumazet-glaptop3.roam.corp.google.com>
 <b2ea01b3-b984-d59f-cbaf-b2fe6b5d9eea@intel.com>
 <1505231262.15310.149.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:13122 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751020AbdILWbq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 18:31:46 -0400
In-Reply-To: <1505231262.15310.149.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/12/2017 8:47 AM, Eric Dumazet wrote:
> On Mon, 2017-09-11 at 23:27 -0700, Samudrala, Sridhar wrote:
>> On 9/11/2017 8:53 PM, Eric Dumazet wrote:
>>> On Mon, 2017-09-11 at 20:12 -0700, Tom Herbert wrote:
>>>
>>>> Two ints in sock_common for this purpose is quite expensive and the
>>>> use case for this is limited-- even if a RX->TX queue mapping were
>>>> introduced to eliminate the queue pair assumption this still won't
>>>> help if the receive and transmit interfaces are different for the
>>>> connection. I think we really need to see some very compelling results
>>>> to be able to justify this.
>> Will try to collect and post some perf data with symmetric queue
>> configuration.
>>
>>> Yes, this is unreasonable cost.
>>>
>>> XPS should really cover the case already.
>>>    
>> Eric,
>>
>> Can you clarify how XPS covers the RX-> TX queue mapping case?
>> Is it possible to configure XPS to select TX queue based on the RX queue
>> of a flow?
>> IIUC, it is based on the CPU of the thread doing the transmit OR based
>> on skb->priority to TC mapping?
>> It may be possible to get this effect if the the threads are pinned to a
>> core, but if the app threads are
>> freely moving, i am not sure how XPS can be configured to select the TX
>> queue based on the RX queue of a flow.
> If application is freely moving, how NIC can properly select the RX
> queue so that packets are coming to the appropriate queue ?
The RX queue is selected via RSS and we don't want to move the flow based on
where the thread is running.
>
> This is called aRFS, and it does not scale to millions of flows.
> We tried in the past, and this went nowhere really, since the setup cost
> is prohibitive and DDOS vulnerable.
>
> XPS will follow the thread, since selection is done on current cpu.
>
> The problem is RX side. If application is free to migrate, then special
> support (aRFS) is needed from the hardware.
This may be true if most of the rx processing is happening in the 
interrupt context.
But with busy polling,  i think we don't need aRFS as a thread should be 
able to poll
any queue irrespective of where it is running.
>
> At least for passive connections, we already have all the support in the
> kernel so that you can have one thread per NIC queue, dealing with
> sockets that have incoming packets all received on one NIC RX queue.
> (And of course all TX packets will use the symmetric TX queue)
>
> SO_REUSEPORT plus appropriate BPF filter can achieve that.
>
> Say you have 32 queues, 32 cpus.
>
> Simply use 32 listeners, 32 threads (or 32 pools of threads)
Yes. This will work if each thread is pinned to a core associated with 
the RX interrupt.
It may not be possible to pin the threads to a core.
Instead we want to associate a thread to a queue and do all the RX and 
TX completion
of a queue in the same thread context via busy polling.

Thanks
Sridhar
