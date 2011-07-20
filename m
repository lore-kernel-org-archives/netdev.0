From: Rick Jones <rick.jones2@hp.com>
Subject: Just one more byte, it is wafer thin...
Date: Wed, 20 Jul 2011 16:28:32 -0700
Message-ID: <4E2764A0.90003@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:15980 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701Ab1GTXgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 19:36:21 -0400
Received: from g4t0009.houston.hp.com (g4t0009.houston.hp.com [16.234.32.26])
	by g4t0016.houston.hp.com (Postfix) with ESMTP id 1D30414BF9
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 23:36:21 +0000 (UTC)
Received: from [16.89.244.213] (tardy.cup.hp.com [16.89.244.213])
	by g4t0009.houston.hp.com (Postfix) with ESMTP id 3722EC280
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 23:28:33 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One of the netperf scripts I run from time to time is the 
packet_byte_script (doc/examples/packet_byte_script in the netperf 
source tree, though I tweaked it locally to use omni output selectors). 
  The goal of that script is to measure the incremental cost of sending 
another byte and/or another TCP segment.  Among other things, it runs RR 
tests where the request or response size is incremented.  It starts at 1 
byte, doubles until it would exceed the MSS, then does 1MSS, 1MSS+1, 
2MSS, 2MSS+1 and 3MSS, 3MSS+1.

I recently ran it between a pair of dual-processor X5650 based systems 
with 10GbE NICs based on Mellanox MT26438 running as a 10GbE interface. 
The kernel is 2.6.38-8-server (maverick) and the driver info is:

# ethtool -i eth2
driver: mlx4_en (HP_0200000003)
version: 1.5.1.6 (August 2010)
firmware-version: 2.7.9294
bus-info: 0000:05:00.0

(yes, that HP_mumble does broach the possibility of a local fubar. i'd 
try a pure upstream myself but the systems at my disposal are somewhat 
locked-down, i'm hoping someone with a "pure" environment can reproduce 
the result, or not)

The full output can be seen at:

ftp://ftp.netperf.org/netperf/misc/sl390_NC543i_mlx4_en_1.5.1.6_Ubuntu_11.04_A5800_56C_to_same_pab_1500mtu_20110719.csv

I wasn't entirely sure what TSO and LRO/GRO would mean for the script, 
at first I thought I wouldn't get the +1 trip down the stack, but the 
transaction rates all looked reasonably "sane" until the 3MSS to 3MSS+1 
transition, when the transaction rate dropped by something like 70%. And 
stayed there as the request size was increased further in other testing. 
I looked at a tcpdump trace on the sending and receiving side - LRO/GRO 
had coalesced segments into the full request size.  On the sending side 
though, I was seeing one segment of 3MSS and one of one byte.  At first 
I thought that perhaps something was fubar with cwnd, but looking at 
traces for 2MSS(+1) and 1MSS(+1) I saw that is just what TSO does - only 
send integer multiples of the MSS as TSO.  So, while that does 
interesting things to the service demand for a given transaction size, 
it probably wasn't the culprit.


It would seem that the adaptive-rx was.  Previously, the coalescing 
settings on the receiver (netserver side) were:

# ethtool -c eth2
Coalesce parameters for eth2:
Adaptive RX: on  TX: off
stats-block-usecs: 0
sample-interval: 0
pkt-rate-low: 400000
pkt-rate-high: 450000

rx-usecs: 16
rx-frames: 44
rx-usecs-irq: 0
rx-frames-irq: 0

tx-usecs: 0
tx-frames: 0
tx-usecs-irq: 0
tx-frames-irq: 0

rx-usecs-low: 0
rx-frame-low: 0
tx-usecs-low: 0
tx-frame-low: 0

rx-usecs-high: 128
rx-frame-high: 0
tx-usecs-high: 0
tx-frame-high: 0

and netperf would look like:
# HDR="-P 1";for r in 4344 4345; do netperf -H mumble.3.21 -t TCP_RR 
$HDR -- -r ${r},1; HDR="-P 0"; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to mumble.3.21 (mumble.3.21) port 0 AF_INET : histogram : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  4344     1       10.00    10030.37
16384  87380
16384  87380  4345     1       10.00    3406.62
16384  87380

when I switched adaptive rx off via ethtool, the drop largely went away:

# HDR="-P 1";for r in 4344 4345; do netperf -H mumble.3.21 -t TCP_RR 
$HDR -- -r ${r},1; HDR="-P 0"; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to mumble.3.21 (mumble.3.21) port 0 AF_INET : histogram : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  4344     1       10.00    11167.48
16384  87380
16384  87380  4345     1       10.00    10460.02
16384  87380

Now, at 11000 transactions per second, even with the request being 4 
packets, that is still < 55000 packets per second, so presumably 
everything should have stayed at "_low" right?  Just for grins, I put 
adaptive coalescing on again and set rx-usecs-high to 64 and ran those 
two points again:

# HDR="-P 1";for r in 4344 4345; do netperf -H mumble.3.21 -t TCP_RR 
$HDR -- -r ${r},1; HDR="-P 0"; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to mumble.3.21 (mumble.3.21) port 0 AF_INET : histogram : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  4344     1       10.00    11143.07
16384  87380
16384  87380  4345     1       10.00    5790.48
16384  87380

and just to be completely pedantic about it, set rx-usecs-high to 0:

# HDR="-P 1";for r in 4344 4345; do netperf -H mumble.3.21 -t TCP_RR 
$HDR -- -r ${r},1; HDR="-P 0"; done
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET 
to mumble.3.21 (mumble.3.21) port 0 AF_INET : histogram : first burst 0
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  4344     1       10.00    14274.03
16384  87380
16384  87380  4345     1       10.00    13697.11
16384  87380

and got a somewhat unexpected result - I've no idea why then they both 
went up - perhaps it was sensing "high" occasionally even in the 4344 
byte request case.  Still, is this suggesting that perhaps the adaptive 
bits are being a bit to aggressive about sensing high?  Over what 
interval is that measurement supposed to be happening?

rick jones
