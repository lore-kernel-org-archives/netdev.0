From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Fri, 01 May 2009 09:31:41 +0200
Message-ID: <49FAA55D.7070406@cosmosbay.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>	 <20090430.022417.07019547.davem@davemloft.net>	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>	 <20090430.070811.260649067.davem@davemloft.net>	 <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>	 <49FA932B.4030405@cosmosbay.com>	 <606676310904302319u1eacc634qde4b1f70e9936779@mail.gmail.com>	 <49FA9940.1010203@cosmosbay.com> <606676310905010023l7bd0f153m35e65fb92e5b8c1e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jelaas@gmail.com,
	netdev@vger.kernel.org
To: Andrew Dickinson <andrew@whydna.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55284 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbZEAHbv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 03:31:51 -0400
In-Reply-To: <606676310905010023l7bd0f153m35e65fb92e5b8c1e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Dickinson a =E9crit :
> On Thu, Apr 30, 2009 at 11:40 PM, Eric Dumazet <dada1@cosmosbay.com> =
wrote:
>> Andrew Dickinson a =E9crit :
>>> On Thu, Apr 30, 2009 at 11:14 PM, Eric Dumazet <dada1@cosmosbay.com=
> wrote:
>>>> Andrew Dickinson a =E9crit :
>>>>> OK... I've got some more data on it...
>>>>>
>>>>> I passed a small number of packets through the system and added a=
 ton
