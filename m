From: Andrew Dickinson <andrew@whydna.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Fri, 1 May 2009 00:23:34 -0700
Message-ID: <606676310905010023l7bd0f153m35e65fb92e5b8c1e@mail.gmail.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	 <20090430.022417.07019547.davem@davemloft.net>
	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>
	 <20090430.070811.260649067.davem@davemloft.net>
	 <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>
	 <49FA932B.4030405@cosmosbay.com>
	 <606676310904302319u1eacc634qde4b1f70e9936779@mail.gmail.com>
	 <49FA9940.1010203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jelaas@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:45864 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbZEAHXf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 03:23:35 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1710078wfd.4
        for <netdev@vger.kernel.org>; Fri, 01 May 2009 00:23:34 -0700 (PDT)
In-Reply-To: <49FA9940.1010203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 11:40 PM, Eric Dumazet <dada1@cosmosbay.com> wr=
ote:
> Andrew Dickinson a =E9crit :
>> On Thu, Apr 30, 2009 at 11:14 PM, Eric Dumazet <dada1@cosmosbay.com>=
 wrote:
>>> Andrew Dickinson a =E9crit :
>>>> OK... I've got some more data on it...
>>>>
>>>> I passed a small number of packets through the system and added a =
ton
>>>> of printks to it ;-P
>>>>
>>>> Here's the distribution of values as seen by
>>>> skb_rx_queue_recorded()... count on the left, value on the right:
>>>> =A0 =A0 =A037 0
>>>> =A0 =A0 =A031 1
>>>> =A0 =A0 =A031 2
>>>> =A0 =A0 =A039 3
>>>> =A0 =A0 =A037 4
>>>> =A0 =A0 =A031 5
>>>> =A0 =A0 =A042 6
>>>> =A0 =A0 =A039 7
>>>>
>>>> That's nice and even.... =A0Here's what's getting returned from th=
e
>>>> skb_tx_hash(). =A0Again, count on the left, value on the right:
>>>> =A0 =A0 =A031 0
>>>> =A0 =A0 =A081 1
>>>> =A0 =A0 =A037 2
>>>> =A0 =A0 =A070 3
>>>> =A0 =A0 =A037 4
>>>> =A0 =A0 =A031 6
>>>>
>>>> Note that we're entirely missing 5 and 7 and that those interrupts
>>>> seem to have gotten munged onto 1 and 3.
>>>>
>>>> I think the voodoo lies within:
>>>> =A0 =A0 return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32=
);
>>>>
>>>> David, =A0I made the change that you suggested:
>>>> =A0 =A0 =A0 =A0 //hash =3D skb_get_rx_queue(skb);
>>>> =A0 =A0 =A0 =A0 return skb_get_rx_queue(skb) % dev->real_num_tx_qu=
eues;
>>>>
>>>> And now, I see a nice even mixing of interrupts on the TX side (ya=
y!).
>>>>
>>>> However, my problem's not solved entirely... here's what top is sh=
owing me:
>>>> top - 23:37:49 up 9 min, =A01 user, =A0load average: 3.93, 2.68, 1=
=2E21
>>>> Tasks: 119 total, =A0 5 running, 114 sleeping, =A0 0 stopped, =A0 =
0 zombie
>>>> Cpu0 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.3%id, =A00.0%wa, =A0=
0.3%hi, =A00.3%si, =A00.0%st
>>>> Cpu1 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A00.0%id, =A00.0%wa, =A0=
4.3%hi, 95.7%si, =A00.0%st
>>>> Cpu2 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.7%id, =A00.0%wa, =A0=
0.0%hi, =A00.3%si, =A00.0%st
>>>> Cpu3 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A00.0%id, =A00.0%wa, =A0=
4.3%hi, 95.7%si, =A00.0%st
>>>> Cpu4 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.3%id, =A00.0%wa, =A0=
0.3%hi, =A00.3%si, =A00.0%st
>>>> Cpu5 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A02.0%id, =A00.0%wa, =A0=
4.0%hi, 94.0%si, =A00.0%st
>>>> Cpu6 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni,100.0%id, =A00.0%wa, =A0=
0.0%hi, =A00.0%si, =A00.0%st
>>>> Cpu7 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A05.6%id, =A00.0%wa, =A0=
2.3%hi, 92.1%si, =A00.0%st
>>>> Mem: =A016403476k total, =A0 335884k used, 16067592k free, =A0 =A0=
10108k buffers
>>>> Swap: =A02096472k total, =A0 =A0 =A0 =A00k used, =A02096472k free,=
 =A0 146364k cached
