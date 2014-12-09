From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: use jhash as hashfn for rhashtable
Date: Tue, 09 Dec 2014 14:38:29 -0500 (EST)
Message-ID: <20141209.143829.477482216978677919.davem@davemloft.net>
References: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au, tgraf@suug.ch,
	hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbaLITic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:38:32 -0500
In-Reply-To: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon,  8 Dec 2014 17:30:30 +0100

> For netlink, we shouldn't be using arch_fast_hash() as a hashing
> discipline, but rather jhash() instead.
> 
> Since netlink sockets can be opened by any user, a local attacker
> would be able to easily create collisions with the DPDK-derived
> arch_fast_hash(), which trades off performance for security by
> using crc32 CPU instructions on x86_64.
> 
> While it might have a legimite use case in other places, it should
> be avoided in netlink context, though. As rhashtable's API is very
> flexible, we could later on still decide on other hashing disciplines,
> if legitimate.
> 
> Reference: http://thread.gmane.org/gmane.linux.kernel/1844123
> Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU protected hash table")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

I think I've seen enough of this.

First of all, you've left all of the example initializers in the
rhashtable implementation recommending to use arch_fast_hash.

Secondly, after this, openvswitch (and nfsd, ugh) are the only users
remaining.   Even though there have been claims that using this
doesn't expose to openvswitch to being hash attackable, I'm still
not entirely convinced that an attacker cannot hurt performance
of an OVS node as a result of this.

I think this whole scheme should be reverted, whatever cycles
openvswitch gains by using crc32c instructions is far outweighed
by the confusion this has caused and all of this infrastructure
created for just one or two users.

Someone send me a patch to revert all of the arch_fast_hash
stuff, and every reference thereof, or else I'll do it myself.

Thanks.
