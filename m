From: Dan Kruchinin <dkruchinin@acm.org>
Subject: [RFC][PATCH] QoS TBF and latency configuration misbehavior
Date: Tue, 31 Aug 2010 17:56:39 +0400
Message-ID: <AANLkTik4Mrzjfk_-u7Qg-B9Q-4tn_seqkkgmwnqQ8FOq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Stephen Hemminger <shemminger@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:65422 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757369Ab0HaN4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 09:56:42 -0400
Received: by ywh1 with SMTP id 1so2199390ywh.19
        for <netdev@vger.kernel.org>; Tue, 31 Aug 2010 06:56:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm sure there is a problem with TBF algorithm configuration in either
tc or documentation describing it. I already mailed description of
this problem to lkml-netdev but I didn't get any feedback.
May be because my description wasn't clear. So here I try to describe
this misbehavior a bit more clear with step-by-step instructions of
how to reproduce the problem.
Please fix me if I'm wrong somewhere.

Description:
man 8 tc-tbf says:
       limit or latency
              Limit  is  the  number of bytes that can be queued
waiting for tokens to become available. You can also specify this the
other way around by setting the latency parameter, which specifies the
              maximum amount of time a packet can sit in the TBF. The
latter calculation takes into account the size of the bucket, the rate
and possibly the peakrate (if set).  These  two  parameters  are
              mutually exclusive.

It's very clear description. According to it the following configuration:
% tc qdisc add dev eth2 root tbf rate 12000 limit 1536 burst 15k

TBF should limit the rate to 12Kbit/s(i.e. 1.5Kb/s), set burst to
15Kb(i.e. it may hold 10 packets of 1.5Kb size)
and set limit equal to MTU.
So I expect that sending packets of equal size(1470 bytes) with a rate
900Kbit/s(i.e. 112.5Kb/s) will transmit only ~17Kb/s:
first 15Kb should be sent immediately and 1 packet will be queued to
the queue of size equal to limit and will wait for available tokens.
Other packets should be dropped.
So let's look at the simple test:
% qdisc tbf 8001: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1536b lat 4285.8s
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

As we can see from tc output latency is equal to 4285.8s and it's of
course not true. With limit ~1.5k latency(as it described in manual)
should be equal to ~1s. But skip this for now.

% iperf -c 192.168.10.2 -u -b 900k -t 1
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 1.0 sec    112 KBytes    900 Kbits/sec
[  3] Sent 78 datagrams
[  3] Server Report:
[  3]  0.0- 2.9 sec  17.2 KBytes  49.3 Kbits/sec  112.169 ms   66/   78 (85%)

%  tc -s -r qdisc show dev eth2
qdisc tbf 8001: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1536b lat 4285.8s
 Sent 19740 bytes 15 pkt (dropped 73, overlimits 77 requeues 0)
 backlog 0b 0p requeues 0

And iperf server output:
[  3]  0.0- 2.9 sec  17.2 KBytes  49.3 Kbits/sec  112.170 ms   66/   78 (85%)

Great. All work as expected(except latency value). But let's replace
limit with equivalent latency.
As manual says: " You can also specify this the other way around by
setting the latency parameter, which specifies the  maximum amount of
time a packet can sit in the TBF".
So with latency equal to ~1.1 second we should get the same result as
above. Let's see:
% tc qdisc del dev eth2 root
% tc qdisc add dev eth2 root tbf rate 12000 latency 1.1s burst 15k
% tc qdisc -s -r show dev eth2
qdisc tbf 8002: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 17010b lat 1.1s
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

Even from the tc output we can see that limit is not equal to
1.5k(which is enough to make packet wait for tokens at most 1s. in TBF
queue) instead it equals to ~17k. I.e. packet will wait for tokens at
most ~11 seconds!

Now let's repeat the last iperf command(as described in first example):
% iperf -c 192.168.10.2 -u -b 900k -t 1
[  3] local 192.168.10.1 port 50305 connected with 192.168.10.2 port 5001
[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 1.0 sec    112 KBytes    900 Kbits/sec
[  3] Sent 78 datagrams

% tc -s -r qdisc show dev eth2
qdisc tbf 8002: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 17010b lat 1.1s
 Sent 37088 bytes 30 pkt (dropped 64, overlimits 106 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0


And iperf server output:
[  4]   0.0-12.9 sec  31.6 KBytes  20.0 Kbits/sec  513.515 ms   56/   78 (72%)

As we can see iperf transmitted > than twice more data than it was
expected by our TBF configuration. First 15k were sent immediately as
expected. Then TBF should enqueued 1 packet
to the queue of packets waiting for tokens but instead it queued 11
packets(~ 1.47k each) and then sent them.

Reasons of described behavior:
If we take a look at linux/net/sched/sch_tbf.c we'll see that kernel
receives limit value from the user-space(see tbf_change) without any
modifications. Then it uses limit to set bfifo queue size(it creates
bfifo queue equal to limit or changes its size if queue already
exist). All incoming packets are queued to this queue. If size of all
packets in the queue plus the size of a packet kernel tries to enqueue
exceeds queue size(limit), packet is dropped. Tokens are allocated
when TBF dequeues packets(see tbf_dequeue). When all tokens are
allocated kernel launches a watchdog timer which will raise when
enough tokens for the next packet in the queue will be available.

1)
So I make an assumption that tc utility makes invalid calculation of
limit by latency. It uses formula(see iproute2/tc/q_tbf.c):
double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC +
buffer; (function tbf_parse_opt)
I.e. limit = (rate * latency)/1000000 + buffer // where buffer == burst size

And then it sends calculated limit value to the kernel. As we can see
from this formula we can not get limit < burst using latency.
And it doesn't matter if latency equal to 1us or 1 second or 5 second
limit will be always greater than burst. And this is invalid
behavior(at least it contradicts to TBF documentation)

2) As we can see from first example we can set limit < than burst
size. For example 1536 bytes. In this case tc shows invalid latency:
% qdisc show dev eth2
qdisc tbf 8001: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1536b lat 4285.8s

