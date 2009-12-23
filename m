From: Dave Johnson <djohnson@starentnetworks.com>
Subject: Re: Deadlock in IPv6 code while garbage collection on the rwlock
 protecting the routing tree.
Date: Wed, 23 Dec 2009 12:44:31 -0500
Message-ID: <19250.22271.876068.511246@zeus.eng.starentnetworks.com>
References: <4D35478224365146822AE9E3AD4A26660E89A49E@exchtewks3.starentnetworks.com>
	<20091222143638.37513a94@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Akkipeddi, Srinivas" <sakkiped@starentnetworks.com>,
	<netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:50796 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989AbZLWSH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 13:07:58 -0500
In-Reply-To: <20091222143638.37513a94@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger writes:
> On Tue, 22 Dec 2009 16:57:05 -0500
> "Akkipeddi, Srinivas" <sakkiped@starentnetworks.com> wrote:
> 
> > I came across a deadlock scenario in the latest IPv6 code. I am trying
> > to fix this and any inputs are really appreciated. 
> > 
> > The deadlock happens when ROUTER-PREF is configured. This happens when
> > trying to do a write_lock_bh on the rwlock protecting the routing tree
> > during garbage collection.
> > 
> > The routing tree is read protected (read_lock_bh(&table->tb6_lock))
> > using the rwlock when performing a ip6_route_input or  ip6_route_output
> > ( "ip6_pol_route"). During route selection (rt6_select), if a neighbor
> > solicit is sent (ndisc_send_ns), a dst_entry is allocated
> > (icmp6_dst_alloc calls dst_alloc). 
> > The garbage collection (fib6_run_gc) will be triggered if the number of
> > dst-entries is more than the threshold (dst_alloc). During garbage
> > collection, all the routing trees are cleaned up (fib6_clean_all). Here
> > we try to take write protect each routing tree (
> > write_lock_bh(&table->tb6_lock)). But one of the trees is already read
> > protected. 
> > 
> > The garbage collection is anyways triggered from "icmp6_dst_alloc" with
> > the call to fib6_force_start_gc. Since it is triggered, we might not
> > want to call the "fib6_run_gc" from dst_alloc for this case but there is
> > no way to figure this out in the "dst_alloc" routine.
> 
> Might just be easier to convert to spinlock and RCU.

I don't think that would help.  You would still have a writer
contained within a reader issue.  This would also likely involve quite
a bit of copying given the amount of data the existing rwlock is
protecting and how frequent write locks may be needed.

The syncronize_rcu() call would have to be done from another thread
otherwise it would just stall forever because it would have been
called from a code path that holds a rcu read lock.

The area of uncertainty about how to fix this is because of the large
number of paths into the garbage collection code, one of which we hit
and resulted in this writer within reader deadlock.

It seems like the garbage collection cannot be done from within this
path and should only be done from an isolated path where it is
guaranteed to be called from a reader-free source.

Another possibility is to change the garbage collection to use a write
try lock and just not garbage collect from any tables it can't obtain.

-- 
Dave Johnson
Starent Networks
