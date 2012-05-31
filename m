From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [RFC PATCH 2/2] tcp: Early SYN limit and SYN cookie handling to mitigate SYN floods
Date: Thu, 31 May 2012 10:45:00 +0200
Message-ID: <201205311045.03556.hans.schillstrom@ericsson.com>
References: <20120528115102.12068.79994.stgit@localhost.localdomain> <4FC68F21.1040402@hp.com> <1338452917.2760.1309.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, Andi Kleen <andi@firstfloor.org>,
	Jesper Dangaard Brouer <jbrouer@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Topholm <mph@hoth.dk>, Florian Westphal <fw@strlen.de>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:62422 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932318Ab2EaIpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2012 04:45:10 -0400
In-Reply-To: <1338452917.2760.1309.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 31 May 2012 10:28:37 Eric Dumazet wrote:
> On Wed, 2012-05-30 at 14:20 -0700, Rick Jones wrote:
> 
> > It may still be high, but a very quick netperf TCP_CC test over loopback 
> > on a W3550 system running a 2.6.38 kernel shows:
> > 
> > raj@tardy:~/netperf2_trunk/src$ ./netperf -t TCP_CC -l 60 -c -C
> > TCP Connect/Close TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 
> > localhost.localdomain () port 0 AF_INET
> > Local /Remote
> > Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> > Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> > bytes  bytes  bytes   bytes  secs.   per sec  %      %      us/Tr   us/Tr
> > 
> > 16384  87380  1       1      60.00   21515.29   30.68  30.96  57.042  57.557
> > 16384  87380
> > 
> > 57 microseconds per "transaction" which in this case is establishing and 
> > tearing-down the connection, with nothing else (no data packets) makes 
> > 19 microseconds for a SYN seem perhaps not all that beyond the realm of 
> > possibility?
> 
> Thats a different story, on loopback device (without stressing IP route
> cache by the way)
> 
> Your netperf test is a full userspace transactions, and 5 frames per
> transaction. Two sockets creation/destruction, process scheduler
> activations, and not enter syncookie mode.
> 
> In case of synflood/(syncookies on), we receive a packet and send one
> from softirq.
> 
> One expensive thing might be the md5 to compute the SYNACK sequence.
> 
> I suspect other things :
> 
> 1) Of course we have to take into account the timer responsible for
> SYNACK retransmits of previously queued requests. Its cost depends on
> the listen backlog. When this timer runs, listen socket is locked.
> 
> 2) IP route cache overflows.
>    In case of SYNFLOOD, we should not store dst(s) in route cache but
> destroy them immediately.
> 
I can see plenty "IPv4: dst cache overflow"