>>>>
>>>> =A0 PID USER =A0 =A0 =A0PR =A0NI =A0VIRT =A0RES =A0SHR S %CPU %MEM=
 =A0 =A0TIME+ =A0COMMAND
>>>> =A0 =A0 7 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 1=
00.2 =A00.0 =A0 5:35.24
>>>> ksoftirqd/1
>>>> =A0 =A013 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 1=
00.2 =A00.0 =A0 5:36.98
>>>> ksoftirqd/3
>>>> =A0 =A019 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 9=
7.8 =A00.0 =A0 5:34.52
>>>> ksoftirqd/5
>>>> =A0 =A025 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 9=
4.5 =A00.0 =A0 5:13.56
>>>> ksoftirqd/7
>>>> =A03905 root =A0 =A0 =A020 =A0 0 12612 1084 =A0820 R =A00.3 =A00.0=
 =A0 0:00.14 top
>>>> <snip>
>>>>
>>>>
>>>> It appears that only the odd CPUs are actually handling the
>>>> interrupts, which doesn't jive with what /proc/interrupts shows me=
:
>>>> =A0 =A0 =A0 =A0 =A0 =A0 CPU0 =A0 =A0 =A0 CPU1 =A0 =A0 CPU2 =A0 =A0=
 =A0 CPU3 =A0 =A0 =A0 CPU4 =A0 =A0 =A0 CPU5 =A0 =A0 =A0 CPU6 =A0 =A0 =A0=
 CPU7
>>>> =A0 66: =A0 =A02970565 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-0
>>>> =A0 67: =A0 =A0 =A0 =A0 28 =A0 =A0 821122 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-1
>>>> =A0 68: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A02943299 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-2
>>>> =A0 69: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 817776 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-3
>>>> =A0 70: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A02963924
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-4
>>>> =A0 71: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 821032 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =
=A0 =A0 eth2-rx-5
>>>> =A0 72: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A02979987 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0=
 =A0 =A0eth2-rx-6
>>>> =A0 73: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 845422 =A0 PCI-MSI-edge =A0 =A0 =A0=
 =A0 =A0eth2-rx-7
>>>> =A0 74: =A0 =A04664732 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-0
>>>> =A0 75: =A0 =A0 =A0 =A0 34 =A0 =A04679312 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-1
>>>> =A0 76: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A04665014 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-2
>>>> =A0 77: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A04681531 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-3
>>>> =A0 78: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A04665793
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-4
>>>> =A0 79: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 4671596 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge=
 =A0 =A0eth2-tx-5
>>>> =A0 80: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A04665279 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0=
 =A0 =A0eth2-tx-6
>>>> =A0 81: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A04664504 =A0 PCI-MSI-edge =A0 =A0 =A0=
 =A0 =A0eth2-tx-7
