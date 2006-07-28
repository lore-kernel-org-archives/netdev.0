From: David Miller <davem@davemloft.net>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Thu, 27 Jul 2006 18:34:15 -0700 (PDT)
Message-ID: <20060727.183415.104032934.davem@davemloft.net>
References: <44C8B0B8.2010408@miyazawa.org>
	<E1G6Fic-0005py-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14786
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750907AbWG1BeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Jul 2006 21:34:18 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 28 Jul 2006 09:56:42 +1000

> Kazunori Miyazawa <kazunori@miyazawa.org> wrote:
> > 
> > I'm interested in the approach. And I have a couple of comments.
> > I think DAD and ND are time critical operations.
> > Can the daemons process with confirming to the specs.
> > even if it were swapped out?
> > Can we prevent the oom killer from killing the daemons?
> 
> These are valid concerns.  However, if we can have things like ntpd
> live in user-space without causing nuisance, then addrconf should be
> fine as well.

I have severe doubts actually in this area.  And I have practical
experience to back up these doubts in this specific case.

If you'll remember, quite some time ago, I tried to move all the ipv6
interface address addition and removal out of software interrupt
context.  The higher level goal of this work was to move the addrconf
locking over to RCU, which would fix several races and bugs.

Just moving the ipv6 address add/delete out of software interrupt
context broke the TAHI and other ipv6 testsuites.

The reason was simple.  Consider a simple test case that emits an
NDISC packet that should cause an interface address to be added, and
then it sends a packet which makes sure that host responds to that
address.  We have those two packets in our queue, as packet "A" and
"B".

If we process these in sequence in software interrupt, everything
is fine.  Processing of "A" will add the address, and the test
ping packet "B" will respond properly.

If you defer "A", everything breaks and the test packet "B" will
get processed first and not work.

As a secondary reason not to even consider this, it's in the kernel
already and therefore it is totally impractical to try and remove it.
When considering new protocols or features, the "user vs.  kernel"
argument is something to validly consider.  But when it's already
there, it will have to live there basically for eternity.  It is not
like some arbitrary internal kernel module symbol or interface we
can deprecate over a 6 month period or something like that.
