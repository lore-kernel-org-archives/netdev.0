From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Bad shaping at low rates, after commit 56b765b79 (htb: improved
 accuracy at high rates)
Date: Tue, 4 Jun 2013 14:13:42 +0200
Message-ID: <20130604141342.00c8eb9f@redhat.com>
References: <20130529151330.22c5c89e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	David Miller <davem@redhat.com>, j.vimal@gmail.com,
	Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40370 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471Ab3FDMOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 08:14:14 -0400
In-Reply-To: <20130529151330.22c5c89e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

I found another regression by commit 56b765b79 (htb: improved accuracy
at high rates).

After the commit HTB does not honor network rate limiting below 500kbps.

I have found that the bandwidth problem is related to GSO being enabled
on the device.  To test the situation, I had to use a real NIC (as I
were not allowed to disable GSO on dev "lo", test below).

Testing with 100kbit/s:
-----------------------
A localhost dev "lo" reproducer commands:
 tc qdisc add dev lo root handle 1: htb default 1
 tc class add dev lo parent 1: classid 1:1 htb rate 100kbit
 netserver
 netperf -t TCP_STREAM -l 60 -H 127.0.0.1 -- -m 1024

Measuring the qdisc "rate" via:
 tc -s -d class show dev lo classid 1:1

I know the qdisc "rate" is not not very reliable/accurate, but I do
see a large difference (and so do netperf reported throughput).
 - Kernel 2.6.32-352.el6 gives rate 98752bit
 - Kernel 3.10.0-rc1     gives rate 390208bit

My real-NIC test show:
 With GSO: rate 153248bit
 Without GSO: rate 99320bit

Now, we just have to figure out why commit 56b765b79e (htb: improved
accuracy at high rates) breaks bandwidth shaping at low rate with GSO
enabled...

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

Data: real NIC
==============

With GSO: rate 153248bit
---------
class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit
burst 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b
level 0 Sent 844892 bytes 568 pkt (dropped 0, overlimits 0 requeues 0)
rate 153248bit 13pps backlog 0b 7p requeues 0 lended: 87 borrowed: 0
giants: 0 tokens: -847776554 ctokens: -847776554

Without GSO: rate 99320bit
------------
(disabled via: ethtool -K eth63 gso off gro off tso off)

class htb 1:1 root prio 0 quantum 1250 rate 100000bit ceil 100000bit
burst 1600b/1 mpu 0b overhead 0b cburst 1600b/1 mpu 0b overhead 0b
level 0 Sent 1706968 bytes 1164 pkt (dropped 0, overlimits 0 requeues
0) rate 99320bit 8pps backlog 0b 51p requeues 0 lended: 664 borrowed: 0
giants: 0 tokens: -121054491 ctokens: -121054491
