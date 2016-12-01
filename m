From: Tom Herbert <tom@herbertland.com>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 12:18:50 -0800
Message-ID: <CALx6S37aknqfrj66AP8hEfVT9X2OmBFK9GVa9A+0FpydPbm9kg@mail.gmail.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201135508.GB24547@oracle.com> <CALx6S35DCyi_2z1pqCLaB1bVyNykP_J3YaYEXUT8xxmuzyBDwA@mail.gmail.com>
 <aac93b13-6298-b9eb-7f3c-b074f22c388c@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35562 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934190AbcLAUS4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:18:56 -0500
Received: by mail-qt0-f174.google.com with SMTP id c47so232353233qtc.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 12:18:52 -0800 (PST)
In-Reply-To: <aac93b13-6298-b9eb-7f3c-b074f22c388c@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 11:48 AM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 12/01/2016 11:05 AM, Tom Herbert wrote:
>>
>> For the GSO and GRO the rationale is that performing the extra SW
>> processing to do the offloads is significantly less expensive than
>> running each packet through the full stack. This is true in a
>> multi-layered generalized stack. In TXDP, however, we should be able
>> to optimize the stack data path such that that would no longer be
>> true. For instance, if we can process the packets received on a
>> connection quickly enough so that it's about the same or just a little
>> more costly than GRO processing then we might bypass GRO entirely.
>> TSO is probably still relevant in TXDP since it reduces overheads
>> processing TX in the device itself.
>
>
> Just how much per-packet path-length are you thinking will go away under the
> likes of TXDP?  It is admittedly "just" netperf but losing TSO/GSO does some
> non-trivial things to effective overhead (service demand) and so throughput:
>
For plain in order TCP packets I believe we should be able process
each packet at nearly same speed as GRO. Most of the protocol
processing we do between GRO and the stack are the same, the
differences are that we need to do a connection lookup in the stack
path (note we now do this is UDP GRO and that hasn't show up as a
major hit). We also need to consider enqueue/dequeue on the socket
which is a major reason to try for lockless sockets in this instance.

> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -- -P
> 12867
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET to
> np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo
> Recv   Send    Send                          Utilization       Service
> Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
>
>  87380  16384  16384    10.00      9260.24   2.02     -1.00    0.428 -1.000
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ sudo ethtool -K hed0 tso off gso off
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -- -P
> 12867
> MIGRATED TCP STREAM TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET to
> np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo
> Recv   Send    Send                          Utilization       Service
> Demand
> Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
> Size   Size    Size     Time     Throughput  local    remote   local remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
>
>  87380  16384  16384    10.00      5621.82   4.25     -1.00    1.486 -1.000
>
> And that is still with the stretch-ACKs induced by GRO at the receiver.
>
Sure, but trying running something emulates a more realistic workload
than a TCP stream, like RR test with relative small payload and many
connections.

> Losing GRO has quite similar results:
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_MAERTS -- -P 12867
> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET to
> np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo
> Recv   Send    Send                          Utilization       Service
> Demand
> Socket Socket  Message  Elapsed              Recv     Send     Recv    Send
> Size   Size    Size     Time     Throughput  local    remote   local remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
>
>  87380  16384  16384    10.00      9154.02   4.00     -1.00    0.860 -1.000
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ sudo ethtool -K hed0 gro off
>
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_MAERTS -- -P 12867
> MIGRATED TCP MAERTS TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET to
> np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo
> Recv   Send    Send                          Utilization       Service
> Demand
> Socket Socket  Message  Elapsed              Recv     Send     Recv    Send
> Size   Size    Size     Time     Throughput  local    remote   local remote
> bytes  bytes   bytes    secs.    10^6bits/s  % S      % U      us/KB   us/KB
>
>  87380  16384  16384    10.00      4212.06   5.36     -1.00    2.502 -1.000
>
> I'm sure there is a very non-trivial "it depends" component here - netperf
> will get the peak benefit from *SO and so one will see the peak difference
> in service demands - but even if one gets only 6 segments per *SO that is a
> lot of path-length to make-up.
>
True, but I think there's a lot of path we'll be able to cut out. In
this mode we don't need IPtables, Netfilter, input route, IPvlan
check, or other similar lookups. Once we've successfully matched a
establish TCP state anything related to policy on both TX and RX for
that connection is inferred from the state. We want the processing
path in this case to just be concerned with just protocol processing
and interface to user.

> 4.4 kernel, BE3 NICs ... E5-2640 0 @ 2.50GHz
>
> And even if one does have the CPU cycles to burn so to speak, the effect on
> power consumption needs to be included in the calculus.
>
Definitely, power consumption is the down side of spin polling CPUs.
As I said we would never should be spinning any more CPUs than
necessary to handle the load.

Tom

> happy benchmarking,
>
> rick jones
