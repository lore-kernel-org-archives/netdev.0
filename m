From: Andrew Dickinson <andrew@whydna.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 21:19:36 -0700
Message-ID: <606676310904302119w92e610crbdb7d5d824e6ed01@mail.gmail.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	 <20090430.022417.07019547.davem@davemloft.net>
	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>
	 <20090430.070811.260649067.davem@davemloft.net>
	 <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jelaas@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:11733 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757AbZEAETg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 00:19:36 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1663008wfd.4
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 21:19:36 -0700 (PDT)
In-Reply-To: <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a bit more info...

I should add, the other 4 ksoftirqd tasklets _are_ running, they're
just not busy. (In case that wasn't clear...)

Also of note, I rebooted the box (after recompiling with NUMA off).
This time when I push traffic through, only the even-ksoftirqd's were
busy..  I then tweaked some of the ring settings via ethtool and
suddenly the odd-ksoftirqd's became busy (and the even ones went
idle).

Thoughts?  Suggestions?  driver issue?  I'm at 2.6.30-rc3.

(BTW, I'm under the assumption that since only 4 (of 8) ksoftirqd's
are busy that I still have room to make this box go faster).

-A


On Thu, Apr 30, 2009 at 4:53 PM, Andrew Dickinson <andrew@whydna.net> w=
rote:
> OK... I've got some more data on it...
>
> I passed a small number of packets through the system and added a ton
> of printks to it ;-P
>
> Here's the distribution of values as seen by
> skb_rx_queue_recorded()... count on the left, value on the right:
> =A0 =A0 37 0
> =A0 =A0 31 1
> =A0 =A0 31 2
> =A0 =A0 39 3
> =A0 =A0 37 4
> =A0 =A0 31 5
> =A0 =A0 42 6
> =A0 =A0 39 7
>
> That's nice and even.... =A0Here's what's getting returned from the
> skb_tx_hash(). =A0Again, count on the left, value on the right:
> =A0 =A0 31 0
> =A0 =A0 81 1
> =A0 =A0 37 2
> =A0 =A0 70 3
> =A0 =A0 37 4
> =A0 =A0 31 6
>
> Note that we're entirely missing 5 and 7 and that those interrupts
> seem to have gotten munged onto 1 and 3.
>
> I think the voodoo lies within:
> =A0 =A0return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
>
> David, =A0I made the change that you suggested:
> =A0 =A0 =A0 =A0//hash =3D skb_get_rx_queue(skb);
> =A0 =A0 =A0 =A0return skb_get_rx_queue(skb) % dev->real_num_tx_queues=
;
>
> And now, I see a nice even mixing of interrupts on the TX side (yay!)=
=2E
>
> However, my problem's not solved entirely... here's what top is showi=
ng me:
> top - 23:37:49 up 9 min, =A01 user, =A0load average: 3.93, 2.68, 1.21
> Tasks: 119 total, =A0 5 running, 114 sleeping, =A0 0 stopped, =A0 0 z=
ombie
> Cpu0 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.3%id, =A00.0%wa, =A00.3=
%hi, =A00.3%si, =A00.0%st
> Cpu1 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A00.0%id, =A00.0%wa, =A04=
=2E3%hi, 95.7%si, =A00.0%st
> Cpu2 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.7%id, =A00.0%wa, =A00.0=
%hi, =A00.3%si, =A00.0%st
> Cpu3 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A00.0%id, =A00.0%wa, =A04=
=2E3%hi, 95.7%si, =A00.0%st
> Cpu4 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.3%id, =A00.0%wa, =A00.3=
%hi, =A00.3%si, =A00.0%st
> Cpu5 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A02.0%id, =A00.0%wa, =A04=
=2E0%hi, 94.0%si, =A00.0%st
> Cpu6 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni,100.0%id, =A00.0%wa, =A00.0=
%hi, =A00.0%si, =A00.0%st
> Cpu7 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A05.6%id, =A00.0%wa, =A02=
=2E3%hi, 92.1%si, =A00.0%st
> Mem: =A016403476k total, =A0 335884k used, 16067592k free, =A0 =A0101=
08k buffers
> Swap: =A02096472k total, =A0 =A0 =A0 =A00k used, =A02096472k free, =A0=
 146364k cached
>
> =A0PID USER =A0 =A0 =A0PR =A0NI =A0VIRT =A0RES =A0SHR S %CPU %MEM =A0=
 =A0TIME+ =A0COMMAND
