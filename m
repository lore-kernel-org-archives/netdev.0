From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: Strange latency spikes/TX network stalls on Sun Fire X4150(x86)
 and e1000e
Date: Tue, 29 May 2012 23:25:18 +0900
Message-ID: <20120529232518.e5b41759.shimoda.hiroaki@gmail.com>
References: <668eeb0d42a1678d9083a58deb3ac40d@visp.net.lb>
	<88c43001441945e1431609db252b69e7@visp.net.lb>
	<df211722d18136698aeeda2f17b876e2@visp.net.lb>
	<d3a88d6c741394a48aee6179d58e4edf@visp.net.lb>
	<CA+mtBx9axFKCjLwDYMvXXP2nB_og896kAhG0UYWaK6PTAXhPcw@mail.gmail.com>
	<79d6b56fdf5f4be4656079568d5a7445@visp.net.lb>
	<CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, eric.dumazet@gmail.com,
	davem@davemloft.net
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:37982 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667Ab2E2OZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 10:25:23 -0400
Received: by dady13 with SMTP id y13so5495955dad.19
        for <netdev@vger.kernel.org>; Tue, 29 May 2012 07:25:23 -0700 (PDT)
In-Reply-To: <CA+mtBx_sF5GCMRpLQuTruZ=xpFTFpd5z8SZJaG_dBqf4oCXpwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 20 May 2012 10:40:41 -0700
Tom Herbert <therbert@google.com> wrote:

> Tried to reproduce:
> 
> May 20 10:08:30 test kernel: [    6.168240] e1000e 0000:06:00.0:
> (unregistered net_device): Interrupt Throttling Rate (ints/sec) set to
> dynamic conservative mode
> May 20 10:08:30 test kernel: [    6.221591] e1000e 0000:06:00.1:
> (unregistered net_device): Interrupt Throttling Rate (ints/sec) set to
> dynamic conservative mode
> 
> 06:00.0 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
> Ethernet Controller (Copper) (rev 01)
> 06:00.1 Ethernet controller: Intel Corporation 80003ES2LAN Gigabit
> Ethernet Controller (Copper) (rev 01)
> 
> Following above instructions to repro gives:
> 
> 1480 bytes from test2 (192.168.2.49): icmp_req=5875 ttl=64 time=0.358 ms
> 1480 bytes from test2 (192.168.2.49): icmp_req=5876 ttl=64 time=0.330 ms
> 1480 bytes from test2 (192.168.2.49): icmp_req=5877 ttl=64 time=0.337 ms
> 1480 bytes from test2 (192.168.2.49): icmp_req=5878 ttl=64 time=0.375 ms
> 1480 bytes from test2 (192.168.2.49): icmp_req=5879 ttl=64 time=0.359 ms
> 1480 bytes from lpb49.prod.google.com (192.168.2.49): icmp_req=5880
> ttl=64 time=0.380 ms
> 
> And I didn't see the stalls. This was on an Intel machine.  The limit
> was stable, went up to around 28K when opened large file and tended to
> stay between 15-28K.
> 
> The describe problem seems to have characteristics that transmit
> interrupts are not at all periodic, and it would seem that some are
> taking hundreds of milliseconds to pop.  I don't see anything that
> would cause that in the NIC, is it possible there is some activity on
> the machines periodically and often holding down interrupts for  long
> periods of time.  Are there any peculiarities on Sun Fire in interrupt
> handling?
> 
> Can you also provide an 'ethtool -c eth0'
> 
> Thanks,
> Tom

I also observed the similar behaviour on the following environment.

03:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection

[    2.962119] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
[    2.968095] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
[    2.974251] e1000e 0000:03:00.0: Disabling ASPM L0s L1
[    2.979653] e1000e 0000:03:00.0: (unregistered net_device): Interrupt Throttling Rate (ints/sec) set to dynamic conservative mode
[    2.991599] e1000e 0000:03:00.0: irq 72 for MSI/MSI-X
[    2.991606] e1000e 0000:03:00.0: irq 73 for MSI/MSI-X
[    2.991611] e1000e 0000:03:00.0: irq 74 for MSI/MSI-X
[    3.092768] e1000e 0000:03:00.0: eth0: (PCI Express:2.5GT/s:Width x1) 48:5b:39:75:91:bd
[    3.100992] e1000e 0000:03:00.0: eth0: Intel(R) PRO/1000 Network Connection
[    3.108173] e1000e 0000:03:00.0: eth0: MAC: 3, PHY: 8, PBA No: FFFFFF-0FF

