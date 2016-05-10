From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in NAPI
 context
Date: Tue, 10 May 2016 10:46:56 -0700
Message-ID: <57321E90.3010505@gmail.com>
References: <20160509134352.3573.37044.stgit@firesoul>
 <20160509134429.3573.4048.stgit@firesoul>
 <CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
 <20160509215956.19ec1c10@redhat.com>
 <CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
 <20160510143017.212c3846@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35930 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbcEJRq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 13:46:58 -0400
Received: by mail-pa0-f48.google.com with SMTP id bt5so7738023pac.3
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 10:46:58 -0700 (PDT)
In-Reply-To: <20160510143017.212c3846@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2016 05:30 AM, Jesper Dangaard Brouer wrote:
>
> On Mon, 9 May 2016 13:46:32 -0700
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> Try testing with TCP_RR instead and watch the CPU utilization.  I'm
>> suspecting allocating 8 and freeing 7 buffers for every 1 buffer
>> received will blow any gains right out of the water.  Also try it with
>> a mix of traffic.  So have one NIC doing TCP_RR while another is doing
>> a stream test.  You are stuffing 7 buffers onto a queue that were were
>> using to perform bulk freeing.  How much of a penalty do you take if
>> you are now limited on how many you can bulk free because somebody
>> left a stray 7 packets sitting on the queue?
>
> Testing with TCP_RR, is not a very "clean" network test. One have to be
> very careful what is actually being tested, is it the server or client
> which is the bottleneck. And most of all this is test of the CPU/process
> scheduler.
>
> We can avoid the scheduler problem by enabling busy_poll/busy_read.
>
> I guess you want to see the "scheduler test" first.  Default setting of
> disabled busy poll on both client and server:
>
> Disable busy poll on both client and server, Not patched:

Lets also define what "Not patched" means.  I only want the bulk 
allocation patch tested.  The other patches you have for the mlx4 and 
the WARN_ON are just noise.  If possible it would be best to focus on 
just the one patch that is high risk.

>   $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
>   MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2
>   ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
>   Local /Remote
>   Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
>   Send   Recv   Size    Size   Time    Rate     local  remote local   remote
>   bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>
>   16384  87380  1       1      60.00   78077.55  3.74   2.69   3.830   8.265
>   16384  87380
>
> Disable busy poll on both client and server, patched:
>
>   $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
>   MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2
>   ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
>   Local /Remote
>   Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
>   Send   Recv   Size    Size   Time    Rate     local  remote local   remote
>   bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>
>   16384  87380  1       1      60.00   78517.32  3.06   2.84   3.118   8.677
>   16384  87380
>
> I will not call this an improvement... the results are basically the same.

So I have a few suggestions.

1.  Either switch to ixgbe and use ATR/Flow Director or look at setting 
up your test so that the RSS key and indirection table are the same for 
each test and use the "-- -P" option in netperf to force the use of the 
same 5 tuple for each test.

2.  Cut down on the noise.  Specifically rebuild your kernel with as few 
options enabled as possible.  If you don't need it drop it out so that 
we can identify exactly how much gain there is to be had from your 
patches.  Also you should increase your test to use multiple CPUs, or 
cut down on the number of CPUs so that you aren't cutting down the the 
CPU utilization so much.  If you have to you might even look at doing 
something like using SAR -P 6 in order to be able to monitor the CPU 
utilization of just CPU 6 on your test system.

The goal is you want your tests to be repeatable if you had to move to 
another system or another NIC so I would recommend trying to find a way 
to make it so that much of the fluctuation is ruled out and that your 
numbers are as reliable as possible.

3.  You might even try a pktgen Rx and drop test to see what the 
difference is in ns/packet for your allocation routine.  Assuming you 
can clear out the variability that would be a useful datapoint as you 
could then also collect the perf data to show which functions have 
reduced their total CPU time.

