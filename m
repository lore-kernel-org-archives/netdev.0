From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on retransmit window
Date: Wed, 18 Jun 2014 23:05:07 -0700
Message-ID: <12254.1403157907@localhost.localdomain>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com> <20140616211954.6E12BA3A89@unicorn.suse.cz> <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com> <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com> <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com> <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com> <20140617122038.GA7275@unicorn.suse.cz> <CAK6E8=e=EoxMfGMFnO90MVfBWGmoua8=4ptG978-jfD2S-J8Fw@mail.gmail.com> <20140617224241.GA17969@unicorn.suse.cz> <2421.1403051930@localhost.localdomain> <CADVnQy=qdaB7GEK8Ggenr92ckjwM3jOdsS18KEQver=9haWmCA@mail.gmail.com> <11392.1403142743@localhost.localdomain> <1403144937.1225.1.camel@edumazet-glaptop2.roam.corp.google.com>
Cc: Neal Cardwell <ncardwell@google.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Yuchung Cheng <ycheng@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:36692 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaFSGFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 02:05:23 -0400
In-reply-to: <1403144937.1225.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:

>On Wed, 2014-06-18 at 18:52 -0700, Jay Vosburgh wrote:
>> 	The test involves adding 40 ms of delay in and out from machine
>> A with netem, then running iperf from A to B.  Once the iperf reaches a
>> steady cwnd, on B, I add an iptables rule to drop 1 packet out of every
>> 1000 coming from A, then remove the rule after 10 seconds.  The behavior
>> resulting from this closely matches what I see on the real systems.
>
>Please share the netem setup. Are you sure you do not drop frames on
>netem ? (considering you disable GSO/TSO netem has to be able to store a
>lot of packets)

	Reasonably sure; the tc -s qdisc doesn't show any drops by netem
for these test runs.  The data I linked to earlier is one run with
TSO/GSO/GRO enabled, and one with TSO/GSO/GRO disabled, and the results
are similar in terms of cwnd recovery time.  Looking at the packet
capture for the TSO/GSO/GRO disabled case, the time span from the first
duplicate ACK to the last is about 9 seconds, which is close to the 10
seconds the iptables drop rule is in effect; the same time analysis
applies to retransmissions from the sender.

	I've also tested with using netem to induce drops, but in this
particular case I used iptables.

	The script I use to set up netem is:

#!/bin/bash

IF=eth1
TC=/usr/local/bin/tc
DELAY=40ms

rmmod ifb
modprobe ifb
ip link set dev ifb0 up

if ${TC} qdisc show dev ${IF} | grep -q ingress; then
	${TC} qdisc del dev ${IF} ingress
fi
${TC} qdisc add dev ${IF} ingress

${TC} qdisc del dev ${IF} root

${TC} filter add dev ${IF} parent ffff: protocol ip \
	u32 match u32 0 0 flowid 1:1 action mirred egress redirect dev ifb0
${TC} qdisc add dev ifb0 root netem delay ${DELAY} limit 5000
${TC} qdisc add dev ${IF} root netem delay ${DELAY} limit 5000

	In the past I've watched the tc backlog, and the highest I've
seen is about 900 packets, so the limit 5000 is probably overkill.

	I'm also not absolutely sure the delay 40ms each direction is
materially different from 80ms in one direction, but the real
configuration I'm recreating is 40ms each way.

	The tc qdisc stats after the two runs I did earlier to capture
data look like this:

qdisc pfifo_fast 0: dev eth0 root refcnt 2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
 Sent 1905005 bytes 22277 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc netem 8002: dev eth1 root refcnt 2 limit 5000 delay 40.0ms
 Sent 773383636 bytes 510901 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc ingress ffff: dev eth1 parent ffff:fff1 ---------------- 
 Sent 14852588 bytes 281846 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc netem 8001: dev ifb0 root refcnt 2 limit 5000 delay 40.0ms
 Sent 18763686 bytes 281291 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 

	Lastly, I ran the same test on the actual systems, and the iperf
results are similar to my test lab:

