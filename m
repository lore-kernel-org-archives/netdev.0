From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 12:31:23 +0300
Message-ID: <20090131093123.GA28151@ioremap.net>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com> <20090130225113.GA13977@ioremap.net> <20090130185224.214b3a59@extreme> <20090131083724.GB26897@ioremap.net> <49841738.7050605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intermatrixgroup.ru ([195.178.208.66]:36187 "EHLO
	tservice.net.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbZAaJbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 04:31:37 -0500
Content-Disposition: inline
In-Reply-To: <49841738.7050605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 31, 2009 at 10:17:44AM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > getaddrinfo() returns list of addresses and IPv6 was the first one iirc.
> > Previously it bailed out, but with my change it will try again without
> > reason for doing this. With the patch I sent based on Eric's observation
> > things should be fine.
> 
> Problem is your patch is wrong Evgeniy, please think about it litle bit more
> and resubmit it. 

No, patch should be ok. And its part which moves bsockets around was
added because of your complaints, that it is written into read-mostly
cache line. It is not a fix and has nothing with the problem at all.

> Take the time to run this $0.02 program, before and after your upcoming fix :

It is not a fix, but enhancement, which really has nothing with the bug
in question :)
Fix is to return an error if socket binding does not use the heuristic.

> offset of bsockets being 0x18 or 0x20 is same result : bad because in
> same cache line than ehash, ehash_locks, ehash_size, ehash_locks_mask,
> bhash, bhash_size, unless your cpu is a Pentium.

Attached patch makes difference, I'm curious if it ever make any
difference in the benchmarks.

> Also, I suggest you change bsockets to something more appropriate, eg a
> percpu counter.

I thought on that first, but found that looping over every cpu and
summing the total number of allocated/freed sockets will have noticebly
bigger overhead than having loosely maintaned number of sockets.

For the reference. This patch has nothing with the bug we discuss here,
the proper patch (without need to move bsockets around) was sent
earlier, which forces port selection codepath to return error when new
selection heuristic is not used.

--- ./include/net/inet_hashtables.h.orig	2009-01-31 12:27:41.000000000 +0300
+++ ./include/net/inet_hashtables.h	2009-01-31 12:28:15.000000000 +0300
@@ -134,7 +134,6 @@
 	struct inet_bind_hashbucket	*bhash;
 
 	unsigned int			bhash_size;
-	int				bsockets;
 
 	struct kmem_cache		*bind_bucket_cachep;
 
@@ -150,6 +149,8 @@
 	 */
 	struct inet_listen_hashbucket	listening_hash[INET_LHTABLE_SIZE]
 					____cacheline_aligned_in_smp;
+	
+	int				bsockets ____cacheline_aligned_in_smp;
 
 };
 

-- 
	Evgeniy Polyakov
