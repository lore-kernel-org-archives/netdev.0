From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 05 May 2006 11:31:08 +1000
Message-ID: <1146792668.7681.59.camel@localhost.localdomain>
References: <200604271331.37073.kelly@au.ibm.com>
	 <20060426.232501.119306252.davem@davemloft.net>
	 <200605041259.23204.kelly@au.ibm.com>
	 <20060504.162223.44735502.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kelly@au1.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:11995 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S1751507AbWEEBbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 21:31:41 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060504.162223.44735502.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-05-04 at 16:22 -0700, David S. Miller wrote:
> From: Kelly Daly <kelly@au1.ibm.com>
> Date: Thu, 4 May 2006 12:59:23 +1000
> 
> > We DID write an infrastructure to resolve this issue, although it is more 
> > complex than the dynamic descriptor scheme for userspace.  And we want to 
> > keep this simple - right?
> 
> Yes.
> 
> I wonder if it is possible to manage the buffer pool just like a SLAB
> cache to deal with the variable lifetimes.  The system has a natural
> "working set" size of networking buffers at a given point in time and
> even the default net channel can grow to accomodate that with some
> kind of limit.
> 
> This is kind of what I was alluding to in the past, in that we now
> have globals limits on system TCP socket memory when really what we
> want to do is have a set of global generic system packet memory
> limits.
> 
> These two things can tie in together.

Hi Dave,

	We kept a simple "used" bitmap, but to avoid the consumer touching it,
also put a "I am masquerading as an SKB" bit in the trailer, like so:

diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .16405-linux-2.6.17-rc3-git7/include/linux/skbuff.h .16405-linux-2.6.17-rc3-git7.updated/include/linux/skbuff.h
--- .16405-linux-2.6.17-rc3-git7/include/linux/skbuff.h	2006-05-03 22:07:14.000000000 +1000
+++ .16405-linux-2.6.17-rc3-git7.updated/include/linux/skbuff.h	2006-05-03 22:07:15.000000000 +1000
@@ -133,7 +133,8 @@ struct skb_frag_struct {
  */
 struct skb_shared_info {
 	atomic_t	dataref;
-	unsigned short	nr_frags;
+	unsigned short	nr_frags : 15;
+	unsigned int	chan_as_skb : 1;
 	unsigned short	tso_size;
 	unsigned short	tso_segs;
 	unsigned short  ufo_size;
diff -urpN --exclude TAGS -X /home/rusty/devel/kernel/kernel-patches/current-dontdiff --minimal .16405-linux-2.6.17-rc3-git7/net/core/skbuff.c .16405-linux-2.6.17-rc3-git7.updated/net/core/skbuff.c
--- .16405-linux-2.6.17-rc3-git7/net/core/skbuff.c	2006-05-03 22:07:14.000000000 +1000
+++ .16405-linux-2.6.17-rc3-git7.updated/net/core/skbuff.c	2006-05-03 22:07:15.000000000 +1000
@@ -289,6 +289,7 @@ struct sk_buff *skb_netchan_graft(struct
 	skb_shinfo(skb)->ufo_size = 0;
 	skb_shinfo(skb)->ip6_frag_id = 0;
 	skb_shinfo(skb)->frag_list = NULL;
+	skb_shinfo(skb)->chan_as_skb = 1;
 
 	return skb;
 }
@@ -328,7 +329,10 @@ void skb_release_data(struct sk_buff *sk
 		if (skb_shinfo(skb)->frag_list)
 			skb_drop_fraglist(skb);
 
-		kfree(skb->head);
+		if (skb_shinfo(skb)->chan_as_skb)
+			skb_shinfo(skb)->chan_as_skb = 0;
+		else
+			kfree(skb->head);
 	}
 }
 
Buffer allocation would be: find_first_bit, check that it's not actually
inside an skb, or otherwise find_next_bit.  Assuming most buffers do not
go down default channel, this is efficient.

Problems:
1) it's still not cache-friendly with producers on multiple CPUs.  We
could divide up the bitmap into per-cpu regions to try first to improve
cache behaviour.

2) In addition, we had every buffer one page large.  This isn't
sufficient for jumbo frames, and wasteful for ethernet.  So if we
statically assign descriptors -> buffers, we need to have multiple
sizes.

3) OTOH, if descriptor table is dynamic, we have cache issues again as
multiple people are writing to it, and it's not clear what we really
gain over direct pointers.

4) Grow/shrink can be done, but needs stop_machine, or maybe tricky RCU.

5) The killer for me: we can't use our scheme straight-to-userspace
anyway, since we can't trust the (user-writable) ringbuffer in deciding
what buffers to release.  Since we need to store this somewhere, we need
a test in netchannel_enqueue.  At which point, we might as well
translate to "descriptors" at that point, anyway (since descriptors are
only really needed for userspace).  Something like:

	tail = np->netchan_tail;
	if (tail == np->netchan_head)
		return -ENOMEM;

+	/* Write to userspace?  They can't deref ptr anyway. */
+	if (np->shadow_ring && !netchan_local_buf(bp)) {
+		np->shadow_ring[tail] = bp;
+		bp = (void *)-1;
+	}
	np->netchan_queue[tail++] = bp;
	if (tail == NET_CHANNEL_ENTRIES)

(We don't have local buffers yet, but I'm assuming we'll use v. low
pointers for them).  Userspace goes "desc number is in range, we can
access directly" or "desc number isn't, call into kernel to copy them
for us".

> So, are you still sure you want to do away with the descriptors for
> the default channel?  Is the scheme I have outlined above doable or
> is there some critical barrier or some complexity issue which makes
> it undesirable?

I think it's simpler to build global alloc limiters on what we have.
The slab already has the nice lifetime and cache-friendly properties we
want, so we just have to write the limiting code.  There's enough work
there to keep us busy 8)

Cheers,
Rusty.
-- 
 ccontrol: http://ozlabs.org/~rusty/ccontrol