[ ID] Interval       Transfer     Bandwidth
[  3]  0.0- 1.0 sec   896 KBytes  7.34 Mbits/sec
[  3]  1.0- 2.0 sec  1.50 MBytes  12.6 Mbits/sec
[  3]  2.0- 3.0 sec  5.12 MBytes  43.0 Mbits/sec
[  3]  3.0- 4.0 sec  13.9 MBytes   116 Mbits/sec
[  3]  4.0- 5.0 sec  27.8 MBytes   233 Mbits/sec
[  3]  5.0- 6.0 sec  39.0 MBytes   327 Mbits/sec
[  3]  6.0- 7.0 sec  36.8 MBytes   308 Mbits/sec
[  3]  7.0- 8.0 sec  36.8 MBytes   308 Mbits/sec
[  3]  8.0- 9.0 sec  37.0 MBytes   310 Mbits/sec
[  3]  9.0-10.0 sec  36.6 MBytes   307 Mbits/sec
[  3] 10.0-11.0 sec  33.9 MBytes   284 Mbits/sec
[  3] 11.0-12.0 sec  0.00 Bytes  0.00 bits/sec
[  3] 12.0-13.0 sec  0.00 Bytes  0.00 bits/sec
[  3] 13.0-14.0 sec  4.38 MBytes  36.7 Mbits/sec
[  3] 14.0-15.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 15.0-16.0 sec  7.00 MBytes  58.7 Mbits/sec
[  3] 16.0-17.0 sec  8.62 MBytes  72.4 Mbits/sec
[  3] 17.0-18.0 sec  4.25 MBytes  35.7 Mbits/sec
[  3] 18.0-19.0 sec  8.50 MBytes  71.3 Mbits/sec
[  3] 19.0-20.0 sec  4.25 MBytes  35.7 Mbits/sec
[  3] 20.0-21.0 sec  6.50 MBytes  54.5 Mbits/sec
[  3] 21.0-22.0 sec  6.38 MBytes  53.5 Mbits/sec
[  3] 22.0-23.0 sec  6.50 MBytes  54.5 Mbits/sec
[  3] 23.0-24.0 sec  8.50 MBytes  71.3 Mbits/sec
[  3] 24.0-25.0 sec  8.50 MBytes  71.3 Mbits/sec
[  3] 25.0-26.0 sec  8.38 MBytes  70.3 Mbits/sec
[  3] 26.0-27.0 sec  8.62 MBytes  72.4 Mbits/sec
[  3] 27.0-28.0 sec  8.50 MBytes  71.3 Mbits/sec
[  3] 28.0-29.0 sec  8.50 MBytes  71.3 Mbits/sec
[  3] 29.0-30.0 sec  8.38 MBytes  70.3 Mbits/sec
[  3] 30.0-31.0 sec  8.50 MBytes  71.3 Mbits/sec
[  3] 31.0-32.0 sec  8.62 MBytes  72.4 Mbits/sec
[  3] 32.0-33.0 sec  8.38 MBytes  70.3 Mbits/sec
[  3] 33.0-34.0 sec  10.6 MBytes  89.1 Mbits/sec
[  3] 34.0-35.0 sec  10.6 MBytes  89.1 Mbits/sec
[  3] 35.0-36.0 sec  10.6 MBytes  89.1 Mbits/sec
[  3] 36.0-37.0 sec  12.8 MBytes   107 Mbits/sec
[  3] 37.0-38.0 sec  15.0 MBytes   126 Mbits/sec
[  3] 38.0-39.0 sec  17.0 MBytes   143 Mbits/sec
[  3] 39.0-40.0 sec  19.4 MBytes   163 Mbits/sec
[  3] 40.0-41.0 sec  23.5 MBytes   197 Mbits/sec
[  3] 41.0-42.0 sec  25.6 MBytes   215 Mbits/sec
[  3] 42.0-43.0 sec  30.2 MBytes   254 Mbits/sec
[  3] 43.0-44.0 sec  34.2 MBytes   287 Mbits/sec
[  3] 44.0-45.0 sec  36.6 MBytes   307 Mbits/sec
[  3] 45.0-46.0 sec  38.8 MBytes   325 Mbits/sec
[  3] 46.0-47.0 sec  36.5 MBytes   306 Mbits/sec

	This result is consistently repeatable.  These systems have more
hops between them than my lab systems, but the ping RTT is 80ms.

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
