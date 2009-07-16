From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: ixgbe:  schedule while atomic bug during dev_disable_lro
 2.6.31-rc3
Date: Thu, 16 Jul 2009 21:58:48 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0907162143460.15031@ask.diku.dk>
References: <4A5E5F8A.308@candelatech.com>
 <Pine.WNT.4.64.0907161206260.5316@ppwaskie-MOBL2.amr.corp.intel.com>
 <4A5F8062.6090009@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:52543 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933144AbZGPUAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 16:00:37 -0400
In-Reply-To: <4A5F8062.6090009@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Jul 2009, Ben Greear wrote:

> On 07/16/2009 12:13 PM, Waskiewicz Jr, Peter P wrote:
>>  On Wed, 15 Jul 2009, Ben Greear wrote:
>> 
>> >  I just got a fancy new 10G NIC and tried it out in a (patched elsewhere, 
>> >  but stock ixgbe driver) 2.6.31-rc3) kernel.
>> > 
>> >  First of all, it runs very fast:  sustained 9.5Gbps tx + rx on two ports 
>> >  concurrently (using modified pktgen),
>> >  with 1500 byte pkts.

Yes, its very fast!  Using pktgen, I can generate 11Mpps with 64 bytes 
packets.  Compared to my other 10GbE NIC which can do 3-4 Mpps.

>> >  ixgbe 0000:03:00.0: This device is a pre-production adapter/LOM.  Please 
>> >  be aware there may be issues associated with your hardware.  If you are 
>> >  experiencing
>> >  problems please contact your Intel or hardware representative who 
>> >  provided you with this hardware.
>>
>>  It's self-explanatory; the EEPROM version on the NIC is not the
>>  production-level EEPROM.  If you run ethtool -i ethX on this interface,
>>  you will see what the firmware (EEPROM) version is.  My guess is it's
>>  going to be 0.5-1 or something; the production firmware is 0.9-3.  If you
>>  received this NIC from an Intel rep, they can get you the production
>>  EEPROM and tools necessary to reprogram the NIC.
>
> Yes, 0.5-1

I'm running firmware-version: 0.9-3 (which I think Peter upgraded for me).

I'm also seeing the issue (sorry for not reporting it before now, Peter, I 
was going to bring it up later.  Didn't think the NIC was being shipped 
yet)


> I believe the trigger for this is my script that enables ip_forward.  I'm
> not twiddling LRO settings directly as far as I can tell.

Also think its when the boot scripts enable ip_forward.

See the devinet_sysctl_forward() call below.

root@firesoul:~# uname -a
Linux firesoul 2.6.31-rc1-net-2.6-00122-ge594e96 #8 SMP PREEMPT Fri Jul 10 17:01:40 CEST 2009 x86_64 GNU/Linux


[   11.729520] ixgbe: eth33 NIC Link is Up 10 Gbps, Flow Control: RX/TX
[   11.729541] ixgbe: eth33 NIC Link is Up 10 Gbps, Flow Control: RX/TX
[   12.496856] BUG: scheduling while atomic: sysctl/3214/0x00000002
[   12.497184] Modules linked in: asus_atk0110 ixgbe hwmon mdio r8169
[   12.497190] Pid: 3214, comm: sysctl Not tainted 2.6.31-rc1-net-2.6-00122-ge594e96 #8
[   12.497192] Call Trace:
[   12.497198]  [<ffffffff8102f8c2>] __schedule_bug+0x57/0x5c
[   12.497202]  [<ffffffff81428291>] schedule+0xcb/0x88f
[   12.497206]  [<ffffffff810aaedb>] ? __inc_zone_state+0x11/0x75
[   12.497211]  [<ffffffff81044301>] ? lock_timer_base+0x26/0x4a
[   12.497214]  [<ffffffff8142a10a>] ? _spin_unlock_irqrestore+0x2c/0x37
[   12.497217]  [<ffffffff81044872>] ? __mod_timer+0x102/0x114
[   12.497220]  [<ffffffff81428d7f>] schedule_timeout+0x98/0xbf
[   12.497223]  [<ffffffff81044413>] ? process_timeout+0x0/0xb
[   12.497225]  [<ffffffff81428d7a>] ? schedule_timeout+0x93/0xbf
[   12.497228]  [<ffffffff81428dbf>] schedule_timeout_uninterruptible+0x19/0x1b
[   12.497231]  [<ffffffff81044898>] msleep+0x14/0x1e
[   12.497240]  [<ffffffffa001d19f>] ixgbe_down+0xc7/0x25e [ixgbe]
[   12.497248]  [<ffffffffa001e512>] ixgbe_reinit_locked+0x59/0x70 [ixgbe]
[   12.497256]  [<ffffffffa0020691>] ixgbe_set_flags+0x52/0x66 [ixgbe]
[   12.497260]  [<ffffffff813882f6>] dev_disable_lro+0x4d/0x69
[   12.497264]  [<ffffffff813d904e>] devinet_sysctl_forward+0xd2/0x1a2
[   12.497268]  [<ffffffff8110aea9>] proc_sys_call_handler+0x96/0xbc
[   12.497272]  [<ffffffff811a9482>] ? __up_read+0x92/0x9c
[   12.497274]  [<ffffffff8110aede>] proc_sys_write+0xf/0x11
[   12.497277]  [<ffffffff810cd625>] vfs_write+0xab/0x105
[   12.497280]  [<ffffffff810cd743>] sys_write+0x47/0x6e
[   12.497284]  [<ffffffff8100baeb>] system_call_fastpath+0x16/0x1b



Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
