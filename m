From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] INET : removes per bucket rwlock in tcp/dccp ehash table
Date: Sun, 4 Nov 2007 00:18:14 +0100
Message-ID: <200711040018.15027.ak@suse.de>
References: <4729A774.9030409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:42653 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756697AbXKCXSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 19:18:18 -0400
In-Reply-To: <4729A774.9030409@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 01 November 2007 11:16:20 Eric Dumazet wrote:

Looks good from a quick look. Thanks for doing that work.

Some quick comments:

> +#if defined(CONFIG_SMP) || defined(CONFIG_PROVE_LOCKING)
> +/*
> + * Instead of using one rwlock for each inet_ehash_bucket, we use a table of locks
> + * The size of this table is a power of two and depends on the number of CPUS.
> + */

This shouldn't be hard coded based on NR_CPUS, but be done on runtime
based on num_possible_cpus(). This is better for kernels with a large
NR_CPUS, but which typically run on much smaller systems (like 
distribution kernels) 

Also the EHASH_LOCK_SZ == 0 special case is a little strange. Why did
you add that?

And as a unrelated node have you tried converting the rwlocks 
into normal spinlocks? spinlocks should be somewhat cheaper
because they have less cache protocol overhead and with
the huge thash tables in Linux the chain walks should be short
anyways so not doing this in parallel is probably not a big issue.
At some point I also had a crazy idea of using a special locking
scheme that special cases the common case that a hash chain
has only one member and doesn't take a look for that at all. 

-Andi

