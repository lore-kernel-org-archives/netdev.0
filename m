From: Andrew Dickinson <andrew@whydna.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 23:19:37 -0700
Message-ID: <606676310904302319u1eacc634qde4b1f70e9936779@mail.gmail.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	 <20090430.022417.07019547.davem@davemloft.net>
	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>
	 <20090430.070811.260649067.davem@davemloft.net>
	 <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>
	 <49FA932B.4030405@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jelaas@gmail.com,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:51817 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbZEAGTh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 02:19:37 -0400
Received: by rv-out-0506.google.com with SMTP id f6so119582rvb.5
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 23:19:37 -0700 (PDT)
In-Reply-To: <49FA932B.4030405@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 11:14 PM, Eric Dumazet <dada1@cosmosbay.com> wr=
ote:
> Andrew Dickinson a =E9crit :
>> OK... I've got some more data on it...
>>
>> I passed a small number of packets through the system and added a to=
n
>> of printks to it ;-P
>>
>> Here's the distribution of values as seen by
>> skb_rx_queue_recorded()... count on the left, value on the right:
>> =A0 =A0 =A037 0
>> =A0 =A0 =A031 1
>> =A0 =A0 =A031 2
>> =A0 =A0 =A039 3
>> =A0 =A0 =A037 4
>> =A0 =A0 =A031 5
>> =A0 =A0 =A042 6
>> =A0 =A0 =A039 7
>>
>> That's nice and even.... =A0Here's what's getting returned from the
>> skb_tx_hash(). =A0Again, count on the left, value on the right:
>> =A0 =A0 =A031 0
>> =A0 =A0 =A081 1
>> =A0 =A0 =A037 2
>> =A0 =A0 =A070 3
>> =A0 =A0 =A037 4
>> =A0 =A0 =A031 6
>>
>> Note that we're entirely missing 5 and 7 and that those interrupts
>> seem to have gotten munged onto 1 and 3.
>>
>> I think the voodoo lies within:
>> =A0 =A0 return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);
>>
>> David, =A0I made the change that you suggested:
>> =A0 =A0 =A0 =A0 //hash =3D skb_get_rx_queue(skb);
>> =A0 =A0 =A0 =A0 return skb_get_rx_queue(skb) % dev->real_num_tx_queu=
es;
>>
>> And now, I see a nice even mixing of interrupts on the TX side (yay!=
).
>>
>> However, my problem's not solved entirely... here's what top is show=
ing me:
>> top - 23:37:49 up 9 min, =A01 user, =A0load average: 3.93, 2.68, 1.2=
1
>> Tasks: 119 total, =A0 5 running, 114 sleeping, =A0 0 stopped, =A0 0 =
zombie
>> Cpu0 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.3%id, =A00.0%wa, =A00.=
3%hi, =A00.3%si, =A00.0%st
>> Cpu1 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A00.0%id, =A00.0%wa, =A0=
4.3%hi, 95.7%si, =A00.0%st
>> Cpu2 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.7%id, =A00.0%wa, =A00.=
0%hi, =A00.3%si, =A00.0%st
>> Cpu3 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A00.0%id, =A00.0%wa, =A0=
4.3%hi, 95.7%si, =A00.0%st
>> Cpu4 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, 99.3%id, =A00.0%wa, =A00.=
3%hi, =A00.3%si, =A00.0%st
>> Cpu5 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A02.0%id, =A00.0%wa, =A0=
4.0%hi, 94.0%si, =A00.0%st
>> Cpu6 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni,100.0%id, =A00.0%wa, =A00.=
0%hi, =A00.0%si, =A00.0%st
>> Cpu7 =A0: =A00.0%us, =A00.0%sy, =A00.0%ni, =A05.6%id, =A00.0%wa, =A0=
2.3%hi, 92.1%si, =A00.0%st
>> Mem: =A016403476k total, =A0 335884k used, 16067592k free, =A0 =A010=
108k buffers
>> Swap: =A02096472k total, =A0 =A0 =A0 =A00k used, =A02096472k free, =A0=
 146364k cached
