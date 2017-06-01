From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: Oops with commit 6d18c73 bridge: start hello_timer when enabling
 KERNEL_STP in br_stp_start
Date: Thu, 1 Jun 2017 17:45:07 +0300
Message-ID: <06ef2ff1-f29d-a163-3226-7bd43c7a407c@cumulusnetworks.com>
References: <alpine.LFD.2.20.1705311816090.1727@schleppi>
 <CADvbK_c_bXnPL5NdADj=aCv8f-A0wPKdUmQJqm=XDRf0rizXcA@mail.gmail.com>
 <alpine.LFD.2.20.1706011415500.1688@schleppi>
 <a6495939-350d-31a4-88db-852344a19a02@cumulusnetworks.com>
 <edd9b7f0-0345-975e-dc97-d5261134c7b4@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Haidong Li <haili@redhat.com>, Ivan Vecera <cera@cera.cz>,
        Stephen Hemminger <stephen@networkplumber.org>,
        network dev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Xin Long <lucien.xin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <edd9b7f0-0345-975e-dc97-d5261134c7b4@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/06/17 17:16, Nikolay Aleksandrov wrote:
> On 01/06/17 17:00, Nikolay Aleksandrov wrote:
>> On 01/06/17 15:34, Sebastian Ott wrote:
>>> On Thu, 1 Jun 2017, Xin Long wrote:
>>>> On Thu, Jun 1, 2017 at 12:32 AM, Sebastian Ott
>>>> <sebott@linux.vnet.ibm.com> wrote:
>>>>> [...]
>>>> I couldn't see any bridge-related thing here, and it couldn't be reproduced
>>>> with virbr0 (stp=1) on my box (on both s390x and x86_64), I guess there
>>>> is something else in you machine.
>>>>
>>>> With the latest upstream kernel, can you remove libvirt (virbr0) and boot your
>>>> machine normally, then:
>>>> # brctl addbr br0
>>>> # ip link set br0 up
>>>> # brctl stp br0 on
>>>>
>>>> to check if it will still hang.
>>>
>>> Nope. That doesn't hang.
>>>
>>>
>>>> If it can't be reproduced in this way, pls add this on your kernel:
>>>>
>>>> --- a/net/bridge/br_stp_if.c
>>>> +++ b/net/bridge/br_stp_if.c
>>>> @@ -178,9 +178,11 @@ static void br_stp_start(struct net_bridge *br)
>>>>                 br->stp_enabled = BR_KERNEL_STP;
>>>>                 br_debug(br, "using kernel STP\n");
>>>>
>>>> +               WARN_ON(1);
>>>>                 /* To start timers on any ports left in blocking */
>>>>                 mod_timer(&br->hello_timer, jiffies + br->hello_time);
>>>>                 br_port_state_selection(br);
>>>> +               pr_warn("hello timer start done\n");
>>>>         }
>>>>
>>>>         spin_unlock_bh(&br->lock);
>>>> diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
>>>> index 60b6fe2..c98b3e5 100644
>>>> --- a/net/bridge/br_stp_timer.c
>>>> +++ b/net/bridge/br_stp_timer.c
>>>> @@ -40,7 +40,7 @@ static void br_hello_timer_expired(unsigned long arg)
>>>>         if (br->dev->flags & IFF_UP) {
>>>>                 br_config_bpdu_generation(br);
>>>>
>>>> -               if (br->stp_enabled == BR_KERNEL_STP)
>>>> +               if (br->stp_enabled != BR_USER_STP)
>>>>                         mod_timer(&br->hello_timer,
>>>>                                   round_jiffies(jiffies + br->hello_time));
>>>>
>>>>
>>>> let's see if it hangs when starting the timer. Thanks.
>>>
>>> No hang either:
>>>
>> [snip]
>> Could you please try the patch below ?
>>
>> ---
>>
>> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
>> index 4efd5d54498a..89110319ef0f 100644
>> --- a/net/bridge/br_stp_if.c
>> +++ b/net/bridge/br_stp_if.c
>> @@ -173,7 +173,8 @@ static void br_stp_start(struct net_bridge *br)
>>  		br_debug(br, "using kernel STP\n");
>>  
>>  		/* To start timers on any ports left in blocking */
>> -		mod_timer(&br->hello_timer, jiffies + br->hello_time);
>> +		if (br->dev->flags & IFF_UP)
>> +			mod_timer(&br->hello_timer, jiffies + br->hello_time);
>>  		br_port_state_selection(br);
>>  	}
>>  
>>
> 
> Ah nevermind, this patch reverts it back to the previous state.
> 

Okay, I saw the problem and can reliably reproduce it. I will send a fix for testing
in a few minutes. I think the issue is that the timer can be started before the bridge
even goes up, i.e. create bridge -> brctl stp br0 on -> ip l del br0
so the del_timer_sync() doesn't get executed and thus it's still armed.

$ while :; do ip l add br0 type bridge hello_time 100; brctl stp br0 on; ip l del br0; done;
