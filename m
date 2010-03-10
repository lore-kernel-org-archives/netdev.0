From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 14:39:29 +0100
Message-ID: <201003101439.30185.arnd@arndb.de>
References: <20100228054012.GA7583@gondor.apana.org.au> <1268217583.2880.2.camel@edumazet-laptop> <20100310104907.GA23752@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, paulmck@linux.vnet.ibm.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:60943 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580Ab0CJNmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 08:42:12 -0500
In-Reply-To: <20100310104907.GA23752@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 March 2010, Herbert Xu wrote:
> >
> > Its really rcu_dereference_bh() that could/should be used:
> > I see no problem changing
> > 
> > 
> >         local_bh_disable();
> >         ...
> >         rcu_read_lock();
> >         rcu_dereference(rt_hash_table[h].chain);
> >         rcu_read_unlock();
> >         ...
> >         local_bh_enable();
> 
> Why don't we just ignore the bh part for rcu_dereference?
> 
> After all it's call_rcu_bh and the other primitives that we really
> care about.  For rcu_dereference bh should make no difference
> whatsoever.

To add some background on what I'm doing, I'm currently adding
new address space modifier __rcu, __rcu_bh, __rcu_sched and __srcu
to the sparse annotations along the same lines that our __iomem,
__user and __percpu annotations work [1].

In order to check all cases, I want to ensure that you can not
use any of those pointers outside of rcu_dereference* and
rcu_assign_pointer, as well as making sure that you cannot pass
a pointer without these annotations in there, so we can catch
code that uses rcu_dereference without rcu_assign_pointer or
call_rcu.

Consequently, rcu_dereference also checks that the pointer is actually
__rcu, and passing an __rcu_bh pointer in would be considered as
wrong as passing a regular pointer by sparse.

With the work that Paul has done on lockdep, rcu_dereference_bh
now also checks that bottom halves are really disabled, which is
a very useful thing to check if you want to prove that the
call_rcu is really serialized with the use of the data.

	Arnd

[1] http://git.kernel.org/?p=linux/kernel/git/arnd/playground.git;a=shortlog;h=refs/heads/rcu-annotate