>>>> =A0 82: =A0 =A0 =A0 =A0 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =
=A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>>>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2:lsc
>>>>
>>>>
>>>> Why would ksoftirqd only run on half of the cores (and only the od=
d
>>>> ones to boot)? =A0The one commonality that's striking me is that t=
hat
>>>> all the odd CPU#'s are on the same physical processor:
>>>>
>>>> -bash-3.2# cat /proc/cpuinfo | grep -E '(physical|processor)' | gr=
ep -v virtual
>>>> processor =A0 =A0 : 0
>>>> physical id =A0 : 0
>>>> processor =A0 =A0 : 1
>>>> physical id =A0 : 1
>>>> processor =A0 =A0 : 2
>>>> physical id =A0 : 0
>>>> processor =A0 =A0 : 3
>>>> physical id =A0 : 1
>>>> processor =A0 =A0 : 4
>>>> physical id =A0 : 0
>>>> processor =A0 =A0 : 5
>>>> physical id =A0 : 1
>>>> processor =A0 =A0 : 6
>>>> physical id =A0 : 0
>>>> processor =A0 =A0 : 7
>>>> physical id =A0 : 1
>>>>
>>>> I did compile the kernel with NUMA support... am I being bitten by
>>>> something there? =A0Other thoughts on where I should look.
>>>>
>>>> Also... is there an incantation to get NAPI to work in the torvald=
s
>>>> kernel? =A0As you can see, I'm generating quite a few interrrupts.
>>>>
>>>> -A
>>>>
>>>>
>>>> On Thu, Apr 30, 2009 at 7:08 AM, David Miller <davem@davemloft.net=
> wrote:
>>>>> From: Andrew Dickinson <andrew@whydna.net>
>>>>> Date: Thu, 30 Apr 2009 07:04:33 -0700
>>>>>
>>>>>> =A0I'll do some debugging around skb_tx_hash() and see if I can =
make
>>>>>> sense of it. =A0I'll let you know what I find. =A0My hypothesis =
is that
>>>>>> skb_record_rx_queue() isn't being called, but I should dig into =
it
>>>>>> before I start making claims. ;-P
>>>>> That's one possibility.
>>>>>
>>>>> Another is that the hashing isn't working out. =A0One way to
>>>>> play with that is to simply replace the:
>>>>>
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb_get_rx_queue(skb);
>>>>>
>>>>> in skb_tx_hash() with something like:
>>>>>
>>>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return skb_get_rx_queue(skb) % dev=
->real_num_tx_queues;
>>>>>
>>>>> and see if that improves the situation.
>>>>>
>>> Hi Andrew
>>>
>>> Please try following patch (I dont have multi-queue NIC, sorry)
>>>
>>> I will do the followup patch if this ones corrects the distribution=
 problem
>>> you noticed.
>>>
>>> Thanks very much for all your findings.
>>>
>>> [PATCH] net: skb_tx_hash() improvements
>>>
>>> When skb_rx_queue_recorded() is true, we dont want to use jash dist=
ribution
>>> as the device driver exactly told us which queue was selected at RX=
 time.
>>> jhash makes a statistical shuffle, but this wont work with 8 static=
 inputs.
