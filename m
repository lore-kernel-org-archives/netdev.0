From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V3-evictor] net: frag evictor, avoid killing
 warm frag queues
Date: Tue, 04 Dec 2012 18:51:37 +0100
Message-ID: <1354643497.20888.178.camel@localhost>
References: <1354319937.20109.285.camel@edumazet-glaptop>
	 <20121204133007.20215.52566.stgit@dragon>
	 <1354632447.1388.150.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52680 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751913Ab2LDRwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 12:52:31 -0500
In-Reply-To: <1354632447.1388.150.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-04 at 06:47 -0800, Eric Dumazet wrote:
> On Tue, 2012-12-04 at 14:30 +0100, Jesper Dangaard Brouer wrote:
> > The fragmentation evictor system have a very unfortunate eviction
> > system for killing fragment, when the system is put under pressure.
> > 
> > If packets are coming in too fast, the evictor code kills "warm"
> > fragments too quickly.  Resulting in close to zero throughput, as
> > fragments are killed before they have a chance to complete
> > 
> > This is related to the bad interaction with the LRU (Least Recently
> > Used) list.  Under load the LRU list sort-of changes meaning/behavior.
> > When the LRU head is very new/warm, then the head is most likely the
> > one with most fragments and the tail (latest used or added element)
> > with least.
> > 
> > Solved by, introducing a creation "jiffie" timestamp (creation_ts).
> > If the element is tried evicted in same jiffie, then perform tail drop
> > on the LRU list instead.
> > 
> > Signed-off-by: Jesper Dangaard Brouer <jbrouer@redhat.com>

First of all, this patch is not the perfect thing, its a starting point
of a discussion to find a better solution.


> This would only 'work' if a reassembled packet can be done/completed
> under one jiffie.

True, and I'm not happy with this resolution.  It's only purpose is to
help me detect when the LRU list is reversing it functionality. 

This is the *only* message I'm trying to convey:

    **The LRU list is misbehaving** (in this situation)


Perhaps the best option is to implement something else than a LRU... I
just haven't found the correct replacement/idea yet.


> For 64KB packets, this means 100Mb link wont be able to deliver a
> reassembled packet under IP frags load if HZ=1000

True, the 1 jiffie check should be increased, but that's not the point.
(Also I make no promise of fairness, I hope we can address this fairness
issues in a later patch, perhaps in combination with replacing the LRU).


(Notice: I have run tests with higher high_thresh/low_thresh values, the
results are the same)


> LRU goal is to be able to select the oldest inet_frag_queue, because in
> typical networks, packet losses are really happening and this is why
> some packets wont complete their reassembly. They naturally will be
> found on LRU head, and they probably are very fat (for example a single
> packet was lost for the inet_frag_queue)

Look at what is happening in inet_frag_evictor(), when we are under
load.  We will quickly delete all the oldest inet_frag_queue, you are
talking about.  After which the LRU list will be filled with what? Only
new fragments.  

Think about that is the order of this list, now?  Remember it only
contains incomplete inet_frag_queue's.

My theory, prove me wrong, is when the LRU head is very new/warm, then
the head is most likely the one with most fragments and the tail (latest
used or added element) with the least fragments.


> Choosing the most recent inet_frag_queue is exactly the opposite
> strategy. We pay the huge cost of maintaining a central LRU, and we
> exactly misuse it.

Then the LRU list is perhaps is the wrong choice?

> As long as an inet_frag_queue receives new fragments and is moved to the
> LRU tail, its a candidate for being kept, not a candidate for being
> evicted.

Remember I have shown/proven that all inet_frag_queue's in the list
have been touched within 1 jiffie.  Which one do you choose for removal?

(Also remember if an inet_frag_queue looses one frame, on the network
layer, it will not complete, and after 1 jiffie it will be killed by the
evictor.  So, this function still "works")


> Only when an inet_frag_queue is the oldest one, it becomes a candidate
> for eviction.
> 
> I think you are trying to solve a configuration/tuning problem by
> changing a valid strategy.
> 
> Whats wrong with admitting high_thresh/low_thresh default values should
> be updated, now some people apparently want to use IP fragments in
> production ?

I'm not against increasing the high_thresh/low_thresh default values.
I have tested with your 4MB/3MB settings (and 40/39, and 400/399).  The
results are (almost) the same, its not the problem!  I have shown you
several test results already (added some extra tests below)
And yes, the high_thresh/low_thresh default values should be increased,
I just don't want to discuss how much.

I want to discuss the correctness of the evictor and LRU.  You are
trying to avoid calling the evictor code; you cannot, assuming a queing
system, where packets are arriving at a higher rate than you can
process.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer


