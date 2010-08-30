From: Dan Kruchinin <dkruchinin@acm.org>
Subject: [RFC] tc: Possible bug in TBF latency
Date: Mon, 30 Aug 2010 13:23:39 +0400
Message-ID: <AANLkTi=ALM5LyUpoJ0dPxE9WH91tnPzaZAjvePngjfnN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:38175 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043Ab0H3JXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Aug 2010 05:23:40 -0400
Received: by qwh6 with SMTP id 6so4658987qwh.19
        for <netdev@vger.kernel.org>; Mon, 30 Aug 2010 02:23:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, list.

I'm not sure but I think there is a bug in tc TBF configuration code
when it calculates limit by given latency, so I need some comments.
kernel version: 2.6.35.1
iproute2 version: commit cb4bd0ec8dcba856d1ebf8b3f72b79f669dad0f4

Here is an example of my configuration:
% tc qdisc add dev eth2 root tbf rate 12000 latency 1 burst 15k
% tc qdisc show dev eth2
qdisc tbf 8005: root refcnt 2 rate 12000bit burst 15Kb lat 0us

Here tc creates 15K burst, sets rate = 12Kbit/s(1.5 KB/s)
As I understand it means that:
1) Filling the burst with 1.5Kb data takes 10 seconds
2) near zero latency assumes that size of waiting queue will be very
small and data that arrives at higher rate will be dropped.

So, here is a simple test: form a machine with configured TBF as
described above I send data at a rate 900 kbit/sec.
Here is the output:
% iperf -u -c 192.168.10.2 -t 1 -b 900k
------------------------------------------------------------
Client connecting to 192.168.10.2, UDP port 5001
Sending 1470 byte datagrams
UDP buffer size:   124 KByte (default)
------------------------------------------------------------
[  3] local 192.168.10.1 port 33116 connected with 192.168.10.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 1.0 sec    112 KBytes    900 Kbits/sec
[  3] Sent 78 datagrams
[  3] WARNING: did not receive ack of last datagram after 10 tries.

Here is the output of iperf server on another machine:
[  3]  0.0-11.9 sec  30.1 KBytes  20.7 Kbits/sec  483.539 ms   57/   78 (73%)

And the qdisc statistics:
% tc -s qdisc show dev eth2
tc -s qdisc show dev eth2
qdisc tbf 8007: root refcnt 2 rate 12000bit burst 15Kb lat 0us
 Sent 34902 bytes 26 pkt (dropped 65, overlimits 89 requeues 0)
 backlog 0b 9p requeues 0

As we can see from backlog TBF queued 9 packets and as we can see from
"Sent" it sent twice more bytes than it should.
According to TBF description all packets that fit into the burst are
sent immediately. When
the burst is full arriving packets must be queued into the queue(with
specified by limit/latency size)
and wait for available tokens.
Really, first 15Kb were sent without any delay then burst became full
and arriving packets were
enqueued into the waiting queue. With rate = 1.5Kb and bucket size =
15Kb first packet in the waiting
queue will be sent for 10 seconds. As we can see from iperf server
output it's true.
But the waiting queue must not queue more than 1.5Kb according to my
configuration(limit = 1us).
Somehow it holds 9 packets which(according to configuration) must be
dropped. Right?

As I can see from the tc code it calculates limit by given latency as
the follow(tc/q_tbf.c: tbf_parse_opt):
double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC + buffer;

In our case rate is 1500, latency is 1 and buffer(burst) is 15360. By
that formula, limit of the queue is greater or equal to the burst
size. In this case latency 1 doesn't distinguishes from latency 1000
right? Does we really need to add buffer to the limit? It seems irrelevant.

Thanks.

-- 
W.B.R.
Dan Kruchinin
