From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Sat, 31 Jan 2009 01:51:14 +0300
Message-ID: <20090130225113.GA13977@ioremap.net>
References: <20090130112125.GA9908@ioremap.net> <20090130125337.GA7155@gondor.apana.org.au> <20090130095737.103edbff@extreme> <498349F7.4050300@cosmosbay.com> <20090130215008.GB12210@ioremap.net> <49837F7E.90306@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, berrange@redhat.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:56670 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754031AbZA3WvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 17:51:17 -0500
Content-Disposition: inline
In-Reply-To: <49837F7E.90306@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 30, 2009 at 11:30:22PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> > It should contain rough number of sockets, there is no need to be very
> > precise because of this hueristic.
> 
> Denying there is a bug is... well... I dont know what to say.
> 
> I wonder why we still use atomic_t all over the kernel.

It is not a bug. It is not supposed to be precise. At all.
I implemented a simple heuristic on when diferent bind port selection
algorithm should start: roughly when number of opened sockets equals to
some predefined value (sysctl at the moment, but it could be 64k or
anything else), so if that number is loosely maintained and does not
precisely corresponds to the number of sockets, it is not a problem.

You also saw 'again' lavel which has magic 5 number - it is another
heuristic - since lock is dropped atfer the bind bucket check, and we
selected it, it is possible that non-reuse socket will be added into the
bucket, so we will have to rerun the process again. I limited this to
the 5 attempts only, since it is better than what we have right now (I
never saw more than 2 attempts needed in the tests), when number of
bound sockets does not exceed 64k.

> > I used free alignment slot so that socket structure would not be
> > icreased.
> 
> Are you kidding ?
> 
> bsockets is not part of socket structure, but part of "struct inet_hashinfo",

Yes, I mistyped.

> shared by all cpus and accessed several thousand times per second on many
> machines.
> 
> Please read the comment three lines after 'the free alignemnt slot'
> you chose.... You just introduced one write on a cache line
> that is supposed to *not* be written.

I have no objection on moving this anywhere at the end of the structure
like after bind_bucket_cachep.

--- ./include/net/inet_hashtables.h~	2009-01-19 22:19:11.000000000 +0300
+++ ./include/net/inet_hashtables.h	2009-01-31 01:48:21.000000000 +0300
@@ -134,7 +134,6 @@
 	struct inet_bind_hashbucket	*bhash;
 
 	unsigned int			bhash_size;
-	int				bsockets;
 
 	struct kmem_cache		*bind_bucket_cachep;
 
@@ -148,6 +147,7 @@
 	 * table where wildcard'd TCP sockets can exist.  Hash function here
 	 * is just local port number.
 	 */
+	int				bsockets;
 	struct inet_listen_hashbucket	listening_hash[INET_LHTABLE_SIZE]
 					____cacheline_aligned_in_smp;
 
--- ./net/ipv4/inet_connection_sock.c~	2009-01-19 22:21:08.000000000 +0300
+++ ./net/ipv4/inet_connection_sock.c	2009-01-31 01:50:20.000000000 +0300
@@ -172,7 +172,8 @@
 		} else {
 			ret = 1;
 			if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb)) {
-				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN && --attempts >= 0) {
+				if (sk->sk_reuse && sk->sk_state != TCP_LISTEN &&
+					smallest_size != -1 && --attempts >= 0) {
 					spin_unlock(&head->lock);
 					goto again;
 				}


-- 
	Evgeniy Polyakov