p.s. I'm working on getting a better interleaving of the fragments. I'm
depending on running netperf generators on different CPUs.  I tried
adding a SFQ qdisc, but no egress queueing occurred, so it didn't have
any effect.

RAW tests, with different high_thresh/low_thresh:
-------------------------------------------------
I'm extracting the "FRAG: inuse X memory YYYYYY" with the command:
 [root@dragon ~]# for pid in `ps aux | grep [n]etserver | awk '{print $2}' | tr '\n' ' '`; do echo -e "\nNetserver PID:$pid"; egrep -e 'UDP|FRAG' /proc/$pid/net/sockstat ; done

Default net-next kernel with out patches:

[root@dragon ~]# uname -a
Linux dragon 3.7.0-rc6-net-next+ #47 SMP Thu Nov 22 00:06:12 CET 2012 x86_64 x86_64 x86_64 GNU/Linux

----------------------
[root@dragon ~]# grep . /proc/sys/net/ipv4/ipfrag_*_thresh
/proc/sys/net/ipv4/ipfrag_high_thresh:262144
/proc/sys/net/ipv4/ipfrag_low_thresh:196608

FRAG: inuse 4 memory 245152

[jbrouer@firesoul ~]$ netperf -H 192.168.51.2 -T0,0 -t UDP_STREAM -l 20 & netperf -p 1337 -H 192.168.31.2 -T7,7 -t UDP_STREAM -l 20
[1] 10580
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.31.2 (192.168.31.2) port 0 AF_INET : cpu bind
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.51.2 (192.168.51.2) port 0 AF_INET : cpu bind
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      353279      0    9256.89
212992           20.00       10768            282.15

Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      350801      0    9191.95
212992           20.00        7283            190.83

------------------------


[root@dragon ~]# sysctl -w net/ipv4/ipfrag_high_thresh=$(((1024**2*4)))
net.ipv4.ipfrag_high_thresh = 4194304
[root@dragon ~]# sysctl -w net/ipv4/ipfrag_low_thresh=$(((1024**2*3)))
net.ipv4.ipfrag_low_thresh = 3145728

FRAG: inuse 41 memory 3867784

[jbrouer@firesoul ~]$ netperf -H 192.168.51.2 -T0,0 -t UDP_STREAM -l 20 & netperf -p 1337 -H 192.168.31.2 -T7,7 -t UDP_STREAM -l 20
[1] 10882
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.31.2 (192.168.31.2) port 0 AF_INET : cpu bind
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.51.2 (192.168.51.2) port 0 AF_INET : cpu bind
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      353379      0    9259.50
212992           20.00       48986           1283.57

Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      350488      0    9183.75
212992           20.00       33336            873.50

-------------------------

[root@dragon ~]# sysctl -w net/ipv4/ipfrag_high_thresh=$(((1024**2*40)))
net.ipv4.ipfrag_high_thresh = 41943040
[root@dragon ~]# sysctl -w net/ipv4/ipfrag_low_thresh=$(((1024**2*39)))
net.ipv4.ipfrag_low_thresh = 40894464

FRAG: inuse 442 memory 41693008

[jbrouer@firesoul ~]$ netperf -H 192.168.51.2 -T0,0 -t UDP_STREAM -l 20 & netperf -p 1337 -H 192.168.31.2 -T7,7 -t UDP_STREAM -l 20
[1] 10899
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.31.2 (192.168.31.2) port 0 AF_INET : cpu bind
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.51.2 (192.168.51.2) port 0 AF_INET : cpu bind
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      353097      0    9252.10
212992           20.00       38281           1003.07

Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      351708      0    9215.72
212992           20.00       23602            618.44


---------------------------

[root@dragon ~]# sysctl -w net/ipv4/ipfrag_high_thresh=$(((1024**2*400)))
net.ipv4.ipfrag_high_thresh = 419430400
[root@dragon ~]# sysctl -w net/ipv4/ipfrag_low_thresh=$(((1024**2*399)))
net.ipv4.ipfrag_low_thresh = 418381824

FRAG: inuse 4665 memory 418760600

[jbrouer@firesoul ~]$ netperf -H 192.168.51.2 -T0,0 -t UDP_STREAM -l 20 & netperf -p 1337 -H 192.168.31.2 -T7,7 -t UDP_STREAM -l 20
[2] 10918
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.31.2 (192.168.31.2) port 0 AF_INET : cpu bind
UDP UNIDIRECTIONAL SEND TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.51.2 (192.168.51.2) port 0 AF_INET : cpu bind
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      352255      0    9230.05
212992           20.00       28048            734.94

Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   65507   20.00      349842      0    9166.83
212992           20.00       20979            549.71
