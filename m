From: Tom Herbert <tom@herbertland.com>
Subject: Re: Initial thoughts on TXDP
Date: Thu, 1 Dec 2016 14:12:36 -0800
Message-ID: <CALx6S34yWeU1_uGEEJvw=+a49V=vF_rgWVwpuJGzwFvwvQOkpg@mail.gmail.com>
References: <CALx6S34qPqXa7s1eHmk9V-k6xb=36dfiQvx3JruaNnqg4v8r9g@mail.gmail.com>
 <20161201135508.GB24547@oracle.com> <CALx6S35DCyi_2z1pqCLaB1bVyNykP_J3YaYEXUT8xxmuzyBDwA@mail.gmail.com>
 <aac93b13-6298-b9eb-7f3c-b074f22c388c@hpe.com> <CALx6S37aknqfrj66AP8hEfVT9X2OmBFK9GVa9A+0FpydPbm9kg@mail.gmail.com>
 <1e88fd64-0045-beb5-101a-a55b8f54bd08@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:36166 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbcLAWMi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 17:12:38 -0500
Received: by mail-qt0-f170.google.com with SMTP id w33so234813020qtc.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 14:12:38 -0800 (PST)
In-Reply-To: <1e88fd64-0045-beb5-101a-a55b8f54bd08@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2016 at 1:47 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 12/01/2016 12:18 PM, Tom Herbert wrote:
>>
>> On Thu, Dec 1, 2016 at 11:48 AM, Rick Jones <rick.jones2@hpe.com> wrote:
>>>
>>> Just how much per-packet path-length are you thinking will go away under
>>> the
>>> likes of TXDP?  It is admittedly "just" netperf but losing TSO/GSO does
>>> some
>>> non-trivial things to effective overhead (service demand) and so
>>> throughput:
>>>
>> For plain in order TCP packets I believe we should be able process
>> each packet at nearly same speed as GRO. Most of the protocol
>> processing we do between GRO and the stack are the same, the
>> differences are that we need to do a connection lookup in the stack
>> path (note we now do this is UDP GRO and that hasn't show up as a
>> major hit). We also need to consider enqueue/dequeue on the socket
>> which is a major reason to try for lockless sockets in this instance.
>
>
> So waving hands a bit, and taking the service demand for the GRO-on receive
> test in my previous message (860 ns/KB), that would be ~ (1448/1024)*860 or
> ~1.216 usec of CPU time per TCP segment, including ACK generation which
> unless an explicit ACK-avoidance heuristic a la HP-UX 11/Solaris 2 is put in
> place would be for every-other segment. Etc etc.
>
>> Sure, but trying running something emulates a more realistic workload
>> than a TCP stream, like RR test with relative small payload and many
>> connections.
>
>
> That is a good point, which of course is why the RR tests are there in
> netperf :) Don't get me wrong, I *like* seeing path-length reductions. What
> would you posit is a relatively small payload?  The promotion of IR10
> suggests that perhaps 14KB or so is a sufficiently common so I'll grasp at
> that as the length of a piece of string:
>
We have consider both request size and response side in RPC.
Presumably, something like a memcache server is most serving data as
opposed to reading it, we are looking to receiving much smaller
packets than being sent. Requests are going to be quite small say 100
bytes and unless we are doing significant amount of pipelining on
connections GRO would rarely kick-in. Response size will have a lot of
variability, anything from a few kilobytes up to a megabyte. I'm sorry
I can't be more specific this is an artifact of datacenters that have
100s of different applications and communication patterns. Maybe 100b
request size, 8K, 16K, 64K response sizes might be good for test.

> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_RR -- -P 12867 -r 128,14K
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET
> to np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 16384  87380  128     14336  10.00   8118.31  1.57   -1.00  46.410  -1.000
> 16384  87380
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ sudo ethtool -K hed0 gro off
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_RR -- -P 12867 -r 128,14K
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET
> to np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 16384  87380  128     14336  10.00   5837.35  2.20   -1.00  90.628  -1.000
> 16384  87380
>
> So, losing GRO doubled the service demand.  I suppose I could see cutting
> path-length in half based on the things you listed which would be bypassed?
>
> I'm sure mileage will vary with different NICs and CPUs.  The ones used here
> happened to be to hand.
>
This is also biased because you're using a single connection, but is
consistent with data we've seen in the past. To be clear I'm not
saying GRO is bad, the fact that GRO has such a visible impact in your
test means that the GRO path is significantly more efficient. Closing
that gap seen in your numbers would be a benefit, that means we have
improved per packet processing.

Tom

> happy benchmarking,
>
> rick
>
> Just to get a crude feel for sensitivity, doubling to 28K unsurprisingly
> goes to more than doubling, and halving to 7K narrows the delta:
>
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_RR -- -P 12867 -r 128,28K
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET
> to np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 16384  87380  128     28672  10.00   6732.32  1.79   -1.00  63.819  -1.000
> 16384  87380
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ sudo ethtool -K hed0 gro off
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_RR -- -P 12867 -r 128,28K
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET
> to np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 16384  87380  128     28672  10.00   3780.47  2.32   -1.00  147.280  -1.000
> 16384  87380
>
>
>
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_RR -- -P 12867 -r 128,7K
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET
> to np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 16384  87380  128     7168   10.00   10535.01  1.52   -1.00  34.664  -1.000
> 16384  87380
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ sudo ethtool -K hed0 gro off
> stack@np-cp1-c0-m1-mgmt:~/rjones2$ ./netperf -c -H np-cp1-c1-m3-mgmt -t
> TCP_RR -- -P 12867 -r 128,7K
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 12867 AF_INET
> to np-cp1-c1-m3-mgmt () port 12867 AF_INET : demo : first burst 0
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % U    us/Tr   us/Tr
>
> 16384  87380  128     7168   10.00   8225.17  1.80   -1.00  52.661  -1.000
> 16384  87380
>
>
