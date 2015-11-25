From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Wed, 25 Nov 2015 11:26:21 -0500
Message-ID: <20151125162621.GA13985@oracle.com>
References: <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
 <20151124152744.GB20972@breakpoint.cc>
 <20151124.105537.185897620062606312.davem@davemloft.net>
 <20151124162515.GA22266@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tom@herbertland.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	kernel-team@fb.com, davejwatson@fb.com,
	alexei.starovoitov@gmail.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46377 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbbKYQ0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 11:26:48 -0500
Content-Disposition: inline
In-Reply-To: <20151124162515.GA22266@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (11/24/15 17:25), Florian Westphal wrote:
> Its a well-written document, but I don't see how moving the burden of
> locking a single logical tcp connection (to prevent threads from
> reading a partial record) from userspace to kernel is an improvement.
> 
> If you really have 100 threads and must use a single tcp connection
> to multiplex some arbitrarily complex record-format in atomic fashion,
> then your requirements suck.

In the interest of providing some context from the rds-tcp use-case
here (without drifting into hyperbole).. RDS-TCP, like KCM,
provides a dgram-over-stream socket, with SEQPACKET semantics,
and an upper-bounded record-size per POSIX/SEQPACKET semantics. 
The major difference from kcm is that it does not use BPF, but 
instead has its own protocol header for each datagram.

There seems to be some misconception in this thread that this model
is about allowing application to be "lazy" and do a 1:1 mapping between
streams- that's not the case for RDS.

In the case of cluster apps, we have DB apps that want to have a single
dgram socket to talk to multiple peers (i.e., a star-network, with the
node in the center of the star wanting to have dgram sockets to everyone
else. Scale is more than a mere 100 threads).

If that central node wants reliable, ordered, congestion-managed
delivery, it would have to use UDP + bunch of its own code for
seq#, rexmit etc. And they are doing that today, but dont want the
to reinvent TCP's congavoid (and in fact, in the absence of congestion,
one complaint is that udp latency is 2x-3x better than rds-tcp for a
512 byte req, 8K resp that is typical for DB workloads. I'm still 
investigating)

>From the TCP standpoint of rds-tcp, we have a many-one mapping: 
multiple RDS sockets funneling to a single tcp connection, sharing
a single congestion state-machine.

I dont know if this is a "poorly designed application", I'm sure
its not perfect, but we have a ton of Oracle clustering s/w that's
already doing this with IB, so extending this with rds-tcp made
sense for us at this point.

--Sowmini
