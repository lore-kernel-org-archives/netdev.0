From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: DDoS attack causing bad effect on conntrack searches
Date: Sat, 24 Apr 2010 13:11:02 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1004241219280.32071@ask.diku.dk>
References: <1271941082.14501.189.camel@jdb-workstation>
 <q2h412e6f7f1004220613m488c2ee4r6d24a8d1e65997d4@mail.gmail.com>
 <4BD04C74.9020402@trash.net> <1271946961.7895.5665.camel@edumazet-laptop>
 <1271948029.7895.5707.camel@edumazet-laptop>  <20100422155123.GA2524@linux.vnet.ibm.com>
  <1271952128.7895.5851.camel@edumazet-laptop>  <Pine.LNX.4.64.1004222213290.10919@ask.diku.dk>
 <1272056237.4599.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1967386983-1272107462=:32071"
Cc: paulmck@linux.vnet.ibm.com, Patrick McHardy <kaber@trash.net>,
	Changli Gao <xiaosuo@gmail.com>, hawk@comx.dk,
	Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:39702 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751967Ab0DXLLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Apr 2010 07:11:09 -0400
In-Reply-To: <1272056237.4599.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1967386983-1272107462=:32071
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

On Fri, 23 Apr 2010, Eric Dumazet wrote:

> Le jeudi 22 avril 2010 à 22:38 +0200, Jesper Dangaard Brouer a écrit :
>
>>
>> I think its plausable, there is a lot of modification going on.
>> Approx 40.000 deletes/sec and 40.000 inserts/sec.
>> The hash bucket size is 300032, and with 80000 modifications/sec, we are
>> (potentially) changing 26.6% of the hash chains each second.
>>
>> As can be seen from the graphs:
>>   http://people.netfilter.org/hawk/DDoS/2010-04-12__001/list.html
>>
>> Notice that primarily CPU2 is doing the 40k deletes/sec, while CPU1 is
>> caught searching...
>>
>>
>>> maybe hash table has one slot :)
>>
>> Guess I have to reproduce the DoS attack in a testlab (I will first have
>> time Tuesday).  So we can determine if its bad hashing or restart of the
>> search loop.
>>
>>
>> The traffic pattern was fairly simple:
>>
>> 200 bytes UDP packets, comming from approx 60 source IPs, going to one
>> destination IP.  The UDP destination port number was varied in the range
>> of 1 to 6000.   The source UDP port was varied a bit more, some ranging
>> from 32768 to 61000, and some from 1028 to 5000.
>>
>>
>
> Re-reading this, I am not sure there is a real problem on RCU as you
> pointed out.
>
> With 800.000 entries, in a 300.032 buckets hash table, each lookup hit
> about 3 entries (aka searches in conntrack stats)
>
> 300.000 packets/second -> 900.000 'searches' per second.

The machine is not getting 300.000 pps, its only getting 40.000 pps (the 
rest is stopped by the NIC by sending Ethernet flowcontrol pause frames)

  http://people.netfilter.org/hawk/DDoS/2010-04-12__001/eth0-rx.png

We are doing 700.000 'searches' per second, with 40.000 pps, thus on 
average the list lenght (in each hash bucket) just need to be 17.5 
elements.  Is this an acceptable has distribution, with 900.000 elements 
in a 300.032 buckets hash table?


> If you have four cpus all trying to insert/delete entries in //, they
> all hit the central conntrack lock.

This machine only have two CPUs, or rather one physical CPU and one 
hyperthreaded.  The server is a old HP380 G4, with an old Xeon type CPU 
3.4 GHz (1MB cache).  If remember correctly its based on Pentium-4 
technologi, which had a pretty bad hyperthreading.


> On a DDOS scenario, every packet needs to take this lock twice,
> once to free an old conntrack (early drop), once to insert a new entry.

I was worried about if the "early drop" e.g. free an old conntrack would 
disturbe the conntrack searching?


> To scale this, only way would be to have an array of locks, like we have
> for TCP/UDP hash tables.
>
> I did some tests here, with a multiqueue card, flooded with 300.000
> pack/second, 65.536 source IP, millions of flows, and nothing wrong
> happened (but packets drops, of course)

A small hint when testing, use Haralds tool 'lnstat' to see the stats on 
the command line, thus you don't need to RRDtool graphe every thing:

Command:
  lnstat -f nf_conntrack -i 1 -c 1000

I don't have a multiqueue NIC in this old machine.

I also ran some tests on my 10G testlab, but it didn't go wrong. 
Tweeking the pktgen DDoS I could get the system to do 4.500.000 'searches' 
per sec with a 1.500.000 packets/sec. (Have not reloaded the kernel with 
the new failed lookup stats).  Guess my 10G machines are too fast to hit 
the issues.


> My two cpus were busy 100%, after tweaking smp_affinities, because on
> first try, irqbalance put "01" mask on both queues, so only one ksoftirq
> was working, other cpu was idle :(

Think my machine is some what slower than yours, perhaps its simply not 
fast enough for this kind of workload (pretty sure that the cache is the 
CPU is getting f*ked in this case).

On my machine one CPU in stuck in softirq:
  http://people.netfilter.org/hawk/DDoS/2010-04-12__001/cpu_softirq001.png

And another observation is that the CPUs are disturbing each other on the 
RX softirq code path.
http://people.netfilter.org/hawk/DDoS/2010-04-12__001/softnet_time_squeeze_rx-softirq001.png
(/proc/net/softnet_stat column 3)

Monday or Tuesdag I'll do a test setup with some old HP380 G4 machines to 
see if I can reproduce the DDoS attack senario.  And see if I can get 
it into to lookup loop.

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
---511516320-1967386983-1272107462=:32071--
