From: Dipankar Sarma <dipankar@in.ibm.com>
Subject: route cache DoS testing and softirqs
Date: Tue, 30 Mar 2004 00:15:50 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329184550.GA4540@in.ibm.com>
Reply-To: dipankar@in.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Andrea Arcangeli <andrea@suse.de>,
        "Paul E. McKenney" <paulmck@us.ibm.com>,
        Dave Miller <davem@redhat.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson noticed dst cache overflows while doing DoS stress testing in a
2.6 based router setup a few months and davem, alexey, robert and I
have been discussing this privately since then (198 mails, no less!!).
Recently, I set up an environment to test Robert's problem and have 
been characterizing it. My setup is -
                                                                                
pktgen box --- in router out --
eth0           eth0 <-> dumm0
                                                                                
10.0.0.1       10.0.0.2  5.0.0.1
                                                                                
The router box is a 2-way P4 xeon 2.4 GHz with 256MB memory. I use
Robert's pktgen script -
                                                                                
CLONE_SKB="clone_skb 1"
PKT_SIZE="pkt_size 60"
#COUNT="count 0"
COUNT="count 10000000"
IPG="ipg 0"
                                                                                
PGDEV=/proc/net/pktgen/eth0
echo "Configuring $PGDEV"
pgset "$COUNT"
pgset "$CLONE_SKB"
pgset "$PKT_SIZE"
pgset "$IPG"
pgset "flag IPDST_RND"
pgset "dst_min 5.0.0.0"
pgset "dst_max 5.255.255.255"
pgset "flows 32768"
pgset "flowlen 10"
                                                                                
With this, wthin a few seconds of starting pktgen, I get dst cache
overflow messages. I use the following instrumentation patch
to look at what's happening -
                                                                                
http://lse.sourceforge.net/locking/rcu/rtcache/pktgen/patches/15-rcu-debug.patch                                                                                
I tried both vanilla 2.6.0 and 2.6.0 + throttle-rcu patch which limits
RCU to 4 updates per RCU tasklet. The results are here -

http://lse.sourceforge.net/locking/rcu/rtcache/pktgen/gracedata/cpu-grace.png

This graph shows the maximum grace period during ~4ms time buckets on x-axis.

Couple of things are clear from this -

1. RCU grace periods of upto 300ms are seen. 300ms + 100Kpps packet
   amounts to about 30000 pending dst entries which result in route cache
   overflow.

2. throttle-rcu is only marginally better (10% less worst case grace period).

So, what causes RCU to stall for 300ms odd time ? I did some measurements
using the following patch -

http://lse.sourceforge.net/locking/rcu/rtcache/pktgen/patches/25-softirq-debug.patch

It applies on top of the 15-rcu-debug patch. This counts the number of
softirqs (in effect and approximation) during ~4ms time buckets. The
result is here -

http://lse.sourceforge.net/locking/rcu/rtcache/pktgen/softirq/cpu-softirq.png

The rcu grace period spikes are always accompanied by softirq frequency
spikes. So, this indicates that it is the large number of quick-running
softirqs that cause userland starvation which in turn result in RCU
delays. This raises a fundamental question - should we work around
this by providing a quiescent point at the end of every softirq handler
(giving softirqs its own RCU mechanism) or should we address a wider
problem, the system getting overwhelmed by heavy softirq load, and
try to implement a real softirq throttling mechanism that balances
cpu use. 

Robert demonstrated to us sometime ago with a small
timestamping user program to show that it can get starved for
more than 6 seconds in his system. So userland starvation is an
issue.

Thanks
Dipankar
