From: Andrew Dickinson <andrew@whydna.net>
Subject: Re: tx queue hashing hot-spots and poor performance (multiq, ixgbe)
Date: Thu, 30 Apr 2009 16:53:26 -0700
Message-ID: <606676310904301653w28f3226fsc477dc92b6a7cdbc@mail.gmail.com>
References: <96ff3930904300207l4ecfe90byd6cce3f56ce4e113@mail.gmail.com>
	 <20090430.022417.07019547.davem@davemloft.net>
	 <606676310904300704p5308e3b6le2c469d320cc669@mail.gmail.com>
	 <20090430.070811.260649067.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jelaas@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:18648 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763736AbZD3Xx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 19:53:26 -0400
Received: by wf-out-1314.google.com with SMTP id 26so1591290wfd.4
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2009 16:53:26 -0700 (PDT)
In-Reply-To: <20090430.070811.260649067.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK... I've got some more data on it...

I passed a small number of packets through the system and added a ton
of printks to it ;-P

Here's the distribution of values as seen by
skb_rx_queue_recorded()... count on the left, value on the right:
     37 0
     31 1
     31 2
     39 3
     37 4
     31 5
     42 6
     39 7

That's nice and even....  Here's what's getting returned from the
skb_tx_hash().  Again, count on the left, value on the right:
     31 0
     81 1
     37 2
     70 3
     37 4
     31 6

Note that we're entirely missing 5 and 7 and that those interrupts
seem to have gotten munged onto 1 and 3.

I think the voodoo lies within:
    return (u16) (((u64) hash * dev->real_num_tx_queues) >> 32);

David,  I made the change that you suggested:
        //hash =3D skb_get_rx_queue(skb);
        return skb_get_rx_queue(skb) % dev->real_num_tx_queues;

And now, I see a nice even mixing of interrupts on the TX side (yay!).

However, my problem's not solved entirely... here's what top is showing=
 me:
top - 23:37:49 up 9 min,  1 user,  load average: 3.93, 2.68, 1.21
Tasks: 119 total,   5 running, 114 sleeping,   0 stopped,   0 zombie
Cpu0  :  0.0%us,  0.0%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.3%hi,  0.3%si, =
 0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,  0.0%id,  0.0%wa,  4.3%hi, 95.7%si, =
 0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.3%si, =
 0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,  0.0%id,  0.0%wa,  4.3%hi, 95.7%si, =
 0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni, 99.3%id,  0.0%wa,  0.3%hi,  0.3%si, =
 0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,  2.0%id,  0.0%wa,  4.0%hi, 94.0%si, =
 0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si, =
 0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni,  5.6%id,  0.0%wa,  2.3%hi, 92.1%si, =
 0.0%st
Mem:  16403476k total,   335884k used, 16067592k free,    10108k buffer=
s
Swap:  2096472k total,        0k used,  2096472k free,   146364k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
    7 root      15  -5     0    0    0 R 100.2  0.0   5:35.24
ksoftirqd/1
   13 root      15  -5     0    0    0 R 100.2  0.0   5:36.98
ksoftirqd/3
   19 root      15  -5     0    0    0 R 97.8  0.0   5:34.52
ksoftirqd/5
   25 root      15  -5     0    0    0 R 94.5  0.0   5:13.56
ksoftirqd/7
 3905 root      20   0 12612 1084  820 R  0.3  0.0   0:00.14 top
<snip>


It appears that only the odd CPUs are actually handling the
interrupts, which doesn't jive with what /proc/interrupts shows me:
            CPU0       CPU1	  CPU2       CPU3	CPU4	   CPU5       CPU6	 =
CPU7
  66:    2970565          0          0          0          0
0          0          0   PCI-MSI-edge	  eth2-rx-0
  67:         28     821122          0          0          0
0          0          0   PCI-MSI-edge	  eth2-rx-1
  68:         28          0    2943299          0          0
0          0          0   PCI-MSI-edge	  eth2-rx-2
  69:         28          0          0     817776          0
0          0          0   PCI-MSI-edge	  eth2-rx-3
  70:         28          0          0          0    2963924
0          0          0   PCI-MSI-edge	  eth2-rx-4
  71:         28          0          0          0          0
821032          0          0   PCI-MSI-edge	  eth2-rx-5
  72:         28          0          0          0          0
0    2979987          0   PCI-MSI-edge	  eth2-rx-6
  73:         28          0          0          0          0
0          0     845422   PCI-MSI-edge	  eth2-rx-7
  74:    4664732          0          0          0          0
0          0          0   PCI-MSI-edge	  eth2-tx-0
  75:         34    4679312          0          0          0
0          0          0   PCI-MSI-edge	  eth2-tx-1
  76:         28          0    4665014          0          0
0          0          0   PCI-MSI-edge	  eth2-tx-2
  77:         28          0          0    4681531          0
0          0          0   PCI-MSI-edge	  eth2-tx-3
  78:         28          0          0          0    4665793
0          0          0   PCI-MSI-edge	  eth2-tx-4
  79:         28          0          0          0          0
4671596          0          0   PCI-MSI-edge	  eth2-tx-5
  80:         28          0          0          0          0
0    4665279          0   PCI-MSI-edge	  eth2-tx-6
  81:         28          0          0          0          0
0          0    4664504   PCI-MSI-edge	  eth2-tx-7
  82:          2          0          0          0          0
0          0          0   PCI-MSI-edge	  eth2:lsc


Why would ksoftirqd only run on half of the cores (and only the odd
ones to boot)?  The one commonality that's striking me is that that
all the odd CPU#'s are on the same physical processor:

-bash-3.2# cat /proc/cpuinfo | grep -E '(physical|processor)' | grep -v=
 virtual
processor	: 0
physical id	: 0
processor	: 1
physical id	: 1
processor	: 2
physical id	: 0
processor	: 3
physical id	: 1
processor	: 4
physical id	: 0
processor	: 5
physical id	: 1
processor	: 6
physical id	: 0
processor	: 7
physical id	: 1

I did compile the kernel with NUMA support... am I being bitten by
something there?  Other thoughts on where I should look.

Also... is there an incantation to get NAPI to work in the torvalds
kernel?  As you can see, I'm generating quite a few interrrupts.

-A


On Thu, Apr 30, 2009 at 7:08 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Andrew Dickinson <andrew@whydna.net>
> Date: Thu, 30 Apr 2009 07:04:33 -0700
>
>> =A0I'll do some debugging around skb_tx_hash() and see if I can make
>> sense of it. =A0I'll let you know what I find. =A0My hypothesis is t=
hat
>> skb_record_rx_queue() isn't being called, but I should dig into it
>> before I start making claims. ;-P
>
> That's one possibility.
>
> Another is that the hashing isn't working out. =A0One way to
> play with that is to simply replace the:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0hash =3D skb_get_rx_queue(skb);
>
> in skb_tx_hash() with something like:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return skb_get_rx_queue(skb) % dev->re=
al_num_tx_queues;
>
> and see if that improves the situation.
>
