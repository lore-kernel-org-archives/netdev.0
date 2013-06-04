From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH] net_sched: htb: do not mix 1ns and 64ns time units
Date: Tue, 4 Jun 2013 22:21:35 +0200
Message-ID: <20130604222135.67eedab8@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
	<20130604141342.00c8eb9f@redhat.com>
	<1370359133.24311.208.camel@edumazet-glaptop>
	<1370361306.24311.214.camel@edumazet-glaptop>
	<1370361727.24311.215.camel@edumazet-glaptop>
	<1370365908.24311.222.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Benc <jbenc@redhat.com>, David Miller <davem@redhat.com>,
	j.vimal@gmail.com, Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, bloat@lists.bufferbloat.net,
	Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324Ab3FDUWM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 16:22:12 -0400
In-Reply-To: <1370365908.24311.222.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Jun 2013 10:11:48 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 56b765b79 ("htb: improved accuracy at high rates") added
> another regression for low rates, because it mixes 1ns and 64ns time
> units.
> 
> So the maximum delay (mbuffer) was not 60 second, but 937 ms.
> 
> Lets convert all time fields to 1ns as 64bit arches are becoming the
> norm.

I'm of-cause happy as I need this fixed for big-HW machines at Red Hat.

But how is this 64-bit usage going to affect performance for smaller
ARM/MIPS based home routers, where shaping at these low rates is more
relevant?  (I'm just asking because I don't know, and just test this
on a 24-CPU machine).

Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>

I have tested you patch, and it works for me.
Tested shaping at 100Kbit/s:
 - max "rate 100656bit" on dev lo
 - max "rate 102016bit" on a real  1 Gbit/s NIC (dev eth63).
 - max "rate 103256bit" on a real 10 Gbit/s NIC (dev eth31).

The traffic "of-cause" spikes due to the GSO frames, if measuring the
traffic at a higher resolution (I've seen upto 3 sec without traffic).

Thanks for the quick fix! :-)))
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

Reproducer commands:
 tc qdisc add dev lo root handle 1: htb default 1
 tc class add dev lo parent 1: classid 1:1 htb rate 100kbit
 netserver
 netperf -t TCP_STREAM -l 60 -H 127.0.0.1 -- -m 1024

Measuring the qdisc "rate" via:
 tc -s -d class show dev lo classid 1:1

Data:
=====
>From dev "lo":
--------------
class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burst 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0 
 Sent 597719 bytes 64 pkt (dropped 942, overlimits 0 requeues 0) 
 rate 100656bit 1pps backlog 0b 1p requeues 0 
 lended: 64 borrowed: 0 giants: 0
 tokens: -27387576 ctokens: -27387576

>From 1Gbit/s dev eth63:
-----------------------
class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burst 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0 
 Sent 1801152 bytes 3224 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 102016bit 9pps backlog 0b 12p requeues 0 
 lended: 2284 borrowed: 0 giants: 0
 tokens: -18923820 ctokens: -18923820


>From 10Gbit/s dev eth31:
------------------------
class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit burst 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b level 0 
 Sent 855814 bytes 581 pkt (dropped 0, overlimits 0 requeues 0) 
 rate 103256bit 9pps backlog 0b 9p requeues 0 
 lended: 81 borrowed: 0 giants: 0
 tokens: -45419150 ctokens: -45419150
