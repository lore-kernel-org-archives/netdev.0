From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 28 Oct 2015 06:24:32 -0700
Message-ID: <1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201510221824.t9MIOp6n003978@room101.nl.oracle.com>
	 <20151022190701.GV22011@ZenIV.linux.org.uk>
	 <201510221951.t9MJp5LC005892@room101.nl.oracle.com>
	 <20151022215741.GW22011@ZenIV.linux.org.uk>
	 <201510230952.t9N9qYZJ021998@room101.nl.oracle.com>
	 <20151024023054.GZ22011@ZenIV.linux.org.uk>
	 <201510270908.t9R9873a001683@room101.nl.oracle.com>
	 <562F577E.6000901@oracle.com> <20151027231702.GA22011@ZenIV.linux.org.uk>
	 <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028123543.GB22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36755 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbbJ1NYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 09:24:34 -0400
In-Reply-To: <20151028123543.GB22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-10-28 at 12:35 +0000, Al Viro wrote:
> [Linus and Dave added, Solaris and NetBSD folks dropped from Cc]
> 
> On Tue, Oct 27, 2015 at 05:13:56PM -0700, Eric Dumazet wrote:
> > On Tue, 2015-10-27 at 23:17 +0000, Al Viro wrote:
> > 
> > > 	* [Linux-specific aside] our __alloc_fd() can degrade quite badly
> > > with some use patterns.  The cacheline pingpong in the bitmap is probably
> > > inevitable, unless we accept considerably heavier memory footprint,
> > > but we also have a case when alloc_fd() takes O(n) and it's _not_ hard
> > > to trigger - close(3);open(...); will have the next open() after that
> > > scanning the entire in-use bitmap.  I think I see a way to improve it
> > > without slowing the normal case down, but I'll need to experiment a
> > > bit before I post patches.  Anybody with examples of real-world loads
> > > that make our descriptor allocator to degrade is very welcome to post
> > > the reproducers...
> > 
> > Well, I do have real-world loads, but quite hard to setup in a lab :(
> > 
> > Note that we also hit the 'struct cred'->usage refcount for every
> > open()/close()/sock_alloc(), and simply moving uid/gid out of the first
> > cache line really helps, as current_fsuid() and current_fsgid() no
> > longer forces a pingpong.
> > 
> > I moved seldom used fields on the first cache line, so that overall
> > memory usage did not change (192 bytes on 64 bit arches)
> 
> [snip]
> 
> Makes sense, but there's a funny thing about that refcount - the part
> coming from ->f_cred is the most frequently changed *and* almost all
> places using ->f_cred are just looking at its fields and do not manipulate
> its refcount.  The only exception (do_process_acct()) is easy to eliminate
> just by storing a separate reference to the current creds of acct(2) caller
> and using it instead of looking at ->f_cred.  What's more, the place where we
> grab what will be ->f_cred is guaranteed to have a non-f_cred reference *and*
> most of the time such a reference is there for dropping ->f_cred (in
> file_free()/file_free_rcu()).
> 
> With that change in kernel/acct.c done, we could do the following:
> 	a) split the cred refcount into the normal and percpu parts and
> add a spinlock in there.
> 	b) have put_cred() do this:
> 		if (atomic_dec_and_test(&cred->usage)) {
> 			this_cpu_add(&cred->f_cred_usage, 1);
> 			call_rcu(&cred->rcu, put_f_cred_rcu);
> 		}
> 	c) have get_empty_filp() increment current_cred ->f_cred_usage with
> this_cpu_add()
> 	d) have file_free() do
> 		percpu_counter_dec(&nr_files);
> 		rcu_read_lock();
> 		if (likely(atomic_read(&f->f_cred->usage))) {
> 			this_cpu_add(&f->f_cred->f_cred_usage, -1);
> 			rcu_read_unlock();
> 			call_rcu(&f->f_u.fu_rcuhead, file_free_rcu_light);
> 		} else {
> 			rcu_read_unlock();
> 			call_rcu(&f->f_u.fu_rcuhead, file_free_rcu);
> 		}
> file_free_rcu() being
> static void file_free_rcu(struct rcu_head *head)
> {
>         struct file *f = container_of(head, struct file, f_u.fu_rcuhead);
>         put_f_cred(&f->f_cred->rcu);
>         kmem_cache_free(filp_cachep, f);
> }
> and file_free_rcu_light() - the same sans put_f_cred();
> 
> with put_f_cred() doing
> 	spin_lock cred->lock
> 	this_cpu_add(&cred->f_cred_usage, -1);
> 	find the sum of cred->f_cred_usage
> 	spin_unlock cred->lock
> 	if the sum has not reached 0
> 		return
> 	current put_cred_rcu(cred)
> 
> IOW, let's try to get rid of cross-cpu stores in ->f_cred grabbing and
> (most of) ->f_cred dropping.
> 
> Note that there are two paths leading to put_f_cred() in the above - via
> call_rcu() on &cred->rcu and from file_free_rcu() called via call_rcu() on
> &f->f_u.fu_rcuhead.  Both are RCU-delayed and they can happen in parallel -
> different rcu_head are used.
> 
> atomic_read() check in file_free() might give false positives if it comes
> just before put_cred() on another CPU kills the last non-f_cred reference.
> It's not a problem, since put_f_cred() from that put_cred() won't be
> executed until we drop rcu_read_lock(), so we can safely decrement the
> cred->f_cred_usage without cred->lock here (and we are guaranteed that we won't
> be dropping the last of that - the same put_cred() would've incremented
> ->f_cred_usage).
> 
> Does anybody see problems with that approach?  I'm going to grab some sleep
> (only a couple of hours so far tonight ;-/), will cook an incremental to Eric's
> field-reordering patch when I get up...

Before I take a deep look at your suggestion, are you sure plain use of
include/linux/percpu-refcount.h infra is not possible for struct cred ?

Thanks !