> Next step enabling busy poll on the server.  The server is likely the
> bottleneck, given it's CPU is slower than the client.  Context switches
> on the server is too high 156K/sec, after enabling busy poll reduced to
> 620/sec. Note the client is doing around 233k/sec context switches,
> (fairly impressive).
>
> Enabling busy poll on the server:
>   sysctl -w net.core.busy_poll=50
>   sysctl -w net.core.busy_read=50
>
>
> Enabled busy poll only on server, Not patched:
>   $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
>   MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2
>   ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
>   Local /Remote
>   Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
>   Send   Recv   Size    Size   Time    Rate     local  remote local   remote
>   bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>
>   16384  87380  1       1      60.00   112480.72  5.90   4.68   4.194   9.984
>   16384  87380
>
> Enabled busy poll only on server, patched:
>
>   $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
>   MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2
>   ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
>   Local /Remote
>   Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
>   Send   Recv   Size    Size   Time    Rate     local  remote local   remote
>   bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>
>   16384  87380  1       1      60.00   110152.34  5.84   4.60   4.242   10.014
>   16384  87380
>
> Numbers are too close, for any conclusions.

Agreed.

> Running a second run, on Not-patched kernel:
>   Enabled busy poll only on server, Not patched:
>   [jbrouer@canyon ~]$ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
>   MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2
>   ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
>   Local /Remote
>   Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
>   Send   Recv   Size    Size   Time    Rate     local  remote local   remote
>   bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>
>   16384  87380  1       1      60.00   101554.90  4.12   4.31   3.245   10.185
>   16384  87380
>
> Thus, variation between runs are bigger than any improvement/regression,
> thus no performance conclusions from this change can be drawn.

Like Eric mentioned this is likely the fact that you are bouncing 
between Rx queues.

> Lets move beyond testing the CPU/process scheduler by enabling
> busy-polling on both client and server:
>   (sysctl -w net.core.busy_poll=50 ;sysctl -w net.core.busy_read=50)
>
> Enable busy poll on both client and server, Not patched:
>
> $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 () port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>
> 16384  87380  1       1      60.00   137987.86  13.18  4.77   7.643   8.298
> 16384  87380
>
>
> Enable busy poll on both client and server, patched:
>
> $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
> MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 () port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
>
> 16384  87380  1       1      60.00   147324.38  13.76  4.76   7.474   7.747
> 16384  87380
>
> I've a little bit surprised to see such a large improvement here 6.76%.
>   147324/137987*100 = 106.76

That is a difference of 500ns per packet.  I am highly doubtful we are 
seeing that much of an improvement as well.  Odds are you were doing 
something cross-node in  your first run or something along those lines 
since the difference is too large to be attributed to the bulk 
allocation change.

> I'm remaining skeptic towards this measurement, as the improvement
> should not be this high.  Even if recycling is happening.
>
> Perf record does show less calls to __slab_free(), indicating better
> interaction with SLUB, and perhaps recycling working.  But this is
> only a perf-report change from 0.37% to 0.33%.
>
> More testing show not-patched kernel fluctuate between 125k-143k/sec,
> and patched kernel fluctuate between 131k-152k/sec. The ranges are too
> high, to say anything conclusive.  It seems to be timing dependent, as
> starting and stoping the test with -D 1, show a rate variation within
> 2k/sec, but rate itself can vary withing the range stated.

I am pretty sure we are guaranteed to see a performance regression for 
socket based workloads.  You are hoping for recycling to occur, but in 
almost all cases recycling almost always fails to show any gains and 
just ends up introducing the possibility for regressions as something 
always gets overlooked.  On top of that you aren't guaranteed a frame 
from Tx clean-up is going to be warm in the cache so you may end up 
taking a few cache line misses as well.

I haven't seen enough change in these patches to justify having them 
submitted to the kernel.  A 1% improvement in one specific test case is 
kind of a vague reason to do something that very likely introduces 
regressions in many other cases.

- Alex