>>>>> of printks to it ;-P
>>>>>
>>>>> Here's the distribution of values as seen by
>>>>> skb_rx_queue_recorded()... count on the left, value on the right:
>>>>>      37 0
>>>>>      31 1
>>>>>      31 2
>>>>>      39 3
>>>>>      37 4
>>>>>      31 5
>>>>>      42 6
>>>>>      39 7
>>>>>
>>>>> That's nice and even....  Here's what's getting returned from the
>>>>> skb_tx_hash().  Again, count on the left, value on the right:
>>>>>      31 0
>>>>>      81 1
>>>>>      37 2
>>>>>      70 3
>>>>>      37 4
>>>>>      31 6
>>>>>
>>>>> Note that we're entirely missing 5 and 7 and that those interrupt=
s
>>>>> seem to have gotten munged onto 1 and 3.
>>>>>
>>>>> I think the voodoo lies within:
>>>>>     return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
>>>>>
>>>>> David,  I made the change that you suggested:
>>>>>         //hash =3D skb_get_rx_queue(skb);
>>>>>         return skb_get_rx_queue(skb) % dev->real_num_tx_queues;
>>>>>
>>>>> And now, I see a nice even mixing of interrupts on the TX side (y=
ay!).
>>>>>
>>>>> However, my problem's not solved entirely... here's what top is s=
howing me:
>>>>> top - 23:37:49 up 9 min,  1 user,  load average: 3.93, 2.68, 1.21
>>>>> Tasks: 119 total,   5 running, 114 sleeping,   0 stopped,   0 zom=
bie
>>>>> Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.3%hi,  0.=
3%si,  0.0%st
>>>>> Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,  0.0%id,  0.0%wa,  4.3%hi, 95.=
7%si,  0.0%st
>>>>> Cpu2  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.=
3%si,  0.0%st
>>>>> Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,  0.0%id,  0.0%wa,  4.3%hi, 95.=
7%si,  0.0%st
>>>>> Cpu4  :  0.0%us,  0.0%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.3%hi,  0.=
3%si,  0.0%st
>>>>> Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,  2.0%id,  0.0%wa,  4.0%hi, 94.=
0%si,  0.0%st
>>>>> Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.=
0%si,  0.0%st
>>>>> Cpu7  :  0.0%us,  0.0%sy,  0.0%ni,  5.6%id,  0.0%wa,  2.3%hi, 92.=
1%si,  0.0%st
>>>>> Mem:  16403476k total,   335884k used, 16067592k free,    10108k =
buffers
>>>>> Swap:  2096472k total,        0k used,  2096472k free,   146364k =
cached
>>>>>
>>>>>   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMM=
AND
>>>>>     7 root      15  -5     0    0    0 R 100.2  0.0   5:35.24
>>>>> ksoftirqd/1
>>>>>    13 root      15  -5     0    0    0 R 100.2  0.0   5:36.98
>>>>> ksoftirqd/3
>>>>>    19 root      15  -5     0    0    0 R 97.8  0.0   5:34.52
>>>>> ksoftirqd/5
>>>>>    25 root      15  -5     0    0    0 R 94.5  0.0   5:13.56
>>>>> ksoftirqd/7
>>>>>  3905 root      20   0 12612 1084  820 R  0.3  0.0   0:00.14 top
>>>>> <snip>
>>>>>
>>>>>
>>>>> It appears that only the odd CPUs are actually handling the
>>>>> interrupts, which doesn't jive with what /proc/interrupts shows m=
e:
>>>>>             CPU0       CPU1     CPU2       CPU3       CPU4       =
CPU5       CPU6       CPU7
>>>>>   66:    2970565          0          0          0          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-rx-0
>>>>>   67:         28     821122          0          0          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-rx-1
>>>>>   68:         28          0    2943299          0          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-rx-2
>>>>>   69:         28          0          0     817776          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-rx-3
>>>>>   70:         28          0          0          0    2963924
>>>>> 0          0          0   PCI-MSI-edge          eth2-rx-4
>>>>>   71:         28          0          0          0          0
>>>>> 821032          0          0   PCI-MSI-edge     eth2-rx-5
>>>>>   72:         28          0          0          0          0
>>>>> 0    2979987          0   PCI-MSI-edge          eth2-rx-6
>>>>>   73:         28          0          0          0          0
>>>>> 0          0     845422   PCI-MSI-edge          eth2-rx-7
>>>>>   74:    4664732          0          0          0          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-tx-0
>>>>>   75:         34    4679312          0          0          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-tx-1
>>>>>   76:         28          0    4665014          0          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-tx-2
>>>>>   77:         28          0          0    4681531          0
>>>>> 0          0          0   PCI-MSI-edge          eth2-tx-3
>>>>>   78:         28          0          0          0    4665793
>>>>> 0          0          0   PCI-MSI-edge          eth2-tx-4
>>>>>   79:         28          0          0          0          0
>>>>> 4671596          0          0   PCI-MSI-edge    eth2-tx-5
>>>>>   80:         28          0          0          0          0
>>>>> 0    4665279          0   PCI-MSI-edge          eth2-tx-6
>>>>>   81:         28          0          0          0          0
>>>>> 0          0    4664504   PCI-MSI-edge          eth2-tx-7
>>>>>   82:          2          0          0          0          0
>>>>> 0          0          0   PCI-MSI-edge          eth2:lsc
>>>>>
>>>>>
>>>>> Why would ksoftirqd only run on half of the cores (and only the o=
dd
>>>>> ones to boot)?  The one commonality that's striking me is that th=
at
>>>>> all the odd CPU#'s are on the same physical processor:
>>>>>
>>>>> -bash-3.2# cat /proc/cpuinfo | grep -E '(physical|processor)' | g=
rep -v virtual
>>>>> processor     : 0
>>>>> physical id   : 0
>>>>> processor     : 1
>>>>> physical id   : 1
>>>>> processor     : 2
>>>>> physical id   : 0
>>>>> processor     : 3
>>>>> physical id   : 1
>>>>> processor     : 4
>>>>> physical id   : 0
>>>>> processor     : 5
>>>>> physical id   : 1
>>>>> processor     : 6
>>>>> physical id   : 0
>>>>> processor     : 7
>>>>> physical id   : 1
>>>>>
>>>>> I did compile the kernel with NUMA support... am I being bitten b=
y
>>>>> something there?  Other thoughts on where I should look.
>>>>>
>>>>> Also... is there an incantation to get NAPI to work in the torval=
ds
>>>>> kernel?  As you can see, I'm generating quite a few interrrupts.
>>>>>
>>>>> -A
>>>>>
>>>>>
>>>>> On Thu, Apr 30, 2009 at 7:08 AM, David Miller <davem@davemloft.ne=
t> wrote:
>>>>>> From: Andrew Dickinson <andrew@whydna.net>
>>>>>> Date: Thu, 30 Apr 2009 07:04:33 -0700
>>>>>>
>>>>>>>  I'll do some debugging around skb_tx_hash() and see if I can m=
ake
>>>>>>> sense of it.  I'll let you know what I find.  My hypothesis is =
that
>>>>>>> skb_record_rx_queue() isn't being called, but I should dig into=
 it
