From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 16:08:19 +1100
Message-ID: <20150121050819.GA23062@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:33368 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbbAUFIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 00:08:52 -0500
Content-Disposition: inline
In-Reply-To: <20150120153556.GJ20315@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 03:35:56PM +0000, Thomas Graf wrote:
> On 01/20/15 at 03:21pm, Patrick McHardy wrote:
> > I think its preferrable to make the need to handle NETLINK_F_DUMP_INTR
> > as noticable as possible and not hide it. Silent failure is the worst
> > kind of failure.
> 
> I agree to that. The point here is to avoid unnecessary use of
> NETLINK_F_DUMP_INTR if all entries fit into a single message buffer.

OK I think I have a solution for you guys.  But first you'll need to
wait for me to undo the nulls stuff so I can steal that bit which
is central to my solution.

Essentially I need a bit to indicate an entry in the bucket chain
should be skipped, either because it has just been removed or that
it is a walker entry (see xfrm_state_walk).

The way it'll work then is exactly the same as xfrm_state_walk,
except that the linked list is broken up into individual buckets.

Of course we'll still need to postpone resizes (and rehashes which
is what my work is about) during a walk but I think that's a fair
price to pay.

This also means handling insertion failures but I think that
should be acceptable if we make it based on a configurable maximum
chain length along with forced resize/rehash where possible.

Note that this can be made optional, i.e., if the user can afford
memory to do their own walking (e.g., xfrm_state), then none of
this needs to happen and it'll just work as it does now.  IOW if
you don't use this special rhashtable walk function then you're
not affected.

Thoughts?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
