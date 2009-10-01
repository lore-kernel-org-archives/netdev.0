From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFCv4 PATCH 2/2] net: Allow protocols to provide an
	unlocked_recvmsg socket method
Date: Thu, 1 Oct 2009 12:03:43 -0300
Message-ID: <20091001150343.GU3361@ghostprotocols.net>
References: <20090916170745.GD7699@ghostprotocols.net> <9b2db90b0909170709n400859c6q13514b315970dde9@mail.gmail.com> <20090917212113.GC3691@ghostprotocols.net> <20090917215344.GE3691@ghostprotocols.net> <20090923000925.GA6011@ghostprotocols.net> <9b2db90b0909222123x7e547210p5755adf9f8ae875f@mail.gmail.com> <20090923043813.GA6464@ghostprotocols.net> <9b2db90b0910010249h182bf5d4sc7fdaea9e1345720@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List
	<netdev@vger.kernel.org>, Ziv Ayalon <ziv@final.co.il>
To: Nir Tzachar <nir.tzachar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754036AbZJAPDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 11:03:48 -0400
Content-Disposition: inline
In-Reply-To: <9b2db90b0910010249h182bf5d4sc7fdaea9e1345720@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Oct 01, 2009 at 11:49:39AM +0200, Nir Tzachar escreveu:
> Hi Arnaldo
> 
> I have repeated the tests using net-next on top of linus' git tree (I
> hope I got it right..) and the patches you sent me. Things did not get
> better, and in most cases were even worse; the recvmmsg parts
> distinctly showed better throughput, but the latency has more than
> doubled.

Interesting... Now the socket lock is held in recvmmsg over all of
udp_recvmmsg for the batch size while when not using unlocked_recvmmsg,
so I think one needs to carefully set the timeout parameter. Perhaps
we'll need to do something like tcp_rcvmmsg does, that is, to call
release_sock + lock_sock to process the backlog in the middle of a
recvmmsg call.
 
> The simplest test of using a batch size of 1 results with recvmmsg's
> latency over 1000 micro, while regular recvmsg is around 450 micro.
> (note that to use 1 packet there is a small bug in the reg_recv which
> needs to be fixed. Namely, change ret = -1 to ret = 0). On the
> previous system config -- part 0001 of the patch, on top of 2.6.31 --
> the latency of a single packet batch is 370 micro.
> 
> So, there seems to be a regression with the kernel tree I am using, or
> with part 0002 of the path. I'll try running the net-next with only
> part 1 of the patch and report.

Yeah, trying with only part 0001 should get you back to the previous
results, but try using it in nonblocking mode and tweaking the timeout
parameter in recvmmsg.

- Arnaldo
