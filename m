From: Jiri Pirko <jiri@resnulli.us>
Subject: inaccurate packet scheduling
Date: Tue, 18 Dec 2012 16:04:07 +0100
Message-ID: <20121218150407.GB1533@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, davem@davemloft.net, edumazet@google.com,
	tgraf@suug.ch, shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:62969 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152Ab2LRP2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 10:28:48 -0500
Received: by mail-wi0-f172.google.com with SMTP id o1so2790735wic.5
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 07:28:47 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all.

Run one of the following 2 scripts on machine A:

#!/bin/bash
tc qdisc del dev eth0 root
sleep 1
tc -batch << EOF
qdisc add dev eth0 root handle 1: prio bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
qdisc add dev eth0 parent 1:1 handle 10: pfifo limit 50
qdisc add dev eth0 parent 1:2 handle 20 tbf latency 100ms rate 4mbit burst 2m
filter add dev eth0 parent 1: protocol ip u32 match ip dst $machineB_ip flowid 1:2
EOF

#!/bin/bash
tc qdisc del dev eth0 root
sleep 1
tc -batch << EOF
qdisc add dev eth0 root handle 1: prio bands 2 priomap 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
qdisc add dev eth0 parent 1:1 handle 10: pfifo limit 20
qdisc add dev eth0 parent 1:2 handle 20: pfifo limit 20
filter add dev eth0 parent 1: protocol ip pref 10 \
u32 match ip dst $machineB_ip \
flowid 1:2 \
police rate 4Mbit burst 2m conform-exceed drop
EOF

And run:
[machineB ~]# iperf -s
[machineA ~]# iperf -c machineB_ip -t 60

Expected results are: ~3.8-4.2 Mbits/s
But actual results are: ~130-170 Kbits/s with tbf, ~70-300 Kbits/s with policy rate

[machineA ~]# tc -s qdisc list dev eth0
qdisc prio 1: root refcnt 9 bands 2 priomap  0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 Sent 1512384 bytes 1032 pkt (dropped 729, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc pfifo 10: parent 1:1 limit 50p
 Sent 4560 bytes 32 pkt (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc tbf 20: parent 1:2 rate 4000Kbit burst 2Mb lat 100.0ms 
 Sent 1507824 bytes 1000 pkt (dropped 729, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 


Tested with kernel pulled from linus's git today. This happens with older
kernels as well (I tried 2.6.32-based rhel6 kernels).

This happens to me on following machines:
HP DL360G8 (x86_64) http://people.redhat.com/jpirko/aThoo2Ei/dl380g8/
HP DL360G3 (i686) 
IBM JS22 (ppc64) http://people.redhat.com/jpirko/aThoo2Ei/ibmjs22/

On following machines, I do not observe this issue:
qemu kvm (x86_64)
IBM Zseries (s390x) http://people.redhat.com/jpirko/aThoo2Ei/ibmz/

Please ask in case you need me to provide any other details.

Thanks.

Jiri