>>
>> =A0 PID USER =A0 =A0 =A0PR =A0NI =A0VIRT =A0RES =A0SHR S %CPU %MEM =A0=
 =A0TIME+ =A0COMMAND
>> =A0 =A0 7 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 100=
=2E2 =A00.0 =A0 5:35.24
>> ksoftirqd/1
>> =A0 =A013 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 100=
=2E2 =A00.0 =A0 5:36.98
>> ksoftirqd/3
>> =A0 =A019 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 97.=
8 =A00.0 =A0 5:34.52
>> ksoftirqd/5
>> =A0 =A025 root =A0 =A0 =A015 =A0-5 =A0 =A0 0 =A0 =A00 =A0 =A00 R 94.=
5 =A00.0 =A0 5:13.56
>> ksoftirqd/7
>> =A03905 root =A0 =A0 =A020 =A0 0 12612 1084 =A0820 R =A00.3 =A00.0 =A0=
 0:00.14 top
>> <snip>
>>
>>
>> It appears that only the odd CPUs are actually handling the
>> interrupts, which doesn't jive with what /proc/interrupts shows me:
>> =A0 =A0 =A0 =A0 =A0 =A0 CPU0 =A0 =A0 =A0 CPU1 =A0 =A0 CPU2 =A0 =A0 =A0=
 CPU3 =A0 =A0 =A0 CPU4 =A0 =A0 =A0 CPU5 =A0 =A0 =A0 CPU6 =A0 =A0 =A0 CP=
U7
>> =A0 66: =A0 =A02970565 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-0
>> =A0 67: =A0 =A0 =A0 =A0 28 =A0 =A0 821122 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-1
>> =A0 68: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A02943299 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-2
>> =A0 69: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 817776 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-3
>> =A0 70: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A02963924
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-rx-4
>> =A0 71: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 821032 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0=
 =A0 eth2-rx-5
>> =A0 72: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A02979987 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0 =A0=
 =A0eth2-rx-6
>> =A0 73: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 845422 =A0 PCI-MSI-edge =A0 =A0 =A0 =A0=
 =A0eth2-rx-7
>> =A0 74: =A0 =A04664732 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0=
 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-0
>> =A0 75: =A0 =A0 =A0 =A0 34 =A0 =A04679312 =A0 =A0 =A0 =A0 =A00 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-1
>> =A0 76: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A04665014 =A0 =A0=
 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-2
>> =A0 77: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A04681531 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-3
>> =A0 78: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A04665793
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2-tx-4
>> =A0 79: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 4671596 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0=
 =A0eth2-tx-5
>> =A0 80: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A04665279 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0 =A0 =A0=
 =A0eth2-tx-6
>> =A0 81: =A0 =A0 =A0 =A0 28 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00=
 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A04664504 =A0 PCI-MSI-edge =A0 =A0 =A0 =A0=
 =A0eth2-tx-7
>> =A0 82: =A0 =A0 =A0 =A0 =A02 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A0=
0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00
>> 0 =A0 =A0 =A0 =A0 =A00 =A0 =A0 =A0 =A0 =A00 =A0 PCI-MSI-edge =A0 =A0=
 =A0 =A0 =A0eth2:lsc
>>
>>
>> Why would ksoftirqd only run on half of the cores (and only the odd
>> ones to boot)? =A0The one commonality that's striking me is that tha=
t
>> all the odd CPU#'s are on the same physical processor:
>>
>> -bash-3.2# cat /proc/cpuinfo | grep -E '(physical|processor)' | grep=
 -v virtual
