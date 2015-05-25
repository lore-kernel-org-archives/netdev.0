From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: TCP window auto-tuning sub-optimal in GRE tunnel
Date: Mon, 25 May 2015 14:49:26 -0400
Message-ID: <1432579766.32671.66.camel@jasiiieee.pacifera.com>
References: <1432568524.32671.29.camel@jasiiieee.pacifera.com>
	 <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.196]:57170 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbbEYStb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2015 14:49:31 -0400
In-Reply-To: <1432573139.4060.167.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 09:58 -0700, Eric Dumazet wrote:
> On Mon, 2015-05-25 at 11:42 -0400, John A. Sullivan III wrote:
> > Hello, all.  I hope this is the correct list for this question.  We are
> > having serious problems on high BDP networks using GRE tunnels.  Our
> > traces show it to be a TCP Window problem.  When we test without GRE,
> > throughput is wire speed and traces show the window size to be 16MB
> > which is what we configured for r/wmem_max and tcp_r/wmem.  When we
> > switch to GRE, we see over a 90% drop in throughput and the TCP window
> > size seems to peak at around 500K.
> > 
> > What causes this and how can we get the GRE tunnels to use the max
> > window size? Thanks - John
> 
> Hi John
> 
> Is it for a single flow or multiple ones ? Which kernel versions on
> sender and receiver ? What is the nominal speed of non GRE traffic ?
> 
> What is the brand/model of receiving NIC  ? Is GRO enabled ?
> 
> It is possible receiver window is impacted because of GRE encapsulation
> making skb->len/skb->truesize ratio a bit smaller, but not by 90%.
> 
> I suspect some more trivial issues, like receiver overwhelmed by the
> extra load of GRE encapsulation.
> 
> 1) Non GRE session
> 
> lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H lpaa24 -Cc -t OMNI
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to lpaa24.prod.google.com () port 0 AF_INET
> tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
> tcpi_rtt 70 tcpi_rttvar 7 tcpi_snd_ssthresh 221 tpci_snd_cwnd 258
> tcpi_reordering 3 tcpi_total_retrans 711
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
> Final       Final                                             %     Method %      Method                          
> 1912320     6291456     16384  10.00   22386.89   10^6bits/s  1.20  S      2.60   S      0.211   0.456   usec/KB  
> 
> 2) GRE session
> 
> lpaa23:~# DUMP_TCP_INFO=1 ./netperf -H 7.7.7.24 -Cc -t OMNI
> OMNI Send TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 7.7.7.24 () port 0 AF_INET
> tcpi_rto 201000 tcpi_ato 0 tcpi_pmtu 1500 tcpi_rcv_ssthresh 29200
> tcpi_rtt 76 tcpi_rttvar 7 tcpi_snd_ssthresh 176 tpci_snd_cwnd 249
> tcpi_reordering 3 tcpi_total_retrans 819
> Local       Remote      Local  Elapsed Throughput Throughput  Local Local  Remote Remote Local   Remote  Service  
> Send Socket Recv Socket Send   Time               Units       CPU   CPU    CPU    CPU    Service Service Demand   
> Size        Size        Size   (sec)                          Util  Util   Util   Util   Demand  Demand  Units    
> Final       Final                                             %     Method %      Method                          
> 1815552     6291456     16384  10.00   22420.88   10^6bits/s  1.01  S      3.44   S      0.177   0.603   usec/KB  
> 
> 

Thanks, Eric. It really looks like a windowing issue but here is the
relevant information:
We are measuring single flows.  One side is an Intel GbE NIC connected
to a 1 Gbps CIR Internet connection. The other side is an Intel 10 GbE
NIC connected to a 40 Gbps Internet connection.  RTT is ~=80ms

The numbers I will post below are from a duplicated setup in our test
lab where the systems are connected by GbE links with a netem router in
the middle to introduce the latency.  We are not varying the latency to
ensure we eliminate packet re-ordering from the mix.

