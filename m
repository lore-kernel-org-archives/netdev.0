From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] addition of a dropped packet notification service
Date: Tue, 24 Feb 2009 23:48:40 -0800 (PST)
Message-ID: <20090224.234840.93952093.davem@davemloft.net>
References: <20090206165736.295ec007@extreme>
	<20090207174931.GA10247@localhost.localdomain>
	<20090209102134.GA8492@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751540AbZBYHs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:48:59 -0500
In-Reply-To: <20090209102134.GA8492@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 9 Feb 2009 21:21:34 +1100

> On Sat, Feb 07, 2009 at 12:49:32PM -0500, Neil Horman wrote:
> >
> > Well, as I mentioned, its totally incomplete.  I only posted it, so that you
> > could see an exemplar of how I wanted to use tracepoints to dynamically
> > intercept various in kernel events so that I could gather drop notifications. Of
> > course several other tracepoints will be needed to capture other classes of drop
> > (IPv6 stats, arp queue overflows, qdisc drops, etc).
> 
> FWIW it sounds pretty reasonable to me.  Although I'm still unsure
> on what impact all these trace points will have on the maintainence
> of our source code.

It occurs to me that this kind of event tracking is more about
a negated test rather than a straight one.

It makes no sense to annotate all of the abnormal drop cases,
there are tons of those.

Rather it's easier to consolidate the normal cases.

Here's an idea that doesn't use tracepoints (I really don't like
them, to be honest):

1) Isolate the normal packet freeing contexts, have them call
   kfree_skb_clean() or something like that.

2) What remains are the abnormal drop cases.  They still call
   plain kfree_skb() which records __builtin_return_address(0)
   and builds a hash table of counts call sites.

Then you just dump the table via some user visible interface.
