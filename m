From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 22:13:38 +0000
Message-ID: <20150323221338.GE20752@casper.infradead.org>
References: <20150322121755.GH1185@casper.infradead.org>
 <20150323000954.GB9507@gondor.apana.org.au>
 <20150323083319.GB16023@casper.infradead.org>
 <20150323.124434.1526209682898584518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
	kaber@trash.net, josh@joshtriplett.org, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59453 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbbCWWNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 18:13:39 -0400
Content-Disposition: inline
In-Reply-To: <20150323.124434.1526209682898584518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/23/15 at 12:44pm, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Mon, 23 Mar 2015 08:33:19 +0000
> 
> > I don't get why almost nobody would want shrinking. I agree that for
> > tables like TCP hash tables, once you have grown you want to keep that
> > table size because the load is likely to come back. But we will also
> > have lots of users such as the Netlink socket with a table per protocol
> > where not shrinking results in giving the user the ability to waste
> > memory indefinitely for no gain.
> 
> The user can't do this with TCP?  Why is netlink only susceptible?

You are right. Any table that doesn't shrink will eventually waste
memory. I used TCP vs Netlink because I believe it represents the
difference in priorities very well. TCP may go 0..1M flows within
a fraction of a second so if you've seen that many flows before you
might get hit again and you prioritize the "being ready" to handle it
higher than eventually wasting the memory indefinitely.

Whereas with Netlink it seems (glad to be proven wrong) that the
need for instant growth is lesser as it takes time to create 1M
sockets across many PIDs. So we gain something by releasing the
resources if not needed.

> The only plausible argument for shrinking I've ever heard of is the
> nft_hash case, and there that code can _explicitly_ ask for a shrink
> after it has made a major table modification.
> 
> That puts all of the smarts for when to shrink where the knowledge
> resides, and in this case that's the user.

My argument pro automatic shrinking is simplicity. I'm absolutely
fine with disabling it by default and to require enabling it
explicitly.
