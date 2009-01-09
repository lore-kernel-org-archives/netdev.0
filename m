From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 09 Jan 2009 00:30:21 -0500
Message-ID: <4966E0ED.9090905@pobox.com>
References: <20090109041952.GA12087@gondor.apana.org.au> <4966DABD.1000203@pobox.com> <20090109051500.GA12836@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44270 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbZAIFab (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 00:30:31 -0500
In-Reply-To: <20090109051500.GA12836@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Jan 09, 2009 at 12:03:57AM -0500, Jeff Garzik wrote:
>> I think you misunderstand.  You don't have touch any drivers at all...  
>> see attached demonstration patch.
>>
>> The more general point is that it is silly to add two ethtool ioctls  
>> each time you want to twiddle a single boolean flag (whatever that flag  
>> may be, generic or driver-specific or whatnot).
>>
>> If you still desire separation from ->{get,set}_flags() ops, then at  
>> least create an ETHTOOL_[GS]STACK_FLAGS.
> 
> OK, however I'm still not convinced that this is a good idea.
> First of all we don't have a shortage in the ethtool name space,
> we've only used up two hex digits worth of a 32-bit integer field.
> 
> More importantly, making multiple bit changes at the same time
> may create semantic nightmares in future.
> 
> For example, imagine if we started out with this generic flag
> function and TX checksum offload, SG, TSO were done using it.
> Now the user issues a request changing all of these bits, we'd
> then have to either validate it for contradictory settings, or
> devise some ad-hoc ordering in which the settings are applied.

Actually it's just the opposite -- _the_ most common complaint from 
users and driver developers of the ethtool interface, over the years, 
has been that there is no way to collect all the modifications and then 
commit it to hardware all in one go.

Each new ethtool command added often winds up pausing and resetting the 
hardware completely, and ETHTOOL_SGRO is no exception.

Now consider what happens when you have a lot of settings to tweak... 
reset, reset, reset, reset, reset.  That's a lot of needless hardware 
banging.

If I could redesign everything from scratch, I would make the interface 
flexible enough to input a list of changed settings, and then commit 
those all at once.  Lists of flags make that possible to a limited 
extent, at least.


> This just seems to be unnecessary penny-pinching that doesn't
> save much but may end up costing us down the road.

This sort of interface was added because the current "multi-reset" 
interface has already cost us.

A multi-flag interface is also more flexible and future-proof, as you 
can deploy new flags without having to update any userland utility... 
ethtool can permit input of the raw value as well as a more refined 
command interface.

That's another facet of the driver-private flag interfaces, too.  The 
ETHTOOL_[GS]PFLAGS interface is flexible enough to permit a wide variety 
of feature flags to be exported by various drivers; userland ethtool 
automatically supports all flags a driver supports, and never needs 
updating even if the list of supported driver-private flags change.

	Jeff