I tried some coalesce options by 'ethtool -C eth0', but
anything didn't help.

If I understand the code and spec correctly, TX interrupts are
generated when TXDCTL.WTHRESH descriptors have been accumulated
and write backed.

I tentatively changed the TXDCTL.WTHRESH to 1, then it seems
that latency spikes are disappear.

drivers/net/ethernet/intel/e1000e/e1000.h
@@ -181,7 +181,7 @@ struct e1000_info;
 #define E1000_TXDCTL_DMA_BURST_ENABLE                          \
        (E1000_TXDCTL_GRAN | /* set descriptor granularity */  \
         E1000_TXDCTL_COUNT_DESC |                             \
-        (5 << 16) | /* wthresh must be +1 more than desired */\
+        (1 << 16) | /* wthresh must be +1 more than desired */\
         (1 << 8)  | /* hthresh */                             \
         0x1f)       /* pthresh */

(before) $ ping -i0.2 192.168.11.2
PING 192.168.11.2 (192.168.11.2) 56(84) bytes of data.
64 bytes from 192.168.11.2: icmp_req=1 ttl=64 time=0.191 ms
64 bytes from 192.168.11.2: icmp_req=2 ttl=64 time=0.179 ms
64 bytes from 192.168.11.2: icmp_req=3 ttl=64 time=0.199 ms
64 bytes from 192.168.11.2: icmp_req=4 ttl=64 time=0.143 ms
64 bytes from 192.168.11.2: icmp_req=5 ttl=64 time=0.193 ms
64 bytes from 192.168.11.2: icmp_req=6 ttl=64 time=0.150 ms
64 bytes from 192.168.11.2: icmp_req=7 ttl=64 time=0.186 ms
64 bytes from 192.168.11.2: icmp_req=8 ttl=64 time=0.198 ms
64 bytes from 192.168.11.2: icmp_req=9 ttl=64 time=0.195 ms
64 bytes from 192.168.11.2: icmp_req=10 ttl=64 time=0.194 ms
64 bytes from 192.168.11.2: icmp_req=11 ttl=64 time=0.196 ms
64 bytes from 192.168.11.2: icmp_req=12 ttl=64 time=0.200 ms
64 bytes from 192.168.11.2: icmp_req=13 ttl=64 time=651 ms
64 bytes from 192.168.11.2: icmp_req=14 ttl=64 time=451 ms
64 bytes from 192.168.11.2: icmp_req=15 ttl=64 time=241 ms
64 bytes from 192.168.11.2: icmp_req=16 ttl=64 time=31.3 ms
64 bytes from 192.168.11.2: icmp_req=17 ttl=64 time=0.184 ms
64 bytes from 192.168.11.2: icmp_req=18 ttl=64 time=0.199 ms
64 bytes from 192.168.11.2: icmp_req=19 ttl=64 time=0.197 ms
64 bytes from 192.168.11.2: icmp_req=20 ttl=64 time=0.196 ms
64 bytes from 192.168.11.2: icmp_req=21 ttl=64 time=0.192 ms
64 bytes from 192.168.11.2: icmp_req=22 ttl=64 time=0.205 ms
64 bytes from 192.168.11.2: icmp_req=23 ttl=64 time=629 ms
64 bytes from 192.168.11.2: icmp_req=24 ttl=64 time=419 ms
64 bytes from 192.168.11.2: icmp_req=25 ttl=64 time=209 ms
64 bytes from 192.168.11.2: icmp_req=26 ttl=64 time=0.280 ms
64 bytes from 192.168.11.2: icmp_req=27 ttl=64 time=0.193 ms
64 bytes from 192.168.11.2: icmp_req=28 ttl=64 time=0.194 ms
64 bytes from 192.168.11.2: icmp_req=29 ttl=64 time=0.143 ms
64 bytes from 192.168.11.2: icmp_req=30 ttl=64 time=0.191 ms
64 bytes from 192.168.11.2: icmp_req=31 ttl=64 time=0.144 ms
64 bytes from 192.168.11.2: icmp_req=32 ttl=64 time=0.192 ms
64 bytes from 192.168.11.2: icmp_req=33 ttl=64 time=0.199 ms
64 bytes from 192.168.11.2: icmp_req=34 ttl=64 time=0.193 ms
64 bytes from 192.168.11.2: icmp_req=35 ttl=64 time=0.196 ms
64 bytes from 192.168.11.2: icmp_req=36 ttl=64 time=0.196 ms
64 bytes from 192.168.11.2: icmp_req=37 ttl=64 time=0.196 ms
64 bytes from 192.168.11.2: icmp_req=38 ttl=64 time=1600 ms
64 bytes from 192.168.11.2: icmp_req=39 ttl=64 time=1390 ms
64 bytes from 192.168.11.2: icmp_req=40 ttl=64 time=1180 ms
64 bytes from 192.168.11.2: icmp_req=41 ttl=64 time=980 ms
64 bytes from 192.168.11.2: icmp_req=42 ttl=64 time=780 ms
64 bytes from 192.168.11.2: icmp_req=43 ttl=64 time=570 ms
64 bytes from 192.168.11.2: icmp_req=44 ttl=64 time=0.151 ms
64 bytes from 192.168.11.2: icmp_req=45 ttl=64 time=0.189 ms
64 bytes from 192.168.11.2: icmp_req=46 ttl=64 time=0.203 ms
64 bytes from 192.168.11.2: icmp_req=47 ttl=64 time=0.185 ms
64 bytes from 192.168.11.2: icmp_req=48 ttl=64 time=0.189 ms
64 bytes from 192.168.11.2: icmp_req=49 ttl=64 time=0.204 ms
64 bytes from 192.168.11.2: icmp_req=50 ttl=64 time=0.198 ms

