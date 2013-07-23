From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: TCP_NOSENT_LOWAT socket option
Date: Mon, 22 Jul 2013 17:13:42 -0700
Message-ID: <1374538422.4990.99.camel@edumazet-glaptop>
References: <1374520422.4990.33.camel@edumazet-glaptop>
	 <51ED9957.9070107@hp.com> <1374533052.4990.89.camel@edumazet-glaptop>
	 <51EDBB8B.2000805@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:55222 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab3GWANq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 20:13:46 -0400
Received: by mail-oa0-f42.google.com with SMTP id j6so9973452oag.29
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 17:13:46 -0700 (PDT)
In-Reply-To: <51EDBB8B.2000805@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 16:08 -0700, Rick Jones wrote:
> On 07/22/2013 03:44 PM, Eric Dumazet wrote:
> > Hi Rick
> >
> >> Netperf is perhaps a "best case" for this as it has no think time and
> >> will not itself build-up a queue of data internally.
> >>
> >> The 18% increase in service demand is troubling.
> >
> > Its not troubling at such high speed. (Note also I had better throughput
> > in my (single) test)
> 
> Yes, you did, but that was only 5.4%, and it may be in an area where 
> there is non-trivial run to run variation.
> 
> I would think an increase in service demand is even more troubling at 
> high speeds than low speeds.  Particularly when I'm still not at link-rate.
> 

If I wanter link-rate, I would use TCP_SENDFILE, and unfortunately be
slowed down by the receiver ;)

> In theory anyway, the service demand is independent of the transfer 
> rate.  Of course, practice dictates that different algorithms have 
> different behaviours at different speeds, but in slightly sweeping 
> handwaving, if the service demand went up 18% that cut your maximum 
> aggregate throughput for the "infinitely fast link" or collection of 
> finitely fast links in the system by 18%.
> 
> I suppose that brings up the question of what the aggregate throughput 
> and CPU utilization was for your 200 concurrent netperf TCP_STREAM sessions.

I am not sure I want to add 1000 lines in the changelog with a detailed
netperf results. Even so, they would be meaningful for my lab machines.


> 
> > Process scheduler cost is abysmal (Or more exactly when cpu enters idle
> > mode I presume).
> >
> > Adding a context switch for every TSO packet is obviously not something
> > you want if you want to pump 20Gbps on a single tcp socket.
> 
> You wouldn't want it if you were pumping 20 Gbit/s down multiple TCP 
> sockets either I'd think.

No difference as a matter of fact, as each netperf _will_ schedule
anyway, as a queue builds in Qdisc layer.



> 
> > I guess that real application would not use 16KB send()s either.
> 
> You can use a larger send in netperf - the 16 KB is only because that is 
> the default initial SO_SNDBUF size under Linux :)
> 
> > I chose extreme parameters to show that the patch had acceptable impact.
> > (128KB are only 2 TSO packets)
> >
> > The main targets of this patch are servers handling hundred to million
> > of sockets, or any machine with RAM constraints. This would also permit
> > better autotuning in the future. Our current 4MB limit is a bit small in
> > some cases.
> >
> > Allowing the socket write queue to queue more bytes is better for
> > throughput/cpu cycles, as long as you have enough RAM.
> 
> So, netperf doesn't queue internally - what happens when the application 
> does queue internally?  Admittedly, it will be user-space memory (I 
> assume) rather than kernel memory, which I suppose is better since it 
> can be paged and whatnot.  But if we drop the qualifiers, it is still 
> the same quantity of memory overall right?
> 
> By the way, does this affect sendfile() or splice()?

Sure : Patch intercepts sk_stream_memory_free() for all its callers.

10Gb link 'experiment with sendfile()' :

lpq83:~# echo -1 >/proc/sys/net/ipv4/tcp_notsent_lowat
lpq83:~# perf stat -e context-switches ./netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.246.17.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    20.00      9372.56   1.69     -1.00    0.355   -1.000 

 Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':

            16,188 context-switches                                            

      20.006998098 seconds time elapsed

lpq83:~# echo 131072 >/proc/sys/net/ipv4/tcp_notsent_lowat
lpq83:~# perf stat -e context-switches ./netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c
TCP SENDFILE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.246.17.84 () port 0 AF_INET
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB

 87380  16384  16384    20.00      9408.33   1.75     -1.00    0.366   -1.000 

 Performance counter stats for './netperf -H 10.246.17.84 -l 20 -t TCP_SENDFILE -c':

           714,395 context-switches                                            

      20.004409659 seconds time elapsed
