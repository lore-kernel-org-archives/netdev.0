From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Performance regression with netns+linux-bridge+veth since Linux
 4.0
Date: Fri, 16 Oct 2015 08:55:38 -0700
Message-ID: <1445010938.25595.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5620B1F7.5020401@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lucas Nussbaum <lucas.nussbaum@loria.fr>,
	Emmanuel Jeanvoine <emmanuel.jeanvoine@inria.fr>
To: Cristian RUIZ <cristian.ruiz@inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34603 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbbJPPzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 11:55:40 -0400
Received: by pacez2 with SMTP id ez2so8326102pac.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 08:55:40 -0700 (PDT)
In-Reply-To: <5620B1F7.5020401@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-10-16 at 10:14 +0200, Cristian RUIZ wrote:
> Hello,
> 
> When evaluating the performance degradation of running HPC applications 
> inside network namespaces
> I found that all Linux kernel versions since 4.0 introduce a high 
> overhead for some applications.
> I compare the execution time of a benchmark (details below) both in a 
> "native" execution (without netns), with the execution inside netns.
> For Linux 3.16, the overhead measured is 42%. For Linux 3.19, it is 8%.
> For Linux 4.0 and later, the overhead measured jumps to 300%.
> Using git bisect, I tracked this down to commit 9949afa4 ("tcp: fix 
> tcp_cong_avoid_ai() credit accumulation bug with decreases in w").
> Reverting commit 9949afa4 on top of Linux 4.2 restores the correct 
> (Linux 3.19) behavior.
> However, I don't understand why commit 9949afa4 causes such issues. Any 
> ideas?
> 
> The network setup I used is the following:
> 
>          M1                               M2
> ------------------------        -------------------------
> |                       |       |                       |
> |  ---------            |       |            ---------  |
> |  | veth0 | <-> veth1  |       |  veth1 <-> | veth0 |  |   ...
> |  ---------      |     |       |    |       ---------  |
> |    netns       br0    |       |   br0        netns    |
> |                 |     |       |    |                  |
> -----------------eth0---        ----eth0-----------------
>                    |                  |
>                    |                  |
>                    ====== switch ======
> 
> Which was created using the following commands:
> brctl addbr br0
> ip addr add dev br0 192.168.60.101/24 # <- machine ip address
> ip link set dev br0 up
> brctl addif br0 eth1
> ifconfig eth1 0.0.0.0 up
> ip link add name veth1 type veth peer name veth0
> ip link set veth1 up
> brctl addif br0 veth1
> ip netns add vnode
> ip link set dev int0 netns vnode
> ip netns exec vnode ip addr add 10.144.0.3/24 dev int0 # I used a 
> different network to communicate among network namespaces.
> ip netns exec vnode ip link set dev veth0 up
> ifconfig br0:1 10.144.0.252/24 # I assigned an IP address to the bridge
> inside the network attributed to the network namespaces.
> 
> All machines used in my experiments have this configuration.
> The performance issue appears when I run a parallel application inside 
> network namespaces
> over 8 physical machines using the configuration mentioned above.
> The parallel applications used during the tests belong to the NAS 
> benchmarks[1]
> and the most affected application is CG class B.
> The application runs 16 CPU intensive processes per machine (1 process 
> per core)
> that exchange around 1 GByte of data per execution. (The mapping of 
> processes per physical machines is the same for both native and netns 
> executions, of course.)
> Below, the output of some network counters inside netns using the 
> command 'netstat -s':
> 
>      98 resets received for embryonic SYN_RECV sockets
>      2344 TCP sockets finished time wait in fast timer
>      986 delayed acks sent
>      2 delayed acks further delayed because of locked socket
>      Quick ack mode was activated 34279 times
>      75 packets directly queued to recvmsg prequeue.
>      2313551 packet headers predicted
>      781506 acknowledgments not containing data payload received
>      1739746 predicted acknowledgments
>      22228 times recovered from packet loss by selective acknowledgements
>      Detected reordering 130 times using FACK
>      Detected reordering 498 times using SACK
>      Detected reordering 68 times using time stamp
>      2157 congestion windows fully recovered without slow start
>      1465 congestion windows partially recovered using Hoe heuristic
>      2273 congestion windows recovered without slow start by DSACK
>      140 congestion windows recovered without slow start after partial ack
>      59007 fast retransmits
>      53276 forward retransmits
>      140 other TCP timeouts
>      TCPLossProbes: 140
> 
> Things to remark here is the high number of congestion windows 
> recoveries and the number of TCP timeouts.
> For an execution with Linux kernel 3.19 the number of congestion windows 
> is 3 times lower and there are few TCP timeouts (around 3) than on 4.0. 
> All this is reflected into the maximum network speed achieved by the 
> application, 239MB/s (4.0) against 552MB/s (3.19).
> 
> More details about the configuration used
> =========================================
> 
> Hardware used
> -------------
> All machines are equipped with two CPUs 8 cores each, I attached the 
> output of '/proc/cpuinfo'.
> 
> Memory: 128 GB
> Network: 10 Gigabit Ethernet (eth0)
> Driver: ixgbe
> Storage:     2*600GB HDD / SAS
> Driver: ahci
> 
> User-space software
> --------------------
> Debian jessie, OpenMPI version 1.8.5[2], NAS benchmark version 3.3
> 
> Linux kernel
> ------------
> The .config files used are attached in this mail.
> 
> [1] https://www.nas.nasa.gov/publications/npb.html
> [2] http://www.open-mpi.org/software/ompi/v1.8/

Hi Christian.

Thanks for the nice report.

Try to find out where frames are dropped.

Apparently some buffers were tuned in the past, and this tuning no
longer is correct.

For example you could try the following while tcp flow is active.

perf record -a -g -e skb:kfree_skb sleep 10
perf report --stdio

I suspect a TSO/GRO issue maybe with large packets.