>>>
>>> Later improvements would be to compute reciprocal value of real_num=
_tx_queues
>>> to avoid a divide here. But this computation should be done once,
>>> when real_num_tx_queues is set. This needs a separate patch, and a =
new
>>> field in struct net_device.
>>>
>>> Reported-by: Andrew Dickinson <andrew@whydna.net>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index 308a7d0..e2e9e4a 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -1735,11 +1735,12 @@ u16 skb_tx_hash(const struct net_device *de=
v, const struct sk_buff *skb)
>>> =A0{
>>> =A0 =A0 =A0 =A0u32 hash;
>>>
>>> - =A0 =A0 =A0 if (skb_rx_queue_recorded(skb)) {
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D skb_get_rx_queue(skb);
>>> - =A0 =A0 =A0 } else if (skb->sk && skb->sk->sk_hash) {
>>> + =A0 =A0 =A0 if (skb_rx_queue_recorded(skb))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return skb_get_rx_queue(skb) % dev->r=
eal_num_tx_queues;
>>> +
>>> + =A0 =A0 =A0 if (skb->sk && skb->sk->sk_hash)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb->sk->sk_hash;
>>> - =A0 =A0 =A0 } else
>>> + =A0 =A0 =A0 else
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb->protocol;
>>>
>>> =A0 =A0 =A0 =A0hash =3D jhash_1word(hash, skb_tx_hashrnd);
>>>
>>>
>>
>> Eric,
>>
>> That's exactly what I did! =A0It solved the problem of hot-spots on =
some
>> interrupts. =A0However, I now have a new problem (which is documente=
d in
>> my previous posts). =A0The short of it is that I'm only seeing 4 (ou=
t of
>> 8) ksoftirqd's busy under heavy load... the other 4 seem idle. =A0Th=
e
>> busy 4 are always on one physical package (but not always the same
>> package (it'll change on reboot or when I change some parameters via
>> ethtool), but never both. =A0This, despite /proc/interrupts showing =
me
>> that all 8 interrupts are being hit evenly. =A0There's more details =
in
>> my last mail. ;-D
>>
>
> Well, I was reacting to your 'voodo' comment about
>
> return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
>
> Since this is not the problem. Problem is coming from jhash() which s=
huffles
> the input, while in your case we want to select same output queue
> because of cpu affinities. No shuffle required.

Agreed.  I don't want to jhash(), and I'm not.

> (assuming cpu0 is handling tx-queue-0 and rx-queue-0,
> =A0 =A0 =A0 =A0 =A0cpu1 is handling tx-queue-1 and rx-queue-1, and so=
 on...)

That's a correct assumption. :D

> Then /proc/interrupts show your rx interrupts are not evenly distribu=
ted.
>
> Or that ksoftirqd is triggered only on one physical cpu, while on oth=
er
> cpu, softirqds are not run from ksoftirqd. Its only a matter of load.

Hrmm... more fuel for the fire...

The NIC seems to be doing a good job of hashing the incoming data and
the kernel is now finding the right TX queue:
-bash-3.2# ethtool -S eth2 | grep -vw 0 | grep packets
     rx_packets: 1286009099
     tx_packets: 1287853570
     tx_queue_0_packets: 162469405
     tx_queue_1_packets: 162452446
     tx_queue_2_packets: 162481160
     tx_queue_3_packets: 162441839
     tx_queue_4_packets: 162484930
     tx_queue_5_packets: 162478402
     tx_queue_6_packets: 162492530
     tx_queue_7_packets: 162477162
     rx_queue_0_packets: 162469449
     rx_queue_1_packets: 162452440
     rx_queue_2_packets: 162481186
     rx_queue_3_packets: 162441885
     rx_queue_4_packets: 162484949
     rx_queue_5_packets: 162478427

Here's where it gets juicy.  If I reduce the rate at which I'm pushing
traffic to a 0-loss level (in this case about 2.2Mpps), then top looks
as follow:
Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu7  :  0.0%us,  0.3%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.0%hi,  0.3%si, =
 0.0%st

And if I watch /proc/interrupts, I see that all of the tx and rx
queues are handling a fairly similar number of interrupts (ballpark,
7-8k/sec on rx, 10k on tx).

OK... now let me double the packet rate (to about 4.4Mpps), top looks l=
ike this:

Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,  1.9%id,  0.0%wa,  5.5%hi, 92.5%si, =
 0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni, 98.7%id,  0.0%wa,  0.0%hi,  1.3%si, =
 0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,  2.3%id,  0.0%wa,  4.9%hi, 92.9%si, =
 0.0%st
Cpu3  :  0.0%us,  0.3%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.0%hi,  1.9%si, =
 0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,  5.2%id,  0.0%wa,  5.2%hi, 89.6%si, =
 0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.3%hi,  1.9%si, =
 0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,  0.3%id,  0.0%wa,  4.9%hi, 94.8%si, =
 0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si, =
 0.0%st

And if I watch /proc/interrupts again, I see that the even-CPUs (i.e.
0,2,4, and 6) RX queues are receiving relatively few interrupts
(5-ish/sec (not 5k... just 5)) and the odd-CPUS RX queues are
receiving about 2-3k/sec.  What's extra strange is that the TX queues
are still handling about 10k/sec each.

So, below some magic threshold (approx 2.3Mpps), the box is basically
idle and happily routing all the packets (I can confirm that my
network test device ixia is showing 0-loss).  Above the magic
threshold, the box starts acting as described above and I'm unable to
push it beyond that threshold.  While I understand that there are
limits to how fast I can route packets (obviously), it seems very
strange that I'm seeing this physical-CPU affinity on the ksoftirqd
"processes".

Here's how fragile this "magic threshold" is...  2.292 Mpps, box looks
idle, 0 loss.   2.300 Mpps, even-CPU ksoftirqd processes at 50%-ish.
2.307 Mpps, even-CPU ksoftirqd processes at 75%.  2.323 Mpps, even-CPU
ksoftirqd proccesses at 100%.  Never during this did the odd-CPU
ksoftirqd processes show any utilization at all.

These are 64-byte frames, so I shouldn't be hitting any bandwidth
issues that I'm aware of, 1.3Gbps in, and 1.3Gbps out (same NIC, I'm
just routing packets back out the one NIC).

=3D/

-A
