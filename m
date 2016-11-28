From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 0/5] net: add protocol level recvmmsg support
Date: Mon, 28 Nov 2016 13:21:41 +0100
Message-ID: <20161128132141.217aef39@redhat.com>
References: <cover.1480086321.git.pabeni@redhat.com>
        <20161125183711.675fa4a7@redhat.com>
        <1480330358.6718.13.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>, brouer@redhat.com
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754872AbcK1MVq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 07:21:46 -0500
In-Reply-To: <1480330358.6718.13.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Nov 2016 11:52:38 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> Hi Jesper,
> 
> On Fri, 2016-11-25 at 18:37 +0100, Jesper Dangaard Brouer wrote:
> > > The measured performance delta is as follow:
> > > 
> > > 		before		after
> > > 		(Kpps)		(Kpps)
> > > 
> > > udp flood[1]	570		1800(+215%)
> > > max tput[2]	1850		3500(+89%)
> > > single queue[3]	1850		1630(-11%)
> > > 
> > > [1] line rate flood using multiple 64 bytes packets and multiple flows  
> > 
> > Is [1] sending multiple flow in the a single UDP-sink?  
> 
> Yes, in the test scenario [1] there are multiple UDP flows using 16
> different rx queues on the receiver host, and a single user space
> reader.
> 
> > > [2] like [1], but using the minimum number of flows to saturate the user space
> > >  sink, that is 1 flow for the old kernel and 3 for the patched one.
> > >  the tput increases since the contention on the rx lock is low.
> > > [3] like [1] but using a single flow with both old and new kernel. All the
> > >  packets land on the same rx queue and there is a single ksoftirqd instance
> > >  running  
> > 
> > It is important to know, if ksoftirqd and the UDP-sink runs on the same CPU?  
> 
> No pinning is enforced. The scheduler moves the user space process on a
> different cpu in respect to the ksoftriqd kernel thread.

This floating userspace process can cause a high variation between test
runs.  On my system, the performance drops to approx 600Kpps when
ksoftirqd and udp_sink share the same CPU.

Quick run with your patches applied:

Sender: pktgen with big packets
 ./pktgen_sample03_burst_single_flow.sh -i mlx5p2 -d 198.18.50.1 \
   -m 7c:fe:90:c7:b1:cf -t1 -b128 -s 1472

Forced CPU0 for both ksoftirq and udp_sink

# taskset -c 0 ./udp_sink --count $((10**7)) --port 9 --repeat 1
                                ns      pps             cycles 
recvMmsg/32  	run: 0 10000000	1667.93	599547.16	6685
recvmsg   	run: 0 10000000	1810.70	552273.39	7257
read      	run: 0 10000000	1634.72	611723.95	6552
recvfrom  	run: 0 10000000	1585.06	630891.39	6353

 
> > > The regression in the single queue scenario is actually due to the improved
> > > performance of the recvmmsg() syscall: the user space process is now
> > > significantly faster than the ksoftirqd process so that the latter needs often
> > > to wake up the user space process.  
> > 
> > When measuring these things, make sure that we/you measure both the packets
> > actually received in the userspace UDP-sink, and also measure packets
> > RX processed by ksoftirq (and I often also look at what HW got delivered).
> > Some times, when userspace is too slow, the kernel can/will drop packets.
> > 
> > It is actually quite easily verified with cmdline:
> > 
> >  nstat > /dev/null && sleep 1  && nstat
> > 
> > For HW measurements I use the tool ethtool_stats.pl:
> >  https://github.com/netoptimizer/network-testing/blob/master/bin/ethtool_stats.pl  
> 
> We collected the UDP stats for all the three scenarios; we have lot of
> drop in test[1] and little, by design, in test[2]. In test [3], with the
> patched kernel, the drops are 0: ksoftirqd is way slower than the user
> space sink. 
> 
> > > Since ksoftirqd is the bottle-neck is such scenario, overall this causes a
> > > tput reduction. In a real use case, where the udp sink is performing some
> > > actual processing of the received data, such regression is unlikely to really
> > > have an effect.  
> > 
> > My experience is that the performance of RX UDP is affected by:
> >  * if socket is connected or not (yes, RX side also)
> >  * state of /proc/sys/net/ipv4/ip_early_demux
> > 
> > You don't need to run with all the combinations, but it would be nice
> > if you specify what config your have based your measurements on (and
> > keep them stable in your runs).
> > 
> > I've actually implemented the "--connect" option to my udp_sink
> > program[1] today, but I've not pushed it yet, if you are interested.  
> 
> The reported numbers are all gathered with unconnected sockets and early
> demux enabled.
> 
> We also used connected socket for test[3], with relative little
> difference (the tput increased for both unpatched and patched kernel, 
> and the difference was roughly the same).

When I use connected sockets (RX side) and ip_early_demux enabled, I do
see a performance boost for recvmmsg.  With these patches applied,
forced ksoftirqd on CPU0 and udp_sink on CPU2, pktgen single flow
sending size 1472 bytes.

$ sysctl net/ipv4/ip_early_demux
net.ipv4.ip_early_demux = 1

$ grep -H . /proc/sys/net/core/{r,w}mem_max
/proc/sys/net/core/rmem_max:1048576
/proc/sys/net/core/wmem_max:1048576

# taskset -c 2 ./udp_sink --count $((10**7)) --port 9 --repeat 1
#                               ns      pps             cycles
recvMmsg/32  	run: 0 10000000	462.51	2162095.23	1853
recvmsg   	run: 0 10000000	536.47	1864041.75	2150
read      	run: 0 10000000	492.01	2032460.71	1972
recvfrom  	run: 0 10000000	553.94	1805262.84	2220

# taskset -c 2 ./udp_sink --count $((10**7)) --port 9 --repeat 1 --connect
#                               ns      pps             cycles
recvMmsg/32  	run: 0 10000000	405.15	2468225.03	1623
recvmsg   	run: 0 10000000	548.23	1824049.58	2197
read      	run: 0 10000000	489.76	2041825.27	1962
recvfrom  	run: 0 10000000	466.18	2145091.77	1868

My theory is that by enabling connect'ed RX socket, the ksoftirqd gets
faster (no fib_lookup) and is no-longer a bottleneck.  This is
confirmed by the nstat output below.

Below: unconnected
 $ nstat > /dev/null && sleep 1  && nstat
 #kernel
 IpInReceives                    2143944            0.0
 IpInDelivers                    2143945            0.0
 UdpInDatagrams                  2143944            0.0
 IpExtInOctets                   3125889306         0.0
 IpExtInNoECTPkts                2143956            0.0

Below: connected
 $ nstat > /dev/null && sleep 1  && nstat
 #kernel
 IpInReceives                    2925155            0.0
 IpInDelivers                    2925156            0.0
 UdpInDatagrams                  2440925            0.0
 UdpInErrors                     484230             0.0
 UdpRcvbufErrors                 484230             0.0
 IpExtInOctets                   4264896402         0.0
 IpExtInNoECTPkts                2925170            0.0

This is a 50Gbit/s link, and IpInReceives correspondent to approx 35Gbit/s.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
