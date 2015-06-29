From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Mon, 29 Jun 2015 13:04:47 -0700
Message-ID: <5591A4DF.4010104@hp.com>
References: <1435360189-641007-1-git-send-email-tom@herbertland.com> <558DF24A.1040504@hp.com> <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ramu Ramamurthy <sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:27295 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbbF2UEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 16:04:50 -0400
In-Reply-To: <df94e5b8a0ed7a9146063908e3001ef3@imap.linux.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I went ahead and put the patched kernel on both systems.  I was getting 
mixed results - in one direction, results in the 8Gbit/s range, in the 
other in the 7 Gbit/s.  I noticed that interrupts were going to 
different CPUs so I started playing with IRQ assignments, and bound all 
interrupts of the 82599ES to CPU0 to remove that variable.  At that 
point I started getting 8.X Gbit/s consistently in either direction.

root@qu-stbaz1-perf0000:~# HDR="-P 1"; for i in `seq 1 5`; do netperf -H 
192.168.0.22 -l 30 $HDR -c -C -- -O 
throughput,local_cpu_util,local_sd,local_cpu_peak_util,local_cpu_peak_id,remote_cpu_util,remote_sd,remote_cpu_peak_util,remote_cpu_peak_id; 
HDR="-P 0"; done
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.0.22 () port 0 AF_INET : demo
Throughput Local Local   Local   Local   Remote Remote  Remote  Remote
            CPU   Service Peak    Peak    CPU    Service Peak    Peak
            Util  Demand  Per CPU Per CPU Util   Demand  Per CPU Per CPU
            %             Util %  ID      %              Util %  ID
8768.48    1.95  0.582   62.22   0       4.36   1.304   99.97   0
8757.99    1.95  0.583   62.27   0       4.37   1.307   100.00  0
8793.86    2.01  0.600   64.32   0       4.23   1.262   100.00  0
8720.98    1.93  0.580   61.67   0       4.45   1.337   99.97   0
8380.49    1.84  0.575   58.74   0       4.39   1.374   100.00  0


root@qu-stbaz1-perf0001:~# HDR="-P 1"; for i in `seq 1 5`; do netperf -H 
192.168.0.21 -l 30 $HDR -c -C -- -O 
throughput,local_cpu_util,local_sd,local_cpu_peak_util,local_cpu_peak_id,remote_cpu_util,remote_sd,remote_cpu_peak_util,remote_cpu_peak_id; 
HDR="-P 0"; done
MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
192.168.0.21 () port 0 AF_INET : demo
Throughput Local Local   Local   Local   Remote Remote  Remote  Remote
            CPU   Service Peak    Peak    CPU    Service Peak    Peak
            Util  Demand  Per CPU Per CPU Util   Demand  Per CPU Per CPU
            %             Util %  ID      %              Util %  ID
8365.16    1.93  0.604   61.64   0       4.57   1.431   99.97   0
8724.08    2.01  0.604   64.31   0       4.66   1.401   100.00  0
8653.70    1.98  0.600   63.37   0       4.67   1.414   99.90   0
8748.05    1.99  0.596   63.62   0       4.62   1.383   99.97   0
8756.66    1.99  0.595   63.55   0       4.52   1.354   99.97   0

If I switch the interrupts to a core on the other socket, throughput 
drops to 7.5 Gbit/s or so either way.

I'm still trying to get onto the consoles to check power management 
settings. Intel(R) Xeon(R) CPU E5-2670 0 @ 2.60GHz are the processors in 
use.

happy benchmarking,

rick

PS  FWIW, if I shift from using just the linux native vxlan to a "mostly 
full" set of OpenStack compute node plumbing - two OVS bridges and a 
linux bridge and associated plumbing with a vxlan tunnel defined in OVS, 
but nothing above the Linux bridge (and no VMs) I see more like 4.9 
Gbit/s.  The veth pair connecting the linux bridge to the top ovs bridge 
show rx checksum and gro enabled.  the linux bridge itself shows GRO but 
rx checksum off (fixed).  I'm not sure how to go about checking the OVS 
constructs.

root@qu-stbaz1-perf0000:/home/raj# cat raj_full_stack.sh
ovs-vsctl add-br br-tun
ovs-vsctl add-port br-tun vxlan0 -- set interface vxlan0 type=vxlan 
options:remote_ip=$1 options:key=99 options:dst_port=4789
ovs-vsctl add-port br-tun patch-tun -- set interface patch-tun 
type=patch options:peer=patch-int

ovs-vsctl add-br br-int
ovs-vsctl add-port br-int patch-int -- set interface patch-int 
type=patch options:peer=patch-tun

brctl addbr qbr
ip link add dev qvb type veth peer name qvo
brctl addif qbr qvb

ovs-vsctl add-port br-int qvo

ifconfig qbr $2
ifconfig qbr mtu 1450
ifconfig qvb up
ifconfig qvo up
