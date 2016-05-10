From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH V1 1/3] net: bulk alloc and reuse of SKBs in
 NAPI context
Date: Tue, 10 May 2016 16:48:57 +0200
Message-ID: <20160510164857.72c8a1cb@redhat.com>
References: <20160509134352.3573.37044.stgit@firesoul>
	<20160509134429.3573.4048.stgit@firesoul>
	<CAKgT0Uftr643AR9n2=_aQmaGJO3eEyKTuaCfXwEKbYj1rVruRw@mail.gmail.com>
	<20160509215956.19ec1c10@redhat.com>
	<CAKgT0UfKzKWnNzGpB-915by2M1nzDAdNz-hDwwcwGoowmZefrg@mail.gmail.com>
	<20160510143017.212c3846@redhat.com>
	<1462888134.23934.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbcEJOtD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 10:49:03 -0400
In-Reply-To: <1462888134.23934.60.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 May 2016 06:48:54 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2016-05-10 at 14:30 +0200, Jesper Dangaard Brouer wrote:
> 
> > Disable busy poll on both client and server, Not patched:
> > 
> >  $ netperf -H 198.18.40.2 -t TCP_RR  -l 60 -T 6,6 -Cc
> >  MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 port 0 AF_INET to 198.18.40.2 
> >  ()  port 0 AF_INET : histogram : demo : first burst 0 : cpu bind
> >  Local /Remote
> >  Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> >  Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> >  bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
> >  
> >  16384  87380  1       1      60.00   78077.55  3.74   2.69   3.830   8.265  
> >  16384  87380   
> 
> Tell us more about the -T6,6
> 
> For example how many TX/RX queues you have on the NIC, and which cpus
> service interrupts.

The -T6,6 option:
 -T lcpu,rcpu      Request netperf/netserver be bound to local/remote cpu

I use the option to get more stable results.  If I don't pin/bind the
CPU netperf/netserver is running on then the CPU scheduler will migrate
the processes around.  This gives unpredictable results, worst for the
busy_poll tests.  Especially if the RX softirq runs on the same CPU
(also true if it runs on a HyperTread siping).  

Netperf client (8 cores i7-4790K CPU @ 4.00GHz)  RX:8 and TX:8 queues.
Netserver server (2x 12 cores E5-2630 @ 2.30GHz) RX:8 and TX:24 queues.
Driver mlx4.
Disabled GRO to hit code path I changed in patch 2.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
