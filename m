From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 17:48:00 -0700
Message-ID: <576B31C0.8090301@hpe.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <576B1AE8.6030309@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:43579 "EHLO
	g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFWAsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 20:48:03 -0400
In-Reply-To: <576B1AE8.6030309@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/2016 04:10 PM, Rick Jones wrote:
> My systems are presently in the midst of an install but I should be able
> to demonstrate it in the morning (US Pacific time, modulo the shuttle
> service of a car repair place)

The installs finished sooner than I thought.  So, receiver:


root@np-cp1-comp0001-mgmt:/home/stack# uname -a
Linux np-cp1-comp0001-mgmt 4.4.11-2-amd64-hpelinux #hpelinux1 SMP Mon 
May 23 15:39:22 UTC 2016 x86_64 GNU/Linux
root@np-cp1-comp0001-mgmt:/home/stack# ethtool -i hed2
driver: bnx2x
version: 1.712.30-0
firmware-version: bc 7.10.10
bus-info: 0000:05:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

the hed2 interface is a port of an HPE 630M NIC, based on the BCM57840:

05:00.0 Ethernet controller: Broadcom Corporation BCM57840 NetXtreme II 
10/20-Gigabit Ethernet (rev 11)
	Subsystem: Hewlett-Packard Company HP FlexFabric 20Gb 2-port 630M Adapter

(The pci.ids entry being from before that 10 GbE IP was purchased from 
Broadcom by QLogic...)

Verify that LRO is disabled (IIRC it is enabled by default):

root@np-cp1-comp0001-mgmt:/home/stack# ethtool -k hed2 | grep large
large-receive-offload: off

Verify that disable_tpa is not set:

root@np-cp1-comp0001-mgmt:/home/stack# cat 
/sys/module/bnx2x/parameters/disable_tpa
0

So this means we will see NIC-firmware GRO.

Start a tcpdump on the receiver:
root@np-cp1-comp0001-mgmt:/home/stack# tcpdump -s 96 -c 2000000 -i hed2 
-w foo.pcap port 12867
tcpdump: listening on hed2, link-type EN10MB (Ethernet), capture size 96 
bytes

Start a netperf test targeting that system, specifying a smaller MSS:

stack@np-cp1-comp0002-mgmt:~$ ./netperf -H np-cp1-comp0001-guest -- -G 
1400 -P 12867 -O throughput,transport_mss
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET to 
np-cp1-comp0001-guest () port 12867 AF_INET : demo
Throughput Transport
            MSS
            bytes

3372.82    1388

Come back to the receiver and post-process the tcpdump capture to get 
the average segment size for the data segments:

2000000 packets captured
2000916 packets received by filter
0 packets dropped by kernel
root@np-cp1-comp0001-mgmt:/home/stack# tcpdump -n -r foo.pcap | fgrep -v 
"length 0" | awk '{sum += $NF}END{print "Average:",sum/NR}'
reading from file foo.pcap, link-type EN10MB (Ethernet)
Average: 2741.93

and finally a snippet of the capture:

00:37:47.333414 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [S], seq 
1236484791, win 28000, options [mss 1400,sackOK,TS val 1491134 ecr 
0,nop,wscale 7], length 0
00:37:47.333488 IP 192.168.2.7.12867 > 192.168.2.8.12867: Flags [S.], 
seq 134167501, ack 1236484792, win 28960, options [mss 1460,sackOK,TS 
val 1499053 ecr 1491134,nop,wscale 7], length 0
00:37:47.333731 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], ack 
1, win 219, options [nop,nop,TS val 1491134 ecr 1499053], length 0
00:37:47.333788 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
1:2777, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 1499053], 
length 2776
00:37:47.333815 IP 192.168.2.7.12867 > 192.168.2.8.12867: Flags [.], ack 
2777, win 270, options [nop,nop,TS val 1499053 ecr 1491134], length 0
00:37:47.333822 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
2777:5553, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 1499053], 
length 2776
00:37:47.333837 IP 192.168.2.7.12867 > 192.168.2.8.12867: Flags [.], ack 
5553, win 313, options [nop,nop,TS val 1499053 ecr 1491134], length 0
00:37:47.333842 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
5553:8329, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 1499053], 
length 2776
00:37:47.333856 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
8329:11105, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.333869 IP 192.168.2.7.12867 > 192.168.2.8.12867: Flags [.], ack 
8329, win 357, options [nop,nop,TS val 1499053 ecr 1491134], length 0
00:37:47.333879 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
11105:13881, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.333891 IP 192.168.2.7.12867 > 192.168.2.8.12867: Flags [.], ack 
11105, win 400, options [nop,nop,TS val 1499053 ecr 1491134], length 0
00:37:47.333911 IP 192.168.2.7.12867 > 192.168.2.8.12867: Flags [.], ack 
13881, win 444, options [nop,nop,TS val 1499053 ecr 1491134], length 0
00:37:47.333964 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
13881:16657, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.333982 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
16657:19433, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.333989 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
19433:22209, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.333994 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
22209:24985, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.334011 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
24985:27761, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.334018 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
27761:30537, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.334025 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
30537:33313, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776
00:37:47.334031 IP 192.168.2.8.12867 > 192.168.2.7.12867: Flags [.], seq 
33313:36089, ack 1, win 219, options [nop,nop,TS val 1491134 ecr 
1499053], length 2776

2776 being twice 1388.

happy benchmarking,

rick jones

root@np-cp1-comp0001-mgmt:/home/stack# tcpdump -n -r foo.pcap | fgrep -v 
-e "length 0" | fgrep length | awk '{print $NF}' | sort | uniq -c | sort -nr
reading from file foo.pcap, link-type EN10MB (Ethernet)
1400584 2776
    5930 1388
      17 2544
      15 1620
      13 2560
      13 2000
      12 2604
      12 2504
      12 2456
      12 1708
      ...
