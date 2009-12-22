From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Deadlock in IPv6 code while garbage collection on the rwlock
 protecting the routing tree.
Date: Tue, 22 Dec 2009 14:36:38 -0800
Message-ID: <20091222143638.37513a94@nehalam>
References: <4D35478224365146822AE9E3AD4A26660E89A49E@exchtewks3.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"Johnson, David" <djohnson@starentnetworks.com>
To: "Akkipeddi, Srinivas" <sakkiped@starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59243 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753056AbZLVWhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Dec 2009 17:37:09 -0500
In-Reply-To: <4D35478224365146822AE9E3AD4A26660E89A49E@exchtewks3.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Dec 2009 16:57:05 -0500
"Akkipeddi, Srinivas" <sakkiped@starentnetworks.com> wrote:

> I came across a deadlock scenario in the latest IPv6 code. I am trying
> to fix this and any inputs are really appreciated. 
> 
> The deadlock happens when ROUTER-PREF is configured. This happens when
> trying to do a write_lock_bh on the rwlock protecting the routing tree
> during garbage collection.
> 
> The routing tree is read protected (read_lock_bh(&table->tb6_lock))
> using the rwlock when performing a ip6_route_input or  ip6_route_output
> ( "ip6_pol_route"). During route selection (rt6_select), if a neighbor
> solicit is sent (ndisc_send_ns), a dst_entry is allocated
> (icmp6_dst_alloc calls dst_alloc). 
> The garbage collection (fib6_run_gc) will be triggered if the number of
> dst-entries is more than the threshold (dst_alloc). During garbage
> collection, all the routing trees are cleaned up (fib6_clean_all). Here
> we try to take write protect each routing tree (
> write_lock_bh(&table->tb6_lock)). But one of the trees is already read
> protected. 
> 
> The garbage collection is anyways triggered from "icmp6_dst_alloc" with
> the call to fib6_force_start_gc. Since it is triggered, we might not
> want to call the "fib6_run_gc" from dst_alloc for this case but there is
> no way to figure this out in the "dst_alloc" routine.

Might just be easier to convert to spinlock and RCU.

-- 
