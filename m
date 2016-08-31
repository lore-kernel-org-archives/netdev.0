From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Wed, 31 Aug 2016 13:42:30 -0700
Message-ID: <1472676150.14381.363.camel@edumazet-glaptop3.roam.corp.google.com>
References: <4f1c4b38528762619fff1fa963de8971006c1234.1472460085.git.pabeni@redhat.com>
         <20160831100854.23dad2d8@redhat.com>
         <1472650472.14381.317.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472650688.32433.115.camel@redhat.com>
         <1472652643.14381.320.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831164216.2901190c@redhat.com>
         <1472661956.14381.335.camel@edumazet-glaptop3.roam.corp.google.com>
         <1472665349.14381.356.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160831214043.2f44cf08@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160831214043.2f44cf08@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-31 at 21:40 +0200, Jesper Dangaard Brouer wrote:

> I can confirm the improvement of approx 900Kpps (no wonder people have
> been complaining about DoS against UDP/DNS servers).
> 
> BUT during my extensive testing, of this patch, I also think that we
> have not gotten to the bottom of this.  I was expecting to see a higher
> (collective) PPS number as I add more UDP servers, but I don't.
> 
> Running many UDP netperf's with command:
>  super_netperf 4 -H 198.18.50.3 -l 120 -t UDP_STREAM -T 0,0 -- -m 1472 -n -N

Are you sure sender can send fast enough ?

> 
> With 'top' I can see ksoftirq are still getting a higher %CPU time:
> 
>     PID   %CPU     TIME+  COMMAND
>      3   36.5   2:28.98  ksoftirqd/0
>  10724    9.6   0:01.05  netserver
>  10722    9.3   0:01.05  netserver
>  10723    9.3   0:01.05  netserver
>  10725    9.3   0:01.05  netserver

Looks much better on my machine, with "udprcv -n 4" (using 4 threads,
and 4 sockets using SO_REUSEPORT)

10755 root      20   0   34948      4      0 S  79.7  0.0   0:33.66 udprcv                                                                                                                                 
    3 root      20   0       0      0      0 R  19.9  0.0   0:25.49 ksoftirqd/0                 

Pressing 'H' in top gives :

    3 root      20   0       0      0      0 R 19.9  0.0   0:47.84 ksoftirqd/0                                                                                                                             
10756 root      20   0   34948      4      0 R 19.9  0.0   0:30.76 udprcv                                                                                                                                  
10757 root      20   0   34948      4      0 R 19.9  0.0   0:30.76 udprcv                                                                                                                                  
10758 root      20   0   34948      4      0 S 19.9  0.0   0:30.76 udprcv                                                                                                                                  
10759 root      20   0   34948      4      0 S 19.9  0.0   0:30.76 udprcv


Patch was on top of commit 071e31e254e0e0c438eecba3dba1d6e2d0da36c2
                          
> 
> 
> > Since the load runs in well identified threads context, an admin can
> > more easily tune process scheduling parameters if needed.
> 
> With this patch applied, I found that changing the UDP server process,
> scheduler policy to SCHED_RR or SCHED_FIFO gave me a performance boost
> from 900Kpps to 1.7Mpps, and not a single UDP packet dropped (even with
> a single UDP stream, also tested with more)
> 
> Command used:
>  sudo chrt --rr -p 20 $(pgrep netserver)


Sure, this is what I mentioned in my changelog : Once we properly
schedule and rely on ksoftirqd, tuning is available.

> 
> The scheduling picture also change a lot:
> 
>    PID  %CPU   TIME+   COMMAND
>  10783  24.3  0:21.53  netserver
>  10784  24.3  0:21.53  netserver
>  10785  24.3  0:21.52  netserver
>  10786  24.3  0:21.50  netserver
>      3   2.7  3:12.18  ksoftirqd/0
> 
>  
