From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in
 NAPI context
Date: Tue, 10 May 2016 08:44:13 -0700
Message-ID: <1462895053.23934.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	 <20160509134429.3573.4048.stgit@firesoul>
	 <CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
	 <20160509215956.19ec1c10@redhat.com>
	 <CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
	 <20160510143017.212c3846@redhat.com>
	 <1462888134.23934.60.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160510164857.72c8a1cb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:35279 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbcEJPoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 11:44:16 -0400
Received: by mail-pf0-f170.google.com with SMTP id 77so7145007pfv.2
        for <netdev@vger.kernel.org>; Tue, 10 May 2016 08:44:15 -0700 (PDT)
In-Reply-To: <20160510164857.72c8a1cb@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-05-10 at 16:48 +0200, Jesper Dangaard Brouer wrote:
> On Tue, 10 May 2016 06:48:54 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > On Tue, 2016-05-10 at 14:30 +0200, Jesper Dangaard Brouer wrote:
> > 
> > > Disable busy poll on both client and server, Not patched:
> > > 
> > >  $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
> > >  MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 port 0 AF_INET to 198.18.40.2 
> > >  ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
> > >  Local /Remote
> > >  Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> > >  Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> > >  bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
> > >  
> > >  16384  87380  1       1      60.00   78077.55  3.74   2.69   3.830   8.265  
> > >  16384  87380   
> > 
> > Tell us more about the -T6,6
> > 
> > For example how many TX/RX queues you have on the NIC, and which cpus
> > service interrupts.
> 
> The -T6,6 option:
>  -T lcpu,rcpu      Request netperf/netserver be bound to local/remote cpu
> 

Sure, I know -T option in netperf.

> I use the option to get more stable results.  If I don't pin/bind the
> CPU netperf/netserver is running on then the CPU scheduler will migrate
> the processes around.  This gives unpredictable results, worst for the
> busy_poll tests.  Especially if the RX softirq runs on the same CPU
> (also true if it runs on a HyperTread siping).  
> 
> Netperf client (8 cores i7-4790K CPU @ 4.00GHz)  RX:8 and TX:8 queues.
> Netserver server (2x 12 cores E5-2630 @ 2.30GHz) RX:8 and TX:24 queues.
> Driver mlx4.
> Disabled GRO to hit code path I changed in patch 2.

But are you using stuff like aRFS, RPS , RFS ?

Each netperf run lands on different cpus, and we know that results can
have a 25% variability  because of that, even more on 2-node systems.

By forcing -T6,6 you force the netperf/netserver cpu, not the RX queues.

A nice effort would be to be able to chose the source in the 4-tuple at
connect() time so that we know that Toeplitz hash will select the
'correct' RX queue.
