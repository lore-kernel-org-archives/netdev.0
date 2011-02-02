From: "juice" <juice@swagman.org>
Subject: RE: Using ethernet device as efficient small packet generator
Date: Wed, 2 Feb 2011 10:13:26 +0200
Message-ID: <c0daa8fc2f1ad4e7bd20651265405b37.squirrel@www.liukuma.net>
References: <D3F292ADF945FB49B35E96C94C2061B90ECC4FAC@nsmail.netscout.com>
    <13dbf221c875a931d408784495884998.squirrel@www.liukuma.net>
    <alpine.WNT.2.00.1101211400000.5816@JBRANDEB-DESK2.amr.corp.intel.com>
    <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
Reply-To: juice@swagman.org
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Loke, Chetan" <chetan.loke@netscout.com>,
	"Jon Zhou" <jon.zhou@jdsu.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Stephen Hemming
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.liukuma.net ([62.220.235.15]:46808 "EHLO www.liukuma.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753086Ab1BBINg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 03:13:36 -0500
In-Reply-To: <8ad1defdf427ceb7af94fad4d216b006.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>> your computation of Bandwidth (as Ben Greear said) is not accounting for
>> the interframe gaps.  Maybe more useful is to note that wire speed 64
>> byte packets is 1.44 Million packets per second.
>
> I am aware of the fact that interframe gap eats away some of the bandwidth
> from actual data bytes, and I am taking that into consideration.
> My benchmark here is the Spirent AX4000 network analyzer, which can send
> and receive full utilization of GE line.
>
> The measurement when sending full line rate from AX4000 are:
>   Total bitrate:             761.903 MBits/s
>   Packet rate:               1488090 packets/s
>   Bandwidth:                 76.19% GE
>   Average packet intereval:  0.67 us
>
>
>> I think you need different hardware (again) as you have saddled yourself
>> with a x1 PCIe connected adapter.  This adapter is not well suited to
>> small packet traffic because the sheer amount of transactions is
>> effected
>> by the added latency due to the x1 connector (vs our dual port 1GbE
>> adapters with a x4 connector)
>>
>> with Core i3/5/7 or newer cpus you should be able to saturate a 1Gb link
>> with a single core/queue.  With Core2 era processors you may have some
>> difficulty, with anything older than that you won't make it. :-)
>>
>> My suggestion is to get one of the igb based adapters, 82576, or 82580
>> based that run the igb driver.
>>
>> If you can't get a hold of those you should be able to easily get 1.1M
>> pps from an 82571 adapter.
>
> I will order the 82576 card and try my tests with that.
>

Okay, now I just installed the new hot 82576 DualGE adapter and compiled
the igb module for 2.6.38-rc2 kernel I am running on.

The results with this adapter look very promising, now I am able to reach
the full GE bandwidth with 64 byte packets with only interrupt cpu affinity
tuning, no other tweaks needed:

root@d8labralinux:/var/home/juice/pkt_test# cat /proc/net/pktgen/eth1
Params: count 10000000  min_pkt_size: 60  max_pkt_size: 60
     frags: 0  delay: 0  clone_skb: 0  ifname: eth1
     flows: 0 flowlen: 0
     queue_map_min: 0  queue_map_max: 0
     dst_min: 10.10.11.2  dst_max:
        src_min:   src_max:
     src_mac: 00:1b:21:97:21:76 dst_mac: 00:04:23:08:91:dc
     udp_src_min: 9  udp_src_max: 9  udp_dst_min: 9  udp_dst_max: 9
     src_mac_count: 0  dst_mac_count: 0
     Flags:
Current:
     pkts-sofar: 10000000  errors: 0
     started: 1941436194us  stopped: 1948155853us idle: 179us
     seq_num: 10000001  cur_dst_mac_offset: 0  cur_src_mac_offset: 0
     cur_saddr: 0x0  cur_daddr: 0x20b0a0a
     cur_udp_dst: 9  cur_udp_src: 9
     cur_queue_map: 0
     flows: 0
Result: OK: 6719658(c6719479+d179) nsec, 10000000 (60byte,0frags)
  1488170pps 714Mb/sec (714321600bps) errors: 0

AX4000 measurements:
   Total bitrate:             761.910 MBits/s
   Packet rate:               1488106 packets/s
   Bandwidth:                 76.19% GE
   Average packet intereval:  0.67 us

Now, I need to check if I can send similar rates from userspace socket
interface. If that is possible then it may be so that I do not even need
to create a kernel driver for my application.

Yours, Jussi Ohenoja


