From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 6/13] bridge: Add core IGMP snooping support
Date: Wed, 10 Mar 2010 10:41:32 +0100
Message-ID: <201003101041.32518.arnd@arndb.de>
References: <20100228054012.GA7583@gondor.apana.org.au> <201003092212.59627.arnd@arndb.de> <20100310021410.GD6203@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:49299 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755391Ab0CJJmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 04:42:20 -0500
In-Reply-To: <20100310021410.GD6203@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 10 March 2010 03:14:10 Paul E. McKenney wrote:
> On Tue, Mar 09, 2010 at 10:12:59PM +0100, Arnd Bergmann wrote:
>
> > I've just tried annotating net/ipv4/route.c like this and did not get
> > very far, because the same pointers are used for rcu and rcu_bh.
> > Could you check if this is a false positive or an actual finding?
> 
> Hmmm...  I am only seeing a call_rcu_bh() here, so unless I am missing
> something, this is a real problem in TREE_PREEMPT_RCU kernels.  The
> call_rcu_bh() only interacts with the rcu_read_lock_bh() readers, not
> the rcu_read_lock() readers.
> 
> One approach is to run freed blocks through both types of grace periods,
> I suppose.

Well, if I introduce different __rcu and __rcu_bh address space annotations,
sparse would still not like that, because then you can only pass the annotated
pointers into either rcu_dereference or rcu_dereference_bh.

What the code seems to be doing here is in some places

	local_bh_disable();
	...
	rcu_read_lock();
	rcu_dereference(rt_hash_table[h].chain);
	rcu_read_unlock();
	...
	local_bh_enable();

and in others

	rcu_read_lock_bh();
	rcu_dereference_bh(rt_hash_table[h].chain);
	rcu_read_unlock_bh();

When rt_hash_table[h].chain gets the __rcu_bh annotation, we'd have to
turn first rcu_dereference into rcu_dereference_bh in order to have a clean
build with sparse. Would that change be
a) correct from RCU perspective,
b) desirable for code inspection, and
c) lockdep-clean?

	Arnd
