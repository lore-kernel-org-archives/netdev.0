From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] softirq: let ksoftirqd do its job
Date: Thu, 1 Sep 2016 12:38:49 +0200
Message-ID: <20160901123849.2c9aa5e1@redhat.com>
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
        <20160831235116.33b1946b@redhat.com>
        <1472682450.14381.364.camel@edumazet-glaptop3.roam.corp.google.com>
        <3567b503-8b3e-5a3f-580a-f99fd28cf77e@hpe.com>
        <1472685066.14381.380.camel@edumazet-glaptop3.roam.corp.google.com>
        <f131776f-7f53-c539-f283-10d6db0b6d57@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Eric Dumazet <eric.dumazet@gmail.com>,
        Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>,
        Rik van Riel <riel@redhat.com>,
        Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@redhat.com>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>, Jonathan Corbet <corbet@lwn.net>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <f131776f-7f53-c539-f283-10d6db0b6d57@hpe.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 31 Aug 2016 16:29:56 -0700 Rick Jones <rick.jones2@hpe.com> wrote:
> On 08/31/2016 04:11 PM, Eric Dumazet wrote:
> > On Wed, 2016-08-31 at 15:47 -0700, Rick Jones wrote:  
> >> With regard to drops, are both of you sure you're using the same socket
> >> buffer sizes?  
> >
> > Does it really matter ?  
> 
> At least at points in the past I have seen different drop counts at the 
> SO_RCVBUF based on using (sometimes much) larger sizes.  The hypothesis 
> I was operating under at the time was that this dealt with those 
> situations where the netserver was held-off from running for "a little 
> while" from time to time.  It didn't change things for a sustained 
> overload situation though.

Yes, Rick, your hypothesis corresponds to my measurements.  The
userspace program is held-off from running for "a little while" from
time to time.  I've measured this with perf sched record/latency.  It
is sort of a natural scheduler characteristic.
 The userspace UDP socket program consume/need more cycles to perform
its jobs, than kernel softirqd. Thus the UDP-prog use up its sched
time-slice, and periodically ksoftirq get schedule multiple times,
because UDP-prog don't have any credits any-longer.

WARNING: Do not increase socket queue size to pamper over this issue,
it is the WRONG solution, it will give horrible latency issues.

With above warning, I can tell your, yes you are also right about
increasing the socket buffer size, can be used to mitigate/hide the
packet drops.  You can even increase the socket size so much, that the
drop problem "goes-away".  The queue simply need to be deep enough to
absorb the worst/maximum time UDP-prog was scheduled out.  The hidden
effect to make this work (to not contradict queue theory) is that this
also slows-down/cost-more-cycles for ksoftirqd/NAPI as it cost more to
enqueue (instead of dropping packets on a full queue).

You can measure the sched "Maximum delay" using:
 sudo perf sched record -C 0 sleep 10
 sudo perf sched latency

On my setup I measured "Maximum delay" of approx 9 ms.  Given I can
see an incoming packet rate of 2.4Mpps (880Kpps reach UDP-prog), and
knowing network stack use skb->truesize (approx 2048 bytes on this
driver), I can calculate that I need approx 45MBytes buffer
((2.4*10^6)*(9/1000)*2048 = 44.2Mb)

The PPS measurement comes from:

 $ nstat > /dev/null && sleep 1 && nstat
 #kernel
 IpInReceives                    2335926            0.0
 IpInDelivers                    2335925            0.0
 UdpInDatagrams                  880086             0.0
 UdpInErrors                     1455850            0.0
 UdpRcvbufErrors                 1455850            0.0
 IpExtInOctets                   107453056          0.0

Changing queue size to 50MBytes :
 sysctl -w net/core/rmem_max=$((50*1024*1024)) ;\
 sysctl -w net.core.rmem_default=$((50*1024*1024))

New result looks "nice", with no drops, and 1.42Mpps delivered to
UDP-prog, but in reality it is not nice for latency...

 $ nstat > /dev/null && sleep 1 && nstat
 #kernel
 IpInReceives                    1425013            0.0
 IpInDelivers                    1425017            0.0
 UdpInDatagrams                  1432139            0.0
 IpExtInOctets                   65539328           0.0
 IpExtInNoECTPkts                1424771            0.0

Tracking of queue size, max, min and average::

 while (true); do netstat -uan | grep '0.0.0.0:9'; sleep 0.3; done |
  awk 'BEGIN {max=0;min=0xffffffff;sum=0;n=0} \
   {if ($2 > max) max=$2;
    if ($2 < min) min=$2;
    n++; sum+=$2;
    printf "%s Recv-Q: %d max: %d min: %d ave: %.3f\n",$1,$2,max,min,sum/n;}';
 Result:
  udp Recv-Q: 23624832 max: 47058176 min: 4352 ave: 25092687.698

I see max queue of 47MBytes, and worse an average standing queue of
25Mbytes, which is really bad for the latency seen by the
application. And having this much outstanding memory is also bad for
CPU cache size effects, and stressing the memory allocator.
 I'm actually using this huge queue "misconfig" to stress the page
allocator and my page_pool implementation into worse case situations ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
