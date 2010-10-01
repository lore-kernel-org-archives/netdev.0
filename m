From: Alexey Vlasov <renton@renton.name>
Subject: Re: Packet time delays on multi-core systems
Date: Fri, 1 Oct 2010 14:16:50 +0400
Message-ID: <20101001101650.GD4094@beaver.vrungel.ru>
References: <20100929191851.GC86786@beaver.vrungel.ru> <1285796721.5211.156.camel@edumazet-laptop> <20100930062419.GD86786@beaver.vrungel.ru> <1285828432.5211.812.camel@edumazet-laptop> <20100930122321.GA1575@beaver.vrungel.ru> <1285850669.2615.426.camel@edumazet-laptop> <20100930173732.GB4094@beaver.vrungel.ru> <1285869782.2615.920.camel@edumazet-laptop> <20100930181556.GC4094@beaver.vrungel.ru> <1285872765.2615.1008.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.df.ru ([195.42.160.16]:41864 "EHLO smtp.df.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756169Ab0JAKSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 06:18:48 -0400
Content-Disposition: inline
In-Reply-To: <1285872765.2615.1008.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 30, 2010 at 08:52:45PM +0200, Eric Dumazet wrote:
> 
> If you have a burst of 'LOG' matches, it can really slow down the whole
> thing.
> 
> You should add a limiter (eg: no more than 5 messages per second)
> 
> http://netfilter.org/documentation/HOWTO/packet-filtering-HOWTO-7.html

Yes, sometimes there aren't even 5 packets a second, but also it slows down.
So I don't think this is the reason.

I have also found that:
1. rx overruns is increasing.
2. rx_queue_drop_packet_count is increasing.
# ethtool -S eth0 | grep drop
     tx_dropped: 0
     rx_queue_drop_packet_count: 1260743751
     dropped_smbus: 0
     rx_queue_0_drops: 0
     rx_queue_1_drops: 0
     rx_queue_2_drops: 0
     rx_queue_3_drops: 0

3. By sending SYN-packets by hping, RST packet doesn't send, but I don't know may 
be it is just some feature in 2.6.32.
newbox # hping -c 1 -S -p 80 111.111.111.111
HPING 111.111.111.111 (eth0 111.111.111.111): S set, 40 headers + 0 data bytes
len=46 ip=111.111.111.111 ttl=58 DF id=11471 sport=80 flags=SA seq=0 win=65535 rtt=99.0 ms

--- 111.111.111.111 hping statistic ---
1 packets tramitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 99.0/99.0/99.0 ms

13:59:07.439528 IP newbox.2777 > 111.111.111.111.80: S 345595033:345595033(0) win 512
13:59:07.439626 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>
13:59:10.439368 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>
13:59:16.439313 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>
13:59:28.439206 IP 111.111.111.111.80 > newbox.2777: S 1178827395:1178827395(0) ack 345595034 win 65535 <mss 1460>

As a result I got doubles:
DUP! len=46 ip=111.111.111.111 ttl=58 DF id=27454 sport=80 flags=SA seq=0 win=65535 rtt=3137.8 ms

Example of another TCP-session from 2.6.28 kernel:
oldbox # hping -c 1 -S -p 80 111.111.111.111
HPING 111.111.111.111 (eth0 111.111.111.111): S set, 40 headers + 0 data bytes
len=46 ip=111.111.111.111 ttl=58 DF id=53180 sport=80 flags=SA seq=0 win=65535 rtt=2.9 ms

--- 111.111.111.111 hping statistic ---
1 packets tramitted, 1 packets received, 0% packet loss
round-trip min/avg/max = 2.9/2.9/2.9 ms

14:01:45.225136 IP oldbox.2776 > 111.111.111.111.80: S 1983626200:1983626200(0) win 512
14:01:45.225288 IP 111.111.111.111.80 > oldbox.2776: S 3796385036:3796385036(0) ack 1983626201 win 65535 <mss 1460>
14:01:45.227990 IP oldbox.2776 > 111.111.111.111.80: R 1983626201:1983626201(0) win 0

-- 
BRGDS. Alexey Vlasov.