We are measuring a single flow.  Here are the non-GRE numbers:
root@gwhq-1:~# nuttcp -T 60 -i 10 192.168.224.2
  666.3125 MB /  10.00 sec =  558.9370 Mbps     0 retrans
 1122.2500 MB /  10.00 sec =  941.4151 Mbps     0 retrans
  720.8750 MB /  10.00 sec =  604.7129 Mbps     0 retrans
 1122.3125 MB /  10.00 sec =  941.4622 Mbps     0 retrans
 1122.2500 MB /  10.00 sec =  941.4101 Mbps     0 retrans
 1122.3125 MB /  10.00 sec =  941.4668 Mbps     0 retrans

 5888.5000 MB /  60.19 sec =  820.6857 Mbps 4 %TX 13 %RX 0 retrans 80.28 msRTT

For some reason, nuttcp does not show retransmissions in our environment
even when they do exist.

gro is active on the send side:
root@gwhq-1:~# ethtool -k eth0
Features for eth0:
rx-checksumming: on
tx-checksumming: on
        tx-checksum-ipv4: on
        tx-checksum-unneeded: off [fixed]
        tx-checksum-ip-generic: off [fixed]
        tx-checksum-ipv6: on
        tx-checksum-fcoe-crc: off [fixed]
        tx-checksum-sctp: on
scatter-gather: on
        tx-scatter-gather: on
        tx-scatter-gather-fraglist: off [fixed]
tcp-segmentation-offload: on
        tx-tcp-segmentation: on
        tx-tcp-ecn-segmentation: off [fixed]
        tx-tcp6-segmentation: on
udp-fragmentation-offload: off [fixed]
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off [fixed]
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off [fixed]
receive-hashing: on
highdma: on [fixed]
rx-vlan-filter: on [fixed]
vlan-challenged: off [fixed]
tx-lockless: off [fixed]
netns-local: off [fixed]
tx-gso-robust: off [fixed]
tx-fcoe-segmentation: off [fixed]
fcoe-mtu: off [fixed]
tx-nocache-copy: on
loopback: off [fixed]

and on the receive side:
root@testgwingest-1:~# ethtool -k eth5
Offload parameters for eth5:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on

The CPU is also lightly utilized.  These are fairly high powered
gateways.  We have measure 16 Gbps throughput on them with no strain at
all. Checking individual CPUs, we occasionally see one become about half
occupied with software interrupts.  

gro is also active on the intermediate netem Linux router.
lro is disabled.  I gather there is a bug in the ixgbe driver which can
cause this kind of problem if both gro and lro are enabled.

Here are the GRE numbers:
root@gwhq-1:~# nuttcp -T 60 -i 10 192.168.126.1
   21.4375 MB /  10.00 sec =   17.9830 Mbps     0 retrans
   23.2500 MB /  10.00 sec =   19.5035 Mbps     0 retrans
   23.3125 MB /  10.00 sec =   19.5559 Mbps     0 retrans
   23.3750 MB /  10.00 sec =   19.6084 Mbps     0 retrans
   23.2500 MB /  10.00 sec =   19.5035 Mbps     0 retrans
   23.3125 MB /  10.00 sec =   19.5560 Mbps     0 retrans

  138.0000 MB /  60.09 sec =   19.2650 Mbps 9 %TX 6 %RX 0 retrans 80.33 msRTT


Here is top output during GRE testing on the receive side (which is much
lower powered than the send side):

top - 14:37:29 up 200 days, 17:03,  1 user,  load average: 0.21, 0.22, 0.17
Tasks: 186 total,   1 running, 185 sleeping,   0 stopped,   0 zombie
Cpu0  :  0.0%us,  2.4%sy,  0.0%ni, 93.6%id,  0.0%wa,  0.0%hi,  4.0%si,  0.0%st
Cpu1  :  0.0%us,  0.1%sy,  0.0%ni, 99.9%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni, 99.9%id,  0.1%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu5  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu8  :  0.0%us,  0.1%sy,  0.0%ni, 99.9%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu9  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu10 :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu11 :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu12 :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu13 :  0.1%us,  0.0%sy,  0.0%ni, 99.9%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu14 :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu15 :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:  24681616k total,  1633712k used, 23047904k free,   175016k buffers
Swap: 25154556k total,        0k used, 25154556k free,  1084648k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
27014 nobody    20   0  6496  912  708 S    6  0.0   0:02.26 nuttcp
    4 root      20   0     0    0    0 S    0  0.0 101:53.42 kworker/0:0
   10 root      20   0     0    0    0 S    0  0.0   1020:04 rcu_sched
   99 root      20   0     0    0    0 S    0  0.0  11:00.02 kworker/1:1
  102 root      20   0     0    0    0 S    0  0.0  26:01.67 kworker/4:1
  113 root      20   0     0    0    0 S    0  0.0  24:46.28 kworker/15:1