> =A0 =A07 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 100.2=
 =A00.0 =A0 5:35.24
> ksoftirqd/1
> =A0 13 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 100.2 =A0=
0.0 =A0 5:36.98
> ksoftirqd/3
> =A0 19 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 97.8 =A0=
0.0 =A0 5:34.52
> ksoftirqd/5
> =A0 25 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 94.5 =A0=
0.0 =A0 5:13.56
> ksoftirqd/7
> =A03905 root =A0 =A0 =A020 =A0 0 12612 1084 =A0820 R =A00.3 =A00.0 =A0=
 0:00.14 top
> <snip>
>
>
> It appears that only the odd CPUs are actually handling the
> interrupts, which doesn't jive with what /proc/interrupts shows me:
> =A0 =A0 =A0 =A0 =A0 =A0CPU0 =A0 =A0 =A0 CPU1 =A0 =A0 =A0 CPU2 =A0 =A0=
 =A0 CPU3 =A0 =A0 =A0 CPU4 =A0 =A0 =A0 CPU5 =A0 =A0 =A0 CPU6 =A0 =A0 =A0=
 CPU7
> =A066: =A0 =A02970565 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-rx-0
> =A067: =A0 =A0 =A0 =A0 28 =A0 =A0 821122 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-rx-1
> =A068: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A02943299 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-rx-2
> =A069: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 817776 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-rx-3
> =A070: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A02963924
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-rx-4
> =A071: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 821032 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0=
 =A0 =A0 eth2-rx-5
> =A072: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A02979987 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0eth2-rx=
-6
> =A073: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 845422 =A0 PCI-MSI-edge =A0 =A0eth2-rx=
-7
> =A074: =A0 =A04664732 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-tx-0
> =A075: =A0 =A0 =A0 =A0 34 =A0 =A04679312 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-tx-1
> =A076: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A04665014 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-tx-2
> =A077: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A04681531 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-tx-3
> =A078: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A04665793
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2-tx-4
> =A079: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 4671596 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0=
 =A0 =A0eth2-tx-5
> =A080: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A04665279 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0eth2-tx=
-6
> =A081: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A04664504 =A0 PCI-MSI-edge =A0 =A0eth2-tx=
-7
> =A082: =A0 =A0 =A0 =A0 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0e=
th2:lsc
>
>
> Why would ksoftirqd only run on half of the cores (and only the odd
> ones to boot)? =A0The one commonality that's striking me is that that
> all the odd CPU#'s are on the same physical processor:
>
> -bash-3.2# cat /proc/cpuinfo | grep -E '(physical|processor)' | grep =
-v virtual
> processor =A0 =A0 =A0 : 0
> physical id =A0 =A0 : 0
> processor =A0 =A0 =A0 : 1
> physical id =A0 =A0 : 1
> processor =A0 =A0 =A0 : 2
> physical id =A0 =A0 : 0
> processor =A0 =A0 =A0 : 3
> physical id =A0 =A0 : 1
> processor =A0 =A0 =A0 : 4
> physical id =A0 =A0 : 0
> processor =A0 =A0 =A0 : 5
> physical id =A0 =A0 : 1
> processor =A0 =A0 =A0 : 6
> physical id =A0 =A0 : 0
> processor =A0 =A0 =A0 : 7
> physical id =A0 =A0 : 1
>
> I did compile the kernel with NUMA support... am I being bitten by
> something there? =A0Other thoughts on where I should look.
>
> Also... is there an incantation to get NAPI to work in the torvalds
> kernel? =A0As you can see, I'm generating quite a few interrrupts.
>
> -A
>
>
> On Thu, Apr 30, 2009 at 7:08 AM, David Miller <davem@davemloft.net> w=
rote:
>> From: Andrew Dickinson <andrew@whydna.net>
>> Date: Thu, 30 Apr 2009 07:04:33 -0700
>>
>>> =A0I'll do some debugging around skb_tx_hash() and see if I can mak=
e
>>> sense of it. =A0I'll let you know what I find. =A0My hypothesis is =
that
>>> skb_record_rx_queue() isn't being called, but I should dig into it
>>> before I start making claims. ;-P
>>
>> That's one possibility.
>>
>> Another is that the hashing isn't working out. =A0One way to
>> play with that is to simply replace the:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb_get_rx_queue(skb);
>>
>> in skb_tx_hash() with something like:
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return skb_get_rx_queue(skb) % dev->r=
eal_num_tx_queues;
>>
>> and see if that improves the situation.
>>
>
