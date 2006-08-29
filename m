From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 4/6] net neighbour: convert to RCU
Date: Tue, 29 Aug 2006 16:49:40 -0700
Message-ID: <20060829164940.13d03500@localhost.localdomain>
References: <20060828230748.827712918@localhost.localdomain>
	<20060828230915.587544687@localhost.localdomain>
	<20060829152816.GA24283@ms2.inr.ac.ru>
	<20060829112204.0cf5e866@localhost.localdomain>
	<20060829211722.GA27855@ms2.inr.ac.ru>
	<20060829144608.012f0d60@dxpl.pdx.osdl.net>
	<20060829221606.GA10285@ms2.inr.ac.ru>
	<20060829160022.552d46e0@dxpl.pdx.osdl.net>
	<20060829232126.GA18636@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36759 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965170AbWH2XuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 19:50:20 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060829232126.GA18636@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 Aug 2006 03:21:26 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!
> 
> > This should not be any more racy than the existing code.
> 
> Existing code is not racy.

Race 1: w/o RCU
					Cpu 0: is in neigh_lookup
						gets read_lock()
						finds entry
						++refcount to 2
						updates it
	Cpu 1: is in forced_gc()
		waits at write_lock()
						releases read_lock()
						drops ref count to 1.
		sees ref count is 1
		deletes it

Race 1: w RCU
					Cpu 0: is in __neigh_lookup
						updates it
	Cpu 1: is in forced_gc()
						leaves refcount=1
		sees ref count is 1
		deletes it


> 
> Critical place is interpretation of refcnt==1. Current code assumes,
> that when refcnt=1 and entry is in hash table, nobody can take this
> entry (table is locked). So, it can be unlinked from the table.
> 
> See? __neigh_lookup()/__neigh_lookup_errno() _MUST_ return alive
> and hashed entry. And will stay hashed until the reference is held.
> Or until neigh entry is forced for destruction by device going down,
> in this case referring dst entries will die as well.

Why must it be hashed, it could always get zapped just after the update.

> If dst cache grabs an entry, which is purged from table because for some
> time it had refcnt==1, you got a valid dst entry referring to dead
> neighbour entry.

Hmm.. Since this is a slow path, grabbing the write_lock on the neighbour
entry would block the gc from zapping it.

in __neigh_lookup()
		neigh_hold();
		write_lock(&n->lock);
		if (n->dead) {
			write_unlock()
			neigh_release()
			goto rescan;
		}

		write_unlock()





-- 
Stephen Hemminger <shemminger@osdl.org>