I think 1000 ms - 2000 ms delay is come from e1000_watchdog_task().

(after) $ ping -i0.2 192.168.11.2
64 bytes from 192.168.11.2: icmp_req=1 ttl=64 time=0.175 ms
64 bytes from 192.168.11.2: icmp_req=2 ttl=64 time=0.203 ms
64 bytes from 192.168.11.2: icmp_req=3 ttl=64 time=0.196 ms
64 bytes from 192.168.11.2: icmp_req=4 ttl=64 time=0.197 ms
64 bytes from 192.168.11.2: icmp_req=5 ttl=64 time=0.186 ms
64 bytes from 192.168.11.2: icmp_req=6 ttl=64 time=0.197 ms
64 bytes from 192.168.11.2: icmp_req=7 ttl=64 time=0.189 ms
64 bytes from 192.168.11.2: icmp_req=8 ttl=64 time=0.146 ms
64 bytes from 192.168.11.2: icmp_req=9 ttl=64 time=0.193 ms
64 bytes from 192.168.11.2: icmp_req=10 ttl=64 time=0.194 ms
64 bytes from 192.168.11.2: icmp_req=11 ttl=64 time=0.195 ms
64 bytes from 192.168.11.2: icmp_req=12 ttl=64 time=0.190 ms
64 bytes from 192.168.11.2: icmp_req=13 ttl=64 time=0.204 ms
64 bytes from 192.168.11.2: icmp_req=14 ttl=64 time=0.201 ms
64 bytes from 192.168.11.2: icmp_req=15 ttl=64 time=0.189 ms
64 bytes from 192.168.11.2: icmp_req=16 ttl=64 time=0.193 ms
64 bytes from 192.168.11.2: icmp_req=17 ttl=64 time=0.190 ms
64 bytes from 192.168.11.2: icmp_req=18 ttl=64 time=0.143 ms
64 bytes from 192.168.11.2: icmp_req=19 ttl=64 time=0.191 ms
64 bytes from 192.168.11.2: icmp_req=20 ttl=64 time=0.190 ms
