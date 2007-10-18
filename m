From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Throughput Bug?
Date: Thu, 18 Oct 2007 10:11:04 -0700
Message-ID: <471793A8.20205@hp.com>
References: <c565abbb0710180854j6f2f756sdd390161bafd1c4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matthew Faulkner <matthew.faulkner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:41537 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933668AbXJRRLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2007 13:11:07 -0400
In-Reply-To: <c565abbb0710180854j6f2f756sdd390161bafd1c4a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Faulkner wrote:
> Hey all
> 
> I'm using netperf to perform TCP throughput tests via the localhost
> interface. This is being done on a SMP machine. I'm forcing the
> netperf server and client to run on the same core. However, for any
> packet sizes below 523 the throughput is much lower compared to the
> throughput when the packet sizes are greater than 524.
> 
> Recv   Send    Send                          Utilization       Service Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local   remote
> bytes  bytes   bytes    secs.    MBytes  /s  % S      % S      us/KB   us/KB
>  65536  65536    523    30.01        81.49   50.00    50.00    11.984  11.984
>  65536  65536    524    30.01       460.61   49.99    49.99    2.120   2.120
> 
> The chances are i'm being stupid and there is an obvious reason for
> this, but when i put  the server and client on different cores i don't
> see this effect.
> 
> Any help explaining this will be greatly appreciated.

One minor nit, but perhaps one that may help in the diagnosis - unless you set 
-D (lack of the full test banner, or a copy of the command line precludes 
knowing), and perhaps even then, all the -m option _really_ does for a 
TCP_STREAM test is set the size of the buffer passed to the transport on each 
send() call.  It is then entirely up to TCP as to how that gets 
merged/sliced/diced into TCP segments.

I forget what the MTU is of loopback, but you can get netperf to report the MSS 
for the connection by setting verbosity to 2 or more with the global -v option.

A packet trace might be interesting.  Seems that is possible under Linux with 
tcpdump.  If it were not possible, another netperf-level thing I might do is 
configure with --enable-histogram and recompile netperf (netserver does not need 
to be recompiled, although it doesn't take much longer once netperf is 
recompiled) and use the -v 2 again.  That will give you a histogram of the time 
spent in the send() call, which might be interesting if it ever blocks.


> Machine details:
> 
> Linux 2.6.22-2-amd64 #1 SMP Thu Aug 30 23:43:59 UTC 2007 x86_64 GNU/Linux

FWIW, with an "earlier" kernel I am not sure I can name since I'm not sure it is 
shipping (sorry, it was just what was on my system at the moment) don't see that 
_big_ difference between 523 and 524 regardless of TCP_NODELAY:

[root@hpcpc105 netperf2_trunk]# netperf -T 0 -c -C -- -m 524
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain 
(127.0.0.1) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  87380    524    10.00      2264.18   25.00    25.00    3.618   3.618
[root@hpcpc105 netperf2_trunk]# netperf -T 0 -c -C -- -m 523
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain 
(127.0.0.1) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  87380    523    10.00      3356.05   25.01    25.01    2.442   2.442


[root@hpcpc105 netperf2_trunk]# netperf -T 0 -c -C -- -m 523 -D
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain 
(127.0.0.1) port 0 AF_INET : nodelay : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  87380    523    10.00       398.87   25.00    25.00    20.539  20.537
[root@hpcpc105 netperf2_trunk]# netperf -T 0 -c -C -- -m 524 -D
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain 
(127.0.0.1) port 0 AF_INET : nodelay : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

  87380  87380    524    10.00       439.33   25.00    25.00    18.646  18.644

Although, if I do constrain the socket buffers to 64KB I _do_ see the behaviour 
on the older kernel as well:

[root@hpcpc105 netperf2_trunk]# netperf -T 0 -c -C -- -m 523 -s 64K -S 64K
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain 
(127.0.0.1) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

131072 131072    523    10.00       406.61   25.00    25.00    20.146  20.145
[root@hpcpc105 netperf2_trunk]# netperf -T 0 -c -C -- -m 524 -s 64K -S 64K
TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to localhost.localdomain 
(127.0.0.1) port 0 AF_INET : cpu bind
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

131072 131072    524    10.00      2017.12   25.02    25.03    4.065   4.066


(yes, this is a four-core system, hence 25% CPU util reported by netperf).

> sched_affinity is used by netperf internally to set the core affinity.
> 
> I tried this on 2.6.18 and i got the same problem!

I can say that the kernel I tried was based on 2.6.18...  So, due dilligence and 
no good deed going unpunished suggests that Matthew and I are now in a race to 
take some tcpdump traces :)

rick jones

> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

