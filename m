From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFCv4 PATCH 2/2] net: Allow protocols to provide an
	unlocked_recvmsg socket method
Date: Thu, 17 Sep 2009 18:21:13 -0300
Message-ID: <20090917212113.GC3691@ghostprotocols.net>
References: <20090916170745.GD7699@ghostprotocols.net> <9b2db90b0909170709n400859c6q13514b315970dde9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>,
	Caitlin Bestler <caitlin.bestler@gmail.com>,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Nivedita Singhvi <niv@us.ibm.com>,
	Paul Moore <paul.moore@hp.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	Steven Whitehouse <steve@chygwyn.com>,
	Ziv Ayalon <zivayalon@gmail.com>
To: Nir Tzachar <nir.tzachar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17133 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205AbZIQVVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Sep 2009 17:21:46 -0400
Content-Disposition: inline
In-Reply-To: <9b2db90b0909170709n400859c6q13514b315970dde9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Sep 17, 2009 at 05:09:19PM +0300, Nir Tzachar escreveu:
> Hello.
> 
> Below are some test results with the patch (only part 1, as I did not
> manage to apply part 2).

I forgot to mention that the patches were made against DaveM's
net-next-2.6 tree at:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6

If you have a linux-2.6 git tree, just do:

cd linux-2.6
git remote add net-next git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
git branch -b net-next-recvmmsg net-next/master

And you should be able to apply the two patches cleanly.

> The test application is attached below, and works as follows:
> 
> I set out to measure the latency which can be saved by this patch, and
> the application is designed accordingly. It is composed of three
> parts: a producer, which time-stamps packets and sends them as fast as
> possible, a mirror, which receives messages and bounces them to a
> remote destination and finally, a consumer, which receives messages as
> fast as possible and measures latency and throughout.
> 
> Both the produce and consumer are executed on the same host and the
> mirror on a remote host. Both hosts are running linux 2.6.31 with v4
> of the patch (but, as I said before, only part 1, with the unlocked_*
> stuff). All processes are executed under SCHED_FIFO. Both hosts are

Here is the problem, the patch, as mentioned above, was made against
net-next-2.6.

I'll rework the 2nd patch so that you can test with both.

> connected by a switched 1G Ethernet network. The mirror is executed on
> a 8-core nahelem beast, and the producer and consumer on my desktop,
> which is a quad. /proc/cpuinfo and lspcis and .configs can be supplied
> if needed. Network cards are Intel Corporation 82566DM-2 Gigabit
> Network and Broadcom Corporation NetXtreme II BCM5709 Gigabit
> Ethernet.
> 
> The results (which follow below) clearly show the advantages of using
> recvmmsg over recvmsg both latency wise and throughput wise. The
> addition of a sendmmsg would also have a huge impact, IMO.

Yeah, there are even some smarts that can be done in the sendmmsg case,
like avoiding passing the same payload to multiple destinations, just
marking the mmsghdr size with zero that would thus mean "use the latest
non-zero sized payload".

> Receiving batches of 30 packets, each of 1024 bytes, results with no
> latency improvements, but with a ~55% throughput improvement, from 72
> megabytes per second to  111. Repeating the same test, but with
> batches of 3000, displays the same behaviour. The more interesting
> result (to me, at least :) is when using small packets. Sending
> packets of size 100 and receiving in batches of 30  gives 470 micro
> latency and 244669 packets per second. On the other hand, without
> recvmmsg we get 750 micro latency and 210818 packets per second. A
> huge improvement here.
> 
> I think that with a bit more tinkering we can even stretch these results a bit.

I guess so too, with luck I'll be able to test this over a 10 Gbit/s
link today, will use my and your test cases.

Thanks a lot!
 
- Arnaldo