>>>>>>> before I start making claims. ;-P
>>>>>> That's one possibility.
>>>>>>
>>>>>> Another is that the hashing isn't working out.  One way to
>>>>>> play with that is to simply replace the:
>>>>>>
>>>>>>                hash =3D skb_get_rx_queue(skb);
>>>>>>
>>>>>> in skb_tx_hash() with something like:
>>>>>>
>>>>>>                return skb_get_rx_queue(skb) % dev->real_num_tx_q=
ueues;
>>>>>>
>>>>>> and see if that improves the situation.
>>>>>>
>>>> Hi Andrew
>>>>
>>>> Please try following patch (I dont have multi-queue NIC, sorry)
>>>>
>>>> I will do the followup patch if this ones corrects the distributio=
n problem
>>>> you noticed.
>>>>
>>>> Thanks very much for all your findings.
>>>>
>>>> [PATCH] net: skb_tx_hash() improvements
>>>>
>>>> When skb_rx_queue_recorded() is true, we dont want to use jash dis=
tribution
>>>> as the device driver exactly told us which queue was selected at R=
X time.
>>>> jhash makes a statistical shuffle, but this wont work with 8 stati=
c inputs.
>>>>
>>>> Later improvements would be to compute reciprocal value of real_nu=
m_tx_queues
>>>> to avoid a divide here. But this computation should be done once,
>>>> when real_num_tx_queues is set. This needs a separate patch, and a=
 new
>>>> field in struct net_device.
>>>>
>>>> Reported-by: Andrew Dickinson <andrew@whydna.net>
>>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>>>
>>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>>> index 308a7d0..e2e9e4a 100644
>>>> --- a/net/core/dev.c
>>>> +++ b/net/core/dev.c
>>>> @@ -1735,11 +1735,12 @@ u16 skb_tx_hash(const struct net_device *d=
ev, const struct sk_buff *skb)
>>>>  {
>>>>        u32 hash;
>>>>
>>>> -       if (skb_rx_queue_recorded(skb)) {
>>>> -               hash =3D skb_get_rx_queue(skb);
>>>> -       } else if (skb->sk && skb->sk->sk_hash) {
>>>> +       if (skb_rx_queue_recorded(skb))
>>>> +               return skb_get_rx_queue(skb) % dev->real_num_tx_qu=
eues;
>>>> +
>>>> +       if (skb->sk && skb->sk->sk_hash)
>>>>                hash =3D skb->sk->sk_hash;
>>>> -       } else
>>>> +       else
>>>>                hash =3D skb->protocol;
>>>>
>>>>        hash =3D jhash_1word(hash, skb_tx_hashrnd);
>>>>
>>>>
>>> Eric,
>>>
>>> That's exactly what I did!  It solved the problem of hot-spots on s=
ome
>>> interrupts.  However, I now have a new problem (which is documented=
 in
>>> my previous posts).  The short of it is that I'm only seeing 4 (out=
 of
>>> 8) ksoftirqd's busy under heavy load... the other 4 seem idle.  The
>>> busy 4 are always on one physical package (but not always the same
>>> package (it'll change on reboot or when I change some parameters vi=
a
>>> ethtool), but never both.  This, despite /proc/interrupts showing m=
e
>>> that all 8 interrupts are being hit evenly.  There's more details i=
n
>>> my last mail. ;-D
>>>
>> Well, I was reacting to your 'voodo' comment about
>>
>> return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
>>
>> Since this is not the problem. Problem is coming from jhash() which =
shuffles
>> the input, while in your case we want to select same output queue
>> because of cpu affinities. No shuffle required.
>=20
> Agreed.  I don't want to jhash(), and I'm not.
>=20
>> (assuming cpu0 is handling tx-queue-0 and rx-queue-0,
>>          cpu1 is handling tx-queue-1 and rx-queue-1, and so on...)
>=20
> That's a correct assumption. :D
>=20
>> Then /proc/interrupts show your rx interrupts are not evenly distrib=
uted.
>>
>> Or that ksoftirqd is triggered only on one physical cpu, while on ot=
her
>> cpu, softirqds are not run from ksoftirqd. Its only a matter of load=
=2E
>=20
> Hrmm... more fuel for the fire...
>=20
> The NIC seems to be doing a good job of hashing the incoming data and
> the kernel is now finding the right TX queue:
> -bash-3.2# ethtool -S eth2 | grep -vw 0 | grep packets
>      rx_packets: 1286009099
>      tx_packets: 1287853570
>      tx_queue_0_packets: 162469405
>      tx_queue_1_packets: 162452446
>      tx_queue_2_packets: 162481160
>      tx_queue_3_packets: 162441839
>      tx_queue_4_packets: 162484930
>      tx_queue_5_packets: 162478402
>      tx_queue_6_packets: 162492530
>      tx_queue_7_packets: 162477162
>      rx_queue_0_packets: 162469449
>      rx_queue_1_packets: 162452440
>      rx_queue_2_packets: 162481186
>      rx_queue_3_packets: 162441885
>      rx_queue_4_packets: 162484949
>      rx_queue_5_packets: 162478427
>=20
> Here's where it gets juicy.  If I reduce the rate at which I'm pushin=
g
> traffic to a 0-loss level (in this case about 2.2Mpps), then top look=
s
> as follow:
> Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si=
,  0.0%st
> Cpu7  :  0.0%us,  0.3%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.0%hi,  0.3%si=
,  0.0%st
>=20
> And if I watch /proc/interrupts, I see that all of the tx and rx
> queues are handling a fairly similar number of interrupts (ballpark,
> 7-8k/sec on rx, 10k on tx).
>=20
> OK... now let me double the packet rate (to about 4.4Mpps), top looks=
 like this:
>=20
> Cpu0  :  0.0%us,  0.0%sy,  0.0%ni,  1.9%id,  0.0%wa,  5.5%hi, 92.5%si=
,  0.0%st
> Cpu1  :  0.0%us,  0.0%sy,  0.0%ni, 98.7%id,  0.0%wa,  0.0%hi,  1.3%si=
,  0.0%st
> Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,  2.3%id,  0.0%wa,  4.9%hi, 92.9%si=
,  0.0%st
> Cpu3  :  0.0%us,  0.3%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.0%hi,  1.9%si=
,  0.0%st
> Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,  5.2%id,  0.0%wa,  5.2%hi, 89.6%si=
,  0.0%st
> Cpu5  :  0.0%us,  0.0%sy,  0.0%ni, 97.7%id,  0.0%wa,  0.3%hi,  1.9%si=
,  0.0%st
> Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,  0.3%id,  0.0%wa,  4.9%hi, 94.8%si=
,  0.0%st
> Cpu7  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si=
,  0.0%st
>=20
> And if I watch /proc/interrupts again, I see that the even-CPUs (i.e.
> 0,2,4, and 6) RX queues are receiving relatively few interrupts
> (5-ish/sec (not 5k... just 5)) and the odd-CPUS RX queues are
> receiving about 2-3k/sec.  What's extra strange is that the TX queues
> are still handling about 10k/sec each.
>=20
> So, below some magic threshold (approx 2.3Mpps), the box is basically
> idle and happily routing all the packets (I can confirm that my
> network test device ixia is showing 0-loss).  Above the magic
> threshold, the box starts acting as described above and I'm unable to
> push it beyond that threshold.  While I understand that there are
> limits to how fast I can route packets (obviously), it seems very
> strange that I'm seeing this physical-CPU affinity on the ksoftirqd
> "processes".
>=20

box is not idle, you hit a bug in kernel, I already corrected this week=
 :)