18321 root      20   0  8564 4516  248 S    0  0.0  80:10.20 haveged
27016 root      20   0 17440 1396  984 R    0  0.0   0:00.03 top
    1 root      20   0 24336 2320 1348 S    0  0.0   0:01.39 init
    2 root      20   0     0    0    0 S    0  0.0   0:00.20 kthreadd
    3 root      20   0     0    0    0 S    0  0.0 217:16.78 ksoftirqd/0
    5 root       0 -20     0    0    0 S    0  0.0   0:00.00 kworker/0:0H

A second nuttcp test shows the same but this time we took a tcpdump of
the traffic:
root@gwhq-1:~# nuttcp -T 60 -i 10 192.168.126.1
   21.2500 MB /  10.00 sec =   17.8258 Mbps     0 retrans
   23.2500 MB /  10.00 sec =   19.5035 Mbps     0 retrans
   23.3750 MB /  10.00 sec =   19.6084 Mbps     0 retrans
   23.2500 MB /  10.00 sec =   19.5035 Mbps     0 retrans
   23.3125 MB /  10.00 sec =   19.5560 Mbps     0 retrans
   23.3750 MB /  10.00 sec =   19.6083 Mbps     0 retrans

  137.8125 MB /  60.07 sec =   19.2449 Mbps 8 %TX 6 %RX 0 retrans 80.31 msRTT

MSS is 1436
Window Scale is 10
Window size tops out at 545 = 558080
Hmm . . . I would think if I could send 558080 bytes every 0.080s, that
would be about 56 Mbps and not 19.5.
ip -s -s link ls shows no errors on either side.

I rebooted the receiving side to reset netstat error counters and reran
the test with the same results.  Nothing jumped out at me in netstat -s:

TcpExt:
    1 invalid SYN cookies received
    1 TCP sockets finished time wait in fast timer
    187 delayed acks sent
    2 delayed acks further delayed because of locked socket
    47592 packets directly queued to recvmsg prequeue.
    48473682 bytes directly in process context from backlog
    90710698 bytes directly received in process context from prequeue
    3085 packet headers predicted
    88907 packets header predicted and directly queued to user
    21 acknowledgments not containing data payload received
    201 predicted acknowledgments
    3 times receiver scheduled too late for direct processing
    TCPRcvCoalesce: 677

Why is my window size so small?
Here are the receive side settings:

# increase TCP max buffer size setable using setsockopt()
net.core.rmem_default = 268800
net.core.wmem_default = 262144
net.core.rmem_max = 33564160
net.core.wmem_max = 33554432
net.ipv4.tcp_rmem = 8960 89600 33564160
net.ipv4.tcp_wmem = 4096 65536 33554432
net.ipv4.tcp_mtu_probing=1

and here are the transmit side settings:
# increase TCP max buffer size setable using setsockopt()
  net.core.rmem_default = 268800
  net.core.wmem_default = 262144
  net.core.rmem_max = 33564160
  net.core.wmem_max = 33554432
  net.ipv4.tcp_rmem = 8960 89600 33564160
  net.ipv4.tcp_wmem = 4096 65536 33554432
  net.ipv4.tcp_mtu_probing=1
  net.core.netdev_max_backlog = 3000


Oh, kernel versions:
sender: root@gwhq-1:~# uname -a
Linux gwhq-1 3.2.0-4-amd64 #1 SMP Debian 3.2.65-1+deb7u1 x86_64 GNU/Linux

receiver:
root@testgwingest-1:/etc# uname -a
Linux testgwingest-1 3.8.0-38-generic #56~precise1-Ubuntu SMP Thu Mar 13 16:22:48 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux

Thanks - John
