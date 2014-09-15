From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Mon, 15 Sep 2014 18:45:17 +0200
Message-ID: <20140915184517.6c5474e5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	Toke =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNl?= =?UTF-8?B?bg==?=
	<toke@toke.dk>, Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18244 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752224AbaIOQqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 12:46:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Eric,

I've constructed a "netperf-wrapper" test for measuring Head-of-Line
blocking, called "tcp_upload_prio", that I hope you will approve of?

 https://github.com/tohojo/netperf-wrapper/commit/1e6b755e8051b6

The basic idea is to have ping packets with TOS bit 0x10, which end-up
in the high-prio band of pfifo_fast.  While two TCP uploads utilize
all the bandwidth.

These high-prio ping packet should then demonstrate the Head-of-Line
blocking occurring due to 1) packets in the HW TX ring buffer, or
2) in the qdisc layers requeue mechanism.  Disgusting these two case
might be a little difficult.



Special care need to be take for using this on the default
qdisc MQ which have pfifo_fast assigned for every HW queue.

Setup requirements:
 1. IRQ align CPUs to NIC HW queues
 2. Force netperf-wrapper subcommands to run the same CPU
  E.g: taskset -c 2 ./netperf-wrapper -H IP tcp_upload_prio

This will force all measurements to go through the same qdisc.  This
is needed so the ping/latency tests measures the real property of
the qdisc and Head-of-Line blocking effect.


Basically the same as:
 sudo taskset -c 2 ping -Q 0x10 192.168.8.2
 sudo taskset -c 2 ping         192.168.8.2
 sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
 sudo taskset -c 2 netperf   -H 192.168.8.2 -t TCP_STREAM -l 120
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
