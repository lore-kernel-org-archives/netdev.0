From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 10:15:12 +0000
Message-ID: <20150127101512.GE22262@casper.infradead.org>
References: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
 <20150126224216.GA30551@gondor.apana.org.au>
 <20150126233100.GA31108@gondor.apana.org.au>
 <20150127094541.GC22262@casper.infradead.org>
 <20150127095454.GA2695@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	ying.xue@windriver.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37448 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbbA0KPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 05:15:14 -0500
Content-Disposition: inline
In-Reply-To: <20150127095454.GA2695@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/15 at 08:54pm, Herbert Xu wrote:
> On Tue, Jan 27, 2015 at 09:45:41AM +0000, Thomas Graf wrote:
> >
> > OK. I'll wait for your netfilter approach before posting NLM_F_INTR
> > patches.
> 
> Why would we still need the INTR stuff given that Dave has asked
> for this to be done outside of rhashtable?

Because libraries like libnl already handle this transparently for
various user space apps. Those apps are not even aware of the problem
and always get a consistent dump if the kernel implements INTR.

> What I'm planning on doing right now is to divide rhashtable users
> into two camps, lockless insert/removal vs. locked insert/removal.
> netfilter will obviously fall into the latter camp.
> 
> For those with locked insert/removal I will make resizing/rehashing
> synchronous since there is zero benefit from doing it in a separate
> thread.

Because making it synchronous does not help the Netlink dump problem
at all, see below.

Also, a sync resize causes a random inserts/removal to take a lot
longer. This leads to less predictable insert/removal times. I have
no objection to offering both sync and async resizing as long as the
choice of balance is configurable.

> Once that is done you can then easily walk the table by just holding
> the lock, which is what netfilter does today.

How? Do you want to hold the mutex while the user is reading? I don't
see how to achieve consistency with locking without introducing a ton
of complexity and attackable behaviour like user space being able to
delay inserts. If at all this only seems acceptable for privileged
users.

My vote is to rely on the proven INTR flag and optionally restart the
dump if user space did not indicate that INTR is supported as Patrick
suggested.