It occurs because tc uses the following formula to raise latency by
given limit (see iproute2/tc/q_tbf.c: tbf_print_opt):
latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate) -
tc_core_tick2time(qopt->buffer);
I.e.
latency = 1000000 * (limit / rate) - burst_size.

As we can see if limit < burst, latency will be _negative_. Which is
invalid as well.

Possible solutions:
1) Update documentation and fix description of "limit or latency"
section in order to described above behavior: at least mention:
1.1) that limit can not be < burst.
1.2) how limit is calculated from latency: i.e. limit = latency * rate + burst.
1.3) replace a string "[latency] which specifies the maximum amount of
time a packet can sit in the TBF." In current iproute2 version latency
_doesn't_ specifies this.

2) Use the following patch for tc which fixes limit and latency calculation:
diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index dc556fe..6722a8d 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -178,7 +178,11 @@ static int tbf_parse_opt(struct qdisc_util *qu,
int argc, char **argv, struct nl
        }

        if (opt.limit == 0) {
-               double lim =
opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC + buffer;
+               double lim = opt.rate.rate*(double)latency/TIME_UNITS_PER_SEC;
+
+        if (lim < mtu) {
+            lim = mtu;
+        }
                if (opt.peakrate.rate) {
                        double lim2 =
opt.peakrate.rate*(double)latency/TIME_UNITS_PER_SEC + mtu;
                        if (lim2 < lim)
@@ -263,7 +267,7 @@ static int tbf_print_opt(struct qdisc_util *qu,
FILE *f, struct rtattr *opt)
        if (show_raw)
                fprintf(f, "limit %s ", sprint_size(qopt->limit, b1));

-       latency =
TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate) -
tc_core_tick2time(qopt->buffer);
+       latency = TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->rate.rate);
        if (qopt->peakrate.rate) {
                double lat2 =
TIME_UNITS_PER_SEC*(qopt->limit/(double)qopt->peakrate.rate) -
tc_core_tick2time(qopt->mtu);
                if (lat2 > latency)
=== END OF PATCH ===

With the following patch the first example looks like this:
% tc qdisc add dev eth2 root tbf rate 12000 limit 1536 burst 15k
% tc -s -r qdisc show dev eth2
qdisc tbf 8004: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1536b lat 1.0s
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
% iperf -c 192.168.10.2 -u -b 900k -t 1
 0.0- 2.9 sec  17.2 KBytes  48.7 Kbits/sec  110.741 ms   66/   78 (85%
% tc -s -r qdisc show dev eth2
qdisc tbf 8004: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1536b lat 1.0s
 Sent 19740 bytes 15 pkt (dropped 73, overlimits 76 requeues 0)
 backlog 0b 0p requeues 0

And the second example:
% tc qdisc add dev eth2 root tbf rate 12000 latency 1s burst 15k
% tc -s -r qdisc show dev eth2
qdisc tbf 8005: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1500b lat 1.0s
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
% iperf -c 192.168.10.2 -u -b 900k -t 1
[  3] WARNING: did not receive ack of last datagram after 10 tries.
%  tc -s -r qdisc show dev eth2
qdisc tbf 8008: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1500b lat 1.0s
 Sent 42 bytes 1 pkt (dropped 88, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

And the last example:
% tc qdisc add dev eth2 root tbf rate 12000 latency 1.1s burst 15
% tc -s -r qdisc show dev eth2
qdisc tbf 8009: root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1650b lat 1.1s
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
% iperf -c 192.168.10.2 -u -b 900k -t 1
[  3]  0.0- 2.9 sec  17.2 KBytes  49.3 Kbits/sec  108.758 ms   66/   78 (85%)
% tc -s -r qdisc show dev eth2
qdisc tbf 800a:  root refcnt 2 rate 12000bit burst 15Kb [09896800]
limit 1650b lat 1.1s
 Sent 19698 bytes 14 pkt (dropped 73, overlimits 77 requeues 0)
 backlog 0b 0p requeues 0

Thanks for your attention.

-- 
W.B.R.
Dan Kruchinin