check for "sched: account system time properly" in google

diff --git a/kernel/sched.c b/kernel/sched.c
index b902e58..26efa47 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4732,7 +4732,7 @@ void account_process_tick(struct task_struct *p, =
int user_tick)
=20
 	if (user_tick)
 		account_user_time(p, one_jiffy, one_jiffy_scaled);
-	else if (p !=3D rq->idle)
+	else if ((p !=3D rq->idle) || (irq_count() !=3D HARDIRQ_OFFSET))
 		account_system_time(p, HARDIRQ_OFFSET, one_jiffy,
 				    one_jiffy_scaled);
 	else


> Here's how fragile this "magic threshold" is...  2.292 Mpps, box look=
s
> idle, 0 loss.   2.300 Mpps, even-CPU ksoftirqd processes at 50%-ish.
> 2.307 Mpps, even-CPU ksoftirqd processes at 75%.  2.323 Mpps, even-CP=
U
> ksoftirqd proccesses at 100%.  Never during this did the odd-CPU
> ksoftirqd processes show any utilization at all.
>=20
> These are 64-byte frames, so I shouldn't be hitting any bandwidth
> issues that I'm aware of, 1.3Gbps in, and 1.3Gbps out (same NIC, I'm
> just routing packets back out the one NIC).
>=20
> =3D/
>=20


