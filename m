From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in
 NAPI context
Date: Tue, 10 May 2016 14:30:17 +0200
Message-ID: <20160510143017.212c3846@redhat.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	<20160509134429.3573.4048.stgit@firesoul>
	<CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
	<20160509215956.19ec1c10@redhat.com>
	<CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270AbcEJMaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 08:30:24 -0400
In-Reply-To: <CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 9 May 2016 13:46:32 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> Try testing with TCP_RR instead and watch the CPU utilization.  I'm
> suspecting allocating 8 and freeing 7 buffers for every 1 buffer
> received will blow any gains right out of the water.  Also try it with
> a mix of traffic.  So have one NIC doing TCP_RR while another is doing
> a stream test.  You are stuffing 7 buffers onto a queue that were were
> using to perform bulk freeing.  How much of a penalty do you take if
> you are now limited on how many you can bulk free because somebody
> left a stray 7 packets sitting on the queue?

Testing with TCP_RR, is not a very "clean" network test. One have to be
very careful what is actually being tested, is it the server or client
which is the bottleneck. And most of all this is test of the CPU/process
scheduler.

We can avoid the scheduler problem by enabling busy_poll/busy_read.

I guess you want to see the "scheduler test" first.  Default setting of
disabled busy poll on both client and server:

Disable busy poll on both client and server, Not patched:

 $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
 MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 
 ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
 Local /Remote
 Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
 Send   Recv   Size    Size   Time    Rate     local  remote local   remote
 bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
 
 16384  87380  1       1      60.00   78077.55  3.74   2.69   3.830   8.265  
 16384  87380 

Disable busy poll on both client and server, patched:

 $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
 MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2
 ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
 Local /Remote
 Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
 Send   Recv   Size    Size   Time    Rate     local  remote local   remote
 bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
 
 16384  87380  1       1      60.00   78517.32  3.06   2.84   3.118   8.677  
 16384  87380 

I will not call this an improvement... the results are basically the same.



Next step enabling busy poll on the server.  The server is likely the
bottleneck, given it's CPU is slower than the client.  Context switches
on the server is too high 156K/sec, after enabling busy poll reduced to
620/sec. Note the client is doing around 233k/sec context switches,
(fairly impressive).

Enabling busy poll on the server:
 sysctl -w net.core.busy_poll=50
 sysctl -w net.core.busy_read=50


Enabled busy poll only on server, Not patched:
 $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
 MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 
 ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
 Local /Remote
 Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
 Send   Recv   Size    Size   Time    Rate     local  remote local   remote
 bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

 16384  87380  1       1      60.00   112480.72  5.90   4.68   4.194   9.984  
 16384  87380 

Enabled busy poll only on server, patched:

 $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
 MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 
 ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
 Local /Remote
 Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
 Send   Recv   Size    Size   Time    Rate     local  remote local   remote
 bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

 16384  87380  1       1      60.00   110152.34  5.84   4.60   4.242   10.014 
 16384  87380 

Numbers are too close, for any conclusions.

Running a second run, on Not-patched kernel:
 Enabled busy poll only on server, Not patched:
 [jbrouer@canyon ~]$ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
 MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 
 ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
 Local /Remote
 Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
 Send   Recv   Size    Size   Time    Rate     local  remote local   remote
 bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

 16384  87380  1       1      60.00   101554.90  4.12   4.31   3.245   10.185 
 16384  87380 

Thus, variation between runs are bigger than any improvement/regression,
thus no performance conclusions from this change can be drawn.


Lets move beyond testing the CPU/process scheduler by enabling
busy-polling on both client and server:
 (sysctl -w net.core.busy_poll=50 ;sysctl -w net.core.busy_read=50)

Enable busy poll on both client and server, Not patched:

$ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 () port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      60.00   137987.86  13.18  4.77   7.643   8.298  
16384  87380 


Enable busy poll on both client and server, patched:

$ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 198.18.40.2 () port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      60.00   147324.38  13.76  4.76   7.474   7.747  
16384  87380 

I've a little bit surprised to see such a large improvement here 6.76%.
 147324/137987*100 = 106.76

I'm remaining skeptic towards this measurement, as the improvement
should not be this high.  Even if recycling is happening.

Perf record does show less calls to __slab_free(), indicating better
interaction with SLUB, and perhaps recycling working.  But this is
only a perf-report change from 0.37% to 0.33%.

More testing show not-patched kernel fluctuate between 125k-143k/sec,
and patched kernel fluctuate between 131k-152k/sec. The ranges are too
high, to say anything conclusive.  It seems to be timing dependent, as
starting and stoping the test with -D 1, show a rate variation within
2k/sec, but rate itself can vary withing the range stated.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
