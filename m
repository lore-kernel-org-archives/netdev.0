From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: No idea about shaping trough many pc
Date: Thu, 10 Jan 2008 13:00:48 +0200
Message-ID: <20080110103708.M15442@visp.net.lb>
References: <4785E01B.3080900@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:56835 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753002AbYAJLBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 06:01:02 -0500
In-Reply-To: <4785E01B.3080900@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For proper link bandwidth sharing i guess something like network counters 
have to be shared between PC's (with proper locking). I didn't heard anything 
like this

IMHO a ways to do this:
Split destination network to multiple parts and do routes on Cisco. Let's say 
you have:
192.168.0.0/16
and u have 4 balancing PC's
total bandwidth 1Gbit/s (speed conforming to IEC 1000Mbit/s in 1Gbit/s)

Then u do on cisco :
192.168.0.0/18 via PC1(shared speed 250Mbit/s)
192.168.64.0/18 via PC2(shared speed 250Mbit/s)
192.168.128.0/18 via PC3(shared speed 250Mbit/s)
192.168.192.0/18 via PC4(shared speed 250Mbit/s)

Probably you can do some scripts to check, if there is in some PC too much 
available bandwidth (average 5 minutes), then you can give some other PC 
which is need more bandwidth - more bandwidth. For example:

Average counters for 5minute shows:
PC1 - occupy 100Mbit/s
PC2 - -//- 50Mbit/s
PC3 - -//- 150Mbit/s
PC4 - -//- 230Mbit/s

Then u change link speed:
PC1 max 200
PC2 max 150
PC3 max 250
PC4 max 400 (100 from PC2 and 50 from PC1)

Sure PC must be capable to pass this traffic. And my IMHO it is not normal 
that your PC's not able to handle more than 200Mbps of traffic. I have 
complicated setup, with 4 LAN 8139 cards, which is passing totally 200Mbps 
traffic. I am sure it can handle up to 300mbps, but already i am changing it 
to PC with PCI-E e1000/broadcom netxtreme with offloading capabilities, large 
buffers and proper drivers with NAPI. I have such hardware handling now for 
example 160Mbps and counters is:
12:50:41     CPU   %user   %nice    %sys %iowait    %irq   %soft  %steal
   %idle    intr/s
12:50:42     all    0.00    0.00    0.00    0.00    0.25    1.24    0.00   
98.51   4009.90
12:50:43     all    0.00    0.00    0.00    0.00    0.00    1.25    0.00   
98.75   4024.75
12:50:44     all    0.00    0.00    0.00    0.00    0.00    1.50    0.00   
98.50   4181.82
12:50:45     all    0.25    0.00    0.00    0.00    0.00    1.50    0.00   
98.25   4626.73
12:50:46     all    0.00    0.00    0.00    0.00    0.00    1.50    0.00   
98.50   4351.52
12:50:47     all    0.25    0.00    0.00    0.00    0.00    1.75    0.00   
98.00   4805.88

It is 2.6.23.8 with some mistakes during configuration, i am doing to try 
2.6.24-rc7 and some optimizations.

Right now profile looks like:
10957    17.0675  mwait_idle_with_hints
7454     11.6110  read_hpet
3883      6.0485  _raw_spin_lock
1605      2.5001  timer_interrupt
1363      2.1231  irq_entries_start

So maybe i will have to try change timers to TSC, disable nmi_watchdog and 
try to tune up network driver (bnx2).
Probably you have to check such things too.

On Thu, 10 Jan 2008 12:06:35 +0300, Badalian Vyacheslav wrote
> Hello all.
> I try more then 2 month resolve problem witch my shaping.  Maybe you 
> can help for me?
> 
> Sheme:
>                                 +-------------------+
>                      + ----- | Shaping PC 1 | ---------+
>                      /          +-------------------+              \
> +--------+   /           +--------------------+              \       
>    + --------+ | Cisco |  +-------- | Shaping PC N  | -----------+ --
> ---| CISCO | +--------+   \           +--------------------+         
>      /          +---------+                     \          +---------
> ------------+           /                     + ----- | Shaping PC 
> 20 | --------+                                +---------------------+
> 
> Network - Over 10k users. Common bandwidth to INTERNET more then 1 
> GBs All computers have BGP and turn on multipath. Cisco can't do 
> load sharing by Packet (its can resolve all my problems =((( ). Only 
> by DST IP, SRC IP, or +Level4. Ok. User must have speed 1mbs. Lets 
> look variants:
> 1. Create rules to user = (1mbs/N computers). If user use N 
> connection all great, but if it use 1 connection his speed = 1mbs/N -
>  its not look good. All be great if cisco can PER PACKET load 
> sharing =(
> 2. Create rules to user = 1mbs. If user use 1 connection all great,
>  but if it use N connection his speed much more then needed limit =(
> 
> Why i use 20 PC? Becouse 1 pc normal forward 100-150mbs... when it 
> have 100% cpu usage on Sofware Interrupts...
> 
> Any idea how to resolve this problem?
> 
> In my dreams (feature request to netdev ;) ):
> Get PC - title: MASTER TC.  All 20 PC syncronize statistic with 
> MASTER and have common rules and statistic. Then i use variant 2 and 
> will be happy... but its not real? =( Maybe have other variants?
> 
> Thanks for help!
> Slavon.
> P.S. Sorry for my english =(
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

