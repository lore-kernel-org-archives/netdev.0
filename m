From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v5 3/3] igmp: convert RTNL lock to a spinlock
Date: Sat, 15 Jun 2013 16:12:22 +0800
Message-ID: <1371283942.23997.8.camel@cr0>
References: <1371282069-26893-1-git-send-email-amwang@redhat.com>
	 <1371282069-26893-3-git-send-email-amwang@redhat.com>
	 <1371282946.3252.148.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44704 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622Ab3FOIMd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jun 2013 04:12:33 -0400
In-Reply-To: <1371282946.3252.148.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-15 at 00:55 -0700, Eric Dumazet wrote:
> On Sat, 2013-06-15 at 15:41 +0800, Cong Wang wrote:
> > From: Cong Wang <amwang@redhat.com>
> > 
> > It is not necessary to hold RTNL lock to protect mc_list,
> > at least IPv6 mcast is using a local spinlock, IPv4 can do
> > this too. This patch converts RTNL lock+RCU to spinlock+RCU.
> > 
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> > ---
> > v5: no change
> > v4: rebased on the latest net-next.
> > v3: remove useless synchronize_rcu().
> 
> Really I think this patch is not needed and way too risky.
> 
> I already said that you added bugs, and you keep posting same bugs ?
> 
> ip_mc_join_group() seems buggy after your v5 patch ?

I really missed this in your previous reply, sorry.

I assume you mean ip_mc_inc_group(in_dev, addr), yes.

> 
> Let me repeat : fast path already uses RCU.
> 
> The writer parts are slow path, using a mutex is much better than a
> spinlock as a mutex allows the writer to use GFP_KERNEL allocations, and
> eventually be preempted/scheduled.

I _did_ try to replace spinlock with mutex, but apparently mutex_lock()
can't be called with rcu_read_lock() held, which is the case in
ip_mc_drop_socket().

BTW, if you think this is a problem, IPv6 has the same problem, since it
uses rwlock.

Thanks.
