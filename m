From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash
 table
Date: Sat, 03 Nov 2007 16:23:37 -0700 (PDT)
Message-ID: <20071103.162337.83099185.davem@davemloft.net>
References: <4729A774.9030409@cosmosbay.com>
	<200711040018.15027.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, acme@redhat.com
To: ak@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36314
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757851AbXKCXXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 19:23:38 -0400
In-Reply-To: <200711040018.15027.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@suse.de>
Date: Sun, 4 Nov 2007 00:18:14 +0100

> On Thursday 01 November 2007 11:16:20 Eric Dumazet wrote:
> 
> Some quick comments:
> 
> > +#if defined(CONFIG_SMP) || defined(CONFIG_PROVE_LOCKING)
> > +/*
> > + * Instead of using one rwlock for each inet_ehash_bucket, we use a table of locks
> > + * The size of this table is a power of two and depends on the number of CPUS.
> > + */
> 
> This shouldn't be hard coded based on NR_CPUS, but be done on runtime
> based on num_possible_cpus(). This is better for kernels with a large
> NR_CPUS, but which typically run on much smaller systems (like 
> distribution kernels) 

I think this is a good idea.  Eric, could you make this change?

> Also the EHASH_LOCK_SZ == 0 special case is a little strange. Why did
> you add that?

He explained this in another reply, because ifdefs are ugly.

> And as a unrelated node have you tried converting the rwlocks 
> into normal spinlocks? spinlocks should be somewhat cheaper
> because they have less cache protocol overhead and with
> the huge thash tables in Linux the chain walks should be short
> anyways so not doing this in parallel is probably not a big issue.
> At some point I also had a crazy idea of using a special locking
> scheme that special cases the common case that a hash chain
> has only one member and doesn't take a look for that at all. 

I agree.

There was movement at one point to get rid of all rwlock's in the
kernel, I personally think they are pointless.  Any use that makes
"sense" is a case where the code should be rewritten to decrease the
lock hold time or convert to RCU.
