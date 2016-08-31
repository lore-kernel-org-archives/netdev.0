From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Wed, 31 Aug 2016 23:51:16 +0200
Message-ID: <20160831235116.33b1946b@redhat.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
        <20160831100854.23dad2d8@redhat.com>
        <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472650688.32433.115.camel@redhat.com>
        <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831164216.2901190c@redhat.com>
        <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
        <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160831214043.2f44cf08@redhat.com>
        <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Aug 2016 13:42:30 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2016-08-31 at 21:40 +0200, Jesper Dangaard Brouer wrote:
> 
> > I can confirm the improvement of approx 900Kpps (no wonder people have
> > been complaining about DoS against UDP/DNS servers).
> > 
> > BUT during my extensive testing, of this patch, I also think that we
> > have not gotten to the bottom of this.  I was expecting to see a higher
> > (collective) PPS number as I add more UDP servers, but I don't.
> > 
> > Running many UDP netperf's with command:
> >  super_netperf 4 -H 198.18.50.3 -l 120 -t UDP_STREAM -T 0,0 -- -m 1472 -n -N  
> 
> Are you sure sender can send fast enough ?

Yes, as I can see drops (overrun UDP limit UdpRcvbufErrors). Switching
to pktgen and udp_sink to be sure.

> > 
> > With 'top' I can see ksoftirq are still getting a higher %CPU time:
> > 
> >     PID   %CPU     TIME+  COMMAND
> >      3   36.5   2:28.98  ksoftirqd/0
> >  10724    9.6   0:01.05  netserver
> >  10722    9.3   0:01.05  netserver
> >  10723    9.3   0:01.05  netserver
> >  10725    9.3   0:01.05  netserver  
> 
> Looks much better on my machine, with "udprcv -n 4" (using 4 threads,
> and 4 sockets using SO_REUSEPORT)
> 
> 10755 root      20   0   34948      4      0 S  79.7  0.0   0:33.66 udprcv 
>     3 root      20   0       0      0      0 R  19.9  0.0   0:25.49 ksoftirqd/0                 
> 
> Pressing 'H' in top gives :
> 
>     3 root      20   0       0      0      0 R 19.9  0.0   0:47.84 ksoftirqd/0
> 10756 root      20   0   34948      4      0 R 19.9  0.0   0:30.76 udprcv 
> 10757 root      20   0   34948      4      0 R 19.9  0.0   0:30.76 udprcv 
> 10758 root      20   0   34948      4      0 S 19.9  0.0   0:30.76 udprcv
> 10759 root      20   0   34948      4      0 S 19.9  0.0   0:30.76 udprcv

Yes, I'm seeing the same when unning 5 instances my own udp_sink[1]:
 sudo taskset -c 0 ./udp_sink --port 10003 --recvmsg --reuse-port --count $((10**10))

 PID  S  %CPU     TIME+  COMMAND
    3 R  21.6   2:21.33  ksoftirqd/0
 3838 R  15.9   0:02.18  udp_sink
 3856 R  15.6   0:02.16  udp_sink
 3862 R  15.6   0:02.16  udp_sink
 3844 R  15.3   0:02.15  udp_sink
 3850 S  15.3   0:02.15  udp_sink

This is the expected result, that adding more userspace receivers
scales up.  I needed 5 udp_sink's before I don't see any drops, either
this says the job performed by ksoftirqd is 5 times faster or the
collective queue size of the programs was fast enough to absorb the
scheduling jitter.

The result from this run were handling 1,517,248 pps, without any
drops, all processes pinned to the same CPU.

 $ nstat > /dev/null && sleep 1 && nstat
 #kernel
 IpInReceives                    1517225            0.0
 IpInDelivers                    1517224            0.0
 UdpInDatagrams                  1517248            0.0
 IpExtInOctets                   69793408           0.0
 IpExtInNoECTPkts                1517246            0.0

I'm acking this patch:

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

> 
> Patch was on top of commit 071e31e254e0e0c438eecba3dba1d6e2d0da36c2

Mine on top of commit 84fd1b191a9468

> > 
> >   
> > > Since the load runs in well identified threads context, an admin can
> > > more easily tune process scheduling parameters if needed.  
> > 
> > With this patch applied, I found that changing the UDP server process,
> > scheduler policy to SCHED_RR or SCHED_FIFO gave me a performance boost
> > from 900Kpps to 1.7Mpps, and not a single UDP packet dropped (even with
> > a single UDP stream, also tested with more)
> > 
> > Command used:
> >  sudo chrt --rr -p 20 $(pgrep netserver)  
> 
> 
> Sure, this is what I mentioned in my changelog : Once we properly
> schedule and rely on ksoftirqd, tuning is available.
> 
> > 
> > The scheduling picture also change a lot:
> > 
> >    PID  %CPU   TIME+   COMMAND
> >  10783  24.3  0:21.53  netserver
> >  10784  24.3  0:21.53  netserver
> >  10785  24.3  0:21.52  netserver
> >  10786  24.3  0:21.50  netserver
> >      3   2.7  3:12.18  ksoftirqd/0
> > 


[1] https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