>> processor =A0 =A0 : 0
>> physical id =A0 : 0
>> processor =A0 =A0 : 1
>> physical id =A0 : 1
>> processor =A0 =A0 : 2
>> physical id =A0 : 0
>> processor =A0 =A0 : 3
>> physical id =A0 : 1
>> processor =A0 =A0 : 4
>> physical id =A0 : 0
>> processor =A0 =A0 : 5
>> physical id =A0 : 1
>> processor =A0 =A0 : 6
>> physical id =A0 : 0
>> processor =A0 =A0 : 7
>> physical id =A0 : 1
>>
>> I did compile the kernel with NUMA support... am I being bitten by
>> something there? =A0Other thoughts on where I should look.
>>
>> Also... is there an incantation to get NAPI to work in the torvalds
>> kernel? =A0As you can see, I'm generating quite a few interrrupts.
>>
>> -A
>>
>>
>> On Thu, Apr 30, 2009 at 7:08 AM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Andrew Dickinson <andrew@whydna.net>
>>> Date: Thu, 30 Apr 2009 07:04:33 -0700
>>>
>>>> =A0I'll do some debugging around skb_tx_hash() and see if I can ma=
ke
>>>> sense of it. =A0I'll let you know what I find. =A0My hypothesis is=
 that
>>>> skb_record_rx_queue() isn't being called, but I should dig into it
>>>> before I start making claims. ;-P
>>> That's one possibility.
>>>
>>> Another is that the hashing isn't working out. =A0One way to
>>> play with that is to simply replace the:
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb_get_rx_queue(skb);
>>>
>>> in skb_tx_hash() with something like:
>>>
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return skb_get_rx_queue(skb) % dev->=
real_num_tx_queues;
>>>
>>> and see if that improves the situation.
>>>
>
> Hi Andrew
>
> Please try following patch (I dont have multi-queue NIC, sorry)
>
> I will do the followup patch if this ones corrects the distribution p=
roblem
> you noticed.
>
> Thanks very much for all your findings.
>
> [PATCH] net: skb_tx_hash() improvements
>
> When skb_rx_queue_recorded() is true, we dont want to use jash distri=
bution
> as the device driver exactly told us which queue was selected at RX t=
ime.
> jhash makes a statistical shuffle, but this wont work with 8 static i=
nputs.
>
> Later improvements would be to compute reciprocal value of real_num_t=
x_queues
> to avoid a divide here. But this computation should be done once,
> when real_num_tx_queues is set. This needs a separate patch, and a ne=
w
> field in struct net_device.
>
> Reported-by: Andrew Dickinson <andrew@whydna.net>
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 308a7d0..e2e9e4a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1735,11 +1735,12 @@ u16 skb_tx_hash(const struct net_device *dev,=
 const struct sk_buff *skb)
> =A0{
> =A0 =A0 =A0 =A0u32 hash;
>
> - =A0 =A0 =A0 if (skb_rx_queue_recorded(skb)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 hash =3D skb_get_rx_queue(skb);
> - =A0 =A0 =A0 } else if (skb->sk && skb->sk->sk_hash) {
> + =A0 =A0 =A0 if (skb_rx_queue_recorded(skb))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return skb_get_rx_queue(skb) % dev->rea=
l_num_tx_queues;
> +
> + =A0 =A0 =A0 if (skb->sk && skb->sk->sk_hash)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb->sk->sk_hash;
> - =A0 =A0 =A0 } else
> + =A0 =A0 =A0 else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb->protocol;
>
> =A0 =A0 =A0 =A0hash =3D jhash_1word(hash, skb_tx_hashrnd);
>
>

Eric,

That's exactly what I did!  It solved the problem of hot-spots on some
interrupts.  However, I now have a new problem (which is documented in
my previous posts).  The short of it is that I'm only seeing 4 (out of
8) ksoftirqd's busy under heavy load... the other 4 seem idle.  The
busy 4 are always on one physical package (but not always the same
package (it'll change on reboot or when I change some parameters via
ethtool), but never both.  This, despite /proc/interrupts showing me
that all 8 interrupts are being hit evenly.  There's more details in
my last mail. ;-D

-Andrew
